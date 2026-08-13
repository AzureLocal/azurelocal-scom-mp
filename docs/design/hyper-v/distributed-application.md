---
title: Hyper-V Distributed Application
description: Hyper-V SCOM Distributed Application service model, dynamic membership, component groups, rollup, topology changes, views, and research gates.
---

# Hyper-V Distributed Application design

The Hyper-V SCOM product ships a Hyper-V-owned Distributed Application (DA) with no dependency on
the Azure Local MP. One DA represents one operational failure boundary: a failover cluster or a
standalone Hyper-V host. The implemented root is `HybridSolutionsCloud.HyperV.Service`, keyed by
the stable cluster-or-host boundary ID and derived from the SCOM Service Designer service class.

A DA organizes and presents health. It does not replace correctly targeted unit, aggregate, and
dependency monitors. Microsoft describes Distributed Applications as grouped monitored objects
whose overall health is calculated for service-oriented alerts, views, and reports. See
[Use the Authoring workspace in Operations Manager](https://learn.microsoft.com/en-us/system-center/scom/manage-using-authoring-workspace?view=sc-om-2025).

## Service boundary rule

```mermaid
flowchart TD
    OBJECT[Discovered Hyper-V object] --> OWNER{Stable operational boundary?}
    OWNER -->|Failover cluster| CDA[Cluster DA]
    OWNER -->|Standalone host| HDA[Standalone-host DA]
    OWNER -->|Unknown or ambiguous| HOLD[Exclude from DA and raise topology/pipeline evidence]
    CDA --> ONE[Exactly one required DA membership path]
    HDA --> ONE
    ONE --> HEALTH[Health rolls to one service root]

    classDef decision fill:#fff7ed,stroke:#ea580c,color:#7c2d12
    classDef service fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b
    classDef outcome fill:#ecfdf5,stroke:#059669,color:#064e3b
    class OWNER decision
    class CDA,HDA,HOLD service
    class ONE,HEALTH outcome
```

SCVMM management does not merge unrelated clusters or hosts into one required DA. A future fleet
view can aggregate DAs through presentation content or a separately packaged integration MP.

## Cluster DA

```mermaid
flowchart TB
    ROOT[Hyper-V cluster service]
    COMP[Compute and cluster]
    VM[Virtual machines]
    STO[Storage and Replica]
    NET[Networking]
    MGMT[Management plane]
    PIPE[Monitoring pipeline]

    ROOT --> COMP
    ROOT --> VM
    ROOT --> STO
    ROOT --> NET
    ROOT --> MGMT
    ROOT --> PIPE

    COMP --> CLUSTER[Cluster, quorum, nodes, roles, and resources]
    VM --> VMS[Expected-running and actionable VMs]
    STO --> CSV[CSVs, paths, virtual disks, VHD/VHDX, and Replica]
    NET --> AUTH[Exactly one Network ATC, manual, or SCVMM/SDN authority path]
    MGMT --> OPTIONAL[Optional SCVMM and Network Controller dependencies]
    PIPE --> TELEMETRY[Agents, discovery freshness, workflow health, and data freshness]

    classDef root fill:#fff7ed,stroke:#ea580c,color:#7c2d12
    classDef branch fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b
    classDef member fill:#ecfdf5,stroke:#059669,color:#064e3b
    class ROOT root
    class COMP,VM,STO,NET,MGMT,PIPE branch
    class CLUSTER,VMS,CSV,AUTH,OPTIONAL,TELEMETRY member
```

## Standalone-host DA

```mermaid
flowchart TB
    ROOT[Hyper-V standalone-host service]
    COMP[Compute and host]
    VM[Virtual machines]
    STO[Storage and Replica]
    NET[Networking]
    PIPE[Monitoring pipeline]

    ROOT --> COMP
    ROOT --> VM
    ROOT --> STO
    ROOT --> NET
    ROOT --> PIPE

    COMP --> HOST[Windows computer, Hyper-V role, and required services]
    VM --> VMS[Expected-running and actionable VMs]
    STO --> DISK[Local/external paths, virtual disks, VHD/VHDX, and Replica]
    NET --> SWITCH[Physical adapters, switches, ports, and VM adapters]
    PIPE --> TELEMETRY[Agent, discovery, workflow, and freshness health]

    classDef root fill:#fff7ed,stroke:#ea580c,color:#7c2d12
    classDef branch fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b
    classDef member fill:#ecfdf5,stroke:#059669,color:#064e3b
    class ROOT root
    class COMP,VM,STO,NET,PIPE branch
    class HOST,VMS,DISK,SWITCH,TELEMETRY member
```

Cluster-only objects are absent rather than Healthy placeholders in a standalone DA. The optional
Management plane branch appears only when an accepted topology makes that plane operationally
required.

## Component contract

| DA branch | Membership | Default root impact |
|---|---|---|
| Compute and cluster | Host role or cluster, quorum, nodes, clustered roles/resources, and required virtualization services | Availability-critical; redundancy-aware for clustered hosts |
| Virtual machines | VMs classified as actionable by expected-state policy | Population-aware; intentional Off/Saved/template states do not penalize availability |
| Storage and Replica | CSVs, approved storage paths, disks, VHD/VHDX dependencies, and Replica relationships | Availability or data-integrity critical where the dependency is required |
| Networking | Physical-to-virtual topology under exactly one selected authority | Availability-critical for required paths; configuration drift can be lower impact |
| Management plane | Optional SCVMM, Network Controller, and authoritative management dependencies | Topology-specific; absent when not selected |
| Monitoring pipeline | Agent, required discovery freshness, workflow health, and required collection paths | Root-impacting so missing telemetry cannot look Healthy |

## Dynamic membership

The DA is authored in XML and populated from discovered classes and typed relationships. Operators
must not recreate it manually with the Distributed Application Designer.

```mermaid
sequenceDiagram
    participant T as Topology discoveries
    participant R as SCOM relationships
    participant M as DA membership discovery
    participant G as Component groups
    participant D as DA root

    T->>R: Create stable boundary, object, and ownership relationships
    M->>R: Query supported typed relationships
    M->>G: Add current members to exactly one applicable branch
    G->>D: Expose dependency rollup path
    Note over M,G: Reconcile membership by stable key
```

Membership rules:

- Start from the stable DA boundary key, not an estate-wide group or name pattern.
- Traverse only product-owned or explicitly approved typed relationships.
- Give every required member exactly one canonical health path to avoid double weighting.
- Do not put the same networking object under Network ATC and SCVMM/SDN branches.
- Retain intentionally non-impacting objects in state/inventory views when useful, without adding
  them to an availability dependency rollup.
- Treat empty required branches as topology or monitoring-pipeline faults, not Healthy success.

## Membership reconciliation

```mermaid
flowchart TD
    SNAP[Authoritative topology snapshot] --> MAP[Map stable IDs and relationships]
    MAP --> VALID{Keys unique and authority unambiguous?}
    VALID -->|No| FAULT[Preserve last known safe membership and raise pipeline fault]
    VALID -->|Yes| DIFF[Compare with current DA membership]
    DIFF --> ADD[Add new supported members]
    DIFF --> KEEP[Keep unchanged members and health history]
    DIFF --> REMOVE[Remove authoritatively absent relationships]
    ADD --> COMMIT[Commit one deterministic membership snapshot]
    KEEP --> COMMIT
    REMOVE --> COMMIT
    COMMIT --> VERIFY[Verify expected branch counts and freshness]

    classDef decision fill:#fff7ed,stroke:#ea580c,color:#7c2d12
    classDef process fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b
    classDef good fill:#ecfdf5,stroke:#059669,color:#064e3b
    classDef bad fill:#fef2f2,stroke:#dc2626,color:#7f1d1d
    class VALID decision
    class SNAP,MAP,DIFF,ADD,KEEP,REMOVE process
    class COMMIT,VERIFY good
    class FAULT bad
```

## Health propagation

```mermaid
flowchart BT
    SIGNAL[Provider evidence] --> UNIT[Unit monitor state]
    UNIT --> DIM[Object health dimension]
    DIM --> OBJECT[Object health]
    OBJECT --> DEP[Dependency monitor]
    DEP --> BRANCH[DA component-group health]
    BRANCH --> IMPACT[Impact-weighted root dependency]
    IMPACT --> ROOT[Hyper-V deployment health]
    ROOT --> SLA[Views, reports, dashboards, and SLO]

    classDef source fill:#e8f3ff,stroke:#0078d4,color:#172554
    classDef health fill:#ecfdf5,stroke:#059669,color:#064e3b
    classDef service fill:#fff7ed,stroke:#ea580c,color:#7c2d12
    class SIGNAL source
    class UNIT,DIM,OBJECT,DEP,BRANCH health
    class IMPACT,ROOT,SLA service
```

Worst state is a starting point, not an unconditional algorithm. Redundant hosts, VM populations,
maintenance, node drain, planned migration, intentional power states, and monitoring freshness need
topology-aware policies validated through lab research.

## Failure examples

```mermaid
flowchart LR
    Q[Quorum unavailable] --> CQ[Compute branch Critical]
    CQ --> CR[Cluster DA Critical]

    V[One intentionally stopped VM] --> VX[Excluded from availability penalty]
    VX --> VR[VM branch remains based on actionable population]

    A[All required discovery stale] --> MP[Monitoring pipeline Critical]
    MP --> DR[DA not allowed to remain Healthy]

    classDef critical fill:#fef2f2,stroke:#dc2626,color:#7f1d1d
    classDef expected fill:#ecfdf5,stroke:#059669,color:#064e3b
    class Q,CQ,CR,A,MP,DR critical
    class V,VX,VR expected
```

## Operator surfaces

```mermaid
flowchart TB
    DA[Selected Hyper-V DA] --> DIAGRAM[Diagram view]
    DA --> STATE[Component and object state views]
    DA --> ALERT[Active alerts scoped to members]
    DA --> PERF[Curated performance views]
    DA --> EVENT[Curated event views]
    DA --> TASK[Safe diagnostic tasks]
    DA --> REPORT[Availability, performance, capacity, and change reports]
    DA --> SLO[Service-level objective targets]
    DA --> DASH[Optional SquaredUp dashboards]

    classDef root fill:#fff7ed,stroke:#ea580c,color:#7c2d12
    classDef surface fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b
    class DA root
    class DIAGRAM,STATE,ALERT,PERF,EVENT,TASK,REPORT,SLO,DASH surface
```

Every surface scopes through stable DA membership or product-owned classes. Reports and dashboards
do not reimplement topology with display-name queries.

Microsoft permits service-level objectives to target a class, group, or Distributed Application.
The product provides DA-oriented guidance and validates the selected target in pre-production. See
[Service-level objectives](https://learn.microsoft.com/en-us/system-center/scom/manage-monitor-sla-overview?view=sc-om-2025).

## Required product artifacts

- Hyper-V-owned DA root and component-group class XML;
- deterministic dynamic membership discoveries for cluster and standalone boundaries;
- topology-aware aggregate and dependency monitors;
- localized diagram, state, alert, event, performance, and task views;
- availability and performance report/SLO guidance;
- optional SquaredUp Dashboard Server content targeting only Hyper-V classes; and
- import, empty-topology, population, move, failover, fault, recovery, scale, upgrade, coexistence,
  and removal tests.

## Release-validation gates

The DA is authored. Before release, lab evidence must prove:

1. stable cluster and standalone-host root keys;
2. deterministic membership and execution placement across HealthServices;
3. correct VM identity and membership during migration, drain, failover, rename, and removal;
4. exclusive Network ATC, manual, or SCVMM/SDN authority membership;
5. actionable expected-state and population rollups for VMs;
6. redundancy-aware host and cluster rollups;
7. Unknown/stale-data behavior and recovery;
8. acceptable membership and rollup cost at supported maximum scale; and
9. correct views, reports, dashboards, and SLO targeting.

## Related design

- [Hyper-V SCOM architecture](architecture.md)
- [Class and relationship model](class-and-relationship-model.md)
- [Health and alert architecture](health-and-alert-architecture.md)
- [ADR 0026 — Platform-owned SCOM Distributed Applications](../decisions/0026-platform-owned-scom-distributed-applications.md)
- [Hyper-V monitoring research](../../hyper-v/monitoring-research.md)
