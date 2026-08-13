---
title: Azure Local SCOM design
description: Azure Local topology, discovery, health, customization, and delivery decisions for the SCOM Management Pack.
---

# Azure Local SCOM Management Pack design

This lane applies the accepted Azure Local platform baseline to SCOM. It does not govern the
Hyper-V SCOM MP unless a shared pattern is explicitly adopted through ADR 0022 or a Hyper-V
successor ADR.

## Canonical design

| Concern | Design source |
|---|---|
| Platform entities and relationships | [Scope and topology](../scope-topology.md), [ADR 0001](../decisions/0001-scope-and-topology.md), and [ADR 0005](../decisions/0005-scom-class-hierarchy.md) |
| Discovery | [ADR 0002](../decisions/0002-signal-source.md), [ADR 0004](../decisions/0004-scom-discovery-strategy.md), and [ADR 0011](../decisions/0011-l3-azure-scope-and-connectivity.md) |
| Health and rollup | [Health model](../health-model.md), [signal catalog](../signal-catalog.md), [ADR 0003](../decisions/0003-health-rollup-policy.md), and [ADR 0009](../decisions/0009-alert-vs-health-state.md) |
| Distributed Application | [Azure Local DA design](distributed-application.md), [ADR 0005](../decisions/0005-scom-class-hierarchy.md), [ADR 0018](../decisions/0018-self-observability.md), and [ADR 0026](../decisions/0026-platform-owned-scom-distributed-applications.md) |
| Overrides | [Customization](../customization.md) and [ADR 0008](../decisions/0008-customization-strategy.md) |
| Packaging | [ADR 0022](../decisions/0022-scom-management-pack-packaging-boundaries.md), accepted independent Azure Local product |
| Testing and release | ADRs [0014](../decisions/0014-cicd-pipeline-strategy.md), [0015](../decisions/0015-testing-strategy.md), [0016](../decisions/0016-signing-and-secrets.md), [0017](../decisions/0017-versioning-and-release.md), and [0018](../decisions/0018-self-observability.md) |

## Implementation section

Continue to the [Azure Local SCOM Management Pack](../../scom-mp/index.md) for planned artifacts,
health-tree views, operator content, and future implementation reference.

The Azure Local DA is a required product artifact, not an optional dashboard convenience. It is the
deployment-level service root for Health Explorer, views, reports, dashboards, and SLOs; aggregate
and dependency monitors perform the underlying health propagation.
