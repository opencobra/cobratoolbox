# Tasks: Canonicalize Bond-Node Keys for Symmetric/Resonance-Equivalent Atom Groups

**Input**: Design documents from `specs/020-canonicalize-symmetric-atom-bonds/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/symmetry-equivalence-canonicalization.md](./contracts/symmetry-equivalence-canonicalization.md), [quickstart.md](./quickstart.md)

**Tests**: Required. This feature fixes a bond-graph node-identity bug and must keep `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m` (and feature 019's `testCanonicalBondKey.m`) passing without weakening their existing assertions.

**Naming decision (this phase)**: Per plan.md/research.md R6/R9 ("name decided at `/speckit-tasks`"), the new equivalence-class helper is named `identifyAtomEquivalenceClasses.m`, matching this domain folder's existing naming convention (parallel to `identifyIsomorphicClasses.m`, which already solves a structurally analogous whole-subgraph problem). Its test file is `testIdentifyAtomEquivalenceClasses.m` (Constitution III-Naming).

**Organization**: Tasks are grouped by user story to keep the equivalence-class fix, no-regression verification, and the post-fix blast-radius confirmation independently testable.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm the implementation context and reproducibility baseline before code edits.

- [X] T001 Read the active feature artifacts `specs/020-canonicalize-symmetric-atom-bonds/spec.md`, `specs/020-canonicalize-symmetric-atom-bonds/plan.md`, `specs/020-canonicalize-symmetric-atom-bonds/research.md`, `specs/020-canonicalize-symmetric-atom-bonds/data-model.md`, `specs/020-canonicalize-symmetric-atom-bonds/contracts/symmetry-equivalence-canonicalization.md`, and `specs/020-canonicalize-symmetric-atom-bonds/quickstart.md`
- [X] T002 [P] Inspect the current, post-019-merge state of `src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m` (the `metBondCountGroundTruth` cache at lines 577-588, the `canonicalBondKey` call sites at lines 604-619, `BondType` construction at line 655, and the FR-008 sanity check at lines 726-748) and `src/analysis/topology/reactingMoieties/canonicalBondKey.m`; confirm line numbers and logic match `research.md` R5-R7
- [X] T003 [P] Inspect `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m` and `test/verifiedTests/analysis/testReactingMoieties/testCanonicalBondKey.m`; confirm the calling convention and the existing `crn[c]`/`crnBondKeySubmodel.mat` fixture pattern to be mirrored for the new fixtures
- [X] T004 [P] Search available skills for MATLAB coding/linting guidance; if none exists (as found during feature 019), follow the openCOBRA style guide (`documentation/source/guides/styleGuide.rst`) and the conventions already established in `canonicalBondKey.m`/`identifyIsomorphicClasses.m` (openCOBRA header format, `containers.Map` caching idiom, `fprintf`/`warning`-gated diagnostics)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Vendor the fixtures and capture the exact pre-fix baseline every user story depends on.

**CRITICAL**: No user story implementation can begin until this phase is complete.

- [X] T005 Vendor the nine new RXN files this feature's acceptance criteria name — `PPACOAATREVm.rxn`, `HMR_3173.rxn`, `HYPGCOAHLm.rxn`, `DDCDATMTCOAHLx.rxn`, `FAOXC2442246x.rxn`, `PTCA3ZCOAHLx.rxn`, `VITEATENCOXCOAxr.rxn`, `DCA4Z7ZCOAr.rxn`, `STCOAATr.rxn` — from `~/repos/reconXmoieties/chempy_results/vmh2_reconx_for_atom_mapping/rxnfiles/atomMapped/` into `test/verifiedTests/analysis/testReactingMoieties/data/rxnFiles/` (research R10). `HMR_2634.rxn` is already vendored (feature 019); do not duplicate it.
- [X] T006 Build minimal submodel `.mat` fixtures under `test/verifiedTests/analysis/testReactingMoieties/data/`, following the `crnBondKeySubmodel.mat` pattern (`extractSubNetwork` from `test/models/mat/Recon3D_301.mat` — the same base model feature 019's fixture and quickstart.md's manual-check example use — saved self-contained): one covering `PPACOAATREVm`/`HMR_3173`/`HYPGCOAHLm` (`coa[m]`), one covering `DDCDATMTCOAHLx`/`FAOXC2442246x`/`PTCA3ZCOAHLx`/`VITEATENCOXCOAxr` (`coa[x]`), one covering `DCA4Z7ZCOAr`/`STCOAATr` (`coa[r]`), and one covering `HMR_2634`/`PPACOAATREVm` (`crn[m]`) — combine into fewer files if a natural grouping avoids duplication (e.g. `PPACOAATREVm` appears in both a `coa[m]` and a `crn[m]` fixture). If any of these nine metabolite instances is not actually present in `Recon3D_301.mat`, source an alternative base model and record the substitution and reason in the implementation receipt (T027).
- [X] T007 Build `dBTM` for each new submodel from T006 against the current (pre-fix) code and confirm the pre-fix baseline matches the spec's Problem Statement exactly: `coa[m]`/`coa[x]`/`coa[r]` each resolve to 86 nodes (true 82) and `crn[m]` resolves to 29 nodes (true 25), with the FR-008 `does not match its true bond count` warning firing for each. Record for the implementation receipt (T027).
- [X] T008 [P] Confirm the reproducibility commands for this feature: `testConservedReactingMoieties` (extended, T009) plus the new `testIdentifyAtomEquivalenceClasses` (new file, T010) — no other new test file is created (Constitution III-Naming, research R9)

**Checkpoint**: Fixtures vendored and committed, pre-fix baseline captured for all four target metabolite instances.

---

## Phase 3: User Story 1 - Correct Bond-Node Identity For Metabolites With Symmetric Atom Groups (Priority: P1) 🎯 MVP

**Goal**: Atoms belonging to the same symmetry-equivalence class resolve to the same canonical bond-node identity regardless of which RXN file's raw numbering produced them, and a resonance bond's formal type resolves deterministically, so `coa[m]`/`coa[x]`/`coa[r]` resolve to 82 nodes and `crn[m]` resolves to 25 nodes, with no FR-008 warning.

**Independent Test**: Rebuild `dBTM` for the `coa[m]` fixture (`PPACOAATREVm`/`HMR_3173`/`HYPGCOAHLm`); confirm exactly 82 bond nodes (not 86). Rebuild for the `crn[m]` fixture (`HMR_2634`/`PPACOAATREVm`); confirm exactly 25 bond nodes (not 29).

### Tests for User Story 1

- [X] T009 [P] [US1] Add a clearly-separated section to `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m` that loads each T006 submodel fixture, builds `dBTM`, and asserts: `coa[m]` resolves to exactly 82 `dBTM.Nodes` rows, `coa[x]` to exactly 82, `coa[r]` to exactly 82, `crn[m]` to exactly 25 — each with no `does not match its true bond count` warning (spec FR-007, SC-001-003)
- [X] T009b [US1] Extend the `crn[m]` assertions from T009 (same file/section — depends on T009) to also read `dBTM.Nodes.BondType` for the canonicalized carboxylate bond-node (the atom-3/atom-6 resonance bond identified in research R2.3/R7) and assert it equals the bond type recorded in whichever of `HMR_2634`/`PPACOAATREVm` is processed first in `model.rxns` order for the `crn[m]` submodel — determine and hardcode the expected literal value (1 or 2) during T007's baseline-capture pass, alongside the existing node-count baseline, so the assertion is concrete rather than symbolic (spec FR-003; closes analysis finding C1, which found node-count-only assertions cannot distinguish a correct node count with the wrong resolved bond type)
- [X] T010 [P] [US1] Create `test/verifiedTests/analysis/testReactingMoieties/testIdentifyAtomEquivalenceClasses.m` (Constitution III-Naming: new source function gets its own test file) asserting: (a) a known symmetric group (e.g. a gem-dimethyl pair reconstructed from `coa[m]`'s own molblock) is detected as one equivalence class and both members canonicalize to the same representative atom number; (b) two atoms sharing an element but distinguishable elsewhere in the molecular graph are NOT merged into the same class (collision-free, FR-004); (c) a metabolite with two independent equivalence classes (e.g. `crn[m]`'s trimethylammonium and carboxylate groups) detects both simultaneously and correctly (FR-005); (d) only a subset of a class's members swapped between two inputs (not a full rotation) still canonicalizes correctly (FR-002, the CoA H49/H52-anchor edge case)

### Implementation for User Story 1

- [X] T011 [US1] Create `src/analysis/topology/reactingMoieties/identifyAtomEquivalenceClasses.m`: given one metabolite's `atoms`/`bonds` tables (from `readABRXNFile.m`), build an undirected atom-adjacency graph (node attribute = element, edge attribute = bond type) and run iterative color refinement (data-model.md "Symmetry-Equivalence Class") to a fixed point; cross-check each candidate class with `isisomorphic` (MATLAB base Graph and Network Algorithms, already precedented in `identifyIsomorphicClasses.m`) to guard against a color-refinement false-positive; return the equivalence classes and the `atomNumber -> canonicalAtomNumber` map (data-model.md "Canonical Atom Rank"), using the openCOBRA header format (Constitution VII-E) matching `canonicalBondKey.m`'s documented style
- [X] T011a [US1] Fix unbounded per-round string growth in `identifyAtomEquivalenceClasses.m`'s color-refinement loop (the `for iter = 1:maxIter` block, currently around lines 117-141, specifically `newColor{k} = [color{k} '|' signature];`): each round currently carries forward the *entire concatenated history* of every prior round's color string rather than a compact per-round label, so a node's color string length (and therefore total memory) grows multiplicatively by roughly `(average node degree + 1)` per iteration instead of staying bounded. This was confirmed as the cause of two real MATLAB out-of-memory kills during implementation attempts on 2026-08-18 (`anon-rss` 17.9GB at 16:50:42 and 25.3GB at 17:01:35, against 31GB total system memory) — the process was killed by the kernel OOM killer, not merely slow. Fix: immediately after computing `newColor` each round, collapse it to a short canonical per-round label before it is used as an input to the *next* round's signature — e.g. `[~, ~, ic] = unique(newColor); color = cellstr(num2str(ic));` (or equivalent) — so only a compact label, never the raw concatenated string, is ever carried forward. `groupIndicesByColor` and the convergence check (`isequal(oldGroups, newGroups)`) already operate on the partition rather than the raw string values, so neither needs to change. Extend `testIdentifyAtomEquivalenceClasses.m` (T010) with a regression case exercising a metabolite requiring several refinement rounds to converge (e.g. a synthetic unbranched chain of >=15 identical-element atoms) and assert that each round's color-label length stays bounded (does not grow with iteration count), so this class of blowup cannot silently reappear. Must land before T022 (which failed twice against this exact defect at corpus scale) is attempted again.
- [X] T012 [US1] In `buildAtomAndBondTransitionMultigraph.m`, add a per-metabolite `containers.Map` cache for the canonical-rank map (mirroring the existing `metBondCountGroundTruth` "compute once, first time seen" pattern at lines 577-588), calling `identifyAtomEquivalenceClasses` the first time each metabolite is encountered in the main reaction loop
- [X] T013 [US1] Remap `bondMappings.headAtoms`/`.tailAtoms` (and the corresponding `dATME.Nodes.AtomNumber` atom-index lookups at lines 612-619) through the current metabolite's canonical-rank map immediately before the existing `canonicalBondKey(...)` calls (lines 604-609), per data-model.md's "Canonical Atom Rank" consumption point — `canonicalBondKey.m` itself is not modified (research R6)
- [X] T014 [US1] Add the Canonical Bond-Type Cache (data-model.md): a `containers.Map` keyed by canonicalized bond-node identity string, populated with each key's `bTypes` value only the first time it is encountered (`if ~isKey(...)`, same idiom as `metBondCountGroundTruth`), in the same per-reaction loop pass that builds `EdgeTable`
- [X] T015 [US1] After `dBTM = digraph(EdgeTable)` and node-level `BondType` construction (around line 655), override `dBTM.Nodes.BondType` from the T014 cache (indexed by `dBTM.Nodes.Name`/`.Bond`) so the final bond type is deterministically first-RXN-file-encountered (spec FR-003, research R7), independent of `mapAontoBOld`'s incidental Head-before-Tail resolution order
- [X] T016 [US1] Run the targeted regression from T009/T009b: confirm post-fix `coa[m]`/`coa[x]`/`coa[r]` each resolve to exactly 82 `dBTM.Nodes` rows (was 86) and `crn[m]` resolves to exactly 25 (was 29), with no FR-008 warning for any of the four, and that `crn[m]`'s canonicalized carboxylate bond-node's `BondType` matches T009b's first-seen-file expectation. Record pass/fail evidence for the implementation receipt (T027).

**Checkpoint**: User Story 1 is complete when all four target metabolite instances resolve to their true bond counts with no FR-008 warning.

---

## Phase 4: User Story 2 - No Regression For Non-Symmetric Metabolites Or Feature 019's Fix (Priority: P2)

**Goal**: Metabolites with no symmetry-equivalence class, and feature 019's already-fixed `crn[c]` case, are byte-for-byte unchanged; a metabolite whose equivalence-class detection is inconclusive warns and falls back safely without halting the run.

**Independent Test**: Rebuild `dBTM` before/after this feature's change for feature 019's existing regression fixtures (`r0317`/`ACONTm`/`r0426`, the `crn[c]` 3-reaction case); confirm byte-for-byte-unchanged node counts, edge counts, and keys. Separately, feed a deliberately malformed/inconclusive input to the new detector and confirm it warns, falls back, and does not halt.

### Tests for User Story 2

- [X] T017 [P] [US2] Run the full `testConservedReactingMoieties.m`; confirm every pre-existing assertion (feature 019's `crn[c]` 25-node case, the `r0317`/`ACONTm`/`r0426` fixture, the `L*N = 0` invariant, moiety/subgraph counts) passes unchanged after the US1 implementation (spec FR-006, SC-004)
- [X] T018 [P] [US2] Add a fault-injection assertion to `testIdentifyAtomEquivalenceClasses.m`: a deliberately malformed or non-terminating-refinement input triggers a visible warning naming the metabolite, returns the identity canonical-rank map (equivalent to feature 019's plain atom-number behavior), and does not raise an error (spec FR-011)

### Implementation for User Story 2

- [X] T019 [US2] Implement the FR-011 warn-and-fall-back path inside `identifyAtomEquivalenceClasses.m` (data-model.md "Detection-Inconclusive Fallback State"): on a non-terminating refinement or a structurally malformed input, emit `warning(...)` naming the metabolite (Constitution VII-B — visible, not suppressed) and return the identity map (every atom number maps to itself) instead of erroring, so the caller (T012's cache-population site) transparently falls back to feature 019's existing behavior for that metabolite only
- [X] T020 [US2] Re-review `identifyConservedReactingMoieties.m`, `identifyConservedReactingSubgraphs.m`, and `extractBondSubgraphs.m` against the T011-T015 changes actually applied; confirm (per feature 019's research R3 finding, re-checked here) that none has an order- or count-dependent assumption the equivalence-class remap or bond-type cache could break — no source change expected in any of the three (spec FR-010)
- [X] T021 [US2] Run the full `testConservedReactingMoieties.m` and `testIdentifyAtomEquivalenceClasses.m` together; confirm all assertions pass, with zero regressions in any feature-019-era assertion

**Checkpoint**: User Stories 1 and 2 both work independently — the fix is correct, does not silently change anything it shouldn't, and degrades safely on inconclusive input.

---

## Phase 5: User Story 3 - Scope The Full Blast Radius Before Implementation (Priority: P3) — pre-implementation scoping SATISFIED, post-fix confirmation remains

**Goal**: The pre-implementation full-network scoping pass (FR-009) is already done (1,171 distinct metabolites catalogued, research.md R4). What remains for this story is the post-fix half of SC-005: confirming the count of metabolites mismatching for this bug class has dropped to zero.

**Independent Test**: Run the FR-008 sanity check, via the actual (now-fixed) MATLAB pipeline, across a materially larger reaction sample than the original 75; confirm no previously-affected metabolite still mismatches for this bug class.

### Implementation for User Story 3

- [X] T022 [US3] Run `buildAtomAndBondTransitionMultigraph.m` with `options.sanityChecks=1` across a post-fix reaction sample materially larger than the original 75 but deliberately bounded well below full-corpus scale — target on the order of **300-500 RXN files** (roughly 4-7x the original 75-file baseline), processed in **batches of no more than ~100 files per MATLAB invocation**, restarting the MATLAB process between batches. Do **not** attempt the ~16,485-file corpus scale in this feature: two real MATLAB out-of-memory kills were observed running this pipeline at corpus-approaching scale during implementation attempts on 2026-08-18 (`anon-rss` 17.9GB and 25.3GB against 31GB total system memory) — T011a's fix removes the specific defect that caused those, but a single-process full-corpus run remains an unnecessary risk this feature does not need to take to satisfy SC-005. Confirm T011a is complete and its regression test passes before starting this task. Catalogue any remaining FR-008 mismatches; confirm each is either resolved by this feature or manually classified as a separately-scoped issue outside this feature (spec SC-005). Record the actual sample size used, batch strategy, mismatch count before/after, and any remaining classified mismatches in the implementation receipt (T027).

**Checkpoint**: All three user stories are independently functional — the fix, its non-regression and safe degradation, and confirmation that the true blast radius is resolved.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final validation, diff hygiene, and receipt.

- [X] T023 [P] Review `buildAtomAndBondTransitionMultigraph.m`, `identifyAtomEquivalenceClasses.m` for MATLAB standards compliance: no `evalc` shadowing, no warning suppression, no new `nargin` usage (explicit `exist`/`isempty` checks for any optional argument), any new `try/catch` propagates full `ME.stack`, all new diagnostic output gated by the existing `options.sanityChecks` convention or emitted as an unconditional `warning` per FR-011
- [X] T024 [P] Confirm via `git diff` that `testConservedReactingMoieties.m` and `testCanonicalBondKey.m` have zero deletions of existing assertions — only additions; `testIdentifyAtomEquivalenceClasses.m` is a new file (Constitution III-Naming), nothing to compare against
- [X] T025 Downstream-consumer spot check (spec FR-010, SC-006): compare `identifyConservedReactingMoieties`/`identifyConservedReactingSubgraphs` output before vs. after this feature's change, for a model containing a previously-affected metabolite (e.g. `coa[m]` via `PPACOAATREVm`/`HMR_3173`/`HYPGCOAHLm`); confirm any output change is limited to the corrected node counts, with no other behavioral difference
- [X] T026 Run `git status --short`; confirm only the intended source/test/fixture/spec changes are present — no untracked generated diaries, logs, or temporary `.mat` probe artifacts inside the repository, and nothing created under `experiments/` (research R8)
- [X] T027 Create the implementation receipt in `specs/020-canonicalize-symmetric-atom-bonds/agent-runs/<UTC-timestamp>-canonicalize-symmetric-atom-bonds/implementation-receipt.md` with files changed, checks run, pass/fail results, the T022 blast-radius confirmation, any residual unverified behavior, and the final response copied verbatim into the `Final response` section

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies.
- **Foundational (Phase 2)**: Depends on Setup completion and blocks all user stories.
- **US1 (Phase 3)**: Depends on Foundational; MVP and the actual defect fix.
- **US2 (Phase 4)**: Depends on Foundational; the T017/T021 full-test validations should run after US1 implementation so the combined path is what's actually proven regression-free.
- **US3 (Phase 5)**: Depends on Foundational and, practically, on US1 (T022 validates the fix that US1 implements) — run last among the user stories.
- **Polish (Phase 6)**: Depends on all desired user stories.

### User Story Dependencies

- **User Story 1 (P1)**: Start after Foundational; no dependency on US2 or US3.
- **User Story 2 (P2)**: Start after Foundational; T017/T021's full-suite validation is only meaningful once US1's code exists.
- **User Story 3 (P3)**: Start after Foundational; T022 validates US1's fix at network scale, so run after US1 (and ideally after US2 confirms no regression).

### Parallel Opportunities

- T002, T003, T004 can run in parallel (different inspection targets).
- T008 can run in parallel with T005-T007 (names the existing/planned reproducibility commands without touching fixtures).
- T009 and T010 can run in parallel (different test files); T009b depends on T009 (same file/section) and follows it.
- T017 and T018 can run in parallel (different test files/concerns).
- T023 and T024 can run in parallel (review different files).

---

## Parallel Example: User Story 1

```text
Task: "T009 [P] [US1] Add coa[m]/coa[x]/coa[r]/crn[m] node-count and no-warning assertions to test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m"
Task: "T010 [P] [US1] Create test/verifiedTests/analysis/testReactingMoieties/testIdentifyAtomEquivalenceClasses.m"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 and Phase 2 (fixtures vendored, pre-fix baseline captured).
2. Implement US1: `identifyAtomEquivalenceClasses.m` plus the four integration points in `buildAtomAndBondTransitionMultigraph.m` (canonical-rank cache, remap before `canonicalBondKey`, bond-type cache, `BondType` override).
3. Validate with the targeted regression (T016).
4. Stop and confirm `coa[m]`/`coa[x]`/`coa[r]` resolve to 82 nodes and `crn[m]` to 25, with no warning.

### Incremental Delivery

1. US1: Fix the actual symmetry/resonance bond-node identity bug.
2. US2: Confirm no regression for unaffected metabolites, feature 019's fix, or downstream consumers; confirm safe degradation on inconclusive input.
3. US3: Confirm the true (~1,171-metabolite) blast radius is resolved at network scale.
4. Polish: final hygiene checks, downstream spot check, and the implementation receipt.

### Notes

- Every task above follows `- [X] T### [P?] [US?] Description with file path`.
- `[P]` marks tasks that touch different files or only gather evidence.
- Do not edit source or tests until the implementation phase is explicitly invoked.
- Do not commit generated logs, diaries, saved probe `.mat` files, or temporary MATLAB artifacts; do not create anything under `experiments/` in this repository (research R8).
- `canonicalBondKey.m` is read but not modified (research R6) — no task edits it.
- Per research R6: `readABRXNFile.m`, `addBondMappingsRXNFile.m` need no source change; T020 (identifyConservedReactingMoieties.m/identifyConservedReactingSubgraphs.m/extractBondSubgraphs.m re-review) is verification-only unless it surfaces an unexpected dependency.
