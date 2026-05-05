# ADR 0014 — CI/CD Pipeline Strategy

- **Status**: Accepted
- **Date**: 2026-05-05
- **Deciders**: @kturner

## Context

Phase 3 (SCOM MP authoring) and Phase 4 (Azure Monitor Bicep) cannot start safely without a defined
CI/CD pipeline. We need build-and-validate gates for three independent artifact streams:

1. **SCOM MPs** — sealed `AzureLocal.SCOM.Library.mp` + sealed `AzureLocal.SCOM.Monitoring.mp` +
   unsealed `AzureLocal.SCOM.Override.xml` (per ADR 0007)
2. **Azure Monitor Bicep** — `src/azure-monitor/bicep/main.bicep` + modules + `.bicepparam` tiers
   (per ADR 0013)
3. **MkDocs documentation site** — published to GitHub Pages with `mike` versioning

There is no pipeline yet. Without one, the three artifacts drift from each other and from the
design docs, signing keys leak into hand-runs, and there is no reproducible release artifact.

## Decision

Adopt a **GitHub Actions–only** CI/CD model with one workflow per artifact stream, all triggered
on PR and on push to `main`. Releases are cut by [release-please](https://github.com/googleapis/release-please)
in Conventional Commits mode.

### Workflows (under `.github/workflows/`)

| Workflow | Trigger | Job summary |
|---|---|---|
| `mp-build.yml` | PR + main; tags `v*` | Restore VSAE solution → `MPSeal` against test key (PR) or prod key from KeyVault (release) → `MPVerify` → `MPBPA` → upload `*.mp` + `*.xml` as artifact |
| `bicep-validate.yml` | PR + main | `bicep build` all `.bicep` → `bicep lint` → `az deployment sub what-if` against the lab subscription using `lab.bicepparam` → publish ARM JSON to `dist/` artifact |
| `pwsh-test.yml` | PR + main | `Invoke-ScriptAnalyzer -Settings PSGallery -Severity Warning,Error` → run `Pester` against `src/scom-mp/discovery/*.Tests.ps1` and `src/azure-monitor/scripts/*.Tests.ps1` |
| `kql-validate.yml` | PR + main | Validate every `kql/signals/*.kql` file parses (`Kusto.Language` parser) and runs against the lab LAW with mock seed data; assert expected health state |
| `parity-check.yml` | PR + main | Custom step (PowerShell) that walks `signal-catalog.md` and asserts every threshold name appears in **both** the SCOM override pack AND a `bicepparam` tier (cross-track parity per ADR 0007) |
| `docs-build.yml` | PR | `mkdocs build --strict` → run `lychee` link-check across rendered site |
| `docs-deploy.yml` | push main; release tag | `mike deploy --update-aliases <version> latest` → `mike set-default latest` → push to `gh-pages` |
| `release-please.yml` | push main | Standard release-please action — opens/maintains release PR, on merge tags `vX.Y.Z` and creates GitHub Release |

### Branch protection on `main`

- All seven workflows above must pass
- Linear history required; squash-merge only
- One review required, code-owner required for `src/scom-mp/`, `src/azure-monitor/bicep/`, and `docs/design/decisions/`

### Identity model

- **Cloud-side jobs** (`bicep-validate`, `kql-validate`) authenticate to Azure via **GitHub OIDC**
  federated to a dedicated lab-only service principal — no long-lived secrets in repo settings.
- **MP signing key** for release builds is fetched from Azure Key Vault using the same OIDC SPN;
  scoped to a release-only environment that requires manual approval (see ADR 0016).

### Out of scope (deliberately)

- Self-hosted runners — start on GitHub-hosted, revisit only if KQL or Bicep eval cost becomes
  a real problem.
- Container builds — no containers in this repo.
- Third-party CI (Azure Pipelines, Jenkins) — explicitly rejected; the org standard is GH Actions.

## Consequences

- **Positive**:
  - Every artifact has a green-build gate before it can land on `main`.
  - `parity-check.yml` mechanically enforces the cross-track naming guarantee from ADR 0007 —
    so the design promise survives long-term drift.
  - Release-please gives clean SemVer tags and an auto-generated changelog matching the
    org-standard format.
  - OIDC eliminates the "rotate the SPN secret" toil and the leak-in-logs risk.
- **Negative**:
  - More workflow YAML to maintain than a single monolith would need.
  - `kql-validate` requires a long-lived lab LAW with seeded fixtures — small but ongoing cost.
- **Neutral**:
  - Pipeline lives in `.github/workflows/` only; no Azure DevOps mirror.
- **Affected components / owners**: All Phase 3 and Phase 4 deliverables, plus the Phase 6
  release process. Workflow files added by the first commit of Phase 3 work.

## Alternatives considered

- **Single monolithic CI workflow** — rejected; couples MP, Bicep, KQL, and docs cycle times,
  and surfaces unrelated failures on every PR.
- **Self-hosted runners on a SCOM management server** — rejected for now; GitHub-hosted Windows
  runners can install VSAE/MPVerify on demand, and self-hosted adds opex without a clear win at
  Phase 3.
- **Azure DevOps Pipelines** — rejected; not the org standard, and OIDC + release-please are
  better-supported in GitHub Actions.
- **No `parity-check`** — rejected; ADR 0007's cross-track naming promise is unenforceable
  without a mechanical gate, and would silently rot.
- **`bicep what-if` only at release time** — rejected; what-if is the cheapest way to catch
  schema drift on Health Model preview API churn, so it runs every PR.

## References

- ADR 0007 — Naming convention (cross-track parity)
- ADR 0013 — Azure Monitor deployment strategy (Bicep-first)
- ADR 0016 — Signing & secrets management (sibling ADR for key handling detail)
- ADR 0017 — Versioning & release policy (sibling ADR; release-please configuration)
- [release-please](https://github.com/googleapis/release-please)
- [Azure login GitHub Action with OIDC](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure)
- Brian Wren MP authoring guide — MPSeal / MPVerify usage
