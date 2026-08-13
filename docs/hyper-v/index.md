---
title: Hyper-V
description: Hyper-V health monitoring through SCOM and a constrained Azure Monitor track through Arc-enabled SCVMM and Arc-enabled hosts.
---

# Hyper-V

Hyper-V is a separate platform track. Its primary delivery is a SCOM Management Pack. Azure
Monitor now has a constrained development path for environments that use Azure Arc-enabled SCVMM
and Arc-enable each participating Hyper-V host for AMA/DCR telemetry.

| Delivery surface | Commitment | Status |
|---|---|---|
| **SCOM Management Pack** | Committed platform track | VSAE-verified and test-sealed development baseline; lab and release certification pending |
| **Azure Monitor through Arc-enabled SCVMM** | Constrained track | Development baseline; substantial parity and lab gates remain |

::: info Two independent solutions
The SCOM Management Pack and Azure Monitor Health Model have separate design, source,
deployment, testing, and release boundaries.
:::

## Why this is separate from Azure Local

Hyper-V and Azure Local share Windows Server virtualization and SCOM concepts, but they do not
have identical product topology or signal sources. Azure Local adds a prescribed, Azure-integrated
platform stack with opinionated storage, lifecycle management, registration, and Azure-side
services. Hyper-V must also account for standalone hosts, general-purpose failover clusters,
optional SCVMM management, and configurations that have no Azure dependency.

Network ATC is **not** an Azure Local-only capability. It is supported for eligible Windows Server
2025 Datacenter failover clusters and is this project's preferred host-networking baseline for such
Hyper-V clusters. When SCVMM and Windows Server SDN are the selected network-management authority,
the Management Pack must model that path instead of assuming Network ATC ownership. Older or
otherwise ineligible Hyper-V environments still require explicit non-ATC coverage.

The project will reuse stable authoring patterns and shared health semantics while keeping
platform-specific discoveries and monitoring independently supportable.

See the [Hyper-V design map](../design/hyper-v/index.md) for the separate
[SCOM](../design/hyper-v/scom-mp.md) and conditional
[Azure Monitor Health Models](../design/hyper-v/azure-monitor.md) lanes.

## Hyper-V topology research

The research baseline defines the candidate supported matrix for:

- standalone Hyper-V hosts;
- Hyper-V failover clusters;
- hosts and VMs managed by SCVMM;
- Network ATC-managed, manually managed, and SCVMM/SDN-managed host networking;
- virtual switches, adapters, storage, replication, and VM relationships; and
- supported Windows Server, SCOM, and SCVMM versions.

See [Research spikes](../design/research-spikes.md) and the
[Hyper-V SCOM track](scom-mp.md) for the delivery gate.

Phase-one execution is documented in the [Hyper-V SCOM monitoring research](monitoring-research.md)
plan. Its [catalog policy](monitoring-catalog.md) separates the exhaustive raw inventory from the
smaller default monitoring profile.
