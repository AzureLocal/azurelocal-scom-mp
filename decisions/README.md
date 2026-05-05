# Architecture Decision Records — azurelocal-scom-mp

Lightweight, numbered, immutable records of architectural decisions that govern the
SCOM Management Pack and Azure Monitor Health Model design for Azure Local.

These are project-scoped ADRs. Org-wide platform standards live in
[`AzureLocal/platform/decisions/`](https://github.com/AzureLocal/platform/tree/main/decisions).

## Index

| # | Title | Status |
|---|---|---|
| [0001](./0001-scope-and-topology.md) | Scope & topology — Azure Local infrastructure (3 layers, ~25 entities) | Proposed |
| 0002 | Primary signal source — Azure Local PowerShell APIs + ARM/Resource Graph | _planned_ |
| 0003 | Health rollup policy — worst-state default with impact exceptions | _planned_ |
| 0004 | SCOM discovery strategy — PowerShell Discovery (not WMI) | _planned_ |
| 0005 | SCOM class hierarchy + hosting relationships (3-layer model) | _planned_ |
| 0006 | Azure Monitor entity model alignment (mirrors SCOM 1:1) | _planned_ |
| 0007 | Naming convention — cross-track parity | _planned_ |
| 0008 | Customization strategy — sealed MP + override pack tiers; Bicep params + tiers | _planned_ |
| 0009 | Alert vs health-state separation policy | _planned_ |
| 0010 | Cloud-side prerequisites contract (HCI Insights, AMA, DCMA, Service Group, RBAC, networking) | _planned_ |

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
