# Implementation Plan: Characterize buildGurobiProblemFromModel

**Branch**: `017-buildgurobifrommodel-tests` | **Date**: 2026-08-17 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/017-buildgurobifrommodel-tests/spec.md`

## Summary

Single-file, additive characterization feature (Constitution Principle III). Adds
one new test, `testBuildGurobiProblemFromModel.m`, that pins the
CURRENT field-mapping and constraint-sense-translation behaviour of
`buildGurobiProblemFromModel` (`src/base/solvers/gurobi/buildGurobiProblemFromModel.m`),
which currently has zero test coverage. The test mirrors the sibling
`testBuildOptProblemFromModel.m` pattern already in
`test/verifiedTests/base/testSolvers/`: a small hand-built toy model, exact
(`isequal`) assertions against values independently derived from
`buildOptProblemFromModel`'s own (already-characterized) output, and no Gurobi
solver/license dependency since the function under test never calls `gurobi()`.
No `src` changes.

## Technical Context

**Language/Version**: MATLAB (COBRA Toolbox baseline; no MATLAB-version-specific
syntax used).

**Primary Dependencies**: `buildGurobiProblemFromModel` (function under test),
`buildOptProblemFromModel` (reference/oracle for the intermediate `optProblem`,
already characterized by the sibling test), COBRA test harness (`prepareTest` is
available but not needed here — see Constraints).

**Storage**: N/A — no files read/written beyond the in-memory toy model struct
built inline in the test.

**Testing**: One new test under `test/verifiedTests/base/testSolvers/`, run via
`test/testAll.m`'s recursive `verifiedTests/` scan and the CI pipelines
(`testAllCI_*`, `.artenolis.yml`, `codecov.yml`). `assert`-based, `isequal` exact
equality (no floating-point tolerance needed — the toy model uses small exact
integers and the function performs no arithmetic, only field renaming/casting).

**Target Platform**: headless Linux/Docker CI, same as the rest of `testSolvers/`;
also runs on any local MATLAB install with no solver installed, since the function
under test builds a struct but never invokes a solver.

**Project Type**: brownfield MATLAB library — solver-core test-only addition.

**Performance Goals**: sub-second; toy models have 3 metabolites / 3 reactions, no
optimization call.

**Constraints**: no `src` change (characterization only, Principle III); no
`prepareTest` solver requirement — the function under test never calls `gurobi()`,
so gating the test behind a Gurobi license would incorrectly narrow its CI
coverage versus what the function's actual dependencies justify; test must pass
in both fast and full suite modes identically (feature 002) since it contains no
per-solver loop to trim.

**Scale/Scope**: 1 new test file (~110 lines, matching the sibling test's size);
0 `src` files touched; 0 new directories (file lands in the existing
`test/verifiedTests/base/testSolvers/`).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.* — **PASS**
(characterization-only; no `src` edits; no unjustified violations).

- **Scientific code quality**: The characterized objects are the native-Gurobi
  struct's `A`/`obj`/`rhs`/`lb`/`ub` (constraint matrix, objective, RHS, bounds —
  Principle I objects `S`, `c`, `b`, `lb`, `ub`), `sense` (the `csense` translation),
  and `modelsense` (the `osense` translation). The test pins these mappings exactly
  as they exist today; it asserts, it does not alter, their semantics.
- **Testing and reproducibility**: Narrowest test is one new file,
  `test/verifiedTests/base/testSolvers/testBuildGurobiProblemFromModel.m`,
  using a fixed, hand-built toy model (no randomness, so no seed needed) and
  `isequal`-based exact assertions (justified: the toy model's numeric values and
  the function's field renaming involve no floating-point arithmetic). Integrated
  into `test/testAll.m` via its existing recursive scan; no manual registration.
- **User experience and diagnostics**: N/A — no console output, print-level, or
  diagnostic behaviour is added or changed; the test is silent on success per the
  existing `testBuildOptProblemFromModel.m` convention (no `fprintf`).
- **Performance and numerical integrity**: Sub-second test, no optimization call,
  no genome-scale model. No `src` performance change. No verification step is
  skipped or made conditional.
- **External-solver configuration audit**: N/A — `buildGurobiProblemFromModel`
  builds a struct shaped for the Gurobi MATLAB interface but never calls `gurobi()`
  itself, so the test invokes no external solver and there is no configuration
  surface (options/tolerances/defaults) to audit.
- **Spec-driven scope control**:
  - Add: `test/verifiedTests/base/testSolvers/testBuildGurobiProblemFromModel.m`
    (new file only).
  - MUST NOT touch: `src/base/solvers/gurobi/buildGurobiProblemFromModel.m`,
    `src/base/solvers/buildOptProblemFromModel.m`, or any other `src` file
    (Principle III: characterization only — a defect found here is a separate,
    spec-driven fix, not part of this feature).
- **MATLAB coding standards**: Test file carries the `% The COBRAToolbox: <name>.m`
  header with `Purpose:`/`Authors:` blocks (per `testGuide.rst` and the sibling
  test), not the full function-style openCOBRA header (VII-E applies to functions;
  this is a test script, matching the sibling test's own convention). No `evalc`,
  no suppressed warnings, no `try/catch` needed (assertion failures propagate
  naturally), no `nargin` (no optional arguments in a test script), `camelCase`
  naming, `cd(fileparts(which(...)))` / `cd(currentDir)` directory save-restore.
- **Parameter-setting fidelity**: N/A — no cross-language port or literate render.
- **Artifact placement**: One new file under
  `test/verifiedTests/base/testSolvers/` (Principle IX: "test or fixture →
  `test/`"), alongside the sibling `testBuildOptProblemFromModel.m` it
  mirrors. No fixture file needed — the toy model is built inline as a local
  helper function within the test file itself (same as the sibling test's
  `buildToyModel()`), so no `test/models/` addition is required. No other file's
  placement changes.

**Re-check after design (Phase 1)**: unchanged — `data-model.md` documents the toy
model and expected `gurobiModel` field values already fixed by the Existing
Contract in `spec.md`; no new entity, interface, or `src` touch-point emerged.
PASS.

## Project Structure

### Documentation (this feature)

```text
specs/017-buildgurobifrommodel-tests/
├── spec.md               # Feature spec (/speckit-specify command output)
├── plan.md                # This file (/speckit-plan command output)
├── research.md            # Phase 0 output (/speckit-plan command)
├── data-model.md           # Phase 1 output (/speckit-plan command)
├── quickstart.md          # Phase 1 output (/speckit-plan command)
├── checklists/
│   └── requirements.md    # Spec quality checklist (/speckit-specify command)
└── tasks.md               # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

(`contracts/`: omitted — this is a test-only characterization feature with no new
public API/CLI/interface surface; the "contract" being pinned is the existing
`buildGurobiProblemFromModel` field mapping, already fully documented in `spec.md`'s
Existing Contract section and reproduced in `data-model.md`.)

### Source Code (repository)

```text
src/base/solvers/gurobi/
└── buildGurobiProblemFromModel.m   # UNCHANGED — function under test, read-only

src/base/solvers/
└── buildOptProblemFromModel.m      # UNCHANGED — reference/oracle, read-only

test/verifiedTests/base/testSolvers/
├── testBuildOptProblemFromModel.m       # EXISTING sibling (pattern reference, unchanged)
└── testBuildGurobiProblemFromModel.m    # NEW — this feature's only deliverable
```

**Structure Decision**: Single new test file in the existing
`test/verifiedTests/base/testSolvers/` directory, alongside the sibling
characterization test it mirrors. No `src/` changes. No new subdirectories, no
`contracts/` artifact, no new test fixture files (toy model built inline).

## Complexity Tracking

No Constitution Check violations to justify. This section is intentionally empty:
the feature is a single additive test file with no new dependency, abstraction, or
repository-layout change.
