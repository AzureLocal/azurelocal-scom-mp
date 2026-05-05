---
title: Migration — SCOM → Azure Monitor
description: SCOM-to-Azure-Monitor migration guidance for Azure Local health monitoring.
---

# Migration — SCOM → Azure Monitor

> **Phase 5 deliverable.** End-to-end migration guidance for operators moving from the
> SCOM track to the Azure Monitor track (or running both side by side).

!!! info "Phase 5 — coming after Phase 3 + 4"
    Migration walkthroughs land after both tracks are authored and validated.
    See [PLAN.md](https://github.com/AzureLocal/azurelocal-scom-mp/blob/main/PLAN.md).

## Looking for the concept crosswalk?

The side-by-side concept mapping (SCOM ↔ Azure Monitor) lives under Design now —
it's a track-agnostic foundation, not migration content:

→ **[Design / Concept Mapping (SCOM ↔ AzMon)](../design/concept-mapping.md)**

## What this section will cover

| Page (planned) | Content |
|---|---|
| Migration walkthrough | Step-by-step move from SCOM MP to Azure Monitor Health Model |
| Migration tool output | Auto-migrated vs manual migration items via the Microsoft `MP2AzMon` tool |
| Side-by-side operation | How to run both tracks against the same Azure Local during transition |
| Cutover checklist | Pre-cutover, cutover day, post-cutover validation |
| Lessons learned | Common gotchas operators hit during migration |

## Why migrate (or not)?

| Reason to stay on SCOM | Reason to move to Azure Monitor |
|---|---|
| Existing SCOM investment + skill set | No SCOM infrastructure to maintain |
| Hybrid estate that includes non-Azure-Local servers | Azure-only / Arc-only estate |
| Custom SCOM MPs already in production | Greenfield Azure Local deployment |
| Need on-prem alerting independent of Azure | Want Azure-native alerting + Workbooks + Grafana |

The dual-track design of this project means you don't have to choose — both surfaces
read from the same conceptual model.

