---
title: Azure Local class and relationship model
description: Stable identity, hosting, topology, and Distributed Application membership.
---

# Azure Local class and relationship model

![Azure Local class model](/assets/diagrams/azure-local-scom-class-model.svg)

## Core classes

| Class | Hosting and keys | Purpose |
|---|---|---|
| NodeRole | Hosted by Windows Computer | Workflow target and node facts |
| Deployment | Unhosted; cluster identifier | Stable cluster boundary |
| StoragePool | Unhosted; deployment plus pool ID | Pool inventory and capacity |
| Volume | Unhosted; deployment plus volume ID | Volume/CSV identity, capacity, owner, redirection |
| PhysicalDisk | Unhosted; deployment plus unique disk ID | Serial, media, location, health, capacity |
| NetworkAtcIntent | Node-hosted; intent name | Per-node intent convergence |
| UpdateState | Unhosted; deployment plus update resource ID | Solution update inventory and state |
| ArcIntegration | Node-hosted singleton | Registration, connection, Arc services |
| ResourceBridge | Node-hosted singleton when present | Local VM-management infrastructure presence and service state |
| MonitoringPipeline | Node-hosted singleton | Discovery freshness and acquisition health |
| Service | Service Designer service | Deployment-level Distributed Application root |

Six Service Designer component classes own Compute, Storage, Network, Azure Integration, Lifecycle,
and Monitoring Pipeline branches.

## Identity behavior

Each node contributes the same deployment-scoped keys for cluster-wide objects. SCOM reconciles
those contributions into one logical object while node-hosted state remains attached to the correct
Windows computer. Lab certification must verify reconciliation, grooming, owner changes, node
replacement, and upgrade behavior.

## Scope boundary

Guest operating systems, customer applications, and general VM health are outside this MP. Azure
Local infrastructure VMs and platform services appear only to the extent required to evaluate the
Azure Local platform.
