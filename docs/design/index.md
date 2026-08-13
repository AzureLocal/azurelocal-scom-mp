---
title: Design
description: Platform-first design map for the Azure Local and Hyper-V SCOM and Azure Monitor delivery surfaces.
---

# Design

The design is organized **platform first, delivery surface second**. Start in one of the four lanes
below rather than assuming that an Azure Local entity, signal, threshold, or dependency also applies
to Hyper-V.

Each lane is a separate solution-design boundary. The SCOM Management Pack and Azure Monitor Health
Models for the same platform may reference common platform evidence, but they do not share runtime
architecture, deployment artifacts, health state, release lifecycle, or navigation ownership.

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

| Solution type | Optional visualization deliverable |
|---|---|
| Azure Local SCOM MP | [SquaredUp Dashboard Server](../scom-mp/squaredup/index.md) |
| Azure Local Azure Monitor | [SquaredUp Cloud](../azure-monitor/squaredup/index.md) |
| Hyper-V SCOM MP | [SquaredUp Dashboard Server](../hyper-v/squaredup-dashboard-server.md) |
| Hyper-V Azure Monitor | [SquaredUp Cloud](../hyper-v/squaredup-cloud.md), conditional with the solution |

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

The [Azure Local platform design map](azure-local/index.md) points to two committed but independent
solutions:

- [Azure Local SCOM Management Pack design](azure-local/scom-mp.md), including the
  [Azure Local Distributed Application](azure-local/distributed-application.md); and
- [Azure Local Azure Monitor Health Models design](azure-local/azure-monitor.md).

The existing [scope and topology](scope-topology.md), [signal catalog](signal-catalog.md), and most
of the accepted early ADRs describe Azure Local unless a page says otherwise.

## Hyper-V design

The [Hyper-V platform design map](hyper-v/index.md) points to two independent solution boundaries:

- [Hyper-V SCOM Management Pack design](hyper-v/scom-mp.md) is the active first phase, includes a
  [comprehensive architecture map](hyper-v/architecture.md), and has a required, research-refined
  [Hyper-V Distributed Application](hyper-v/distributed-application.md); and
- [Hyper-V Azure Monitor design](hyper-v/azure-monitor.md) remains conditional on the Arc-enabled
  SCVMM research and ADR 0023.

Hyper-V can reuse sound patterns, but its support matrix, topology, Network ATC/manual/SCVMM-SDN
network paths, discoveries, signals, defaults, and thresholds require their own evidence.

## Architecture decisions

The [ADR index](decisions/index.md) includes a scope map showing which platform and delivery lane
owns each accepted or proposed decision. Read the scope map before applying an older Azure
Local-era ADR to newer Hyper-V work.
