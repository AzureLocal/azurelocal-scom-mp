# Handoff

<!--
  Written at the END of every session by whichever tool was used.
  This is the single most important cross-tool file — the next session
  (possibly a different tool) starts by reading it.
-->

## Last session

- **What changed and why:** Split the project into Azure Local and Hyper-V platform tracks under the
  public title "Hybrid infrastructure health monitoring." Azure Local has committed SCOM and Azure
  Monitor surfaces. Hyper-V has a committed SCOM surface and a conditional Azure Monitor surface
  through Arc-enabled SCVMM. Updated the site information architecture, home page, banner, roadmap,
  implementation plan, shared design framing, contributor guidance, and durable memory. Added
  accepted ADR 0021 plus proposed ADRs 0022–0023 and a research-spike evidence contract.
- **Azure DevOps:** Created area paths `Azure Local` and `Hyper-V`; Epics AB#7313 and AB#7314;
  Features AB#7315–AB#7318; and child Stories AB#7319–AB#7334 with parent, predecessor, priority,
  tags, descriptions, and acceptance criteria. Updated the project description to the new public
  product scope. Hyper-V Azure Monitor remains Priority 4 / `future-roadmap` and cannot activate
  before its research and go/no-go ADR.
- **Files touched:** `README.md`, `PLAN.md`, `CHANGELOG.md`, `CONTRIBUTING.md`, VitePress config and
  banner assets, platform entry pages under `docs/azure-local/` and `docs/hyper-v/`, roadmap/about,
  shared design pages, ADR index and ADRs 0021–0023, research spikes, and `.ai/` state/memory.
  Product implementation directories remain untouched pending ADR 0022.
- **Commands / tests run and results:** HCS Governance bootstrap; current Microsoft Learn research
  for Arc-enabled SCVMM, Arc-enabled Servers, Azure Monitor Agent, and Health Models; `npm run
  docs:build` passed; markdownlint passed on all 29 changed Markdown files; `git diff --check`
  passed; secret-pattern scan passed; ADO hierarchy audit passed; representative local VitePress
  routes returned HTTP 200; visual browser review passed for home branding, Hyper-V, and research
  content. Governance validation could not run `lychee` because it is not installed; VitePress
  internal-link validation passed during the production build.
- **Branch:** `main`; publish commit and GitHub Pages deployment verified before session end.
- **Blockers:** None for the planning/documentation split. Product authoring is deliberately gated.
- **Exact next steps:** Run AB#7319 (SCOM packaging), AB#7327 (Hyper-V topology/signals/support), and
  AB#7323 (Azure Local Health Models revalidation). Run AB#7331 then AB#7332 before resolving ADR
  0023. Do not activate Hyper-V Azure Monitor implementation unless ADR 0023 records a go decision.
