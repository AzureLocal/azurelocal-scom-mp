# ADR 0018 — Self-Observability ("Monitor the Monitor")

- **Status**: Accepted
- **Date**: 2026-05-05
- **Deciders**: @kturner

## Context

A health monitoring solution that silently stops working is worse than no monitoring at all —
operators rely on a green dashboard to mean "the cluster is healthy", but it could equally mean
"the collection pipeline has been dead for 6 hours and we don't know it." Both tracks (SCOM and
Azure Monitor) have collection pipelines with multiple failure modes that are invisible to the
health model itself unless explicitly surfaced.

Failure modes we have seen in adjacent projects:

- AMA agent disconnected; metrics stop ingesting; LAW queries return empty; KQL signal returns
  zero rows → entity resolves to **Unknown** at best, **Healthy** at worst (depending on the
  signal's NULL handling).
- DCR misassociation after a redeploy; specific perf counters silently drop while others continue.
- SCOM management server ↔ agent heartbeat fails; agent goes "Not Monitored" but the cluster
  health rolls up from cached state and looks fine.
- A KQL signal query has a syntax error introduced by a schema change in a referenced table;
  the scheduled query rule alerts every 15 minutes but no one watches alert-rule-failed alerts.
- The DCMA / Azure Local cloud agent goes offline; the HCI cluster ARM resource freezes in
  `Connected` while the on-prem cluster diverges.

ADR 0010 (cloud prerequisites) declares these dependencies exist; this ADR makes them visible.

## Decision

Add a **Self-Observability layer** to the health model itself — entities and signals that monitor
the monitoring pipeline, with their own rollup branch under the root entity that operators can see
without leaving the health model dashboard.

### Self-Observability entities (cross-track)

| Entity | Layer | Health dimension | What "Unhealthy" means |
|---|---|---|---|
| `AzureLocal.Monitoring.SCOMAgent` | L1 | Availability | SCOM agent on a node is in `Not Monitored` / `Critical` state, or has not heartbeated in > 6 minutes |
| `AzureLocal.Monitoring.SCOMManagementServer` | L1 | Availability | Management server `HealthService` not running, or DB queue depth > threshold |
| `AzureLocal.Monitoring.AMAExtension` | L2 | Availability | Azure Monitor Agent VM extension not in `Succeeded` provisioning state on an Arc-enabled node |
| `AzureLocal.Monitoring.DCRAssociation` | L2 | Configuration | Required Data Collection Rule not associated with the Arc machine, or association not in `Succeeded` state |
| `AzureLocal.Monitoring.DCMA` | L2 | Availability | DCMA / Azure Local cloud agent service not running, or last-heartbeat-to-Azure > 15 min |
| `AzureLocal.Monitoring.LAWIngestion` | L3 | Availability + Performance | LAW receives no rows from this cluster's namespace in last 30 min, or ingestion latency P95 > 5 min |
| `AzureLocal.Monitoring.AzMonHealthModel` | L3 | Availability | The Azure Monitor Health Model resource itself is in a non-Succeeded provisioning state, or last evaluation > 30 min ago |
| `AzureLocal.Monitoring.AlertRuleHealth` | L3 | Configuration | Any alert rule on the model is in `Disabled` state unintentionally, or scheduled query rule reports `LastFailureReason` non-empty in last 24h |
| `AzureLocal.Monitoring.SignalQueryHealth` | L3 | Configuration | Any KQL signal in `kql/signals/` returned zero rows for > 6 evaluation cycles when at least one node is reporting (suggests query is broken vs. genuinely empty) |

### Rollup behavior

A new aggregate entity `AzureLocal.Monitoring.Pipeline` sits as a **direct child of the root**
(parallel to the cluster entity, not nested under it). Worst-state rollup applies. The aggregate is
documented in `scope-topology.md` as the "telemetry pipeline" branch.

> **Rationale for placing it parallel to the cluster, not under it:** if the SCOM agent on every
> node is dead, every node child of the cluster shows `Unknown`, the cluster shows `Unknown` or
> stale `Healthy`, and the operator sees green. With a parallel branch, the **root** entity
> rolls up worst-of(`Cluster`, `Pipeline`) and goes red regardless of what the cluster branch says.

### Alert policy

- Self-Observability entities have their **own action group** (separate from the cluster
  health action group, per ADR 0009).
- They generate alerts at `Sev2` (not Sev1) by default — pipeline outages are typically
  recoverable and not customer-facing in the way a cluster outage is. Tunable via override.
- The alert text always says: "Cluster health is **unknown** until pipeline restored."
- A dedicated dashboard panel ("Telemetry pipeline status") sits at the top of every workbook
  and SquaredUp dashboard.

### Implementation by track

- **SCOM track**: implemented as standard SCOM entities + monitors in `AzureLocal.SCOM.Library.mp`
  + `AzureLocal.SCOM.Monitoring.mp`. Existing SCOM "Health Service Watcher" infrastructure is
  reused; this ADR adds the cross-cluster aggregate.
- **Azure Monitor track**: implemented as additional entities in `bicep/modules/entities.bicep`
  with KQL signals in `kql/signals/monitoring/*.kql`. ARM probes for DCR / health-model resource
  state come from Resource Graph queries (Tier B per ADR 0011).

### What we deliberately do not monitor here

- The Self-Observability stack itself — at some point the chain has to terminate, and we accept
  that complete failure of the SCOM and Azure Monitor *control planes* (both at once) is out
  of scope. Customers running mission-critical clusters should layer an independent
  reachability check (Azure Service Health subscription, third-party uptime probe) on top.

## Consequences

- **Positive**:
  - Operators can no longer mistake "green dashboard" for "actually green cluster" — a dead
    pipeline shows as red at the root.
  - Failure modes that previously surfaced as customer support tickets ("why didn't we get an
    alert?") become first-class signals in the model.
  - The pipeline branch is a natural place to surface ADR 0010's cloud prerequisites contract
    in operational form.
- **Negative**:
  - Adds ~9 entities and ~12 signals to the catalog (was ~250, now ~260+). Marginal authoring
    cost.
  - Self-Observability alerts add noise during planned maintenance windows; mitigated by
    standard SCOM maintenance mode / Azure Monitor alert suppression.
- **Neutral**:
  - Customers can disable the pipeline branch in their override pack / `bicepparam` if they
    have an external pipeline-health system they prefer.
- **Affected components / owners**: signal-catalog.md (add Self-Observability section);
  scope-topology.md (add `AzureLocal.Monitoring.*` entities to L1/L2/L3 tables); ADR 0009
  (alert-vs-state policy already supports Sev2 default — no change needed).

## Alternatives considered

- **Surface pipeline failure only as Azure Service Health / alert rule failures** — rejected;
  these channels are easy to miss, and the whole point is operators see this on the same
  dashboard as cluster health.
- **Add the entities under the cluster entity** — rejected; if the agent on every node dies,
  the cluster goes Unknown, which a busy operator can read as "stale data, ignore." Parallel
  branch forces a root-level red.
- **External pipeline check only** (third-party uptime probe) — rejected as the only mechanism;
  recommended as additional layer for mission-critical, but the in-band signal must exist.
- **Sev1 alerts on pipeline failures** — rejected; pipeline failures are typically self-healing
  (agent reconnect within minutes). Sev2 with paging at sustained > 30 min via override.
- **Skip this entirely, document it as customer responsibility** — rejected; "I had a dashboard
  that lied to me for 6 hours" is the worst possible failure mode for a health monitoring
  product.

## References

- ADR 0009 — Alert vs health-state separation (governs alert routing for the new entities)
- ADR 0010 — Cloud prerequisites contract (these entities operationalize the contract)
- ADR 0011 — L3 Azure-side scope (Tier B ARM probes used by `AlertRuleHealth`,
  `AzMonHealthModel`, `DCRAssociation`)
- ADR 0012 — Azure Monitor Workspace vs LAW (LAWIngestion entity routes through this decision)
- [SCOM Health Service Watcher](https://learn.microsoft.com/en-us/system-center/scom/manage-mp-health-service-watcher)
- [AMA extension state via Resource Graph](https://learn.microsoft.com/en-us/azure/governance/resource-graph/samples/samples-by-category)
- [Scheduled Query Rule failure reasons](https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-troubleshoot-log)
- WAF Mission-Critical guidance: "monitor the monitor"
