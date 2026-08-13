---
title: Hyper-V health and alert architecture
description: Hyper-V SCOM health dimensions, monitor-state behavior, alert policy, rollup, suppression, missing data, and threshold design.
---

# Hyper-V health and alert architecture

Health answers **what is currently unhealthy**; alerts answer **what an operator should act on**.
They are related but not identical. Unit monitors establish object health, aggregate monitors organize
the four SCOM health dimensions, dependency monitors propagate service impact, and alerts originate
at the most actionable layer. Rules collect diagnostic history or alert on discrete events that do
not have a durable state model.

## Health construction

```mermaid
flowchart LR
    SOURCE[Validated signal] --> UNIT[Unit monitor]
    UNIT --> DIM[Availability, Configuration, Performance, or Security]
    DIM --> OBJECT[Object health]
    OBJECT --> DEP[Dependency monitor]
    DEP --> GROUP[DA component health]
    GROUP --> ROOT[Hyper-V deployment health]
    UNIT --> ALERT[Actionable alert]
    ALERT --> KNOW[Product knowledge and diagnostics]

    classDef signal fill:#e8f3ff,stroke:#0078d4,color:#172554
    classDef health fill:#ecfdf5,stroke:#059669,color:#064e3b
    classDef action fill:#fff7ed,stroke:#ea580c,color:#7c2d12
    class SOURCE signal
    class UNIT,DIM,OBJECT,DEP,GROUP,ROOT health
    class ALERT,KNOW action
```

Aggregate and dependency monitors normally do not generate duplicate alerts. The leaf monitor that
has the evidence and remediation context alerts; its state then rolls up for service impact.

## Standard health dimensions

| Dimension | Hyper-V examples | Typical evidence |
|---|---|---|
| Availability | Host role, VM service, cluster/node/resource, CSV online, Replica availability | Service state, cluster state, authoritative events, heartbeat |
| Configuration | Version drift, unsupported topology, integration configuration, network authority drift | Registry, CIM, PowerShell, configuration provider |
| Performance | Sustained CPU pressure, memory pressure, latency, queue, packet loss | Performance counters and calculated property bags |
| Security | Explicit security posture signals that are both supported and actionable | Security/configuration provider; disabled unless evidence supports default health |

Security is not a catch-all for general configuration. The first release includes Security health
only for signals with a documented source, owner, remediation, and support boundary.

## Stateful threshold pattern

```mermaid
stateDiagram-v2
    [*] --> Healthy
    Healthy --> Warning: warning condition sustained
    Warning --> Critical: critical condition sustained
    Critical --> Warning: below critical recovery band
    Warning --> Healthy: below warning recovery band
    Critical --> Healthy: authoritative recovery event
    Healthy --> Unknown: telemetry stale or workflow failed
    Warning --> Unknown: telemetry stale or workflow failed
    Critical --> Unknown: telemetry stale or workflow failed
    Unknown --> Healthy: valid healthy evidence
    Unknown --> Warning: valid warning evidence
    Unknown --> Critical: valid critical evidence
```

SCOM may render a missing or uninitialized state as unmonitored rather than a custom fourth state;
the implementation must map that platform behavior explicitly. It must not substitute Healthy for
missing evidence.

## Threshold contract

Every numeric monitor defines the complete time behavior, not only a percentage:

```mermaid
flowchart LR
    SAMPLE[Sample interval] --> WINDOW[Consecutive samples or duration]
    WINDOW --> ENTRY[Warning and critical entry bands]
    ENTRY --> HYST[Recovery bands and hysteresis]
    HYST --> STATE[Health transition]
    STATE --> ALERT[Alert severity, priority, and repeat behavior]
    ALERT --> ROLL[Object and DA impact]
    ROLL --> OVERRIDE[Safe override parameters]

    classDef contract fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b
    classDef result fill:#ecfdf5,stroke:#059669,color:#064e3b
    class SAMPLE,WINDOW,ENTRY,HYST,OVERRIDE contract
    class STATE,ALERT,ROLL result
```

The default host-memory design does not alert at 75% utilization alone. It combines available or
reserved host memory, Hyper-V pressure, paging, sustained duration, topology, and lab evidence.
The same evidence contract applies to CPU, storage, network, and VM pressure.

## Alert decision flow

```mermaid
flowchart TD
    CONDITION[Detected condition] --> SUPPORTED{Supported and understood?}
    SUPPORTED -->|No| DATA[Research or diagnostic data only]
    SUPPORTED -->|Yes| ACTIONABLE{Operator action exists?}
    ACTIONABLE -->|No| COLLECT[Collect, view, or health-only]
    ACTIONABLE -->|Yes| EXPECTED{Expected during maintenance or transition?}
    EXPECTED -->|Yes| SUPPRESS[Suppress, delay, or reduce impact]
    EXPECTED -->|No| ROOTCAUSE{More specific parent/root cause active?}
    ROOTCAUSE -->|Yes| ROLLUP[Roll up state; suppress duplicate symptom alert]
    ROOTCAUSE -->|No| ALERT[Generate alert at actionable unit monitor]
    ALERT --> KNOW[Attach evidence, impact, validation, remediation, and recovery]

    classDef question fill:#fff7ed,stroke:#ea580c,color:#7c2d12
    classDef quiet fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b
    classDef action fill:#ecfdf5,stroke:#059669,color:#064e3b
    class SUPPORTED,ACTIONABLE,EXPECTED,ROOTCAUSE question
    class DATA,COLLECT,SUPPRESS,ROLLUP quiet
    class ALERT,KNOW action
```

## Alert contract

Every enabled alert-generating workflow must define:

- source object and monitor/rule ID;
- condition, operational impact, and evidence captured in alert parameters;
- severity and priority with a consistent mapping;
- whether the alert auto-resolves, and the exact healthy/reset evidence;
- suppression key and repeat-count behavior for event storms;
- maintenance, migration, backup, checkpoint, drain, and failover behavior;
- probable causes, validation commands or views, remediation, escalation, and recovery verification;
- related performance, event, state, and task views; and
- DA branch and parent impact.

## Dependency and symptom suppression

```mermaid
flowchart TB
    HOST[Host unavailable] --> VM1[VM telemetry missing]
    HOST --> NIC[Host adapter telemetry missing]
    HOST --> VSW[Virtual switch telemetry missing]
    HOST --> ROOT[Compute branch Critical]
    VM1 -. suppress symptom alert .-> HOSTALERT[Host availability alert]
    NIC -. suppress symptom alert .-> HOSTALERT
    VSW -. suppress symptom alert .-> HOSTALERT
    HOST --> HOSTALERT

    classDef cause fill:#fef2f2,stroke:#dc2626,color:#7f1d1d
    classDef symptom fill:#fff7ed,stroke:#ea580c,color:#7c2d12
    classDef outcome fill:#ecfdf5,stroke:#059669,color:#064e3b
    class HOST cause
    class VM1,NIC,VSW symptom
    class ROOT,HOSTALERT outcome
```

Suppression must be implemented only where targeting and correlation are deterministic. When SCOM
cannot safely suppress a symptom, the MP should delay the child condition or provide correlation
knowledge instead of hiding a potentially independent fault.

## Population-aware VM health

```mermaid
flowchart LR
    INVENTORY[VM inventory] --> POLICY[Expected-state classification]
    POLICY --> ACTIONABLE[Actionable VMs]
    POLICY --> EXEMPT[Intentional Off, saved, template, maintenance, or excluded]
    ACTIONABLE --> STATE[Per-VM health]
    STATE --> POP[Population rollup]
    POP --> ABS[Absolute unhealthy count]
    POP --> PCT[Unhealthy percentage]
    ABS --> DECIDE[Warning/Critical policy]
    PCT --> DECIDE
    EXEMPT --> AUDIT[Visible but no default availability penalty]

    classDef input fill:#e8f3ff,stroke:#0078d4,color:#172554
    classDef policy fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b
    classDef outcome fill:#ecfdf5,stroke:#059669,color:#064e3b
    class INVENTORY input
    class POLICY,ACTIONABLE,EXEMPT,ABS,PCT policy
    class STATE,POP,DECIDE,AUDIT outcome
```

An intentionally powered-off VM must not make the DA unhealthy by default. Expected state is an
explicit discovered or configured policy, not a guess based on one sample.

## Rollup defaults

| Scope | Proposed default | Reason |
|---|---|---|
| Unit monitor to dimension | Worst state within that dimension | Preserve the most severe supported condition |
| Dimension to object | Standard SCOM object health behavior | Keep Health Explorer predictable |
| Critical infrastructure child to branch | Worst state | One failed quorum, CSV, or required host dependency can be service-critical |
| Redundant host population | Topology-aware or percentage rollup | One drained node may not equal cluster outage |
| VM population | Expected-state plus absolute and percentage policy | Avoid one intentionally stopped VM poisoning a large service |
| Monitoring pipeline | Worst state with explicit freshness deadlines | Prevent false confidence when telemetry is absent |
| Branch to DA root | Impact-weighted dependency monitors | Availability-critical branches may affect root differently from advisory configuration |

## Monitoring profiles

| Profile | Intended behavior |
|---|---|
| Core | Low-noise availability, data-integrity, and monitoring-pipeline health enabled |
| Balanced | Core plus validated predictive performance and configuration monitoring |
| Deep diagnostic | High-cardinality collection and disabled-by-default monitors enabled selectively |

Profiles are documented override recommendations, not separate sealed runtime products. Customer
changes remain in their unsealed override MP.

## Decision gate

ADR 0029 cannot be accepted until AB#7351–AB#7353 provide threshold evidence, lab fault/recovery
results, noise assessment, VM expected-state policy, and final Must/Should/Could/Collect/Diagnostic
classification.
