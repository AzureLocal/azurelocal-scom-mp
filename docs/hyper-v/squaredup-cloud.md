---
title: SquaredUp Cloud for Hyper-V Azure Monitor
description: Conditional SquaredUp Cloud deliverable owned by the Hyper-V Azure Monitor Health Models solution.
---

# SquaredUp Cloud for Hyper-V Azure Monitor

::: warning Conditional with Azure Monitor
This is not a committed deliverable. It can proceed only if Arc-enabled SCVMM research succeeds and
ADR 0023 records a go decision for the Hyper-V Azure Monitor Health Models solution. Its reserved
source boundary is `src/hyper-v/azure-monitor/squaredup/`.
:::

SquaredUp Cloud would be an optional visualization layer over the Hyper-V Azure Monitor entity,
telemetry, health, and alert model. It would not consume or extend the Hyper-V SCOM Management Pack
as a runtime dependency.

## Research questions

- Which Arc-enabled SCVMM resources and Azure Monitor entities are stable dashboard targets?
- Which supported metrics, logs, health states, and alerts can be queried at cluster, host, and VM scope?
- Can multi-site and multi-subscription views preserve stable identity and acceptable query cost?
- Which dashboard content remains useful when guest management or Azure Monitor Agent coverage is partial?
- Can workspace exports be versioned and tested independently from the Azure Monitor deployment?

## Gate

No workspace, dashboard, or deployable source is authored before the required research completes and
[ADR 0023](../design/decisions/0023-hyper-v-azure-monitor-through-arc-enabled-scvmm.md) resolve the
parent solution.

## Resources

- [SquaredUp Cloud](https://squaredup.com)
- [Conditional Hyper-V Azure Monitor design](../design/hyper-v/azure-monitor.md)
