# Project context

This repository defines Hybrid infrastructure health monitoring for two platform tracks. Azure
Local has committed SCOM Management Pack and Azure Monitor Health Models delivery surfaces. Hyper-V
has a committed SCOM Management Pack and a conditional future Azure Monitor surface through
Arc-enabled SCVMM. SquaredUp integrations are optional visualization layers. Product implementation
has not started.

The documentation is a VitePress site rooted at `docs/` and published beneath the
`/azurelocal-scom-mp/` base path. ADR 0020 records the repository owner's explicit decision to use
VitePress. ADR 0021 records platform-first organization. The site is deployed by GitHub Pages and
the central Azure DevOps VitePress template.

Azure DevOps project `Azure Local SCOM MP` remains the tracker for continuity. Epic AB#7313 owns
Azure Local, Epic AB#7314 owns Hyper-V, and Features AB#7315–AB#7318 own the four delivery surfaces.
