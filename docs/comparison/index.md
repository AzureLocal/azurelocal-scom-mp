---
title: On-premises SCOM → Azure Monitor migration
description: Monitoring migration guidance from on-premises SCOM Management Packs to Azure Monitor Health Models.
---

# On-premises SCOM → Azure Monitor migration

> **Planned deliverable.** End-to-end migration guidance for operators moving from the
> on-premises SCOM Management Pack solution to the corresponding Azure Monitor Health Models
> solution—or running both side by side during transition.

This is a **monitoring-platform migration**, not a VM migration, workload migration, Azure Local
migration, or Hyper-V-to-Azure migration. The two destination scopes are deliberately separate:

| Platform | Migration scope |
|---|---|
| Azure Local | Azure Local SCOM Management Pack → Azure Local Azure Monitor Health Models |
| Hyper-V | Hyper-V SCOM Management Pack → Hyper-V Azure Monitor Health Models, only if ADR 0023 records a go decision |

::: info Planned after both Azure Local surfaces ship
Migration walkthroughs land after both implementation tracks are authored and validated.
See the [implementation plan](https://github.com/Hybrid-Solutions-Cloud/hybrid-health-monitoring/blob/main/PLAN.md).
:::

## Looking for the concept crosswalk?

The Azure Local side-by-side concept mapping (SCOM ↔ Azure Monitor) lives under Design now. It is
the conceptual foundation for this migration lane, not a Hyper-V design contract:

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
