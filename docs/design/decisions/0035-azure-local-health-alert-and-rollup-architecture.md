# ADR 0035 — Azure Local health, alert, and rollup architecture

- **Status**: Accepted
- **Date**: 2026-08-13
- **Deciders**: Hybrid Solutions Cloud maintainers

## Context

A single worst-of node aggregate would contaminate every DA branch: a storage fault could make the
Network component unhealthy, and a registration fault could obscure compute. Alerts would also
duplicate the root-cause behavior already provided by the Azure Local Health Service.

## Decision

One shared node probe produces 14 state signals with identical acquisition configuration so SCOM
can cook down execution. Six domain aggregates partition the node state:

- Compute: Cluster Service, node membership, quorum, CPU, and memory.
- Storage: Health Service faults, pools, volumes/CSVs, and physical disks.
- Network: Network ATC intent status.
- Azure Integration: registration/connection and locally present platform services.
- Lifecycle: solution-update health.
- Monitoring Pipeline: probe execution health.

Component dependency monitors consume their matching domain aggregate. Six component states then
roll into the Azure Local DA root using worst-state semantics.

Eleven curated state monitors can auto-resolve alerts. CPU, memory, and individual physical-disk
state are state-only by default. Four high-confidence Failover Clustering event rules supplement
state. Performance collection is independent of alerting; high-cardinality or availability-dependent
collections begin disabled.

Lab, Standard, and Strict thresholds are provisional starter profiles. The release defaults remain
uncertified until fault, recovery, duration, reserve, scale, maintenance, and upgrade testing is
complete.

## Consequences

- DA branches explain the affected platform domain.
- Health Service root-cause reduction is preserved instead of duplicated per drive.
- A percentage-used memory threshold is not accepted as a standalone default.
- Monitoring failure can degrade the DA instead of leaving stale green health.
- Every health and event-alert workflow carries operator knowledge and a customer override path.

## References

- [Azure Local Health Service root-cause faults](https://learn.microsoft.com/en-us/azure/azure-local/manage/health-service-faults)
- [Microsoft monitor and rule concepts](https://learn.microsoft.com/en-us/previous-versions/system-center/system-center-2012-R2/hh457603(v=sc.12))
- [SquaredUp health rollup](https://squaredup.com/blog/a-dive-into-health-roll-up/)
