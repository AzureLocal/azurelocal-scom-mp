# ADR 0022 — SCOM Management Pack packaging boundaries

**Status:** Proposed  
**Date:** 2026-08-12  
**Decision gate:** Research spike [AB#7319](https://dev.azure.com/hybridcloudsolutions/Hybrid%20Infrastructure%20Health%20Monitoring/_workitems/edit/7319)

## Context

The Azure Local and Hyper-V SCOM surfaces can reuse authoring conventions and may share some base
types. Sharing source patterns is low risk; sharing sealed Management Pack dependencies creates a
long-lived versioning and upgrade contract. The correct artifact boundary must be chosen before
either implementation establishes public class names or references.

## Decision drivers

- stable public class and relationship contracts;
- independent platform release and support cadence;
- upgrade and side-by-side compatibility;
- sealing and strong-name key dependencies;
- operator import, upgrade, and removal experience;
- avoidance of circular or unnecessary references;
- ability to reuse test fixtures and authoring fragments; and
- future companion Management Packs.

## Options under evaluation

1. A small shared sealed library referenced by separate Azure Local and Hyper-V libraries.
2. Completely separate platform libraries with source-level reuse only.
3. A Hyper-V base library extended by Azure Local-specific libraries.

No option is selected yet. In particular, Azure Local must not inherit a generic Hyper-V type
hierarchy until the spike proves that doing so preserves correct discovery, hosting, health rollup,
versioning, and support behavior.

## Acceptance gate

This ADR can be accepted only after the spike produces:

- a class and relationship ownership matrix;
- example reference graphs for all options;
- import, upgrade, coexistence, and removal analysis;
- artifact names and namespace conventions;
- signing and versioning consequences; and
- a recommendation supported by lab validation where feasible.
