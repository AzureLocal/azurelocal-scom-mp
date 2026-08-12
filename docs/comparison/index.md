---
title: Migration — SCOM → Azure Monitor
description: SCOM-to-Azure-Monitor migration guidance for Azure Local health monitoring.
---

# Migration — SCOM → Azure Monitor

> **Planned deliverable.** End-to-end migration guidance for operators moving from the
> Azure Local SCOM surface to Azure Monitor (or running both side by side).

::: info Planned after both Azure Local surfaces ship
Migration walkthroughs land after both implementation tracks are authored and validated.
See the [implementation plan](https://github.com/AzureLocal/azurelocal-scom-mp/blob/main/PLAN.md).
:::

## Looking for the concept crosswalk?

The side-by-side concept mapping (SCOM ↔ Azure Monitor) lives under Design now —
it's a track-agnostic foundation, not migration content:

→ **[Design / Concept Mapping (SCOM ↔ AzMon)](../design/concept-mapping.md)**

## What this section will cover

| Page (planned) | Content |
|---|---|
| Migration walkthrough | Step-by-step move from SCOM MP to Azure Monitor Health Model |
| Migration tool output | Auto-migrated vs manual migration items via the Microsoft `MP2AzMon` tool |
| Side-by-side operation | How to run both Azure Local delivery surfaces during transition |
| Cutover checklist | Pre-cutover, cutover day, post-cutover validation |
| Lessons learned | Common gotchas operators hit during migration |

## Why migrate (or not)?

| Reason to stay on SCOM | Reason to move to Azure Monitor |
|---|---|
| Existing SCOM investment + skill set | No SCOM infrastructure to maintain |
| Hybrid estate that includes non-Azure-Local servers | Azure-only / Arc-only estate |
| Custom SCOM MPs already in production | Greenfield Azure Local deployment |
| Need on-prem alerting independent of Azure | Want Azure-native alerting + Workbooks + Grafana |

For Azure Local, both surfaces use the same conceptual model where supported. Hyper-V migration
guidance is conditional on the Arc-enabled SCVMM Azure Monitor track passing its research gate.
