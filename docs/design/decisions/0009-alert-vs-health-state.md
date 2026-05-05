# ADR 0009 — Alert vs health-state separation policy

- **Status**: Proposed
- **Date**: 2026-05-05
- **Deciders**: @AzureLocal/azurelocal-scom-mp-maintainers

## Context

A *health state* and an *alert* answer different questions:

- **Health state** = "What is the current condition of this entity?" (read-only, current,
  always present)
- **Alert** = "Should a human do something about this right now?" (workflow object,
  routed to action groups, has severity, can be acknowledged / closed)

In SCOM, every monitor has a `Generate alerts for this monitor` checkbox. The default
in many community MPs is **on** for state-bearing monitors — every Critical → Warning →
Healthy transition fires an alert. This produces *alert fatigue*: hundreds of alerts a
day, most of which are transient blips.

In Azure Monitor Health Models, alert rules are deliberately a separate object from the
model — you author the model first, then *separately* author alert rules on either:
- Specific signals (the recommended pattern), or
- The model's overall state (rare; only useful at the root)

If we don't make an explicit policy, two failure modes:

1. **Alert fatigue** — every transient state change pages someone. Operators silence the
   pack, defeating the point.
2. **Missed alerts** — operators rely on the Health Explorer view and don't realize
   actionable conditions need explicit alert wiring.

## Decision

**Health states and alerts are separate concerns.** A signal that drives a state does
not automatically generate an alert. Alerts are explicitly opted in for a curated
subset of signals.

### Policy rules

1. **Default = state only.** Every signal in the [Signal Catalog](../signal-catalog.md)
   drives a health state. By default it does **not** generate an alert.
2. **Alerts are explicitly opted in** via:
   - SCOM: Setting `<AlertSettings>` on the monitor with `<AlertOnState>`
   - Azure Monitor: Authoring a separate alert rule on the underlying signal
3. **Alert severity is independent of state severity.** A signal can have state
   = Degraded but alert severity = Information (don't page, just log). Or state = Healthy
   on resolution but no alert (state visible, no notification).
4. **Alerts use a curated allow-list.** Phase 3/4 ships a documented set of "this is
   alert-worthy" signals. The rest are state-only.
5. **Alert routing is parameterized.** Customers configure action groups (Azure Monitor)
   or notification subscriptions (SCOM) per-signal, with sensible defaults.

### Alert allow-list (initial — refined in Phase 3/4)

| Signal | Default alert severity | Why pageable |
|---|---|---|
| `Cluster.Service.State` (Stopped) | Critical | Cluster down — workload impact |
| `Cluster.Quorum.State` (Failed) | Critical | Cluster will not survive another failure |
| `Node.Up.State` (Down) | Warning (Critical if multiple nodes) | Node down reduces redundancy |
| `Volume.HealthStatus` (Unhealthy) | Critical | Data path at risk |
| `Volume.FreeSpace.Percent` (< Crit threshold) | Critical | Volume will fill — write failure imminent |
| `StoragePool.PhysicalDisks.Failed` (> 1) | Critical | Beyond fault tolerance |
| `StoragePool.RepairJobs.Active` (> 24h) | Warning | Stuck repair |
| `NetIntent.State` (Failed) | Critical | Network plane misconfigured |
| `KeyVault.Secret.ExpiryDays` (< 7) | Critical | Auth will break |
| `RBAC.RequiredAssignments` (> 1 missing) | Critical | Operations will break |
| `HCICluster.ConnectionStatus` (Disconnected > 1h) | Warning | Cloud-side billing/management drift |
| `Update.LastResult` (Failed) | Warning | LCM run failed; manual investigation |

State-only signals (no alert) include:
- All Performance signals on Nodes (CPU, Memory) — used in dashboards, not alerts
- `Volume.RedirectedIO.Active` — diagnostic, not actionable on its own
- `Update.Available.Days` — informational
- All `*.ResourceHealth` signals — Resource Health already has its own alerting
  product; double-alerting wastes operator attention

### Action group / notification routing

**Azure Monitor track:**
- Three named action groups deployed by the Bicep module:
  - `azurelocal-critical-ag` — pages on-call (default = email + SMS to a parameterized list)
  - `azurelocal-warning-ag` — emails the ops mailing list
  - `azurelocal-info-ag` — logs to a Teams channel webhook
- Customers override targets via Bicep params; routing per-signal is parameter-driven
  (each alert rule references one of the three action groups by name).

**SCOM track:**
- Notification subscriptions are *not* part of the MP — they're SCOM tenant-level config.
- The MP ships sensible alert severities (per the table above), and the customer's
  existing SCOM notification subscriptions handle routing.

### Auto-resolve

Both tracks use auto-resolve when the underlying state returns to Healthy:
- SCOM: standard monitor-driven alert auto-resolves when the monitor returns to Healthy.
- Azure Monitor: alert rule with `autoMitigate: true` (the default for log/metric alerts).

### Storm prevention

| Mechanism | SCOM | Azure Monitor |
|---|---|---|
| **Alert suppression** during cluster-wide failure | Aggregate monitor at parent rolls up; child alerts suppressed via dependency | Alert rule scoped to specific signal; rely on action group throttling + de-duplication |
| **Frequency throttling** | Per-monitor alert generation interval | Alert rule `evaluationFrequency` + de-duplication via dimension grouping |
| **Maintenance window** | Maintenance Mode | Action group suppression rule |

## Consequences

- **Positive**: No alert fatigue. Health state is rich and always available; alerts are
  pageable and curated.
- **Positive**: Operators can adopt the pack without immediately retuning alert
  severities — defaults are sane.
- **Positive**: Action group separation lets customers route Critical to PagerDuty and
  Warning to a quiet email list with one parameter change.
- **Negative**: Operators new to this pattern may expect the pack to alert on
  *everything* and be surprised some signals are state-only. Mitigated by the docs
  page and the alert allow-list table.
- **Negative**: Adding new alerts requires a code change. Mitigated by the customer
  having full freedom to author their own SCOM rules / Azure Monitor alert rules
  pointing at the same signals.
- **Affected**: Phase 3 (SCOM) — every monitor's `<AlertSettings>` block. Phase 4
  (Azure Monitor) — the separate Bicep module for alert rules + action groups.

## Alternatives considered

- **Alert on every state transition** — rejected: alert fatigue, operators turn the pack
  off.
- **Alert on root entity state only** — rejected: hides all granularity; one alert says
  "the deployment is degraded" with no clue what's degraded.
- **No alerts in the pack; require customer to author all** — rejected: most customers
  want the project's curated allow-list as a starting point.

## References

- ADR 0003 — [Health rollup policy](0003-health-rollup-policy.md)
- ADR 0008 — [Customization strategy](0008-customization-strategy.md)
- [Brian Wren, "Rules" (SC 2012 R2 module 18)](https://learn.microsoft.com/en-us/shows/system-center-2012-r2-operations-manager-management-packs/)
- [Kevin Holman — Tuning SCOM alerts](https://kevinholman.com/2009/05/27/scom-tuning-101/)
- [Azure Monitor — Alerts overview](https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-overview)
- [Azure Monitor — Action groups](https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/action-groups)
- [Resource Health — alerts](https://learn.microsoft.com/en-us/azure/service-health/resource-health-alert-arm-template-guide)
