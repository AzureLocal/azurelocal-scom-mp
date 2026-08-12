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

1. [Research the Hyper-V topology, signals, and support matrix — AB#7327](https://dev.azure.com/hybridcloudsolutions/Hybrid%20Infrastructure%20Health%20Monitoring/_workitems/edit/7327).
2. Decide the shared library and packaging boundary in proposed [ADR 0022](../design/decisions/0022-scom-management-pack-packaging-boundaries.md).
3. Accept a Hyper-V scope/topology successor ADR based on the spike results.

The Management Pack will not inherit Azure Local-only assumptions such as Network ATC, solution
updates, DCMA, or the Azure Local ARM resource model.

## Why the SCOM design is reusable

The reusable parts are substantial: class and relationship conventions, discovery workflows,
monitor types, health dimensions, rollup rules, override strategy, signing, tests, and operator
views. The platform-specific parts remain the entity inventory, discovery data sources, signal
catalog, thresholds, and support matrix.
