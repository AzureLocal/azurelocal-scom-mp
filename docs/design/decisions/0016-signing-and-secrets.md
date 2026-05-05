# ADR 0016 — Signing & Secrets Management

- **Status**: Accepted
- **Date**: 2026-05-05
- **Deciders**: @kturner

## Context

Two distinct secrets management problems must be solved before Phase 3 (SCOM MP) and Phase 4
(Azure Monitor) can produce releasable artifacts:

1. **SCOM MP signing** — sealed `.mp` files require an `.snk` strong-name key pair. The same key
   must sign every release of `AzureLocal.SCOM.Library.mp` and `AzureLocal.SCOM.Monitoring.mp`
   for the entire lifetime of the project, or every existing customer override pack breaks on upgrade.
2. **Azure deployment identity** — `bicep what-if` (PR validation, ADR 0014/0015) and the lab/standard
   acceptance deployments need a service principal with sufficient rights against a real Azure
   subscription, without parking long-lived secrets in repo settings or on developer laptops.

A throwaway dev key and an SPN in `secrets.AZURE_CLIENT_SECRET` would unblock work today but fail
the supply-chain bar for a published management pack and would leak credentials in CI logs the
first time someone forgot to mask a variable.

## Decision

### SCOM MP signing

**Two-key model**, both stored in Azure Key Vault, fetched at build time only via OIDC.

| Key | Storage | Use | Rotation |
|---|---|---|---|
| **Test signing key** (`AzureLocal.SCOM.Test.snk`) | Key Vault `kv-azurelocal-scom-mp-ci` (lab subscription); replica downloadable to dev workstations | PR builds, all dev sealing | Rotated freely; no customer dependency |
| **Release signing key** (`AzureLocal.SCOM.Release.snk`) | Key Vault `kv-azurelocal-scom-mp-release` (release subscription); HSM-backed | Tagged release builds only | **Never rotated** — rotation breaks all customer override packs (sealed-MP rule). Only replaced by a new project name (e.g. v2 fork) |

- The release Key Vault has a single role assignment: a release-only GitHub OIDC SPN, scoped via a
  GitHub Environment named `release` that requires manual approval.
- Local development uses the **test key only**. There is no path for a developer workstation to
  pull the release key. The release key is only accessible from a `mp-build.yml` job running in
  the `release` environment.
- `MPSeal` invocations in CI fetch the key with `az keyvault secret download --vault-name … --name SCOM-Signing-Key --file $env:RUNNER_TEMP/key.snk`,
  use it, and rely on the runner being ephemeral (GitHub-hosted) for cleanup.
- `secret-scanning` and `push-protection` are required on the GitHub repo; any `.snk` that
  accidentally lands in a commit fails push.

### Azure identity for deployments

**Three OIDC-federated SPNs**, no long-lived secrets:

| SPN | GitHub environment | Scope | Used by |
|---|---|---|---|
| `sp-azurelocal-scom-mp-pr` | (no env; PRs from forks blocked) | `Reader` + `Microsoft.Resources/deployments/validate/action` on the `lab` subscription | `bicep-validate.yml` (what-if only — no actual writes) |
| `sp-azurelocal-scom-mp-lab` | `lab` (no approval) | `Contributor` on the lab resource group only | `kql-validate.yml` integration tests, nightly Layer 3 deploys |
| `sp-azurelocal-scom-mp-release` | `release` (manual approval) | `Contributor` on the release subscription's release-acceptance resource group; `Key Vault Secrets User` on the release KV | Layer 5 acceptance deploys, MP signing key fetch |

- All three use [GitHub OIDC federated credentials](https://learn.microsoft.com/en-us/entra/workload-id/workload-identity-federation-create-trust)
  bound to the specific repo + branch (`main`) or tag (`refs/tags/v*`) pattern. No `AZURE_CLIENT_SECRET`
  ever lands in repo or org secrets.
- PR runs from forks are blocked from cloud-side jobs entirely (label-gated `pull_request_target` is
  not used; we keep the OIDC trust limited to first-party PRs).

### Secret-handling rules across the repo

- **No secrets in repo at any time.** This includes `.snk`, `.pfx`, `.p12`, JSON keys, `.env`,
  `*.bicepparam` overrides containing IDs that map to specific tenants. Lab tenant IDs are
  considered configuration, not secrets, and may be checked in.
- **No secrets in workflow logs.** All `az`/`gh` commands that emit secrets must pipe through
  `--query` or `Out-Null`; CI runs with `ACTIONS_STEP_DEBUG` disabled by default.
- **Customer-owned secrets** (Key Vault names, action group webhooks, paging endpoints) are pure
  Bicep `param` inputs supplied at deployment time. None ship in this repo.
- **Pre-commit:** `gitleaks` runs as a pre-commit hook (see `.pre-commit-config.yaml`) and as a
  CI gate on every PR.

### Out of scope

- Notarization / authenticode signing of `.mp` files — sealed MPs use SCOM's strong-name model;
  Authenticode is not a SCOM concept.
- Customer-side override-pack signing — customers own their own override packs and their own
  signing keys (or leave them unsigned).

## Consequences

- **Positive**:
  - The release signing key never leaves Key Vault and is never accessible to a developer or to
    a PR build — supply-chain bar met for a published management pack.
  - Zero long-lived secrets in repo or org settings; OIDC + ephemeral runners eliminate the
    "leaked client secret in CI logs" class of bug.
  - GitHub Environments + manual approval gate gives a clear human checkpoint between merge and
    release artifact production.
- **Negative**:
  - Manual approval on every tagged release adds friction (acceptable trade-off).
  - Three SPNs to maintain instead of one shared SPN.
  - Lab subscription cost is permanent, not on-demand.
- **Neutral**:
  - Test signing key is freely shared with the team; not a secret in the supply-chain sense.
- **Affected components / owners**: Phase 3 first PR must add `mp-build.yml` with the OIDC
  config and `release` environment definition. Phase 4 first PR must add `bicep-validate.yml`
  with the `pr` SPN. Phase 6 release process gates on the `release` environment manual approval.

## Alternatives considered

- **Single signing key, dev access for everyone** — rejected; release key compromise has
  unbounded blast radius (every customer override pack permanently broken).
- **GitHub Actions repo secrets for SPN credentials** — rejected; long-lived secrets are a
  rotation and leak risk, OIDC eliminates both.
- **Self-hosted runner with the key on disk** — rejected; runner compromise = key compromise,
  and we'd own the OS patching cost.
- **Sign with a Microsoft-issued cert** — rejected; SCOM sealed MPs use strong-name only, not
  Authenticode.
- **Skip signing entirely (unsealed MPs)** — rejected; sealing is required for the
  Library → Monitoring → Override dependency chain (per ADR 0007 / Brian Wren Module 7) to be
  upgrade-safe.

## References

- ADR 0007 — Naming convention (sealed-MP 3-pack model)
- ADR 0014 — CI/CD pipeline (workflows that fetch keys)
- ADR 0015 — Testing strategy (Layer 3 + 5 use cloud-side SPNs)
- [GitHub OIDC → Azure federation](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure)
- [GitHub Environments + required reviewers](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)
- [Azure Key Vault HSM-backed secrets](https://learn.microsoft.com/en-us/azure/key-vault/managed-hsm/overview)
- [gitleaks](https://github.com/gitleaks/gitleaks)
- Brian Wren — sealed MP signing model (SC2012 Authoring Guide §5)
