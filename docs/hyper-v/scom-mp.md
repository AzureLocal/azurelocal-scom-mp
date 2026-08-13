---
title: Hyper-V SCOM Management Pack
description: Planned SCOM Management Pack for standalone, clustered, and supported SCVMM-managed Hyper-V environments.
---

# Hyper-V SCOM Management Pack

The Hyper-V SCOM Management Pack is the committed delivery surface for this platform track.
It will apply the shared SCOM health-model patterns to the Hyper-V topology approved by the
research and ADR gates.

## Planned scope

| Capability | Planned outcome |
|---|---|
| Topology | Stable classes and relationships for approved standalone, clustered, and SCVMM-managed configurations |
| Discovery | Supported PowerShell and CIM/WMI discovery workflows with offline fixtures |
| Health | Availability, performance, configuration, and applicable security rollups |
| Monitoring | Unit, aggregate, and dependency monitors plus event and performance collection rules |
| Customization | Upgrade-safe override packs with Lab, Standard, and Strict tiers |
| Operations | State, alert, performance, and topology views with optional SquaredUp dashboards |
| Delivery | Sealed, signed, tested, versioned Management Pack artifacts and operator documentation |

## Delivery gate

Authoring starts after these decisions are complete:

1. [Research and define the Hyper-V SCOM monitoring catalog — AB#7327](https://dev.azure.com/hybridcloudsolutions/Hybrid%20Infrastructure%20Health%20Monitoring/_workitems/edit/7327).
2. Decide the shared library and packaging boundary in proposed [ADR 0022](../design/decisions/0022-scom-management-pack-packaging-boundaries.md).
3. Accept a Hyper-V scope/topology successor ADR based on the spike results.

The Management Pack will not inherit Azure Local-only assumptions such as solution updates, DCMA,
or the Azure Local ARM resource model. It will include Network ATC discovery and health for eligible
Windows Server 2025 Datacenter Hyper-V clusters while preserving explicit coverage for non-ATC and
SCVMM/SDN-managed networking.

The Microsoft Hyper-V 2019 Management Pack is a research reference only. This product will not
import, extend, override, or require it; useful monitoring ideas must be revalidated and implemented
independently in this project's own Management Pack.

## Phase one — monitoring research

The active first phase is not MP XML authoring. It is the exhaustive inventory and evidence gate in
[AB#7327](https://dev.azure.com/hybridcloudsolutions/Hybrid%20Infrastructure%20Health%20Monitoring/_workitems/edit/7327).
Eleven child spikes separate topology, Windows Server, Hyper-V/VM, clustering/CSV, storage/Replica,
networking, prior Microsoft MP research, SCOM workflow mapping, threshold engineering, lab
validation, and final catalog curation.

- [Research plan](monitoring-research.md)
- [Monitoring catalog and threshold policy](monitoring-catalog.md)

The research records everything technically observable, but only actionable and supportable signals
will ship enabled by default.

## Why the SCOM design is reusable

The reusable parts are substantial: class and relationship conventions, discovery workflows,
monitor types, health dimensions, rollup rules, override strategy, signing, tests, and operator
views. The platform-specific parts remain the entity inventory, discovery data sources, signal
catalog, thresholds, and support matrix.
