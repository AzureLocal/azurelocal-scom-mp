# Research spikes

Research is tracked as time-boxed Azure DevOps User Stories. Each spike must produce evidence,
update the relevant proposed ADR, and identify executable follow-up work. A spike is not complete
when it merely collects links.

## Current spike backlog

| Spike | Platform / surface | Required evidence | Work item |
|---|---|---|---|
| Independent SCOM packaging contract | Both SCOM products | Separate artifact/namespace ownership, no-dependency reference graphs, signing, coexistence, upgrade, and removal evidence | [AB#7319](https://dev.azure.com/hybridcloudsolutions/Hybrid%20Infrastructure%20Health%20Monitoring/_workitems/edit/7319) |
| Hyper-V SCOM monitoring catalog and DA refinement | Hyper-V / SCOM | Complete raw signal inventory, prior-MP research, SCOM workflow mapping, DA boundary/membership/rollup inputs, threshold evidence, lab validation, curated defaults, and successor ADR inputs | [AB#7327](https://dev.azure.com/hybridcloudsolutions/Hybrid%20Infrastructure%20Health%20Monitoring/_workitems/edit/7327) |
| Azure Local Health Models API and signal revalidation | Azure Local / Azure Monitor | Current API versions, preview limits, identity and RBAC contract, signal-source delta report | [AB#7323](https://dev.azure.com/hybridcloudsolutions/Hybrid%20Infrastructure%20Health%20Monitoring/_workitems/edit/7323) |
| Arc-enabled SCVMM inventory and guest management | Hyper-V / Azure Monitor | ARM resource map, Arc Resource Bridge behavior, guest-management distinction, support and network matrix, repeatable lab steps | [AB#7331](https://dev.azure.com/hybridcloudsolutions/Hybrid%20Infrastructure%20Health%20Monitoring/_workitems/edit/7331) |
| Hyper-V telemetry and Health Models feasibility | Hyper-V / Azure Monitor | Minimum viable entity graph, supported signals, fault-injection result, identity, latency, scale and cost findings | [AB#7332](https://dev.azure.com/hybridcloudsolutions/Hybrid%20Infrastructure%20Health%20Monitoring/_workitems/edit/7332) |

## Planned ADR flow

```mermaid
flowchart LR
    P[Platform split decision<br/>ADR 0021] --> Pkg[Independent packaging decision<br/>ADR 0022]
    Pkg --> S1[Packaging contract validation<br/>AB#7319]
    Pkg --> DA[Platform-owned DAs<br/>ADR 0026]
    P --> S2[Hyper-V SCOM catalog research<br/>AB#7327]
    P --> Net[Hyper-V network authority<br/>ADR 0025]
    Net --> S2
    S2 --> MP[MP decomposition<br/>ADR 0027 proposed]
    S2 --> OBJ[Object and discovery architecture<br/>ADR 0028 proposed]
    S2 --> HEALTH[Health and DA rollup<br/>ADR 0029 proposed]
    P --> S3[Arc-enabled SCVMM spike<br/>AB#7331]
    S3 --> S4[Telemetry proof<br/>AB#7332]
    S4 --> Arc[Go / defer / no-go<br/>ADR 0023]
```

## Hyper-V SCOM phase-one child spikes

AB#7327 is the umbrella research Story. Its bounded child Tasks can execute in the dependency order
shown on the [Hyper-V monitoring research](../hyper-v/monitoring-research.md) page:

Their evidence validates the proposed
[MP decomposition](decisions/0027-hyper-v-scom-management-pack-decomposition.md),
[object/discovery architecture](decisions/0028-hyper-v-object-and-discovery-architecture.md), and
[health/DA rollup](decisions/0029-hyper-v-health-alert-and-da-rollup.md) decisions.

| Work item | Focus |
|---|---|
| [AB#7343](https://dev.azure.com/hybridcloudsolutions/Hybrid%20Infrastructure%20Health%20Monitoring/_workitems/edit/7343) | Support matrix, topology, DA boundary keys, and candidate membership |
| [AB#7344](https://dev.azure.com/hybridcloudsolutions/Hybrid%20Infrastructure%20Health%20Monitoring/_workitems/edit/7344) | Windows Server host and platform signals |
| [AB#7345](https://dev.azure.com/hybridcloudsolutions/Hybrid%20Infrastructure%20Health%20Monitoring/_workitems/edit/7345) | Hyper-V, hypervisor, and VM signals |
| [AB#7346](https://dev.azure.com/hybridcloudsolutions/Hybrid%20Infrastructure%20Health%20Monitoring/_workitems/edit/7346) | Failover Cluster, quorum, and CSV signals |
| [AB#7347](https://dev.azure.com/hybridcloudsolutions/Hybrid%20Infrastructure%20Health%20Monitoring/_workitems/edit/7347) | Storage, VHD/VHDX, and Replica signals |
| [AB#7348](https://dev.azure.com/hybridcloudsolutions/Hybrid%20Infrastructure%20Health%20Monitoring/_workitems/edit/7348) | Network ATC, manual, and SCVMM/SDN Hyper-V networking signals |
| [AB#7349](https://dev.azure.com/hybridcloudsolutions/Hybrid%20Infrastructure%20Health%20Monitoring/_workitems/edit/7349) | Existing Microsoft MP research inputs; no runtime dependency or reuse of its package |
| [AB#7350](https://dev.azure.com/hybridcloudsolutions/Hybrid%20Infrastructure%20Health%20Monitoring/_workitems/edit/7350) | Supported SCOM workflow, dynamic DA membership, rollup mapping, and cost |
| [AB#7351](https://dev.azure.com/hybridcloudsolutions/Hybrid%20Infrastructure%20Health%20Monitoring/_workitems/edit/7351) | Threshold, duration, recovery, and tuning policy |
| [AB#7352](https://dev.azure.com/hybridcloudsolutions/Hybrid%20Infrastructure%20Health%20Monitoring/_workitems/edit/7352) | Lab source, fault, latency, recovery, and overhead validation |
| [AB#7353](https://dev.azure.com/hybridcloudsolutions/Hybrid%20Infrastructure%20Health%20Monitoring/_workitems/edit/7353) | Final Must/Should/Could/collect-only/excluded catalog |
| [AB#7359](https://dev.azure.com/hybridcloudsolutions/Hybrid%20Infrastructure%20Health%20Monitoring/_workitems/edit/7359) | Trace all architecture contracts to the research evidence and resolve proposed ADRs 0027–0029 |

## Spike completion contract

Every spike must include:

1. the question and explicit non-goals;
2. first-party source citations and tested product versions;
3. repeatable lab steps, fixtures, or API queries;
4. observed results, including negative results and unsupported paths;
5. risks, gaps, cost, scale, and security implications;
6. a recommendation with confidence level; and
7. ADR and backlog updates driven by the evidence.
