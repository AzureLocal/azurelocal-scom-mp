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
topology, exhaustive raw inventories, prior Microsoft MP research, SCOM workflow mapping, threshold
engineering, lab/fault validation, and final catalog curation. AB#7359 validates the comprehensive
MP/DA architecture and resolves proposed ADRs 0027–0029. Authoring Stories AB#7328–AB#7330 remain
gated by this evidence and accepted successor Hyper-V ADRs.

The design information architecture is platform first and delivery surface second. It has explicit
Azure Local/SCOM, Azure Local/Azure Monitor, Hyper-V/SCOM, and conditional Hyper-V/Azure Monitor
lanes. Shared design is deliberately small; accepted Azure Local ADRs do not silently govern
Hyper-V. ADR 0025 establishes Network ATC as the preferred eligible Hyper-V cluster baseline while
requiring separate handling for SCVMM/SDN and non-ATC network-management paths.

ADRs 0022 and 0026 establish the SCOM product boundary: Azure Local and Hyper-V share research and
non-runtime engineering practices only. They own independent MP namespaces, packages, classes,
monitoring, overrides, Distributed Applications, releases, and support lifecycles. Azure Local uses
the deployment DA defined by ADR 0005/0018. Hyper-V requires a separate DA instance per supported
failover cluster or standalone host, refined by AB#7327 before authoring.

The source tree enforces the same hierarchy through accepted ADR 0030. Azure Local and Hyper-V are
top-level source owners, each with `scom-mp` and `azure-monitor` solution roots. The Hyper-V Azure
Monitor root is reserved but cannot contain deployable implementation before an ADR 0023 go decision.
