# Decisions

- The repository uses VitePress, not MkDocs. This is an explicit repository-owner direction and is
  recorded in ADR 0020, which supersedes the MkDocs and `mike` portions of ADRs 0014 and 0017.
- Site branding uses `docs/public/assets/images/azurelocal-scom-mp-icon.svg` for the navigation logo
  and favicon, and `azurelocal-scom-mp-banner.svg` for the home-page hero.
- Mermaid fences are rendered by the local VitePress theme component. The third-party wrapper was
  removed after its browser runtime showed syntax-error placeholders for valid diagrams.
- The public product title is "Hybrid infrastructure health monitoring" with the subtitle "SCOM
  and Azure Monitor health models for Hyper-V and Azure Local."
- The repository identity is `Hybrid-Solutions-Cloud/hybrid-health-monitoring`; the canonical site
  is `https://labs.hybridsolutions.cloud/hybrid-health-monitoring/`. ADR 0024 records the migration.
- Planning is platform-first: Azure Local and Hyper-V each have an Azure DevOps Epic, with SCOM and
  Azure Monitor represented as child Features.
- Documentation design follows the same platform-first, delivery-surface-second hierarchy. Shared
  design is intentionally narrow, and accepted Azure Local ADRs are not inherited by Hyper-V
  without research and an explicit successor decision.
- Azure Local SCOM and Azure Monitor plus Hyper-V SCOM are committed delivery surfaces. Hyper-V
  Azure Monitor is an accepted constrained development track: Arc-enabled SCVMM supplies inventory,
  while Arc-enabled Server plus AMA and DCRs supply host telemetry. Unsupported fabric domains must
  remain Unknown instead of receiving inferred health.
- Azure Local and Hyper-V are completely independent SCOM runtime products. Accepted ADR 0022
  prohibits shared sealed libraries, classes, namespaces, Distributed Applications, packages,
  versions, or cross-product MP dependencies. Research and non-runtime engineering practices may
  be reused.
- Each SCOM product must ship its own platform-owned Distributed Application. ADR 0026 requires an
  Azure Local deployment DA and separate Hyper-V cluster/standalone-host DAs with dynamic
  membership, tested rollup, operator views, reports, dashboards, and SLO targeting.
- Hyper-V SCOM research preserves a complete raw capability inventory separately from the curated
  default monitoring catalog. Technically collectable does not mean enabled or health-impacting.
- A 75% host-memory-used threshold is not accepted as a standalone default. Default memory health
  must consider available/reserved memory, Hyper-V pressure, paging, duration, recovery, topology,
  source evidence, and lab results.
- Network ATC is not Azure Local-only. It is the preferred host-networking baseline for eligible
  Windows Server 2025 Datacenter Hyper-V failover clusters unless SCVMM/SDN is the selected network
  authority. Hyper-V research and MP coverage must also include manual/legacy networking. Accepted
  ADR 0025 supersedes only the incorrect Network ATC implication in accepted ADR 0021.
- The Microsoft Hyper-V 2019 Management Pack is a research input only. The new Hyper-V MP will not
  import, extend, override, require, or take a runtime dependency on it. Useful concepts must be
  revalidated and implemented independently in this project's namespaces and workflows.
- The comprehensive Hyper-V SCOM architecture and ADRs 0027–0029 are accepted and implemented as a
  functional development baseline: Library, Discovery, Monitoring, Presentation, optional
  Reporting, and customer-owned override generation; stable boundary identity and mobile VM
  identity; staged discovery and cookdown; evidence-driven health, alerts, pipeline health, and
  topology-aware DA rollup. VSAE/SDK verification and transient test sealing pass against the
  installed SCOM 2022 dependencies; governed release signing and SCOM lab evidence remain gates.
- Hyper-V customer customization uses two unsealed, customer-owned MPs: Discovery Overrides for the
  sealed Discovery MP and Monitoring Overrides for the sealed Monitoring MP. Optional Lab,
  Standard, and Strict profiles are public starter examples only; they are reviewed and copied into
  customer-owned files, never imported automatically. The Default Management Pack is prohibited.
- Accepted ADR 0031 makes tool-neutral XML/templates and PowerShell 7 the canonical Hyper-V MP
  source/build path. Microsoft verification runs through VSAE `VerifyMergedManagementPack`;
  standalone MPVerify is not a separate gate. Governed release sealing/signing and SCOM lab import
  remain authoritative release gates; Silect authoring tools are optional aids rather than
  source-of-truth or runtime dependencies.
- Accepted ADRs 0032–0035 define the Azure Local SCOM local-runtime boundary, five-artifact package
  decomposition, staged object discovery and platform-owned Distributed Application, and
  evidence-driven health/alert/rollup policy. The development baseline is implemented and passes
  VSAE verification/transient test sealing; governed release signing and SCOM lab gates remain.
- Accepted ADR 0036 defines an independent Azure Local Azure Monitor Health Model. The first Bicep
  baseline uses documented Azure Local platform metrics and leaves unproven domains Unknown.
- Accepted ADRs 0023 and 0037 define the constrained Hyper-V Azure Monitor Health Model. Arc-enabled
  SCVMM is not treated as a complete health plane and does not replace Arc-enabled Server guest
  telemetry.
- Accepted ADR 0038 defines the SCOM-to-ServiceNow boundary. The Management Packs remain
  connector-neutral; ServiceNow consumes alerts through separate product allowlists and uses SCOM
  AlertId as the source identity. ServiceNow supplies the existing SCOM Events connector; this repo
  supplies configuration contracts and validation, not a custom connector. Metrics ingestion and
  bidirectional updates are opt-in policies.
- Public documentation and repository text must not expose internal work-item identifiers or direct
  board links. Use descriptive public milestones and research-gate names instead.
- ServiceNow integration is optional and solution-owned. SCOM and Azure Monitor integrations do not
  become core runtime dependencies, and dual-source forwarding requires an explicit authority or
  correlation decision. New Azure Monitor work targets Secure Webhook rather than legacy ITSM actions.
- Product source is platform first and solution second under `src/azure-local/{scom-mp,azure-monitor}`
  and `src/hyper-v/{scom-mp,azure-monitor}`. ADR 0030 is accepted and supersedes obsolete source-path
  examples in ADRs 0013–0015 without changing their substantive decisions. SquaredUp artifacts live
  inside their owning solution.
