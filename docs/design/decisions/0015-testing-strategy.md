# ADR 0015 — Testing Strategy

- **Status**: Accepted
- **Date**: 2026-05-05
- **Deciders**: @kturner

## Context

The repo ships three artifact streams (sealed SCOM MPs, Bicep modules, MkDocs site) that are
authored independently but must remain semantically aligned (same logical thresholds, same
entity model, same health propagation). Phase 3 and Phase 4 cannot have a "done" gate without a
defined verification approach. ADR 0014 lists the *workflows* that run tests; this ADR defines
*what* the tests are and *what coverage means* for each artifact.

## Decision

Adopt a **layered test pyramid** scoped to what is realistically testable per artifact, with one
hard gate per layer. No artifact merges to `main` without its layer passing.

### Layer 1 — Static / lint (every PR, fast)

| Artifact | Tool | Gate |
|---|---|---|
| SCOM MP XML | `MPVerify.exe` | Zero errors; warnings reviewed |
| SCOM MP XML | `MPBPA` (MP Best Practice Analyzer) | Zero criticals; warnings reviewed |
| Bicep | `bicep build` + `bicep lint --diagnostics-format sarif` | Zero `error`-severity diagnostics |
| PowerShell | `PSScriptAnalyzer` (Settings: `PSGallery`, Severity ≥ `Warning`) | Zero `Error`; `Warning` reviewed |
| KQL | `Microsoft.Azure.Kusto.Language` parser | Every `*.kql` parses successfully |
| Markdown | `markdownlint-cli2` (default rules + `MD013` off) | Zero errors |
| Links | `lychee` against built MkDocs site | Zero broken internal links; external links cached + warn-only |

### Layer 2 — Unit (every PR, fast, hermetic)

| Artifact | Tool | What gets tested |
|---|---|---|
| PowerShell discovery scripts (SCOM) | `Pester 5.x` | Every discovery in `src/scom-mp/discovery/` has a sibling `*.Tests.ps1` that mocks `Get-Cluster`, `Get-PhysicalDisk`, `Get-StoragePool`, etc. and asserts the discovery emits the expected `<Instance>` elements |
| KQL signals | `KustoLoco` (or LAW with seed table) — local Kusto evaluator | Each `kql/signals/<signal>.kql` has a sibling `<signal>.tests.json` listing `{seed_rows, expected_state}` cases; harness loads seed, runs query, asserts `HealthState` column matches |
| Bicep modules | `bicep what-if` against an empty resource group | Each module deploys cleanly with `lab.bicepparam`; what-if returns expected resource set |
| Health rollup logic | Pester | Synthetic entity tree fed through aggregate/dependency monitor logic; assert worst-state per ADR 0003 |

### Layer 3 — Integration (PR + nightly, against lab subscription)

| Artifact | Method | Gate |
|---|---|---|
| Bicep stack | `az deployment sub create` against lab subscription using `lab.bicepparam` | Deployment succeeds; smoke test queries `healthmodels` resource and asserts entities match `entities.bicep` count |
| KQL signals (live) | Run every signal against lab LAW with seeded HCI cluster | Each signal returns at least one row of expected schema (`HealthState`, `EntityId`, `Timestamp`) |
| MP load test | Import sealed MPs into pre-prod SCOM management group | All discoveries run within 10 minutes; no `Health Service Modules` event-log errors |

### Layer 4 — Cross-track parity (every PR, hard gate)

This is the keystone test that protects ADR 0007's naming-parity promise. A single PowerShell
script (`tests/Test-Parity.ps1`) walks:

1. `docs/design/signal-catalog.md` — extract every `Threshold name` column entry
2. `src/scom-mp/AzureLocal.SCOM.Override.xml` — extract every `<Override>` parameter name
3. `src/azure-monitor/bicep/parameters/*.bicepparam` — extract every parameter assignment

Asserts: **every threshold name in the catalog appears in BOTH the SCOM override pack AND at least
one bicepparam file**, and vice versa (no orphan parameters on either side). Fails the PR with a
diff if any names diverge.

### Layer 5 — Behavioral / acceptance (release tag only)

| Artifact | Method |
|---|---|
| Full SCOM MP | Deploy to pre-prod SCOM, run for 24h, capture `OperationsManager` event log; assert no script-runtime errors, no orphaned discoveries |
| Full Azure Monitor stack | Deploy `standard.bicepparam` to a real Azure Local lab cluster, drive a known fault (e.g. fail a physical disk), assert root-entity health flips to Degraded within 15 minutes |

### Test code location

- Pester tests: alongside the script under test (`Foo.ps1` → `Foo.Tests.ps1`)
- KQL signal seed data: `src/azure-monitor/kql/signals/<signal>.tests.json`
- Cross-track parity: `tests/Test-Parity.ps1` (top-level `tests/`)
- Behavioral acceptance scripts: `tests/acceptance/` (excluded from PR runs; tagged `Acceptance`)

### What is **not** tested in CI

- SCOM-side end-to-end with real cluster — too expensive for PR runs; covered by Layer 5 release gate
- Performance / scale (max cluster size, max signals) — captured as a separate Phase 6 perf-baseline exercise, not a gate
- Localization — out of scope (English-only deliverable)

## Consequences

- **Positive**:
  - Every PR has a fast, hermetic gate (Layer 1 + 2) that catches structural and logic regressions before integration cost is paid.
  - Layer 4 mechanically enforces cross-track parity — the design promise from ADR 0007 cannot silently rot.
  - Layer 5 acceptance gate gives confidence to cut a SemVer release without manual smoke testing.
- **Negative**:
  - Authoring overhead — every discovery script and every KQL signal requires a sibling test file. Will slow down Phase 3 day-1 velocity.
  - Layer 3 requires an always-on lab subscription with a seeded LAW, which has small but ongoing Azure cost.
- **Neutral**:
  - Test runners are GitHub-hosted Windows for MP/Pester, ubuntu-latest for everything else.
- **Affected components / owners**: All Phase 3 and Phase 4 deliverables. The first PR for Phase 3 must include `tests/Test-Parity.ps1` and at least one Pester test file as the pattern reference.

## Alternatives considered

- **Manual test plan, no automation** — rejected; cross-track parity cannot be sustained by manual review across ~250 signals.
- **Pester for Bicep too** — rejected; `bicep what-if` is the right tool for IaC validation, Pester for PowerShell only.
- **End-to-end test on every PR** — rejected; too expensive (Azure deployment time, lab quota), held to nightly + release.
- **Test in production SCOM** — rejected; Layer 5 uses pre-prod SCOM only.
- **Skip Layer 4 (parity)** — rejected; ADR 0007's value is gated entirely on this test existing.

## References

- ADR 0003 — Health rollup policy (drives Layer 2 rollup tests)
- ADR 0007 — Naming convention (drives Layer 4 parity test)
- ADR 0013 — Azure Monitor deployment strategy (Bicep what-if as Layer 1+3)
- ADR 0014 — CI/CD pipeline (workflows that run these tests)
- [Pester](https://pester.dev/)
- [PSScriptAnalyzer](https://learn.microsoft.com/en-us/powershell/module/psscriptanalyzer/)
- [KustoLoco](https://github.com/NeilMacMullen/KustoLoco) — local Kusto evaluator for offline KQL tests
- [bicep what-if](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-what-if)
- Brian Wren — MPVerify and MPBPA usage
