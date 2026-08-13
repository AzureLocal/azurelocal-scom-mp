---
title: Integrations
description: Optional integrations for Hybrid Infrastructure Health Monitoring solutions.
---

# Integrations

Integrations are optional solution-owned delivery layers. They consume supported alerts, health,
metrics, and topology from a SCOM Management Pack or Azure Monitor Health Models solution without
becoming a runtime dependency of that solution.

| Integration | SCOM path | Azure Monitor path | Status |
|---|---|---|---|
| [ServiceNow](servicenow.md) | Existing ServiceNow SCOM Events connector plus implemented product profiles, mapping, and offline validation; Metrics optional | Secure Webhook/common-alert-schema design; optional Logic Apps enrichment | SCOM configuration baseline complete, live lab pending; Azure Monitor implementation pending |

An integration must preserve the independent Azure Local and Hyper-V product boundaries. Shared
field semantics and test fixtures are allowed; shared runtime packages that couple releases are not.
