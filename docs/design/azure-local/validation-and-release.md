---
title: Azure Local validation and release
description: Offline contracts, SDK verification, sealing, signing, and SCOM lab certification.
---

# Azure Local validation and release

Development XML is intentionally marked not release-ready. Promotion requires every applicable gate.

| Gate | Evidence |
|---|---|
| Offline build | Deterministic identities, versions, well-formed XML, no unresolved tokens |
| Product contracts | Independent namespace, class/relationship counts, workflow catalog, DA rollup, views, override generation |
| Static analysis | PowerShell analyzer and unit tests |
| Microsoft SDK | All target-version sealed dependency MPs resolve and TryVerify returns no errors |
| MP verification | MPVerify passes on the governed Windows authoring host |
| Test sealing | All sealed projects protect successfully with the test key |
| Clean import | Import order, discovery, workflow initialization, and views succeed |
| Fault/recovery | Compute, storage, Network ATC, registration, platform, update, and pipeline conditions transition and recover |
| Lifecycle | Upgrade, rollback, coexistence, override preservation, and removal behave as documented |
| Scale | Workflow, Operations database, data warehouse, console, and agent overhead stay within the release envelope |
| Release signing | Governed release key, provenance, inventory, checksum, and signed bundle |

The current repository can complete offline and static gates. Official dependency exports and the
representative SCOM/Azure Local lab are external evidence gates, not missing source-code work.
