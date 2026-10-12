# Implementation Plan: Test that blocks function-name conflicts

**Branch**: none (work stays on `develop`) | **Date**: 2026-10-12 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/20261012-123644-function-name-conflicts/spec.md`

## Summary

Add one verified test, `testFunctionNameConflicts.m`, that scans the toolbox for function
names that clash with another toolbox function or with a MATLAB function, fails with an
explanatory message for every conflict that is not recorded in a reviewed known-conflicts
file, and proves its own detection on a temporary tree. Existing conflicts (23 duplicate names
and 2 MATLAB-shadowing names found by a probe) are recorded with reasons so the test passes
today. A two-line rule in the change-based test selector makes the test run whenever a
function file under `src/` changes.

## Technical Context

**Language/Version**: MATLAB R2025a (script test with local functions at the end of the file).

**Primary Dependencies**: COBRA Toolbox on the path (as for every verified test); base MATLAB
only (`which`, `dir`, `fileread`, `tempname`). No MATLAB toolbox, no solver.

**Storage**: plain-text known-conflicts file beside the test.

**Testing**: the test is its own deliverable and contains a self-check on a temporary tree; it
runs within `test/testAll.m` and is verified through the harness runner (`runScriptFile`).
The selector rule is verified by a Python run on a synthetic change list.

**Target Platform**: headless Linux CI and developer machines (Windows/macOS file systems are
case-insensitive, which is why case-only differences are conflicts).

**Project Type**: repository hygiene test.

**Performance Goals**: under 30 seconds for about 1,600 source and 670 vendored functions.

**Constraints**: leave no files behind (temporary tree removed even on failure), do not change
the MATLAB path or the working directory of later tests, change no `src/` file.

**Scale/Scope**: 1 test, 1 known-conflicts file, 1 selector rule (+ one Python unit test of it).

## Constitution Check

*GATE: passed before research; re-checked after design: still passes.*

- **Scientific code quality**: no formulation/solver/interface touched; `src/` read-only.
- **Testing and reproducibility**: Principles III, III-Coverage (Tier 1: no model, no solver,
  `prepareTest()` opening, header with purpose/tier/exemptions, `%%` sections, comments, memory
  light) and III-Naming apply. There is no single source function under test (the test checks
  a repository property), so the test is named for what it checks; the spec's traceability
  uses the no-source convention. III-Defects: the test asserts nothing defective; the known
  conflicts are recorded in the known-conflicts file, not as asserted behaviour.
- **User experience and diagnostics**: the failure message is the product (FR-005); the test
  prints nothing when it passes except a short note when a recorded entry can be removed.
- **Performance and numerical integrity**: N/A for numerics; runtime bound above.
- **External-solver configuration audit**: N/A.
- **Spec-driven scope control**: new files under `test/verifiedTests/base/testInstall/`, one
  rule in `.github/scripts/select_tests.py`, its README line, one Python unit test. No `src/`
  edit.
- **MATLAB coding standards**: no `evalc`, warnings visible, errors raised with a clear
  message, no `nargin`.
- **Parameter-setting fidelity**: N/A.
- **Artifact placement**: test and its fixture file beside the install tests (test-suite role,
  Principle IX); selector rule with the other CI scripts.

## Project Structure

### Documentation (this feature)

```text
specs/20261012-123644-function-name-conflicts/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
└── tasks.md          # created by /speckit-tasks
```

### Source Code (repository root)

```text
test/verifiedTests/base/testInstall/
├── testFunctionNameConflicts.m          # new
└── knownFunctionNameConflicts.txt       # new: reviewed baseline of existing conflicts
.github/scripts/
├── select_tests.py                      # edited: always select the test when src/*.m changes
├── test_select_tests.py                 # new: unit test of that rule
└── README.md                            # edited: one line
```

**Structure Decision**: the install tests already check path/installation properties, so the
name-conflict test sits with them; the fixture file stays beside the test (Principle IX).

## Complexity Tracking

No constitution violations. The selector edit touches `.github/` (which, by the selector's own
policy, makes the introducing pull request run the full suite once); it is the minimum needed
for the test to guard pull requests (FR-011).
