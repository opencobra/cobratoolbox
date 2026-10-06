---

description: "Task list for the Tier-1 test coverage pilot (5 functions)"
---

# Tasks: Tier-1 test coverage pilot (5 functions)

**Input**: Design documents from `/specs/20261006-145354-tier1-test-pilot/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [quickstart.md](quickstart.md)

**Tests**: The deliverable IS the tests. Each test file is the narrowest check for its
function (Principle III). No `src` file may change (III-Characterization).

**Organization**: One user story per phase. Every test file follows the shape in
data-model.md: header (purpose, Tier 1, function under test, coverage exemptions,
authors/date), the `currentDir`/`cd` boilerplate used by sibling tests, `%%` sections
per branch with commented assertion groups, `cd(currentDir)`. Expected values come from
[research.md](research.md); use `verifyCobraFunctionError` for error paths; clear large
variables; hand-built inputs only; no solver, no model, no files written.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: US1, US2, US3 from spec.md

## Phase 1: Setup

- [ ] T001 Confirm the baseline: `git diff --stat -- src` is empty, MATLAB R2025a runs, and `initCobraToolbox(false)` succeeds from the repo root; record the result in the receipt (no file change).
- [ ] T002 Prepare a throwaway coverage runner outside the repo (in the session scratchpad, not committed) that takes a test path and a source path and runs `matlab.unittest.TestRunner` with `CodeCoveragePlugin.forFile` as in quickstart.md step 3, printing covered/uncovered executable line numbers.

---

## Phase 2: Foundational

**Purpose**: Gate checks that apply to every test file before writing them.

- [ ] T003 Consult the MATLAB best-practice skill per the constitution (VII-F) and confirm the rules every test must follow: no `evalc`, warnings visible, no `nargin`, try/catch only via `verifyCobraFunctionError`. Note the outcome in the receipt.
- [ ] T004 Read one sibling test from each target folder (`test/verifiedTests/base/testTools/testSplitString.m`, `test/verifiedTests/reconstruction/testModelGeneration/testVerifyModel.m`) and match their header and boilerplate style.

**Checkpoint**: Ready to write the tests.

---

## Phase 3: User Story 1 - Type-dispatch and ID-lookup helpers (Priority: P1) 🎯 MVP

**Goal**: Pin `getDefaultValue` and `getIDPositions`.

**Independent Test**: `runtests` on each file passes; coverage per function is 100% or every uncovered line is documented in the header.

- [ ] T005 [P] [US1] Create `test/verifiedTests/base/testTools/testGetDefaultValue.m` (source: `src/base/utilities/getDefaultValue.m`). Sections: numeric of several classes and shapes (including `int8` 2x2, empty 0x3: NaN of the same class and size); scalar string and string array (`""`, string arrays collapse to scalar); char (`''`); logical (false of the same size); nested cell (recursion, stays a cell); unsupported types struct and function handle (error identifier `MATLAB:unassignedOutputs`, commented as an existing defect pinned and not fixed).
- [ ] T006 [P] [US1] Create `test/verifiedTests/reconstruction/testModelManipulation/testGetIDPositions.m` (source: `src/reconstruction/refinement/getIDPositions.m`). Hand-built struct stub with `rxns`, `mets`, `evars`, `ctrs`, cellstr field `foo`, numeric field `bar`. Sections: `rxns` without and with `evars` (`{'R2','E1','zz'}` -> `[2 3 0]`, `[true true false]`); `mets` without and with `ctrs`; generic cellstr field; error for non-cellstr field and for missing field via `verifyCobraFunctionError` (message "Basefield has to be a  field representing a cell array of strings in the model", note double space).
- [ ] T007 [US1] Run both tests with `runtests` and measure coverage with the T002 runner; fix test gaps until 100% (or document exemptions in the header).

**Checkpoint**: US1 independently verified.

---

## Phase 4: User Story 2 - String-parsing helpers (Priority: P2)

**Goal**: Pin `getMetAbbr` and `verifyRuleSyntax`.

**Independent Test**: As US1.

- [ ] T008 [P] [US2] Create `test/verifiedTests/reconstruction/testModelManipulation/testGetMetAbbr.m` (source: `src/reconstruction/refinement/getMetAbbr.m`). Sections: char input returns char for both outputs; cell input returns column cells and a sorted de-duplicated unique list (`{'atp[c]';'adp[c]';'atp[m]'}`); an ID without brackets returns empty output silently (current behaviour, commented).
- [ ] T009 [P] [US2] Create `test/verifiedTests/reconstruction/testModelGeneration/testVerifyRuleSyntax.m` (source: `src/reconstruction/modelGeneration/modelVerification/verifyRuleSyntax.m`). Run `clear verifyRuleSyntax` before every case (FR-008). Sections: empty rule -> true; valid rule `(x(1) | x(2)) & x(3)` -> true; invalid `x(1) &&& x(2)` and `1 & (` -> false; `x(20000) | x(1)` -> true through the regrow retry; order independence (re-run a case after clearing).
- [ ] T010 [US2] Run both tests and measure coverage as in T007; confirm the retry branch lines are covered.

**Checkpoint**: US2 independently verified.

---

## Phase 5: User Story 3 - Array-extension helper and its failure path (Priority: P3)

**Goal**: Pin `extendIndicesInDimenion`.

**Independent Test**: As US1.

- [ ] T011 [US3] Create `test/verifiedTests/base/testTools/testExtendIndicesInDimenion.m` (source: `src/base/utilities/extendIndicesInDimenion.m`). Sections: numeric extension in dimension 1 and 2 (new entries hold the value, original entries unchanged); cell extension; table extension (height grows by `sizeIncrease`); `sizeIncrease = 0` returns the input; class mismatch (`{1}` into numeric) via `verifyCobraFunctionError` with message "extendIndicesInDimenion: Input class must be the same as value class". Header exemption: the catch block prints `input class is:`/`value class is:` and `ans` to the console; not suppressed because VII-A forbids `evalc`.
- [ ] T012 [US3] Run the test and measure coverage as in T007; confirm the `catch` lines are covered.

**Checkpoint**: US3 independently verified.

---

## Phase 6: Polish & Cross-Cutting

- [ ] T013 Verify `git diff --stat -- src` is empty and no stray files were created (SC-003, FR-007); confirm each new file name matches III-Naming and its function name appears in only that one test file.
- [ ] T014 Confirm the harness discovers the five files (`test/testAll.m` / `.github/scripts/select_tests.py` selection) without any registration change; run all five together once and record total time (SC-004).
- [ ] T015 Read each header and first screen for SC-005 (purpose, tier, exemptions visible without reading the source); confirm comments exist on every assertion group.
- [ ] T016 Write the implementation receipt at `specs/20261006-145354-tier1-test-pilot/agent-runs/<UTC-timestamp>-tier1-test-pilot/implementation-receipt.md` with Prompt, Final response, Diff summary, Tests, Unresolved issues; report files changed, checks run, tests passed/failed, behaviours not verified.
- [ ] T017 Stop for user validation of the five tests (FR-009, SC-006). Do not add further functions until the user approves.

---

## Dependencies & Execution Order

- Phase 1 -> Phase 2 -> US phases -> Phase 6. T002 is needed by T007, T010, T012.
- US1, US2 and US3 are independent of each other; within a story the `[P]` test files are in different files and can be written in parallel. Suggested order is priority order, easiest first: T005, T006, T007, then T008, T009, T010, then T011, T012.
- T016 and T017 come last.

## Parallel Example

```text
T005 testGetDefaultValue.m   ||   T006 testGetIDPositions.m
T008 testGetMetAbbr.m        ||   T009 testVerifyRuleSyntax.m
```

## Implementation Strategy

MVP is User Story 1 (two simplest functions): write, run, measure, show the user the style, then proceed to US2 and US3. Total: 17 tasks (setup 2, foundational 2, US1 3, US2 3, US3 2, polish 5). Implementation requires an explicit `/speckit-implement` (or the agent-assign pipeline) after approval.
