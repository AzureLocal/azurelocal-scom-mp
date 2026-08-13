---
title: Hyper-V SCOM architecture
description: End-to-end architecture for the Hyper-V SCOM Management Pack, health model, and Distributed Application.
---

# Hyper-V SCOM architecture

The Hyper-V System Center Operations Manager (SCOM) product is an independent, sealed Management
Pack suite that discovers supported standalone hosts and failover clusters, evaluates their health,
and presents one service-oriented Distributed Application (DA) for each monitored boundary. This
page is the architecture map; the linked pages define each contract in implementation detail.

The design follows Microsoft's Management Pack model: classes represent managed objects,
discoveries create their instances, monitors establish health, rules collect or react to data,
Run As profiles provide explicitly assigned credentials, and views, knowledge, reports, and tasks
complete the operator experience. See [What is in an Operations Manager management pack?](https://learn.microsoft.com/en-us/system-center/scom/manage-overview-management-pack?view=sc-om-2025).

## Architecture at a glance

```mermaid
flowchart LR
    ENV[Windows Server estate] --> AGENT[SCOM agents]
    AGENT --> DISC[Discovery plane]
    AGENT --> SIGNAL[Signal acquisition]
    DISC --> MODEL[Hyper-V object model]
    SIGNAL --> HEALTH[Unit monitors and collection rules]
    MODEL --> HEALTH
    HEALTH --> ROLLUP[Aggregate and dependency rollups]
    ROLLUP --> DA[Hyper-V Distributed Application]
    HEALTH --> ALERTS[Actionable alerts and knowledge]
    DA --> UX[Health Explorer, views, reports, SLOs]
    ALERTS --> UX

    classDef source fill:#e8f3ff,stroke:#0078d4,color:#172554
    classDef runtime fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b
    classDef health fill:#ecfdf5,stroke:#059669,color:#064e3b
    classDef output fill:#fff7ed,stroke:#ea580c,color:#7c2d12
    class ENV,AGENT source
    class DISC,SIGNAL,MODEL runtime
    class HEALTH,ROLLUP health
    class DA,ALERTS,UX output
```

## Design goals

- Cover supported standalone Hyper-V hosts, Windows Server Failover Clusters, and explicitly
  approved SCVMM/SDN-managed variants without assuming Azure connectivity.
- Make topology and ownership first-class so alerts identify the affected host, cluster, virtual
  machine (VM), storage, or network component.
- Produce useful health with low alert noise, explicit recovery, maintenance awareness, and no
  silent Healthy state when telemetry is stale.
- Keep agent, management-server, operational-database, and data-warehouse cost within documented
  budgets at the supported maximum scale.
- Ship operator-ready knowledge, views, diagnostics, reports, service-level objective (SLO)
  targets, overrides, upgrade guidance, and self-monitoring.
- Remain independently installable, upgradeable, and removable from the Azure Local SCOM product
  and the Microsoft Hyper-V 2019 Management Pack.

## Architectural planes

```mermaid
flowchart TB
    subgraph AUTHOR[Authoring and delivery plane]
      SRC[Version-controlled fragments and resources]
      BUILD[Schema, reference, naming, and best-practice validation]
      SIGN[Seal, sign, version, and package]
      SRC --> BUILD --> SIGN
    end

    subgraph CONTROL[SCOM control plane]
      IMPORT[Management Pack import]
      CONFIG[Configuration service]
      OVERRIDE[Customer override MP]
      IMPORT --> CONFIG
      OVERRIDE --> CONFIG
    end

    subgraph DATA[Monitored data plane]
      HS[HealthService on Hyper-V hosts]
      LOCAL[Local services, events, counters, CIM and PowerShell]
      CLUSTER[Cluster and topology providers]
      LOCAL --> HS
      CLUSTER --> HS
    end

    subgraph EXPERIENCE[Operator experience plane]
      STATE[Health and alerts]
      DA[Distributed Applications]
      VIEW[Views, reports, dashboards, tasks, and knowledge]
      STATE --> DA --> VIEW
    end

    SIGN --> IMPORT
    CONFIG --> HS
    HS --> STATE

    classDef author fill:#f5f3ff,stroke:#7c3aed,color:#3b0764
    classDef control fill:#eff6ff,stroke:#2563eb,color:#172554
    classDef data fill:#ecfeff,stroke:#0891b2,color:#164e63
    classDef experience fill:#f0fdf4,stroke:#16a34a,color:#14532d
    class SRC,BUILD,SIGN author
    class IMPORT,CONFIG,OVERRIDE control
    class HS,LOCAL,CLUSTER data
    class STATE,DA,VIEW experience
```

## Supported topology shapes

The architecture supports multiple shapes through explicit topology classification. Optional
branches are discovered only when their authority and prerequisites are proven.

```mermaid
flowchart TD
    SEED[Windows Server with Hyper-V role] --> Q{Cluster member?}
    Q -->|No| STANDALONE[Standalone-host boundary]
    Q -->|Yes| CLUSTER[Failover-cluster boundary]
    CLUSTER --> N{Network authority?}
    N -->|Network ATC| ATC[Network ATC topology]
    N -->|SCVMM and SDN| SDN[SCVMM/SDN topology]
    N -->|Neither| MANUAL[Manual networking topology]
    STANDALONE --> DA1[One host DA]
    ATC --> DA2[One cluster DA]
    SDN --> DA2
    MANUAL --> DA2

    classDef decision fill:#fff7ed,stroke:#ea580c,color:#7c2d12
    classDef topology fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b
    classDef service fill:#ecfdf5,stroke:#059669,color:#064e3b
    class Q,N decision
    class SEED,STANDALONE,CLUSTER,ATC,SDN,MANUAL topology
    class DA1,DA2 service
```

Network ATC is the preferred baseline for eligible Windows Server 2025 Datacenter Hyper-V
clusters unless SCVMM/SDN is the selected authority. The MP must never populate overlapping network
authorities into one DA branch.

## Runtime data flow

```mermaid
sequenceDiagram
    participant C as SCOM configuration service
    participant A as Host HealthService
    participant P as Windows and Hyper-V providers
    participant M as Monitor or rule
    participant D as SCOM databases
    participant O as Operator surface

    C->>A: Deliver only applicable MP configuration
    A->>P: Query local or authoritative topology and signals
    P-->>A: Typed discovery or property-bag data
    A->>M: Execute data source and condition detection
    alt Stateful condition
      M->>D: Commit monitor state and optional alert
    else Collection or event rule
      M->>D: Commit performance or event data
    end
    D->>O: Present health, alert, trend, report, and DA rollup
```

## Document map

| Contract | Design document |
|---|---|
| Product boundaries, requirements, and runtime planes | This page |
| Sealed MP decomposition and dependency graph | [Management Pack structure](management-pack-structure.md) |
| Classes, keys, hosting, containment, and mobility | [Class and relationship model](class-and-relationship-model.md) |
| Staged discovery, data sources, cookdown, and workflow placement | [Discovery and workflow architecture](discovery-and-workflow-architecture.md) |
| Health dimensions, state, alerting, recovery, and suppression | [Health and alert architecture](health-and-alert-architecture.md) |
| Service roots, DA membership, and dependency rollup | [Distributed Application](distributed-application.md) |
| Naming, localization, knowledge, overrides, and authoring rules | [Authoring standards](authoring-standards.md) |
| Least privilege, execution boundaries, and self-observability | [Security and operability](security-and-operability.md) |
| Static, lab, scale, lifecycle, and release gates | [Validation and release](validation-and-release.md) |

## Non-functional requirements

| Attribute | Required design behavior | Acceptance evidence |
|---|---|---|
| Reliability | No single script failure may falsely mark the platform Healthy | Fault injection and stale-data tests |
| Scale | Workflow and data-volume budgets defined by target class and interval | Maximum-fixture performance test |
| Performance | Expensive providers queried once and shared through cookdown where safe | Workflow trace and HealthService measurements |
| Security | Local least privilege first; explicit Run As only where proven necessary | Permission matrix and negative-access tests |
| Maintainability | Stable IDs, modular fragments, product knowledge, and traceable catalog rows | Static analysis and design review |
| Upgrade safety | Stable class keys and element IDs; additive change preferred | In-place upgrade and override-preservation tests |
| Operability | Every alert explains impact, evidence, validation, remediation, and recovery | Knowledge-content quality gate |
| Portability | No Azure Local or legacy Hyper-V MP runtime dependency | Reference-graph and side-by-side import tests |

## Decision status

This is a **proposed implementation baseline**. ADRs 0022, 0025, and 0026 are already accepted.
The package, object/discovery, and health/DA refinements in ADRs 0027–0029 remain proposed until the
research and lab gates provide supporting evidence. Proposed identifiers may be refined;
the product boundaries and independent Hyper-V DA requirement may not.
