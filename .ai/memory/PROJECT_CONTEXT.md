# Project context

This repository defines Hybrid infrastructure health monitoring for two platform tracks. Azure
Local has committed SCOM Management Pack and Azure Monitor Health Models delivery surfaces. Hyper-V
has a committed SCOM Management Pack and a conditional future Azure Monitor surface through
Arc-enabled SCVMM. SquaredUp integrations are optional visualization layers. Product implementation
has not started.

The documentation is a VitePress site rooted at `docs/` and published beneath the
`/hybrid-health-monitoring/` base path at
`https://labs.hybridsolutions.cloud/hybrid-health-monitoring/`. ADR 0020 records the repository
owner's explicit decision to use VitePress. ADR 0021 records platform-first organization. ADR 0024
records the move to `Hybrid-Solutions-Cloud/hybrid-health-monitoring`. The site is deployed by
GitHub Pages and the central Azure DevOps VitePress template.

Azure DevOps project `Hybrid Infrastructure Health Monitoring` is the tracker. Epic AB#7313 owns
Azure Local, Epic AB#7314 owns Hyper-V, and Features AB#7315–AB#7318 own the four delivery surfaces.

Hyper-V SCOM phase one is active under Story AB#7327. Child Tasks AB#7343–AB#7353 cover support and
topology, exhaustive raw inventories, incumbent MP overlap, SCOM workflow mapping, threshold
engineering, lab/fault validation, and final catalog curation. Authoring Stories AB#7328–AB#7330
remain gated by this evidence and the successor Hyper-V ADRs.
