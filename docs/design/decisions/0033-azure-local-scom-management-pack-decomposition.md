# ADR 0033 — Azure Local SCOM Management Pack decomposition

- **Status**: Accepted
- **Date**: 2026-08-13
- **Deciders**: Hybrid Solutions Cloud maintainers

## Context

The planning-era Azure Local packaging decision described three files and one product-supplied
override file. Microsoft guidance recommends logical Management Pack separation and a distinct
unsealed override MP for each sealed MP being customized. The Hyper-V implementation also proved
the value of deterministic source, independent verification, and explicit release metadata.

## Decision

Azure Local ships as an independent five-project suite:

| Artifact | Release form | Responsibility |
|---|---|---|
| HybridSolutionsCloud.AzureLocal.Library | Sealed | Classes and relationships |
| HybridSolutionsCloud.AzureLocal.Discovery | Sealed | Role seed, topology, DA membership |
| HybridSolutionsCloud.AzureLocal.Monitoring | Sealed | Health, alerts, performance, tasks, DA rollup |
| HybridSolutionsCloud.AzureLocal.Presentation | Sealed | Folders and operator views |
| HybridSolutionsCloud.AzureLocal.Reporting | Optional sealed | Reports and SLO presentation after certification |

Customers own two separate unsealed MPs:

- Organization.HybridSolutionsCloud.AzureLocal.Discovery.Overrides.xml
- Organization.HybridSolutionsCloud.AzureLocal.Monitoring.Overrides.xml

Lab, Standard, and Strict profiles are generators and examples. They never import automatically,
never become sealed product policy, and never write to the Default Management Pack.

Source is tool-neutral XML/templates plus PowerShell 7 build and verification tooling. Microsoft
SDK verification, MPVerify, sealing/signing, and SCOM lab import remain release gates.

This decision supersedes the Azure Local SCOM file and override layout in ADR 0008. It applies ADR
0022 independently and does not create a Hyper-V dependency.

## Consequences

- Discovery and monitoring customizations can be upgraded or removed independently.
- Presentation and optional reporting can evolve without changing the class library.
- Generated XML is a development artifact, not a release claim.
- Release-specific dependency versions and signing identity remain governed inputs.

## References

- [Select a Management Pack file](https://learn.microsoft.com/en-us/system-center/scom/select-management-pack-file?view=sc-om-2025)
- [Create a Management Pack for overrides](https://learn.microsoft.com/en-us/system-center/scom/manage-mp-create-unsealed-mp?view=sc-om-2025)
- [Best practices for overrides](https://learn.microsoft.com/en-us/troubleshoot/system-center/scom/best-practices-configure-overrides)
