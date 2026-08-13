---
title: Design
description: Platform-first design map for the Azure Local and Hyper-V SCOM and Azure Monitor delivery surfaces.
---

# Design

The design is organized **platform first, delivery surface second**. Start in one of the four lanes
below rather than assuming that an Azure Local entity, signal, threshold, or dependency also applies
to Hyper-V.

| Platform | SCOM Management Pack | Azure Monitor Health Models |
|---|---|---|
| **Azure Local** | [Accepted design baseline](azure-local/scom-mp.md) | [Accepted baseline; API revalidation next](azure-local/azure-monitor.md) |
| **Hyper-V** | [Comprehensive proposed architecture; active evidence research](hyper-v/scom-mp.md) | [Conditional research track](hyper-v/azure-monitor.md) |

## Source ownership

Accepted [ADR 0030](decisions/0030-platform-first-source-tree.md) applies the same hierarchy to
product source:

| Platform | SCOM source | Azure Monitor source |
|---|---|---|
| Azure Local | `src/azure-local/scom-mp/` | `src/azure-local/azure-monitor/` |
| Hyper-V | `src/hyper-v/scom-mp/` | `src/hyper-v/azure-monitor/` (reserved until ADR 0023 records a go decision) |

Optional SquaredUp content sits under the solution it visualizes. Shared research and build tooling
must not become a shared runtime product dependency.

## Shared design

The [shared-design section](shared/index.md) contains only portfolio rules and patterns that are
intended to span more than one lane. Shared intent does not automatically make an accepted Azure
Local topology or signal contract valid for Hyper-V; the Hyper-V research and successor ADRs must
adopt it explicitly.

Shared topics include:

- platform-first ownership and delivery-surface boundaries;
- common health-state vocabulary and rollup design principles;
- stable logical naming and customization goals;
- independent SCOM runtime and packaging boundaries;
- research evidence and decision gates; and
- repository, documentation, validation, and release conventions.

## Azure Local design

The [Azure Local design](azure-local/index.md) is the completed baseline originally developed in
ADRs 0001–0019. It has two committed delivery lanes:

- [Azure Local SCOM Management Pack design](azure-local/scom-mp.md), including the
  [Azure Local Distributed Application](azure-local/distributed-application.md); and
- [Azure Local Azure Monitor Health Models design](azure-local/azure-monitor.md).

The existing [scope and topology](scope-topology.md), [signal catalog](signal-catalog.md), and most
of the accepted early ADRs describe Azure Local unless a page says otherwise.

## Hyper-V design

The [Hyper-V design](hyper-v/index.md) is intentionally separate:

- [Hyper-V SCOM Management Pack design](hyper-v/scom-mp.md) is the active first phase under
  AB#7327, includes a [comprehensive architecture map](hyper-v/architecture.md), and has a required,
  research-refined
  [Hyper-V Distributed Application](hyper-v/distributed-application.md); and
- [Hyper-V Azure Monitor design](hyper-v/azure-monitor.md) remains conditional on the Arc-enabled
  SCVMM research and ADR 0023.

Hyper-V can reuse sound patterns, but its support matrix, topology, Network ATC/manual/SCVMM-SDN
network paths, discoveries, signals, defaults, and thresholds require their own evidence.

## Architecture decisions

The [ADR index](decisions/index.md) includes a scope map showing which platform and delivery lane
owns each accepted or proposed decision. Read the scope map before applying an older Azure
Local-era ADR to newer Hyper-V work.
