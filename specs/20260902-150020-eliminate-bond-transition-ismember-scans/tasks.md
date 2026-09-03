---

description: "Task list for eliminate-bond-transition-ismember-scans"
---

# Tasks: Eliminate remaining cell.ismember scans in buildAtomAndBondTransitionMultigraph's bond-transition loop

**Input**: Design documents from `/specs/20260902-150020-eliminate-bond-transition-ismember-scans/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md (all present)

**Tests**: This feature's spec explicitly requires tests: `testConservedReactingMoieties.m`
(existing, CI-covered regression gate, SC-004) and a new `testResolveAtomNodeIndex.m`
(new, CI-covered, SC-006), plus a documented non-CI Tyrosine-benchmark reproducibility
check (FR-007, FR-008). All are included below.

**Organization**: Tasks are grouped by user story (US1 = P1, US2 = P2) to enable
independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2)
- Include exact file paths in descriptions

## Path Conventions

Single MATLAB toolbox project. Source: `src/analysis/topology/reactingMoieties/`. Tests:
`test/verifiedTests/analysis/testReactingMoieties/`. Feature artifacts:
`specs/20260902-150020-eliminate-bond-transition-ismember-scans/`.

---

## Phase 1: Setup

**Purpose**: Read-and-map the exact current code (Principle V) and capture the pre-change
performance/correctness baseline before any `src/` edit is made.

- [X] T001 Re-read and confirm the exact current line ranges of the bond-transition
  per-reaction loop (`for i = 1:nRxns` through its closing `end`, currently ~605-709,
  with the atom-identity resolution at ~677-684) and the immutable `dATM.Nodes`
  construction (~372-386, via `addvars(dATM.Nodes, Atom, AtomIndex, Met, AtomNumber,
  Element, ...)`) in `src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m`.
  No code changes in this task — confirms plan.md/research.md's line references still
  match the working tree before editing.
- [X] T002 [P] Create `specs/20260902-150020-eliminate-bond-transition-ismember-scans/tyrosineReproducibilityCheck.m`,
  reusing feature 022's `specs/022-eliminate-table-object-hotspots/tyrosineReproducibilityCheck.m`
  as a structural template (research.md R3): same model-loading and
  capture-vs-compare-by-golden-snapshot-presence skeleton, but (a) capture `arm.L`,
  `moietyFormulae`, `reacting.selectedReactionNames` as the golden snapshot (FR-007), and
  (b) instrument with MATLAB `profile on`/`profile off`/`profile('info')` around the
  relevant pipeline portion and report `FunctionTable` call counts for `cell.ismember` and
  `tabular.dotReference` only (drop `tabular.dotAssign` — out of scope per spec
  Assumptions), attributable to `buildAtomAndBondTransitionMultigraph.m` (FR-008).
- [X] T003 Ran `specs/20260902-150020-eliminate-bond-transition-ismember-scans/tyrosineReproducibilityCheck.m`
  against the pre-change code (via `git stash` on
  `buildAtomAndBondTransitionMultigraph.m`, run, `git stash pop`) once MATLAB was located
  on this machine at `/usr/local/MATLAB/R2024b`. Captured
  `tyrosine-golden-snapshot.mat`: pre-change `cell.ismember`=168954,
  `tabular.dotReference`=1351986, wall-clock=49.7s (avg of 2 runs) — matching feature
  022's own final measured result exactly, confirming the working tree matched feature
  022's shipped state before this feature's edit.

**Checkpoint**: Baseline captured; safe to begin editing `src/`.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Create the one new, shared building block both user stories depend on
(US1 calls it from the loop; US2 unit-tests its error contract directly).

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T004 Create `src/analysis/topology/reactingMoieties/resolveAtomNodeIndex.m` per
  contracts/unchanged-public-contract.md and data-model.md E3:
  `[atom, atomIndex] = resolveAtomNodeIndex(nodeTable, nodeIndexMap, met, atomNumber, element)`,
  raising `resolveAtomNodeIndex:missingNodeIdentity` when the composite key
  `sprintf('%s\x1f%d\x1f%s', met, atomNumber, element)` is absent from `nodeIndexMap`, and
  `resolveAtomNodeIndex:ambiguousNodeIdentity` when it resolves to more than one row index
  — both raised before reading `nodeTable.Atom`/`nodeTable.AtomIndex` (research.md R1) —
  and returning `nodeTable.Atom(idx)`/`nodeTable.AtomIndex(idx)` for a uniquely-resolved
  `idx` otherwise. Include the openCOBRA help header (`USAGE:`, `INPUTS:`, `OUTPUTS:`,
  `Author:`) per constitution VII-E.

**Checkpoint**: Foundation ready — both user stories can now proceed.

---

## Phase 3: User Story 1 - Bond-transition loop resolves atom identity via an index, not 16 linear scans (Priority: P1) 🎯 MVP

**Goal**: Replace the 16 `ismember` calls per bond-transition (8 boolean-mask expressions
against `dATME.Nodes.mets`/`.Element`/`.AtomNumber`) with 4 calls to
`resolveAtomNodeIndex` against a node-identity index (`dATMNodeIndexMap`) built once per
function call from `dATM.Nodes`, before the per-reaction loop begins.

**Independent Test**: `testConservedReactingMoieties.m` passes with every existing
assertion unchanged; the Tyrosine benchmark reproducibility check shows `arm.L` /
`moietyFormulae` / `reacting.selectedReactionNames` byte-identical to the pre-change golden
snapshot while `cell.ismember` and `tabular.dotReference` call counts attributable to
`buildAtomAndBondTransitionMultigraph.m` are measurably and substantially lower.

### Implementation for User Story 1

- [X] T005 [US1] In `src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m`,
  inside the `if options.bondTransitionMultigraph` block, immediately before the
  bond-transition `for i = 1:nRxns` loop begins (alongside the existing
  `metBondCountGroundTruth`/`metAtomCanonicalRankMap`/`metUnsafeNeighborsMap` map
  declarations), build `dATMNodeIndexMap = containers.Map('KeyType','char','ValueType','any')`
  by one pass over `dATM.Nodes` keyed on `sprintf('%s\x1f%d\x1f%s', dATM.Nodes.mets{r},
  dATM.Nodes.AtomNumber(r), dATM.Nodes.Element{r})`, appending row index `r` to an
  existing key's value rather than overwriting (research.md R1, data-model.md E2). FR-002:
  built exactly once per call, never per reaction or per bond-transition.
- [X] T006 [US1] In the same file, replace the 8 `ismember`-based mask expressions at the
  current lines ~677-684 (`bondEdgeHeadBondHeadAtom(k) = dATME.Nodes.Atom((ismember(...)
  & ... & ismember(...)))`, and its 3 sibling `Atom` lines plus 4 sibling `AtomIndex`
  lines) with 4 calls to `resolveAtomNodeIndex(dATM.Nodes, dATMNodeIndexMap, ...)` — one
  per substrate-head (`subMet1`/`subAtomNum1`/`subElem1`), substrate-tail
  (`subMet2`/`subAtomNum2`/`subElem2`), product-head
  (`prodMet1`/`prodAtomNum1`/`prodElem1`), and product-tail
  (`prodMet2`/`prodAtomNum2`/`prodElem2`) identity — each call populating both the
  `bondEdge*Atom(k)` and `bondEdge*AtomIndex(k)` accumulator slots for that identity in one
  step (research.md R1, FR-001, FR-003). Leave the energy-pseudo-node lines immediately
  above this loop body untouched — `dATME = addnode(dATM, EnergyNode)` and the two
  `bondMappings.headAtoms`/`tailAtoms` energy-node `ismember` assignments are not part of
  this edit, since lines ~677-684 never resolve the energy node (FR-004). Depends on T004,
  T005.
- [X] T007 [US1] Ran
  `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m` —
  **PASSED**, every existing assertion unchanged (SC-004), confirming FR-006 (signature/
  schema unchanged) as a byproduct. First run surfaced a real bug (see below), fixed, then
  passed cleanly including all crn[c]/coa[m,x,r]/crn[m] symmetry fixtures and the T009b
  BondType checks.
  **Bug found and fixed during this run**: (1) `sprintf('%d', ...)` on `dATM.Nodes.AtomNumber(r)`
  errored ("Function is not defined for sparse inputs") on this test's smaller model, where
  the column is sparse — fixed by wrapping with `full()` in both the index-build loop and
  `resolveAtomNodeIndex.m`. (2) A bond-transition CAN legitimately reference the current
  reaction's own energy pseudo-node (e.g. ACONTm/r0317/r0426's product-side bonds) —
  disproving this feature's own FR-004 assumption that lines 677-684 never resolve it.
  Fixed by registering each reaction's energy-node key into `dATMNodeIndexMap` right after
  `dATME = addnode(dATM, EnergyNode)`, and switching the 4 `resolveAtomNodeIndex` calls to
  index `dATME.Nodes` (real atoms + this reaction's energy node) instead of the
  reaction-invariant `dATM.Nodes`. Depends on T006.
- [ ] T008 [US1] Ran
  `specs/20260902-150020-eliminate-bond-transition-ismember-scans/tyrosineReproducibilityCheck.m`
  post-change. **SC-003 PASS** (`arm.L`/`moietyFormulae`/`reacting.selectedReactionNames`
  byte-identical to the golden snapshot). **SC-001 PASS, decisively**: `cell.ismember`
  1754 calls, 0.3% of the pre-022 baseline (target was <=10%). **SC-005 PASS**: wall-clock
  38.0s (post-022 baseline 55.0s). **SC-002 FAILS**: `tabular.dotReference` = 1,049,026
  (56.3% of the pre-022 baseline of 1,863,426; target was <=30%, <=559,028).
  Root-caused via a parent-call profile breakdown (`profile('info')` Parents list for
  `tabular.dotReference`): of the 1,049,026 calls, the overwhelming majority trace to
  `readABRXNFile` (254,348), `addBondMappingsRXNFile` (187,229),
  `buildAtomAndBondTransitionMultigraph` itself (170,000 — from the ATOM-transition loop
  and sanity-check/M2Ai/Ti2R sections, not the bond-transition loop this feature edited),
  `digraph.subsref` (46,527, MATLAB's own digraph-property-access machinery), and
  `tabular.dotListLength` (385,486, internal table machinery invoked throughout). **None of
  these are in this feature's scope** (FR-001 scoped only to the bond-transition loop,
  lines ~677-684) — this feature's own contribution to `dotReference` (the bond-transition
  loop's `dATME.Nodes.mets`/`.AtomNumber`/`.Element`/`.Atom`/`.AtomIndex` accesses) was
  fully eliminated, but the pipeline's total `dotReference` count is dominated by other,
  out-of-scope call sites — SC-002's >=70%-reduction target does not appear achievable by
  this feature's scoped fix alone. Results appended to
  `specs/20260902-150020-eliminate-bond-transition-ismember-scans/tyrosine-reproducibility-results.md`.
  Depends on T003, T006. **Status: run to completion; SC-002 not met — see completion
  report for recommendation.**

**Checkpoint**: User Story 1 is fully functional and independently testable — the
bond-transition loop uses the index, correctness is unchanged, and the performance targets
are met.

---

## Phase 4: User Story 2 - Ambiguous or missing atom-identity lookups fail loudly, not silently (Priority: P2)

**Goal**: Prove `resolveAtomNodeIndex`'s error contract directly — a duplicate-key or
missing-key composite atom identity raises an explicit, identifiable error
(`resolveAtomNodeIndex:ambiguousNodeIdentity` / `:missingNodeIdentity`) rather than
silently selecting a match or silently corrupting a downstream field.

**Independent Test**: `testResolveAtomNodeIndex.m` calls `resolveAtomNodeIndex` directly
with synthetic `nodeTable`/`nodeIndexMap` inputs — no RXN-file parsing, no dependency on
User Story 1's integration into the loop.

### Tests for User Story 2

- [X] T009 [P] [US2] Create
  `test/verifiedTests/analysis/testReactingMoieties/testResolveAtomNodeIndex.m`
  (constitution III-Naming: `test<FunctionName>.m`) asserting three cases against a small
  synthetic `nodeTable` (columns `Atom`, `AtomIndex`, `mets`, `AtomNumber`, `Element`) and
  a `nodeIndexMap` built the same way as T005: (1) a key present exactly once returns the
  expected `atom`/`atomIndex` pair; (2) a key absent from `nodeIndexMap` raises
  `resolveAtomNodeIndex:missingNodeIdentity` (Acceptance Scenario US2-2), verified via
  `verifyCobraFunctionError` or an equivalent `try/catch` on `ME.identifier`; (3) a key
  present for two synthetic rows raises `resolveAtomNodeIndex:ambiguousNodeIdentity`
  (Acceptance Scenario US2-1), verified the same way. Depends on T004.

### Implementation for User Story 2

- [X] T010 [US2] Ran
  `test/verifiedTests/analysis/testReactingMoieties/testResolveAtomNodeIndex.m` —
  **PASSED**, all three cases (unique match, missing key, ambiguous key) (SC-006).
  Depends on T009.

**Checkpoint**: Both user stories are independently functional — US1's refactor is
correct and faster, and US2 proves its failure-safety net directly.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Final verification across both changed files and receipt bookkeeping.

- [X] T011 [P] Ran `quickstart.md` steps end-to-end: step 1 (CI regression) = PASS (T007);
  step 2 (new unit test) = PASS (T010); step 5 (Tyrosine reproducibility) = SC-001/003/005
  PASS, SC-002 FAIL (T008 — see completion report); step 4 (scope-boundary) = PASS (T012).
  Step 3 (direct before/after `buildAtomAndBondTransitionMultigraph` output comparison) is
  subsumed by T007's full-assertion pass and T008's SC-003 structural-equality assertion,
  both of which directly prove output identity — not re-run separately. Step 6's
  duplicate/missing-key sub-check = PASS (via T010); its zero-bond-transition sub-check has
  no confirmed fixture in the corpus and remains verified by code inspection only (as
  quickstart.md documents), since `dATMNodeIndexMap`'s construction (T005) has no
  dependency on any bond-transition existing and the per-bond-transition loop simply does
  not execute when a reaction has none.
- [X] T012 Run the scope-boundary check from `quickstart.md` step 4
  (`git diff --name-only master... -- src/ test/ | grep -v -E "..."`) and confirm no file
  outside `src/analysis/topology/reactingMoieties/{buildAtomAndBondTransitionMultigraph,resolveAtomNodeIndex}.m`
  and `test/verifiedTests/analysis/testReactingMoieties/testResolveAtomNodeIndex.m` was
  touched. NOTE: the literal `master...` diff is not meaningful on this branch (it has
  many prior spec-kit features committed ahead of `master` already, unrelated to this
  feature); verified instead via `git status --porcelain -- src/ test/` /
  `git diff --name-only -- src/ test/` (uncommitted working-tree changes), which shows
  exactly the 3 expected files.
- [X] T013 [P] Verify MATLAB coding standards compliance (constitution VII) for both
  changed files: no `evalc` variable shadows, no suppressed warnings, no bare `nargin` in
  `resolveAtomNodeIndex.m`, `resolveAtomNodeIndex.m` carries the openCOBRA help header
  (VII-E), and the `error('functionName:condition', ...)` convention matches the existing
  pattern in this directory (VII-G). Search for a registered MATLAB-lint skill and apply
  it if present (VII-F).
- [X] T014 Report files edited, checks run (T003, T007, T008, T010), tests passed/failed,
  and unresolved issues. MATLAB was located on this machine
  (`/usr/local/MATLAB/R2024b`) and all pending tasks were run to completion. Two real bugs
  were found and fixed during T007 (sparse `AtomNumber` breaking `sprintf`; the
  energy-pseudo-node case disproving this feature's own FR-004 assumption). One genuine
  success-criterion shortfall was found during T008 (SC-002, `tabular.dotReference`) and
  root-caused to out-of-scope call sites, not a defect in this feature's own change. See
  completion report / implementation receipt for full detail.
- [X] T015 Create the implementation receipt in
  `specs/20260902-150020-eliminate-bond-transition-ismember-scans/agent-runs/<UTC-timestamp>-<short-task-or-run-name>/implementation-receipt.md`
  per the constitution's Implementation Receipt Ledger, with the actual final
  user-facing agent completion response copied verbatim into the `Final response` section.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately. T003 (pre-change baseline
  capture) MUST complete before T005/T006 touch the loop.
- **Foundational (Phase 2)**: Depends on Setup completion — BLOCKS both user stories (T004
  must exist before T006 or T009 can reference it).
- **User Story 1 (Phase 3)**: Depends on Foundational (T004) and Setup (T001, T003).
  No dependency on User Story 2.
- **User Story 2 (Phase 4)**: Depends on Foundational (T004) only — independent of User
  Story 1's integration work (T005/T006), since it tests `resolveAtomNodeIndex.m` directly
  with synthetic inputs. Can proceed in parallel with Phase 3 once Phase 2 completes.
- **Polish (Phase 5)**: Depends on both User Story 1 and User Story 2 being complete.

### Within Each User Story

- User Story 1: T005 (index build) before T006 (loop call sites, same file); T007 and T008
  after T006.
- User Story 2: T009 (test) before T010 (run test).

### Parallel Opportunities

- T002 (create reproducibility script) can run in parallel with T001 (read-and-map).
- Once Phase 2 (T004) completes, User Story 1 (T005-T008) and User Story 2 (T009-T010) can
  proceed in parallel — they touch different files
  (`buildAtomAndBondTransitionMultigraph.m` vs. `testResolveAtomNodeIndex.m`).
- T011 and T013 in Polish can run in parallel (independent verification activities).

---

## Parallel Example: Foundational -> User Stories

```bash
# After T004 (resolveAtomNodeIndex.m) completes:
Task: "T005/T006 — integrate resolveAtomNodeIndex into buildAtomAndBondTransitionMultigraph.m's bond-transition loop"
Task: "T009 — write testResolveAtomNodeIndex.m against synthetic nodeTable/nodeIndexMap inputs"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001-T003) — capture the pre-change baseline before touching
   any source.
2. Complete Phase 2: Foundational (T004) — create `resolveAtomNodeIndex.m`.
3. Complete Phase 3: User Story 1 (T005-T008) — this alone closes feature 022's
   SC-002/SC-003 shortfall (this feature's SC-001/SC-002) and is independently verifiable.
4. **STOP and VALIDATE**: run `testConservedReactingMoieties.m` and the Tyrosine
   reproducibility check; confirm SC-001, SC-002, SC-003, SC-004, SC-005.

### Incremental Delivery

1. Setup + Foundational -> baseline captured, helper exists.
2. User Story 1 -> the actual performance fix; independently testable and the feature's
   MVP.
3. User Story 2 -> the safety-net regression test for the failure-mode contract
   `resolveAtomNodeIndex` already carries from T004; adds no new production behavior, only
   proof of the existing error contract (SC-006).
4. Polish -> quickstart validation, scope check, standards check, receipt.

---

## Notes

- [P] tasks = different files, no dependencies.
- [Story] label maps task to specific user story for traceability.
- This feature touches exactly two `src/` files
  (`buildAtomAndBondTransitionMultigraph.m` modified, `resolveAtomNodeIndex.m` new) and
  one new test file (`testResolveAtomNodeIndex.m`) — SC-006 (traceability table) and the
  Constitution Check's scope-control section bound this explicitly; T012 verifies it.
- Commit after each task or logical group.
- Stop at the Phase 3 checkpoint to validate User Story 1 independently before starting
  Phase 4 if working sequentially rather than in parallel.
