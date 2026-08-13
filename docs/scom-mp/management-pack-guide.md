---
title: Azure Local Management Pack guide
description: Build, import, configure, tune, operate, upgrade, and remove the Azure Local SCOM product.
---

# Azure Local Management Pack guide

The repository currently produces development XML. Do not treat it as a signed release until the
validation page records successful SDK, sealing, signing, and SCOM lab gates.

## Build

Run the PowerShell 7 build script with a four-part version, the intended product public-key token,
and an output directory. Add the reporting switch only when validating the optional Reporting
project. The generated inventory deliberately reports releaseReady as false.

## Import order

1. Confirm official Microsoft dependency MPs for the target management group.
2. Import Library.
3. Import Discovery.
4. Import Monitoring.
5. Import Presentation.
6. Import optional Reporting only when certified.
7. Generate and review customer Discovery and Monitoring override MPs.
8. Import customer override MPs after the sealed product.

## Verify discovery

Confirm:

- one node-role object per managed Azure Local node;
- one stable Deployment and Service per cluster;
- pools, volumes, disks, Network ATC intents, update resources, Arc/platform objects, and pipeline
  instances;
- six DA components with dynamic membership; and
- no Hyper-V product dependency.

Discovery is asynchronous. Do not shorten intervals in production just to accelerate testing; use a
temporary lab override and remove it afterward.

## Generate customer overrides

The generator creates separate unsealed Discovery and Monitoring files from Lab, Standard, or
Strict. Use an organization-owned XML-safe prefix and the exact sealed product version/public key
token. Review every generated value, rename or annotate it under customer policy, and store it in
version control.

## Create a manual override

1. Open the monitor, rule, or discovery in the SCOM Authoring workspace.
2. Choose the override command, not the generic Disable shortcut.
3. Prefer a group target where the operating policy applies to multiple deployments or nodes.
4. Select the corresponding customer-owned Azure Local Discovery or Monitoring Overrides MP.
5. Set only the required parameters and document the reason.
6. Validate in pre-production, including recovery and DA rollup.
7. Export and archive the updated unsealed MP.

Never select the Default Management Pack.

## Operate

Use the Azure Local service view for overall status and enter the affected component branch before
responding. Confirm maintenance mode, current monitor context, active Health Service faults, recent
cluster events, and pipeline health. The read-only diagnostic task summarizes cluster, storage,
Network ATC, registration, and active fault counts.

## Upgrade and removal

Back up both customer override MPs. Import sealed projects in dependency order, then update override
references only when required. Validate topology reconciliation and effective configuration.

To remove the product, first remove customer MPs and optional Reporting/Presentation dependents,
then Monitoring, Discovery, and Library. Disabling discovery does not instantly delete existing
class instances; follow Microsoft disabled-instance removal guidance after scope validation.
