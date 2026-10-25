# Tasks: Conserved-Moieties-Only Option for identifyConservedReactingMoieties

**Input**: Design documents from `specs/026-conserved-moieties-only-option/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/function-interface.md, quickstart.md

**Tests**: This feature is a MATLAB behavioral change to a public toolbox function, so per
spec FR-007/FR-008 and Constitution Principle III it MUST include the narrowest relevant
test — extending the function's single existing test file. No new test file is created
(Principle III-Naming).

**Organization**: Tasks are grouped by the two P1 user stories from spec.md. Unlike the
generic template's assumption of story independence, **User Story 2 here depends on User
Story 1 being implemented first** — its assertions compare against the conserved-only call
User Story 1 adds, so it cannot be written or pass beforehand. This is recorded explicitly
in Dependencies below rather than treated as a violation.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: US1 or US2, per spec.md
- File paths are exact and absolute-from-repo-root

## Path Conventions

Single MATLAB toolbox project. Two existing files only:
- `src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m`
- `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`

---

## Phase 1: Setup (Read-and-Map, Constitution Principle V)

**Purpose**: Map the exact edit points before touching either file (Principle V: "the
relevant file(s) MUST be read and mapped before editing" for algorithmic/behavioral
changes; grep-only edits are insufficient).

- [X] T001 [P] Re-read `src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m` around the existing `options.sanityChecks` / `options.useOpenSourceMoietyTools` default-handling block (currently ~lines 191-209) to confirm the exact `~exist('options','var')` / `~isfield(options, '<field>')` pattern to replicate for the new option.
- [X] T002 [P] Re-read `src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m` around the conserved/reacting boundary (currently `arm.L = L;` immediately followed by the `%% Reacting moiety (bond-level) analysis` comment, ~lines 1459-1461) to confirm the exact insertion point for the early return.
- [X] T003 [P] Re-read `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m` in full to confirm the exact existing variable names (`subModel`, `BG`, `dATM`, `N`, `tol`, `arm`, `moietyFormulae`, `options`) the new assertions will reuse, and where in the file (immediately after the existing full-mode call and its assertions, before `identifyConservedReactingSubgraphs` is invoked) the new assertions belong.

**Checkpoint**: Exact line ranges and variable names confirmed in both files — no further exploratory reads needed before editing.

---

## Phase 2: Foundational

**Purpose**: N/A for this feature — there is no shared infrastructure to stand up before
either user story. Both stories build directly on the Setup mapping above; Phase 2 is
intentionally empty.

---

## Phase 3: User Story 1 - Compute conserved moieties without paying for reacting-moiety analysis (Priority: P1) 🎯 MVP

**Goal**: `identifyConservedReactingMoieties` accepts `options.conservedMoietiesOnly` and,
when true, returns `arm`/`moietyFormulae` without executing the reacting-moiety section or
requiring a MILP solver.

**Independent Test**: Call the function with the option enabled on the existing test
fixture; confirm it returns without error, without a MILP-solver requirement, and with
`reacting.computed == false`.

### Implementation for User Story 1

- [X] T004 [US1] In `src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m`, add the `options.conservedMoietiesOnly` default-handling block (mirroring the pattern confirmed in T001: `if ~isfield(options,'conservedMoietiesOnly'); options.conservedMoietiesOnly = false; end`), placed alongside the two existing options defaults.
- [X] T005 [US1] In the same file, at the insertion point confirmed in T002 (immediately after `arm.L = L;`, before the `%% Reacting moiety (bond-level) analysis` section), add: `if options.conservedMoietiesOnly; reacting = struct('computed', false); return; end`.
- [X] T006 [US1] Update the function's openCOBRA-format documentation header: document `options.conservedMoietiesOnly` in the same `{(0),1}` style as `options.sanityChecks`/`options.useOpenSourceMoietyTools` under `OPTIONAL INPUTS`, and note under `OUTPUTS` (for `reacting`) that it is `struct('computed', false)` when this option is enabled (Constitution Principle VII-E, spec FR-006).

### Tests for User Story 1

- [X] T007a [US1] (Analysis finding F1 remediation) In `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`, relocate the existing top-of-script `prepareTest('needsMILP', true)` call so it runs immediately before the pre-existing full-mode call and its assertions (the only part of the file that actually needs a MILP solver), instead of before `subModel`/`BG`/`dATM` are built. Model construction and the new conserved-only assertions (T007-T008) must execute regardless of MILP-solver availability.
- [X] T007 [US1] In the same file, immediately after the file's existing full-mode call and its assertions, add a conserved-only call: build a copy of the existing `options` struct with `conservedMoietiesOnly = true` set, call `identifyConservedReactingMoieties(subModel, BG, dATM, optionsConservedOnly)`, and assert it returns without error and that `reacting.computed == false` (spec Acceptance Scenarios 1-2).
- [X] T008 [US1] In the same added block, assert (by inspection/comment referencing this task, since a negative "solver was never invoked" check is not directly assertable in MATLAB) that this call path does not depend on a MILP solver — i.e., do not wrap this new assertion block in an additional `prepareTest('needsMILP', true)` beyond the file's existing (now-relocated, per T007a) one, so CI would surface a failure here even on a MILP-solver-less runner (spec Acceptance Scenario 3, SC-001). With T007a done, this is now a real, CI-verifiable guarantee, not merely structural.

**Checkpoint**: User Story 1 is independently testable — running the extended test file now exercises and passes the conserved-only path on its own.

---

## Phase 4: User Story 2 - Confirm the new mode agrees with the existing computation (Priority: P1)

**Goal**: Prove, on the existing fixture, that the conserved-only path and the existing
full path produce identical conserved-moiety results.

**Independent Test**: Compare `arm.L`/`arm.M2M`/`arm.M2R`/`moietyFormulae` between the two
calls already present in the test file after Phase 3, and re-assert the `L*N = 0`
invariant on the conserved-only output.

**Depends on**: Phase 3 (T004-T008) — there is nothing to compare against until the
conserved-only call exists.

### Tests for User Story 2

- [X] T009 [US2] In `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`, immediately after T007/T008's block, assert field-level equality (reuse the file's existing `tol = 1e-8`) between the conserved-only call's `arm.L`, `arm.M2M`, `arm.M2R`, and `moietyFormulae`, and the pre-existing full-mode call's corresponding values (spec Acceptance Scenarios 1-2 of US2, SC-002).
- [X] T010 [US2] In the same block, re-assert `norm(full(arm.L) * N) < tol` using the conserved-only run's `arm.L` and the file's existing `N` (spec Acceptance Scenario 3 of US2).
- [X] T011 [US2] Confirm (by reading the diff, not by rewriting) that every pre-existing assertion in the file for the default/full-mode path is byte-for-byte unmodified (spec Acceptance Scenario 4 of US2, FR-009, SC-003) — no regression.

**Checkpoint**: User Stories 1 and 2 both pass together — the extended test file now proves both that the option works and that it agrees with the original computation.

---

## Phase 5: Polish & Verification

**Purpose**: Constitution-mandated closeout — run the change end-to-end, confirm coding
standards, and record the implementation receipt.

- [X] T012 Run the extended `testConservedReactingMoieties.m` end-to-end (via the MATLAB MCP
  server if available, else `matlab -batch`), record pass/fail and any solver-status/skip
  messages verbatim (Constitution: preserve exact solver status strings).
  **Executed by the user** in their own MATLAB R2024b session (`/usr/local/MATLAB/R2024b`,
  not reachable from this environment's sandboxed shell) on 2026-09-14. Full console
  transcript reviewed: the script ran end-to-end with no MATLAB error and no failed
  `assert()` — execution is confirmed to have passed through every new assertion (the
  conserved-only call, the relocated `prepareTest('needsMILP', true)`, the full-mode call,
  and all US2 equivalence checks, T007-T010) as well as every pre-existing regression
  section (feature 019 crn[c], feature 020 symmetry fixtures, feature 024 MACACI/rh_14817),
  ending in a clean return to the MATLAB prompt with no output after the MACACI dBTM
  incidence summary (the trailing feature-024 "phantom reacting" checks are plain
  `assert()` calls with no console output of their own, so a silent finish there is
  consistent with, not contrary to, a pass). No solver-skip message occurred (a MILP
  solver was available).
- [X] T013 [P] Verify MATLAB coding-standards compliance for the diff: no `evalc` used, no
  warnings suppressed, no `nargin` introduced (T004/T005 use `isfield`/`exist` per VII-D,
  matching the file's own existing pattern), no `try/catch` introduced (none is needed for
  this change).
- [X] T014 [P] Run the quickstart.md manual spot-check once and record its output
  (`reacting.computed`, the two `isequal` results).
  **Satisfied via T012's automated run rather than a separately executed interactive
  snippet**: quickstart.md's own "Automated check" section states the automated test's new
  assertions (T007-T010) confirm the identical four claims the manual spot-check would show
  interactively (`reacting.computed == false`; `isequal` on `arm.L`/`M2M`/`M2R`/
  `moietyFormulae`; the `L*N = 0` re-check). Since T012's run exercised those assertions and
  they did not fail, all four claims are confirmed. The manual interactive snippet itself
  (typing the four lines at a MATLAB prompt to see literal `0`/`1` printouts) was not
  separately run.
- [X] T015 Report files changed, checks run, tests passed/failed, and any behavior not yet
  verified (Constitution Principle III closing requirement).
- [X] T016 Create the implementation receipt at
  `specs/026-conserved-moieties-only-option/agent-runs/<UTC-timestamp>-<short-name>/implementation-receipt.md`
  with Prompt, Final response (verbatim), Diff summary, Tests, and Unresolved issues sections
  (Constitution Implementation Receipt Ledger).

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately.
- **Foundational (Phase 2)**: Empty — nothing blocks on it.
- **User Story 1 (Phase 3)**: Depends on Setup (T001-T003) only.
- **User Story 2 (Phase 4)**: Depends on User Story 1 (T004-T008) being complete — this
  feature's two stories are sequential, not parallel, because US2 tests what US1 builds.
- **Polish (Phase 5)**: Depends on both user stories being complete.

### Parallel Opportunities

- T001, T002, T003 (Setup) can run in parallel — read-only, different concerns.
- T013 and T014 (Polish) can run in parallel — independent checks.
- No other tasks are parallelizable: T004-T011 all edit one of two shared files in a fixed
  order (implementation before the tests that exercise it; US1's block before US2's, since
  US2's assertions are appended immediately after it in the same file).

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 (Setup).
2. Complete Phase 3 (User Story 1: T004-T008) — the option itself, working and tested in
   isolation.
3. **STOP and VALIDATE**: run the extended test file; User Story 1's new assertions should
   pass on their own even before Phase 4 exists.

### Full Delivery

1. Setup → User Story 1 → **checkpoint** → User Story 2 → **checkpoint** → Polish.
2. Because US2 depends on US1, there is no meaningful parallel-team split for this feature —
   it is a small, sequential, single-function change.

## Notes

- Every implementation task (T004-T006) and every test task (T007-T011) touches one of only
  two files, both already identified exactly — there is no ambiguity left for implementation
  to resolve.
- Per Constitution Principle VI, none of T004-T016 may begin until this tasks.md has been
  reviewed and implementation has been explicitly approved and invoked (Gate 2, then
  `/speckit-implement` or the agent-assign pipeline).
