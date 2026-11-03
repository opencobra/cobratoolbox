# Implementation Plan: Tier-2 test pilot (ten model-manipulation functions)

**Branch**: `20261102-142225-tier2-test-pilot` | **Date**: 2026-11-02 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/20261102-142225-tier2-test-pilot/spec.md`

## Summary

Write one Tier-2 characterization test for each of ten untested model-manipulation functions,
using `ecoli_core_model` from `getDistributedModel` (loaded once per file), with structural
consistency and content-agreement assertions and first-run reference counts (Tier 5). Defects are
recorded per III-Defects. Regenerate the registry, write a style note, and stop for review.

## Technical Context

**Language/Version**: MATLAB R2025a; Python 3 for the registry tool.

**Primary Dependencies**: COBRA Toolbox; `getDistributedModel`; no solver, no MATLAB toolbox.

**Storage**: none; tests create no files.

**Testing**: script-style `test<Name>.m` run by `test/testAll.m`; verified with `runScriptFile`
and line coverage (throwaway helper, see [quickstart.md](quickstart.md)); `%%` sections are
independent (each section can run alone).

**Target Platform**: headless Linux CI and developer machines.

**Project Type**: MATLAB library (test back-fill).

**Performance Goals**: each test well under a minute (E. coli core loads in about a second).

**Constraints**: no `src` change; no solver; one model load per file.

**Scale/Scope**: 10 test files, 1 style note, registry regeneration.

## Constitution Check

*GATE: passed before research; re-checked after design: still passes.*

- **Scientific code quality**: no formulation touched; `src/` read-only.
- **Testing and reproducibility**: III-Characterization, III-Coverage (Tier 2, Tier 4 model
  loading, Tier 5 references), III-Naming, III-Defects. Commands in [quickstart.md](quickstart.md).
- **User experience and diagnostics**: function output and warnings are not suppressed.
- **Performance and numerical integrity**: counts are integers (exact equality); any float
  comparison uses a justified tolerance.
- **External-solver configuration audit**: N/A (no solver; probe confirmed all ten run without one).
- **Spec-driven scope control**: new files only under the four test folders of the selection
  table, this feature folder, and the regenerated `test/known-defects.md`.
- **MATLAB coding standards**: no `evalc` except to capture console output that is asserted;
  warnings visible; no `nargin`.
- **Parameter-setting fidelity**: N/A.
- **Artifact placement**: tests beside sibling tests (existing folders only).

## Project Structure

### Documentation (this feature)

```text
specs/20261102-142225-tier2-test-pilot/
├── spec.md, plan.md, research.md, data-model.md, quickstart.md, tasks.md
├── style-note.md                 # US2 deliverable
└── agent-runs/<UTC>-implement/implementation-receipt.md
```

### Source Code (repository root)

```text
test/verifiedTests/reconstruction/testModelManipulation/test{ExtractSubSysModel,ExtractCompModel,KeepCompartment,OrderModelFields,UpdateFieldOrderForType}.m
test/verifiedTests/reconstruction/testModelGeneration/testRemoveCompartments.m
test/verifiedTests/base/testIO/testUtilities/test{CreateEmptyFields,ConvertOldCouplingFormat}.m
test/verifiedTests/analysis/testExploration/test{FindRxnFromCompartment,FindMetFromCompartment}.m
```

**Structure Decision**: existing folders only; no new folders.

## Complexity Tracking

No constitution violations; nothing to justify.
