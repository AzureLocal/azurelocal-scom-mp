---
title: Hyper-V design
description: Design map for the committed Hyper-V SCOM Management Pack and conditional Azure Monitor track.
---

# Hyper-V design

Hyper-V has its own support contract and topology. It reuses sound product principles but does not
inherit Azure Local entities, signals, thresholds, cloud dependencies, or accepted ADRs by default.

| Design lane | Commitment | Status |
|---|---|---|
| [SCOM Management Pack](scom-mp.md) | Committed | Phase-one research active under AB#7327 |
| [Azure Monitor through Arc-enabled SCVMM](azure-monitor.md) | Conditional | Research and go/defer/no-go ADR required |

## Platform design questions

- Which Windows Server, SCOM, cluster, and optional SCVMM versions are supported?
- Which standalone and clustered entities have stable discovery keys and ownership relationships?
- When is Network ATC the host-network authority, and when is networking manual or owned by
  SCVMM/SDN?
- Which signals should become default monitors, disabled monitors, collection rules, diagnostics,
  or exclusions?
- Which shared SCOM packaging option, if any, is safe for both platform MPs?
- Can Arc-enabled SCVMM expose a supportable Azure Monitor entity and telemetry model?

These questions are resolved through the [research backlog](../research-spikes.md), not by copying
the Azure Local design.
