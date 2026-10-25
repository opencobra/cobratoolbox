---

description: "Task list for feature 20260921-125236-sparse-bond-matrices"
---

# Tasks: Return buildAtomAndBondTransitionMultigraph's bond matrices as sparse, without changing its original behaviour

**Input**: Design documents from `/specs/20260921-125236-sparse-bond-matrices/`

**Prerequisites**: plan.md, spec.md, research.md (R1-R8), data-model.md (E1-E6), contracts/public-contract.md, quickstart.md

**Tests**: Required by the spec — a new CI test (FR-015), the unmodified
`testConservedReactingMoieties.m` (FR-011), and a non-CI golden-snapshot reproducibility
check (FR-012/FR-013). The CI test and the snapshot are written and exercised **before**
any `src/` edit.

**Organization**: One source edit serves all three stories. It sits in US1 (the P1
non-regression gate, MVP) because US1 is the acceptance test for every other story;
US2 and US3 then verify the storage/timing and dense-opt-in properties and add the
header documentation.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)

## Conventions used by every task

- `SRC` = `src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m`
- `TEST` = `test/verifiedTests/analysis/testReactingMoieties/testBuildAtomAndBondTransitionMultigraph.m`
- `HARNESS` = `specs/20260921-125236-sparse-bond-matrices/reproducibilityCheck.m`
- `FD` = `specs/20260921-125236-sparse-bond-matrices/`
- Line numbers refer to `SRC` at `develop` commit `97ecfc596` (== branch base).
- Run MATLAB headless from the repo root:
  `matlab -batch "initCobraToolbox(false); <commands>"`. Never suppress warnings;
  read every warning printed and act on it (Principle VII-B).
- Stop and report to the user (do not improvise) on any gate marked **STOP**.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm the starting state is the unmodified original and that fixture data is reachable.

- [X] T001 Confirm `git rev-parse HEAD` equals `git rev-parse develop` (`97ecfc596`) and `git diff develop -- SRC test/` is empty; then run `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m` via `matlab -batch` against the unmodified source and record that it passes (pre-change baseline). **STOP** if either fails.
- [X] T002 [P] Verify external and fixture data for `HARNESS`: `~/repos/ReconXKG-cidev/ReconXKGtoCobra/models/subsystemSubModels/subsystemSubModels.mat` loads and contains a Tyrosine sub-model (field matching `tyr`; 127 reactions in the 2026-09-17 file); `/media/JACK/repos/ctf/rxns/old/atomMapped_standardised` contains `.rxn` files (expected 17,224); `test/models/mat/Recon3D_301.mat` and the five sub-model fixtures in `test/verifiedTests/analysis/testReactingMoieties/data/` (`crnBondKeySubmodel.mat`, `coaMBondKeySubmodel.mat`, `coaXBondKeySubmodel.mat`, `coaRBondKeySubmodel.mat`, `crnMBondKeySubmodel.mat`) plus `data/rxnFiles/` exist. **STOP** and ask for the correct path if the tyrosine model or corpus is missing.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Capture the golden snapshot and write the CI test while `SRC` is still unmodified.

**⚠️ CRITICAL**: No edit to `SRC` until T005 and T007 are complete.

- [X] T003 Read research R9 (`FD/research.md`) and apply its rules 1-4 to every MATLAB file written in T004, T006 and T009. Record in the implementation receipt that R9 was consulted.
- [X] T004 Write `HARNESS` (`FD/reproducibilityCheck.m`) following research R7/R8 and data-model E5/E6, using `specs/20260902-150020-eliminate-bond-transition-ismember-scans/tyrosineReproducibilityCheck.m` as the structural template (header comment block with USAGE and "ADJUST BEFORE RUNNING" paths; capture vs compare mode chosen by existence of `FD/golden-snapshot.mat`; append-only `FD/reproducibility-results.md`; local `tern` helper). Required content:
  - **Fixtures** (in this order): `ci` = `extractSubNetwork(readCbModel(<CBTDIR>/test/models/mat/Recon3D_301.mat), {'r0317';'ACONTm';'r0426'})`; `crn`, `coaM`, `coaX`, `coaR`, `crnM` = `.subModel` of the five `data/*BondKeySubmodel.mat` files; `macaci` = the hand-built 4-met/2-rxn model exactly as in `testConservedReactingMoieties.m` (mets `maleacac[c]`,`4fumacac[c]`,`CHEBI_17105[c]`,`CHEBI_18034[c]`; rxns `MACACI`,`rh_14817`; same `S`, `lb`, `ub`) — all with `rxnFilesDir = test/verifiedTests/analysis/testReactingMoieties/data/rxnFiles`; `tyr` = tyrosine sub-model with corpus `/media/JACK/repos/ctf/rxns/old/atomMapped_standardised` (model-loading block copied from the template). Also `ci_noBond` = `ci` with `options.bondTransitionMultigraph = 0`, first five outputs only (the only outputs assigned in that mode; verified 2026-09-21) (US1 AS4); and `noRxnFiles` = the `ci` sub-model with `rxns` renamed to IDs that have no RXN file (`strcat(rxns, '_none')`), capturing in both modes either its outputs or its error `identifier` and `message` (propagated with `ME.stack(1)` per VII-C) and requiring the same outcome after the change. Required fixtures are `tyr` and `ci`; all others are optional (research R7). Record in the results file that the reconXmoieties pilot fixtures are not covered and why (research R7).
  - **Call**: `options.directed = 0; options.sanityChecks = 1;` then all twelve outputs of `buildAtomAndBondTransitionMultigraph`, console text captured with a local helper `runWithDiary` that saves `get(0,'Diary')`/`get(0,'DiaryFile')`, diaries to `tempname`, restores state via `onCleanup`, and returns the text (no `evalc`).
  - **Capture mode**: per fixture store E5 fields — `outputs` (1x12 cell; `M2BiE`/`M2BiW`/`BTi2R` stored via `sparse(...)`), `originalClasses` (`class` + `issparse` of all 12), `residuals` (atom: `max(abs((M2Ai*M2Ai')*N_a - M2Ai*incidence(dATM)*Ti2R))` with `N_a = model.S(metAtomMappedBool, rxnAtomMappedBool)`; bond: recompute `rxnBondMappedBool = ismember(model.rxns, dBTM.Edges.rxns)`, `metBondMappedBool = ismember(model.mets, dBTM.Nodes.mets(~ismember(dBTM.Nodes.Bond,{'E'})))`, `N_b = model.S(metBondMappedBool, rxnBondMappedBool)`, `max(abs((M2BiW(b,:)*M2BiE(b,:)')*N_b - M2BiE(b,:)*BTiE*BTi2R))` — mirroring SRC lines 828-836 and 956), `warningsSeen` (whether `Inconsistent directed atom transition multigraph` / `Inconsistent directed bond transition multigraph` occur in the diary text), `provenance` (corpus path, `.rxn` count, SHA-256 via `java.security.MessageDigest` of the sorted `name\tbytes\tdatenum` listing from `dir(fullfile(corpus,'*.rxn'))`, model path, `git rev-parse HEAD`). For `tyr` only, also `fillMedianSecondsBefore` = median of 5 `tic`/`toc` runs of `fillBondMatricesOriginal`. Assert the snapshot is `isequaln` to itself after reload. Save with `save(..., '-v7')`; print file size and `warning` (visible) if > 10 MB.
  - **Compare mode**: for each fixture and each mode (`denseBondMatrices` absent, and `= 1`): refuse with `error('reproducibilityCheck:CorpusChanged', ...)` if any provenance count/hash differs; SC-001 — every output `isequaln` to the snapshot (the three matrices compared as `full`, same `size`); also, for **all twelve** outputs, `class` and `issparse` checked against `originalClasses`: the only allowed difference is `issparse == true` for `M2BiE`, `M2BiW` and `BTi2R` in default mode, and in dense mode all twelve match `originalClasses` exactly (`isequaln` ignores data type, research R9 rule 3); SC-003 — `ci`: both residuals exactly 0 and neither inconsistency warning in the diary; every other fixture (including `tyr`): residuals and warnings identical to the snapshot's; all fixtures: bond mismatch report text identical to the snapshot's (FR-007); SC-004 — `whos` bytes of the three matrices as returned in default mode vs `full` of them, ratio reported, gate ≤ 0.10 only where `numel(model.mets) >= 50 && numel(model.rxns) >= 50`; edge checks — every column of `M2BiE`/`M2BiW` whose `dBTM.Nodes.mets` is not in `model.mets` has `nnz == 0`, every `model.mets` row with no bond node has `nnz == 0`; SC-005 (`tyr` only) — median of 5 runs of `fillBondMatricesModified`, PASS if ≤ `fillMedianSecondsBefore`. Append one `## Run <timestamp>` section with per-fixture/per-mode PASS/FAIL, all figures, provenance, then `assert` each gate so any FAIL errors after the results are written.
  - **Local functions**: `fillBondMatricesOriginal(modelMets, nodeMets, bondType, nBonds)` = verbatim body of SRC lines 883-893 (substituting `model.mets`→`modelMets`, `dBTM.Nodes.mets`→`nodeMets`, `dBTM.Nodes.BondType`→`bondType`) returning `[M2BiE, M2BiW]`; `fillBondMatricesModified(...)` = the research R1 construction, same substitutions. Fidelity (research R8): in both modes each copy's output, after `full`, MUST be `isequaln` to the function's returned `M2BiE`/`M2BiW` for the same call (original copy in capture mode, modified copy in compare mode); in compare mode also assert every non-blank code line of `fillBondMatricesModified`'s body (after reversing the substitutions) appears in order in `SRC`.
- [X] T005 Run `HARNESS` in capture mode via `matlab -batch "initCobraToolbox(false); run('specs/20260921-125236-sparse-bond-matrices/reproducibilityCheck.m')"` against the unmodified `SRC` (re-confirm `git diff develop -- SRC` empty first). Gates: `FD/golden-snapshot.mat` exists; every fixture's `originalClasses` shows `M2BiE`/`M2BiW`/`BTi2R` as full `double`; original-copy fidelity holds; `fillMedianSecondsBefore` recorded. **STOP** if the CI fixture's original bond or atom residual is nonzero or an inconsistency warning was seen (research R7). For every other fixture, including tyrosine (already inconsistent in the original; spec SC-003 as amended 2026-09-21), record the original residuals, warnings and bond mismatch report and continue. **STOP** and ask before committing if the snapshot is > 10 MB.
- [X] T006 [P] Write `TEST` following the openCOBRA test header and structure of `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m` (Purpose/Authors header; `global CBTDIR`; `prepareTest()`; `currentDir = pwd;` ... `cd(currentDir)` at the end; `fileDir = fileparts(which('testBuildAtomAndBondTransitionMultigraph'))`; `rxnFilesDir = [fileDir filesep 'data' filesep 'rxnFiles']`; CI fixture `extractSubNetwork(readCbModel([CBTDIR filesep 'test' filesep 'models' filesep 'mat' filesep 'Recon3D_301.mat']), {'r0317';'ACONTm';'r0426'})`; every call with `options.directed = 0; options.sanityChecks = 1;`; no figures; minimal console output). Implement research R6 with assertions in exactly this order so a pre-change run fails only at the last block:
  1. **(d)** default-mode and dense-mode (`options.denseBondMatrices = 1`) calls on the CI fixture; for each mode recompute the atom residual and the bond residual exactly as described in T004 and `assert` both equal 0.
  2. **(e)** build `badModel` = CI sub-model with one stoichiometric coefficient doubled for a metabolite of `r0317` that has bond nodes (choose it programmatically: first `model.mets` entry with nonzero `S` in `r0317` that appears in `dBTM.Nodes.mets` of the consistent call); call it in default and dense mode, each wrapped by a local `runWithDiary` helper (diary to `tempname`, save/restore `get(0,'Diary')` and `get(0,'DiaryFile')` via `onCleanup`, return the text; no `evalc`, no warning suppression); `assert` each text contains `Inconsistent directed bond transition multigraph` and `Inconsistency between reaction stoichiometry and bond mapped reactions`; `assert(strcmp(defaultText, denseText))`.
  3. **(b)** dense mode: `M2BiE`, `M2BiW`, `BTi2R` each `~issparse` and `isa(x,'double')`.
  4. **(c)** the other nine outputs `isequaln` across modes, with the same `class` and `issparse` in both modes; the three matrices equal `size` and `isequaln(full(defaultX), denseX)`.
  5. **(a)** default mode: `M2BiE`, `M2BiW`, `BTi2R` each `issparse` and `isa(x,'double')`, with messages naming FR-003.
  6. **(f)** US1 AS4: with `options.bondTransitionMultigraph = 0`, call requesting only the first five outputs (the only ones assigned in that mode), once with `denseBondMatrices` absent and once with it set to 1; `assert` the two sets are `isequaln` with the same `class`/`issparse`.
  Each `assert` carries a message citing the FR-015 letter. Each exact-equality assertion (residual `== 0`, `isequaln`, `strcmp` of report text) carries a comment citing research R4 as the reason exact comparison is valid under Principle III (integer/dyadic arithmetic and discrete text, not approximations).
- [X] T007 Run `TEST` via `matlab -batch "initCobraToolbox(false); cd test/verifiedTests/analysis/testReactingMoieties; testBuildAtomAndBondTransitionMultigraph"` against the unmodified `SRC`. Expected: (d), (e), (b), (c) pass and the run fails at the first (a) assertion (proves the test detects the change and that the inconsistent fixture reaches the bond mismatch report). **STOP** if (e) does not produce the bond warning/report (pick a different metabolite per T006's rule and document why) or if anything other than (a) fails.

**Checkpoint**: snapshot captured from the original; CI test proven to detect the change. `SRC` may now be edited.

---

## Phase 3: User Story 1 - Every existing caller sees exactly the same results as before (Priority: P1) 🎯 MVP

**Goal**: The source change, made so that all twelve outputs keep their values, sizes and element class, every diagnostic is unchanged, and existing callers need no edits.

**Independent Test**: `testConservedReactingMoieties.m` passes unmodified; `HARNESS` compare mode passes SC-001 and SC-003 on every fixture in default mode.

### Implementation for User Story 1

- [X] T008 [US1] In `SRC`, after the `bondTransitionMultigraph` default block (lines 153-155), add, matching its style: `if ~isfield(options,'denseBondMatrices')` / `    options.denseBondMatrices=0;` / `end` (research R5).
- [X] T009 [US1] In `SRC`, replace the `M2BiE` loop (lines 883-886) and the `M2BiW` loop (lines 889-893) with the research R1 construction (`nModelMets`, `[isModelMetBond, bondMetRow] = ismember(dBTM.Nodes.mets, model.mets)`, `bondCols = find(isModelMetBond)`, the two `sparse(..., nModelMets, nBonds)` calls, `M2BiW` values `double(full(dBTM.Nodes.BondType(isModelMetBond)))`), keeping the existing `%matrix to map each metabolite...` and `%Matrix that specifies the type...` comments and the commented-out legacy lines 881-882; change line 898 to `BTi2R = sparse((1:nTransInstances)',transInstance2rxns,1,nTransInstances,nMappedRxns);` (drop only `full(`...`)`, research R2); immediately after the `BTi2R` line insert the research R3 block (`if options.denseBondMatrices` → `full` of all three → `end`) with a one-line comment citing `options.denseBondMatrices`. Make the construction code textually identical to `fillBondMatricesModified` in `HARNESS` (modulo T004's substitutions). Do not touch lines 900-976 or anything else.
- [X] T010 [US1] Run `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m` via `matlab -batch` and confirm it passes (SC-002); confirm `git diff develop -- test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m` is empty.
- [X] T011 [US1] Run `TEST` via `matlab -batch`; all of (a)-(f) MUST pass. **STOP** if (e) fails (research R4 fallback: report the differing lines; a fix needs a spec note, FR-009).
- [X] T012 [US1] Run `HARNESS` in compare mode via `matlab -batch`; confirm the appended section in `FD/reproducibility-results.md` shows SC-001 and SC-003 PASS for every fixture in both modes, modified-copy fidelity and source-match PASS, and provenance unchanged. **STOP** on any FAIL or `reproducibilityCheck:CorpusChanged`.
- [X] T013 [P] [US1] Static checks (SC-006, FR-008, FR-011): `git diff develop --stat -- src/ test/` lists only `SRC` and the new `TEST`; `git diff develop -- SRC | grep -E '^[-+].*(error|warning|fprintf)\('` is empty; every `SRC` hunk lies in the options block, the header, or lines 879-898 plus the inserted dense-conversion block.

**Checkpoint**: MVP — the function is sparse by default with values and diagnostics proven unchanged.

---

## Phase 4: User Story 2 - A full-size model can be built without exhausting memory on the three bond matrices (Priority: P2)

**Goal**: Evidence that the three matrices are stored sparsely at ≤ 10% of dense and that the fill step is not slower.

**Independent Test**: `FD/reproducibility-results.md` reports tyrosine storage (sparse vs dense bytes, ratio ≤ 0.10) and fill-step medians (after ≤ before); energy-node columns and bond-less rows are empty.

- [X] T014 [US2] From the T012 section of `FD/reproducibility-results.md`, confirm SC-004 (tyrosine combined sparse bytes ≤ 10% of dense; figures for every fixture reported), SC-005 (after median ≤ before median, both reported), and the energy-node-column / bond-less-row edge checks PASS for every fixture. **STOP** and report both medians if SC-005 fails (spec requires a strict comparison; do not add a tolerance).

**Checkpoint**: US2 acceptance scenarios 1-4 evidenced.

---

## Phase 5: User Story 3 - A legacy caller can opt back into the exact dense output (Priority: P2)

**Goal**: `options.denseBondMatrices = 1` reproduces the historical output exactly, and the option and storage-class change are documented.

**Independent Test**: `HARNESS` dense mode — all twelve outputs `isequaln` to the snapshot, three matrices full `double`; `TEST` (b)/(c) pass; header inspection.

- [X] T015 [US3] In `SRC` header `OPTIONAL INPUT` list (after line 76), add `%                     * .denseBondMatrices - boolean; if 1, M2BiE, M2BiW and BTi2R are returned as full matrices, as before (default = 0, sparse)`; append to the `M2BiE`, `M2BiW` and `BTi2R` output descriptions (lines 139-141) the note `(sparse by default; set options.denseBondMatrices = 1 for the historical full matrix)` (research R5, FR-004, SC-007). Do not edit the `USAGE` line or any other header text.
- [X] T016 [US3] Confirm from the T012 section of `FD/reproducibility-results.md` that dense mode passes SC-001 for every fixture with `M2BiE`/`M2BiW`/`BTi2R` `issparse == false` and class `double`, and that `TEST` (b)/(c) passed in T011.

**Checkpoint**: all three user stories independently evidenced.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T017 Re-run, after T015's header edit, `TEST`, `testConservedReactingMoieties.m` and `HARNESS` compare mode via `matlab -batch`; all MUST pass (a second `## Run` section is appended to `FD/reproducibility-results.md`). Re-run T013's static checks.
- [ ] T018 [P] (Optional, FR-014/SC-008 — not a gate) Only if the user asks: run a full-VMH-size call with default options and record outcome, peak memory and wall-clock under `## Full-VMH demonstration` in `FD/reproducibility-results.md`, including any failure caused by the out-of-scope consumers listed in spec Assumptions.
- [X] T019 Write the implementation receipt `FD/agent-runs/<UTC-timestamp>-sparse-bond-matrices/implementation-receipt.md` with exactly the sections Prompt, Final response (verbatim final user-facing response), Diff summary (every file changed: `SRC`, `TEST`, `HARNESS`, `FD/golden-snapshot.mat`, `FD/reproducibility-results.md`, `FD/tasks.md` checkboxes), Tests (commands run and pass/fail), Unresolved issues (including behaviours not verified, e.g. reconXmoieties fixtures, full-VMH run if skipped). Mark T001-T017 `[X]` in this file as completed.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (T001-T002)**: none; T002 parallel with T001.
- **Foundational (T003-T007)**: after Setup. T003 (read research R9) first; then T004 ∥ T006 (different files). T005 needs T004; T007 needs T006. **Both T005 and T007 must finish before any `SRC` edit.**
- **US1 (T008-T013)**: after Foundational. T008 → T009 (same file) → T010, T011, T012 (independent runs; can go in any order) ; T013 after T009.
- **US2 (T014)**: after T012.
- **US3 (T015-T016)**: T015 after T009 (same file, sequential edits); T016 after T012.
- **Polish (T017-T019)**: T017 after T015; T019 last.

### User Story Dependencies

- US1 carries the only code change; US2 and US3 depend on it for evidence (T012) and US3 adds header docs. US2 and US3 do not depend on each other.

### Parallel Opportunities

- T001 ∥ T002; T004 ∥ T006; T010 ∥ T011 ∥ T012 (separate MATLAB sessions) ∥ T013; T014 ∥ T016.

## Parallel Example: Foundational

```text
Task: "T004 Write HARNESS specs/20260921-125236-sparse-bond-matrices/reproducibilityCheck.m"
Task: "T006 Write TEST test/verifiedTests/analysis/testReactingMoieties/testBuildAtomAndBondTransitionMultigraph.m"
```

## Parallel Example: User Story 1 verification

```text
Task: "T010 Run testConservedReactingMoieties.m"
Task: "T011 Run testBuildAtomAndBondTransitionMultigraph.m"
Task: "T012 Run reproducibilityCheck.m compare mode"
Task: "T013 Static git diff checks"
```

## Implementation Strategy

### MVP First (User Story 1)

1. Phase 1 → Phase 2 (snapshot and failing-at-(a) CI test, source untouched).
2. Phase 3: edit `SRC`, prove non-regression. **Stop and validate** — this alone delivers the memory fix with proven-unchanged values.

### Incremental Delivery

3. Phase 4: confirm storage/timing evidence (no code).
4. Phase 5: header documentation + dense-mode evidence.
5. Phase 6: final re-run, optional full-VMH demo, receipt.

## Notes

- Gate (Principle VI): no task here may run until `/speckit-implement` (or the agent-assign pipeline) is invoked.
- `binary` (submodule) and `.specify/feature.json` show pre-existing working-tree changes; do not touch or commit `binary`.
- Commit only when the user asks.
