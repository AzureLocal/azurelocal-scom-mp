---
title: Hyper-V validation and release architecture
description: Test layers, lab topologies, fault injection, scale budgets, lifecycle validation, and release gates for the Hyper-V SCOM product.
---

# Hyper-V validation and release architecture

No Management Pack moves directly from authoring to production. Microsoft recommends a
pre-production Operations Manager environment for reviewing and tuning new or updated MPs, with
version control and archived releases. See [Management Pack lifecycle](https://learn.microsoft.com/en-us/system-center/scom/manage-mp-lifecycle?view=sc-om-2025).

## Validation layers

```mermaid
flowchart TB
    STATIC[Static: XML schema, references, aliases, IDs, strings, scripts, secrets]
    UNIT[Fixture: discovery, property bags, state mapping, thresholds, and knowledge]
    INTEGRATION[SCOM lab: import, discovery, monitor, alert, DA, views, reports, and tasks]
    FAULT[Fault lab: failure, recovery, stale data, maintenance, migration, and failover]
    SCALE[Scale: workflow cost, cardinality, databases, event volume, and convergence]
    LIFE[Lifecycle: upgrade, overrides, side-by-side, removal, and rollback procedure]
    RELEASE[Release: signing, reproducibility, guide, checksums, and provenance]

    STATIC --> UNIT --> INTEGRATION --> FAULT --> SCALE --> LIFE --> RELEASE

    classDef early fill:#e8f3ff,stroke:#0078d4,color:#172554
    classDef lab fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b
    classDef gate fill:#ecfdf5,stroke:#059669,color:#064e3b
    class STATIC,UNIT early
    class INTEGRATION,FAULT,SCALE,LIFE lab
    class RELEASE gate
```

## Continuous-integration flow

```mermaid
flowchart LR
    PR[Pull request] --> FORMAT[Markdown, XML, PowerShell, and resource checks]
    FORMAT --> BUILD[Compose and build MPs]
    BUILD --> VERIFY[Schema and Management Pack verification]
    VERIFY --> CONTRACT[Element, reference, catalog, and override contract tests]
    CONTRACT --> TESTSIGN[Test seal and sign]
    TESTSIGN --> ARTIFACT[Immutable test artifacts]
    ARTIFACT --> LAB[Approved pre-production deployment]
    LAB --> PROMOTE{All release evidence approved?}
    PROMOTE -->|No| FIX[Return to authoring]
    PROMOTE -->|Yes| SIGN[Release seal and sign]
    SIGN --> PUBLISH[Publish bundle and documentation]

    classDef source fill:#f5f3ff,stroke:#7c3aed,color:#3b0764
    classDef check fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b
    classDef decision fill:#fff7ed,stroke:#ea580c,color:#7c2d12
    classDef output fill:#ecfdf5,stroke:#059669,color:#064e3b
    class PR source
    class FORMAT,BUILD,VERIFY,CONTRACT,TESTSIGN,LAB,FIX check
    class PROMOTE decision
    class ARTIFACT,SIGN,PUBLISH output
```

## Required lab matrix

| Axis | Minimum fixtures |
|---|---|
| SCOM | Every supported Operations Manager release/update baseline |
| Windows Server | Every supported Hyper-V host release and relevant edition |
| Topology | Standalone, failover cluster, and each accepted SCVMM/SDN variant |
| Networking | Eligible Network ATC, manual networking, and SCVMM/SDN authority |
| Storage | Local, CSV/shared storage, and each accepted SMB/SAN/virtual FC variant |
| VM lifecycle | Create, rename, start, stop, save, pause, checkpoint, move, remove, and restore |
| Cluster lifecycle | Join, drain, pause, failover, node loss, quorum/witness change, and rolling update |
| Monitoring | Agent loss, workflow timeout, access denied, stale data, bad output, and recovery |
| Scale | Empty, typical, supported maximum, and limit-exceeded fixtures |

Research validation defines the exact supported matrix. A topology not represented by a repeatable fixture
cannot be listed as supported.

## Fault-to-evidence loop

```mermaid
sequenceDiagram
    participant T as Test harness
    participant H as Hyper-V fixture
    participant S as SCOM
    participant D as Distributed Application
    participant R as Evidence record

    T->>H: Inject one controlled fault
    H-->>S: Emit provider evidence
    S->>S: Discover or evaluate workflow
    S->>D: Propagate health through relationships
    S-->>R: Record alert, latency, parameters, and knowledge
    D-->>R: Record branch and root state
    T->>H: Recover or roll back fault
    H-->>S: Emit recovery evidence
    S-->>R: Record closure and convergence time
```

Every threshold and stateful monitor requires both fault and recovery evidence. A test that proves
only that an alert opens is incomplete.

## Scale budget model

```mermaid
flowchart LR
    TARGETS[Target instances] --> MULT[Workflows per target]
    MULT --> RATE[Executions per interval]
    RATE --> CPU[Agent CPU and memory]
    RATE --> DATA[Network and database volume]
    RATE --> EVENTS[Diagnostic and alert volume]
    CPU --> BUDGET{Within approved budget?}
    DATA --> BUDGET
    EVENTS --> BUDGET
    BUDGET -->|No| TUNE[Cookdown, longer interval, selective discovery, or disabled default]
    BUDGET -->|Yes| ACCEPT[Eligible for curated profile]

    classDef input fill:#e8f3ff,stroke:#0078d4,color:#172554
    classDef metric fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b
    classDef decision fill:#fff7ed,stroke:#ea580c,color:#7c2d12
    classDef output fill:#ecfdf5,stroke:#059669,color:#064e3b
    class TARGETS,MULT,RATE input
    class CPU,DATA,EVENTS metric
    class BUDGET decision
    class TUNE,ACCEPT output
```

The final support matrix records limits for hosts, clusters, VMs, adapters, disks, relationships,
workflow runtime, and collected samples. Crossing a proven limit produces guidance or a pipeline
health condition rather than uncontrolled discovery.

## Upgrade and removal sequence

```mermaid
flowchart TD
    BASE[Supported previous release installed] --> OVR[Representative customer overrides]
    OVR --> DATA[Generate topology, health, alerts, and warehouse history]
    DATA --> UPGRADE[Import candidate higher version]
    UPGRADE --> CHECK[Verify object identity, state, overrides, views, DA, and workflows]
    CHECK --> FAULT[Repeat representative fault and recovery]
    FAULT --> REMOVE[In isolated fixture, remove dependent MPs in documented order]
    REMOVE --> ORPHAN[Verify expected data/object effects and no orphaned references]
    ORPHAN --> DOC[Approve upgrade, rollback procedure, and removal documentation]

    classDef setup fill:#e8f3ff,stroke:#0078d4,color:#172554
    classDef action fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b
    classDef gate fill:#ecfdf5,stroke:#059669,color:#064e3b
    class BASE,OVR,DATA setup
    class UPGRADE,CHECK,FAULT,REMOVE,ORPHAN action
    class DOC gate
```

Removal can delete configuration and affect monitored data and dependent MPs. It is tested only in
an isolated management group and documented accurately; it is not presented as a zero-impact
rollback. Microsoft documents dependency and removal constraints in
[Import, export, and remove an Operations Manager Management Pack](https://learn.microsoft.com/en-us/system-center/scom/manage-mp-import-remove-delete?view=sc-om-2025).

## Release gates

- All proposed Hyper-V ADRs required by the release are accepted.
- The support matrix and monitoring catalog contain evidence for every enabled workflow.
- No unresolved schema, reference, best-practice, security, or secret-scan findings remain.
- Discovery converges correctly for every supported topology and lifecycle transition.
- Health and alerts open, roll up, suppress, recover, and close as designed.
- DA membership, branch health, diagram/state views, reports, dashboards, and SLO targets pass.
- Maximum-scale tests meet approved HealthService, database, and convergence budgets.
- Side-by-side import proves no runtime dependency on Azure Local or Microsoft Hyper-V 2019 MPs.
- Upgrade preserves stable identity and representative customer overrides.
- The release bundle is reproducible and signed only after test artifacts are approved.
- Published docs contain the exact artifact versions, dependencies, known issues, and tuning advice.
