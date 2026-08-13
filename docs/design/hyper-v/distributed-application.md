---
title: Hyper-V Distributed Application
description: Hyper-V SCOM Distributed Application boundaries, component groups, rollup rules, and research gates.
---

# Hyper-V Distributed Application design

The Hyper-V SCOM product ships a Hyper-V-owned Distributed Application with no dependency on the
Azure Local MP. The working logical root is **`HyperV.Deployment`**; the final platform namespace,
stable key, and class hierarchy are locked before authoring by the successor Hyper-V topology and
discovery ADRs.

## Monitoring boundaries

The product creates an independent DA instance for each supported monitoring boundary:

- one per Hyper-V failover cluster; and
- one per standalone Hyper-V host.

SCVMM management does not merge unrelated clusters or hosts into one required DA. A future fleet
view can aggregate multiple DAs through optional presentation content or a separately packaged
integration MP.

## Candidate service model

| DA branch | Membership | Applicability and rollup intent |
|---|---|---|
| Compute and cluster | Hyper-V host or cluster, cluster service, quorum, nodes, and virtualization services | Always present; cluster-only objects are omitted for standalone hosts |
| Virtual machines | VMs and clustered VM roles related to the boundary | Only expected-running or otherwise actionable state affects default availability; intentional Off state must not make the DA unhealthy |
| Storage and Replica | CSVs, storage paths, virtual disks, VHD/VHDX dependencies, and Hyper-V Replica relationships | Include only discovered resources owned by the boundary |
| Networking | Physical adapters, vSwitches, ports, VM adapters, and the selected Network ATC, manual, or SCVMM/SDN authority path | Do not roll overlapping network-management authorities into the same deployment |
| Management plane | Optional SCVMM, Network Controller, and related authoritative management dependencies | Present only when the supported topology selects that management plane |
| Monitoring pipeline | SCOM agent, discovery freshness, workflow health, and required management-server collection paths | Separate root-level branch so missing telemetry cannot appear as healthy infrastructure |

The exact classes and membership queries remain evidence-gated by AB#7343, AB#7348, and AB#7350.
Those spikes may refine branch names or split a branch, but they may not remove the requirement for
a platform-owned DA.

## Health propagation

| Layer | Responsibility |
|---|---|
| Unit monitors | Establish health for supported Hyper-V, cluster, storage, network, VM, and management signals |
| Aggregate monitors | Organize Availability, Configuration, Performance, and applicable Security state within each object |
| Dependency monitors | Propagate health through discovered relationships and into the applicable DA component group |
| DA root | Presents the standalone-host or cluster service state for views, reports, dashboards, and SLOs |

Worst-state is the default, not an unconditional rule. VM power state, percentage-based population
health, redundancy, maintenance, intentional drain/offline state, missing data, and recovery behavior
must be decided from AB#7351–AB#7353 and validated in the lab. A simple count of powered-off VMs or
a single raw utilization threshold must not turn the entire DA unhealthy without operational
context.

## Required product artifacts

- Hyper-V-owned DA root and component-group class XML;
- dynamic relationship and membership discoveries for standalone and clustered boundaries;
- topology-aware aggregate and dependency monitors;
- Health Explorer, diagram, state, alert, and task views scoped to the DA instance;
- report and service-level objective targeting;
- optional SquaredUp Dashboard Server views that target only Hyper-V classes; and
- import, population, topology-change, fault, recovery, upgrade, side-by-side, and removal tests.

## Research acceptance gates

Before MP XML authoring, the Hyper-V research must prove:

1. stable cluster and standalone-host DA keys;
2. deterministic membership through supported discoveries and relationships;
3. correct behavior for clustered VM movement, host drain, maintenance, and failover;
4. exclusive Network ATC, manual, or SCVMM/SDN authority membership;
5. actionable VM-state and population-rollup rules;
6. Unknown and stale-data behavior; and
7. acceptable workflow cost at the supported scale.

## References

- [ADR 0026 — Platform-owned SCOM Distributed Applications](../decisions/0026-platform-owned-scom-distributed-applications.md)
- [Hyper-V SCOM monitoring research](../../hyper-v/monitoring-research.md)
- [Microsoft Operations Manager Distributed Applications](https://learn.microsoft.com/en-us/system-center/scom/manage-using-authoring-workspace?view=sc-om-2025)
- [Microsoft Operations Manager service-level objectives](https://learn.microsoft.com/en-us/system-center/scom/manage-monitor-sla-overview?view=sc-om-2025)
