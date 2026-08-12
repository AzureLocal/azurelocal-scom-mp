# Contributing to azurelocal-scom-mp

Please read the [AzureLocal Contributing Guide](https://github.com/AzureLocal/.github/blob/main/CONTRIBUTING.md) first — it covers branching, PR workflow, Conventional Commits, and the IIC example-data rule that apply to all AzureLocal repositories.

## Repo-specific notes

### Management Pack authoring

- Azure Local class, relationship, monitor, rule, and view names follow the `AzureLocal.*`
  namespace defined in [ADR 0005](docs/design/decisions/0005-scom-class-hierarchy.md).
- The current Azure Local baseline uses three MP files:
  - `AzureLocal.SCOM.Library.mp` — class and relationship definitions
  - `AzureLocal.SCOM.Monitoring.mp` — monitors, rules, discoveries
  - `AzureLocal.SCOM.Override.xml` — sealed-MP overrides
- Never edit `AzureLocal.SCOM.Override.xml` directly for new logic — overrides only.
- Do not create shared Hyper-V/Azure Local sealed dependencies until proposed
  [ADR 0022](docs/design/decisions/0022-scom-management-pack-packaging-boundaries.md) is accepted.
- Keep Hyper-V classes, discoveries, and signals platform-specific unless the accepted ADR assigns
  them to a shared library and defines their namespace.

### Testing

Follow the five-layer test pyramid in [ADR 0015](docs/design/decisions/0015-testing-strategy.md). New monitors and discoveries must include at least a unit test (Layer 1) before the PR will pass CI.

### Signing

Do not commit MP signing keys or certificates. See [ADR 0016](docs/design/decisions/0016-signing-and-secrets.md) for the two-key signing model and how CI handles signing via OIDC.

### Versioning

All user-facing changes require a `CHANGELOG.md` entry under `[Unreleased]` and a Conventional Commit message so release-please can generate the next version automatically (see [ADR 0017](docs/design/decisions/0017-versioning-and-release.md)).

### Documentation

Documentation lives under `docs/` and is built with VitePress. Preview it before pushing:

```powershell
Set-Location docs
npm ci
npm run docs:dev
```

Run `npm run docs:build` to perform the same production build used by GitHub Pages. Keep navigation
in `docs/.vitepress/config.mts` synchronized with the Markdown pages, and use VitePress custom
containers (`::: info`, `::: tip`, and `::: warning`) for callouts.
