---
title: Azure Local health and alert architecture
description: Domain aggregates, alert policy, thresholds, event rules, performance, and DA rollup.
---

# Azure Local health and alert architecture

![Azure Local health rollup](/assets/diagrams/azure-local-scom-health-rollup.svg)

## Health catalog

| Domain | Signals | Default alert behavior |
|---|---|---|
| Compute | Cluster Service, node membership, quorum | Auto-resolving alerts |
| Compute performance | CPU, available memory | State only |
| Storage | Health Service faults, pool, volume/CSV | Auto-resolving alerts |
| Storage diagnostics | Individual physical-disk aggregate | State only; Health Service owns root-cause paging |
| Network | Network ATC intent convergence | Auto-resolving alert |
| Azure Integration | Registration/connection and local platform services | Auto-resolving alerts |
| Lifecycle | Failed or attention-required solution updates | Auto-resolving warning/critical alert |
| Monitoring | Shared-probe completion | Auto-resolving alert |

Four Failover Clustering event rules cover node removal, clustered-role failure, CSV access failure,
and CSV no-longer-accessible conditions. Event rules supplement current state; they do not replace
state monitors.

## Threshold policy

CPU, memory, and volume capacity defaults are provisional development values. A release threshold
requires evidence for duration, recovery, host reserve, failover reserve, workload density, scale,
maintenance, and false-positive rate.

In particular, 75 percent memory used is not a universal Azure Local failure threshold. Available
host memory, host/guest split, paging, pressure, failover capacity, and trend must be considered.

## DA propagation

Each node has six domain aggregates. Component dependencies consume the matching aggregate, then
six service dependencies apply worst-state rollup at the DA root. A storage failure therefore
degrades Storage without falsely making Network unhealthy.
