# ADR 0038 — SCOM-to-ServiceNow connector boundary

- **Status**: Accepted
- **Date**: 2026-08-13
- **Deciders**: Hybrid Solutions Cloud maintainers

## Context

ServiceNow ITOM Event Management provides separate SCOM Events and SCOM Metrics connector
definitions. The Events connector runs through a Windows MID Server and uses PowerShell plus native
SCOM client assemblies. It can synchronize SCOM alert lifecycle in both directions. The Metrics
connector reads `OperationsManagerDW` through JDBC and requires Metric Intelligence.

Embedding ServiceNow credentials or behavior in either platform Management Pack would couple the
monitoring products to a specific ITSM platform and complicate upgrades, removal, and customer
ownership.

## Decision

- The Azure Local and Hyper-V sealed Management Packs remain connector-neutral.
- SCOM-to-ServiceNow is an optional integration package with public mapping contracts, validation,
  and operator guidance; it contains no credentials and performs no unattended ServiceNow changes.
- The ServiceNow SCOM Events connector through a Windows MID Server is the preferred alert path.
- Initial deployments are read/pull with bidirectional updates disabled. Bidirectional close,
  reopen, and ticket-ID behavior requires a separate acceptance test and change approval.
- Connector collection and ServiceNow event rules use explicit Management Pack/target allow-lists.
  Never activate a default all-alert feed in a production management group.
- SCOM alert GUID is the source event identity. Stable correlation additionally records platform,
  Management Pack element ID, stable monitored-object identity, and condition identity.
- Monitoring alerts must auto-resolve. Event-rule alerts require explicit lifecycle design because
  a one-time event has no inherent recovery event.
- SCOM Metrics remains out of the default integration. It is evaluated only when Metric Intelligence
  is licensed and a measured use case justifies Data Warehouse access and ingestion volume.

## Implementation evidence

The accepted boundary is implemented as two separate secret-free connector profiles, one normalized
event mapping contract, a PowerShell 7 offline validator, and public configuration/lifecycle
guidance. The validator also builds both product MP suites and checks the alert behaviors the
connector contract depends on. No custom connector, MID Server installation, ServiceNow mutation,
or credential provisioning has been implemented. Live connector certification remains the next
gate.

## Consequences

- Connector credentials stay in the ServiceNow credential store or Windows service identity.
- Separate allow-lists preserve the independent Azure Local and Hyper-V product boundaries.
- ServiceNow 2025/SCOM 2025 compatibility requires vendor confirmation: current ServiceNow
  documentation describes 2025 assembly files but its supported-version list ends at SCOM 2022.
- CMDB binding, maintenance behavior, connector outage/replay, and lifecycle synchronization require
  a real SCOM/ServiceNow lab.

## References

- [ServiceNow SCOM connector configuration](https://www.servicenow.com/docs/r/it-operations-management/event-management/t_EMConfigureSCOMConnector.html)
- [SCOM product connector subscriptions](https://learn.microsoft.com/en-us/system-center/scom/manage-integration-config-integration?view=sc-om-2025)
