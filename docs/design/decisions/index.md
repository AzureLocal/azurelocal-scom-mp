# Architecture Decision Records

Lightweight, numbered, immutable records of architectural decisions that govern the shared
foundation plus the Azure Local and Hyper-V platform tracks.

These are project-scoped ADRs. Org-wide platform standards live in
[`AzureLocal/platform/decisions/`](https://github.com/AzureLocal/platform/tree/main/decisions).

## Design lane scope map

The early accepted ADRs were written for the Azure Local baseline. They do not automatically govern
Hyper-V simply because both products use SCOM or share health terminology.

| Design lane | Governing decisions |
|---|---|
| Shared portfolio architecture | ADRs 0020, 0021, and 0024 |
| Shared SCOM product boundaries | ADR 0022 requires independent runtime products; ADR 0026 requires platform-owned DAs |
| Azure Local platform baseline | ADRs 0001–0003, 0007–0009, and 0014–0018 |
| Azure Local SCOM | ADRs 0004, 0005, 0011, 0022, and 0026 |
| Azure Local Azure Monitor | ADRs 0006, 0010, 0012, 0013, and 0019 |
| Hyper-V platform and SCOM | Accepted ADRs 0022, 0025, and 0026 plus proposed ADRs 0027–0029 for package, object/discovery, and health/DA architecture |
| Hyper-V Azure Monitor | ADR 0023, proposed go/defer/no-go gate |

Cross-cutting lifecycle ADRs can provide reusable patterns, but each platform and delivery lane
must still validate its applicable topology, dependencies, artifacts, tests, and release contract.

## Index

| # | Title | Status |
|---|---|---|
| [0001](./0001-scope-and-topology.md) | Scope & topology — Azure Local infrastructure (3 layers, ~27 entities) | Accepted |
| [0002](./0002-signal-source.md) | Primary signal source — Azure Local PowerShell APIs + ARM/Resource Graph | Accepted |
| [0003](./0003-health-rollup-policy.md) | Health rollup policy — worst-state default with documented exceptions | Accepted |
| [0004](./0004-scom-discovery-strategy.md) | SCOM discovery strategy — PowerShell Discovery (not WMI) | Accepted |
| [0005](./0005-scom-class-hierarchy.md) | SCOM class hierarchy + hosting relationships (3-layer model) | Accepted |
| [0006](./0006-azmon-entity-model.md) | Azure Monitor entity model alignment (mirrors SCOM 1:1) | Accepted |
| [0007](./0007-naming-convention.md) | Naming convention — cross-track parity | Accepted |
| [0008](./0008-customization-strategy.md) | Customization strategy — sealed MP + override pack tiers; Bicep params + tiers | Accepted |
| [0009](./0009-alert-vs-health-state.md) | Alert vs health-state separation policy | Accepted |
| [0010](./0010-cloud-prerequisites-contract.md) | Cloud-side prerequisites contract (HCI Insights, AMA, DCMA, Service Group, RBAC, networking) | Accepted |
| [0011](./0011-l3-azure-scope-and-connectivity.md) | L3 Azure-side scope: agent-local Arc health checks (Tier A) vs. management server ARM probes (Tier B) | Accepted |
| [0012](./0012-azure-monitor-workspace-vs-law-metrics.md) | Azure Monitor Workspace vs Log Analytics Workspace: metrics routing for the health model (dual-topology support) | Accepted |
| [0013](./0013-azmon-deployment-strategy.md) | Azure Monitor Health Model deployment strategy — Bicep-first, portal-bootstrap | Accepted |
| [0014](./0014-cicd-pipeline-strategy.md) | CI/CD pipeline strategy — GitHub Actions, OIDC, release-please | Accepted |
| [0015](./0015-testing-strategy.md) | Testing strategy — 5-layer pyramid, cross-track parity gate | Accepted |
| [0016](./0016-signing-and-secrets.md) | Signing & secrets management — two-key MP signing, OIDC SPNs | Accepted |
| [0017](./0017-versioning-and-release.md) | Versioning & release policy — single repo SemVer, Conventional Commits, mike docs | Accepted |
| [0018](./0018-self-observability.md) | Self-observability — monitor the monitoring pipeline as a parallel root branch | Accepted |
| [0019](./0019-cost-scale-retention.md) | Cost, scale, and data retention — per-tier ingestion envelopes, sharding, retention policy | Accepted |
| [0020](./0020-vitepress-documentation-platform.md) | Documentation platform — VitePress with Mermaid and GitHub Pages | Accepted |
| [0021](./0021-platform-and-delivery-track-architecture.md) | Platform-first architecture — Azure Local and Hyper-V, split by SCOM and Azure Monitor delivery surfaces | Accepted |
| [0022](./0022-scom-management-pack-packaging-boundaries.md) | Independent SCOM packaging — no shared runtime MP dependencies | Accepted |
| [0023](./0023-hyper-v-azure-monitor-through-arc-enabled-scvmm.md) | Hyper-V Azure Monitor through Arc-enabled SCVMM — go, defer, or no-go gate | Proposed |
| [0024](./0024-repository-and-publishing-identity.md) | Repository and publishing identity — Hybrid Solutions Cloud and labs.hybridsolutions.cloud | Accepted |
| [0025](./0025-hyper-v-network-management-authority.md) | Hyper-V network-management authority — prefer Network ATC when eligible; distinguish SCVMM/SDN and manual paths | Accepted |
| [0026](./0026-platform-owned-scom-distributed-applications.md) | Platform-owned SCOM Distributed Applications — separate Azure Local and Hyper-V service roots | Accepted |
| [0027](./0027-hyper-v-scom-management-pack-decomposition.md) | Hyper-V SCOM Management Pack decomposition — modular sealed product suite and customer override boundary | Proposed |
| [0028](./0028-hyper-v-object-and-discovery-architecture.md) | Hyper-V object and discovery architecture — stable mobility identity, staged discovery, and cookdown | Proposed |
| [0029](./0029-hyper-v-health-alert-and-da-rollup.md) | Hyper-V health, alert, and DA rollup — evidence-driven state, actionable alerts, and topology-aware service health | Proposed |

## When to write an ADR

- Any architectural choice that affects how the SCOM MP or Azure Monitor health model is built
- Any decision that creates a constraint on Phases 3–6
- Any cross-track parity decision
- Any decision the next maintainer would otherwise have to re-litigate

## Format

See [`template.md`](./template.md). Numbered sequentially, ZERO-padded to four digits. Filename
is `NNNN-kebab-case-title.md`. Once an ADR is **Accepted** it is immutable — supersede it with a
new ADR rather than editing it in place.

## Workflow

1. Open a PR adding the ADR with status `Proposed`
2. Discuss and refine in PR review
3. Merge with status `Accepted` once consensus reached
4. If later overturned, write a successor ADR and mark this one `Superseded by ADR XXXX`
