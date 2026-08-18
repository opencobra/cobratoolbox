# Tasks: Canonicalize Bond-Node Keys in Atom/Bond Transition Multigraph Construction

**Input**: Design documents from `specs/019-canonicalize-bond-node-keys/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/buildAtomAndBondTransitionMultigraph-bond-key.md](./contracts/buildAtomAndBondTransitionMultigraph-bond-key.md), [quickstart.md](./quickstart.md)

**Tests**: Required. This feature fixes a bond-graph node-identity bug and must keep `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m` passing without weakening its existing assertions.

**Organization**: Tasks are grouped by user story to keep the canonicalization fix, no-regression verification, and the new sanity check independently testable.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm the implementation context and reproducibility baseline before code edits.

- [X] T001 Read the active feature artifacts `specs/019-canonicalize-bond-node-keys/spec.md`, `specs/019-canonicalize-bond-node-keys/plan.md`, `specs/019-canonicalize-bond-node-keys/research.md`, `specs/019-canonicalize-bond-node-keys/data-model.md`, `specs/019-canonicalize-bond-node-keys/contracts/buildAtomAndBondTransitionMultigraph-bond-key.md`, and `specs/019-canonicalize-bond-node-keys/quickstart.md`
- [X] T002 Inspected the current bond-node key construction (`src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m` lines 593–668) and the `N`-vs-`N2` consistency check (lines 798–824); confirmed line numbers and logic match `research.md` R1 (same commit `35f6490c8` as at planning time)
- [X] T003 Inspected `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m` and its existing fixtures; confirmed the calling convention (`options.directed`, `options.sanityChecks`, the 12-output destructuring `[dATM, metAtomMappedBool, rxnAtomMappedBool, M2Ai, Ti2R, dATME, BG, dBTM, M2BiE, M2BiW, BTi2R, TiE]`)
- [X] T004 [P] Searched available skills for MATLAB coding/linting guidance — none found specific to MATLAB in this environment; followed the openCOBRA style guide (`documentation/source/guides/styleGuide.rst`) and the conventions already established in the target file (`fprintf`-based diagnostics, `addvars`/`mapAontoBOld` table idioms)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Establish the fixtures and the exact pre-fix baseline every user story depends on.

**CRITICAL**: No user story implementation can begin until this phase is complete.

- [X] T005 Source `ELAIDCPT1.rxn`, `HMR_2634.rxn`, and `HMR_2919.rxn` (all sharing `crn[c]`). **Correction during implementation (research R6)**: the public `opencobra/ctf` files do not reproduce the bug (verified: byte-identical `crn[c]` blocks across all three, pre-fix node count already 25). The real reproduction data was located at `rxns/atomMapped_standardised/` in the private `gitlab.com/recon4imd/ctf` repo (mounted locally at `/media/JACK/repos/ctf/`), paired with model `vmh2_reconx_for_atom_mapping.mat` (not `Recon3D_301.mat`). Committed the three real RXN files under `test/verifiedTests/analysis/testReactingMoieties/data/rxnFiles/`, and a minimal extracted 10-met/3-rxn submodel as `test/verifiedTests/analysis/testReactingMoieties/data/crnBondKeySubmodel.mat` (21KB, self-contained, no external model/network dependency at test time).
- [X] T006 Built `dBTM` for the `crnBondKeySubmodel.mat` submodel with the vendored RXN files and confirmed the pre-fix baseline via MATLAB (R2024b, Gurobi available): `crn[c]` resolves to **31** `dBTM.Nodes` rows (not 25), the `Inconsistent directed bond transition multigraph` warning fires for all three reactions, and the residual matches the spec's Problem Statement exactly (`N=-1`, `N2=-0.787879`, `res=-7`). Atom numbering for `crn[c]` confirmed stable across all three RXN files via direct `readABRXNFile` comparison. Recorded for the implementation receipt (T029).
- [X] T007 Confirmed in `readABRXNFile.m` (lines 132–208, `bonds` table assembly at 244–267) that the `bonds` table returned per reaction contains, for any single reaction, exactly one row per true bond of each metabolite appearing in that reaction — the per-metabolite bond-count ground truth needed for US3 (T023) is read from this already-parsed table rather than re-parsing the molblock a second time.
- [X] T008 [P] Confirmed the standard reproducibility command for this feature is `testConservedReactingMoieties` (extended by this feature) plus the targeted `crn[c]` node-count check in `quickstart.md`; no new test file is created (Constitution III-Naming, research R7), except the new helper's own test (T010).

**Checkpoint**: Fixtures committed, pre-fix baseline captured, ground-truth source for the sanity check confirmed.

---

## Phase 3: User Story 1 - Consistent Bond Identity Across Independently-Generated RXN Files (Priority: P1) 🎯 MVP

**Goal**: The same physical bond of a shared metabolite resolves to the same `dBTM.Nodes` identity regardless of which reaction's RXN file it was read from.

**Independent Test**: Rebuild `dBTM` for `ELAIDCPT1`/`HMR_2634`/`HMR_2919`; `crn[c]` resolves to exactly 25 bond nodes (not 31), with no `Inconsistent directed bond transition multigraph` warning for any of the three reactions.

### Tests for User Story 1

- [X] T009 [P] [US1] Added a clearly-separated section to `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m` that loads `crnBondKeySubmodel.mat`, builds `dBTM` for the `ELAIDCPT1`/`HMR_2634`/`HMR_2919` fixtures, and asserts `crn[c]` resolves to exactly 25 `dBTM.Nodes` rows with no `Inconsistent directed bond transition multigraph` warning, plus that all three reactions reference `crn[c]` bond nodes. Confirmed via direct pre-fix probe that this failed as expected before implementation (31 nodes, warning present, matching spec Problem Statement exactly: `N=-1`, `N2=-0.787879`, `res=-7`).
- [X] T010 [P] [US1] Created `test/verifiedTests/analysis/testReactingMoieties/testCanonicalBondKey.m` (Constitution III-Naming: a new source function gets its own test file) asserting: (a) the same physical bond supplied in both atom orders produces an identical key string; (b) two distinct bonds of one metabolite (sharing an atom, and not sharing an atom) produce distinct keys; (c) a bond between a real atom and a reaction's energy node (`AtomNumber` hardcoded to `1`) canonicalizes correctly via metabolite-identity ordering even when atom numbers coincide. Run directly via MATLAB R2024b: **PASSED**.

### Implementation for User Story 1

- [X] T011 [US1] Created `src/analysis/topology/reactingMoieties/canonicalBondKey.m` implementing the ordering rule from `data-model.md` (primary sort key: metabolite identity, via `sort({metA,metB})` — not the naive `metA < metB` string comparison in the spec's illustrative pseudocode, which errors in MATLAB for unequal-length char arrays; secondary sort key: atom number within one metabolite), returning a canonical key string plus the canonically-ordered (met, atomNumber, element) pair for each side.
- [X] T012 [US1] Routed the node-identity construction in `buildAtomAndBondTransitionMultigraph.m` (`bondSubstrateID`/`bondProductID`, lines 593–598) through `canonicalBondKey`.
- [X] T013 [US1] Reordered `bondSubstrateType`/`bondProductType` (line 599–600, e.g. `'C-O'`) from `canonicalBondKey`'s returned canonically-ordered elements, so `BondElmts` cannot disagree with `Bond`.
- [X] T014 [US1] Derived `HeadBondHeadAtom`/`HeadBondTailAtom`/`TailBondHeadAtom`/`TailBondTailAtom` and their `*Index` counterparts (lines 606–613) from the canonicalized (met1/atomNum1/elem1, met2/atomNum2/elem2) pairs returned by `canonicalBondKey`, not from the raw substrate/product atom order.
- [X] T015 [US1] Verified by reading lines 634–668 that `dBTM.Nodes.Bond`/`BondHeadAtom`/`BondTailAtom`/`BondHeadAtomIndex`/`BondTailAtomIndex` are derived via `mapAontoBOld` purely from the edge-level fields touched in T014, with no other raw `bondMappings` reference remaining — confirmed via `git diff` that no further code change was needed (spec FR-005 holds by construction).
- [X] T016 [US1] Ran the targeted regression against the real, MATLAB-verified `crn[c]`/`ELAIDCPT1`/`HMR_2634`/`HMR_2919` fixture (research R6): **post-fix `crn[c]` resolves to exactly 25 `dBTM.Nodes` rows (was 31), and the `Inconsistent directed bond transition multigraph` warning no longer fires.** Pass/fail evidence recorded for the implementation receipt (T029).

**Checkpoint**: User Story 1 is complete when `crn[c]` resolves to 25 bond nodes for the three-reaction submodel and the false-positive warning no longer fires.

---

## Phase 4: User Story 2 - No Regression For Unaffected Metabolites, Reactions, Or Downstream Consumers (Priority: P2)

**Goal**: Metabolites/reactions not affected by the bug, and all three downstream consumers, are unchanged by the fix.

**Independent Test**: Rebuild `dBTM` before/after the fix for the existing `r0317`/`ACONTm`/`r0426` fixture and the previously-fixed regression cases; node counts, edge counts, and known-good diagnostic outputs are unchanged.

### Tests for User Story 2

- [X] T017 [P] [US2] Ran the full `testConservedReactingMoieties.m`: all existing assertions for the `r0317`/`ACONTm`/`r0426` fixture (`L*N = 0` invariant, `brokenBondsTable`/`formedBondsTable` heights of 7, moiety counts of 2) **pass unchanged** after the US1 change.
- [X] T018 [P] [US2] Confirmed via direct probe that `dBTM.Edges.HeadMet`/`.TailMet` are unaffected: for `ELAIDCPT1`, `crn[c]` appears only as `HeadMet` (substrate side) and never as `TailMet` (product side) — the reaction-direction assignment is untouched by the within-bond atom-order canonicalization.

### Implementation for User Story 2

- [X] T019 [US2] Re-reviewed `identifyConservedReactingSubgraphs.m` (lines 53–54, 100–102, 108) and `identifyConservedReactingMoieties.m` (`CRB2R` construction, `moietyBondIndex`) against the applied change: both consume `BondIndex`/`BondHeadAtomIndex`/`BondTailAtomIndex` as opaque identifiers or unordered sets and `HeadMet`/`TailMet` for reaction direction only — confirmed no order-dependent assumption is broken by the canonicalization actually applied (matches research R3; no source change made to either file).
- [X] T020 [US2] Confirmed via direct probe: `crn[c]` has exactly 24 single bonds + 1 double bond (25 total, matching the spec exactly); the double-bond node is touched by multiple edges (multi-edge-per-node collapsing preserved) after canonicalization.
- [X] T020b [US2] Attempted for `AKGDm`/`CSm`: sourced both RXN files from `opencobra/ctf` (Recon3D-compatible naming, confirmed matches `Recon3D_301.mat`), rebuilt `dBTM` for a 2-reaction submodel. **Result**: no `Inconsistent directed bond transition multigraph` warning fired for this pair — this fix's mechanism is not triggered here at all, so there is no interaction with the CoA symmetric-molecule case by construction. `NumReactingBonds` (formed 16 + broken 17 = 33) was observed but could not be checked against the spec's cited "3-23 range" baseline, since that prior finding's exact methodology/reaction scope is not available in this session — flagged as an open verification gap rather than silently assumed passing. **`tyr`/`bileacid`/`pufa` deferred**: the spec names subsystems, not specific reaction IDs, and enumerating+fetching a representative reaction set was out of scope for the remaining implementation budget. Recorded honestly in the implementation receipt (T029) rather than asserted as verified.
- [X] T021 [US2] Ran `testConservedReactingMoieties.m` in full via MATLAB R2024b (Gurobi available): **all assertions pass**, confirming no regression for previously-correct metabolites/reactions and no order-dependent breakage in the two reviewed downstream consumers.

**Checkpoint**: User Stories 1 and 2 both work independently — the fix is correct and does not silently change anything it shouldn't.

---

## Phase 5: User Story 3 - Fail Fast On Future Bond-Node Identity Bugs (Priority: P3)

**Goal**: A per-metabolite bond-count sanity check flags any future node/bond-count mismatch immediately after `dBTM` construction, as a non-fatal warning.

**Independent Test**: Construct (or reuse) a metabolite whose bond-graph node count does not match its true bond count; confirm the sanity check flags it immediately, without needing a downstream stoichiometry comparison to notice.

### Tests for User Story 3

- [X] T022 [P] [US3] Added assertions to `testConservedReactingMoieties.m`: (a) the crn[c] fixture (already matching, 25==25) produces no "does not match its true bond count" warning; (b) a synthetic mismatched scenario (7 nodes vs. ground-truth 5) exercises the exact comparison-and-warn logic and confirms the warning fires, identifies the metabolite by name, and execution continues past it (non-fatal).

### Implementation for User Story 3

- [X] T023 [US3] Added a per-metabolite bond-count sanity check block in `buildAtomAndBondTransitionMultigraph.m` (after the existing node/edge reordering checks, ~line 728), gated by `options.sanityChecks` (default on). Ground truth is accumulated once per metabolite during the main reaction loop from the already-parsed `bonds` table returned by `readABRXNFile` (T007's finding — `containers.Map`, first-instance-only bond-row count, no second molblock parse), then compared post-construction against `nnz(strcmp(dBTM.Nodes.mets, met))` for each atom/bond-mapped metabolite; mismatches emit a non-fatal `warning(...)` identifying the metabolite, without halting execution or altering return values (spec FR-008, resolved severity per Clarifications).
- [X] T024 [US3] Ran T022's assertions via the full `testConservedReactingMoieties.m`: **PASSED** — matching case silent, mismatched case warns with the metabolite name, execution reaches completion in both cases. Pass/fail evidence recorded for the implementation receipt (T029).

**Checkpoint**: All three user stories are independently functional — the fix, its non-regression, and the new fail-fast guard.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final validation, diff hygiene, and receipt.

- [X] T025 [P] Reviewed `buildAtomAndBondTransitionMultigraph.m` (full diff) and `canonicalBondKey.m` for MATLAB standards: no `evalc`, no warning suppression, no new `nargin` usage, no new `try/catch` (none needed), all new diagnostic output gated by the existing `options.sanityChecks` convention. Pre-existing linter warnings in the file (unused-variable/reachability notes at lines far from the edited regions) are untouched and out of scope.
- [X] T026 [P] Confirmed via `git diff` that `testConservedReactingMoieties.m` has 57 insertions and **zero deletions** — no existing assertion was weakened, deleted, or skipped. `testCanonicalBondKey.m` is a new file (Constitution III-Naming), nothing to compare against.
- [ ] T027 Full network validation (spec SC-002) **deferred**: rerunning the complete moiety-identification pipeline across the full Recon3D/HMR atom-mapped RXN corpus (thousands of reactions) was out of reach within this implementation session's time budget. Recorded as an explicit residual gap in the implementation receipt (T029), consistent with research R4's scoping note, rather than silently skipped or falsely claimed.
- [X] T028 Ran `git status --short`: only the intended source/test/spec changes are present — no untracked generated diaries, logs, or temporary `.mat` probe artifacts inside the repository (all scratch scripts used during implementation lived outside the repo, under the session scratchpad).
- [X] T029 Created implementation receipt in `agent-runs/20260818T104711Z-canonicalize-bond-node-keys/implementation-receipt.md` with files changed, checks run, pass/fail results, residual unverified behaviour (T027 deferral, T020b's partial `tyr`/`bileacid`/`pufa` gap), and the final response copied verbatim into the `Final response` section

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies.
- **Foundational (Phase 2)**: Depends on Setup completion and blocks all user stories.
- **US1 (Phase 3)**: Depends on Foundational; MVP and the actual defect fix.
- **US2 (Phase 4)**: Depends on Foundational; should be validated after US1 implementation so the full test proves the combined path introduces no regression.
- **US3 (Phase 5)**: Depends on Foundational; independent of US1/US2 code paths but shares the same source file, so coordinate edits.
- **Polish (Phase 6)**: Depends on all desired user stories.

### User Story Dependencies

- **User Story 1 (P1)**: Start after Foundational; no dependency on US2 or US3.
- **User Story 2 (P2)**: Start after Foundational; final full-test validation (T021) should run after US1 code exists.
- **User Story 3 (P3)**: Start after Foundational; coordinates with US1 because both edit `buildAtomAndBondTransitionMultigraph.m`.

### Parallel Opportunities

- T004 can run in parallel with T002/T003 because it only searches skills.
- T008 can run in parallel with T005–T007 because it only names the existing reproducibility command.
- T009 and T010 can run in parallel because they touch different test files.
- T017 and T018 can run in parallel because they inspect/assert on different aspects of the existing test.
- T025 and T026 can run in parallel because they review different files.

---

## Parallel Example: User Story 1

```text
Task: "T009 [P] [US1] Add crn[c] node-count and no-warning assertions to test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m"
Task: "T010 [P] [US1] Create test/verifiedTests/analysis/testReactingMoieties/testCanonicalBondKey.m"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 and Phase 2 (fixtures committed, baseline captured).
2. Implement US1: `canonicalBondKey.m` plus the four call-site updates in `buildAtomAndBondTransitionMultigraph.m`.
3. Validate with the targeted `crn[c]` regression (T016).
4. Stop and confirm `crn[c]` resolves to exactly 25 nodes with no warning.

### Incremental Delivery

1. US1: Fix the actual bond-node identity bug.
2. US2: Confirm no regression for unaffected metabolites, reactions, or the two named downstream consumers.
3. US3: Add the fail-fast per-metabolite sanity check as a runtime guard against recurrence.
4. Polish: run final hygiene checks, attempt the full network validation if data permits, and create the implementation receipt.

### Notes

- Every task above follows `- [ ] T### [P?] [US?] Description with file path`.
- `[P]` marks tasks that touch different files or only gather evidence.
- Do not edit source or tests until the implementation phase is explicitly invoked.
- Do not commit generated logs, diaries, saved probe `.mat` files, or temporary MATLAB artifacts.
- Per research R2/R3: `readABRXNFile.m`, `checkABRXNFiles.m`, `addBondMappingsRXNFile.m`, `identifyConservedReactingMoieties.m`, `identifyConservedReactingSubgraphs.m`, and `extractBondSubgraphs.m` are confirmed to need no source change — tasks that touch them (T007, T019) are verification-only.
