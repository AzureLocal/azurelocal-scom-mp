# Decisions

- The repository uses VitePress, not MkDocs. This is an explicit repository-owner direction and is
  recorded in ADR 0020, which supersedes the MkDocs and `mike` portions of ADRs 0014 and 0017.
- Site branding uses `docs/public/assets/images/azurelocal-scom-mp-icon.svg` for the navigation logo
  and favicon, and `azurelocal-scom-mp-banner.svg` for the home-page hero.
- Mermaid fences are rendered by the local VitePress theme component. The third-party wrapper was
  removed after its browser runtime showed syntax-error placeholders for valid diagrams.
