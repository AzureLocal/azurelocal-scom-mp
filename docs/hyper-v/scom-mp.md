---
title: Hyper-V SCOM Management Pack
description: Planned SCOM Management Pack for standalone, clustered, and supported SCVMM-managed Hyper-V environments.
---

# Hyper-V SCOM Management Pack

The Hyper-V SCOM Management Pack is the committed delivery surface for this platform track. It can
reuse research and engineering practices, but its runtime health model is authored independently
for the Hyper-V topology approved by the research and ADR gates.

## Planned scope

| Capability | Planned outcome |
|---|---|
| Topology | Stable classes and relationships for approved standalone, clustered, and SCVMM-managed configurations |
| Discovery | Supported PowerShell and CIM/WMI discovery workflows with offline fixtures |
| Health | Availability, performance, configuration, and applicable security rollups |
| Monitoring | Unit, aggregate, and dependency monitors plus event and performance collection rules |
| Distributed Application | A Hyper-V-owned service root for every supported cluster or standalone host, with dynamic component membership, rollup, views, reports, dashboards, and SLO targeting |
| Customization | Separate customer-owned Discovery and Monitoring override MPs with optional Lab, Standard, and Strict starter templates |
| Operations | State, alert, performance, and topology views with optional SquaredUp dashboards |
| Delivery | Sealed, signed, tested, versioned Management Pack artifacts and operator documentation |

## Delivery gate

Authoring starts after these decisions are complete:

1. Research and define the Hyper-V SCOM monitoring catalog.
2. Apply the independent packaging boundary in accepted [ADR 0022](../design/decisions/0022-scom-management-pack-packaging-boundaries.md).
3. Refine the required [Hyper-V Distributed Application](../design/hyper-v/distributed-application.md)
   membership and rollup contract through the topology and workflow spikes.
4. Accept a Hyper-V scope/topology successor ADR based on the spike results.

The comprehensive proposed design is now available in the
[Hyper-V SCOM architecture map](../design/hyper-v/scom-mp.md). It covers package decomposition,
classes and relationships, staged discovery, workflows and cookdown, health and alerts, dynamic DA
membership and rollup, authoring standards, least privilege, operability, testing, and release.

The design now defines the sealed-versus-unsealed boundary in detail. Discovery and Monitoring each
have a corresponding customer-owned override MP; the Default Management Pack is never used. Lab,
Standard, and Strict are optional public starter templates, not automatically imported policy. See
the [override and tuning architecture](../design/hyper-v/override-and-tuning-architecture.md) and
the public [Management Pack administration guide](management-pack-guide.md).

The Management Pack will not inherit Azure Local-only assumptions such as solution updates, DCMA,
or the Azure Local ARM resource model. It will include Network ATC discovery and health for eligible
Windows Server 2025 Datacenter Hyper-V clusters while preserving explicit coverage for non-ATC and
SCVMM/SDN-managed networking.

The Microsoft Hyper-V 2019 Management Pack is a research reference only. This product will not
import, extend, override, or require it; useful monitoring ideas must be revalidated and implemented
independently in this project's own Management Pack.

## Phase one — monitoring research

The active first phase is not MP XML authoring. It is the exhaustive inventory and evidence gate
described in the [monitoring research plan](monitoring-research.md).
Twelve child Tasks separate topology, Windows Server, Hyper-V/VM, clustering/CSV, storage/Replica,
networking, prior Microsoft MP research, SCOM workflow mapping, threshold engineering, lab
validation, final catalog curation, and comprehensive architecture validation.

- [Research plan](monitoring-research.md)
- [Monitoring catalog and threshold policy](monitoring-catalog.md)
- [Comprehensive SCOM architecture](../design/hyper-v/architecture.md)
- [Distributed Application design](../design/hyper-v/distributed-application.md)
- [Management Pack administration guide](management-pack-guide.md)

The research records everything technically observable, but only actionable and supportable signals
will ship enabled by default.

## Why the SCOM design is reusable

The reusable parts are substantial: class and relationship conventions, discovery workflows,
monitor types, health dimensions, rollup rules, override strategy, signing, tests, and operator
views. The platform-specific parts remain the entity inventory, discovery data sources, signal
catalog, thresholds, support matrix, and Distributed Application implementation. Research and
engineering methods can be reused; no Azure Local runtime MP is referenced.
