# Tasks: Fix Empty-Selection Crashes in Reacting-Moieties Pipeline

**Input**: Design documents from `specs/024-fix-empty-selection-bugs/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/empty-output-schema.md](./contracts/empty-output-schema.md), [quickstart.md](./quickstart.md)

**Tests**: Required (Constitution III; spec FR-007). This feature fixes two
hard crashes (plus one latent third crash, FR-009) and must keep
`test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`
passing without weakening its existing assertions.

**Scope note**: Most tasks edit this repository (cobratoolbox). Five tasks
(T004, T015, T016, T020, T021) touch a **separate git repository**,
`~/repos/reconXmoieties`, per the FR-005 amendment recorded in
`checklists/requirements.md` — narrowly scoped to
`constructCanonicalMoietySignature.m:278-283` and its own test suite;
`compareMoietySignatures.m` is explicitly untouched throughout.

**Organization**: Tasks are grouped by user story (US1 = P1, US2 = P2) to
keep each independently testable, per spec.md's Acceptance Scenarios.

## Phase 1: Setup

**Purpose**: Confirm the implementation context before code edits.

- [X] T001 Read `specs/024-fix-empty-selection-bugs/spec.md`, `plan.md`, `research.md`, `data-model.md`, `contracts/empty-output-schema.md`, `quickstart.md`, and `checklists/requirements.md` (the two amendment notes)
- [X] T002 [P] Re-inspect `src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m` (STEP 4-6, currently lines ~1626-1705) and `src/analysis/topology/reactingMoieties/buildReactingMoietyTables.m` (lines 1-91 in full); confirm the exact current line numbers match plan.md's/research.md's citations before editing (they may have shifted since planning) — **confirmed: line numbers matched exactly**
- [X] T003 [P] Re-inspect `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m` in full; confirm the exact fixture variable names available for reuse (`reacting`, `formedBondsTable`, `brokenBondsTable`, `subModel`, `dATM`, `BG`) at the point where new assertions will be inserted
- [X] T004 [P] Confirm `~/repos/reconXmoieties` is checked out and locate its existing test convention under `moietySignature/tests/` (mirror pattern for the new/extended reconXmoieties test in Phase 4); confirm no registered MATLAB-linting skill exists beyond the openCOBRA style guide already cited in plan.md (Constitution VII-F) — **confirmed: `moietySignature/tests/scripts/stage5_pilot_*.m` + `moietySignature/tests/data/pilot_*_rxnfiles/` + `moietySignature/tests/results/logs/` (gitignored)**

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Prerequisites shared by both user stories.

**CRITICAL**: No user story implementation can begin until this phase is complete.

- [X] T005 Confirm a MILP-capable solver is configured for this MATLAB session (`changeCobraSolver`) so `prepareTest('needsMILP', true)` does not skip `testConservedReactingMoieties`; record which solver is used for the implementation receipt (T027) — **gurobi and glpk both installed; gurobi used throughout (glpk's MEX wrapper errors on the fully-unconstrained/zero-row MILP this feature's zero-selection case produces — an unrelated, out-of-scope solver limitation found empirically, not fixed here; see Unresolved Issues)**
- [X] T006 [P] Confirm the MATLAB coding-standards compliance plan for this feature (Constitution VII): no `evalc`, no warning suppression, no `try/catch` needed on either fixed path (both fixes are unconditional initialization/assignment, not exception handling), no `nargin` usage introduced, no function-signature changes (FR-006) — **confirmed against the actual applied diffs**
- [X] T007 Confirm this feature's reproducibility commands are exactly quickstart.md §1 and §2's two `runtests(...)` invocations — no new command needed beyond what quickstart.md already documents

**Checkpoint**: Foundation ready — both user stories can now proceed.

---

## Phase 3: User Story 1 - Zero-selection reactions no longer crash the moiety pipeline (Priority: P1) 🎯 MVP

**Goal**: `identifyConservedReactingMoieties` completes without error and
returns `reacting.ReactMoietySets`/`reacting.ReactMoietyGraphs` as `{}` when
the MILP set-cover selects zero reactions (FR-001, FR-002).

**Independent Test**: Run `identifyConservedReactingMoieties` on a case
where the set-cover selects zero reactions; confirm no error and both
fields are `{}` (spec US1 Acceptance Scenario 1).

### Tests for User Story 1

- [X] T008 [US1] Resolve research.md R1 empirically in a live MATLAB session (MATLAB R2024b was available at `/usr/local/MATLAB/R2024b`, not merely assumed unavailable): single-reaction subsets of the existing r0317/ACONTm/r0426 fixture each select themselves (never zero) — confirmed empirically, ruling out that fixture. **Found a real, better option than either planned fallback**: reconXmoieties' own staged reproduction data for the four US1 pairs (`~/repos/reconXmoieties/experiments/notebooks/data/exp_positive_control_broad/<PAIR>/rxnfiles/`) is available and, hand-built into a minimal combined model (Stage 3/Stage 5 pilot convention — metabolite names read from each RXN file's own $MOL header), reproduces the exact real crash end-to-end with the actual production function — no synthetic harness needed
- [X] T009 [US1] Added the zero-selection characterization test (MACACI/rh:14817) to `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m` (extended the existing file — no new file). Confirmed FAILING pre-fix (`Unrecognized function or variable 'RM_sets'`, live-executed) and PASSING post-fix (`isequal(reacting.ReactMoietySets, {})` / `isequal(reacting.ReactMoietyGraphs, {})`, FR-001/FR-002, US1 Acceptance Scenario 1)

### Implementation for User Story 1

- [X] T010 [US1] In `src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m`, added `RM_sets = {}; RM_graph = {};` immediately before the STEP-5 `for k = 1:length(selectedReactions)` loops (line 1674), so both variables are always defined regardless of whether `selectedReactions` is empty (FR-001)
- [X] T011 [US1] Added a `NOTE:` block to `identifyConservedReactingMoieties.m`'s help header (Constitution VII-E) documenting that `reacting.ReactMoietySets`/`reacting.ReactMoietyGraphs` are `{}` (a valid result, not an error) when the MILP set-cover selects zero reactions
- [X] T012 [US1] Ran T009's new assertion plus the full existing test file live: **PASSED** (1 Passed, 0 Failed, 0 Incomplete, 27.26s), including every pre-existing assertion (non-empty r0317/ACONTm/r0426 path, `L*N=0` invariant, moiety/subgraph counts, feature 019/020 regression sections) unchanged (US1 Acceptance Scenario 3). `lastwarn()` captured before/after: empty both times — no new/unexpected warning (SC-005)

**Checkpoint**: User Story 1 complete — zero-selection reactions no longer crash; non-empty path unaffected. This is a shippable MVP increment on its own.

---

## Phase 4: User Story 2 - Empty reacting-moiety tables carry the expected schema (Priority: P2)

**Goal**: `buildReactingMoietyTables` stores a typed-but-empty table
(including a `BondChange` column) whenever a selected reaction's formed/
broken bond subtables are both empty, or exactly one is empty (FR-003,
FR-004, FR-009); reconXmoieties' `constructCanonicalMoietySignature.m`
preserves that schema instead of collapsing it to a bare `table()`, so
`compareMoietySignatures.m`'s `reactingPatternSetEqual` (left untouched) can
compare two empty patterns without error (FR-005).

**Independent Test**: Run the pipeline on a reaction pair known to produce
two empty reacting-moiety tables; confirm `compareMoietySignatures` reaches
a verdict instead of throwing on `.BondChange` (spec US2 Acceptance
Scenario 2).

### Tests for User Story 2

- [X] T013 [US2] Added the both-empty-subtable characterization test to `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m` using the phantom-reaction technique (research.md R2): appended `'PHANTOM_NO_REACTING_BONDS'` to `reacting.selectedReactionNames`; asserted the resulting `reactMoietyTables` entry has zero rows and a `BondChange` variable (FR-003, FR-004, US2 Acceptance Scenario 1). Confirmed FAILING pre-fix (live-executed: `MATLAB:table:vertcat:SizeMismatch` — see T014, same call) and PASSING post-fix
- [X] T014 [US2] Added the one-empty-subtable (FR-009) characterization test to the same file/call, using the asymmetric phantom-row technique (research.md R3): one hand-appended row (copied from `formedBondsTable(1,:)`, only its `rxns` field overwritten) for `'PHANTOM_ONE_SIDE_EMPTY'`, zero matching rows in `brokenBondsTable`. Confirmed FAILING pre-fix — live-executed, real error: `Error using tabular/vertcat: All tables being vertically concatenated must have the same number of variables`, thrown from `buildReactingMoietyTables.m` line 36 — and PASSING post-fix (uniform `BondChange` column, one real row)
- [X] T015 [P] [US2] In `~/repos/reconXmoieties`, added `moietySignature/tests/scripts/stage5_pilot_empty_reacting_pattern_schema.m` (that repository's `stage5_pilot_*.m` convention) asserting `constructCanonicalMoietySignature`'s empty-`T` branch produces a `sig.reactingPattern` with columns `{BondChange, CanonicalBondElmts, IntraInterMoiety}` at 0 rows (Contract 3). **Upgraded beyond the plan**: uses the real RETI3/rh:55352 pair (spec.md's own named US2 reproduction case) run through the actual Stage 4 pipeline, not a hand-built synthetic `T` — stronger evidence, and doubles as this pair's SC-002 reproduction. Confirmed FAILING pre-amendment (live-executed: `Unrecognized table variable name 'BondChange'`, at `reactingPatternSetEqual` via `compareOneDirection` via `compareMoietySignatures`) and PASSING post-amendment
- [X] T016 [US2] In the same script as T015, added the `compareMoietySignatures(signatures(1), signatures(2))` call exercising `reactingPatternSetEqual` (`compareMoietySignatures.m`, unmodified) on the two typed-but-empty `reactingPattern` tables — confirmed it returns `combinedVerdict = "MATCH"`, `forward.reactMatch = true` (Contract 4, FR-005's acceptance condition), live-executed, no change to `compareMoietySignatures.m` required

### Implementation for User Story 2

- [X] T017 [P] [US2] In `src/analysis/topology/reactingMoieties/buildReactingMoietyTables.m`, removed the `~isempty(F)`/`~isempty(B)` guards around the `BondChange` assignment (now unconditional, including 0-row tables) and removed the `if isempty(T) ... reacting.reactMoietyTables{k} = table(); continue` special case, letting the existing non-empty-case processing pipeline run unconditionally for every `k`. Closes FR-003, FR-004, and FR-009 together by construction
- [X] T018 [US2] Added a `NOTE:` block to `buildReactingMoietyTables.m`'s help header (Constitution VII-E) documenting that `reactMoietyTables{k}` is always typed, including a `BondChange` column, even at zero rows
- [X] T019 [US2] Ran T013 and T014 (single call covers both): **PASSED** against the T017 fix (live-executed, part of the same full-file run as T012)
- [X] T020 [P] [US2] In `~/repos/reconXmoieties/moietySignature/functions/constructCanonicalMoietySignature.m`, removed the `if isempty(T) ... sig.reactingPattern = table(); ... continue` special case so the existing non-empty-case code path runs unconditionally, producing a properly typed 0-row `{BondChange, CanonicalBondElmts, IntraInterMoiety}` table when `T` is empty (FR-005 amendment). This is the **only** reconXmoieties file/branch touched; `compareMoietySignatures.m` remains unmodified (confirmed: `git diff --stat` shows only this one file changed in `moietySignature/functions/`)
- [X] T021 [US2] Ran T015 and T016 against the T020 fix: **PASSED** (live-executed via `stage5_pilot_empty_reacting_pattern_schema.m`, standalone)
- [X] T022 [US2] Ran the full `testConservedReactingMoieties.m`: **PASSED**, every pre-existing assertion unchanged (US2 Acceptance Scenario 3) — same run as T012. `lastwarn()` before/after: empty both times (SC-005)

**Checkpoint**: User Story 2 complete — both-empty and one-empty (FR-009) subtable cases are schema-consistent end-to-end through reconXmoieties' `compareMoietySignatures.m`, without modifying that file.

---

## Phase 5: Polish & Cross-Cutting Concerns

- [X] T023 [P] Ran quickstart.md §1 (cobratoolbox `runtests(...)`, plus the whole `testReactingMoieties` directory for extra non-regression confidence: 4/4 files passed) and §2 (reconXmoieties `stage5_pilot_empty_reacting_pattern_schema.m`) end-to-end: **all passed**, no new/unexpected MATLAB warnings in either (SC-005)
- [X] T024 [P] **Upgraded from "recommended follow-up" to actually performed**: live-executed all 9 known-affected pairs (MACACI/rh:14817, RPE/rh:13677, UDPG4E/rh:22168, UAG4E/rh:20517, RETI3/rh:55352, RETI2/rh:55348, RETI1/rh:19141, MMEm/rh:20553, RE2624M/rh:40455) through the real fixed pipeline. **All 9/9 PASS**: the 4 US1 pairs each select 0 reactions with `{}` outputs; the 5 US2 pairs each select 2 reactions with both `reactMoietyTables` typed-but-empty, reaching `combinedVerdict = "MATCH"` via `compareMoietySignatures`
- [X] T025 Confirmed no previously-passing pair changes verdict (SC-004) — T012/T022's non-regression assertions passed, plus the whole-directory non-regression run (T023). The broader 300-pair `exp_positive_control_broad` re-run (SC-003) was **not** performed (would require access to reconXmoieties' full experiment harness/notebook execution beyond this feature's scope) — explicitly deferred, consistent with spec Assumptions ("a full notebook re-run is not required to verify the fix")
- [X] T026 Reported files changed (both repositories), checks run, tests passed/failed, and behavior not yet verified — see implementation receipt (T027) and final response
- [X] T027 Implementation receipt created at `specs/024-fix-empty-selection-bugs/agent-runs/20260904T115735Z-fix-empty-selection-bugs/implementation-receipt.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Setup — BLOCKS both user stories
- **User Story 1 (Phase 3)**: Depends on Foundational only — no dependency on US2
- **User Story 2 (Phase 4)**: Depends on Foundational only — no dependency on US1 (independently testable per spec, though both fixes share the same "empty output isn't schema-safe" root-cause diagnosis)
- **Polish (Phase 5)**: Depends on both user stories being complete

### Within User Story 2

- T013/T014 (cobratoolbox tests) and T015/T016 (reconXmoieties tests) are independent of each other (different repositories) — either pair can go first
- T017 (cobratoolbox fix) and T020 (reconXmoieties fix) are independent of each other (different files, different repos) — can be done in parallel
- T019 depends on T017 (and T013/T014 existing); T021 depends on T020 (and T015/T016 existing)

### Parallel Opportunities

- Setup: T002, T003, T004 in parallel after T001
- Foundational: T006 in parallel with T005/T007
- User Story 1 and User Story 2 can proceed in parallel once Foundational is complete (no file overlap between `identifyConservedReactingMoieties.m` and `buildReactingMoietyTables.m`/reconXmoieties)
- Within US2: T015 and T017 and T020 touch three different files across two repositories and have no dependency on each other — parallelizable
- Polish: T023 and T024 in parallel

---

## Parallel Example: User Story 2

```bash
# Once Foundational is done, these three can start together (different files/repos):
Task: "Add empty-branch test to constructCanonicalMoietySignature.m's test suite in ~/repos/reconXmoieties (T015)"
Task: "Remove isempty guards in buildReactingMoietyTables.m (T017)"
Task: "Remove isempty(T) special case in constructCanonicalMoietySignature.m (T020)"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 (Setup) + Phase 2 (Foundational)
2. Complete Phase 3 (User Story 1) — T008-T012
3. **STOP and VALIDATE**: run T012; confirm US1's independent test passes with no regression
4. This alone resolves 4/9 of the originally-observed crashing pairs (MACACI, RPE, UDPG4E, UAG4E) and is shippable independently

### Incremental Delivery

1. Setup + Foundational → both stories unblocked
2. User Story 1 → validate independently → MVP-shippable
3. User Story 2 (cobratoolbox side T013/T014/T017-T019, reconXmoieties side T015/T016/T020-T021) → validate independently → resolves the remaining 5/9 pairs
4. Polish (T023-T027) → quickstart validation, non-regression confirmation, implementation receipt

---

## Notes

- [P] tasks touch different files with no dependency on an incomplete task
- [Story] label maps each task to US1 or US2 for traceability to spec.md
- No new test files are created anywhere in this feature (Constitution
  III-Naming): all cobratoolbox assertions extend
  `testConservedReactingMoieties.m`; all reconXmoieties assertions extend
  that repository's existing test file(s) under `moietySignature/tests/`
- `compareMoietySignatures.m` is read-only throughout this feature — no task
  above edits it, only tests exercise it (T016, T021)
- Every "Tests" task must be confirmed FAILING against pre-fix source before
  its paired implementation task, and PASSING after — recorded in the
  implementation receipt (T027)
