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
  authoring before the research program and proposed ADRs 0027–0029 are resolved.
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
- **Delivery tracking:** Added architecture validation, packaging, workflow, DA, and source-layout
  updates to the applicable internal delivery work without publishing board identifiers.
- **Source structure:** Replaced the obsolete solution-first `src/scom-mp`, `src/azure-monitor`, and
  `src/squaredup` roots with `src/azure-local/{scom-mp,azure-monitor}` and
  `src/hyper-v/{scom-mp,azure-monitor}`. Added source-root contracts and solution placeholders,
  nested optional SquaredUp artifacts under their owners, and kept Hyper-V Azure Monitor reserved
  with no deployable files. Accepted ADR 0030 is the current source-path authority and supersedes
  obsolete path examples in immutable ADRs 0008 and 0013–0015.
- **Navigation and project state:** Updated VitePress navigation, Hyper-V design/product pages, ADR
  index, roadmap, research flow, plan, changelog, source register, and `.ai/` memory/state files.
- **Solution navigation and privacy:** Split the Design and platform sidebars into four explicit
  solution groups: Azure Local SCOM, Azure Local Azure Monitor, Hyper-V SCOM, and conditional
  Hyper-V Azure Monitor. Exposed SquaredUp Dashboard Server under each SCOM solution and SquaredUp
  Cloud under each Azure Monitor solution, adding the missing Hyper-V placeholder pages. Renamed
  Migration to on-premises SCOM-to-Azure-Monitor monitoring migration and clarified that it is not
  workload migration. Removed work-item identifiers and direct board links from all tracked source
  and documentation files so the public site and repository do not expose internal tracking IDs.
- **ServiceNow roadmap:** Added an Integrations section and a public ServiceNow roadmap covering
  ServiceNow SCOM Events/Metrics connectors, Azure Monitor Secure Webhook and optional Logic Apps,
  dual-source authority, CMDB/CI mapping, lifecycle, security, reliability, proof-of-concept gates,
  and solution-owned deliverables. It is Later work and does not displace committed monitoring.
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
- **Next steps:** Execute the research program, trace findings into architecture validation, refine
  the proposed identifiers and contracts, and accept/revise/replace ADRs 0027–0029 before starting
  authoring. In particular, resolve exact supported SCOM/Windows/SCVMM versions,
  Microsoft library versions, class keys/base classes, workflow execution runtime, scale budgets,
  thresholds, expected VM state, and DA percentage/redundancy rollups.
- **Unrelated cleanup:** The superseded clone at `D:/git/azurelocal/azurelocal-scom-mp` remains until
  the prior Windows working-directory handle is released.
