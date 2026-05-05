---
title: SCOM Management Pack
description: Track 1 — SCOM Management Pack for Azure Local (HCI) clusters.
---

# SCOM Management Pack

> **Track 1** — SCOM health monitoring for Azure Local clusters.

This section covers **how the design is implemented** as a SCOM Management Pack. The
*design itself* — entity model, signal catalog, rollup policy, customization — is
track-agnostic and lives in [Design](../design/index.md). Read that first.

!!! info "Phase 3 — coming after Phase 2 sign-off"
    Authoring lands in Phase 3 once the [Design ADRs](../design/decisions/index.md)
    move from Proposed to Accepted. Current roadmap is in
    [PLAN.md](https://github.com/AzureLocal/azurelocal-scom-mp/blob/main/PLAN.md).

## What lives here

| Page (planned) | Content |
|---|---|
| Health model XML overview | The sealed `AzureLocal.HealthModel.mp` structure |
| Class hierarchy reference | Implementation of [ADR 0005](../design/decisions/0005-scom-class-hierarchy.md) |
| Discoveries reference | PowerShell discovery scripts per [ADR 0004](../design/decisions/0004-scom-discovery-strategy.md) |
| Monitor inventory | Unit / Aggregate / Dependency monitors mapping to the [Signal Catalog](../design/signal-catalog.md) |
| Override pack reference | Customer-facing overrides per [ADR 0008](../design/decisions/0008-customization-strategy.md) |
| Authoring guide | VSAE + Kevin Holman fragment library workflow |
| Lifecycle | Sealing, signing, import, update, retirement |
| Diagrams | Health rollup tree (Mermaid) + class hierarchy (draw.io) |

## Where to start

1. [Design overview](../design/index.md) — the conceptual foundation
2. [SCOM class hierarchy ADR](../design/decisions/0005-scom-class-hierarchy.md)
3. [Discovery strategy ADR](../design/decisions/0004-scom-discovery-strategy.md)
4. [Customization](../design/customization.md) — how operators tune the SCOM track

## Track-specific upstream references

- [Brian Wren / MPAuthor video series (SC 2012 R2 — Operations Manager Management Packs)](https://learn.microsoft.com/en-us/shows/system-center-2012-r2-operations-manager-management-packs/)
- [Kevin Holman — SCOM Management Pack Fragment Library](https://kevinholman.com/2017/02/05/scom-management-pack-fragment-library/)
- [Silect MP Author](https://www.silect.com/mp-author/) (free authoring tool)
- See full reference list in [REFERENCES.md](https://github.com/AzureLocal/azurelocal-scom-mp/blob/main/REFERENCES.md).
