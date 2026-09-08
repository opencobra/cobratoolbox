---

description: "Task list for 022-eliminate-table-object-hotspots"

---

# Tasks: Eliminate table-object dot-indexing and cell.ismember hotspots in RXN parsing

**Input**: Design documents from `/specs/022-eliminate-table-object-hotspots/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md,
contracts/unchanged-public-contracts.md, quickstart.md

**Tests**: The existing CI-covered regression test
(`test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`)
MUST keep passing unchanged (FR-009/SC-001) — no new CI test is added because
this feature introduces no new `src/` module (research.md R4). The non-CI
Tyrosine benchmark reproducibility check (FR-010) is the documented
Constitution Principle III substitute for the externally-dependent,
multi-minute benchmark.

**Organization**: Tasks are grouped by user story (US1 = P1, US2 = P2) per `spec.md`.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2)
- Include exact file paths in descriptions

## Path Conventions

Single MATLAB toolbox project. Both source changes are under
`src/analysis/topology/reactingMoieties/`; feature artifacts are under
`specs/022-eliminate-table-object-hotspots/`.

---

## Phase 1: Setup

**Purpose**: Read and map the exact current state of both files this feature touches before any edit (Constitution Principle V: "the relevant file(s) MUST be read and mapped before editing... for algorithmic changes").

- [X] T001 Read and map the current implementation of
  `src/analysis/topology/reactingMoieties/readABRXNFile.m` (per-bond loop,
  currently lines ~250-259) and
  `src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m`
  (atom-transition loop, currently lines ~217-355; bond-transition loop,
  currently lines ~547-693) to confirm the line ranges and variable names in
  `plan.md`/`research.md`/`data-model.md` still match the working tree
  exactly before editing either file.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Create the non-CI reproducibility script and capture the pre-change golden snapshot before either source file is modified.

**⚠️ CRITICAL**: No user story work (Phase 3/4) may begin until this phase is complete — in particular, the golden snapshot (T003) MUST be captured while both files are still unmodified (FR-010a).

- [X] T002 [P] Create
  `specs/022-eliminate-table-object-hotspots/tyrosineReproducibilityCheck.m`
  per `research.md` R3 / `quickstart.md` step 4: reuse feature 021's
  `tyrosineReproducibilityCheck.m` as a structural template (model-loading
  block, capture-vs-compare mode selection by golden-snapshot presence,
  append-only results file), but capture `dATM.Nodes`, `dATM.Edges`,
  `dBTM.Nodes`, `dBTM.Edges` directly plus a representative sample of
  `readABRXNFile`-returned `atoms`/`bonds` tables (data-model.md E1/E4);
  wrap the `buildAtomAndBondTransitionMultigraph` call (which itself calls
  `readABRXNFile`/`addBondMappingsRXNFile`) in MATLAB's `profile on`/
  `profile off`, then read `profile('info').FunctionTable` for the
  `cell.ismember`, `tabular.dotAssign`, and `tabular.dotReference` entries
  to report before/after call counts (FR-010c) instead of a hand-rolled
  counter. Measure wall-clock time by running the parsing/graph-building
  portion at least twice per mode and reporting the average (SC-004); the
  profiled call counts are deterministic per input and need only one
  capture per mode. Support a "capture baseline" mode (writes
  `tyrosine-golden-snapshot.mat`) and a "compare" mode (asserts structural
  equality against that snapshot and appends results to
  `tyrosine-reproducibility-results.md`, so it can be invoked more than
  once as each user story lands).
- [X] T003 Run
  `specs/022-eliminate-table-object-hotspots/tyrosineReproducibilityCheck.m`
  in "capture baseline" mode against the current, unmodified code to produce
  `specs/022-eliminate-table-object-hotspots/tyrosine-golden-snapshot.mat`
  (FR-010a). Depends on T002.
- [X] T004 [P] Verify MATLAB coding standards groundwork applicable to both
  planned edits (Principle VII): confirm no `evalc` or suppressed warnings
  will be introduced, the existing `ME.stack`-propagating try/catch blocks
  in `buildAtomAndBondTransitionMultigraph.m` stay untouched, no bare
  `nargin` is introduced, and no project MATLAB-lint skill has since been
  registered (VII-F) beyond the openCOBRA style guide already bound by
  reference (VII-G).

**Checkpoint**: Foundation ready — reproducibility script exists, pre-change golden snapshot captured, both files mapped. User story implementation can now begin.

---

## Phase 3: User Story 1 - readABRXNFile's per-bond atom lookup stops re-scanning the whole molecule (Priority: P1) 🎯 MVP

**Goal**: `readABRXNFile.m`'s per-bond loop stops doing two redundant
`find(...&ismember(...))` linear scans over the whole atoms table per bond,
and stops repeating the identical head-atom/tail-atom search a second time
just to read a second column.

**Independent Test**: `testConservedReactingMoieties.m` passes unchanged;
`readABRXNFile` called directly on a sample RXN file before/after this
change returns field-for-field identical `atoms`/`bonds` tables, with a
measurably lower `cell.ismember` call count attributable to `readABRXNFile`.

### Implementation for User Story 1

- [X] T005 [US1] Implement FR-001 in
  `src/analysis/topology/reactingMoieties/readABRXNFile.m`: immediately
  after `atoms` is constructed (current line ~243), build
  `atomIndexMap = containers.Map('KeyType','char','ValueType','any')` in one
  pass over `atoms`'s rows, keyed by
  `sprintf('%s\x1f%d\x1f%d', atoms.mets{r}, atoms.metNrs(r), atoms.instances(r))`,
  appending to (never overwriting) an existing key's value so duplicate
  keys accumulate every matching row index (research.md R1, data-model.md
  E2). Replace the per-bond loop (current lines ~254-259) with two
  `isKey`-guarded lookups per bond (`headKey`/`tailKey`, resolving to `[]`
  on a miss rather than a `containers.Map` "key not present" error), feeding
  the same `atoms.atomTransitionNrs(headIdx)`/`atoms.elements(headIdx)`-style
  expressions the current code already uses, so the exact existing
  duplicate-key and no-match error behavior is reproduced unchanged
  (FR-002, Edge Cases, Acceptance Scenario 3).
- [X] T006 [P] [US1] Run
  `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`
  against the post-T005 code; confirm PASS with every existing assertion
  intact, test file byte-for-byte unmodified (FR-009/SC-001). Depends on T005.
- [X] T007 [P] [US1] Perform the direct before/after `readABRXNFile`
  comparison from `quickstart.md` step 2 on a sample atom-mapped RXN file
  with more than one bond: assert `headAtomTransitionNrs`,
  `tailAtomTransitionNrs`, `headAtomElements`, `tailAtomElements` are
  identical, value for value, in the same row order (Acceptance Scenario 1).
  Depends on T005.
- [X] T008 [P] [US1] Manually verify Edge Cases/Acceptance Scenarios 3-4 via
  `quickstart.md` step 5: a bond referencing an atom that does not exist in
  `atoms` still fails the same way as today; a synthetic
  `(met, metNr, instance)` duplicate key still errors the same way as today
  rather than silently picking a match; a zero-bond RXN file still returns
  the same trivial `bonds` table with no indexing error. Depends on T005.
- [X] T009 [US1] Run
  `specs/022-eliminate-table-object-hotspots/tyrosineReproducibilityCheck.m`
  in "compare" mode against the post-T005 (User Story 1 only) code: confirm
  it runs without structural-equality failures on the parts already fully
  exercised, and record the interim `cell.ismember`/`tabular.dotAssign`/
  `tabular.dotReference` call-count reduction attributable to
  `readABRXNFile` alone (Acceptance Scenario 2) — note this interim run's
  numbers are reported, not the final gate: SC-002/SC-003's combined ≥90%/
  ≥70% thresholds and SC-005's full `dATM`/`dBTM` identity are only fully
  verifiable once User Story 2 (Phase 4) also lands. Depends on T003, T006.

**Checkpoint**: User Story 1 is fully functional and independently testable — identical `atoms`/`bonds` output, measurably fewer `cell.ismember` calls attributable to `readABRXNFile`.

---

## Phase 4: User Story 2 - buildAtomAndBondTransitionMultigraph stops building its EdgeTable one dot-indexed row at a time (Priority: P2)

**Goal**: Both of `buildAtomAndBondTransitionMultigraph.m`'s per-reaction
loops (atom-transition and bond-transition) accumulate each transition's
fields in plain preallocated arrays during the loop, constructing the
`EdgeTable`/`dATM`/`dBTM` objects only once after each loop completes.

**Independent Test**: `testConservedReactingMoieties.m` passes unchanged;
`dATM.Nodes`, `dATM.Edges`, `dBTM.Nodes`, `dBTM.Edges` are identical before
and after this change, with measurably fewer `tabular.dotAssign`/
`tabular.dotReference`/`cell.ismember` calls attributable to
`buildAtomAndBondTransitionMultigraph`.

### Implementation for User Story 2

- [X] T010 [US2] Implement FR-003 in
  `src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m`'s
  atom-transition loop (currently lines ~217-355): replace the pre-loop
  `EdgeTable = table(cell(nTotalAtomTransitions,...), zeros(nTotalAtomTransitions,...), ...)`
  construction with one plain local preallocated array/cell per column
  (same `nTotalAtomTransitions` size and type as today, per data-model.md
  E3), replace every in-loop `EdgeTable.col(k) = ...`/
  `EdgeTable.col{k} = ...` write with a plain array/cell write to the local
  variable, and construct `EdgeTable = table(col1, col2, ...,
  'VariableNames', {...})` exactly once, immediately after the loop, using
  the identical column order and `'VariableNames'` list the current pre-loop
  `table(...)` call already passes (research.md R2). Leave the existing
  `if nTotalAtomTransitions ~= k-1, warning(...)` check (current line ~353)
  and the existing try/catch log-and-skip block untouched (FR-005, FR-007,
  FR-008).
- [X] T011 [US2] Implement FR-004 in the same file's bond-transition loop
  (currently lines ~547-693) using the identical technique as T010, for its
  own `EdgeTable`/`dBTM` (preallocated at `nTotalBondTransitions`). Leave the
  existing try/catch log-and-skip block untouched (FR-005, FR-008); do not
  add a new post-loop mismatch warning for this loop — none exists today,
  and FR-007 only requires the *existing* atom-transition warning to keep
  firing (research.md R2). Depends on T010 (same file — sequential to avoid
  concurrent edits).
- [X] T012 [US2] Run
  `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`
  against the post-T010/T011 code; confirm PASS with every existing
  assertion intact, test file byte-for-byte unmodified (FR-009/SC-001).
  Depends on T010, T011.
- [X] T013 [US2] Verify FR-007 and FR-008 by code-tracing only — confirmed
  no test in `test/` currently exercises either loop's parse-failure or
  preallocation-mismatch path (grep of `testConservedReactingMoieties.m`
  for any parse-failure string returns nothing; commit `e95da5fa6` states
  neither crash-fix try/catch path has fired in any run to date, since
  real RXN files all parse cleanly). Trace that: (a) the
  `nTotalAtomTransitions ~= k-1` warning (FR-007) is driven by the same
  `k` the plain-array accumulator now advances identically to the
  pre-change table-based `k`, so it still fires under the same conditions;
  (b) a caught per-reaction parse failure in either loop (FR-008) leaves
  already-accumulated earlier-reaction array slots untouched and skips
  only the failed reaction's own slots, matching pre-change behavior
  exactly. Record in T017 that FR-007/FR-008 are verified by inspection
  only, with no automated or real-data trigger for either path before or
  after this change (Constitution Principle III: state the remaining gap
  explicitly). Depends on T010, T011.
- [X] T014 [US2] Run
  `specs/022-eliminate-table-object-hotspots/tyrosineReproducibilityCheck.m`
  in "compare" mode against the post-T010/T011 (User Story 1 + User Story 2)
  code — the final combined run: assert `dATM.Nodes`, `dATM.Edges`,
  `dBTM.Nodes`, `dBTM.Edges`, and the sampled `atoms`/`bonds` tables are
  identical to the golden snapshot (SC-005); confirm the combined
  `cell.ismember` call-count reduction attributable to `readABRXNFile` +
  `buildAtomAndBondTransitionMultigraph` is ≥90% (SC-002) and the combined
  `tabular.dotAssign`/`tabular.dotReference` reductions are each ≥70%
  (SC-003); confirm wall-clock time for the parsing/graph-building portion
  is reported, averaged over at least 2 runs, and is not itself a pass/fail
  gate (SC-004). Results appended to
  `tyrosine-reproducibility-results.md`. Depends on T009, T012.

**Checkpoint**: Both user stories are independently functional — identical output, combined performance targets met (SC-002, SC-003, SC-005).

---

## Phase 5: Polish & Cross-Cutting Concerns

- [X] T015 [P] Run the scope-boundary check from `quickstart.md` step 3
  (`git diff --name-only master... -- src/ | grep -v -E
  "src/analysis/topology/reactingMoieties/(readABRXNFile|buildAtomAndBondTransitionMultigraph)\.m"`)
  and confirm empty output — no `src/` file other than the two named
  functions was modified, including `checkABRXNFiles.m` and
  `addBondMappingsRXNFile.m`'s own internal redundant `readABRXNFile` call
  (SC-006, FR-011), and everything already covered by feature
  021-prefilter-isomorphism-classification.
- [X] T016 [P] Confirm `contracts/unchanged-public-contracts.md`'s claims
  hold: `readABRXNFile`'s and `buildAtomAndBondTransitionMultigraph`'s
  function signatures (inputs, outputs) are byte-for-byte unchanged from
  before this feature (FR-006) — diff each function's `function [...] =
  ...(...)` declaration line against its pre-feature version.
- [X] T017 Report files changed, checks run, tests passed, tests failed, and
  any behaviors not yet verified (Principle III), including whether the
  Tyrosine benchmark paths were available in this environment or had to be
  adjusted per `spec.md`'s Assumptions section. Depends on T015, T016.
- [X] T018 Create the implementation receipt at
  `specs/022-eliminate-table-object-hotspots/agent-runs/<UTC-timestamp>-eliminate-table-object-hotspots/implementation-receipt.md`
  with the mandatory sections (Prompt, Final response, Diff summary, Tests,
  Unresolved issues), copying the actual final user-facing completion
  response verbatim into `Final response` (Implementation Receipt Ledger).
  Depends on T017.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately.
- **Foundational (Phase 2)**: Depends on Setup (T001). T003 (golden
  snapshot) MUST complete before either T005 or T010/T011 modify their
  respective files. BLOCKS all user stories.
- **User Story 1 (Phase 3)**: Depends on Foundational completion
  (T002, T003).
- **User Story 2 (Phase 4)**: Depends on Foundational completion
  (T002, T003). Independent of User Story 1's own edits (different file),
  but T014's *combined* SC-002/SC-003/SC-005 verification depends on T009
  (User Story 1's interim reproducibility run) and T012.
- **Polish (Phase 5)**: Depends on both user stories being complete.

### Within Each Phase

- T006, T007, T008 each depend only on T005 and touch no shared file — safe
  to run in parallel.
- T009 depends on T003 (baseline) and T006 (tests passing first).
- T010 and T011 both edit `buildAtomAndBondTransitionMultigraph.m` — T011
  runs after T010 to avoid concurrent edits to the same file, even though
  the two loops are otherwise independent.
- T012 and T013 depend on both T010 and T011.
- T014 depends on T009 (so the results file already has User Story 1's
  interim entry) and T012.

### Parallel Opportunities

- T002 and T004 can run in parallel (different files, no shared state).
- T006, T007, T008 can run in parallel once T005 is done.
- T015 and T016 can run in parallel once both user stories are complete.

---

## Parallel Example: User Story 1

```bash
# Once T005 is done, launch all three verification tasks together:
Task: "Run testConservedReactingMoieties.m against the post-T005 code"
Task: "Direct before/after readABRXNFile comparison on a sample RXN file"
Task: "Manually verify Edge Cases/Acceptance Scenarios 3-4"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001).
2. Complete Phase 2: Foundational (T002-T004) — the reproducibility script
   and the pre-change golden snapshot are the hard prerequisites.
3. Complete Phase 3: User Story 1 (T005-T009) — the smaller, more contained
   of the two fixes, and the dominant single contributor to both hotspots.
4. **STOP and VALIDATE**: `testConservedReactingMoieties.m` passes
   unchanged, and the interim reproducibility run shows a `readABRXNFile`-
   attributable `cell.ismember` reduction with identical `atoms`/`bonds`
   output.

### Incremental Delivery

1. Setup + Foundational → reproducibility script exists, baseline captured.
2. User Story 1 → measurable `readABRXNFile` performance win, zero output
   change (MVP).
3. User Story 2 → measurable `buildAtomAndBondTransitionMultigraph`
   performance win, zero output change; combined with User Story 1, the
   full SC-002/SC-003 thresholds are met.
4. Polish → scope-boundary check, signature-stability check, report,
   implementation receipt.

---

## Notes

- [P] tasks = different files (or read-only verification with no shared
  write target), no dependencies.
- [Story] label maps task to specific user story for traceability.
- User Story 2's two loops (T010, T011) share one file, so they run
  sequentially even though they are otherwise independent of each other.
- Commit after each task or logical group.
- Stop at the Phase 3 checkpoint to validate User Story 1 independently
  before proceeding to Phase 4.
- Avoid: editing any `src/` file outside `readABRXNFile.m` and
  `buildAtomAndBondTransitionMultigraph.m` (SC-006); changing either
  function's public signature (FR-006); touching
  `addBondMappingsRXNFile.m`'s own internal redundant `readABRXNFile` call
  (FR-011) or anything under `specs/021-prefilter-isomorphism-classification/`.
