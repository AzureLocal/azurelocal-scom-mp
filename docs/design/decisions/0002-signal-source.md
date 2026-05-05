# ADR 0002 — Primary signal source: Azure Local PowerShell APIs + ARM/Resource Graph

- **Status**: Accepted
- **Date**: 2026-05-05
- **Deciders**: @AzureLocal/azurelocal-scom-mp-maintainers

## Context

Both tracks (SCOM MP, Azure Monitor Health Model) need to know **where each signal comes
from**. The choice has to be:

- **Authoritative** — the same data Microsoft uses to render its own portals
- **Stable** — survives Azure Local feature updates (currently shipping `azloc-2604`)
- **Available on the box** *and* **available cloud-side** — different parts of the model
  live in different places (see [ADR 0001](0001-scope-and-topology.md))
- **Compatible with the customization story** — operators must be able to override what
  signals the model uses without forking

Signal source candidates per layer:

**Layer 1 (on-prem):**

- `Get-Cluster*` / `Get-Storage*` / `Get-NetIntent*` cmdlets exposed by Azure Local
- WMI/CIM (`MSCluster_*`, `MSFT_StoragePool`, `Win32_*`)
- Windows Event Log channels (`Microsoft-Windows-Health/Operational`,
  `Microsoft-Windows-SDDC-Management/Operational`)
- Performance counters
- DCMA (Telemetry & Diagnostics agent) metrics surfaced under
  `AzureStackHCI/clusters` Metrics Explorer

**Layer 2 (cluster-resident platform):**

- `az arcappliance` for Resource Bridge
- MOC service state
- Service control manager state for DCMA / AMA / Cloud Agent

**Layer 3 (Azure-side):**

- ARM REST (per-resource property `provisioningState`, `connectivityStatus`, etc.)
- Resource Graph queries
- Resource Health stream
- Activity Log
- Microsoft Graph (for SPN credential expiry)

## Decision

We adopt a **layer-specific signal source policy**:

### Layer 1 — Azure Local PowerShell as the canonical source

- All cluster/storage/network signals derive from **PowerShell cmdlets** in the
  `FailoverClusters`, `Storage`, `NetworkATC`, and `StorageReplica` modules.
- WMI is permitted only where a PowerShell cmdlet doesn't expose the field
  (e.g., `Win32_OperatingSystem.LastBootUpTime`).
- **Event log** is permitted as a *supplementary* source via KQL on the
  `Microsoft-Windows-Health/Operational` and `Microsoft-Windows-SDDC-Management/Operational`
  channels — but never as the *only* source for a state-bearing signal.
- **Performance counters** are permitted for time-series signals (CPU, memory, IOPS, latency).

### Layer 2 — Service state + Resource Health

- Resource Bridge / MOC: ARM resource state on
  `Microsoft.ResourceConnector/appliances` plus Resource Health stream.
- DCMA / AMA / Cloud Agent: Windows service state on each node + KQL `Heartbeat` for
  cloud-side staleness.

### Layer 3 — ARM + Resource Health + Activity Log first; Resource Graph for fan-out

- **Resource Health** is the first signal on every Azure resource entity — it's free,
  authoritative, and Microsoft surfaces it in their own portals.
- **Activity Log** is the second signal — for adverse configuration events (failed
  ARM operations, RBAC removal, etc.).
- **Resource Graph** queries are used for *fan-out* across multiple resources (e.g.,
  "all DCRs associated with this cluster's nodes").
- **Microsoft Graph** is the canonical source for SPN credential expiry and identity
  existence (no other service exposes this).

### Why DCMA metrics as supplementary, not primary

DCMA exposes 60+ Azure Local metrics under `AzureStackHCI/clusters`. They're useful for
the Azure Monitor track because they're already-aggregated cloud-side. But:

- They're not available on the SCOM track without round-tripping through Azure
- They lag PowerShell signals (DCMA collects every 5 minutes by default)
- They don't cover all the signals we need (e.g., Network ATC intent state)

So DCMA is the **fallback** for L1 signals on the Azure Monitor track when we don't want
to build a custom KQL query, but PowerShell is the authoritative source for the SCOM track.

## Consequences

- **Positive**: PowerShell is what Microsoft's own portals run on for Azure Local — the
  same data, same authority. Stable across Azure Local updates because Microsoft owns the
  cmdlet contracts.
- **Positive**: Resource Health + Activity Log give us "free" L3 signals on every Azure
  resource — high coverage with zero custom code.
- **Positive**: The `AzureStackHCI` resource type publishes Resource Health states
  (Available / Degraded / Unavailable) that map directly to our Healthy / Degraded /
  Unhealthy states.
- **Negative**: Two different signal-collection runtimes (PowerShell on each cluster node
  for L1+L2; ARM/Graph from a designated management server or cloud-side compute for L3).
  Operators have to deploy and maintain both.
- **Negative**: PowerShell signals require credentialed access to each node (SCOM Run As
  account; Arc Custom Script extension on the Azure Monitor track).
- **Neutral**: Some signals are available from multiple sources (e.g., volume health from
  both `Get-Volume` and DCMA). We pin one canonical source per signal in the
  [Signal Catalog](../signal-catalog.md) — second source is documented as an alternative.

## Alternatives considered

- **WMI/CIM as primary** — rejected: PowerShell cmdlets cover the same ground with better
  ergonomics and a stable contract. WMI namespaces have churned across Windows Server
  versions; the new Azure Local cmdlets haven't.
- **DCMA metrics as primary on both tracks** — rejected: requires the SCOM track to
  round-trip through Azure (defeats the point of an on-prem MP), and DCMA doesn't cover
  all signals we need.
- **Event log as primary** — rejected: KQL-on-events for state-bearing signals is fragile
  (event format changes across versions, missing events ≠ healthy).
- **Pure ARM/Resource Graph for L1** — rejected: ARM doesn't expose volume free space,
  CPU %, IOPS latency, or Network ATC intent state. Insufficient coverage.

## References

- [Azure Local — PowerShell modules](https://learn.microsoft.com/en-us/azure/azure-local/manage/powershell?view=azloc-2604)
- [Azure Local — Telemetry & Diagnostics agent (DCMA)](https://learn.microsoft.com/en-us/previous-versions/azure/azure-local/manage/monitor-hci-single?view=azloc-2604&tabs=22h2-and-later)
- [Resource Health overview](https://learn.microsoft.com/en-us/azure/service-health/resource-health-overview)
- [Azure Resource Graph overview](https://learn.microsoft.com/en-us/azure/governance/resource-graph/overview)
- [Brian Wren, "Monitoring Scripts" (SC 2012 R2 module 20)](https://learn.microsoft.com/en-us/shows/system-center-2012-r2-operations-manager-management-packs/)
