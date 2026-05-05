# Contributing to azurelocal-scom-mp

Please read the [AzureLocal Contributing Guide](https://github.com/AzureLocal/.github/blob/main/CONTRIBUTING.md) first — it covers branching, PR workflow, Conventional Commits, and the IIC example-data rule that apply to all AzureLocal repositories.

## Repo-specific notes

### Management Pack authoring

- All class, relationship, monitor, rule, and view names must follow the `AzureLocal.*` namespace defined in [ADR 0005](docs/design/decisions/0005-scom-class-hierarchy.md).
- The source is split across three MP files per [ADR 0007](docs/design/decisions/0007-mp-file-split.md):
  - `AzureLocal.SCOM.Library.mp` — class and relationship definitions
  - `AzureLocal.SCOM.Monitoring.mp` — monitors, rules, discoveries
  - `AzureLocal.SCOM.Override.xml` — sealed-MP overrides
- Never edit `AzureLocal.SCOM.Override.xml` directly for new logic — overrides only.

### Testing

Follow the five-layer test pyramid in [ADR 0015](docs/design/decisions/0015-testing-strategy.md). New monitors and discoveries must include at least a unit test (Layer 1) before the PR will pass CI.

### Signing

Do not commit MP signing keys or certificates. See [ADR 0016](docs/design/decisions/0016-signing-and-secrets.md) for the two-key signing model and how CI handles signing via OIDC.

### Versioning

All user-facing changes require a `CHANGELOG.md` entry under `[Unreleased]` and a Conventional Commit message so release-please can generate the next version automatically (see [ADR 0017](docs/design/decisions/0017-versioning-and-release.md)).

### Docs

Documentation lives under `docs/` and is built with MkDocs Material. Run `mkdocs serve` locally to preview before pushing. The CI build runs with `strict: true` — broken links will fail the workflow.
