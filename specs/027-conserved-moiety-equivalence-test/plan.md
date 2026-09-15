# Implementation Plan: Conserved-Moiety Cross-Function Equivalence Test

**Branch**: `027-conserved-moiety-equivalence-test` | **Date**: 2026-09-15 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/027-conserved-moiety-equivalence-test/spec.md`

## Summary

Add four `isequal` regression assertions to the existing
`test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`,
comparing the conserved-only output of `identifyConservedReactingMoieties.m`
(`options.conservedMoietiesOnly = true`, added by feature 026) against the output of
the sibling function `identifyConservedMoieties.m` on the same `subModel`/`dATM`
fixture already built earlier in that file. This turns a one-off manual comparison
(done while verifying feature 026's regression-safety) into a standing, CI-executed
guard against the two independent conserved-moiety implementations silently
diverging. No source function is modified; no new fixture, model, or test file is
introduced.

## Technical Context

**Language/Version**: MATLAB, R2024b+ baseline (Constitution Scientific Computing
Constraints).

**Primary Dependencies**: None new. Uses only what
`test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`
already uses (`identifyConservedReactingMoieties.m`, its sibling
`identifyConservedMoieties.m`, `buildAtomAndBondTransitionMultigraph.m`,
`extractSubNetwork.m`, `readCbModel.m`). `identifyConservedMoieties.m` is called for
comparison only — it is not modified and no new call site outside the test file is
introduced.

**Storage**: N/A

**Testing**: Existing MATLAB test harness (`test/testAll.m`,
`test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`);
no new `prepareTest` requirement (neither compared call needs a MILP solver).

**Target Platform**: Headless Linux CI (`matlab -batch`), same as the rest of the
toolbox. Both compared calls specifically must not require a MILP solver
license/installation.

**Project Type**: Library (test-only change within the existing MATLAB toolbox test
tree; no new subfolder, no new dependency, no source function modified).

**Performance Goals**: No numeric throughput target. The added work is one extra
function call (`identifyConservedMoieties` on an already-tiny 4-metabolite/3-reaction
fixture) plus four `isequal` comparisons — negligible relative to the file's existing
runtime.

**Constraints**: The new assertions MUST NOT require a MILP solver and MUST NOT
depend on `options.sanityChecks = 1` on either compared call (a pre-existing,
out-of-scope defect makes the conserved-only call to
`identifyConservedReactingMoieties.m` crash under `sanityChecks = 1`; both calls use
`sanityChecks = 0`, matching the file's existing conserved-only call from feature
026).

**Scale/Scope**: One test file extended
(`test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`).
No source file modified. No new test file (Principle III-Naming).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Scientific code quality**: This feature adds no new formulation and touches no
  solver or interface boundary. It only calls two already-existing, already-correct
  functions (`identifyConservedReactingMoieties.m` conserved-only mode, and
  `identifyConservedMoieties.m`) and compares their already-documented output fields
  (`arm.L`, `arm.M2M`, `arm.M2R`, `moietyFormulae`) for exact equality. (Constitution
  Principle I — no model, bound, objective, or status semantics are involved; this is
  a structural-decomposition equivalence check.)

- **Testing and reproducibility**: Narrowest test = four `isequal` assertions
  appended to the one existing, correctly-named test file for
  `identifyConservedReactingMoieties.m`
  (`test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`,
  per Principle III-Naming), placed immediately after the existing feature-026
  conserved-only call (`armConservedOnly`, `moietyFormulaeConservedOnly`) and reusing
  the file's existing `subModel`/`dATM` fixture. No new `prepareTest` requirement:
  neither `identifyConservedReactingMoieties(..., conservedMoietiesOnly=true)` nor
  `identifyConservedMoieties(...)` invokes a MILP solver, so the new assertions run
  and pass even on a runner with no MILP solver licensed (spec FR-007, SC-003) —
  they are placed alongside the existing conserved-only block, before the file's
  `prepareTest('needsMILP', true)` gate.

- **User experience and diagnostics**: No new console output beyond what
  `identifyConservedMoieties.m` already prints by default at `sanityChecks = 0`
  (matching the file's existing calls). No new diagnostic surface is introduced.

- **Performance and numerical integrity**: One additional function call on an
  already-tiny fixture; no loop, no repeated solve, no change to any existing
  assertion's tolerance or logic. The comparison itself uses exact `isequal` (per
  spec Assumptions, justified by the manually-verified bit-for-bit equivalence),
  not a tolerance-based comparison — no numerical-integrity claim beyond what
  `identifyConservedReactingMoieties.m`'s own existing `norm(L*N) < tol` assertion
  already establishes for the conserved-only run.

- **External-solver configuration audit**: N/A — neither compared function call
  reaches `intlinprog`/`solveCobraMILP` (this is the entire reason `sanityChecks = 0`
  and no MILP `prepareTest` gate are needed for the new assertions).

- **Spec-driven scope control**: Exactly one file is edited:
  `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`.
  `src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m` and
  `src/analysis/topology/conservedMoieties/identifyConservedMoieties.m` are read-only
  for this feature — it calls both but modifies neither (spec FR-008). No new
  fixture, helper file, or abstraction is introduced (spec FR-006).

- **MATLAB coding standards**: The new assertions follow the exact `assert(isequal(...),
  '<message>')` pattern already used elsewhere in this same file (e.g. the existing
  feature-026 equivalence assertions comparing `armConservedOnly` against the file's
  full-mode `arm`). No `evalc` is introduced. No warning is suppressed. No `try/catch`
  is introduced (none is needed for a pure assertion addition).

- **Parameter-setting fidelity**: N/A — no cross-language port, render, or literate-
  document output is produced by this feature.

- **Artifact placement**: No new source or test files. The one edited file stays at
  its current, already-correct location
  (`test/verifiedTests/analysis/testReactingMoieties/`, per Principle IX). Spec Kit
  artifacts for this feature live under
  `specs/027-conserved-moiety-equivalence-test/`, as here.

## Project Structure

### Documentation (this feature)

```text
specs/027-conserved-moiety-equivalence-test/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md         # Phase 1 output
├── quickstart.md         # Phase 1 output
└── tasks.md              # Phase 2 output (/speckit-tasks — not created by this command)
```

No `contracts/` directory: this feature introduces no new or changed public
interface (no function signature, option, or output-field change) — it only adds
test-side assertions comparing two already-existing, unmodified functions.

### Source Code (repository root)

**Structure Decision**: This is a single-library MATLAB toolbox, test-only feature
(no frontend/backend/mobile split applies). Exactly one existing test file is
modified in place; no source file is modified; no new test file is created.

```text
test/verifiedTests/analysis/testReactingMoieties/
└── testConservedReactingMoieties.m         # MODIFIED: new identifyConservedMoieties
                                             # call + 4 isequal assertions, same
                                             # fixture/data already in the file
```

## Complexity Tracking

*No Constitution Check violations. Table intentionally left empty.*

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|---------------------------------------|
| — | — | — |
