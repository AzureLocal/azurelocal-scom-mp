---
title: Shared design
description: Portfolio-level principles and explicitly shared architecture for Hybrid Infrastructure Health Monitoring.
---

# Shared design

Shared design is deliberately small. It contains rules that coordinate the product lanes without
forcing them to share unsupported topology, signals, binaries, or release behavior.

## Governing principles

1. **Platform first, surface second.** Azure Local and Hyper-V own separate support contracts.
2. **Share meaning before implementation.** Health-state vocabulary, logical names, and operator
   outcomes can align while source APIs and workflows remain different.
3. **Evidence controls reuse.** A pattern becomes Hyper-V design only after its spike and ADR adopt
   it; an accepted Azure Local ADR is not inherited silently.
4. **Customization survives upgrades.** Released SCOM MPs use override packs; released Azure
   Monitor artifacts use deployment parameters and tier files.
5. **Conditional work stays conditional.** Hyper-V Azure Monitor is not a committed implementation
   until ADR 0023 records a go decision.
6. **Share research, not runtime.** Azure Local and Hyper-V have independent SCOM namespaces,
   packages, classes, Distributed Applications, versions, and support lifecycles.

## Shared pages and decisions

| Topic | Scope |
|---|---|
| [Health-model principles](../health-model.md) | Shared state vocabulary and structural principles; current detailed baseline remains Azure Local until Hyper-V successor ADRs are accepted |
| [Customization](../customization.md) | Shared product goal; exact artifacts and defaults remain lane-specific |
| [Research spikes](../research-spikes.md) | Evidence contract and cross-lane decision gates |
| [ADR 0021](../decisions/0021-platform-and-delivery-track-architecture.md) | Platform-first product structure |
| [ADR 0022](../decisions/0022-scom-management-pack-packaging-boundaries.md) | Accepted independent SCOM packaging and runtime boundary |
| [ADR 0026](../decisions/0026-platform-owned-scom-distributed-applications.md) | A separate platform-owned Distributed Application in each SCOM product |
| [ADR 0020](../decisions/0020-vitepress-documentation-platform.md) | Documentation platform |
| [ADR 0024](../decisions/0024-repository-and-publishing-identity.md) | Repository and publishing identity |

## What is not automatically shared

- classes, relationships, discoveries, source APIs, and credentials;
- signal availability, thresholds, defaults, and alert knowledge;
- Azure Local lifecycle, registration, DCMA, and Azure resource dependencies;
- Hyper-V standalone-host and general failover-cluster behavior;
- Network ATC eligibility or SCVMM/SDN ownership in a particular topology; and
- Management Pack binaries, sealed dependencies, classes, or Distributed Applications across the
  two platform products.
