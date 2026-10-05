# Tasks: Vectorize the stage02 reorientation loop and createBIGraph's edge-expansion loop

**Input**: Design documents from `specs/029-vectorize-atm-loops/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/function-interface.md, quickstart.md

**Tests**: This is a MATLAB behavioural-fidelity change, so per spec FR-009/FR-010 and
Constitution Principle III it carries two tiers: the existing CI test
(`testConservedReactingMoieties.m`, which must pass **unmodified**) and a non-CI documented
reproducibility check over all 8 fixtures. `testConservedReactingMoieties.m` is not edited at
all. One new CI test file is created, `testCreateBIGraph.m` (T013a) — permitted by Principle
III-Naming, since `createBIGraph` has no test file yet.

**Organization**: Tasks are grouped by the two user stories from spec.md. Unlike the generic
template, **Phase 2 (Foundational) is the largest and most time-critical phase**: the golden
baseline must be captured against unmodified `src/` before either story's rewrite lands
(research.md R9), and `pufa`'s capture alone is a multi-hour run.

**Revision (2026-09-18)**: Regenerated after the Clarifications entry recording that
`SCP2x.rxn` was quarantined from the corpus. All 8 fixtures, including `bileacid`, now run
through the normal pipeline; the harness-local stage02 mirror and saved-input path are retired
(research.md R6), and corpus provenance is recorded instead (R11).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: US1 or US2, per spec.md
- File paths are exact and absolute-from-repo-root

## Path Conventions

Two `src/` files only (SC-005):
- `src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m`
- `src/analysis/topology/reactingMoieties/createBIGraph.m`

New CI test (not `src/`):
- `test/verifiedTests/analysis/testReactingMoieties/testCreateBIGraph.m`

Feature-local, non-`src/` artifacts:
- `specs/029-vectorize-atm-loops/vectorizationReproducibilityCheck.m`
- `specs/029-vectorize-atm-loops/snapshots/<fixture>-golden-snapshot.mat`
- `specs/029-vectorize-atm-loops/vectorization-reproducibility-results.md`

External (read-only inputs, not repo state): `/media/JACK/repos/ctf/rxns/atomMapped_std`,
`~/repos/ReconXKG-cidev/ReconXKGtoCobra/models/subsystemSubModels/subsystemSubModels.mat`.

---

## Phase 1: Setup (Read-and-Map, Constitution Principle V)

**Purpose**: Confirm the exact edit points and the fidelity traps before touching either file.

- [X] T001 [P] Re-read `src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m` lines ~300-345 and confirm all three stage02 traps: the `else` branch is `orientation ~= 1` (not `== -1`, research.md R1), the forward branch's `strtok`/`rem(2:end)` yields `''` when `Trans` has no `#` (R2), and the reverse branch rebuilds `Trans` from the *swapped* atom names without stripping any prefix (R3).
- [X] T002 [P] Re-read `src/analysis/topology/reactingMoieties/createBIGraph.m` in full and confirm the accumulation loop (lines ~38-61), the `Weight`-forced-to-1 rule, and the construction tail (`addedge` then positional property assignment, skipping `EndNodes`) that research.md R5 requires be preserved verbatim.
- [X] T003 [P] Re-read `specs/022-eliminate-table-object-hotspots/tyrosineReproducibilityCheck.m` as the structural template (snapshot-presence mode selection, append-only results file), noting that its hardcoded `atomMapped_standardised` corpus path is stale and MUST NOT be copied forward (research.md R8).
- [X] T004 [P] Verify the fixture environment and record observed sizes: `subsystemSubModels.mat` exists, `/media/JACK/repos/ctf/rxns/atomMapped_std` exists, `SCP2x.rxn` is present in `atomMapped_std/flagged_for_review/` and absent from the top level, and each of the 8 fixtures' actual reaction/metabolite counts (they have changed since the 15 Sept 2026 record — research.md R8 note).

**Checkpoint**: Edit points and fidelity traps confirmed; no further exploratory reads needed.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Build the reproducibility harness and capture the pre-change golden baseline for
all 8 fixtures. **No `src/` rewrite may begin until the baseline exists** — once either file is
edited, the baseline is unrecoverable (research.md R9).

**⚠️ CRITICAL**: T008-T009 must run against `src/` that is unmodified except for T007's
temporary capture hook, which only saves state and does not alter output.

- [X] T005 Create `specs/029-vectorize-atm-loops/vectorizationReproducibilityCheck.m`: per-fixture capture/compare mode selection driven by whether `snapshots/<fixture>-golden-snapshot.mat` exists (so a run is resumable per FR-011), the 8-fixture list, corpus/model paths from T004 with up-front existence assertions, and an append-only `vectorization-reproducibility-results.md` writer recording the fields listed in data-model.md. Every fixture runs through the normal pipeline — there is no saved-input or mirror path (research.md R6, retired).
- [X] T006 In the same harness, record corpus provenance per research.md R11 — corpus path, top-level `.rxn` count, and sorted contents of `flagged_for_review/` — into every snapshot at capture and every results entry at compare; in compare mode, when a fixture's current provenance differs from its snapshot's, report "corpus changed since capture" for that fixture instead of reporting any `isequal` mismatch as a code regression.
- [X] T006a In the same harness, add the synthetic stage02 edge-case section (research.md R12): a local function that is a verbatim copy of the **original** stage02 loop (`identifyConservedReactingMoieties.m` lines ~321-335, copied now, before any `src/` edit, and labelled with those source lines), plus hand-built `ATM.Edges` inputs covering orientation-`0` rows, a `Trans` with no `#`, a `Trans` with several `#`, an empty table, all-forward, and all-reverse. The copy of the new block is added in T011a.
- [X] T007 Add a TEMPORARY capture hook to `src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m`, immediately **after** the stage02 `sanityChecks` block (after line ~349). When the environment variable `CBT029_CAPTURE_FILE` is non-empty, it runs `save(getenv('CBT029_CAPTURE_FILE'), 'stage02AtmEdges', 'stage02Seconds')`, where `stage02AtmEdges = ATM.Edges` and `stage02Seconds` comes from `tic`/`toc` around lines ~321-335 (research.md R10). Mark every inserted line `% TEMPORARY (029 T007)`; T020 removes them. Add nothing to `createBIGraph.m`: the harness captures and times `createBIGraph(BG)` itself on the build output `BG`, verified identical to the input at line 566. Use `save`/`getenv` only, never `evalc` (VII-A).
- [X] T008 Run capture mode against unmodified `src/` for the seven fast fixtures (`nglycan`, `phe`, `andest`, `chol`, `urea`, `tyr`, `bileacid`) and confirm each writes a snapshot containing `atmEdges`, `bigNodes`/`bigEdges`, `corpusProvenance`, and pre-change timings. `bileacid` must be captured fresh against the post-quarantine corpus; no earlier `bileacid` capture is comparable (spec Assumptions).
- [X] T008a Run `tyr` through the pipeline with `options.sanityChecks = 1` against the pre-change code, and confirm T007's capture file is written. Because the hook sits after the stage02 `sanityChecks` block, the file's existence proves that block ran and passed (FR-006). The later crash with `sanityChecks = 1` recorded by feature 027 (a separate, downstream stage unrelated to stage02) may still occur afterwards; record it, but do not count it as a failure.
- [X] T009 Run capture mode for `pufa` as a background session (multi-hour; measured 2026-09-17 at ~744 s build plus a full-mode identify exceeding 3 h 48 min) and confirm its snapshot is written before any Phase 3/4 edit is applied.
- [X] T010 Record each snapshot's size and apply research.md R7's policy: snapshots ≤10 MB are kept under `specs/029-vectorize-atm-loops/snapshots/`; any larger one is written to the sibling `reconXmoieties` results tree instead, with its path and hash recorded in the results file rather than committed here.

**Checkpoint**: A pre-change golden baseline exists for all 8 fixtures. The rewrites may now begin.

---

## Phase 3: User Story 1 - Stage02 reorientation stops rebuilding strings row by row (Priority: P1) 🎯 MVP

**Goal**: The stage02 loop is replaced by vectorized statements producing byte-identical
`ATM.Edges`.

**Independent Test**: Run the CI test (passes unmodified) and the harness in compare mode for
the stage02 tables; `ATM.Edges` is `isequal` to the baseline on every fixture, independent of
whether User Story 2 has been done.

- [X] T011 [US1] In `src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m`, replace the `for i=1:nTransInstances` loop (lines ~321-335) with a vectorized implementation: `fwdBool = (orientationATM2dATM == 1)` with the reverse branch applied to `~fwdBool` (research.md R1); forward `Trans` via `cellfun` applying the identical `strtok`/`rem(2:end)` expression (R2); reverse rows via bulk logical-index assignment of `HeadAtomIndex`/`TailAtomIndex` from `EndNodes(:,2)`/`EndNodes(:,1)`, a swap of `HeadAtom`/`TailAtom` computed before either is assigned, and `Trans` rebuilt with `cellfun(@(h,t)[h '#' t], ...)` (R3). Touch no other `ATM.Edges` column and do not modify `orientationATM2dATM` (FR-002).
- [X] T011a [US1] In the harness's synthetic stage02 section (T006a), add a local function that is a verbatim copy of the **new** block T011 just shipped, labelled with its source lines, then run every synthetic case through both copies and assert `isequal`, logging each case to the results file. This is the only check that exercises the orientation-`0` trap (research.md R1) and the no-`#`/multi-`#` `Trans` cases (R2); it proves semantics, not the shipped code (R12).
- [X] T012 [US1] Run the harness in compare mode for the seven fast fixtures (including `bileacid`) and assert `ATM.Edges` is `isequal` to each baseline (SC-002), with corpus provenance matching; append outcomes and stage02 before/after timings to the results file.
- [X] T012a [US1] Repeat T008a after T011's rewrite: `tyr` with `options.sanityChecks = 1` must again write the capture file (proving the stage02 `sanityChecks` block still passes, FR-006), and its `ATM.Edges` must be `isequal` to T008a's.
- [X] T013 [US1] Run `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m` end-to-end and confirm it passes with every assertion unmodified (FR-009, SC-001); confirm via `git diff` that the test file itself is untouched.

**Checkpoint**: User Story 1 is independently verifiable — stage02 is vectorized and proven identical, with `createBIGraph` still on its original loop.

---

## Phase 4: User Story 2 - createBIGraph stops growing its edge table per bond instance (Priority: P2)

**Goal**: `createBIGraph`'s O(n²) accumulation is replaced by a single `repelem`-based
expansion producing byte-identical `BIG.Nodes`/`BIG.Edges`.

**Independent Test**: Harness compare mode for the `BIG` tables on all 8 fixtures; `isequal`
against baseline, independent of User Story 1.

**Depends on**: Phase 2 only (the baseline). It does not depend on User Story 1, though in
practice both land before the Polish phase's full-fixture runs.

- [X] T013a [US2] **Test first.** Create `test/verifiedTests/analysis/testReactingMoieties/testCreateBIGraph.m` as a characterization test on synthetic graphs, asserting against hand-computed expected tables: (a) every `Weight == 1` gives one row per edge; (b) mixed weights 1/2/3 give a row count equal to the sum of weights, in edge-major order; (c) a cell-array edge property is copied once per instance; (d) the energy node (`Element == 'E'`) and its edges are removed; (e) zero edges remain after that removal; (f) `EdgeIndex == (1:n)'` and `Weight` is all ones; (g) a non-integer weight (e.g. 2.7) and a zero weight behave as the original loop does (truncate; emit nothing). Run it against the **unmodified** `createBIGraph.m` and confirm cases (a)-(d), (f) and (g) pass before T014 begins. Case (e) is expected to FAIL there: the pre-change function crashes on zero-edge input (line 81), and the user chose to fix that in this feature (spec Clarifications, zero-edge entry) — so (e) is the one red->green case; it then guards the rewrite. No solver is needed, so no `prepareTest` requirement is declared beyond the file's standard setup.
- [X] T014 [US2] In `src/analysis/topology/reactingMoieties/createBIGraph.m`, replace the nested `for edgeIdx` / `for bInstance` accumulation (lines ~38-61) with `rowIdx = repelem((1:numEdges)', graphNoE.Edges.Weight)` and one indexed copy per property column, setting `Weight` to `ones(numel(rowIdx),1)` (research.md R4). Preserve the construction tail verbatim — same `newEdgesTable`, same `addedge` call, same positional property assignment skipping `EndNodes` (R5) — since `addedge` sorts by (source, target) and the existing correctness depends on the input arriving sorted.
- [X] T015 [US2] In the same function, use `max(floor(Weight), 0)` as the `repelem` count, which reproduces the loop's `for bInstance = 1:bondMult` exactly for any finite `Weight` (truncating non-integers, emitting nothing for zero or negative) and is a no-op for integer weights (research.md R4). Confirm T013a's case (g) passes against the rewritten function.
- [X] T016 [US2] Run the harness in compare mode for the seven fast fixtures (including `bileacid`) and assert `BIG.Nodes` and `BIG.Edges` are `isequal` to each baseline, including `Weight` and `EdgeIndex` (SC-003); append outcomes and `createBIGraph` before/after timings to the results file.
- [X] T017 [US2] Re-run `testConservedReactingMoieties.m` and `testCreateBIGraph.m` with both rewrites in place and confirm both pass; `testConservedReactingMoieties.m` must remain unedited (FR-009, SC-001).

**Checkpoint**: Both rewrites are in and proven identical on every fast fixture.

---

## Phase 5: Polish & Verification

- [X] T018 Run the harness in compare mode for `pufa` (multi-hour background session) covering both stories, and append its `isequal` outcomes, provenance check, and timings to the results file.
- [X] T019 Record the SC-004 figures for `tyr` in `specs/029-vectorize-atm-loops/vectorization-reproducibility-results.md` and confirm they meet the floors (≥100x stage02, ≥200x `createBIGraph`), reporting the measured numbers rather than a bare pass/fail.
- [X] T020 Remove T007's temporary capture hook (every line marked `% TEMPORARY (029 T007)`) and verify the shipped diff is clean: `git diff --stat -- src/` shows exactly the two `src/` files, and `git diff -- src/ | grep -E "tic|toc|CBT029_CAPTURE_FILE|TEMPORARY"` prints nothing (research.md R10, SC-005, SC-006).
- [X] T021 [P] Verify MATLAB coding-standards compliance for the diff: no `evalc` (VII-A), no suppressed warnings (VII-B), no new `try/catch` (VII-C), no `nargin` introduced (VII-D), help headers unchanged since neither signature nor documented behaviour changed (VII-E), and vectorization idioms consistent with the openCOBRA style guide (VII-F/G). Also confirm the harness's two stage02 copies are faithful (research.md R12): the original-loop copy matches the pre-change lines, and the new-block copy is character-for-character identical to the shipped lines in `identifyConservedReactingMoieties.m`.
- [X] T022 [P] Run `specs/029-vectorize-atm-loops/quickstart.md`'s procedure end-to-end once and record its output.
- [X] T023 Report files changed, checks run, tests passed/failed, and any behaviour not yet verified (Constitution Principle III closing requirement) — explicitly stating the corpus provenance every baseline was captured against, and whether `pufa`'s compare run completed.
- [X] T024 Create the implementation receipt at `specs/029-vectorize-atm-loops/agent-runs/<UTC-timestamp>-<short-name>/implementation-receipt.md` with Prompt, Final response (verbatim), Diff summary, Tests, and Unresolved issues sections (Constitution Implementation Receipt Ledger).

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately.
- **Foundational (Phase 2)**: Depends on Setup. **Blocks both user stories.** T006a's
  original-loop copy, T008, T008a and T009 must all complete before any Phase 3/4 edit, against
  `src/` unmodified except for T007's hook.
- **User Story 1 (Phase 3)**: Depends on Phase 2 (baseline exists).
- **User Story 2 (Phase 4)**: Depends on Phase 2 only — independent of User Story 1, since the
  two rewrites touch different files and different tables. Within it, T013a (test first) must
  pass against the unmodified `createBIGraph.m` before T014.
- **Within User Story 1**: T011a follows T011 (it copies the shipped block); T012a follows T011.
- **Polish (Phase 5)**: Depends on both stories; T018 needs `pufa`'s baseline (T009) and both
  rewrites; T020 must run after all measurement tasks (T012, T016, T018, T019).

### Parallel Opportunities

- T001-T004 (Setup) can run in parallel — read-only, different files.
- T009 (`pufa` capture, hours) runs in the background alongside T005-T008 and alongside
  *writing* — but not applying — the Phase 3/4 rewrites.
- User Story 1 (T011-T013) and User Story 2 (T014-T017) touch different files and may proceed
  in parallel once Phase 2 is complete, aside from the shared harness results file.
- T021 and T022 (Polish) can run in parallel.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 (Setup) and Phase 2 (harness + baseline) — the latter is the bulk of the
   calendar time because of `pufa`.
2. Complete Phase 3 (T011-T013).
3. **STOP and VALIDATE**: CI test passes unmodified and `ATM.Edges` is `isequal` on every fast
   fixture. Stage02 alone accounts for ~20.8% of pipeline time per the spec's measurements.

### Full Delivery

1. Setup → Foundational → **checkpoint (baseline captured)** → User Story 1 → User Story 2 →
   Polish.
2. The one-way door is Phase 2: applying a rewrite before the baseline is captured destroys the
   ability to prove `isequal` at all, and re-capturing costs another multi-hour `pufa` run.

## Notes

- **The corpus is mutable, and that is now a first-class risk.** `bileacid`'s earlier failures
  were caused by `SCP2x.rxn`, since quarantined by the user into
  `atomMapped_std/flagged_for_review/`; `SCP2x` appears in no other fixture. If that file is ever
  restored, `bileacid` will fail again and its baseline becomes invalid. More generally, any
  corpus edit between capture and compare invalidates the affected fixtures' baselines — T006's
  provenance check exists so that such a change is reported as a corpus change, never as a code
  regression.
- T011 and T014 each touch one file only, and neither touches the CI test — which this feature
  must leave byte-identical.
- Per Constitution Principle VI, none of T005-T024 may begin until this tasks.md has been
  reviewed and implementation has been explicitly approved and invoked (`/speckit-implement`, or
  the agent-assign pipeline).
