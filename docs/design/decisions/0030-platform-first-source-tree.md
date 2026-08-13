# ADR 0030 — Platform-first source tree

**Status:** Accepted

**Date:** 2026-08-13

**Decision owners:** Repository owner and maintainers

## Context

The repository originally had solution-first source roots: `src/scom-mp`, `src/azure-monitor`, and
`src/squaredup`. That layout was created when the product covered only Azure Local. It no longer
shows who owns an artifact now that Azure Local and Hyper-V are independent platform tracks with
separate runtime products, support contracts, releases, and Distributed Applications.

ADR 0021 established platform-first planning and documentation. ADR 0022 established independent
Azure Local and Hyper-V SCOM runtime products. The physical source tree must enforce the same
boundary and reserve the conditional Hyper-V Azure Monitor solution without activating it.

## Decision

Organize product source by platform first and solution second:

```text
src/
├── azure-local/
│   ├── scom-mp/
│   └── azure-monitor/
└── hyper-v/
    ├── scom-mp/
    └── azure-monitor/
```

Each solution owns its implementation, tests, optional SquaredUp content, versioning, and release
artifacts beneath its source root. No shared runtime source root is allowed. Cross-product build and
validation automation belongs under `tools/`, not under either platform.

Create the Hyper-V Azure Monitor root now as a documented, empty implementation boundary. It must
not contain deployable source until ADR 0023 records a go decision. Its presence does not activate
the conditional roadmap Feature.

Optional SquaredUp artifacts live inside the solution whose classes or telemetry they visualize:

- Dashboard Server content under the applicable `scom-mp/squaredup/`; and
- SquaredUp Cloud content under the applicable `azure-monitor/squaredup/`.

This ADR supersedes only the obsolete `src/scom-mp`, `src/azure-monitor`, and `src/squaredup` path
examples in ADRs 0008 and 0013–0015. It does not change their customization, deployment, testing,
or pipeline decisions.

## Consequences

- Source ownership matches the public platform-first documentation and platform delivery boundaries.
- Azure Local and Hyper-V artifacts cannot be confused inside one solution-first directory.
- Both platform tracks have stable roots for both solution types.
- The conditional Hyper-V Azure Monitor boundary is visible without implying implementation approval.
- Historical ADR path examples remain immutable; this ADR is the current path authority.
- Build, test, CODEOWNERS, and documentation references must use the new roots.

## Alternatives considered

### Keep solution-first roots

Rejected because platform ownership and independent product boundaries remain implicit.

### Add platform names below the existing solution roots

Rejected because `src/scom-mp/azure-local` still makes the delivery technology the primary owner
and encourages shared SCOM runtime content.

### Omit Hyper-V Azure Monitor until a go decision

Rejected because the requested repository contract has two solution boundaries per platform. A
documented reserved root is safe as long as deployable implementation remains prohibited.

## Related design

- [Source-tree contract](https://github.com/Hybrid-Solutions-Cloud/hybrid-health-monitoring/blob/main/src/README.md)
- [ADR 0021 — Platform and delivery-track architecture](0021-platform-and-delivery-track-architecture.md)
- [ADR 0022 — Independent SCOM Management Pack packaging](0022-scom-management-pack-packaging-boundaries.md)
- [ADR 0023 — Hyper-V Azure Monitor through Arc-enabled SCVMM](0023-hyper-v-azure-monitor-through-arc-enabled-scvmm.md)
