---
title: Azure Local SCOM architecture
description: Runtime, packaging, discovery, health, and Distributed Application architecture for the independent Azure Local Management Pack.
---

# Azure Local SCOM architecture

The Azure Local SCOM product is a local, Azure-independent monitoring suite. It remains useful when
the cluster cannot reach Azure and does not place interactive authentication or customer secrets in
agent workflows.

![Azure Local SCOM architecture](/assets/diagrams/azure-local-scom-architecture.svg)

## Runtime boundaries

| Boundary | Runs where | Responsibility |
|---|---|---|
| Role seed | Every SCOM-managed Windows Server | Identify clustered Azure Local nodes without discovering ordinary Hyper-V or S2D systems |
| Topology discovery | Discovered Azure Local node role | Create stable deployment, node, storage, Network ATC, lifecycle, platform, pipeline, and DA objects |
| Shared health probe | Discovered Azure Local node role | Acquire 14 local health signals once per identical configuration through cookdown |
| Event and performance rules | Discovered Azure Local node role | Supplement state with high-confidence events and independently tunable time series |
| DA rollup | SCOM health service | Roll domain-specific node health into six components and one deployment service root |
| Azure Monitor solution | Azure | Own Azure resource, Resource Health, metric, log, alert, and cloud entity evaluation |

The optional future SCOM Azure Extension can add management-server ARM probes. The core suite never
depends on it.

## Product projects

The suite follows [ADR 0033](../decisions/0033-azure-local-scom-management-pack-decomposition.md):
Library, Discovery, Monitoring, Presentation, and optional Reporting are separate sealed projects.
Discovery and Monitoring each have a separate customer-owned unsealed override MP.

## Design invariants

- Azure Local and Hyper-V have no shared runtime Management Pack dependency.
- Cluster-scoped identity survives node ownership changes.
- No state is inferred Healthy because a probe failed or stopped reporting.
- Storage Health Service root-cause faults are preferred to duplicate per-drive paging.
- Thresholds, duration, alert behavior, and optional collections remain overrideable.
- The Default Management Pack is never a customization destination.
- Generated XML is development output until SDK, sealing, signing, and SCOM lab gates pass.
