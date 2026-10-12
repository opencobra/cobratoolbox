# Tasks: Exact isomorphism for near-symmetric bond components, and reading RXN reactions with no bonds

**Input**: Design documents from `/specs/20261012-093525-symmetric-iso-zero-bond/` ([spec.md](spec.md), [plan.md](plan.md), [research.md](research.md), [quickstart.md](quickstart.md))

**Prerequisites**: spec, plan and research present; no open clarifications. Implementation starts only on an explicit implementation command (Constitution Principle VI).

**Tests**: required (spec FR-007, Traceability table); written before the code they cover.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: can run in parallel (different files, no dependency on an incomplete task)
- **[Story]**: US1 exact classification, US2 zero-bond reading

---

## Phase 1: Setup

- [X] T001 Copy the stuck pair from reconXmoieties (`results/ki001_strip_h/lastUnlabelledPair_noH.mat`: label-only copies `g1`, `g2`) into `test/verifiedTests/analysis/testReactingMoieties/data/nearSymmetricBondComponentPair.mat`, keeping only `g1` and `g2`; commit it as a normal binary `.mat` like the existing references in that folder
- [X] T002 [P] Create RXN fixtures under `test/verifiedTests/analysis/testReactingMoieties/data/rxn/`: `H2Ot_implicitH.rxn` (h2o[c] → h2o[e], one O atom per side, mapping 1↔1, no bonds), `KCLt_implicitH.rxn` (two single-atom ions per side, no bonds), and a bonded companion `ETOHt_implicitH.rxn` (ethanol transport, heavy atoms only)

---

## Phase 2: Foundational

- [X] T003 Record the baseline before any source change: run `test/verifiedTests/analysis/testReactingMoieties/` on develop f1581781c and save pass/fail per test; time unlabelled classification on the 1,960-reaction capture `/home/jackmcgoldrick/repos/reconXmoieties/results/moietySizing/outputs/conservedMoietyHotspots/n1960-identifyInputs.mat` (feature 20260930-102230's quickstart), using an adapted copy of `specs/20260930-102230-isomorphism-label-only-copies/isomorphismLabelOnlyCheck.m` saved in this feature's folder, N = 3; stop and report if the capture is missing; save to `results/20261012-093525-symmetric-iso-zero-bond/baseline_timing.mat` (SC-005 baseline)
- [X] T004 [P] Verify MATLAB coding standards for the files this feature edits (`classifySubgraphIsomorphism.m`, `readABRXNFile.m`): no evalc (VII-A), warnings visible (VII-B), try/catch keeps `ME.stack` (VII-C), no `nargin` for optional arguments (VII-D); consult the MATLAB best-practice skill if one is available (Principle VII-F) and note the outcome in the receipt

**Checkpoint**: baseline recorded; user stories can proceed (US1 and US2 touch different files).

---

## Phase 3: User Story 1 — Exact classification of near-symmetric components (P1) 🎯 MVP

**Goal**: unlabelled candidate pairs decided exactly without stalling (FR-001–FR-003, SC-001).

**Independent Test**: `runtests('testClassifySubgraphIsomorphism')` including the new cases; stored pair classified as one class within 5 s.

### Tests for User Story 1

- [X] T005 [P] [US1] In `test/verifiedTests/analysis/testReactingMoieties/testClassifySubgraphIsomorphism.m`, add: (a) the stored pair from T001 is one isomorphism class, with a generous timed assertion (< 30 s, following the precedent in `testIdentifyAtomEquivalenceClasses`; SC-001's 5 s is measured in T011); (b) a graph and a random node relabelling are one class; (c) the same graph with one edge moved are two classes; (d) randomized equivalence with `isisomorphic` on 200 small cases (≤ 12 nodes; simple, multigraph, self-loops, directed; fixed `rng` seed), comparing classifications; (e) empty-graph and single-node-graph pairs (graph and digraph, with and without a self-loop) classify as `isisomorphic` would; (f) `classifySubgraphIsomorphism('getFallbackCount')` returns a non-negative integer and is reset by `'resetCallCount'`
- [X] T006 [P] [US1] Confirm the existing reference cases (`data/classifySubgraphIsomorphismReference.mat`: classifications, call counts, errors) still load and assert unchanged; extend the test header (Purpose, Authors) with this feature's cases (Principle VII-E)

### Implementation for User Story 1

- [X] T007 [US1] In `src/analysis/topology/reactingMoieties/classifySubgraphIsomorphism.m`, add local functions: multiplicity adjacency from `findedge` with `sparse` accumulation (undirected symmetric, self-loops on the diagonal, digraph in/out separate); joint colour refinement with histogram rejection; individualisation–refinement search with a named node-budget constant (1e5) and bijection verification on the multiplicity matrices (research R1, R2, R3)
- [X] T008 [US1] Use the exact test for unlabelled candidate pairs only (`isempty(varargin)`), keep `isisomorphic` for labelled calls, increment `isisomorphicCallCount` once per candidate pair either way, and on budget exhaustion call `isisomorphic` and increment a new persistent fallback counter (research R4, R5)
- [X] T009 [US1] Add the action `'getFallbackCount'` (and reset it in `'resetCallCount'`); update the function help: algorithm, exactness, fallback, new action, provenance line for this feature (VII-E)
- [X] T010 [US1] Run T005 and T006 and the whole `testReactingMoieties` folder; all pass with golden references unchanged (SC-002)
- [X] T011 [US1] Measure SC-001 (stored pair, N = 3, maximum) and SC-005 (1,960-reaction model, N = 3, median, against T003) and save to `results/20261012-093525-symmetric-iso-zero-bond/`

**Checkpoint**: US1 complete and independently verified.

---

## Phase 4: User Story 2 — Reading RXN reactions with no bonds (P2)

**Goal**: zero-bond reactions read and built (FR-004, FR-005, SC-004).

**Independent Test**: `runtests({'testReadABRXNFile','testBuildAtomAndBondTransitionMultigraph'})`.

### Tests for User Story 2

- [X] T012 [P] [US2] Create `test/verifiedTests/analysis/testReactingMoieties/testReadABRXNFile.m` (header per VII-E; `prepareTest` declarations as in the sibling tests): `H2Ot_implicitH` and `KCLt_implicitH` read without error, atom table has the mappings, bond table is empty with variables `mets, headAtoms, tailAtoms, bTypes, headAtomElements, tailAtomElements, headAtomTransitionNrs, tailAtomTransitionNrs, isSubstrate, instances`; `ETOHt_implicitH` and an existing explicit-H fixture produce the same tables as on develop (captured in T003 if needed)
- [X] T013 [P] [US2] In `test/verifiedTests/analysis/testReactingMoieties/testBuildAtomAndBondTransitionMultigraph.m`, add a two-reaction model (`ETOHt_implicitH`, `H2Ot_implicitH`) built from the fixture folder: build completes, the water reaction's atom transitions are in the atom graph, it contributes no bond transitions

### Implementation for User Story 2

- [X] T014 [US2] In `src/analysis/topology/reactingMoieties/readABRXNFile.m`, create `headAtomElements` and `tailAtomElements` (n-by-1 cell) before the per-bond loop and build the empty bond table with typed empty columns, so the final reorder never indexes with 0 (research R6); update the help's provenance line
- [X] T015 [US2] Run T012 and T013; if the builder fails on the empty bond table, fix the smallest place in `src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m` that the test exposes, and re-run (research R7)

**Checkpoint**: US2 complete and independently verified.

---

## Phase 5: Polish & Cross-Cutting

- [X] T016 [P] Update `src/analysis/topology/reactingMoieties/KNOWN_ISSUES.md` KI-001: the hydrogen-removal evidence (reconXmoieties exploration ki001-hydrogen-stripping, E3–E5, E9), the second, hydrogen-independent mechanism (E10–E11), what this feature resolves (exact unlabelled classification; zero-bond reading) and what stays open (FR-009)
- [X] T017 Run the external check of quickstart step 4 in reconXmoieties (pufa n = 514 with hydrogen-free RXN files and moiety graphs on; then full pufa) and record the result (SC-003)
- [X] T018 Run the whole `test/verifiedTests/analysis/testReactingMoieties/` folder and the quickstart scenarios; report files edited, checks run, pass/fail, and any unverified behaviour
- [X] T019 Create the implementation receipt in `agent-runs/<UTC-timestamp>-symmetric-iso-zero-bond/implementation-receipt.md`, with the actual final completion response copied verbatim into its `Final response` section

---

## Dependencies & Execution Order

- Phase 1 → Phase 2 → US1 and US2 (independent; different source files) → Polish.
- T001 before T005; T002 before T012 and T013; T003 before any source edit and before T011.
- T017 needs US1; it also benefits from US2 (no zero-bond reactions in the pufa subsystem, so not required).

## Parallel examples

- T001 and T002; T005 and T006; T012 and T013.
- US1 (T005–T011) and US2 (T012–T015) can proceed in parallel after Phase 2.

## Implementation Strategy

MVP is US1: it removes the remaining bond-level blocker for lipid networks. US2 is small and unblocks reconXmoieties spec 033 (implicit-H corpus) for its gate and moiety runs; doing both on this branch was the maintainer's decision (2026-10-12).
