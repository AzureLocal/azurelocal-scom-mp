---
layout: home
title: Hybrid infrastructure health monitoring
titleTemplate: false
description: SCOM and Azure Monitor health models for Hyper-V and Azure Local.
hero:
  name: Hybrid Infrastructure
  text: Health monitoring
  tagline: SCOM and Azure Monitor health models for Hyper‑V and Azure Local.
  image:
    src: /assets/images/azurelocal-scom-mp-banner.svg
    alt: Hybrid Infrastructure Health Monitoring
  actions:
    - theme: brand
      text: Explore the design
      link: /design/
    - theme: alt
      text: View the roadmap
      link: /project/roadmap
features:
  - title: Azure Local
    details: A committed SCOM Management Pack and Azure Monitor Health Models for the full Azure Local infrastructure stack.
    link: /azure-local/
    linkText: Explore Azure Local
  - title: Hyper-V
    details: A committed Hyper-V SCOM Management Pack, with Azure Monitor on the roadmap when Arc-enabled SCVMM research passes its gate.
    link: /hyper-v/
    linkText: Explore Hyper-V
  - title: Shared design
    details: Common health semantics and SCOM engineering patterns, with platform-specific topology and signals kept explicit.
    link: /design/
    linkText: Explore the design
---

## What this project is

This project defines production-grade health monitoring for **Hyper-V and Azure Local
infrastructure** at the health-model level, rather than treating monitoring as a collection of
unrelated metric thresholds. Planning is organized by platform first and delivery surface second.

## Health model components

Both platforms use the same health-model grammar while retaining their own supported topology:

```mermaid
graph TD
    Root["Platform Health"]:::root
    Root --> HV["Hyper-V"]
    Root --> AzL["Azure Local"]
    HV --> HVS["SCOM MP"]
    HV -. research gate .-> HVA["Azure Monitor via Arc-enabled SCVMM"]
    AzL --> AzLS["SCOM MP"]
    AzL --> AzLA["Azure Monitor"]

    classDef root fill:#0078D4,color:#fff,stroke:none
```

## Tracks at a glance

| Platform | SCOM Management Pack | Azure Monitor Health Models |
|---|---|---|
| **Azure Local** | Committed — [Feature AB#7315](https://dev.azure.com/hybridcloudsolutions/Azure%20Local%20SCOM%20MP/_workitems/edit/7315) | Committed — [Feature AB#7316](https://dev.azure.com/hybridcloudsolutions/Azure%20Local%20SCOM%20MP/_workitems/edit/7316) |
| **Hyper-V** | Committed — [Feature AB#7317](https://dev.azure.com/hybridcloudsolutions/Azure%20Local%20SCOM%20MP/_workitems/edit/7317) | Conditional on Arc-enabled SCVMM research — [Feature AB#7318](https://dev.azure.com/hybridcloudsolutions/Azure%20Local%20SCOM%20MP/_workitems/edit/7318) |

## Companion tooling

[SquaredUp DS](https://ds.squaredup.com) and [SquaredUp Cloud](https://squaredup.com) are optional
visualization layers for the SCOM and Azure Monitor tracks respectively.

## Project status

::: info The platform split is planned
The original Azure Local design baseline is complete. The roadmap now separates Azure Local and
Hyper-V into their own Epics and delivery Features. Hyper-V research and the shared SCOM packaging
decision come before authoring. See the [project roadmap](/project/roadmap) and
[implementation plan](https://github.com/AzureLocal/azurelocal-scom-mp/blob/main/PLAN.md).
:::

| Phase | Description | Status |
|---|---|---|
| 0 | Research and planning | Complete |
| 1 | Documentation scaffold | Complete |
| 2 | Azure Local health-model design baseline | Complete |
| 3 | Platform split, ADO hierarchy, ADR and spike planning | Complete |
| 4 | Research and architecture gates | Next |
| 5 | Azure Local and Hyper-V delivery work | Planned |
| 6 | Validation, documentation, and releases | Planned |
