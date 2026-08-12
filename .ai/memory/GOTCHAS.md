# Gotchas

- VitePress assets in `docs/public/` are referenced from Markdown and theme configuration as
  `/assets/...`; VitePress adds the configured repository base path at runtime.
- The generated site and cache are under `docs/.vitepress/dist/` and `docs/.vitepress/cache/` and
  must remain untracked.
- `npm audit` currently reports three transitive development-tool vulnerabilities (two moderate,
  one high) with no stable VitePress upgrade available that removes all of them.
- Do not reintroduce `vitepress-plugin-mermaid`; its renderer produced visible syntax-error panels
  for valid diagrams in this site. Use the local `MermaidDiagram.vue` integration.
