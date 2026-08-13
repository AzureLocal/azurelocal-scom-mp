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
| [ServiceNow](servicenow.md) | SCOM Events connector; optional Metrics connector | Secure Webhook action group; optional Logic Apps enrichment | Later — research and proof of concept |

An integration must preserve the independent Azure Local and Hyper-V product boundaries. Shared
field semantics and test fixtures are allowed; shared runtime packages that couple releases are not.
