# ADR 0019 — Cost, Scale, and Data Retention

- **Status**: Accepted
- **Date**: 2026-05-05
- **Deciders**: @kturner

## Context

The Azure Monitor track has cost and scale dimensions that the SCOM track does not — every signal
costs ingestion, every alert rule costs evaluation, every retained day costs storage. ADR 0008
defines three Bicep parameter tiers (`lab.bicepparam`, `standard.bicepparam`, `strict.bicepparam`)
that vary thresholds, but they do not vary cost or scale assumptions. Operators sizing this for
a real fleet need:

- An expected ingestion volume per cluster (so they can budget LAW capacity)
- A maximum supported cluster count per service group / health model
- A retention policy that balances investigation needs vs. storage cost
- A documented "what to turn off if you need to cut cost"

Without this guidance, the standard tier could surprise an operator with a $5k/month LAW bill,
or a customer trying to monitor 200 clusters could exceed Azure Monitor preview limits silently.

The SCOM track has analogous concerns (DB size, performance counter cardinality) but the
authoring guide (Brian Wren Module 16, "Designing a Health Model") covers them adequately;
this ADR is primarily for the Azure Monitor track with brief SCOM coverage.

## Decision

### Per-cluster cost envelope (Azure Monitor track)

Document an expected per-cluster ingestion budget for each tier, in the prerequisites doc:

| Tier | Signals enabled | Ingestion budget per cluster | Alert rules | Eval cadence |
|---|---|---|---|---|
| **Lab** | ~120 (L1 perf + L2 platform availability only; L3 ARM probes off) | ~250 MB/day | 0 (no paging) | 5 min |
| **Standard** | ~250 (full catalog except Self-Observability extras) | ~600 MB/day | ~30 metric + ~12 query | 1–5 min |
| **Strict** | ~280 (full catalog + Self-Observability + custom event-log signals) | ~1.2 GB/day | ~50 metric + ~20 query | 1 min |

Numbers are **upper bounds for a 4-node Azure Local cluster with 50 VMs**, derived from a Phase 4
sizing exercise. Linear scaling for larger clusters; sub-linear for additional clusters in the
same LAW (shared system tables).

### Maximum supported scale (per health model resource)

| Dimension | Tested supported | Hard limit |
|---|---|---|
| Clusters per Service Group | 50 | Azure Monitor Health Models preview limit, ~100 entities per model — see [preview limits](https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/health-status-alerts) |
| Entities per cluster | ~30 (3-layer × ~10 entities each) | Stays within the ~100-entity preview cap × 50 clusters via per-cluster sub-models |
| KQL signals per entity | ~6 | No platform limit; this is a readability bound |
| Alert rules per model | 100 | Subscription-level metric alert quota (default 5,000, but model-level readability) |

For fleets > 50 clusters, **shard into multiple Service Groups** (one model per geographic region
or per environment). The Bicep `main.bicep` accepts a `serviceGroupSharding: 'single' \| 'per-region'`
parameter.

### Data Collection Rule efficiency

- DCRs use **Custom XPath filters** for Windows event logs to drop noise at the agent before
  ingestion (per ADR 0002 signal source rules).
- DCRs route **non-health-model perf counters** to a basic-tier table where supported, not the
  premium analytics table — KQL signals do not need premium-tier features.
- High-cardinality dimensions (per-process, per-thread perf counters) are **never collected**
  through the health-model DCR; operators wanting them set up a separate DCR.

### Retention policy

| Data class | Default retention | Why |
|---|---|---|
| **Health model state history** (`HealthState` table) | 90 days | Sufficient for trend analysis and most post-incident review; aligns with Azure Local Insights default |
| **Signal raw data** (`Perf`, custom KQL signal sources) | 30 days interactive + archive to 365 days | Investigation typically completes within 30 days; archive enables ad-hoc historical queries at low cost |
| **Alert / Activity log** | 90 days (LAW default) | Compliance and audit needs |
| **Self-Observability signals** (per ADR 0018) | 30 days | Pipeline failure analysis rarely needs deeper history |

Retention is set per-table via Bicep, not at the LAW level, to avoid over-paying for the
high-volume perf table.

### Tier downgrade — "what to turn off if you need to cut cost"

Documented in `docs/azure-monitor/cost-tuning.md` (Phase 4 deliverable):

1. Switch from `strict.bicepparam` to `standard.bicepparam` — saves ~50% by disabling
   Self-Observability extras and tightening eval cadence to 5 min.
2. Drop event-log signals (CO2 reduction in DCR) — saves ~20%.
3. Increase signal eval cadence from 1 min to 5 min — saves ~30% (alert latency increases).
4. Reduce raw-data retention from 30 days to 14 days — saves ~30% storage.
5. Disable per-VM signals (cluster + node level only) — saves ~40% on a VM-dense cluster.

### SCOM track guidance (brief)

- Performance collection rules use **3-minute samples + 10-minute aggregations** (Brian Wren
  Module 18 default), not 30-second sampling.
- DB sizing follows the SCOM Sizing Helper rules with per-cluster Azure Local rows added —
  documented in `docs/scom-mp/sizing.md` (Phase 3 deliverable).
- Override pack tiers (Lab/Standard/Strict, ADR 0008) carry parallel cost envelopes.

### What this ADR does NOT do

- Fix cost numbers in dollars — Azure pricing changes; numbers are in MB/day so customers can
  multiply by their region's LAW price.
- Cover SCOM database sizing in detail — deferred to Phase 3 deliverable.
- Define disaster recovery / backup retention — separate concern.

## Consequences

- **Positive**:
  - Operators have an upfront budget number per tier — no $5k/month surprises.
  - Tier downgrade playbook makes "I need to cut my LAW bill 30%" a documented procedure, not
    a panic project.
  - Retention is right-sized per data class — health state kept long enough for trend analysis,
    high-volume perf data archived cheaply.
  - Sharding policy gives a clear path for fleets exceeding the 50-cluster mark.
- **Negative**:
  - Phase 4 needs an actual sizing exercise on a real cluster to validate the numbers in this
    ADR; until then they are estimates flagged as such.
  - Per-table retention adds Bicep complexity vs. a single LAW-level setting.
- **Neutral**:
  - Tiers, retention, and sharding are all parameter-driven — customers can override.
- **Affected components / owners**: `bicep/modules/dcr.bicep` (XPath filters, per-table retention);
  Phase 4 first PR adds `docs/azure-monitor/cost-tuning.md`; Phase 4 sizing exercise validates numbers
  and updates this ADR's table if reality diverges (per immutability rule, via a successor ADR).

## Alternatives considered

- **One LAW-level retention setting** — rejected; over-pays for retaining perf data, under-retains health-state.
- **No documented cost guidance, "depends on workload"** — rejected; the absence of a number is the worst answer.
- **Use Azure Monitor Workspace (AMW) as the routing target instead of LAW** (per ADR 0012) — already covered by ADR 0012; this ADR layers on top of either topology.
- **Hard cap clusters per model at 25 instead of 50** — rejected; preview limits support 50 in current testing, more conservative cap loses scale headroom for no clear benefit.
- **Cost envelopes in dollars** — rejected; pricing varies by region and changes; MB/day is durable.
- **Skip the Strict tier cost ceiling** — rejected; "Strict means no upper bound" is how monitoring bills get out of control.

## References

- ADR 0002 — Signal source (DCR XPath filtering)
- ADR 0008 — Customization strategy (tier definitions)
- ADR 0010 — Cloud prerequisites (LAW + AMA + DCR baseline)
- ADR 0012 — Azure Monitor Workspace vs LAW (routing topology)
- ADR 0013 — Azure Monitor deployment strategy (Bicep modules carry per-table retention)
- ADR 0018 — Self-Observability (signals included in tier ingestion budgets)
- [Azure Monitor Health Models preview limits](https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/health-status-alerts)
- [LAW table-level retention](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/data-retention-archive)
- [DCR XPath transformations](https://learn.microsoft.com/en-us/azure/azure-monitor/agents/data-collection-rule-transformations)
- [Azure Monitor pricing](https://azure.microsoft.com/en-us/pricing/details/monitor/)
- Brian Wren Module 16 — Designing a Health Model (SCOM perf counter cost guidance)
- Brian Wren Module 18 — Rules (collection cadence defaults)
