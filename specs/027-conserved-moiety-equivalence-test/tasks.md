# Tasks: Conserved-Moiety Cross-Function Equivalence Test

**Input**: Design documents from `specs/027-conserved-moiety-equivalence-test/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md

**Tests**: This feature *is* a test addition (per spec FR-001..FR-007 and Constitution
Principle III), so "Implementation" and "Tests" below are the same work: extending the
one existing, correctly-named test file for `identifyConservedReactingMoieties.m`. No
new test file is created (Principle III-Naming); no source file is modified.

**Organization**: A single P1 user story from spec.md. No cross-story dependencies.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: US1, per spec.md
- File paths are exact and absolute-from-repo-root

## Path Conventions

Single MATLAB toolbox project. One file is edited; two source files are read-only
references:

- Edited: `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`
- Read-only: `src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m`
- Read-only: `src/analysis/topology/conservedMoieties/identifyConservedMoieties.m`

---

## Phase 1: Setup (Read-and-Map, Constitution Principle V)

**Purpose**: Map the exact edit point and confirm the exact interfaces being called
before touching the test file (Principle V: "the relevant file(s) MUST be read and
mapped before editing" for algorithmic/behavioral changes; grep-only edits are
insufficient).

- [X] T001 [P] Re-read `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m` in full to confirm the exact current location of the feature-026 conserved-only block (where `armConservedOnly`/`moietyFormulaeConservedOnly` are computed via `identifyConservedReactingMoieties(subModel, BG, dATM, optionsConservedOnly)`) and the file's `prepareTest('needsMILP', true)` gate, so the new assertions can be inserted between them.
- [X] T002 [P] Re-read `src/analysis/topology/conservedMoieties/identifyConservedMoieties.m`'s documentation header and signature (`[arm, moietyFormulae] = identifyConservedMoieties(model, dATM, options)`) to confirm the exact call form and output field names (`arm.L`, `arm.M2M`, `arm.M2R`, `moietyFormulae`) needed for the comparison — read-only, confirms no source edit is required.

**Checkpoint**: Exact insertion point and call signature confirmed — no further exploratory reads needed before editing.

---

## Phase 2: Foundational

**Purpose**: N/A for this feature — there is no shared infrastructure to stand up
before the single user story below. Phase 2 is intentionally empty.

---

## Phase 3: User Story 1 - Automated cross-implementation equivalence guard (Priority: P1) 🎯 MVP

**Goal**: `testConservedReactingMoieties.m` calls `identifyConservedMoieties` on the
same fixture already used for the feature-026 conserved-only call, and asserts
`isequal` on `arm.L`, `arm.M2M`, `arm.M2R`, and `moietyFormulae` between the two, so a
future divergence between the two implementations fails this test.

**Independent Test**: Run the extended test file; the four new assertions pass today
(reproducing the manually-verified equivalence) and would fail if either function's
conserved-moiety algorithm changes in a way that breaks the equivalence.

### Implementation for User Story 1

- [X] T003 [US1] In `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`, immediately after the existing feature-026 conserved-only block (after `armConservedOnly`/`moietyFormulaeConservedOnly` are computed) and before the file's `prepareTest('needsMILP', true)` gate, add a call to the sibling function on the same fixture: `optionsSibling = struct('sanityChecks', 0); [armSibling, moietyFormulaeSibling] = identifyConservedMoieties(subModel, dATM, optionsSibling);` (spec FR-001, research.md "sanityChecks" decision).
- [X] T004 [US1] In the same block, add `assert(isequal(armConservedOnly.L, armSibling.L), 'arm.L must be identical between identifyConservedReactingMoieties(conservedMoietiesOnly=true) and identifyConservedMoieties (spec 027 SC-001/SC-002).');` (spec FR-002).
- [X] T005 [US1] In the same block, add `assert(isequal(armConservedOnly.M2M, armSibling.M2M), 'arm.M2M must be identical between identifyConservedReactingMoieties(conservedMoietiesOnly=true) and identifyConservedMoieties (spec 027 SC-001/SC-002).');` (spec FR-003).
- [X] T006 [US1] In the same block, add `assert(isequal(armConservedOnly.M2R, armSibling.M2R), 'arm.M2R must be identical between identifyConservedReactingMoieties(conservedMoietiesOnly=true) and identifyConservedMoieties (spec 027 SC-001/SC-002).');` (spec FR-004).
- [X] T007 [US1] In the same block, add `assert(isequal(moietyFormulaeConservedOnly, moietyFormulaeSibling), 'moietyFormulae must be identical between identifyConservedReactingMoieties(conservedMoietiesOnly=true) and identifyConservedMoieties (spec 027 SC-001/SC-002).');` (spec FR-005).
- [X] T008 [US1] Immediately above T003-T007's block, add a short dated comment (matching this file's existing `--- feature NNN-... ---` style) stating: this feature (027) guards against divergence between the two independent conserved-moiety implementations; `options.sanityChecks = 0` is used on both compared calls because `sanityChecks = 1` on the conserved-only call is a known, pre-existing, out-of-scope crash (spec Edge Cases, research.md); no MILP solver is required by this block, so it is placed before the file's `prepareTest('needsMILP', true)` gate (spec FR-007).

**Checkpoint**: User Story 1 is independently testable — running the extended test file now exercises and passes the new cross-function equivalence assertions on their own, without requiring a MILP solver.

---

## Phase 4: Polish & Verification

**Purpose**: Constitution-mandated closeout — run the change end-to-end, confirm
coding standards, and record the implementation receipt.

- [X] T009 Run the extended `testConservedReactingMoieties.m` end-to-end (via the MATLAB MCP server if available, else `matlab -batch` at `/usr/local/MATLAB/R2024b/bin/matlab`), record pass/fail and any solver-status/skip messages verbatim (Constitution: preserve exact solver status strings); confirm every pre-existing assertion (features 004, 019, 020, 024, 026) still passes unmodified alongside the new T003-T007 assertions.
- [X] T010 [P] Verify MATLAB coding-standards compliance for the diff: no `evalc` used, no warnings suppressed, no `nargin` introduced, no `try/catch` introduced, and the new `assert(isequal(...), '<message>')` calls match this file's existing assertion style exactly (Constitution VII).
- [X] T011 [P] Run quickstart.md's automated check and manual spot-check once each; record the four `isequal` outputs.
- [X] T012 Confirm via `git diff --stat` (or equivalent) that only `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m` changed — neither `identifyConservedReactingMoieties.m` nor `identifyConservedMoieties.m` was modified (spec FR-008).
- [X] T013 Report files changed, checks run, tests passed/failed, and any behavior not yet verified (Constitution Principle III closing requirement).
- [X] T014 Create the implementation receipt at `specs/027-conserved-moiety-equivalence-test/agent-runs/<UTC-timestamp>-<short-name>/implementation-receipt.md` with Prompt, Final response (verbatim), Diff summary, Tests, and Unresolved issues sections (Constitution Implementation Receipt Ledger).

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately.
- **Foundational (Phase 2)**: Empty — nothing blocks on it.
- **User Story 1 (Phase 3)**: Depends on Setup (T001-T002) only.
- **Polish (Phase 4)**: Depends on User Story 1 (T003-T008) being complete.

### Parallel Opportunities

- T001 and T002 (Setup) can run in parallel — read-only, different files.
- T010 and T011 (Polish) can run in parallel — independent checks.
- T003-T008 are strictly sequential: each adds to the same growing block in the same
  file in the same order (the sibling call before the assertions that use its output;
  the explanatory comment can be written alongside T003 but is listed last here only
  for narrative clarity).

---

## Implementation Strategy

### MVP First (and only) — User Story 1

1. Complete Phase 1 (Setup).
2. Complete Phase 3 (User Story 1: T003-T008) — the entire feature.
3. **STOP and VALIDATE**: run the extended test file; the four new assertions should
   pass immediately, reproducing the manually-verified equivalence.
4. Complete Phase 4 (Polish).

There is no second user story and no meaningful parallel-team split for this
feature — it is a small, single-file, single-story test addition.

## Notes

- Every task (T003-T008) touches the same single file, at the same insertion point,
  in a fixed order — there is no ambiguity left for implementation to resolve.
- Per Constitution Principle VI, none of T003-T014 may begin until this tasks.md has
  been reviewed and implementation has been explicitly approved and invoked (Gate 2,
  then `/speckit-implement` or the agent-assign pipeline).
