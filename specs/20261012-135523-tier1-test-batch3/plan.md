# Implementation Plan: Tier-1 test coverage batch 3

**Branch**: none (work stays on `develop`) | **Date**: 2026-10-12 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/` of this feature (spec.md)

## Summary

Add one Tier-1 characterization test per remaining plain-data function (up to 74, provisional),
following III-Coverage, III-Naming and III-Defects: hand-built inputs, `prepareTest()` opening,
100% line coverage or documented exemptions, defects recorded in the header in the standard
format and skipped. Work in folder groups with a mandatory stop after the first ten tests.
Functions that the per-function probe shows are not Tier 1 are dropped and reported. At the
end the known-defects registry is regenerated. No `src` file changes.

## Technical Context

**Language/Version**: MATLAB R2025a (installed); Python 3 for the registry tool.

**Primary Dependencies**: COBRA Toolbox on the path; `verifyCobraFunctionError`; base MATLAB
only (a function that needs a MATLAB toolbox is dropped).

**Storage**: none; tests create no files.

**Testing**: script-style `test<Name>.m`, run by `test/testAll.m`; verified through
`runScriptFile` and measured with the code-coverage plugin (Cobertura; `hits` precedes
`number`); `%%` sections must be independent.

**Target Platform**: headless Linux CI and developer machines.

**Project Type**: MATLAB library (test back-fill).

**Performance Goals**: whole batch under 10 minutes; each test target under a few seconds.

**Constraints**: memory efficient; no files; no persistent state left; no change to `src/`.

**Scale/Scope**: up to 74 tests (64 up to 150 code lines, 10 larger).

## Constitution Check

*GATE: passed before research; re-checked after design: still passes.*

- **Scientific code quality**: no formulation/solver/interface touched; `src/` read-only.
- **Testing and reproducibility**: Principle III with III-Characterization, III-Coverage,
  III-Naming and III-Defects. Commands in [quickstart.md](quickstart.md).
- **User experience and diagnostics**: function console output is not suppressed (VII-A) and is
  documented per test.
- **Performance and numerical integrity**: tolerances justified wherever floats are compared.
- **External-solver configuration audit**: N/A.
- **Spec-driven scope control**: edit only new files under `test/verifiedTests/`, this
  feature's `specs/` folder, and regenerate `test/known-defects.md`.
- **MATLAB coding standards**: no `evalc`, warnings visible, no `nargin`, try/catch only via
  `verifyCobraFunctionError`.
- **Parameter-setting fidelity**: N/A.
- **Artifact placement**: tests beside sibling tests; existing folders used wherever one fits.

## Project Structure

### Documentation (this feature)

```text
specs/<this feature>/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
└── tasks.md
```

### Source Code (repository root)

New test files in the folders named in the spec's selection table (all existing test folders);
`test/known-defects.md` is regenerated.

**Structure Decision**: follow sibling convention; no new top-level folders.

## Complexity Tracking

No constitution violations; nothing to justify.
