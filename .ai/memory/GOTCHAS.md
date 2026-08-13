# Gotchas

- VitePress assets in `docs/public/` are referenced from Markdown and theme configuration as
  `/assets/...`; VitePress adds the configured repository base path at runtime.
- The generated site and cache are under `docs/.vitepress/dist/` and `docs/.vitepress/cache/` and
  must remain untracked.
- `npm audit` currently reports three transitive development-tool vulnerabilities (two moderate,
  one high) with no stable VitePress upgrade available that removes all of them.
- Do not reintroduce `vitepress-plugin-mermaid`; its renderer produced visible syntax-error panels
  for valid diagrams in this site. Use the local `MermaidDiagram.vue` integration.
- Azure Arc-enabled SCVMM inventory projection is not the same as Azure Arc-enabled Servers guest
  management. Do not assume inventory resources have Azure Monitor Agent telemetry without proving
  the guest-management, agent, Data Collection Rule, identity, and networking path.
- Do not generalize accepted Azure Local ADRs 0001–0020 to Hyper-V. Hyper-V topology and signals
  require their own research-backed successor ADRs.
- Microsoft ships an older Hyper-V 2019 Management Pack. Use it to research useful concepts in
  AB#7349, but never make it an import, extension, override target, prerequisite, or runtime
  dependency of this product.
- Do not create a shared Azure Local/Hyper-V sealed library, base class, namespace, Distributed
  Application, package, or runtime MP reference. ADR 0022 requires independent products; only
  research and non-runtime engineering practices may be reused.
- An exhaustive counter/event/property inventory is intentionally larger than the shipped default
  profile. Keep rejected and collection-only candidates traceable instead of silently deleting them.
