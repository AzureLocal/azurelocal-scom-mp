# Contributing to Hybrid Infrastructure Health Monitoring

Follow the [HCS governance standards](https://platform.hybridsolutions.cloud/standards/) for
branching, pull requests, Conventional Commits, documentation, and the IIC example-data rule.
Azure Local-specific contributions must also preserve the conventions established by the accepted
Azure Local ADRs in this repository.

## Repo-specific notes

### Source ownership

- Start in the platform root: `src/azure-local/` or `src/hyper-v/`.
- Then select the solution root: `scom-mp/` or `azure-monitor/`.
- Do not add runtime product source directly under `src/` or create shared platform runtime folders.
- Keep optional SquaredUp content below the solution it visualizes.
- The reserved `src/hyper-v/azure-monitor/` root accepts no deployable implementation until ADR
  0023 records a go decision.
- See [ADR 0030](docs/design/decisions/0030-platform-first-source-tree.md) and
  [the source-tree contract](src/README.md).

### Management Pack authoring

- Azure Local class, relationship, monitor, rule, and view names follow the `AzureLocal.*`
  namespace defined in [ADR 0005](docs/design/decisions/0005-scom-class-hierarchy.md).
- The current Azure Local baseline uses three MP files:
  - `AzureLocal.SCOM.Library.mp` — class and relationship definitions
  - `AzureLocal.SCOM.Monitoring.mp` — monitors, rules, discoveries
  - `AzureLocal.SCOM.Override.xml` — sealed-MP overrides
- Never edit `AzureLocal.SCOM.Override.xml` directly for new logic — overrides only.
- Never create shared Hyper-V/Azure Local sealed dependencies, base classes, namespaces, packages,
  or Distributed Applications. Accepted
  [ADR 0022](docs/design/decisions/0022-scom-management-pack-packaging-boundaries.md) requires
  independent runtime products.
- Research, authoring knowledge, non-runtime templates, build automation, and validation methods may
  be reused without creating a cross-product MP reference.

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
