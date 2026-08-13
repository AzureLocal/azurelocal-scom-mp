---
title: Azure Local Azure Monitor design
description: Azure Local entity, signal, prerequisite, deployment, and operations decisions for Azure Monitor Health Models.
---

# Azure Local Azure Monitor Health Models design

This lane applies the accepted Azure Local platform baseline to Azure Monitor Health Models. Its
cloud prerequisites and entity mappings do not apply to the conditional Hyper-V Arc-enabled SCVMM
track.

## Canonical design

| Concern | Design source |
|---|---|
| Platform entities and signal meaning | [Scope and topology](../scope-topology.md), [signal catalog](../signal-catalog.md), and [concept mapping](../concept-mapping.md) |
| Entity graph | [ADR 0006](../decisions/0006-azmon-entity-model.md) |
| Health and alert separation | [Health model](../health-model.md), [ADR 0003](../decisions/0003-health-rollup-policy.md), and [ADR 0009](../decisions/0009-alert-vs-health-state.md) |
| Cloud prerequisites | [ADR 0010](../decisions/0010-cloud-prerequisites-contract.md) and [prerequisites](../../azure-monitor/prerequisites.md) |
| Metrics and logs | [ADR 0012](../decisions/0012-azure-monitor-workspace-vs-law-metrics.md) |
| Deployment | [ADR 0013](../decisions/0013-azmon-deployment-strategy.md) |
| Cost, scale, and retention | [ADR 0019](../decisions/0019-cost-scale-retention.md) |
| Customization and lifecycle | [Customization](../customization.md) and supporting ADRs 0007–0008 and 0014–0018 |

## Implementation section

Continue to [Azure Monitor Health Models for Azure Local](../../azure-monitor/index.md) for the
implementation plan, prerequisites, entity graph, signals, alerts, workbooks, and Bicep artifacts.
