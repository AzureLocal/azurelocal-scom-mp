---
title: Azure Local SCOM monitoring catalog
description: Implemented development workflows and their current default behavior.
---

# Azure Local SCOM monitoring catalog

This catalog describes the authored development baseline. The suite passes Microsoft VSAE/SDK
verification and transient test sealing, but it is not yet governed-release-signed or
lab-certified.

## State monitors

| Monitor | DA domain | Alert | Default |
|---|---|---:|---|
| Cluster Service | Compute | Yes | Enabled |
| Cluster node membership | Compute | Yes | Enabled |
| Quorum | Compute | Yes | Enabled |
| CPU pressure | Compute | No | Enabled, provisional thresholds |
| Available memory | Compute | No | Enabled, provisional thresholds |
| Health Service faults | Storage | Yes | Enabled |
| Storage pool | Storage | Yes | Enabled |
| Volume and CSV | Storage | Yes | Enabled, provisional capacity thresholds |
| Physical disk aggregate | Storage | No | Enabled |
| Network ATC | Network | Yes | Enabled |
| Registration and connection | Azure Integration | Yes | Enabled |
| Arc/MOC platform services | Azure Integration | Yes | Enabled |
| Solution update | Lifecycle | Yes | Enabled |
| Monitoring pipeline | Monitoring Pipeline | Yes | Enabled |

All monitor-generated alerts auto-resolve. CPU, memory, and disk aggregate remain visible in Health
Explorer without default paging.

## Performance rules

Enabled: processor load, available memory, network throughput, physical-disk read/write throughput,
physical-disk read/write latency, and logical-disk free percentage.

Disabled starter collections: network output queue, physical-disk queue length, CSV read throughput,
and CSV write throughput. Enable them only after verifying counter existence, cardinality, and
database cost.

## Event rules

Events 1135, 1069/1205, 5120, and 5142 from Microsoft-Windows-FailoverClustering create suppressed
alerts with the original event description.

## Operator surface

The Presentation MP contains service, node, deployment, pool, volume, disk, Network ATC, update,
Arc integration, resource bridge, pipeline, active alert, performance, and event views.
