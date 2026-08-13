---
title: Azure Local Azure Monitor architecture
description: Azure Monitor Health Model resource, identity, entity, signal, relationship, alert, and investigation architecture for Azure Local.
---

# Azure Local Azure Monitor architecture

The Azure Monitor solution is a separate cloud product. It does not import SCOM state, reference an
SCOM Management Pack, or require SCOM to operate. Comparable domain names help operators move
between the products without creating a runtime dependency.

## Resource graph

```text
Microsoft.Monitor/accounts
└── healthmodels (system-assigned identity)
    ├── authenticationsettings/system-assigned-identity
    ├── signaldefinitions/
    │   ├── azure-local-cluster-cpu
    │   └── azure-local-storage-degraded
    ├── entities/
    │   ├── root (service-created)
    │   └── azure-local-deployment
    │       ├── compute-component
    │       │   └── azure-local-cluster-compute
    │       ├── storage-component
    │       │   └── azure-local-cluster-storage
    │       ├── network-component
    │       ├── azure-integration-component
    │       ├── lifecycle-component
    │       └── monitoring-pipeline-component
    └── relationships/ (root and dependency edges)
```

The development baseline intentionally starts with a sparse, verifiable signal graph. It is safer
to show Unknown or incomplete preview coverage than to create a polished model from undocumented
tables or guessed metrics.

## Evaluation flow

1. Azure Local Telemetry and Diagnostics publishes documented platform metrics.
2. The Health Model managed identity reads the authorized Azure resource signals.
3. Signal definitions convert metric values into Healthy, Degraded, Unhealthy, or Unknown.
4. Relationships propagate child state with worst-of semantics.
5. The deployment entity creates state-based alerts through configured Action Groups.
6. The workbook supports investigation; it does not define authoritative health.

## Security boundary

- The template contains no tenant, subscription, credential, or endpoint secret.
- The Health Model uses a system-assigned managed identity.
- Operators grant the identity only the data-source permissions required at the actual cluster and
  workspace scopes.
- Action Groups are supplied by resource ID and remain customer-owned.
- Public network access is explicit in the development template and must be reviewed against the
  target environment's network design before production deployment.

## Release gates

- supported region and provider registration;
- Bicep build and subscription-level what-if;
- deployment and deterministic teardown;
- identity and least-privilege access to every signal source;
- exact metric namespace/name/dimension verification;
- Unknown and telemetry-freshness behavior;
- fault, propagation, alert, and recovery evidence;
- cost, query, evaluation, and cardinality measurements; and
- preview API change review.

See [ADR 0036](../decisions/0036-azure-local-azure-monitor-health-model-v1.md) and the
[research record](../../azure-monitor/research.md).
