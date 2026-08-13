---
title: Azure Local overrides and tuning
description: Customer-owned override MPs, starter profiles, safe tuning, and upgrade behavior.
---

# Azure Local overrides and tuning

## Required customer files

Create one unsealed override MP for Discovery and another for Monitoring. Keep them customer-owned,
version-controlled, exported before upgrades, and documented with the operational reason for every
change.

Never store Azure Local overrides in the Default Management Pack.

## Starter profiles

| Profile | Purpose | Important caution |
|---|---|---|
| Lab | Lower-frequency, relaxed capacity thresholds | Not a production policy |
| Standard | Conservative development baseline | Still requires environment validation |
| Strict | Earlier warning and faster polling | Higher workflow and alert sensitivity |

The generator accepts organization identity, product version, public key token, destination, and one
starter profile. It produces the two unsealed files without importing them.

## Safe tuning sequence

1. Confirm maintenance mode and current effective configuration.
2. Identify the class, monitor/rule, parameter, and matching dependent workflows.
3. Prefer a dynamic or explicit group over many instance overrides.
4. Change one hypothesis at a time in pre-production.
5. Test fault, duration, recovery, auto-resolution, DA propagation, and workflow load.
6. Record owner, reason, evidence, date, review date, and rollback value.
7. Export and version the customer override MP.

Disabling discovery does not immediately remove an existing object. Follow Microsoft guidance for
disabled class-instance removal after validating scope.
