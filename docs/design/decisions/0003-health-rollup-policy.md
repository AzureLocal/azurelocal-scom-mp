# ADR 0003 — Health rollup policy: worst-state default with documented exceptions

- **Status**: Proposed
- **Date**: 2026-05-05
- **Deciders**: @AzureLocal/azurelocal-scom-mp-maintainers

## Context

Once we have an entity graph ([ADR 0001](0001-scope-and-topology.md)) and signals
([ADR 0002](0002-signal-source.md)), we have to decide **how a child's state propagates
to its parent**. Both tracks support multiple algorithms; without a project-wide default
the SCOM and Azure Monitor implementations will drift.

SCOM dependency monitor algorithms:

- **Worst-state** — parent inherits the worst child state
- **Best-state** — parent inherits the best child state
- **Percentage-based** — parent unhealthy if X% of children unhealthy

Azure Monitor Health Models impact:

- **Standard** — child fully participates in parent rollup (worst-state semantics)
- **Limited** — child can degrade parent to Warning but never to Unhealthy
- **Suppressed** — child does not affect parent

Without a project-wide default we have three failure modes:

1. **Inconsistent rollup across tracks** — operator sees Cluster=Healthy in SCOM and
   Cluster=Degraded in Azure Monitor for the same conditions
2. **False all-clears** — best-state hides a single failed node
3. **Alert fatigue** — every transient signal degrades the cluster, paging operators
   for non-actionable conditions

## Decision

**Default rollup is `worst-state`** in both tracks (SCOM dependency monitor `WorstOf`
algorithm; Azure Monitor `Standard` impact).

A small, **documented exception list** captures the cases where worst-state is wrong:

| Entity / signal | Behavior | Why |
|---|---|---|
| `Update.LastResult` | `Best-of` rollup at Configuration dimension; max severity = Warning | Pending updates are never a critical cluster failure |
| `StorageReplica` (when DR partner unreachable) | `Worst-state` Availability but `Suppressed` impact when `partnerSiteReachable == false` | Don't make local cluster Unhealthy because DR partner is offline |
| `Stopped Resource Bridge` (planned maintenance) | `Suppressed` via maintenance window | Operator-initiated; honor maintenance mode |
| `UpdateManager.Linkage` missing | Max severity = Warning (not Critical) | Linkage missing is configuration drift, not failure |
| `KeyVault.Secret.ExpiryDays` | Tiered: Warning at 30 days, Critical at 7 days | Built-in tiering — expiry is a slope, not a step |

### Layered application

- **Aggregate monitors** (Availability / Performance / Configuration / Security on each
  entity) use `worst-state` across signals within the same dimension.
- **Dependency monitors** between entities use `worst-state` by default; exceptions above
  override.
- **Distributed Application root** uses `worst-state` across the four aggregate dimensions.

### Per-customer overrides

Operators can override any rollup behavior via the customization mechanism
([ADR 0008](0008-customization-strategy.md)). Common patterns:

- Promote a `Suppressed` entity to `Standard` if you do care about your DR partner
- Cap a particularly noisy signal at `Warning` (effectively making it Limited)
- Disable a dependency entirely for a test-lab deployment

## Consequences

- **Positive**: Operationally sensible default — one bad node makes the cluster look bad,
  matching how operators reason. No false all-clears.
- **Positive**: Cross-track parity by construction — SCOM and Azure Monitor compute the
  same rollup state for the same conditions.
- **Positive**: Exception list is small and documented, so reviewers can sanity-check.
- **Negative**: Worst-state is noisy on large clusters during transient blips. Mitigated
  by the alert/state separation ([ADR 0009](0009-alert-vs-health-state.md)) — state
  changes don't auto-page.
- **Negative**: Operators in lab/dev environments may find Standard rollup too sensitive.
  Mitigated by the Lab tier in [Customization](../customization.md) which loosens
  thresholds before they cross.
- **Affected**: Every dependency monitor in the SCOM MP and every entity in the Azure
  Monitor model must reference this policy. ADR 0005 (class hierarchy) and ADR 0006
  (entity model) operationalize it per entity.

## Alternatives considered

- **Best-state default** — rejected: hides single-node failures behind healthy peers.
- **Percentage-based default (e.g., 50% unhealthy = parent unhealthy)** — rejected:
  appropriate for stateless web farms, wrong for clustered systems where one Unhealthy
  member already breaks quorum/redundancy guarantees.
- **No project default; per-entity case-by-case** — rejected: leads to drift between
  tracks and across entities; reviewer fatigue.

## References

- ADR 0001 — [Scope & topology](0001-scope-and-topology.md)
- ADR 0009 — [Alert vs health-state separation](0009-alert-vs-health-state.md)
- [Brian Wren, "Health Rollup" (SC 2012 R2 module 19)](https://learn.microsoft.com/en-us/shows/system-center-2012-r2-operations-manager-management-packs/)
- [SquaredUp — A dive into health roll-up](https://squaredup.com/blog/a-dive-into-health-roll-up/)
- [Azure Monitor Health Models — health propagation](https://learn.microsoft.com/en-us/azure/azure-monitor/health-models/)
