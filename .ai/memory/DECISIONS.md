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
  Azure Monitor is conditional on Arc-enabled SCVMM inventory/guest-management and telemetry lab
  spikes, followed by an accepted go/no-go ADR.
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
- The comprehensive Hyper-V SCOM architecture is a proposed implementation baseline, not permission
  to begin XML authoring. Proposed ADR 0027 decomposes the product into Library, Discovery,
  Monitoring, Presentation, optional Reporting, and customer-owned Overrides artifacts. Proposed
  ADR 0028 defines stable boundary identity, VM mobility, staged discovery, workflow placement, and
  cookdown. Proposed ADR 0029 defines evidence-driven health, alerts, monitoring freshness, and
  topology-aware DA rollup. The research and architecture validation program must validate all three
  before acceptance.
- Public documentation and repository text must not expose internal work-item identifiers or direct
  board links. Use descriptive public milestones and research-gate names instead.
- Product source is platform first and solution second under `src/azure-local/{scom-mp,azure-monitor}`
  and `src/hyper-v/{scom-mp,azure-monitor}`. ADR 0030 is accepted and supersedes obsolete source-path
  examples in ADRs 0013–0015 without changing their substantive decisions. Hyper-V Azure Monitor is
  a reserved boundary only until ADR 0023 records a go decision. SquaredUp artifacts live inside
  their owning solution.
