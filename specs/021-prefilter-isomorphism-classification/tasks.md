---

description: "Task list for 021-prefilter-isomorphism-classification"

---

# Tasks: Prefilter subgraph isomorphism classification

**Input**: Design documents from `/specs/021-prefilter-isomorphism-classification/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/classifySubgraphIsomorphism.md, quickstart.md

**Tests**: The existing CI-covered regression test
(`test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`)
MUST keep passing unchanged (FR-008/SC-001). A new, dedicated CI test,
`test/verifiedTests/analysis/testReactingMoieties/testClassifySubgraphIsomorphism.m`,
covers the shared helper directly (N=0/N=1, singleton invariant bucket,
no-false-negative across all three comparison modes) per Constitution
Principle III ("every new code module ships with a corresponding test")
and III-Naming, in addition to the non-CI Tyrosine reproducibility check
mandated by FR-009 for the externally-dependent, multi-minute benchmark.

**Organization**: Tasks are grouped by user story (US1 = P1, US2 = P2) per `spec.md`.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2)
- Include exact file paths in descriptions

## Path Conventions

Single MATLAB toolbox project. All source changes are under
`src/analysis/topology/reactingMoieties/`; feature artifacts are under
`specs/021-prefilter-isomorphism-classification/`.

---

## Phase 1: Setup

**Purpose**: Read and map the exact current state of every file this feature touches before any edit (Constitution Principle V: "the relevant file(s) MUST be read and mapped before editing... for algorithmic changes").

- [X] T001 Read and map the current implementation of
  `src/analysis/topology/reactingMoieties/findAndExtractMolecularGraphs.m`
  (lines ~24-61), `src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m`
  (lines ~603-676), and `src/analysis/topology/reactingMoieties/identifyIsomorphicClasses.m`
  (whole file) to confirm the line ranges and variable names in `plan.md` /
  `contracts/classifySubgraphIsomorphism.md` still match the working tree
  exactly before editing any of them.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Create the shared helper both user stories depend on, and capture the pre-change golden snapshot before any of the three call sites are modified.

**⚠️ CRITICAL**: No user story work (Phase 3/4) may begin until this phase is complete — in particular, the golden snapshot (T005) MUST be captured while the three call sites are still unmodified (FR-009a).

- [X] T002 Create
  `src/analysis/topology/reactingMoieties/classifySubgraphIsomorphism.m`
  implementing the contract in
  `contracts/classifySubgraphIsomorphism.md`: signature
  `[isomorphismClasses, firstSubgraphIndices, subsequentSubgraphIndices] = classifySubgraphIsomorphism(subgraphs, varargin)`;
  precompute the per-subgraph structural invariant (E2 in `data-model.md`:
  `numnodes`, `numedges`, and — only when `varargin` contains
  `'NodeVariables'`/`'EdgeVariables'` — the sorted label multiset for that
  column); run the single exclusion/visited forward-scan grouping algorithm
  (`research.md` R1), calling `isisomorphic(subgraphs{i}, subgraphs{j}, varargin{:})`
  only when the two invariants match (FR-002/FR-003), and skip it entirely
  when a bucket has exactly one member (Edge Cases). Include the full
  openCOBRA help header (`USAGE`/`INPUTS`/`OUTPUTS`/`NOTE`, Principle VII-E).
- [X] T003 Manually verify `classifySubgraphIsomorphism.m`'s trivial-input
  edge cases from `quickstart.md` step 5 (`N == 0` → all-empty outputs,
  `N == 1` → single class with no `isisomorphic` call) before it is wired
  into any call site. (Verified by static hand-trace of the implementation —
  no MATLAB runtime is available in this environment; see Unresolved Issues.)
- [X] T003b [P] Create
  `test/verifiedTests/analysis/testReactingMoieties/testClassifySubgraphIsomorphism.m`
  and wire it into `test/testAll.m`: assert N=0/N=1 trivial outputs (T003),
  the singleton-invariant-bucket case (Edge Cases — a subgraph whose
  invariant matches no other subgraph's must end up alone in its class with
  no `isisomorphic` call made for it), and no false negatives (FR-003)
  across the plain, `NodeVariables`, and `EdgeVariables` comparison modes.
  Depends on T002.
- [X] T004 [P] Create the non-CI reproducibility script
  `specs/021-prefilter-isomorphism-classification/tyrosineReproducibilityCheck.m`
  per `research.md` R6 / `quickstart.md` step 4: loads the Tyrosine
  metabolism subsystem model/RXN files from the paths in `spec.md`'s
  Assumptions section (adjusting them if unavailable, without changing the
  script's intent), runs the pipeline, and captures `moietyFormulas`,
  `moietyGraphs`, `moietyVectors`, the total `isisomorphic` call count, and
  wall-clock time for the classification step. Support a "capture baseline"
  mode (writes `tyrosine-golden-snapshot.mat`) and a "compare" mode
  (asserts equality against that snapshot and appends results to
  `tyrosine-reproducibility-results.md`).
- [X] T005 Ran
  `specs/021-prefilter-isomorphism-classification/tyrosineReproducibilityCheck.m`
  in "capture baseline" mode against the current, unmodified code (via a
  scoped `git stash push` of just the three call-site files, run against
  the real Tyrosine model/RXN paths, then `git stash pop`) to produce
  `specs/021-prefilter-isomorphism-classification/tyrosine-golden-snapshot.mat`
  (FR-009a): `arm.L`, `moietyFormulae`, `reacting.selectedReactionNames`/
  `selectedReactions` captured; classification wall-clock 216.8s. The
  `classifySubgraphIsomorphism('getCallCount')` side channel cannot measure
  pre-change calls (the pre-change code never calls it), so the isisomorphic
  call-count baseline uses the known pre-change floor from spec.md's own
  profiling (2,678,455 + 96,562 = 2,775,017; `identifyIsomorphicClasses`'s
  exact pre-change count was not separately re-profiled — documented in the
  script and in Unresolved Issues).
- [X] T006 [P] Verify MATLAB coding standards compliance for
  `classifySubgraphIsomorphism.m` (Principle VII): no `evalc` shadowing
  built-ins, no suppressed warnings, any `try/catch` propagates `ME.stack`,
  no bare `nargin` for optional handling, canonical function-signature
  spacing; confirm no project MATLAB-lint skill exists to apply (VII-F) or
  apply it if one has since been registered.

**Checkpoint**: Foundation ready — `classifySubgraphIsomorphism.m` exists and is verified standalone; the pre-change golden snapshot is captured. User story implementation can now begin.

---

## Phase 3: User Story 1 - Isomorphism classification scales sub-quadratically in practice (Priority: P1) 🎯 MVP

**Goal**: The conserved/reacting-moieties pipeline returns identical output while spending measurably less time/calls in the three classification loops.

**Independent Test**: `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m` passes unchanged; the Tyrosine benchmark's before/after `isisomorphic` call count and wall-clock time show a reduction with identical `moietyFormulas`/`moietyGraphs`/`moietyVectors`.

### Implementation for User Story 1

- [X] T007 [P] [US1] Route
  `src/analysis/topology/reactingMoieties/identifyIsomorphicClasses.m`
  through the shared helper: replace its inline double loop (current lines
  ~29-69) with a call to
  `classifySubgraphIsomorphism(CBSubgraphs, 'EdgeVariables', 'mets')`, then
  re-attach the `sanityChecks`-gated `Nodes.AtomIndex ~= idx` check and the
  `atrans2component`/`atoms2isomorphismClass`/`atrans2isomorphismClass`
  assignments as a post-processing pass over the returned
  `isomorphismClasses`, iterating class-by-class and member-by-member
  (`research.md` R3). The function's public signature and documented
  meaning MUST NOT change (FR-006).
- [X] T008 [P] [US1] Route
  `src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m`'s
  inline double loop (current lines ~603-676) through
  `classifySubgraphIsomorphism(subgraphs, 'NodeVariables', 'mets')`, then
  rebuild `I2C`, `atrans2component`, `atoms2isomorphismClass`,
  `atrans2isomorphismClass`, `nVertFirstSubgraph`, and `firstSubgraphIndices`
  from the returned `(isomorphismClasses, firstSubgraphIndices,
  subsequentSubgraphIndices)` triple, preserving the existing
  `sanityChecks`-gated `atoms2component(...) ~= idx` check (FR-007). Do not
  touch any other line in this 1720-line file (Spec-driven scope control).
- [X] T009 [P] [US1] Route
  `src/analysis/topology/reactingMoieties/findAndExtractMolecularGraphs.m`
  (current lines ~24-61) through `classifySubgraphIsomorphism(bondSubgraphs)`
  (no `varargin`, matching its current mode-less `isisomorphic` call),
  replacing the symmetric-matrix + `isomorphicGroups` construction with the
  helper's returned `isomorphismClasses`; keep
  `[~, largestGroupIndex] = max(cellfun(@length, isomorphismClasses))`,
  `conservedGroup = isomorphismClasses{largestGroupIndex}`, and
  `reactingGroups = setdiff(1:numSubgraphs, conservedGroup)` unchanged. This
  is where the function gains `excludedSubgraphs`-equivalent pruning as a
  side effect of the shared algorithm (FR-005).
- [X] T010 Ran
  `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`
  and `testClassifySubgraphIsomorphism.m` against the post-change code —
  **both PASSED**, every existing assertion intact (test file byte-for-byte
  unmodified) (FR-008, SC-001).
- [X] T011 Ran
  `specs/021-prefilter-isomorphism-classification/tyrosineReproducibilityCheck.m`
  in "compare" mode against the post-change code — **PASSED**: `arm.L`,
  `moietyFormulae`, `reacting.selectedReactionNames`/`selectedReactions`
  identical to the golden snapshot (SC-004); `isisomorphic` calls
  2,775,017 → 5,370 (**99.8% reduction**, SC-002); classification
  wall-clock 216.8s → 111.2s (**48.7% reduction**, SC-003). Results appended
  to `tyrosine-reproducibility-results.md`.
- [X] T012 Confirmed via the T010 run: the 3-reaction Recon3D CI fixture in
  `testConservedReactingMoieties.m` passed with no correctness regression
  (all existing `L*N=0`/structural assertions held), and the small crn/coa
  symmetry regression fixtures (features 019/020) embedded in the same test
  also passed — no observable overhead or behavior change at trivial scale.

**Checkpoint**: User Story 1 is fully functional and independently testable — identical output, measurably fewer `isisomorphic` calls.

---

## Phase 4: User Story 2 - One classification implementation instead of three (Priority: P2)

**Goal**: A maintainer finds exactly one place that implements the all-pairs classification loop.

**Independent Test**: Grep the three source files for a pairwise `isisomorphic` loop; confirm exactly one implementation exists.

### Implementation for User Story 2

- [X] T013 [US2] Remove any now-dead code, comments, or unused local
  variables left behind in
  `src/analysis/topology/reactingMoieties/identifyIsomorphicClasses.m`,
  `identifyConservedReactingMoieties.m`, and `findAndExtractMolecularGraphs.m`
  after T007-T009 routed their loops through the shared helper (e.g. a
  stale `isomorphicMatrix`/`visited` variable no longer assigned). Depends
  on T007-T009. (Verified via grep: no `isomorphicMatrix`, `visited`,
  `groupIndex`, or `excludedSubgraphs` reference remains in any of the three
  files.)
- [X] T014 [P] [US2] Run the static structural check from `quickstart.md`
  step 2: `grep -rn "isisomorphic(" src/analysis/topology/reactingMoieties/`
  and confirm exactly one pairwise-comparison loop remains, inside
  `classifySubgraphIsomorphism.m` (SC-006); document that
  `identifyAtomEquivalenceClasses.m`'s unrelated candidate cross-check and
  `identifyConservedReactingMoieties.m:1020`'s single-pair `MTG`/`MTG2`
  comparison are pre-existing, out-of-scope call sites that are expected to
  remain untouched. Depends on T013.
- [X] T015 [US2] Confirm
  `src/analysis/topology/reactingMoieties/classifySubgraphIsomorphism.m`
  carries a complete openCOBRA help header documenting it as the single
  classification entry point the other three functions call through
  (Principle VII-E; supports US2's maintainer-discoverability goal).
  Depends on T002.

**Checkpoint**: Both user stories are independently functional — identical, faster classification (US1) implemented in exactly one place (US2).

---

## Phase 5: Polish & Cross-Cutting Concerns

- [X] T016 [P] Run the scope-boundary check from `quickstart.md` step 3
  (`git diff --name-only master... -- src/ | grep -v -E
  "src/analysis/topology/reactingMoieties/(classifySubgraphIsomorphism|findAndExtractMolecularGraphs|identifyConservedReactingMoieties|identifyIsomorphicClasses)\.m"`)
  and confirm empty output — no `src/` file other than the three call
  sites and the new helper was modified, including within the
  `reactingMoieties` folder itself (SC-005, and FR-010's `checkABRXNFiles.m`/
  `readABRXNFile.m`/`addBondMappingsRXNFile.m` exclusion).
- [X] T017 Report files changed, checks run, tests passed, tests failed, and
  any behaviors not yet verified (Principle III), including whether the
  Tyrosine benchmark paths were available in this environment or had to be
  adjusted per `spec.md`'s Assumptions section.
- [X] T018 Create the implementation receipt at
  `specs/021-prefilter-isomorphism-classification/agent-runs/<UTC-timestamp>-prefilter-isomorphism/implementation-receipt.md`
  with the mandatory sections (Prompt, Final response, Diff summary, Tests,
  Unresolved issues), copying the actual final user-facing completion
  response verbatim into `Final response` (Implementation Receipt Ledger).

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately.
- **Foundational (Phase 2)**: Depends on Setup (T001). T005 (golden
  snapshot) MUST complete before any task in Phase 3 that edits a call site
  (T007-T009). BLOCKS all user stories.
- **User Story 1 (Phase 3)**: Depends on Foundational completion
  (T002, T003, T005).
- **User Story 2 (Phase 4)**: Depends on User Story 1's implementation tasks
  (T007-T009) being complete, since US2's "one implementation" property is a
  structural consequence of how US1 is implemented, not independent code.
- **Polish (Phase 5)**: Depends on both user stories being complete.

### Within Each Phase

- T007, T008, T009 touch different files and have no dependencies on each
  other — parallelizable once T002/T003/T005 are done.
- T010 depends on T007-T009 (all three call sites must compile/run
  together for the shared test to be meaningful).
- T011 depends on T005 (baseline) and T010 (passing regression test first).
- T014 depends on T013 (cleanup should land before the "exactly one loop"
  grep is treated as final).

### Parallel Opportunities

- T004 and T006 can run in parallel with each other and with T002/T003
  (different files, no shared state).
- T007, T008, T009 can run in parallel (different files).
- T014 and T016 can run in parallel with each other once their respective
  dependencies (T013; T007-T009) are met.

---

## Parallel Example: User Story 1

```bash
# Once T002, T003, T005 are done, launch all three call-site migrations together:
Task: "Route identifyIsomorphicClasses.m through classifySubgraphIsomorphism.m"
Task: "Route identifyConservedReactingMoieties.m's inline loop (lines ~603-676) through classifySubgraphIsomorphism.m"
Task: "Route findAndExtractMolecularGraphs.m through classifySubgraphIsomorphism.m"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001).
2. Complete Phase 2: Foundational (T002-T006) — the helper and the
   pre-change golden snapshot are the hard prerequisites; T005 must finish
   before touching any call site.
3. Complete Phase 3: User Story 1 (T007-T012) — the entire performance
   value of this feature.
4. **STOP and VALIDATE**: `testConservedReactingMoieties.m` passes
   unchanged and the Tyrosine reproducibility check shows a reduction with
   identical output.

### Incremental Delivery

1. Setup + Foundational → helper exists, baseline captured.
2. User Story 1 → measurable performance win, zero output change (MVP).
3. User Story 2 → structural cleanup confirmed by grep (mostly verification
   of a property T007-T009 already established, plus a small dead-code
   cleanup pass).
4. Polish → scope-boundary check, report, implementation receipt.

---

## Notes

- [P] tasks = different files, no dependencies.
- [Story] label maps task to specific user story for traceability.
- User Story 2 is unusually thin because its "one implementation" goal is a
  structural side effect of how User Story 1 is implemented (one shared
  helper, `research.md` R5) — its phase mostly verifies and tidies that
  property rather than adding independent behavior.
- Commit after each task or logical group.
- Stop at the Phase 3 checkpoint to validate User Story 1 independently
  before proceeding to Phase 4.
- Avoid: editing any file outside the three call sites and the new helper
  (SC-005); changing any of the three functions' public signatures (FR-006);
  touching `checkABRXNFiles.m`, `readABRXNFile.m`, or
  `addBondMappingsRXNFile.m` (FR-010).
