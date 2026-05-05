# ADR 0017 — Versioning & Release Policy

- **Status**: Accepted
- **Date**: 2026-05-05
- **Deciders**: @kturner

## Context

The repo produces three independently versioned artifact streams that each have different
upgrade semantics:

1. **Sealed SCOM MPs** — `AzureLocal.SCOM.Library.mp` and `AzureLocal.SCOM.Monitoring.mp`. SCOM
   enforces strict version handling: a sealed MP version is part of every override pack's
   reference, and override packs only load if the referenced sealed-MP version is present. The
   Library and Monitoring packs have a `<References>` chain (Monitoring depends on Library, per
   ADR 0007), so their version movement is coupled.
2. **Bicep modules / Azure Monitor health model** — modular IaC. Customers consume by either
   `az deployment` against `main.bicep` at a specific git tag, or by registering a Bicep
   module from the published artifact.
3. **MkDocs documentation site** — `mike`-versioned, deployed to GitHub Pages. Customers may
   land on docs that no longer match the MP they have installed if versioning drifts.

There is currently no policy that says when a change bumps major vs minor, no documented
relationship between the three streams, and no release cadence. Without one, every release is
a one-off judgement call and the SCOM "sealed MP version contract" is fragile.

## Decision

### Single repo version, three artifacts pinned to it

The repo carries **one SemVer version** (e.g. `v1.2.0`) reflected in:

- `package.json` / `pyproject.toml` style root version file: `VERSION` (single-line, just the
  number, e.g. `1.2.0`)
- `<Version>` element of both sealed MPs (set by `mp-build.yml` from `VERSION`)
- `metadata.version` of every Bicep module (set by `bicep-validate.yml` from `VERSION`)
- `mike deploy <version>` of the docs site (`docs-deploy.yml`)

All three artifacts ship together at every release. There is no path where the Library MP
ships at `v1.2.0` and the Bicep at `v1.3.0` — they are released as a coordinated set. Patch
releases for one stream still bump the shared version (e.g. a docs typo → `v1.2.1` for all
three).

### SemVer rules — what bumps what

| Change | SCOM MP | Bicep | Docs | Bump |
|---|---|---|---|---|
| Add a new `Class` / `RelationshipType` | Library | Entities module | Yes | **Minor** |
| Remove or rename a `Class` / `RelationshipType` | Library | Entities module | Yes | **Major** |
| Add a unit/aggregate/dependency monitor | Monitoring | (n/a) | Yes | **Minor** |
| Change default health rollup behavior of an existing monitor | Monitoring | Entities module | Yes | **Major** (behavioral) |
| Add a KQL signal | (n/a) | `kql/signals/` | Yes | **Minor** |
| Change a default threshold value | Override pack defaults + bicepparam tier defaults | Yes | Yes | **Minor** (operators must re-review tuning) |
| Rename a parameter / threshold name | Override + bicepparam | Yes | Yes | **Major** (breaks customer override packs) |
| Add an action-group / alert rule | (n/a) | Alerts module | Yes | **Minor** |
| Bump `<Version>` of the Library MP only (rebuild) | Library + Monitoring (Library version is referenced) | (n/a) | (n/a) | **Patch minimum** — see "Library coupling" below |
| Docs-only fix (typo, link, diagram) | (n/a) | (n/a) | Yes | **Patch** |
| Test-only / CI-only change | (n/a) | (n/a) | (n/a) | **No release** (excluded from release-please via `chore:` or `ci:`) |

### Library MP coupling rule

Because every override pack and every Monitoring MP references the Library MP **by version**,
the Library version is part of the public contract. Therefore:

- The Library MP version may not regress.
- Bumping the Library version forces a Monitoring MP rebuild (because Monitoring's
  `<Reference>` to Library carries the version).
- Override packs authored by customers must be rebuilt against the new Library version for any
  Library version bump — even patch. We document this explicitly in the changelog.
- We treat **any** Library MP `<Version>` change as Minor at minimum, never Patch, to make
  this contract obvious in tags.

### Conventional Commits → release-please

Releases are cut by [release-please](https://github.com/googleapis/release-please) configured
in Conventional Commits mode:

| Commit prefix | Bump |
|---|---|
| `feat:` | Minor |
| `fix:` | Patch |
| `feat!:` / `fix!:` / `BREAKING CHANGE:` footer | Major |
| `docs:` | Patch (docs-only fix) |
| `chore:`, `ci:`, `test:`, `refactor:`, `style:`, `build:` | No release |

A `release-please.yml` config at repo root pins the schema to `simple` (single root version)
and points to `VERSION` as the manifest file.

### Pre-1.0 behavior

The repo is currently pre-1.0. While `0.x.y`:

- Minor (`0.x.0`) may include breaking changes — the SemVer "anything goes pre-1.0" rule
  applies. Changelog must call out breaks loudly.
- We commit to cutting `1.0.0` only after Phase 5 completes (Phase 6 release).
- The "Library coupling rule" above still applies pre-1.0 — even at `0.x` we honor the sealed-MP
  version contract because customer override packs may already exist in pre-prod environments.

### Release cadence

- **Patch releases**: as needed, no cadence. Triggered by docs-fix or CI-fix PRs.
- **Minor releases**: at least every 6 weeks while in active development; release-please
  opens a release PR continuously, we merge when content justifies.
- **Major releases**: explicitly planned. Coordinated with a roadmap entry and a 30-day
  pre-announcement on the docs site.
- **Long-Term Support**: no LTS branches in 1.x. If demand emerges post-1.0 we revisit;
  not promised in advance.

### Deprecation policy

- A class, monitor, signal, or parameter may be deprecated in any minor release.
- Deprecation = mark `Deprecated="true"` in the MP / `@deprecated` description in Bicep / red
  banner on the docs page; behavior unchanged.
- Removal requires a major bump and at least one minor release of overlap where the item is
  deprecated but still functional.

### Versioning the docs site

- `mike deploy <version> latest` on every release tag — `latest` always points to the most
  recent stable.
- Pre-1.0 minor versions get their own slug (`0.3`, `0.4`, …) so customers running an older
  MP can find matching docs.
- The default landing on `azurelocal.cloud/azurelocal-scom-mp/` is `latest`. Older versions
  available via the version selector.

## Consequences

- **Positive**:
  - Single repo version means a customer can match "I'm running v1.2.0" to one set of docs,
    one MP pair, and one Bicep state — no version-drift hunting.
  - SemVer rules table makes "is this a breaking change?" a checklist, not a debate.
  - Library coupling rule is explicit, so the sealed-MP version contract is impossible to
    violate by accident.
  - release-please automates the cut, so cadence is bounded by content readiness, not by
    release-engineering effort.
- **Negative**:
  - Coupled releases mean a docs-only typo bumps all three streams. The version space gets
    "noisy" with patch tags. We accept this as the price of a single source-of-truth version.
  - Customers may install a v1.2.1 MP but think they need v1.2.1 of the Bicep when only the
    docs changed. Changelog must clearly mark "docs-only" patches.
- **Neutral**:
  - `mike` versioning means the published docs site grows linearly with releases. Disk cost
    on `gh-pages` is negligible.
- **Affected components / owners**: Phase 3 / Phase 4 first PRs must add `VERSION`,
  `release-please-config.json`, `.release-please-manifest.json`. Phase 6 release process
  gates on the rules above.

## Alternatives considered

- **Independent versioning per artifact** (Library v1.x, Monitoring v2.x, Bicep v3.x) — rejected;
  customer mental overhead is high, support questions get harder, and the Library coupling
  rule already forces near-lockstep movement anyway.
- **CalVer** (e.g. `2026.05.0`) — rejected; SemVer's breaking-change signaling is too valuable
  for an MP that has a sealed-version contract with override packs.
- **No release-please, manual tag** — rejected; manual tagging led to the gap that motivated
  this ADR. Automation prevents drift.
- **LTS branches** — rejected pre-1.0; revisit after 1.0 if customer demand emerges.
- **Skip the deprecation policy** — rejected; without an overlap window, removing a class or
  parameter silently breaks customer override packs.

## References

- ADR 0007 — Naming convention (sealed-MP 3-pack model + Library reference rule)
- ADR 0014 — CI/CD pipeline (release-please workflow lives here)
- ADR 0015 — Testing strategy (Layer 4 parity test must hold across version bumps)
- ADR 0016 — Signing & secrets (release-key contract pairs with Library coupling rule)
- [SemVer 2.0](https://semver.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [release-please](https://github.com/googleapis/release-please)
- [mike — versioned MkDocs](https://github.com/jimporter/mike)
- Brian Wren — sealed MP version contract (SC2012 Authoring Guide §5)
