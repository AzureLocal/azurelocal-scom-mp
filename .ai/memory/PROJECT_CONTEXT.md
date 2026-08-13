# Project context

This repository defines Hybrid infrastructure health monitoring for two platform tracks. Azure
Local has committed SCOM Management Pack and Azure Monitor Health Models delivery surfaces. Hyper-V
has a committed SCOM Management Pack and a conditional future Azure Monitor surface through
Arc-enabled SCVMM. SquaredUp integrations are optional visualization layers. The Hyper-V
functional development MP is authored; it is not yet a sealed, signed, or SCOM-lab-certified
release.

The documentation is a VitePress site rooted at `docs/` and published beneath the
`/hybrid-health-monitoring/` base path at
`https://labs.hybridsolutions.cloud/hybrid-health-monitoring/`. ADR 0020 records the repository
owner's explicit decision to use VitePress. ADR 0021 records platform-first organization. ADR 0024
records the move to `Hybrid-Solutions-Cloud/hybrid-health-monitoring`. The site is deployed by
GitHub Pages and the central Azure DevOps VitePress template.

Internal delivery tracking mirrors the two platforms and four solution boundaries. Work-item
identifiers and direct board links must never be published in the public site or repository text.

Hyper-V SCOM phase one covers support and topology, exhaustive raw inventories, prior Microsoft MP
research, SCOM workflow mapping, threshold engineering, lab/fault validation, final catalog
curation, and comprehensive MP/DA architecture validation. ADRs 0027–0029 and 0031 are accepted;
the authored development baseline now advances through SDK dependency verification, sealing, and
lab certification.

The proposed Hyper-V packaging contract includes sealed Library, Discovery, Monitoring,
Presentation, and optional Reporting artifacts. Customers own separate unsealed Discovery and
Monitoring override MPs. Optional Lab, Standard, and Strict templates are public starter examples,
not active product policy, and the Default Management Pack is never a customization target.

The design information architecture is platform first and delivery surface second. It has explicit
Azure Local/SCOM, Azure Local/Azure Monitor, Hyper-V/SCOM, and conditional Hyper-V/Azure Monitor
lanes. Shared design is deliberately small; accepted Azure Local ADRs do not silently govern
Hyper-V. ADR 0025 establishes Network ATC as the preferred eligible Hyper-V cluster baseline while
requiring separate handling for SCVMM/SDN and non-ATC network-management paths.

ADRs 0022 and 0026 establish the SCOM product boundary: Azure Local and Hyper-V share research and
non-runtime engineering practices only. They own independent MP namespaces, packages, classes,
monitoring, overrides, Distributed Applications, releases, and support lifecycles. Azure Local uses
the deployment DA defined by ADR 0005/0018. Hyper-V requires a separate DA instance per supported
failover cluster or standalone host, refined by topology and DA validation before authoring.

The source tree enforces the same hierarchy through accepted ADR 0030. Azure Local and Hyper-V are
top-level source owners, each with `scom-mp` and `azure-monitor` solution roots. The Hyper-V Azure
Monitor root is reserved but cannot contain deployable implementation before an ADR 0023 go decision.

ServiceNow is a Later optional integration area. SCOM and Azure Monitor have separate integration
paths and artifacts. The candidate SCOM path uses ServiceNow SCOM Events and optional Metrics
connectors through a MID Server. The candidate Azure Monitor path uses Secure Webhook action groups
with the common alert schema, with Logic Apps only when enrichment or orchestration is required.
Dual-source deployments must prove authoritative-source or correlation behavior before release.
