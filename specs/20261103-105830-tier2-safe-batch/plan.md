# Implementation Plan: Tier-2 tests for every safe untested model-manipulation function

**Branch**: `20261103-105830-tier2-safe-batch` | **Date**: 2026-11-03 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/20261103-105830-tier2-safe-batch/spec.md`

## Summary

Write Tier-2 characterization tests for the 30 provisional functions of the spec, in the pilot's
style, after a per-function probe that drops functions needing a solver, undistributed models or
external data. Each test is verified with the harness runner, line coverage, and solver spies.
Then regenerate the registry, write `summary.md`, and commit.

## Technical Context

**Language/Version**: MATLAB R2025a; Python 3 for the registry tool.

**Primary Dependencies**: COBRA Toolbox; `getDistributedModel` (22 entries: E. coli core,
iAF1260, iJO1366, Recon2.v04, Recon3D, a few AGORA strains, cardiac mitochondrion, ...).

**Storage**: none; tests create no files.

**Testing**: `runScriptFile`; line coverage per section with the throwaway helper
`runWithCoverage.m`; solver spies `solverSpies/` (throwaway) placed first on the path for one run.

**Target Platform**: headless Linux CI.

**Project Type**: MATLAB library (test back-fill).

**Performance Goals**: each test under a minute; Recon3D only where a branch needs it.

**Constraints**: no `src` change; no solver; one model load per model per file.

**Scale/Scope**: up to 30 tests.

## Constitution Check

*GATE: passed before research; re-checked after design: still passes.*

- **Scientific code quality**: `src/` read-only.
- **Testing and reproducibility**: III-Characterization, III-Coverage (Tier 2/4/5), III-Naming,
  III-Defects; commands in [quickstart.md](quickstart.md).
- **User experience and diagnostics**: output not suppressed; global state restored by the test.
- **Performance and numerical integrity**: exact equality for counts; justified tolerances.
- **External-solver configuration audit**: N/A — no solver (spy-verified, FR-004).
- **Spec-driven scope control**: new test files in the folders of the selection table, this
  feature folder, regenerated registry.
- **MATLAB coding standards**: no `evalc` unless the captured text is asserted; warnings visible.
- **Parameter-setting fidelity**: N/A.
- **Artifact placement**: existing test folders only.

## Project Structure

```text
specs/20261103-105830-tier2-safe-batch/  spec, plan, research, data-model, quickstart, tasks,
                                         summary.md, agent-runs/<UTC>-implement/
test/verifiedTests/<folders of the selection table>/test<Function>.m
test/known-defects.md                    regenerated
```

**Structure Decision**: existing folders only.

## Complexity Tracking

No constitution violations; nothing to justify.
