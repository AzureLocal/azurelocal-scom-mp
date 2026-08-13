# ADR 0029 — Hyper-V health, alert, and DA rollup

**Status:** Proposed

**Date:** 2026-08-13

**Decision owners:** Repository owner and maintainers

## Context

A comprehensive MP can easily become a noisy MP. Technically collectible signals do not all deserve
enabled health monitors or alerts. Hyper-V adds topology-sensitive cases: intentionally stopped VMs,
redundant cluster nodes, maintenance, migration, backup/checkpoint activity, dependency symptoms,
and missing telemetry. The DA must show service impact without producing duplicate root and child
alerts or remaining Healthy when monitoring is broken.

## Proposed decision

Use unit monitors to establish current health on the narrowest actionable class, standard SCOM
Availability, Configuration, Performance, and Security aggregate dimensions, and dependency
monitors to propagate service impact into platform-owned DA component groups and the deployment
root.

Alerts originate at the most actionable unit monitor or discrete event rule. Aggregate and
dependency monitors do not alert by default. Numeric thresholds require sustained duration or
sample count, explicit recovery bands/hysteresis, missing-data behavior, and safe overrides.
Cluster redundancy and VM expected-state/population use topology-aware rollups rather than
unconditional worst-state. Each DA includes a root-impacting Monitoring pipeline branch.

Exact thresholds, severity mappings, expected-state rules, population algorithms, and branch impact
remain provisional until AB#7351–AB#7353 complete.

## Options considered

### Evidence-driven, topology-aware health

| Dimension | Assessment |
|---|---|
| Noise | Controlled through actionability, duration, recovery, and dependency design |
| Service accuracy | Handles redundancy, intent, and missing telemetry |
| Complexity | Highest design and lab effort |
| Tunability | Explicit, documented override contract |

### Alert on every available signal

| Dimension | Assessment |
|---|---|
| Noise | Unacceptable duplicate and low-value alert volume |
| Service accuracy | Raw symptoms can dominate actual impact |
| Complexity | Easy to author, expensive to operate |
| Tunability | Pushes design burden to every customer |

### DA worst-state for every member

| Dimension | Assessment |
|---|---|
| Noise | Root becomes unhealthy for planned or redundant conditions |
| Service accuracy | Poor for VM populations and clustered redundancy |
| Complexity | Simple implementation |
| Tunability | Difficult to correct safely with overrides alone |

## Trade-off analysis

Topology-aware health takes more research and testing, but this work belongs in the product rather
than being transferred to every customer. Worst-state remains appropriate for non-redundant critical
dependencies; it is not a universal rollup rule.

## Consequences

- The raw signal inventory remains larger than the enabled default catalog.
- Every enabled alert requires complete product knowledge and verified recovery.
- VM expected state and monitoring freshness become explicit model inputs.
- The DA can show impact without duplicating every leaf alert at the root.
- Threshold and rollup changes require fault/recovery and noise regression tests.

## Acceptance gates

1. AB#7351 supplies threshold semantics and evidence.
2. AB#7352 proves fault, rollup, suppression, recovery, maintenance, migration, and stale-data paths.
3. AB#7353 approves the curated default profile and exclusions.
4. AB#7357 validates DA rollups, views, reports, dashboards, and SLO targeting.

## Related design

- [Health and alert architecture](../hyper-v/health-and-alert-architecture.md)
- [Hyper-V Distributed Application](../hyper-v/distributed-application.md)
- [ADR 0026 — Platform-owned SCOM Distributed Applications](0026-platform-owned-scom-distributed-applications.md)
