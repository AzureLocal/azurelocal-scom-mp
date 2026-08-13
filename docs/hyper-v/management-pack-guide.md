---
title: Hyper-V Management Pack administration guide
description: Public operator guide for building, installing, validating, tuning, upgrading, and removing the Hyper-V SCOM Management Pack.
---

# Hyper-V Management Pack administration guide

This guide explains how the Hyper-V SCOM Management Pack is built, installed, tuned, and
maintained. Functional development XML is available; no sealed and signed product package has been
released yet. Microsoft VSAE/SDK verification and ordered transient test sealing pass for the full
five-project suite. A release remains blocked until clean SCOM lab import, runtime, fault/recovery,
scale, lifecycle, and governed release-signing gates pass.

## What customers will receive

| Deliverable | Purpose |
|---|---|
| Sealed product MPs | Library, Discovery, Monitoring, Presentation, and optional Reporting content |
| Management Pack guide | Prerequisites, import, verification, tuning, upgrade, rollback, removal, and troubleshooting |
| Monitoring catalog | Workflow IDs, targets, defaults, overrideable parameters, knowledge, and evidence |
| Override starter files | Generator and separate customer-owned Discovery and Monitoring output for Lab, Standard, and Strict |
| Release record | Version matrix, dependencies, checksums, changes, known issues, and profile changes |

The sealed MPs are product-owned. Every active override is stored in customer-owned, unsealed XML.

## Before installation

1. Confirm that the SCOM, Windows Server, Hyper-V, Failover Clustering, networking, storage, and
   optional System Center Virtual Machine Manager versions appear in the release support matrix.
2. Confirm that required Microsoft Management Pack libraries and minimum versions are installed.
3. Review the monitoring catalog, default-enabled workflows, expected data volume, and known issues.
4. Export and archive existing customer Management Packs and record the current management-group
   configuration.
5. Test the release in a representative pre-production SCOM management group.

Do not use a production management group as the first import target.

## Install the sealed product MPs

For the first installation, import the sealed artifacts in dependency order:

1. Hyper-V Library;
2. Hyper-V Discovery;
3. Hyper-V Monitoring;
4. Hyper-V Presentation; and
5. optional Hyper-V Reporting.

If a release uses a Management Pack bundle, the release record will state which dependencies remain
separate prerequisites. Use the Operations Manager import review to resolve every dependency before
committing the import. Do not import any customer override MP until its referenced sealed MP is
present.

Microsoft documents the console and shell procedures in
[Import, export, and remove a Management Pack](https://learn.microsoft.com/en-us/system-center/scom/manage-mp-import-remove-delete?view=sc-om-2025).

## Verify the initial import

Wait for configuration distribution and then verify:

- the expected standalone hosts or clusters are discovered once with stable identity;
- host, cluster, virtual machine, storage, and network relationships match the approved topology;
- each Hyper-V Distributed Application has the expected dynamic membership;
- monitoring-pipeline health is not stale or failed;
- state, alert, performance, event, task, and diagram views open without errors; and
- HealthService, operational database, data warehouse, and alert volumes remain within the release
  budget.

Do not compensate for missing or duplicate topology by changing monitoring thresholds. Resolve the
discovery problem first.

## Create customer override MPs

Create two unsealed Management Packs in the Operations console:

| Customer-owned MP | Stores |
|---|---|
| `<Organization>.HybridSolutionsCloud.HyperV.Discovery.Overrides` | Discovery enablement, schedules, timeouts, supported scope settings, and discovery-targeting groups |
| `<Organization>.HybridSolutionsCloud.HyperV.Monitoring.Overrides` | Monitor/rule enablement, thresholds, timing, alerts, collection settings, and monitoring-targeting groups |

In the Administration workspace, right-click **Management Packs**, select **Create Management
Pack**, and assign the organization's approved ID, display name, version, and description. The
destination file must be customer-owned and unsealed.

Never select the Default Management Pack. Microsoft states that installed unsealed system MPs
should not be used for customer settings and recommends a dedicated unsealed override MP for each
sealed MP being customized. See
[Create a Management Pack for overrides](https://learn.microsoft.com/en-us/system-center/scom/manage-mp-create-unsealed-mp?view=sc-om-2025).

## Create a discovery override

1. In the Authoring workspace, open **Management Pack Objects** and **Object Discoveries**.
2. Locate the documented Hyper-V discovery by its display name and stable workflow ID.
3. Choose the appropriate class, group, or specific object target.
4. Select only the parameters that must change and keep every value inside its documented range.
5. Save the change to the customer Discovery Overrides MP.
6. Allow configuration to distribute, then validate discovery data, relationships, DA membership,
   workflow health, and execution cost.
7. Export and archive the approved override MP.

To disable a discovery, create an explicit `Enabled = False` override in the Discovery Overrides MP.
Do not assume already discovered objects will disappear. Review Microsoft's
[object-discovery override guidance](https://learn.microsoft.com/en-us/system-center/scom/manage-apply-overrides-object-discovery?view=sc-om-2025)
before considering removal of disabled class instances.

## Create a monitor or rule override

1. In the Authoring workspace, open **Management Pack Objects**, then select **Monitors** or
   **Rules**.
2. Locate the documented workflow and verify its target, default, unit, state behavior, and alert or
   collection effect.
3. Prefer **For a group** for an operational tier or policy cohort. Use a class only for universal
   policy and a specific object only for a reviewed exception.
4. Select the individual parameters to override.
5. Save the change to the customer Monitoring Overrides MP.
6. Validate both the intended condition and recovery, including alert opening, suppression,
   auto-resolution, health rollup, and data volume where applicable.
7. Export and archive the approved override MP.

When disabling a monitor or rule, use an explicit `Enabled = False` override and choose the correct
destination MP. Do not use a console shortcut that obscures where the change is stored. See
[Best practices for configuring overrides](https://learn.microsoft.com/en-us/troubleshoot/system-center/scom/best-practices-configure-overrides).

## Choose a tuning template

| Profile | Choose it when | Do not choose it when |
|---|---|---|
| Lab | Running bounded functional, fault, transition, or diagnostic tests | The environment is production or representative data volume has not been reviewed |
| Standard | Establishing the normal production starting point | Local topology or response requirements clearly differ from the documented assumptions |
| Strict | Protecting explicitly designated critical services with tested response capacity | The goal is simply to generate more alerts or lower every threshold |

Templates are examples, not signed product dependencies. Generate one selected profile with:

```powershell
./src/hyper-v/scom-mp/tools/New-HyperVOverrideManagementPacks.ps1 `
    -TuningProfile Standard `
    -OrganizationId Contoso `
    -OrganizationName 'Contoso' `
    -Version '0.1.0.0' `
    -PublicKeyToken '<product-public-key-token>' `
    -OutputPath './out/contoso-overrides'
```

Then:

1. Read the profile manifest and change log for the exact product version.
2. Review both generated Discovery and Monitoring files.
3. Replace the example organization identity with the customer's approved identity.
4. Remove settings that are not intentionally adopted.
5. Validate XML references and import the files only in pre-production.
6. Exercise normal, failure, recovery, maintenance, migration, and failover scenarios.
7. Promote the resulting customer-owned files through the customer's change process.

Never import all three profiles together or treat Lab values as a production shortcut.

## Review effective configuration

An imported override is not proof that the intended value is effective. Review:

- the target class, group membership, and specific instances;
- other class, group, and instance overrides that can apply;
- the destination override MP and its version;
- the workflow's effective configuration on representative agents;
- HealthService events or monitoring-pipeline health for rejected or stale configuration; and
- resulting state, alerts, collections, DA rollup, and runtime cost.

Record the reason, owner, evidence, approval date, and review date for every production deviation
from Standard. Company knowledge can document local operational context without modifying sealed
product knowledge.

## Upgrade safely

1. Read the release notes, dependency matrix, monitoring-catalog changes, and tuning-profile diff.
2. Export both customer override MPs and retain the currently installed product artifacts.
3. Import the newer sealed MPs in dependency order in pre-production.
4. Leave the customer override MPs in place and review unresolved, retired, or changed workflow
   references.
5. Repeat representative discovery, health, alert, DA, performance, and scale tests.
6. Promote the same signed product artifacts and approved customer overrides to production.
7. Verify effective configuration and record the installed versions.

An Operations Manager Management Pack downgrade is not treated as a routine rollback. The release
must provide a tested recovery procedure; removal and reimport can affect configuration, objects,
and historical data and therefore require a separately approved change.

## Remove the product

Removal is dependency-sensitive and potentially destructive. Test the exact release procedure in
an isolated management group before production. The expected dependency order is:

1. export and archive the customer override MPs;
2. remove customer Monitoring Overrides;
3. remove customer Discovery Overrides;
4. remove optional Reporting and Presentation;
5. remove Monitoring;
6. remove Discovery; and
7. remove Library.

Operations Manager blocks removal while referencing MPs remain. Removing MPs can also remove
configuration and affect discovered objects or stored data. Review the product release guide and
Microsoft's import/removal documentation before proceeding.

## Common mistakes

| Mistake | Safer practice |
|---|---|
| Saving to the Default Management Pack | Create the matching customer Discovery or Monitoring Overrides MP |
| Combining all product overrides in one file | Keep Discovery and Monitoring overrides separate so lifecycle operations do not remove unrelated policy |
| Overriding individual objects at scale | Create an intentional group and document its membership logic |
| Lowering a threshold without duration or recovery analysis | Tune threshold, sampling, duration, and hysteresis as one state contract |
| Disabling discovery to fix a monitor | Correct discovery only when the object should not exist; tune monitoring when it should exist but use different policy |
| Importing a template without review | Copy, rename, trim, test, and own the resulting unsealed files |
| Editing or resealing the product MP | Leave signed product artifacts unchanged and use supported overrides |
| Testing only alert creation | Validate recovery, closure, rollup, maintenance behavior, and data volume too |

## Related design

- [Override and tuning architecture](../design/hyper-v/override-and-tuning-architecture.md)
- [Management Pack structure](../design/hyper-v/management-pack-structure.md)
- [Monitoring catalog and threshold policy](monitoring-catalog.md)
- [Validation and release architecture](../design/hyper-v/validation-and-release.md)
