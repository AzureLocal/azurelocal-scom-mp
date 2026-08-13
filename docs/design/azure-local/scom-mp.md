---
title: Azure Local SCOM design
description: Azure Local topology, discovery, health, customization, and delivery decisions for the SCOM Management Pack.
---

# Azure Local SCOM Management Pack design

This lane applies the accepted Azure Local platform baseline to SCOM. It does not govern the
Hyper-V SCOM MP unless a shared pattern is explicitly adopted through ADR 0022 or a Hyper-V
successor ADR.

## Current status

The independent Azure Local SCOM product now has a functional development baseline. Its source
builds five Management Pack artifacts and passes deterministic offline contract tests. Microsoft
SDK verification, sealing/signing, SCOM lab import, discovery, fault/recovery, upgrade,
coexistence, and removal evidence remain release gates.

## Canonical design

| Concern | Design source |
|---|---|
| Product boundary | [Architecture](architecture.md) and [ADR 0032](../decisions/0032-azure-local-scom-local-runtime-boundary.md) |
| Packaging | [Management Pack structure](management-pack-structure.md) and [ADR 0033](../decisions/0033-azure-local-scom-management-pack-decomposition.md) |
| Platform entities and relationships | [Class and relationship model](class-and-relationship-model.md) and [ADR 0034](../decisions/0034-azure-local-object-discovery-and-da-architecture.md) |
| Discovery and execution | [Discovery and workflow architecture](discovery-and-workflow-architecture.md) |
| Health, alerts, and rollup | [Health and alert architecture](health-and-alert-architecture.md) and [ADR 0035](../decisions/0035-azure-local-health-alert-and-rollup-architecture.md) |
| Distributed Application | [Azure Local DA design](distributed-application.md), [ADR 0026](../decisions/0026-platform-owned-scom-distributed-applications.md), and ADRs 0034–0035 |
| Overrides | [Override and tuning architecture](override-and-tuning-architecture.md) and [ADR 0008](../decisions/0008-customization-strategy.md) |
| Testing and release | ADRs [0014](../decisions/0014-cicd-pipeline-strategy.md), [0015](../decisions/0015-testing-strategy.md), [0016](../decisions/0016-signing-and-secrets.md), [0017](../decisions/0017-versioning-and-release.md), and [0018](../decisions/0018-self-observability.md) |

## Implementation section

Continue to the [Azure Local SCOM Management Pack](../../scom-mp/index.md) for the implementation
inventory, monitoring research, catalog, administration guide, and validation status.

The Azure Local DA is a required product artifact, not an optional dashboard convenience. It is the
deployment-level service root for Health Explorer, views, reports, dashboards, and SLOs; aggregate
and dependency monitors perform the underlying health propagation.
