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
- Azure Local SCOM and Azure Monitor plus Hyper-V SCOM are committed delivery surfaces. Hyper-V
  Azure Monitor is conditional on Arc-enabled SCVMM inventory/guest-management and telemetry lab
  spikes, followed by an accepted go/no-go ADR.
- Shared health semantics and SCOM engineering patterns are expected, but shared sealed Management
  Pack dependencies are not approved until proposed ADR 0022 is resolved.
- Hyper-V SCOM research preserves a complete raw capability inventory separately from the curated
  default monitoring catalog. Technically collectable does not mean enabled or health-impacting.
- A 75% host-memory-used threshold is not accepted as a standalone default. Default memory health
  must consider available/reserved memory, Hyper-V pressure, paging, duration, recovery, topology,
  source evidence, and lab results.
