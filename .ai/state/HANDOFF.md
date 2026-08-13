# Handoff

<!--
  Written at the END of every session by whichever tool was used.
  This is the single most important cross-tool file — the next session
  (possibly a different tool) starts by reading it.
-->

## Last session

- **What changed:** Defined the Hyper-V customization and tuning contract as two separate unsealed,
  customer-owned MPs: Discovery Overrides and Monitoring Overrides. Added public Lab, Standard, and
  Strict starter-template contracts, an operator administration guide, and explicit safeguards that
  prohibit storing product overrides in the Default Management Pack.
- **Architecture:** Updated the sealed MP decomposition, health/alert design, authoring standards,
  validation/release design, roadmap, plan, navigation, and proposed ADR 0027. Added the dedicated
  override-and-tuning architecture page and proposed ADR 0031 for the MP authoring toolchain.
- **Authoring decision:** Canonical source is tool-neutral XML/templates built by PowerShell 7.
  Microsoft SDK schema verification, MPVerify, test sealing, release signing/sealing, and SCOM lab
  import remain authoritative release gates. Silect tools may assist authoring but are not the
  source of truth or a runtime dependency.
- **Build foundation:** Added manifest-only development templates for the Hyper-V Library,
  Discovery, Monitoring, Presentation, and optional Reporting MPs. Added a deterministic build
  manifest, PowerShell 7 build/contract scripts, three evidence-gated tuning-profile manifests,
  and six deliberately non-importable override examples. No production classes, discoveries,
  monitors, rules, DAs, or signing material were invented ahead of the open research decisions.
- **Tests and CI:** Added Pester unit tests plus integration/scenario test plans. The Pages workflow
  now runs the MP contract suite before deployment. Local validation passed: five development XML
  outputs, six override examples, three tuning manifests, three Pester tests, zero
  PSScriptAnalyzer warnings/errors, VitePress production build, repository markdownlint,
  `git diff --check`, zero public work-item references, and zero high-confidence secret findings.
- **Known validation gap:** The in-app browser was unavailable and installed Chrome/Edge instances
  would not create an isolated headless session, so the new pages did not receive a fresh rendered
  SVG/browser assertion this session. The VitePress production build and route generation passed.
- **Build environment:** The governed Windows build VM could not be reached over WinRM during a
  bounded attempt and was returned to the powered-off state. Microsoft SDK verification, MPVerify,
  sealing/signing, and SCOM lab import therefore remain incomplete. The generated XML inventory
  reports `releaseReady=false`, `sealed=false`, `signed=false`, and `labImported=false`.
- **Privacy:** Public repository and generated-site scans contain no Azure Boards identifiers or
  direct work-item links. Internal tracking is updated only through the private board.
- **Branch:** `main`.
- **Next steps:** Resolve the supported-product matrix, Microsoft reference-library versions, exact
  class keys/base classes, workflow runtime and execution placement, discovery evidence,
  thresholds, expected VM state, DA rollup semantics, scale budgets, and the governed Windows
  authoring environment. Then implement and lab-validate Library classes/relationships first,
  followed by Discovery, Monitoring, Presentation/DA, and optional Reporting workflows.
