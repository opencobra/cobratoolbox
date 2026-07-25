# Implementation Plan: XomicsToModel test

**Branch**: `006-xomicstomodel-test` | **Date**: 2026-07-14 | **Spec**: [spec.md](./spec.md)

## Summary

Add two **full-mode-only** tests that drive `XomicsToModel` end-to-end on the shipped
generic model + the tutorial's shipped omics data — one with `fastCore`, one with
`thermoKernel` — so both untested functions gain coverage. Skipped in fast/default mode
so routine runs stay fast; each asserts the extracted model is non-empty, feasible, and
matches captured reference facts. No `src` change.

## Technical Context

**Language/Version**: MATLAB (harness R2014b+).
**Primary Dependencies**: `XomicsToModel`, `preprocessingOmicsModel`, `thermoKernel`/`fastCore`,
`optimizeCbModel`; fixtures — `Recon3DModel_301_xomics_input.mat` (ships in papers/2023_iDopaNeuro,
var `model`, 5835×10600) and the tutorial's omics data (bibliomic xlsx, exometabolomic/transcriptomic txt).
**Testing**: the two new tests; run via `run_matlab_file`/`runScriptFile` in FULL mode (bounded `-batch`).
**Constraints**: full-mode-only (FR-006); no src/interface/result change (FR-005); genuine assertions
incl. `optimizeCbModel` stat==1 (FR-002); prepareTest needsLP+needsMILP → clean skip (FR-003);
submodule-independent fixtures (FR-004); figures invisible if any (FR-008).
**Scale/Scope**: two test files + a small shared omics-data fixture (+ generic model referenced or copied).

## Constitution Check

- **Scientific code quality**: asserts the extracted model is a valid, feasible COBRA model;
  no model math/interface changed. XomicsToModel/thermoKernel/fastCore run with their own settings.
- **Testing/reproducibility**: each config run to completion once (bounded, possibly long) to
  capture reference size/core-reaction facts; asserted exactly or within tolerance (extractor
  nondeterminism). Full-mode-only via `getCobraTestMode`.
- **UX/diagnostics**: fast-mode → clean skip (COBRA:RequirementsNotMet, "full-mode-only"); missing
  solver → clean skip; figures invisible.
- **Performance/numerical integrity**: no verification step removed; the tests are heavy by nature
  and quarantined to full mode so they do not burden routine runs.
- **External-solver config audit**: uses the default LP/MILP solver (gurobi) that XomicsToModel/the
  extractor select; no solver option changed.
- **Spec-driven scope control**: ADD `test/verifiedTests/dataIntegration/testXomicsToModel/` (two
  test .m + omics-data fixture). Read-only: all `src/`, the tutorial/paper submodules. The generic
  model is referenced from its shipped `papers/2023_iDopaNeuro/` path (CBTDIR-anchored) with a clean
  skip if absent, to avoid duplicating a 4.6 MB .mat; the small omics files are copied into the test folder.
- **MATLAB standards**: openCOBRA test header; assert-with-tolerance; figure-visibility via onCleanup;
  full-mode-only guard via `getCobraTestMode`; no evalc-suppression/nargin.
- **Artifact placement**: test + fixtures beside the test under verifiedTests/.

## Full-mode-only guard (shared pattern)

```matlab
global CBT_MISSING_REQUIREMENTS_ERROR_ID
if strcmp(getCobraTestMode(), 'fast')
    error(CBT_MISSING_REQUIREMENTS_ERROR_ID, ...
        'testXomicsToModel_* is full-mode-only (heavyweight); skipped in fast mode.');
end
```

## Project Structure

```text
test/verifiedTests/dataIntegration/testXomicsToModel/
├── testXomicsToModel_fastCore.m        # NEW: XomicsToModel + fastCore (full-mode-only)
├── testXomicsToModel_thermoKernel.m    # NEW: XomicsToModel + thermoKernel (full-mode-only)
└── data/                               # NEW: copied omics fixtures (bibliomic/exomet/transcriptomic)
# generic model referenced from papers/2023_iDopaNeuro/Recon3DModel_301_xomics_input.mat (CBTDIR-anchored, skip if absent)
```

## Complexity Tracking

| Deviation | Why | Simpler alternative rejected because |
|---|---|---|
| Full-mode-only, potentially multi-minute tests | XomicsToModel is inherently heavy (>10 min in feasibility); the user wants it tested and chose full-mode-only + both extractors | A fast in-suite test isn't achievable without changing what's tested; skipping it entirely leaves a major function untested. Quarantining to full mode keeps routine runs fast. |
| Viability risk: neither config completed in feasibility | Implementation must first run each config to completion (generous bounded cap) to confirm it finishes and capture references | If a config does not complete within the cap, that test is deferred/documented rather than committed as a hanging test. |
