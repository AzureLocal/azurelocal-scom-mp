---
title: Hyper-V security and operability
description: Least-privilege execution, Run As design, task safety, monitoring-pipeline health, and supportability for the Hyper-V SCOM product.
---

# Hyper-V security and operability

The default architecture executes local read-only workflows under the agent's existing action
account. A named Run As profile is introduced only when a supported topology requires privileges
that cannot be granted safely to that account. The MP defines profiles but never ships credentials
or automatically binds accounts.

Microsoft documents that rules, monitors, discoveries, and tasks run under an applicable Run As
account and that more-secure distribution limits credentials to specified computers. See
[Run As accounts and profiles](https://learn.microsoft.com/en-us/system-center/scom/plan-security-runas-accounts-profiles?view=sc-om-2025)
and [Manage Run As accounts and profiles](https://learn.microsoft.com/en-us/system-center/scom/manage-security-maintain-runas-profiles?view=sc-om-2025).

## Credential decision flow

```mermaid
flowchart TD
    WORK[Workflow requires data or action] --> LOCAL{Available read-only through the target's default action account?}
    LOCAL -->|Yes| DEFAULT[Use default action account]
    LOCAL -->|No| REQUIRED{Capability required for a supported scenario?}
    REQUIRED -->|No| EXCLUDE[Exclude or make diagnostic-only]
    REQUIRED -->|Yes| LEAST[Define minimum permissions]
    LEAST --> PROFILE[Associate a purpose-specific Run As profile]
    PROFILE --> DIST[Require more-secure distribution to explicit targets]
    DIST --> NEG[Validate allowed and denied test cases]

    classDef question fill:#fff7ed,stroke:#ea580c,color:#7c2d12
    classDef path fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b
    classDef outcome fill:#ecfdf5,stroke:#059669,color:#064e3b
    class LOCAL,REQUIRED question
    class LEAST,PROFILE,DIST path
    class DEFAULT,EXCLUDE,NEG outcome
```

## Proposed execution boundaries

```mermaid
flowchart LR
    subgraph HOST[Hyper-V host]
      AGENT[SCOM HealthService]
      LOCAL[Local Windows, Hyper-V, cluster, event, and performance providers]
      AGENT --> LOCAL
    end

    subgraph MGMT[SCOM management tier]
      RP[Approved resource pool]
      SDK[SCOM SDK and topology]
      RP --> SDK
    end

    subgraph OPTIONAL[Optional management plane]
      VMM[SCVMM or SDN endpoint]
    end

    CONFIG[Run As profile mapping] --> AGENT
    CONFIG --> RP
    RP -. only for accepted topology .-> VMM

    classDef local fill:#ecfdf5,stroke:#059669,color:#064e3b
    classDef management fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b
    classDef optional fill:#fff7ed,stroke:#ea580c,color:#7c2d12
    class AGENT,LOCAL local
    class RP,SDK,CONFIG management
    class VMM optional
```

| Workflow family | Default identity | Escalation policy |
|---|---|---|
| Local discovery and monitoring | Agent default action account | Add no Run As profile unless negative tests prove a required read is unavailable |
| Cluster topology | Agent or approved cluster workflow identity | Minimum remote cluster-provider access only if local ownership cannot supply the view |
| SCVMM/SDN topology | Dedicated optional profile | Scoped only to management servers/resource pools and endpoints in that topology |
| Diagnostic task | Console-supplied or purpose-specific task profile | Read-only by default; explicit operator invocation |
| Recovery task | Separate elevated profile if shipped at all | Disabled by default, auditable, idempotent, and independently approved |

## Task safety classes

```mermaid
flowchart TD
    TASK[Candidate task] --> READ{Read-only?}
    READ -->|Yes| DIAG[Diagnostic task]
    READ -->|No| REV{Reversible and idempotent?}
    REV -->|No| OMIT[Do not ship]
    REV -->|Yes| IMPACT{Can it affect VM, cluster, storage, or network availability?}
    IMPACT -->|Yes| GOVERN[Separate approval; disabled by default; explicit Run As]
    IMPACT -->|No| LIMITED[Constrained recovery with audit output]
    DIAG --> KNOW[Link from product knowledge]
    GOVERN --> KNOW
    LIMITED --> KNOW

    classDef question fill:#fff7ed,stroke:#ea580c,color:#7c2d12
    classDef safe fill:#ecfdf5,stroke:#059669,color:#064e3b
    classDef risky fill:#fef2f2,stroke:#dc2626,color:#7f1d1d
    class READ,REV,IMPACT question
    class DIAG,LIMITED,KNOW safe
    class OMIT,GOVERN risky
```

The first release prioritizes diagnostics over automatic remediation. It must not automatically
restart VMs, move roles, modify quorum, change networking, delete checkpoints, or alter storage.

## Monitoring-pipeline health

```mermaid
flowchart LR
    CONFIG[Configuration received] --> RUN[Workflow executes]
    RUN --> DATA[Valid data produced]
    DATA --> FRESH[Freshness checkpoint updated]
    FRESH --> HEALTHY[Pipeline Healthy]
    CONFIG -->|missing| UNKNOWN[Pipeline Unknown or Critical]
    RUN -->|timeout or exception| FAULT[Workflow fault monitor]
    DATA -->|invalid or duplicate| FAULT
    FRESH -->|deadline exceeded| STALE[Stale-data monitor]
    FAULT --> DEGRADED[Pipeline Warning or Critical]
    STALE --> DEGRADED

    classDef good fill:#ecfdf5,stroke:#059669,color:#064e3b
    classDef process fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b
    classDef bad fill:#fef2f2,stroke:#dc2626,color:#7f1d1d
    class CONFIG,RUN,DATA,FRESH process
    class HEALTHY good
    class UNKNOWN,FAULT,STALE,DEGRADED bad
```

Each DA has a Monitoring pipeline branch covering:

- SCOM agent/HealthService availability and heartbeat;
- discovery success and age for required topology stages;
- monitor/rule script failures, timeouts, and malformed output;
- data freshness for required signal families;
- excessive runtime, event storms, duplicate keys, and object-count limits; and
- optional management-plane connectivity only when that plane is part of the boundary.

## Diagnostic event contract

| Field | Requirement |
|---|---|
| Source | Stable Hyper-V MP event source |
| Event identifier | Allocated by workflow family and documented centrally |
| Level | Information only for explicit debug; Warning/Error for actionable faults |
| Correlation | Workflow ID, target key, execution ID, and provider operation |
| Timing | Start/end duration for expensive workflows; UTC timestamps |
| Error | Sanitized exception type, result code, and bounded message |
| Volume | Suppression/throttling to one event per failure episode where possible |
| Privacy | No credentials, tokens, personal data, or full sensitive configuration dumps |

## Supportability contract

- All required privileges appear in the Management Pack guide by workflow family.
- The default path works without a custom privileged account wherever Windows exposes the required
  data to the agent identity.
- Access denied produces a monitoring-pipeline condition with corrective knowledge; it never causes
  object deletion or a Healthy state.
- Debug logging is disabled by default, bounded in duration and volume, and overrideable by group.
- Every remote endpoint, port, protocol, identity, and credential-distribution target is documented.
- The MP exposes a non-destructive task that collects sanitized configuration, workflow, and
  topology diagnostics for support.
