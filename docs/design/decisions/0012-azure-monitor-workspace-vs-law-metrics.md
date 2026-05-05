# ADR 0012 — Azure Monitor Workspace vs Log Analytics Workspace: metrics routing for the Azure Monitor health model

- **Status**: Accepted
- **Date**: 2026-05-05
- **Deciders**: @AzureLocal/azurelocal-scom-mp-maintainers

## Context

This ADR applies **exclusively to the Azure Monitor health model track**. The SCOM MP
is unaffected — it queries agent-local data sources, not Azure Monitor workspaces.

Azure Monitor now maintains two distinct telemetry stores:

| Store | Type | Query language | Destination in DCR | Typical contents |
|---|---|---|---|---|
| **Log Analytics Workspace (LAW)** | Log store (append-only, columnar) | KQL | `destinations.logAnalytics` | Event logs, performance counter rows (`Perf` table), Heartbeat, custom log tables |
| **Azure Monitor Workspace (AMW)** | Metrics store (time-series, compressed) | PromQL / Metrics API | `destinations.monitoringAccounts` | Prometheus-format metrics, custom metrics, (optionally) platform metrics for ARC resources |

Before AMW was available (~2022), AMA wrote **everything** — including performance counter data
— into the LAW `Perf` table. The Insights DCR for Azure Local still ships with this pattern:
five performance counters land in `Perf`, queryable via KQL
(`Perf | where CounterName == "% Processor Time"`).

Many customer deployments are **still on this legacy pattern**. AMW may not even be created,
let alone have the DCMA or AMA DCR routed to it.

The modern pattern, which Microsoft is actively driving:

- AMA → logs and events → **LAW** (`Event`, `Heartbeat`, `WindowsEvent`, `Syslog`, ...)
- AMA → performance metrics → **AMW** (via a separate DCR `destinations.monitoringAccounts` stream)
- DCMA platform metrics → native **Azure Monitor metrics store** (always — DCMA never routes to LAW)

The Azure Monitor health model can target signals from **both** stores. The problem this ADR
resolves is: which store do we query for performance signals, and what do we do when a
deployment hasn't split its metric routing yet?

References:
- [Azure Monitor Workspace overview](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/azure-monitor-workspace-overview)
- [Azure Monitor Workspace — collect Prometheus metrics from ARC servers](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/prometheus-metrics-overview)
- [Data collection rules overview](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/data-collection-rule-overview)
- [Azure Local — HCI Insights performance counters](https://learn.microsoft.com/en-us/previous-versions/azure/azure-local/manage/monitor-hci-single?view=azloc-2604&tabs=22h2-and-later#performance-counters)
- [DCMA / Telemetry & Diagnostics agent metrics](https://learn.microsoft.com/en-us/azure/azure-local/concepts/monitoring-overview?view=azloc-2604#metrics)
- [Azure Monitor Workspace — manage access](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/azure-monitor-workspace-manage)

## The two routing topologies

### Topology A — Legacy (metrics in LAW `Perf` table)

All AMA data — logs and performance counters — routes to a single LAW. No AMW exists or
the AMW is not referenced by any DCR targeting this cluster.

```
AMA → DCR (logAnalytics destination) → LAW
  writes: Event, Heartbeat, Perf (5 counters from Insights)
DCMA → native metrics store (always, regardless of topology)
```

Queries performance signals via KQL on the `Perf` table:
```kql
Perf
| where ObjectName == "Processor" and CounterName == "% Processor Time"
| where InstanceName == "_Total"
| summarize avg(CounterValue) by Computer, bin(TimeGenerated, 5m)
```

### Topology B — Modern (metrics split to AMW)

AMA logs route to LAW; AMA performance counter metrics route to a separate
`monitoringAccounts` DCR destination pointing at an AMW instance.

```
AMA → DCR (logAnalytics destination)   → LAW  (Event, Heartbeat)
AMA → DCR (monitoringAccounts dest.)   → AMW  (performance counters as Prometheus series)
DCMA → native metrics store (always)
```

Queries performance signals via PromQL (or Metrics Query API targeting the AMW):
```promql
avg(windows_cpu_time_total{mode="idle"})
```
or via Metrics API on the AMW endpoint.

## Decision

### 1. The health model MUST detect topology at deployment time

The Bicep module that deploys the health model checks the DCR(s) associated with the
cluster's nodes for a `destinations.monitoringAccounts` stream. If found and linked to
an AMW, Topology B is active; otherwise Topology A is assumed.

The detection logic:
```bicep
// Pseudo-code: scan DCR destinationss for monitoringAccounts reference
var dcrs = [existing DCRs found via ARG on the cluster's nodes]
var hasAmwDestination = any(dcrs, dcr => length(dcr.properties.destinations.monitoringAccounts) > 0)
var metricsTopology = hasAmwDestination ? 'AMW' : 'LAW'
```

The resolved topology is stored as a **deployment output** (`metricsTopology`) and
referenced by the health model Bicep to wire the correct signal DSL for performance
monitors.

### 2. Topology B (AMW) is preferred when available

When AMW is detected, performance metric signals in the health model use AMW queries.
This is preferred because:

- AMW provides native time-series compression (lower query cost at scale)
- PromQL is more expressive for aggregating across nodes than KQL + `Perf`
- AMW retains metrics independently of the LAW retention/pricing tier
- Microsoft's roadmap is moving away from writing metrics to the `Perf` table

### 3. Topology A (LAW `Perf`) remains fully supported

No deployment is penalized for not having an AMW. The health model ships with both
query variants for every performance signal. The `Perf`-based KQL variant is the
fallback (and the default for most current Azure Local deployments).

The prerequisites.md marks AMW as **Recommended** (not Blocking) — a deployment without
an AMW is fully functional, just using the `Perf` table path.

### 4. Dual-topology signal resolution rule

For every performance signal in the catalog that can come from either store:

1. **If AMW is configured**: use AMW PromQL / Metrics Query API
2. **Else**: fall back to KQL on `Perf` (or DCMA native metrics for DCMA-sourced signals)

DCMA platform metrics (the `AzureStackHCI/clusters` namespace in Metrics Explorer) are
**always** queried from the native metrics store — they never go through LAW `Perf`.
DCMA routing is unaffected by this ADR.

### 5. Signal catalog marks which store each signal resolves from

The signal catalog column "Azure Monitor source" is updated to show
`AMW (fallback: LAW Perf)` for AMA-sourced performance metrics, and
`DCMA native metrics` for DCMA-sourced metrics.

## Signals affected by topology detection

Performance signals that exist in **both** topologies:

| Signal | LAW `Perf` KQL | AMW PromQL |
|---|---|---|
| `Node.CPU.Percent` | `Perf \| where CounterName == "% Processor Time" and InstanceName == "_Total"` | `100 - avg(rate(windows_cpu_time_total{mode="idle"}[5m])) * 100` |
| `Node.Memory.Percent` | `Perf \| where CounterName == "Available Bytes" and ObjectName == "Memory"` | `1 - (windows_memory_available_bytes / windows_cs_physical_memory_bytes)` |
| `Node.Network.BytesTotal` | `Perf \| where CounterName == "Bytes Total/sec" and ObjectName == "Network Interface"` | `sum by (computer)(rate(windows_net_bytes_total[5m]))` |
| `Node.RDMA.InboundBytes` | `Perf \| where CounterName == "RDMA Inbound Bytes/sec"` | `rate(windows_rdma_inbound_bytes_total[5m])` |
| `Node.RDMA.OutboundBytes` | `Perf \| where CounterName == "RDMA Outbound Bytes/sec"` | `rate(windows_rdma_outbound_bytes_total[5m])` |

Signals that are **always LAW** regardless of topology (log-based, not metrics):

- All `Event`-based signals (cluster health events, Arc heartbeat events, SDDC events)
- `Heartbeat` (AMA heartbeat → LAW)
- Storage and volume operational status (from `Microsoft-Windows-Health/Operational` → `Event`)

Signals that are **always DCMA native metrics** regardless of topology:

- `storagepool_health`, `storagepool_capacity_used_percentage`, `storagepool_failed_disks`
- `volume_health`, `volume_free_space_percentage`, `volume_latency_ms`
- `cluster_status`, `cluster_node_count`
- All other `AzureStackHCI/clusters` namespace metrics from the DCMA

## Azure Monitor Workspace prerequisites (when Topology B)

If an AMW is in use, the health model managed identity requires:

- `Monitoring Reader` on the AMW (same permission pattern as on the LAW — see
  [ADR 0010](0010-cloud-prerequisites-contract.md))
- The AMW must be added to the Azure Service Group alongside the LAW

DCR for AMW must not replace the Insights DCR. It should be a **supplementary** DCR that
adds the `monitoringAccounts` destination to the counter streams already collected. This
avoids breaking the Insights workbooks which depend on the original DCR.

## Health model signal DSL pattern

Each performance monitor in the health model Bicep is parameterized by a `metricsSource`
enum that the detection block populates:

```bicep
// Resolved by topology detection; passed to each monitor module
param metricsSource 'AMW' | 'LAW' = 'LAW'  // default to legacy

// Monitor module example (Node CPU)
module nodeCpuMonitor './monitors/node-cpu.bicep' = {
  params: {
    metricsSource: metricsSource
    amwResourceId: metricsSource == 'AMW' ? amw.id : ''
    lawResourceId: law.id
    cpuWarningPct: cpuWarningPct
    cpuCriticalPct: cpuCriticalPct
  }
}
```

Within `node-cpu.bicep`, the signal expression switches on `metricsSource`:

```bicep
var signalExpression = metricsSource == 'AMW'
  ? '100 - avg(rate(windows_cpu_time_total{mode="idle",computer=~"${nodeName}"}[5m])) * 100'
  : 'Perf | where Computer == "${nodeName}" | where ObjectName == "Processor" and CounterName == "% Processor Time" and InstanceName == "_Total" | summarize avg(CounterValue) by bin(TimeGenerated, 5m)'
```

## Consequences

- **Positive**: Deployments on the legacy pattern (most current Azure Local customers)
  get a fully functional health model without any additional setup.
- **Positive**: Deployments that have adopted or adopt AMW get a leaner, cheaper, and
  more expressive metrics path automatically.
- **Positive**: The migration path is clear: create an AMW, add `monitoringAccounts`
  destination to the AMA DCR, re-deploy the health model Bicep — the topology detection
  picks up the change.
- **Negative**: Dual query variant maintenance — every performance signal needs to be
  tested against both KQL and PromQL paths.
- **Negative**: Topology detection adds complexity to the Bicep deploy module (ARG query
  at deploy time).
- **Neutral**: DCMA metrics are unaffected — they always come from the native metrics
  store, never from LAW or AMW.

## Alternatives considered

- **AMW only, mandate migration** — rejected: would block most current Azure Local
  deployments. The LAW `Perf` fallback is essential for day-1 adoption.
- **LAW only, never use AMW** — rejected: leaves performance on the table for customers
  who have already adopted AMW; also misaligned with Microsoft's direction on metrics
  routing.
- **Always query both, merge results** — rejected: more expensive, complex, and creates
  ambiguity when the same metric appears in both stores (e.g., double-alerting).
- **Runtime detection (query both, pick non-empty)** — rejected: LAW `Perf` will always
  have data (the Insights DCR always sends the 5 counters there), so "non-empty" doesn't
  distinguish the topology.

## References

- ADR 0002 — [Primary signal source](0002-signal-source.md)
- ADR 0010 — [Cloud prerequisites contract](0010-cloud-prerequisites-contract.md)
- [Azure Monitor Workspace overview](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/azure-monitor-workspace-overview)
- [Data Collection Rules overview](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/data-collection-rule-overview)
- [Azure Local — Monitoring overview (Metrics section)](https://learn.microsoft.com/en-us/azure/azure-local/concepts/monitoring-overview?view=azloc-2604#metrics)
- [Azure Local — Monitor a single system with Insights — Performance counters](https://learn.microsoft.com/en-us/previous-versions/azure/azure-local/manage/monitor-hci-single?view=azloc-2604&tabs=22h2-and-later#performance-counters)
- [Azure Monitor Workspace — manage access](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/azure-monitor-workspace-manage)
- [Prometheus metrics overview](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/prometheus-metrics-overview)
