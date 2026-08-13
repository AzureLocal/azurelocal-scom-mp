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
| Microsoft verification | All target-version sealed dependency MPs resolve and VSAE `VerifyMergedManagementPack` returns no errors |
| Test sealing | All sealed projects protect successfully in dependency order with a transient development key |
| Clean import | Import order, discovery, workflow initialization, and views succeed |
| Fault/recovery | Compute, storage, Network ATC, registration, platform, update, and pipeline conditions transition and recover |
| Lifecycle | Upgrade, rollback, coexistence, override preservation, and removal behave as documented |
| Scale | Workflow, Operations database, data warehouse, console, and agent overhead stay within the release envelope |
| Release signing | Governed release key, provenance, inventory, checksum, and signed bundle |

All five Azure Local development projects—Library, Discovery, Monitoring, Presentation, and
optional Reporting—pass VSAE verification against the installed OM2022 sealed dependency set and
complete ordered test sealing with a transient development key. This authoring-host evidence does
not replace governed release signing, clean SCOM import, workflow execution, or the representative
SCOM/Azure Local lab gates. Standalone `MPVerify.exe` is not an additional release gate: the
implemented VSAE target invokes the Microsoft SDK verification path directly.
