---
title: Hyper-V design
description: Design map for the Hyper-V SCOM Management Pack and constrained Azure Monitor track.
---

# Hyper-V design

Hyper-V has its own support contract and topology. Its SCOM Management Pack and constrained Azure
Monitor Health Models are completely separate solutions: neither shares runtime components,
deployment artifacts, health state, or release lifecycle with the other. Both may reuse validated
Hyper-V research without creating a product dependency.

| Design lane | Commitment | Status |
|---|---|---|
| [SCOM Management Pack](scom-mp.md) | Committed | Comprehensive architecture proposed; phase-one research active |
| [Azure Monitor through Arc-enabled SCVMM](azure-monitor.md) | Constrained development | SCVMM inventory plus Arc-enabled host telemetry; live validation and parity review required |

## SCOM Management Pack solution

The SCOM lane now has implementation-grade design contracts for the
[end-to-end architecture](architecture.md), [Management Pack structure](management-pack-structure.md),
[class and relationship model](class-and-relationship-model.md),
[discovery and workflows](discovery-and-workflow-architecture.md),
[health and alerts](health-and-alert-architecture.md),
[Distributed Application](distributed-application.md), [authoring standards](authoring-standards.md),
[security and operability](security-and-operability.md), and
[validation and release](validation-and-release.md).

The diagrams on these pages are rendered by the site's Vue component so architecture, sequence,
state, class, and decision flows remain readable in both light and dark documentation themes.

The [Hyper-V Distributed Application](distributed-application.md) belongs only to this SCOM
solution. Optional [SquaredUp Dashboard Server](../../hyper-v/squaredup-dashboard-server.md)
content also belongs to the Hyper-V SCOM solution.

## Azure Monitor Health Models solution

The [constrained Azure Monitor design](azure-monitor.md) is a separate solution boundary.
It remains gated on Arc-enabled SCVMM research and ADR 0023 and does not inherit the SCOM class,
workflow, Distributed Application, packaging, or health-state implementation.
Optional [SquaredUp Cloud](../../hyper-v/squaredup-cloud.md) content remains inside this same
conditional boundary and cannot proceed before the Azure Monitor solution receives a go decision.

## Platform design questions

- Which Windows Server, SCOM, cluster, and optional SCVMM versions are supported?
- Which standalone and clustered entities have stable discovery keys and ownership relationships?
- When is Network ATC the host-network authority, and when is networking manual or owned by
  SCVMM/SDN?
- Which signals should become default monitors, disabled monitors, collection rules, diagnostics,
  or exclusions?
- Which stable keys and relationships populate each standalone-host or cluster
  [Distributed Application](distributed-application.md)?
- Can Arc-enabled SCVMM expose a supportable Azure Monitor entity and telemetry model?

SCOM packaging is no longer an open question. [ADR 0022](../decisions/0022-scom-management-pack-packaging-boundaries.md)
requires completely independent Azure Local and Hyper-V runtime products.

These questions are resolved through the [research backlog](../research-spikes.md), not by copying
the Azure Local design.
