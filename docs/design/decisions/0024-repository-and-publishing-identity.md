# ADR 0024 — Repository and publishing identity

**Status:** Accepted  
**Date:** 2026-08-12  
**Decision owners:** Repository owner and maintainers

## Context

The repository began as an Azure Local-specific SCOM Management Pack and was named
`AzureLocal/azurelocal-scom-mp`. ADR 0021 expanded the product into separate Azure Local and
Hyper-V platform tracks with SCOM and Azure Monitor delivery surfaces. The original organization,
repository name, internal project name, and `azurelocal.cloud` publishing address no longer
represent the complete product.

Hybrid Solutions Cloud already hosts independently named products as GitHub Pages project sites.
Its organization-wide custom domain is `labs.hybridsolutions.cloud`, so each product retains a
repository-specific path beneath that base domain.

## Decision

Adopt the following identity:

| Surface | Identity |
|---|---|
| Public product | **Hybrid Infrastructure Health Monitoring** |
| GitHub repository | `Hybrid-Solutions-Cloud/hybrid-health-monitoring` |
| Documentation | `https://labs.hybridsolutions.cloud/hybrid-health-monitoring/` |
| Local repository | `D:/git/hybrid-solutions-cloud/hybrid-health-monitoring` |

Keep the subtitle **SCOM and Azure Monitor health models for Hyper-V and Azure Local**. Use
`/hybrid-health-monitoring/` as the VitePress base because this remains a GitHub Pages project site.
Preserve repository redirects supplied by GitHub and maintain an explicit redirect from the former
documentation location, `https://azurelocal.cloud/azurelocal-scom-mp/`, to the new canonical site.

This decision supersedes only the repository-continuity statement in ADR 0021. It does not change
the platform or delivery-track architecture established there.

## Consequences

- The repository and documentation identity accurately cover both Azure Local and Hyper-V.
- The project becomes part of the Hybrid Solutions Cloud product portfolio alongside products such
  as Homestead Foundry.
- Repository links, Pages configuration, local paths, automation, governance metadata, release
  configuration, ownership references, and internal delivery links must be migrated and validated.
- GitHub redirects the former repository location, but GitHub Pages does not redirect the former
  project-site URL; that documentation redirect must be maintained separately.
- Historical release links and accepted ADR text remain unchanged as records of the identity in use
  when they were written.

## Alternatives considered

### Remain in the AzureLocal organization and rename only the repository

Rejected because organization ownership would still imply that Hyper-V is subordinate to Azure
Local rather than a peer platform track.

### Retain `azurelocal-scom-mp`

Rejected because the name omits Hyper-V and Azure Monitor and would become increasingly misleading.

### Use `hybrid-infrastructure-health-monitoring`

Rejected as the repository name because it is unnecessarily long. The complete phrase remains the
public product title, while `hybrid-health-monitoring` is the stable technical identifier.

## Related work

- [ADR 0021](0021-platform-and-delivery-track-architecture.md)
- [GitHub repository transfer behavior](https://docs.github.com/en/repositories/creating-and-managing-repositories/transferring-a-repository)
- [GitHub repository rename behavior](https://docs.github.com/en/repositories/creating-and-managing-repositories/renaming-a-repository)
