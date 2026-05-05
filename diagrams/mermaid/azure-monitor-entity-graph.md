# Azure Monitor Entity Graph — Azure Local

> Source: `diagrams/mermaid/azure-monitor-entity-graph.md`
> Embed in docs using the `mermaid` fenced code block.

```mermaid
graph TD
    ROOT["🏢 Root Entity\nAzure Local Workload\n(Generic)"]:::root

    ROOT --> CLUSTER["Azure Local Cluster\n(Generic Entity)"]:::generic

    CLUSTER --> NODE1["Node 1\n(Azure Resource)"]:::resource
    CLUSTER --> NODE2["Node N\n(Azure Resource)"]:::resource
    CLUSTER --> SPOOL["Storage Pool\n(Azure Resource)"]:::resource
    CLUSTER --> NETINT["Network Intent\n(Generic)"]:::generic
    CLUSTER --> ARC["Arc Agent\n(Azure Resource)"]:::resource

    SPOOL --> VOL1["Volume 1\n(Azure Resource)"]:::resource
    SPOOL --> VOL2["Volume N\n(Azure Resource)"]:::resource

    NODE1 --> VM1["VM 1\n(Azure Resource)"]:::resource
    NODE2 --> VM2["VM N\n(Azure Resource)"]:::resource

    NETINT --> NIC1["NIC / RDMA Adapter 1\n(Generic)"]:::generic
    NETINT --> NIC2["NIC / RDMA Adapter N\n(Generic)"]:::generic

    classDef root     fill:#0078D4,color:#fff,stroke:none,font-weight:bold
    classDef generic  fill:#004B8D,color:#fff,stroke:none
    classDef resource fill:#F0F0F0,color:#333,stroke:#999
```

## Signal types per entity

| Entity | Signal type | Example metric / KQL |
|---|---|---|
| Azure Local Cluster | Azure Resource metric | `microsoft.azurestackhci/clusters` health metrics |
| Node | Azure Resource metric | CPU %, memory %, disk I/O |
| Storage Pool | Azure Resource metric | Pool health, operational status |
| Volume | Azure Resource metric | Volume % full, IOPS, latency |
| VM | Azure Resource metric | VM availability, integration services |
| Arc Agent | Log Analytics (KQL) | Heartbeat within last 5 min |
| Network Intent | Log Analytics (KQL) | NIC operational state, RDMA status |
