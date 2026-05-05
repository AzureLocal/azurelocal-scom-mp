---
title: Azure Monitor Health Models
description: Azure Monitor Health Models for Azure Local (HCI) — overview.
---

# Azure Monitor Health Models

> Track 2 — Native Azure Monitor health monitoring for Azure Local clusters.

!!! tip "Start here — Prerequisites"
    Before building or deploying the health model, work through the [Prerequisites](prerequisites.md)
    page. The model itself collects nothing — it pulls signals from data that other features (HCI
    Insights, AMA, DCMA, Resource Health) must already be flowing.

!!! info "Coming soon"
    The full health model design lands in Phase 2. See [PLAN.md](https://github.com/AzureLocal/azurelocal-scom-mp/blob/main/PLAN.md) for the roadmap.

## What will be here

- Health model concepts (entities, signals, relationships)
- Azure Local entity hierarchy and signal inventory
- Service Group wiring and auto-discovery
- ARM / Bicep deployment templates
- KQL signal queries
- Alert rules and Action Group integration
- Azure portal designer walkthrough
