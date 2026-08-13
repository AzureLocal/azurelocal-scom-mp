# ADR 0025 — Hyper-V network-management authority

**Status:** Accepted

**Date:** 2026-08-12

**Decision owners:** Repository owner and maintainers

## Context

ADR 0021 separated the Hyper-V and Azure Local platform tracks, but its context treated Network ATC
as part of the Azure Local-specific distinction. Network ATC is also supported for eligible Windows
Server 2025 Datacenter failover clusters. It is therefore a Hyper-V topology and monitoring concern,
not an Azure Local-only capability.

Hyper-V environments can instead use manually managed host networking or select SCVMM and Windows
Server Software Defined Networking as the network-management authority. The Management Pack must
discover the active model and avoid assuming that every cluster is owned by Network ATC.

## Decision

Use Network ATC as the preferred host-networking baseline for eligible Windows Server 2025
Datacenter Hyper-V failover clusters. When SCVMM and Windows Server SDN are the selected
network-management authority, model and monitor that path instead of assuming Network ATC
ownership. Treat standalone, older, ineligible, and manually managed networking as explicit support
matrix variants. Discovery and monitoring must identify the applicable authority without enforcing
or changing host-network configuration.

This decision supersedes only the implication in ADR 0021 that Network ATC differentiates Azure
Local from Hyper-V. The platform-first and delivery-surface architecture in ADR 0021 remains
accepted.

## Consequences

- Eligible Hyper-V clusters receive Network ATC intent, deployment, status, and drift research.
- SCVMM/SDN-managed environments require their own discovery and health evidence.
- The support matrix must state which non-ATC configurations are supported.
- The MP must not create conflicting network-management ownership or remediate configuration.
- AB#7343 and AB#7348 must validate supported combinations and stable monitoring sources before
  successor discovery and signal ADRs are accepted.

## Alternatives considered

### Treat Network ATC as Azure Local-only

Rejected because it omits a supported and preferred Windows Server 2025 cluster networking model.

### Require Network ATC for every Hyper-V deployment

Rejected because standalone, older, ineligible, manually managed, and SCVMM/SDN environments need
an explicit support decision.

### Monitor Network ATC and SCVMM/SDN simultaneously without authority detection

Rejected because overlapping assumptions can produce misleading health and conflicting ownership.

## Related work

- [ADR 0021](0021-platform-and-delivery-track-architecture.md)
- Support and topology Task
  [AB#7343](https://dev.azure.com/hybridcloudsolutions/Hybrid%20Infrastructure%20Health%20Monitoring/_workitems/edit/7343)
- Network inventory Task
  [AB#7348](https://dev.azure.com/hybridcloudsolutions/Hybrid%20Infrastructure%20Health%20Monitoring/_workitems/edit/7348)
- [Microsoft Network ATC overview](https://learn.microsoft.com/en-us/azure/azure-local/concepts/network-atc-overview)
- [Microsoft Network ATC for Windows Server](https://learn.microsoft.com/en-us/windows-server/networking/network-atc/network-atc)
- [Microsoft SCVMM SDN deployment](https://learn.microsoft.com/en-us/system-center/vmm/deploy-sdn?view=sc-vmm-2025)
