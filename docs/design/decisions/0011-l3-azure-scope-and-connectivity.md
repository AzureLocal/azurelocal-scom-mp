# ADR 0011 — L3 Azure-side scope: agent-local checks vs. management server ARM probes

- **Status**: Accepted
- **Date**: 2026-05-05
- **Deciders**: @AzureLocal/azurelocal-scom-mp-maintainers

## Context

[ADR 0001](0001-scope-and-topology.md) defines three layers. [ADR 0004](0004-scom-discovery-strategy.md)
says L3 is discovered from a designated management server using `Az` PowerShell modules. But it
doesn't answer the harder question this project must resolve before Phase 3 authoring:

> **Which "Azure-side" signals actually require connecting to Azure, and which can be
> checked locally from the SCOM agent on the cluster node?**

This matters because:

- The SCOM agent on each Azure Local node is a standard Windows agent. It **can** make
  outbound HTTPS calls, but doing so from every node on every monitoring interval
  contradicts the SCOM architecture (agents monitor local state; management servers
  proxy external calls).
- Azure Local nodes typically operate in hardened network environments where
  `management.azure.com` is only reachable through a designated proxy or from a specific
  management host — not from every cluster node.
- Some "Azure connectivity" signals are actually surfaced **locally** by the Arc Connected
  Machine Agent and the DCMA without needing a separate outbound call.
- Some L3 signals (Key Vault expiry, RBAC drift, SPN credential) require ARM API access
  and **cannot** be surfaced from agent scripts on the cluster node.

Reference:
- [Azure Local — firewall requirements](https://learn.microsoft.com/en-us/azure/azure-local/concepts/firewall-requirements?view=azloc-2604)
  — outbound HTTPS-inspection prohibited; Arc Private Link Scopes unsupported; specific
  endpoints listed for each service (Arc, AMA, DCMA, Update Manager, etc.)
- [Azure Arc-enabled servers overview](https://learn.microsoft.com/en-us/azure/azure-arc/servers/overview)
  — the `HIMDS` (Hybrid Instance Metadata Service) and `AzureConnectedMachineAgent` services
  manage and report Arc connectivity state locally.
- [Azure Monitor Agent overview](https://learn.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-overview)
  — AMA manages its own connection lifecycle; its service state and last-write timestamp
  are available locally.

## The core question answered

### SCOM agents NEVER make direct ARM calls

This is the governing rule. No monitor script targeting `AzureLocal.Cluster`,
`AzureLocal.Node`, or any other L1/L2 class shall call `management.azure.com`. The
SCOM agent's job is to observe local state. ARM calls belong on the management server.

### "Soft L3" — locally observable Arc state (agent-side)

A significant amount of what looks like "Azure connectivity" is actually **surfaced
locally** by the agents Microsoft already ships with every Azure Local deployment. These
are checkable from the SCOM agent without any outbound ARM call:

| What to check | How to check it locally | SCOM class | Collection host |
|---|---|---|---|
| Arc Connected Machine Agent service state | `Get-Service "HIMDS"` + `Get-Service "GCArcService"` | `AzureLocal.Node` | Each cluster node |
| Arc agent connection status | Registry: `HKLM:\SOFTWARE\Microsoft\Azure Connected Machine Agent\Config` → `Status` | `AzureLocal.Node` | Each cluster node |
| Arc agent last-heartbeat age | Event log: `Microsoft-AzureArc-HybridAgent/Operational` channel — Event ID 50 (heartbeat sent) / Event ID 70 (connection error) | `AzureLocal.Node` | Each cluster node |
| AMA (AzureMonitorWindowsAgent) extension state | `Get-Service "AzureMonitorWindowsAgent"` + extension health event log `Microsoft-AzureMonitorWindowsAgent/Operational` | `AzureLocal.DCMA` | Each cluster node |
| DCMA (diagnostics extension) service state | `Get-Service "AzHCSvc"` (Azure HCI Service) | `AzureLocal.DCMA` | Each cluster node |
| DCMA last telemetry upload | Registry: `HKLM:\SOFTWARE\Microsoft\AzureStackHCI` → `LastConnectedTime` | `AzureLocal.DCMA` | Each cluster node |
| Required Arc extension installed | Registry: `HKLM:\SOFTWARE\Microsoft\Azure Connected Machine Agent\Extensions\<ExtensionName>` → `Status` | `AzureLocal.Node` | Each cluster node |
| Required Arc extension version currency | Same registry path → `Version` | `AzureLocal.Node` | Each cluster node |
| HCI Registration status | Registry: `HKLM:\SOFTWARE\Microsoft\AzureStackHCI` → `RegistrationStatus` + `DiagnosticLevel` | `AzureLocal.HCIRegistration` | Each cluster node |

All of the above are **L1/L2 signals on L1/L2 classes**, collected by the SCOM agent
on each node. They tell the operator "is this node's Azure connectivity healthy?" without
ever calling Azure.

### "Hard L3" — signals that genuinely require ARM access (management server only)

Only signals with **no on-box representation at all** belong here. If a local proxy
exists (registry, service state, event log), the signal moves to Tier A. This list
was reviewed against all known local data sources and trimmed accordingly.

These run from the designated management server only, targeting
`Class="Microsoft.SystemCenter.ManagementServer"`:

| Signal | ARM / Graph endpoint | SCOM class | Why it cannot be done locally |
|---|---|---|---|
| Key Vault Resource Health + secret expiry | `microsoft.keyvault/vaults` + KV data plane | `AzureLocal.Azure.KeyVault` | Pure Azure resource — no local representation |
| Storage Account Resource Health | `microsoft.storage/storageaccounts` | `AzureLocal.Azure.StorageAccount` | Pure Azure resource — no local representation |
| Required RBAC role assignments (SPN, MI, cluster identity) | ARM Authorization `roleAssignments` | `AzureLocal.Azure.RBAC` | Role assignments exist only in ARM — no local copy |
| SPN credential expiry | Microsoft Graph `servicePrincipals/{id}/passwordCredentials` | *(management server monitor)* | Microsoft Graph only — no local representation |
| Custom Location provisioning state | `microsoft.extendedlocation/customlocations` | `AzureLocal.Azure.CustomLocation` | ARM-only resource created by deployment stack |
| Logical Network provisioning state + IP pool usage | `microsoft.azurestackhci/logicalnetworks` | `AzureLocal.Azure.LogicalNetwork` | ARM-only resource managed by MOC |
| Update Manager maintenance config ARM linkage | `microsoft.maintenance/maintenanceconfigurations` | `AzureLocal.Azure.HCICluster` | Whether the ARM maintenance config is *linked* to the cluster is ARM-only; update state itself is available locally via `Get-SolutionUpdate` |
| DCR ARM-side association (supplementary) | ARM `dataCollectionRuleAssociations` via Resource Graph | `AzureLocal.Azure.HCICluster` | Whether the ARM-side association record still exists — the local AMA config (Tier A) tells you what AMA is doing, but can't detect if the ARM association was deleted |

**Signals removed from Tier B compared to the original draft:**

- **HCI cluster provisioning state** → moved to Tier A: `HKLM:\SOFTWARE\Microsoft\AzureStackHCI` → `RegistrationStatus` + `ConnectionIdentifier` + `LastConnectedTime` are valid local proxies. ARM is a cross-check, not the primary.
- **Arc Machine connection status (authoritative)** → already covered by Tier A `ArcAgent.ConnectionStatus.Local`. The ARM view *lags* the node's reality by up to one sync interval — the local registry is actually *more* timely. The ARM version was removed from Tier B to avoid false health-state discrepancy between Tier A and Tier B.

## Decision

We adopt a **two-tier L3 strategy**:

### Tier A — "Soft L3": Agent-local Arc health checks (required, blocking)

Every signal in the "soft L3" table above is implemented as a standard SCOM unit monitor
on the L1/L2 class it belongs to. These run on every cluster node, use the SCOM agent's
standard PowerShell/registry/event-log data sources, and have **Standard** health impact.
They directly answer "is this cluster's Azure connectivity working?" from on-prem.

Because these checks run locally, they:
- Work even if the management server has no network path to Azure
- Respond immediately when the Arc agent drops (service stops → monitor fires within one
  polling interval, default 5 min)
- Don't require any Azure credentials on the cluster nodes

### Tier B — "Hard L3": Management server ARM probes (optional by default, configurable to Standard)

L3 ARM probes run from the management server. The management server requires:
- `Az.Accounts`, `Az.Resources`, `Az.ResourceGraph` PowerShell modules
- A SCOM Run As account backed by a service principal with the role assignments defined
  in [ADR 0010](0010-cloud-prerequisites-contract.md)
- Outbound HTTPS to `management.azure.com`, `login.microsoftonline.com`, `graph.microsoft.com`

By default, all Tier B monitors ship with **`Impact = Limited`** (health visible, does not
propagate to the cluster's top-level health state). Operators can upgrade individual monitors
to `Impact = Standard` via the override pack. Rationale:

1. Not every SCOM deployment has a management server with Azure network access
2. KV secret expiry, RBAC drift, and SPN expiry are configuration warnings — important
   to know, but a missing KV secret doesn't stop the cluster from running
3. The SCOM MP should not require Azure credentials to function for operators who only
   want on-prem monitoring

### The "is the cluster connected to Azure?" answer lives in Tier A

The canonical SCOM health state for Azure connectivity comes from the agent-local checks:

- `ArcAgent.HimdsService.State` — is the HIMDS service running?
- `ArcAgent.ConnectionStatus.Local` — does the local registry report Connected?
- `ArcAgent.Heartbeat.EventLog.Age` — how old is the most recent heartbeat event?
- `DCMA.Service.State` + `DCMA.LastUpload.Age` — is telemetry flowing?

If any of these are unhealthy, the Node's Availability aggregate goes Degraded/Unhealthy,
which propagates to the Cluster. **No ARM call required.**

## Consequences

- **Positive**: SCOM MP works fully on deployments with no management-server-to-Azure
  connectivity. Tier A is fully self-contained.
- **Positive**: Tier A provides immediate response to Arc agent failures — no Azure round-trip.
- **Positive**: Tier B gives rich configuration drift detection (KV expiry, RBAC) for
  operators who do have management server Azure access.
- **Positive**: Operators can choose their L3 depth by flipping impact from Limited to
  Standard on the Tier B monitors — no MP fork required.
- **Negative**: Tier B requires `Az` modules + SPN credentials on the management server.
  Some operators will not configure this.
- **Negative**: The management server becomes a single point of collection for all L3 ARM
  data. If it goes offline, L3 Tier B monitors show Unknown.
- **Neutral**: Tier B checks run on a 1-hour polling interval (see ADR 0004) — not real-time.
  This is acceptable for configuration drift, not acceptable for availability signals (which
  is why availability lives in Tier A).

## Additional Tier A signals — locally checkable, previously missing

These signals were identified during Tier B review as locally checkable but not
previously included in the Tier A list. All run on the SCOM agent on each node
or on a designated cluster node (cookdown target).

| What to check | How to check it locally | SCOM class |
|---|---|---|
| **HCI cluster registration status (local proxy)** | Registry `HKLM:\SOFTWARE\Microsoft\AzureStackHCI` → `RegistrationStatus`, `LastConnectedTime`, `ConnectionIdentifier` | `AzureLocal.HCIRegistration` |
| **LCM / SolutionUpdate state** | `Get-SolutionUpdate` (update pending/failed state) + `Get-SolutionUpdateEnvironment` (LCM health) | `AzureLocal.LCMState` |
| **Environment Checker results** | `Invoke-AzureStackHCIEnvironmentChecker` — ships on every cluster; returns pass/fail per check category (network, storage, Arc, update) | `AzureLocal.Cluster` (run at discovery cadence) |
| **Cloud Witness reachability** | `Get-ClusterQuorum` → witness type; if cloud witness: `Test-NetConnection <account>.blob.core.windows.net -Port 443` | `AzureLocal.Cluster` |
| **Hyper-V host health** | `Get-VMHost` health state + `Get-VMSwitch` NIC binding presence | `AzureLocal.Node` |
| **DCB / QoS policy conformance** | `Get-NetQosPolicy`, `Get-NetQosFlowControl`, `Get-NetQosTrafficClass` — verify PFC enabled on correct priorities, ETS bandwidth allocation per Network ATC intent | `AzureLocal.NetworkAdapter` |
| **S2D cache dirty pages percent** | Perf counter `\Cluster Storage Cache Stores(*)\Cache Dirty Pages %` | `AzureLocal.StorageTier` |
| **Storage rebuild job progress** | `Get-StorageJob | Where-Object JobState -eq 'Running'` → `PercentComplete` + elapsed time | `AzureLocal.StoragePool` |
| **DCR local AMA config present** | Registry `HKLM:\SOFTWARE\Microsoft\Azure Monitor Agent\` → active DCR list present and non-empty | `AzureLocal.Node` (supplements Tier B ARM association check) |

## Required extensions to monitor (Tier A — locally checkable)

These extensions are required for a supported Azure Local deployment. The MP checks each one:

| Extension | Service / Registry key | Signal |
|---|---|---|
| `AzureMonitorWindowsAgent` | `AzureMonitorWindowsAgent` service + `Microsoft-AzureMonitorWindowsAgent/Operational` channel | `Extension.AMA.State` |
| `AzureEdgeTelemetryAndDiagnostics` (DCMA) | `AzHCSvc` service | `Extension.DCMA.State` |
| `AzureConnectedMachineAgent` (Arc for Servers) | `HIMDS` + `GCArcService` services | `ArcAgent.HimdsService.State`, `ArcAgent.GCArcService.State` |
| `WindowsOSSettings` (Arc extension) | Registry probe | `Extension.OsSettings.Installed` |

References:
- [Azure Local — firewall requirements](https://learn.microsoft.com/en-us/azure/azure-local/concepts/firewall-requirements?view=azloc-2604)
- [Azure Monitor Agent network / DCE settings](https://learn.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-data-collection-endpoint?tabs=PowerShellWindows)
- [Azure Local Insights — single cluster](https://learn.microsoft.com/en-us/previous-versions/azure/azure-local/manage/monitor-hci-single?view=azloc-2604&tabs=22h2-and-later)
- [Azure Local — required permissions](https://learn.microsoft.com/en-us/azure/azure-local/deploy/deployment-arc-register-server-permissions?view=azloc-2604)

## Alternatives considered

- **No L3 monitoring at all** — rejected: Tier A local checks are low cost and directly
  answer the "is Arc healthy?" question operators ask every day. Not implementing them
  leaves a real gap.
- **All L3 from management server** — rejected: forces every operator to provision Azure
  credentials, breaks deployments without management-server-to-Azure connectivity, and
  creates ARM rate-limit exposure from many agents.
- **L3 via ARM from each cluster node** — rejected: violates SCOM architecture (agents
  observe local state), adds Azure credential management to 4–16 nodes, creates ARM
  throttling risk, and violates most customer firewall policies.
- **L3 Tier B with Standard impact by default** — rejected: would make the MP health state
  "Unknown" for operators who haven't provisioned management server Azure credentials, even
  though on-prem monitoring is fully functional.

## References

- ADR 0001 — [Scope & topology](0001-scope-and-topology.md)
- ADR 0002 — [Primary signal source](0002-signal-source.md)
- ADR 0004 — [SCOM discovery strategy](0004-scom-discovery-strategy.md)
- ADR 0010 — [Cloud prerequisites contract](0010-cloud-prerequisites-contract.md)
- [Azure Local — firewall requirements](https://learn.microsoft.com/en-us/azure/azure-local/concepts/firewall-requirements?view=azloc-2604)
- [Azure Arc-enabled servers overview](https://learn.microsoft.com/en-us/azure/azure-arc/servers/overview)
- [Azure Monitor Agent overview](https://learn.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-overview)
- [SCOM — Heartbeat overview](https://learn.microsoft.com/en-us/system-center/scom/manage-agent-heartbeat-overview?view=sc-om-2025)
- [Kevin Holman — SCOM 2025 Security Account Matrix](https://kevinholman.com/2024/11/25/scom-2025-security-account-matrix/)
