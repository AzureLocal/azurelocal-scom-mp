# Architecture Decision Records — azurelocal-scom-mp

Lightweight, numbered, immutable records of architectural decisions that govern the
SCOM Management Pack and Azure Monitor Health Model design for Azure Local.

These are project-scoped ADRs. Org-wide platform standards live in
[`AzureLocal/platform/decisions/`](https://github.com/AzureLocal/platform/tree/main/decisions).

## Index

| # | Title | Status |
|---|---|---|
| [0001](./0001-scope-and-topology.md) | Scope & topology — Azure Local infrastructure (3 layers, ~27 entities) | ✅ Accepted |
| [0002](./0002-signal-source.md) | Primary signal source — Azure Local PowerShell APIs + ARM/Resource Graph | ✅ Accepted |
| [0003](./0003-health-rollup-policy.md) | Health rollup policy — worst-state default with documented exceptions | ✅ Accepted |
| [0004](./0004-scom-discovery-strategy.md) | SCOM discovery strategy — PowerShell Discovery (not WMI) | ✅ Accepted |
| [0005](./0005-scom-class-hierarchy.md) | SCOM class hierarchy + hosting relationships (3-layer model) | ✅ Accepted |
| [0006](./0006-azmon-entity-model.md) | Azure Monitor entity model alignment (mirrors SCOM 1:1) | ✅ Accepted |
| [0007](./0007-naming-convention.md) | Naming convention — cross-track parity | ✅ Accepted |
| [0008](./0008-customization-strategy.md) | Customization strategy — sealed MP + override pack tiers; Bicep params + tiers | ✅ Accepted |
| [0009](./0009-alert-vs-health-state.md) | Alert vs health-state separation policy | ✅ Accepted |
| [0010](./0010-cloud-prerequisites-contract.md) | Cloud-side prerequisites contract (HCI Insights, AMA, DCMA, Service Group, RBAC, networking) | ✅ Accepted |
| [0011](./0011-l3-azure-scope-and-connectivity.md) | L3 Azure-side scope: agent-local Arc health checks (Tier A) vs. management server ARM probes (Tier B) | ✅ Accepted |
| [0012](./0012-azure-monitor-workspace-vs-law-metrics.md) | Azure Monitor Workspace vs Log Analytics Workspace: metrics routing for the health model (dual-topology support) | ✅ Accepted |
| [0013](./0013-azmon-deployment-strategy.md) | Azure Monitor Health Model deployment strategy — Bicep-first, portal-bootstrap | ✅ Accepted |
| [0014](./0014-cicd-pipeline-strategy.md) | CI/CD pipeline strategy — GitHub Actions, OIDC, release-please | ✅ Accepted |
| [0015](./0015-testing-strategy.md) | Testing strategy — 5-layer pyramid, cross-track parity gate | ✅ Accepted |
| [0016](./0016-signing-and-secrets.md) | Signing & secrets management — two-key MP signing, OIDC SPNs | ✅ Accepted |
| [0017](./0017-versioning-and-release.md) | Versioning & release policy — single repo SemVer, Conventional Commits, mike docs | ✅ Accepted |
| [0018](./0018-self-observability.md) | Self-observability — monitor the monitoring pipeline as a parallel root branch | ✅ Accepted |
| [0019](./0019-cost-scale-retention.md) | Cost, scale, and data retention — per-tier ingestion envelopes, sharding, retention policy | ✅ Accepted |

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
