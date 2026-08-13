---
title: Hyper-V class and relationship model
description: Hyper-V SCOM classes, stable keys, hosting boundaries, containment, reference relationships, and VM mobility behavior.
---

# Hyper-V class and relationship model

The object model must represent operational ownership without making transient placement part of an
object's identity. A VM can move between cluster nodes; its SCOM identity must survive that move.
A host adapter cannot move between computers; its identity can be hosted by the host. This distinction
drives class keys, hosting, relationship discovery, workflow placement, and upgrade safety.

ADR 0028 accepts the namespace and identity strategy. The functional development Library MP now
implements the first-release model; lab migration, scale, and upgrade tests remain release gates.

## Conceptual object model

```mermaid
classDiagram
    class Deployment {
      +BoundaryId
      +BoundaryType
      +DisplayName
    }
    class Cluster {
      +ClusterId
      +FunctionalLevel
    }
    class Host {
      +PrincipalName
      +HostId
      +RoleVersion
    }
    class VirtualMachine {
      +VMId
      +ExpectedState
      +ConfigurationVersion
    }
    class ClusterSharedVolume {
      +VolumeId
      +Path
    }
    class VirtualDisk {
      +DiskId
      +Path
    }
    class VirtualSwitch {
      +SwitchId
      +Name
    }
    class NetworkAdapter {
      +AdapterId
      +InterfaceGuid
    }
    class ReplicaRelationship {
      +RelationshipId
      +Mode
    }
    class MonitoringPipeline {
      +BoundaryId
      +FreshnessState
    }

    Deployment "1" *-- "0..1" Cluster : contains
    Deployment "1" *-- "1..*" Host : contains
    Deployment "1" *-- "0..*" VirtualMachine : contains
    Cluster "1" *-- "0..*" ClusterSharedVolume : contains
    VirtualMachine "1" *-- "0..*" VirtualDisk : owns
    Host "1" *-- "0..*" VirtualSwitch : hosts
    Host "1" *-- "0..*" NetworkAdapter : hosts
    VirtualMachine "0..*" --> "0..1" Host : currently runs on
    VirtualMachine "0..*" --> "0..*" ReplicaRelationship : participates in
    Deployment "1" *-- "1" MonitoringPipeline : contains
```

This is a service model, not a promise to discover every possible child by default. High-cardinality
classes such as virtual disks and VM network adapters require an explicit catalog and scale decision.

## Class categories

| Category | Candidate classes | Identity and placement rule |
|---|---|---|
| Service boundary | Deployment, Cluster, Standalone Host Boundary | Stable cluster identity or host principal name; never a display name alone |
| Compute | Hyper-V Host Role, Cluster Node, VM | Host follows Windows computer; VM uses Hyper-V VM GUID and is contained by the stable boundary |
| Cluster | Cluster, Quorum, Clustered Role, Cluster Resource, Cluster Network | Prefer stable cluster identifiers and approved Microsoft cluster base types where supportable |
| Storage | CSV, volume, virtual disk, VHD/VHDX, storage path, Replica relationship | Keys use provider IDs or canonical paths with documented normalization |
| Network | Physical adapter, switch, port, VM adapter, Network ATC intent, SDN authority | Host-local components are hosted by host; authority objects are scoped to the boundary |
| Management | SCVMM management relationship, Network Controller dependency | Reference relationships only when the topology selects that authority |
| Monitoring | Boundary monitoring pipeline and discovery freshness | One platform-owned instance per DA boundary |

## Identity decision tree

```mermaid
flowchart TD
    ENTITY[Candidate monitored entity] --> MOVE{Can it move between hosts?}
    MOVE -->|Yes| BOUNDARY[Key within stable cluster or deployment boundary]
    MOVE -->|No| EXIST{Does it cease to exist with its host?}
    EXIST -->|Yes| HOSTED[Host it under the Windows computer or host role]
    EXIST -->|No| GLOBAL{Does the provider expose a stable global ID?}
    GLOBAL -->|Yes| UNHOSTED[Use unhosted or boundary-contained identity]
    GLOBAL -->|No| COMPOSITE[Define and validate a normalized composite key]
    BOUNDARY --> PROVIDER[Prefer provider GUID over name or path]
    HOSTED --> PROVIDER
    UNHOSTED --> PROVIDER
    COMPOSITE --> TEST[Prove rename, move, failover, upgrade, and rediscovery behavior]
    PROVIDER --> TEST

    classDef question fill:#fff7ed,stroke:#ea580c,color:#7c2d12
    classDef answer fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b
    classDef gate fill:#ecfdf5,stroke:#059669,color:#064e3b
    class MOVE,EXIST,GLOBAL question
    class BOUNDARY,HOSTED,UNHOSTED,COMPOSITE,PROVIDER answer
    class TEST gate
```

## VM mobility contract

```mermaid
sequenceDiagram
    participant C as Cluster boundary
    participant H1 as Host A
    participant VM as VM object keyed by VMId
    participant H2 as Host B
    participant D as Relationship discovery

    C->>VM: Contains stable VM instance
    H1->>VM: Current placement relationship
    Note over VM: Health history and overrides remain attached
    H1-->>H2: Live migration
    D->>VM: Remove Host A placement
    D->>VM: Add Host B placement
    H2->>VM: Current placement relationship
    Note over VM: No delete and recreate of the VM instance
```

The VM is not hosted by a cluster node. Hosting it by a node would change its SCOM identity when it
moves and could orphan health history, alerts, relationships, and overrides.

## Relationship semantics

```mermaid
flowchart LR
    HOSTING[Hosting relationship] --> LIFE[Child existence and workflow execution follow one parent]
    CONTAIN[Containment relationship] --> SERVICE[Logical ownership and DA membership]
    REFERENCE[Reference relationship] --> DEP[Dependency or current placement without lifecycle ownership]
    LIFE --> LOCAL[Host-local services, adapters, and switches]
    SERVICE --> BOUNDARY[Deployment, cluster, and DA component groups]
    DEP --> MOBILE[VM placement, Replica, and management-plane dependencies]

    classDef relation fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b
    classDef effect fill:#ecfdf5,stroke:#059669,color:#064e3b
    class HOSTING,CONTAIN,REFERENCE relation
    class LIFE,SERVICE,DEP,LOCAL,BOUNDARY,MOBILE effect
```

| Relationship | Use | Do not use for |
|---|---|---|
| Hosting | A child truly exists on one parent and workflows must execute there | Mobile VMs, cross-node cluster objects, or presentation-only grouping |
| Containment | A boundary or component group owns members for service modeling | Inferring where a workflow can execute |
| Reference | Current placement, Replica pairing, external authority, or another non-lifecycle dependency | Deleting a child when a source disappears |

## Candidate keys

| Entity | Preferred key | Fallback requiring proof | Never use alone |
|---|---|---|---|
| Failover cluster | Stable cluster/provider ID | Canonical cluster fully qualified domain name | Friendly display name |
| Standalone boundary | Windows computer principal name plus role identity | Machine GUID with rename migration plan | NetBIOS name only |
| VM | Hyper-V VM GUID | None unless Microsoft changes the provider contract | VM name or current host |
| CSV | Cluster-scoped volume unique ID | Normalized CSV path plus cluster key | Owner node or drive label |
| Virtual switch | Host key plus switch GUID | Host key plus invariant provider name | Display name without host |
| Physical adapter | Host key plus interface GUID | Host key plus permanent hardware identifier | Interface index alone |
| Replica | Source VM ID plus target relationship/provider ID | Normalized endpoint tuple | Friendly replication name |

## Class modeling rules

- Model only entities that need independent health, targeting, properties, relationships, views,
  overrides, or lifecycle. A property bag is preferable when a first-class object adds no value.
- Target workflows at the narrowest stable class that owns the signal.
- Keep class properties small, stable, operationally meaningful, and safe to store. Do not store
  rapidly changing measurements as properties.
- Every discovered class has a deterministic display name and every public property has a localized
  display string.
- Never use a mutable friendly name as the sole key.
- Avoid deep hosting chains; each level increases identity, discovery, and workflow complexity.
- Separate current placement from identity for every mobile or failover-capable object.
- Explicitly document whether disappearance means deletion, stale topology, monitoring failure, or
  temporary unavailability.

## Boundary variants

```mermaid
flowchart TB
    subgraph STANDALONE[Standalone boundary]
      SD[Deployment]
      SH[Host role]
      SVM[VMs]
      SNET[Host networking]
      SSTO[Local and external storage]
      SD --> SH
      SD --> SVM
      SD --> SNET
      SD --> SSTO
    end

    subgraph CLUSTERED[Cluster boundary]
      CD[Deployment]
      CC[Cluster]
      CH[Nodes]
      CVM[Clustered VMs]
      CCSV[CSVs and shared storage]
      CNET[Selected network authority]
      CD --> CC
      CC --> CH
      CC --> CVM
      CC --> CCSV
      CC --> CNET
    end

    classDef root fill:#fff7ed,stroke:#ea580c,color:#7c2d12
    classDef member fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b
    class SD,CD root
    class SH,SVM,SNET,SSTO,CC,CH,CVM,CCSV,CNET member
```

## Release-validation gates

Before the first signed release, topology and lab research must prove:

1. the stable key for every supported entity;
2. the appropriate Microsoft base class and library dependency;
3. workflow execution location for hosted, unhosted, and cluster-owned objects;
4. deletion and rediscovery behavior during rename, live migration, failover, drain, and role removal;
5. scale/cardinality for optional child classes; and
6. whether SCVMM/SDN objects are modeled directly or represented as external dependencies.
