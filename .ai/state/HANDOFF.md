# Handoff

## Current session

- **Public-site reconciliation:** Updated the landing/status pages, both SCOM product and design
  lanes, validation pages, roadmap, administration guides, source READMEs, current ADR notes, and
  the Azure Local package diagram to record completed OM2022 VSAE verification and transient test
  sealing. Standalone MPVerify is no longer represented as an additional release gate.
- **ServiceNow clarification:** Audited the existing integration source and public docs. ServiceNow
  supplies the SCOM Events connector; the repository already supplies separate Azure Local and
  Hyper-V profiles, the normalized AlertId mapping/lifecycle contract, offline validation, ADR, and
  operator guidance. No custom connector or automated ServiceNow mutation exists or is needed for
  the first lab. Live Windows MID Server configuration and certification remain next; Azure Monitor
  Secure Webhook/common-alert-schema artifacts remain future implementation.
- **Microsoft verification unlocked:** Located the installed VSAE 1.10.571.0 OM2022 dependency
  set and Visual Studio 2022 full-framework MSBuild. Replaced both PowerShell 7 in-process SDK
  loaders with a shared VSAE `VerifyMergedManagementPack` MSBuild project and product wrappers.
- **Verified defect fixed:** Microsoft verification proved that
  `Microsoft.SystemCenter.ServiceDesigner.Component` does not exist in the OM2022 Service Designer
  library. Changed all five Hyper-V and six Azure Local DA component classes to the verified
  `Microsoft.SystemCenter.ServiceDesigner.ServiceComponentGroup` base and added regression checks.
- **SDK and test-seal result:** The complete Hyper-V and Azure Local suites—Library, Discovery,
  Monitoring, Presentation, and optional Reporting—pass Microsoft VSAE/SDK verification against
  the installed OM2022 sealed dependencies. Both five-MP chains then test-sealed successfully in
  dependency order with a transient development key stored only under `D:/tmp/`.
- **Additional verified fixes:** Renamed discovery-script `$data` and helper `$Target` variables so
  they cannot collide with SCOM expression namespaces, split malformed MAML into sibling sections,
  and made all three-state monitor health mappings unique. Added regression assertions.
- **Sealing runtime:** VSAE `FASTSEAL.exe` targets CLR v2.0.50727. `NET-Framework-Core` initially
  reported `Removed`, then completed installation through Server Manager and now reports
  `Installed`. **No restart was performed, and the operator explicitly prohibited restarting this
  server.**
- **Latest validation:** Both complete five-MP VSAE/SDK wrappers passed; all ten transient artifacts
  test-sealed and passed strong-name verification; Pester 15/15; PSScriptAnalyzer zero warnings or
  errors; VitePress production build and `git diff --check` passed; public ADO identifier scan
  returned zero matches. VitePress emitted only its existing large-chunk warning.
- **Outcome:** Implemented the Azure Local SCOM development baseline, both independent Azure
  Monitor Health Model baselines, and the optional SCOM-to-ServiceNow development contract. Updated
  research, ADRs, architecture, operator guidance, navigation, roadmap, source READMEs, changelog,
  and private delivery tracking.
- **Azure Local SCOM:** Added five package sources (Library, Discovery, Monitoring, Presentation,
  optional Reporting), 17 classes, 28 relationships, staged local topology discovery, a
  platform-owned Distributed Application with six health components, 14 unit monitors, six
  aggregate monitors, 12 dependency rollups, 11 curated monitor alerts, 12 performance rules, four
  event rules, a diagnostic task, operational knowledge, and 14 views.
- **Overrides:** Added separate customer-owned Discovery and Monitoring override generators plus
  Lab, Standard, and Strict starter profiles. The Default Management Pack remains prohibited.
- **Azure Local Azure Monitor:** Added an independent monitor account/Health Model Bicep baseline,
  deployment and six domain entities, separate compute/storage Azure-resource entities, documented
  Azure Local CPU and storage-degraded signals, deployment state alerts, KQL research queries, and
  a workbook. Unproven domains remain Unknown.
- **Hyper-V Azure Monitor:** Accepted the constrained go decision and added an independent Bicep
  baseline. Arc-enabled SCVMM supplies inventory; Arc-enabled Server plus AMA/DCR supplies host
  heartbeat, hypervisor CPU, cluster-event, and telemetry-coverage signals. Explicit DCR
  associations and complete fabric parity remain lab work.
- **ServiceNow:** Accepted the connector-boundary ADR and added separate Azure Local and Hyper-V
  connector profiles, a normalized AlertId-based mapping, an offline compatibility validator, and
  public setup/lifecycle/security guidance. Live MID Server and ServiceNow validation remains.
- **Architecture:** Accepted ADRs 0032–0038 and promoted ADR 0023 to the constrained Hyper-V Azure
  Monitor implementation decision. Added four Azure Local SCOM draw.io diagrams with public SVG
  exports and repaired three previously committed draw.io files that had obsolete stub XML appended.
- **Private tracking:** Updated all existing Azure Local and Hyper-V SCOM/Azure Monitor delivery
  items with exact baseline and remaining-gate status. Added a separate integrations Epic, a
  SCOM-to-ServiceNow Feature, and research, architecture, implementation, and lab-validation
  Stories. No internal identifiers or board links appear in public repository content.
- **Validation passed:** Azure Local and Hyper-V MP contracts; Azure Local and Hyper-V Azure Monitor
  Bicep/contract checks; SCOM-to-ServiceNow contract; Pester 15/15; product PSScriptAnalyzer zero
  warnings/errors; gitleaks zero findings; 20 JSON files parsed; seven draw.io files parsed; local
  Markdown links passed; changed-file structural Markdown lint passed; VitePress production build;
  `git diff --check`; public work-item scan zero. VitePress reports only its existing large-chunk
  warning.
- **Governance:** Registry resolves this as the HCS `docs` profile. The governance server could not
  inspect the Windows path for drift and its optional markdown/link binaries are not installed;
  equivalent local checks were run directly.
- **Release gates:** Both complete suites are SDK dependency-resolved and transiently test-sealed
  against OM2022, but no test output is a public release artifact. Governed release signing and
  SCOM-lab certification remain; standalone MPVerify is not a separate gate.
  Neither Azure Monitor baseline has been deployed to a representative subscription. ServiceNow
  MID Server behavior and the supported SCOM version pair are not lab-certified.
- **Branch:** `main`.
- **Latest documentation validation:** VitePress production build passed, the ServiceNow contract
  validator passed, Pester passed 15/15, PSScriptAnalyzer returned zero warnings/errors, edited
  draw.io/SVG XML parsed, gitleaks reported zero findings, the public work-item identifier scan
  returned zero matches, and `git diff --check` passed. Governance MCP could not access the local
  Windows path; its optional markdownlint/lychee executables are also not installed server-side.
- **Next action:** Do not restart this server. Import the transiently test-sealed products into the
  operator-provided SCOM labs in dependency order and execute the documented SCOM and ServiceNow
  matrices. Establish the governed release-signing identity only after the lab evidence is
  approved. Azure Monitor live deployment remains a separate lab workstream.

## Last session

- **Outcome:** Authored the functional Hyper-V SCOM development baseline and reconciled public
  design, roadmap, product, catalog, administration, ADR, source README, changelog, and AI state.
- **Library:** 13 localized public classes, 70 localized properties, and 20 localized relationships.
  The model has a stable cluster-or-host boundary, non-hosted mobile VM identity, hosted host-local
  objects, a Service Designer DA root, and five component classes.
- **Discovery and DA:** Added registry role seed plus staged PowerShell topology discovery for
  Hyper-V, Failover Clustering, CSV, virtual switches, Network ATC, Replica facts, monitoring
  pipeline, DA roots/components, and 20 membership/reference relationships.
- **Monitoring:** Added one shared cookdown data source, nine three-state host monitors, auto-resolve
  alerts, 10 DA dependency rollups, 12 performance rules, four Failover Clustering event-alert
  rules, 13 operational-knowledge articles, and one read-only diagnostic task. Five
  high-cardinality/topology-sensitive performance rules are disabled by default.
- **Presentation:** Added four folders and 10 localized service-health, inventory, alert,
  performance, and event views. DA roots derive from the Service Designer service class and roll up
  through Compute, Virtual Machines, Storage, Network, and Monitoring Pipeline components.
- **Overrides:** Added generator-backed Lab, Standard, and Strict profiles. Each invocation creates
  separate unsealed, customer-owned Discovery and Monitoring override MPs. The Default Management
  Pack remains prohibited.
- **Build and validation:** Added deterministic element localization, structural product contracts,
  and a Microsoft SDK verification command that requires official target-version dependency MPs
  and fails on missing dependencies or verification errors.
- **Architecture:** Accepted ADRs 0027–0029 and 0031. Release-specific dependency versions,
  test/release sealing, signing identity, and lab certification remain release gates, not unbuilt
  source work.
- **Private tracking:** Updated the architecture, classes/discovery, monitoring/overrides, DA
  membership, DA rollup, and release-validation items with exact status and remaining gates. No
  internal work-item identifiers or links appear in public repository content.
- **Validation passed:** Hyper-V MP contract suite; Pester 8/8; PSScriptAnalyzer zero
  warnings/errors; VitePress production build; changed-file Markdown lint with VitePress-compatible
  line/H1 exclusions; `git diff --check`; public work-item scan zero; high-confidence secret scan
  zero. The VitePress build reports only its existing large-chunk warning.
- **External gate:** The Microsoft SDK assembly is installed, but official sealed System, Windows,
  Service Designer, Health, Performance, System Center, and Data Warehouse dependency MPs are not
  locally available. Full SDK verification therefore cannot truthfully pass yet. Test sealing,
  representative standalone/cluster SCOM lab import, topology lifecycle, fault/recovery,
  maintenance, failover, scale, upgrade/removal, release sealing/signing, and optional Reporting,
  SLO, and SquaredUp certification remain.
- **Branch:** `main`.
- **Next action:** Export the official dependency MPs from each target SCOM management group, run
  `Test-HyperVManagementPacksWithSdk.ps1`, correct any verified schema/dependency findings, then
  test-seal and execute the documented standalone and cluster lab matrix.
