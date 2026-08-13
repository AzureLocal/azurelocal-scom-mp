---
title: SCOM to ServiceNow integration
description: Design, mapping, security, configuration, validation, and operating guidance for forwarding Azure Local and Hyper-V SCOM alerts to ServiceNow Event Management.
---

# SCOM to ServiceNow integration

The integration uses the ServiceNow **SCOM (Events)** connector on a Windows MID Server. The
Management Packs stay independent and connector-neutral. ServiceNow owns connector credentials,
CMDB binding, event rules, correlation, incident policy, and optional bidirectional behavior.

::: warning Development baseline
The two product-specific profiles, mapping contract, administration guidance, and repository tests
are implemented. This is not a deployed connector. A real ServiceNow ITOM Event Management
instance, Windows MID Server, SCOM management group, compatible SCOM client assemblies, and lab
credentials are required to configure and certify it.
:::

## Build-versus-configure decision

ServiceNow already supplies the SCOM Events connector used by this design. We therefore need to
**configure and validate** that connector, not write a custom connector for the first release. The
repository adds the product-specific contract ServiceNow cannot infer for us: namespace
allow-lists, stable identity, severity mapping, lifecycle policy, safe defaults, and acceptance
tests.

The repository does not install a MID Server, upload Microsoft assemblies, create credentials,
change a ServiceNow instance, or enable bidirectional write-back. Those are controlled lab or
customer-environment actions.

## Supported architecture

```text
Azure Local MP alerts ─┐
                       ├─ SCOM management group ─ Windows MID Server ─ SCOM Events connector
Hyper-V MP alerts ─────┘                                        │
                                                               ▼
                                            ServiceNow events → alerts → incidents
                                                      │
                                                      └─ CMDB binding/correlation
```

The ServiceNow connector collects alerts using PowerShell and native SCOM client assemblies copied
from the SCOM server. The MID Server must be Windows-based, domain-aligned with SCOM, time-zone
aligned with SCOM, able to reach the SCOM API, and run with the permissions documented by
ServiceNow. SCOM Metrics is a separate connector and is not enabled by this baseline.

## Version gate

The current ServiceNow Australia documentation lists SCOM 2007, 2012, 2016, 2019, and 2022 in its
supported-version table. The same page includes a SCOM 2025 assembly list. Because those statements
are inconsistent, treat SCOM 2025 as **unverified** until ServiceNow confirms support for the exact
connector release in use.

The documentation update in August 2026 still shows that mismatch. Confirm the exact installed
ServiceNow connector release and SCOM build before enabling collection; do not infer SCOM 2025
support from the assembly list alone.

## Security model

- Store credentials only in the ServiceNow credential store or the Windows MID Server service
  identity; never in repository profiles, scripts, logs, or Management Packs.
- Grant the MID Server identity the least SCOM API permissions that support the selected direction.
- Start with bidirectional behavior disabled.
- Set debug and raw-payload logging off after time-boxed troubleshooting.
- Restrict network access from the MID Server to the required SCOM and ServiceNow endpoints.
- Audit connector configuration, credential rotation, lifecycle writes, and failed/replayed batches.

ServiceNow currently documents local administrator rights for the MID Server service identity to
run connector PowerShell. That is a product prerequisite with security impact, not a reason to
broaden rights elsewhere.

## Collection boundary

Create explicit allow-lists for these Management Pack namespaces:

| Product | Allowed namespace | Primary targets |
|---|---|---|
| Azure Local | `HybridSolutionsCloud.AzureLocal.*` | Node role, deployment service, and Azure Local topology classes |
| Hyper-V | `HybridSolutionsCloud.HyperV.*` | Host role, deployment service, VM, cluster, storage, and network classes |

Do not begin with “all alerts.” ServiceNow documents limiting this pull connector by creating a
SCOM group, scoping a SCOM user role to that group, and assigning only that role to the connector
identity. Translate each profile's namespace boundary into product-owned SCOM groups and scoped
roles, then prove that an unrelated SCOM alert is excluded. Use a SCOM product-connector
subscription only if the installed integration actually registers a product connector; the native
ServiceNow pull connector does not make that assumption part of this design.

## Event and alert mapping

| ServiceNow concept | SCOM source | Contract |
|---|---|---|
| Source | Connector constant | `SCOM` |
| Source instance | Management group | Stable management-group identity; no credentials |
| Source event ID | Alert GUID | Immutable identity for update/close of the same SCOM alert |
| Message key | Platform + element ID + stable monitored-object identity + condition | Stable across repeated observations; never display text alone |
| Node / resource | Principal name and monitored-object path | Used with class and key properties for CMDB binding |
| Type | Management Pack/monitor/rule element ID | Stable technical condition identity |
| Severity | SCOM severity | Critical → Critical, Warning → Warning, Information → Informational; confirm local policy |
| Description | Alert name, description, and parameters | Human-readable context, not the deduplication key |
| Additional info | MP name/version, class, object keys, monitor/rule, health state, knowledge URL | Structured enrichment with no secrets |
| Resolution | SCOM alert resolution state | Auto-resolving monitor alerts close naturally; event alerts need an explicit policy |
| Ticket ID | SCOM alert ticket field | Optional return path when bidirectional behavior is approved |

## Lifecycle policy

1. Poll an allow-listed New alert and create/update one ServiceNow event/alert.
2. Repeated polls update the same record by SCOM alert GUID.
3. A monitor alert auto-resolving in SCOM closes the ServiceNow alert on the next successful cycle.
4. An event-rule alert is not auto-closed merely because the event stopped; use an operator,
   timeout, correlation, or companion recovery policy.
5. Maintenance mode should prevent new actionable SCOM alerts; prove the connector does not replay
   suppressed maintenance noise afterward.
6. Bidirectional close/reopen and ticket-ID synchronization stay disabled until tested for both
   monitor-generated and event-rule alerts.

ServiceNow documents that SCOM resolution closes the ServiceNow alert, manual ServiceNow close can
close SCOM when bidirectional behavior is active, reopen can update SCOM, and an associated incident
number can populate SCOM ticket ID. Incident resolution itself does not resolve SCOM.

## Configuration sequence

1. Confirm ITOM Event Management licensing and connector release compatibility.
2. Install and validate a Windows MID Server in the SCOM domain and time zone.
3. Create a dedicated least-privilege identity and document the unavoidable local-admin prerequisite.
4. Copy only the exact SCOM client assemblies required by the connector release into ServiceNow as
   documented; do not commit or redistribute Microsoft DLLs.
5. Create the SCOM Events connector instance with a 7-day initial sync, 500-alert batch, debug off,
   raw-payload logging off, and bidirectional behavior off.
6. Configure explicit Azure Local and/or Hyper-V allow-lists and CI binding/event rules.
7. Test the connector before activating it.
8. Run the acceptance suite below and capture evidence.
9. Enable bidirectional behavior only through a separate reviewed change.

## Acceptance suite

- allow-listed Critical and Warning monitor alerts create correctly bound records;
- unrelated SCOM alerts do not cross the boundary;
- repeated collection updates rather than duplicates;
- SCOM auto-resolution closes the matching ServiceNow alert;
- event-rule alerts follow the explicit non-auto-close policy;
- maintenance suppresses rather than delays/replays noise;
- MID Server/ServiceNow outage recovery is bounded, ordered, and replay-safe;
- credential failure is visible and does not expose secret material;
- connector lag, last success, error count, and backlog are observable;
- bidirectional close/reopen/ticket behavior, if approved, affects only the intended alert; and
- uninstalling the integration leaves both Management Packs functional.

## Repository artifacts

The source directory contains secret-free connector profiles, a normalized mapping contract, and a
PowerShell validator. These are review/configuration inputs, not an automated ServiceNow deployment.

| Artifact | Purpose |
|---|---|
| `config/azure-local.connector-profile.json` | Azure Local namespace, collection, and lifecycle defaults |
| `config/hyper-v.connector-profile.json` | Independent Hyper-V namespace, collection, and lifecycle defaults |
| `mappings/scom-event-contract.json` | Stable alert identity, field, severity, and replay contract |
| `scripts/Test-ScomServiceNowIntegration.ps1` | Offline package, MP alert-behavior, mapping, and secret-policy validation |

```powershell
& ./src/integrations/servicenow/scom/scripts/Test-ScomServiceNowIntegration.ps1
```

## Next lab session

1. Record the SCOM and ServiceNow releases, installed Event Management connector version, and
   licensing.
2. Prepare a Windows MID Server in the SCOM domain and time zone with the documented service
   identity permissions.
3. Upload only the matching SCOM client assemblies through the supported ServiceNow process.
4. Create the SCOM Events connector with debug, raw payload logging, and bidirectional write-back
   disabled.
5. Apply one product allow-list first, then prove create, update, auto-close, exclusion,
   maintenance, outage replay, and credential-failure behavior.
6. Repeat with the other product profile; only then evaluate combined collection and correlation.
7. Capture results in the validation matrix before deciding whether deployment automation or a
   custom integration is justified.

## References

- [Configure the ServiceNow SCOM connector](https://www.servicenow.com/docs/r/it-operations-management/event-management/t_EMConfigureSCOMConnector.html)
- [Limit collected SCOM alerts to specific SCOM groups](https://www.servicenow.com/docs/r/it-operations-management/event-management/t_EMAssignRoleSCOMGroup.html)
- [Configure a SCOM product connector subscription](https://learn.microsoft.com/en-us/system-center/scom/manage-integration-config-integration?view=sc-om-2025)
