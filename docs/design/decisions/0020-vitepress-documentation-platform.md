# ADR 0020 — VitePress documentation platform

- **Status**: Accepted
- **Date**: 2026-08-12
- **Decider**: @kturner
- **Supersedes**: The MkDocs and `mike` documentation portions of ADR 0014 and ADR 0017

## Context

The documentation site was originally implemented with MkDocs Material. A July 2026 federation
change introduced a partial VitePress migration: the GitHub Pages workflow and a generated
VitePress configuration existed, but the repository still contained MkDocs-specific syntax,
commands, platform descriptions, and versioning decisions. Mermaid rendering, a deterministic
dependency lock, and complete branding metadata were also absent.

## Decision

Use VitePress as this repository's documentation generator, by explicit repository-owner
direction. The implementation has these requirements:

- `docs/.vitepress/config.mts` is the navigation and theme source of truth.
- `docs/package.json` and `docs/package-lock.json` define a reproducible Node.js build.
- `vitepress-plugin-mermaid` renders the existing Mermaid diagrams.
- VitePress custom containers provide information, tip, and warning callouts.
- The existing Azure Local banner remains the home-page hero artwork.
- The existing Azure Local icon is both the navigation logo and browser-tab favicon.
- GitHub Pages deploys `docs/.vitepress/dist` after `npm ci` and `npm run docs:build`.
- VitePress local search is enabled.
- The current site publishes one continuously updated version. Static version snapshots may be
  added later if released Management Packs require version-matched documentation.

The product artifact versioning rules in ADR 0017 are unchanged. Only its MkDocs and `mike`
documentation mechanism is superseded.

## Consequences

- Documentation has one JavaScript-based toolchain for local preview and production builds.
- Existing Markdown remains portable, while callouts and home-page metadata use VitePress syntax.
- Mermaid adds a client-side dependency but preserves the existing diagrams without exporting
  them as static images.
- The site no longer depends on Python, MkDocs plugins, or a `gh-pages` branch managed by `mike`.
- A future version selector requires a separate VitePress versioning design.

## Alternatives considered

- **Finish the MkDocs site** — rejected by repository-owner direction to adopt VitePress.
- **Keep both toolchains** — rejected because two sources of navigation and syntax would drift.
- **Convert to Docusaurus** — rejected because a partial VitePress deployment was already present
  and the existing Markdown requires less conversion with VitePress.

## References

- [VitePress site configuration](https://vitepress.dev/reference/site-config)
- [VitePress default theme configuration](https://vitepress.dev/reference/default-theme-config)
- [VitePress Mermaid plugin](https://github.com/emersonbottero/vitepress-plugin-mermaid)
- ADR 0014 — CI/CD pipeline strategy
- ADR 0017 — Versioning and release policy
