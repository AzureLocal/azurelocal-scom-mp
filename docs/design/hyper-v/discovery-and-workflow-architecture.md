---
title: Hyper-V discovery and workflow architecture
description: Staged topology discovery, source selection, cookdown, monitor and rule design, and workflow execution boundaries.
---

# Hyper-V discovery and workflow architecture

Discovery is staged from a cheap role seed to progressively richer topology. Monitoring begins only
after the target class exists, and each workflow runs where its target and data source can be
evaluated safely. The MP prefers native event, service, performance, registry, and CIM providers;
PowerShell is used where it supplies a materially better supported topology contract, not as a
universal wrapper around every signal.

## Staged discovery pipeline

```mermaid
flowchart LR
    W[Windows Server computer] --> SEED[Stage 0: Hyper-V role seed]
    SEED --> ROLE[Stage 1: host role and version]
    ROLE --> MODE{Stage 2: topology classification}
    MODE -->|Standalone| HOST[Host-boundary topology]
    MODE -->|Clustered| CLUSTER[Cluster-boundary topology]
    CLUSTER --> AUTH{Stage 3: network authority}
    AUTH --> ATC[Network ATC]
    AUTH --> SDN[SCVMM/SDN]
    AUTH --> MANUAL[Manual]
    HOST --> DETAIL[Stage 4: approved child entities]
    ATC --> DETAIL
    SDN --> DETAIL
    MANUAL --> DETAIL
    DETAIL --> REL[Stage 5: relationships and DA membership]
    REL --> FRESH[Stage 6: freshness and self-monitoring]

    classDef seed fill:#e8f3ff,stroke:#0078d4,color:#172554
    classDef decision fill:#fff7ed,stroke:#ea580c,color:#7c2d12
    classDef stage fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b
    classDef finish fill:#ecfdf5,stroke:#059669,color:#064e3b
    class W,SEED seed
    class MODE,AUTH decision
    class ROLE,HOST,CLUSTER,ATC,SDN,MANUAL,DETAIL,REL stage
    class FRESH finish
```

Each stage has an independently testable contract. A failure in detailed storage discovery must not
erase the already proven Hyper-V host role or make the discovery pipeline appear healthy.

## Discovery contract

Every discovery defines:

| Field | Required content |
|---|---|
| Target | Narrowest stable seed class |
| Execution location | Agent, cluster-managing HealthService, or approved resource pool |
| Provider | Registry, service manager, event log, performance provider, CIM/WMI, PowerShell, or SDK |
| Key mapping | Source field to every class key and hosting key |
| Relationship mapping | Source, target, relationship type, and deletion behavior |
| Schedule | Interval, optional synchronization time, timeout, and jitter strategy if supported |
| Cost | Expected runtime, object count, data size, and provider calls |
| Failure behavior | Event/logging, stale deadline, retry, and last-known-topology policy |
| Security | Default action account or named Run As profile with minimum permissions |
| Test fixtures | Empty, normal, maximum scale, malformed data, access denied, timeout, and topology change |

## Source selection

```mermaid
flowchart TD
    NEED[Required signal or topology fact] --> EVENT{Authoritative event exists?}
    EVENT -->|Yes| E[Event data source]
    EVENT -->|No| PERF{Native performance counter exists?}
    PERF -->|Yes| P[Performance data source]
    PERF -->|No| STATE{Service, registry, or CIM property exists?}
    STATE -->|Yes| N[Native state/property provider]
    STATE -->|No| PS{Supported PowerShell cmdlet is authoritative?}
    PS -->|Yes| S[PowerShell data source]
    PS -->|No| SYN{Safe synthetic test required?}
    SYN -->|Yes| T[Explicit synthetic workflow]
    SYN -->|No| EX[Exclude or retain as research-only]
    E --> VALIDATE[Validate semantics, cost, privilege, and failure behavior]
    P --> VALIDATE
    N --> VALIDATE
    S --> VALIDATE
    T --> VALIDATE

    classDef question fill:#fff7ed,stroke:#ea580c,color:#7c2d12
    classDef source fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b
    classDef gate fill:#ecfdf5,stroke:#059669,color:#064e3b
    class EVENT,PERF,STATE,PS,SYN question
    class E,P,N,S,T,EX source
    class VALIDATE gate
```

## Monitor, rule, or task

```mermaid
flowchart TD
    SIGNAL[Validated signal] --> CURRENT{Must it represent current health?}
    CURRENT -->|Yes| STATEFUL[Unit monitor]
    CURRENT -->|No| AUTO{Must it run automatically?}
    AUTO -->|No| TASK[Diagnostic or recovery task]
    AUTO -->|Yes| STORE{Store data for trends or reports?}
    STORE -->|Yes| COLLECT[Collection rule]
    STORE -->|No| EVENT{Create an alert from a discrete event?}
    EVENT -->|Yes| ALERT[Alert-generating rule]
    EVENT -->|No| DIAG[Diagnostic-only rule or exclusion]
    STATEFUL --> RECOVERY[Define warning/critical, recovery, and missing-data behavior]
    ALERT --> CLOSE[Define suppression, repeat count, and closure behavior]

    classDef question fill:#fff7ed,stroke:#ea580c,color:#7c2d12
    classDef choice fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b
    classDef contract fill:#ecfdf5,stroke:#059669,color:#064e3b
    class CURRENT,AUTO,STORE,EVENT question
    class STATEFUL,TASK,COLLECT,ALERT,DIAG choice
    class RECOVERY,CLOSE contract
```

Rules do not create durable current health. A condition that operators must see in Health Explorer
after the original event has passed needs a monitor with a reliable healthy transition or reset.

## Cookdown design

```mermaid
flowchart LR
    TIMER[One scheduled trigger] --> DS[Shared data source]
    DS --> BAG[Multi-instance property bags]
    BAG --> F1[Filter for VM A]
    BAG --> F2[Filter for VM B]
    BAG --> F3[Filter for VM N]
    F1 --> M1[Monitor or rule A]
    F2 --> M2[Monitor or rule B]
    F3 --> M3[Monitor or rule N]

    BAD1[Per-object script A] -. avoid .-> P1[Provider query]
    BAD2[Per-object script B] -. avoid .-> P2[Provider query]

    classDef shared fill:#ecfdf5,stroke:#059669,color:#064e3b
    classDef consumer fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b
    classDef bad fill:#fef2f2,stroke:#dc2626,color:#7f1d1d
    class TIMER,DS,BAG shared
    class F1,F2,F3,M1,M2,M3 consumer
    class BAD1,BAD2,P1,P2 bad
```

Cookdown is required where multiple workflows can use the same module configuration and provider
call. It is not assumed merely because scripts look similar: target, configuration XML, Run As,
schedule, and module parameters must be identical. Workflow research records expected cookdown groups and lab
evidence for each multi-instance data source.

## Workflow execution placement

| Signal owner | Preferred execution | Reason |
|---|---|---|
| Host-local service, event, counter, adapter, or switch | Agent on that host | Lowest latency and no remote credential path |
| VM runtime state | Agent currently responsible for the supported provider view | Avoid management-server fan-out; preserve VM identity separately from placement |
| Cluster-wide topology | Proven cluster-managing agent or approved resource pool | Requires one authoritative view and failover-safe execution |
| SCVMM/SDN management object | Approved management server/resource pool only if the variant is supported | Keep remote SDK access explicit and optional |
| DA membership reconciliation | Management server or resource-pool workflow with deterministic source relationships | Membership spans objects managed by multiple HealthServices |

## Workflow state machine

```mermaid
stateDiagram-v2
    [*] --> Scheduled
    Scheduled --> Acquiring
    Acquiring --> Evaluating: valid data
    Acquiring --> Retrying: transient provider failure
    Acquiring --> Failed: timeout, access denied, or malformed data
    Retrying --> Acquiring: bounded retry
    Retrying --> Failed: retry budget exhausted
    Evaluating --> Publishing
    Publishing --> Complete
    Failed --> TelemetryFault
    TelemetryFault --> Scheduled: next interval
    Complete --> Scheduled: next interval
```

Retries must be bounded. Persistent failure becomes monitoring-pipeline health and actionable
knowledge rather than an infinite retry loop or a silent Healthy result.

## Topology-change sequence

```mermaid
sequenceDiagram
    participant P as Hyper-V or cluster provider
    participant D as Discovery workflow
    participant S as SCOM topology service
    participant H as Health model
    participant A as Hyper-V DA

    P-->>D: VM moved, node drained, or resource ownership changed
    D->>S: Submit stable instances and revised relationships
    S->>H: Recalculate workflow targeting and dependencies
    H->>A: Reconcile DA membership and rollup paths
    Note over S,A: Stable objects retain identity, state history, and overrides
```

## Authoring constraints

- Use reusable composite module types for repeated acquisition and state logic.
- Expose interval, timeout, enabled state, thresholds, consecutive samples, and recovery bands only
  when operators have a safe reason to override them.
- Never pass secrets in script arguments, events, property bags, alert parameters, or debug output.
- Emit one structured diagnostic event per failure episode, with throttling to prevent event storms.
- Return no discovery data only when the source authoritatively reports absence. Access denied,
  timeout, or malformed output is a workflow failure, not proof that objects disappeared.
- Keep collected properties deterministic; sort multi-instance results before building discovery
  data to make fixture comparison stable.
- All script data must be validated for type, range, null, duplicate key, and encoding behavior.

## Research gates

Workflow and lab research must validate source semantics, execution placement, cookdown, timeout,
cardinality, failure behavior, and recovery before the first signed release.
