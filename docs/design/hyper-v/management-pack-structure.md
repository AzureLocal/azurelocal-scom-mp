---
title: Hyper-V Management Pack structure
description: Proposed sealed package decomposition, reference graph, overrides, and release-bundle contract for Hyper-V monitoring.
---

# Hyper-V Management Pack structure

The Hyper-V product is decomposed by responsibility so its model remains stable while monitoring,
presentation, and reporting evolve. Microsoft recommends logically grouping custom elements,
sealing reusable MPs that other MPs reference, and keeping overrides in separate writable MPs.
See [Select a Management Pack file](https://learn.microsoft.com/en-us/system-center/scom/select-management-pack-file?view=sc-om-2025)
and [Create a Management Pack for overrides](https://learn.microsoft.com/en-us/system-center/scom/manage-mp-create-unsealed-mp?view=sc-om-2025).

## Proposed artifact set

`HybridSolutionsCloud.HyperV` is the working namespace. ADR 0027 must accept the final IDs before
any sealed public contract is released.

| Artifact | Form | Responsibility | Required dependencies |
|---|---|---|---|
| `HybridSolutionsCloud.HyperV.Library` | Sealed `.mp` | Classes, properties, relationships, reusable module types, secure references, icons, and core language strings | Approved Microsoft System and Windows libraries only |
| `HybridSolutionsCloud.HyperV.Discovery` | Sealed `.mp` | Seed, role, topology, relationship, DA, and membership discoveries | Hyper-V Library plus approved Windows/cluster libraries |
| `HybridSolutionsCloud.HyperV.Monitoring` | Sealed `.mp` | Unit and aggregate monitors, rules, diagnostics, recoveries, and tasks | Hyper-V Library and Discovery |
| `HybridSolutionsCloud.HyperV.Presentation` | Sealed `.mp` | Folder hierarchy, state, alert, performance, event, task, and diagram views | Hyper-V Library and Monitoring |
| `HybridSolutionsCloud.HyperV.Reporting` | Optional sealed `.mp` or `.mpb` resource | Reports and SLO-oriented presentation content | Hyper-V Library and applicable reporting libraries |
| Customer Discovery Overrides | Customer-owned unsealed `.xml` | Discovery enablement, schedules, timeouts, supported scope, and discovery-targeting groups | Hyper-V Library and Discovery |
| Customer Monitoring Overrides | Customer-owned unsealed `.xml` | Monitor/rule enablement, thresholds, timing, alerts, collection, and monitoring-targeting groups | Hyper-V Library and Monitoring |

The shipped release may combine tightly coupled sealed content into an `.mpb`, but the logical
boundaries and dependency direction remain unchanged.

## Dependency graph

```mermaid
flowchart BT
    SYS[Microsoft System libraries] --> LIB[Hyper-V Library]
    WIN[Approved Windows Server libraries] --> LIB
    CLU[Approved Failover Cluster libraries] --> DISC[Hyper-V Discovery]
    LIB --> DISC
    LIB --> MON[Hyper-V Monitoring]
    DISC --> MON
    LIB --> PRES[Hyper-V Presentation]
    MON --> PRES
    LIB --> REPORT[Hyper-V Reporting]
    MON --> REPORT
    LIB --> DOVR[Customer Discovery Overrides]
    DISC --> DOVR
    LIB --> MOVR[Customer Monitoring Overrides]
    MON --> MOVR

    LEGACY[Microsoft Hyper-V 2019 MP] -. prohibited .-> LIB
    AZL[Azure Local SCOM MPs] -. prohibited .-> LIB

    classDef microsoft fill:#e8f3ff,stroke:#0078d4,color:#172554
    classDef product fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b
    classDef customer fill:#ecfdf5,stroke:#059669,color:#064e3b
    classDef blocked fill:#fef2f2,stroke:#dc2626,color:#7f1d1d
    class SYS,WIN,CLU microsoft
    class LIB,DISC,MON,PRES,REPORT product
    class DOVR,MOVR customer
    class LEGACY,AZL blocked
```

No sealed Hyper-V artifact imports, extends, overrides, or requires the Microsoft Hyper-V 2019 MP
or any Azure Local MP. Referencing approved Microsoft System, Windows Server, and Failover Cluster
libraries is expected where those libraries supply stable platform base classes.

## Why the model is separated

```mermaid
flowchart LR
    MODEL[Stable public model] --> DISC[Topology can evolve]
    MODEL --> MON[Monitoring can evolve]
    MODEL --> UX[Presentation can evolve]
    MODEL --> EXT[Customer overrides and future extensions]
    DISC --> REL[Discovered instances and relationships]
    MON --> STATE[Health, alerts, and collected data]
    UX --> OPS[Operator experience]

    classDef stable fill:#ecfdf5,stroke:#059669,color:#064e3b
    classDef change fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b
    class MODEL stable
    class DISC,MON,UX,EXT,REL,STATE,OPS change
```

The Library is the most expensive artifact to change because other sealed MPs and customer
override MPs can reference its element IDs. Model changes therefore require compatibility review;
monitoring and presentation changes can usually move faster.

## Override ownership

```mermaid
flowchart TD
    DEFAULT[Sealed product defaults] --> EFFECTIVE[Effective monitoring configuration]
    TIER[Lab, Standard, or Strict example] --> ADMIN[SCOM administrator]
    ADMIN --> DOVR[Customer Discovery Overrides]
    ADMIN --> MOVR[Customer Monitoring Overrides]
    DOVR --> EFFECTIVE
    MOVR --> EFFECTIVE
    EFFECTIVE --> TARGETS[Classes, groups, and instances]
    TARGETS --> PROD[Production HealthService configuration]

    classDef sealed fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b
    classDef customer fill:#fff7ed,stroke:#ea580c,color:#7c2d12
    classDef runtime fill:#ecfdf5,stroke:#059669,color:#064e3b
    class DEFAULT,TIER sealed
    class ADMIN,DOVR,MOVR customer
    class EFFECTIVE,TARGETS,PROD runtime
```

The product never writes to the Default Management Pack and never mutates a customer's override
MP. Discovery and Monitoring each have a corresponding customer-owned unsealed override MP.
Microsoft recommends one unsealed override MP for each sealed MP being customized, group targeting
instead of individual-instance overrides where practical, documentation of every override, and
validation in a test environment. See [Best practices for configuring overrides](https://learn.microsoft.com/en-us/troubleshoot/system-center/scom/best-practices-configure-overrides).

Optional Lab, Standard, and Strict templates are public examples only. Customers review, rename,
and copy selected settings into their own unsealed Discovery and Monitoring override MPs. Template
files are not signed product dependencies and are not imported automatically. The complete contract
is defined in [Override and tuning architecture](override-and-tuning-architecture.md).

## Release bundle

```mermaid
flowchart LR
    XML[Authored XML and resources] --> VERIFY[Schema and MP verification]
    VERIFY --> TEST[Test signing]
    TEST --> LAB[Pre-production import and fault tests]
    LAB --> RELEASE[Release signing]
    RELEASE --> BUNDLE[Versioned release bundle]
    BUNDLE --> GUIDE[Guide, catalog, changes, dependencies, and checksums]

    classDef source fill:#f5f3ff,stroke:#7c3aed,color:#3b0764
    classDef gate fill:#fff7ed,stroke:#ea580c,color:#7c2d12
    classDef output fill:#ecfdf5,stroke:#059669,color:#064e3b
    class XML source
    class VERIFY,TEST,LAB,RELEASE gate
    class BUNDLE,GUIDE output
```

Each release bundle must contain:

- sealed and release-signed MPs or MP bundles;
- separate Discovery and Monitoring override starter files for the optional Lab, Standard, and
  Strict profiles, delivered as non-importable public examples;
- the Management Pack guide, support matrix, monitoring catalog, and tuning guidance;
- release notes, dependency/version matrix, checksums, and license;
- import, upgrade, rollback, and removal instructions; and
- machine-readable inventory of artifact, element, and reference versions.

## Versioning rules

- Every shipped artifact in a release uses the same product version unless a documented exception
  is required by the packaging toolchain.
- Element IDs and class keys are immutable after public release unless a versioned migration design
  is accepted.
- Additive changes are preferred. Removing a class, property, relationship, monitor, or rule needs
  impact analysis for historical data, overrides, views, reports, and dependent customer MPs.
- A release never lowers a Management Pack version.
- The release signing identity is stable for the lifetime of the public product line.
- The dependency graph is generated and compared in continuous integration to prevent accidental
  Azure Local or legacy Hyper-V MP references.

## Packaging decision gate

ADR 0027 must resolve these remaining details:

1. exact namespace and display-name prefix;
2. whether Reporting ships in the base bundle or as an optional add-on;
3. exact Microsoft library dependencies and minimum versions;
4. `.mp` versus `.mpb` packaging by artifact;
5. language-pack strategy; and
6. release and test signing identities.
