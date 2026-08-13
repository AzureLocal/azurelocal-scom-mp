---
title: Azure Local design
description: Design map for the Azure Local SCOM Management Pack and Azure Monitor Health Models.
---

# Azure Local design

Azure Local has two committed, completely separate monitoring solutions. They use the same platform
evidence where applicable, but each owns its runtime architecture, deployment artifacts, health
state, customization, testing, versioning, and release lifecycle.

| Solution | Status | Start here |
|---|---|---|
| SCOM Management Pack | Committed; authoring planned | [Azure Local SCOM design](scom-mp.md) |
| Azure Monitor Health Models | Committed; current API revalidation next | [Azure Local Azure Monitor design](azure-monitor.md) |

## SCOM Management Pack solution

The [Azure Local SCOM Management Pack design](scom-mp.md) owns SCOM discoveries, classes,
relationships, monitors, rules, overrides, views, packaging, and the
[Azure Local Distributed Application](distributed-application.md). The Distributed Application is
not part of the Azure Monitor solution. Optional
[SquaredUp Dashboard Server](../../scom-mp/squaredup/index.md) content is packaged with this
solution, not with Azure Monitor.

## Azure Monitor Health Models solution

The [Azure Local Azure Monitor Health Models design](azure-monitor.md) owns Azure resource and
entity modeling, signal ingestion, Azure Monitor health evaluation, alerting, deployment, and its
cloud visualization artifacts. It does not depend on or extend the Azure Local SCOM Management Pack.
Optional [SquaredUp Cloud](../../azure-monitor/squaredup/index.md) content is packaged with this
solution, not with the SCOM Management Pack.

## Platform baseline

- [Scope and topology](../scope-topology.md)
- [Health model](../health-model.md)
- [Signal catalog](../signal-catalog.md)
- [Customization](../customization.md)
- [SCOM and Azure Monitor concept mapping](../concept-mapping.md)

Network ATC is important to Azure Local, but it is not unique to Azure Local. Eligible Windows
Server 2025 Datacenter Hyper-V failover clusters can also use it. Azure Local remains distinct
because of its prescribed platform integration, lifecycle, registration, DCMA, and Azure resource
model—not merely because a Network ATC intent exists.

## Decision scope

Use the [ADR scope map](../decisions/index.md#design-lane-scope-map) to distinguish platform-wide
Azure Local decisions from SCOM-only and Azure Monitor-only decisions.
