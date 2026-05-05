---
title: SquaredUp Dashboard Server
description: Optional SquaredUp DS visualization layer for the Azure Local SCOM Management Pack.
---

# SquaredUp Dashboard Server (SCOM track)

!!! info "Optional deliverable — Phase 3"
    The SquaredUp DS dashboard pack is an optional deliverable that ships after the SCOM MP
    reaches GA. Source lives in `src/squaredup/ds/`. This page is a placeholder; content
    lands in Phase 3.

[SquaredUp Dashboard Server (DS)](https://ds.squaredup.com) is the leading on-premises
dashboard solution for System Center Operations Manager. It connects directly to the SCOM
SDK — no MP changes required — and renders health states, performance data, and alerts
from the `AzureLocal.*` classes automatically.

## Why SquaredUp works well with this MP

The Azure Local SCOM MP is designed with SquaredUp integration in mind:

1. **Consistent `AzureLocal.*` class prefix** — all tiles can target Azure Local entities
   by class prefix without per-class configuration.
2. **Distributed Application at the root** — the DS DA tile renders the full 3-layer
   health rollup tree (`Infrastructure` → `Platform` → `AzureServices` component groups)
   automatically.
3. **Alert allow-list + auto-resolve** (per [ADR 0009](../../design/decisions/0009-alert-vs-health-state.md))
   — prevents the alert tile from flooding the dashboard with transient state changes.

## Dashboard pack (planned)

A SquaredUp DS dashboard pack will ship as a separate deliverable in `src/squaredup/ds/`
once the SCOM MP reaches GA. Planned tiles:

| Dashboard | Contents |
|---|---|
| **Cluster Overview** | DA health rollup, node status grid, storage pool capacity, top alerts |
| **Storage Detail** | Volume free space trends, physical disk health, storage pool capacity waterfall |
| **Network Detail** | Network Intent state per node, RDMA utilisation, PFC/ETS status |
| **Platform Services** | Arc Resource Bridge, AKS Arc, DCMA, HCI Registration states |
| **Azure-side Health** | L3 ARM resource states (Key Vault, Storage Account, SPN expiry) |
| **Alert NOC** | Active alert list filtered to `AzureLocal.*`, grouped by severity |

## Resources

- [SquaredUp DS product site](https://ds.squaredup.com)
- [Dashboard packs catalog](https://ds.squaredup.com/dashboard-packs/)
- [SCOM MI dashboarding blog](https://squaredup.com/blog/dashboarding-scom-mi-in-squaredup/)
- [Health roll-up deep-dive](https://squaredup.com/blog/a-dive-into-health-roll-up/)
