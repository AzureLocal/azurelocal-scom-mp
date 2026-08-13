# Handoff

<!--
  Written at the END of every session by whichever tool was used.
  This is the single most important cross-tool file — the next session
  (possibly a different tool) starts by reading it.
-->

## Last session

- **What changed and why:** Expanded the Hyper-V SCOM design from a high-level research gate into a
  comprehensive proposed Management Pack and Distributed Application architecture. The design is
  implementation-grade but explicitly remains evidence-gated; it does not authorize MP XML
  authoring before AB#7327/AB#7359 and proposed ADRs 0027–0029 are resolved.
- **Architecture documents:** Added end-to-end architecture, MP structure, class/relationship model,
  discovery/workflow architecture, health/alert architecture, authoring standards, security and
  operability, and validation/release pages. Rebuilt the Hyper-V DA page with cluster and standalone
  service models, stable-boundary rules, membership reconciliation, topology-aware rollup, operator
  surfaces, and acceptance gates.
- **Diagrams:** Added 47 Mermaid diagrams rendered by the repository's Vue component. They cover
  component, dependency, class, sequence, state, discovery, decision, health, security, scale,
  lifecycle, and release flows. Browser validation rendered all 47 SVGs across ten design pages
  with zero Mermaid errors, zero loading placeholders, and zero console errors.
- **Proposed decisions:** Added ADR 0027 for modular sealed Library/Discovery/Monitoring/Presentation
  and optional Reporting MPs plus customer Overrides; ADR 0028 for stable object identity, VM
  mobility, staged discovery, execution placement, and cookdown; and ADR 0029 for evidence-driven
  health, alerts, monitoring freshness, and topology-aware DA rollup. All remain Proposed.
- **Microsoft best practices:** Grounded the design in current Microsoft SCOM guidance for MP
  contents, logical MP separation, sealed versus writable override MPs, override targeting,
  Run As profiles and more-secure credential distribution, pre-production lifecycle validation,
  Distributed Applications, SLOs, knowledge, and import/removal dependencies. Detailed legacy and
  community authoring patterns remain research inputs that require current-version validation.
- **Azure DevOps:** Created Task AB#7359, `Validate comprehensive Hyper-V SCOM MP and DA
  architecture`, in the Hyper-V area and parented it to AB#7327. Added architecture comments to
  AB#7327, AB#7350, AB#7356, and AB#7357. Roadmap and plan now include AB#7359. Added the accepted
  source-tree implementation note to packaging Story AB#7319.
- **Source structure:** Replaced the obsolete solution-first `src/scom-mp`, `src/azure-monitor`, and
  `src/squaredup` roots with `src/azure-local/{scom-mp,azure-monitor}` and
  `src/hyper-v/{scom-mp,azure-monitor}`. Added source-root contracts and solution placeholders,
  nested optional SquaredUp artifacts under their owners, and kept Hyper-V Azure Monitor reserved
  with no deployable files. Accepted ADR 0030 is the current source-path authority and supersedes
  obsolete path examples in immutable ADRs 0008 and 0013–0015.
- **Navigation and project state:** Updated VitePress navigation, Hyper-V design/product pages, ADR
  index, roadmap, research flow, plan, changelog, source register, and `.ai/` memory/state files.
- **Validation:** Repository-configured markdownlint passed the architecture set and the subsequent
  17 source-layout Markdown files with zero issues. VitePress 1.6.4 production builds passed,
  including internal-link validation and sitemap generation; only the existing large-chunk advisory
  remains. Browser validation returned HTTP 200 for all ten live Hyper-V design routes and rendered
  47/47 diagrams. Source-layout assertions found all four required roots, zero legacy roots, and no
  deployable files in conditional Hyper-V Azure Monitor. `git diff --check` passed and the
  changed-file secret scan found zero suspicious matches. Governance validation could not invoke
  globally installed markdownlint or lychee because they are unavailable; the repository lint,
  VitePress link/build checks, and browser checks ran instead.
- **Branch:** `main`.
- **Next steps:** Execute AB#7343–AB#7353, continuously trace findings into AB#7359, refine the
  proposed identifiers and contracts, and accept/revise/replace ADRs 0027–0029 before starting
  Stories AB#7328 or AB#7329. In particular, resolve exact supported SCOM/Windows/SCVMM versions,
  Microsoft library versions, class keys/base classes, workflow execution runtime, scale budgets,
  thresholds, expected VM state, and DA percentage/redundancy rollups.
- **Unrelated cleanup:** The superseded clone at `D:/git/azurelocal/azurelocal-scom-mp` remains until
  the prior Windows working-directory handle is released.
