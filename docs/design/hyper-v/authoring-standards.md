---
title: Hyper-V Management Pack authoring standards
description: Authoring conventions for IDs, display strings, knowledge, overrides, scripts, modules, localization, and maintainable SCOM XML.
---

# Hyper-V Management Pack authoring standards

These rules turn the architecture into consistent, supportable Management Pack XML. They apply to
every Hyper-V class, relationship, discovery, module type, monitor, rule, task, view, report, and
language resource.

## Element naming

```mermaid
flowchart LR
    NS[HybridSolutionsCloud.HyperV] --> DOMAIN[Domain]
    DOMAIN --> ENTITY[Entity or scenario]
    ENTITY --> KIND[Element kind]
    KIND --> QUAL[Optional qualifier]
    QUAL --> ID[Stable dot-separated element ID]

    classDef part fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b
    classDef result fill:#ecfdf5,stroke:#059669,color:#064e3b
    class NS,DOMAIN,ENTITY,KIND,QUAL part
    class ID result
```

Working examples:

| Element | Working ID pattern |
|---|---|
| Class | `HybridSolutionsCloud.HyperV.VirtualMachine` |
| Relationship | `HybridSolutionsCloud.HyperV.Deployment.Contains.VirtualMachine` |
| Discovery | `HybridSolutionsCloud.HyperV.VirtualMachine.Discovery` |
| Unit monitor | `HybridSolutionsCloud.HyperV.VirtualMachine.RuntimeState.Monitor` |
| Collection rule | `HybridSolutionsCloud.HyperV.Host.LogicalProcessorRuntime.Collection` |
| Task | `HybridSolutionsCloud.HyperV.Host.CollectDiagnostics.Task` |
| View | `HybridSolutionsCloud.HyperV.VirtualMachine.State.View` |

IDs describe semantics, not implementation mechanics. Do not include script names, ticket numbers,
temporary version labels, or mutable threshold values in public IDs.

## Display strings and knowledge

Microsoft identifies knowledge, views, reports, tasks, monitors, rules, and discoveries as core MP
content. Every operator-visible element therefore needs a localized display string and useful
description. Product knowledge must explain the condition without requiring the author to be
present. See [Add knowledge to a Management Pack](https://learn.microsoft.com/en-us/system-center/scom/manage-mp-add-knowledge?view=sc-om-2025).

```mermaid
flowchart TD
    ALERT[Alert or unhealthy monitor] --> SUMMARY[What happened]
    SUMMARY --> IMPACT[Why it matters]
    IMPACT --> EVIDENCE[Evidence and affected object]
    EVIDENCE --> CAUSE[Probable causes]
    CAUSE --> VERIFY[Validation steps]
    VERIFY --> FIX[Remediation and escalation]
    FIX --> RECOVER[How to verify recovery]
    RECOVER --> RELATED[Related views, tasks, and reports]

    classDef step fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b
    classDef finish fill:#ecfdf5,stroke:#059669,color:#064e3b
    class ALERT,SUMMARY,IMPACT,EVIDENCE,CAUSE,VERIFY,FIX,RECOVER step
    class RELATED finish
```

Required conventions:

- Use concise sentence-case display names and descriptions that identify the target and behavior.
- Localize every visible string through language packs; do not embed operator text only in scripts.
- Alert descriptions include discovered context through safe parameters, never credentials or
  sensitive configuration.
- Product knowledge distinguishes platform remediation from guest/application remediation.
- Company-specific procedures belong in customer company knowledge or their override/documentation
  process, not in the sealed product MP.

## Override design

```mermaid
flowchart TD
    PARAM[Candidate override parameter] --> SAFE{Can changing it preserve valid semantics?}
    SAFE -->|No| FIXED[Keep internal]
    SAFE -->|Yes| USEFUL{Does an operator have a realistic tuning need?}
    USEFUL -->|No| FIXED
    USEFUL -->|Yes| DOC[Expose with units, range, default, and effect]
    DOC --> TEST[Test class, group, and instance overrides]
    TEST --> SHIP[Document in monitoring catalog]

    classDef question fill:#fff7ed,stroke:#ea580c,color:#7c2d12
    classDef internal fill:#f3f4f6,stroke:#6b7280,color:#111827
    classDef output fill:#ecfdf5,stroke:#059669,color:#064e3b
    class SAFE,USEFUL question
    class FIXED internal
    class DOC,TEST,SHIP output
```

- All threshold, interval, sample-count, timeout, severity, priority, and enabled-state overrides
  use documented units and safe ranges.
- Related workflows expose matching parameters consistently.
- The guide recommends group-based overrides for policy tiers and explains when class or instance
  targeting is justified.
- Discovery overrideable parameters are documented separately from monitor/rule overrideable
  parameters and stored in their corresponding customer-owned override MPs.
- Lab, Standard, and Strict examples contain only reviewed settings for the matching product
  version; they never contain customer identity, credentials, or notification destinations.
- No workflow stores changes in the Default Management Pack.
- Override compatibility is an explicit upgrade test.

Microsoft's override guidance calls for a separate MP, deliberate `Enabled=False` overrides instead
of an ambiguous console disable operation, group targeting where practical, and test-environment
validation. See [Best practices for configuring overrides](https://learn.microsoft.com/en-us/troubleshoot/system-center/scom/best-practices-configure-overrides).

The full parameter, ownership, targeting, template, and lifecycle contract is defined in
[Override and tuning architecture](override-and-tuning-architecture.md).

## Module and script standards

| Concern | Required rule |
|---|---|
| Reuse | Repeated acquisition and state logic becomes a typed composite module with a reviewed contract |
| Cookdown | Identical expensive acquisition uses identical module configuration; test actual cookdown |
| Input | Validate nulls, types, ranges, duplicate keys, escaping, and unsupported provider versions |
| Output | Emit typed discovery data or property bags with stable field names and units |
| Errors | Fail explicitly, emit throttled diagnostic evidence, and surface stale telemetry |
| Timeout | Every external call and script has a bounded timeout below its schedule interval |
| Logging | Structured source, workflow ID, target, duration, result code, and correlation identifier |
| Secrets | Never accept, print, serialize, or alert on credentials or secret values |
| Side effects | Discoveries, monitors, and collection rules are read-only; recovery actions are separate and explicit |
| Runtime | PowerShell engine/version and module prerequisites must be proven in the supported SCOM agent matrix |

The repository's automation scripts remain PowerShell 7+. Embedded SCOM workflow scripts are not
authored until runtime research proves the supported host engine. If SCOM cannot execute the governed runtime
directly, ADR 0028 must select a supportable execution mechanism rather than silently introducing a
Windows PowerShell dependency.

## Authoring source layout

```mermaid
flowchart TB
    FRAG[Small scenario-focused fragments] --> COMPOSE[Deterministic composition]
    RES[Scripts, icons, reports, and language resources] --> COMPOSE
    CATALOG[Monitoring catalog IDs and defaults] --> GENERATE[Generated constants and validation data]
    GENERATE --> COMPOSE
    COMPOSE --> XML[Reviewable Management Pack XML]
    XML --> VERIFY[Schema, references, aliases, strings, and best-practice checks]

    classDef input fill:#f5f3ff,stroke:#7c3aed,color:#3b0764
    classDef process fill:#eef2ff,stroke:#4f46e5,color:#1e1b4b
    classDef output fill:#ecfdf5,stroke:#059669,color:#064e3b
    class FRAG,RES,CATALOG input
    class COMPOSE,GENERATE process
    class XML,VERIFY output
```

Fragments are source organization, not permission to copy community XML without review. Useful
patterns from Microsoft's legacy Hyper-V MP, Kevin Holman's fragment library, or Silect material
must be traced, revalidated, renamed into this product, and tested against the supported matrix.

## Definition of done for an element

An element is not complete until it has:

1. a stable ID and localized display string;
2. a narrow target and documented execution location;
3. source semantics, units, supported versions, and topology applicability;
4. safe defaults and overrides with range validation;
5. product knowledge and related diagnostic surfaces;
6. cookdown, security, scale, failure, and stale-data analysis;
7. normal, negative, transition, and upgrade fixtures; and
8. a traceable monitoring-catalog row and work item.
