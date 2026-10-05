---

description: "Task list for feature 20260921-160105-build-function-runtime"
---

# Tasks: Cut the redundant RXN-file work and the per-bond element loop in buildAtomAndBondTransitionMultigraph, without changing its outputs

**Input**: Design documents from `/specs/20260921-160105-build-function-runtime/`

**Prerequisites**: plan.md, spec.md, research.md (R1-R10), data-model.md (E1-E6), contracts/public-contract.md, quickstart.md

**Tests**: Required by the spec — two new CI tests (FR-013), the two existing tests
unmodified (FR-010), and a non-CI golden-snapshot reproducibility check (FR-011/FR-012).
Every baseline capture and both new tests are written and run **before** any `src/` edit.

**Organization and phase order**: the phases run Setup → Foundational → **US3 → US1 → US2** → Polish.
US3 (CI tests, P2) comes before US1 (P1) because the constitution requires tests to exist
before the behaviour they verify, and US1's source edits are what those tests check. The
three source edits sit in US1, the P1 non-regression gate (the MVP), because US1 is the
acceptance test for every edit; US2 then measures the speed, call-count and memory
properties the same edits are for.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)

## Conventions used by every task

- `ADD` = `src/analysis/topology/reactingMoieties/addBondMappingsRXNFile.m`
- `CHK` = `src/analysis/topology/reactingMoieties/checkABRXNFiles.m`
- `BUILD` = `src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m`
- `TD` = `test/verifiedTests/analysis/testReactingMoieties/`
- `FD` = `specs/20260921-160105-build-function-runtime/`
- `HARNESS` = `FD/buildRuntimeReproducibilityCheck.m`
- `BASE` = commit `64efe1dc8` (`develop`; `ADD`, `CHK`, `BUILD` are identical to it at branch start).
  Line numbers below refer to `BASE`.
- Run MATLAB headless from the repo root:
  `matlab -batch "initCobraToolbox(false); <commands>"`. Never suppress warnings; read every
  warning printed and act on it (Principle VII-B). No `evalc`; capture console text with
  `diary` to a `tempname` file.
- Every `try/catch ME` added in `HARNESS` or the tests records `ME.message`, `ME.identifier`
  and `ME.stack(1).file`/`.line` (VII-C). No `try/catch` is added to `src/`.
- Stop and report to the user (do not improvise) on any gate marked **STOP**.
- Console comparison rule (research R5), used by T008 and T024: split each text into lines;
  drop stack-frame lines (lines matching `^\s*>?\s*In \S+ \(line \d+\)`, `^Error in \S+ \(line \d+\)`,
  and the one indented source-echo line that `getReport` prints after each `Error in` line)
  and keep them in a separate list; classify the remaining lines as `readABRXNFile` lines if
  they match one of the templates from `readABRXNFile.m` lines 73, 115, 169, 212, 219, 222,
  226, 237 (turn each format string into a regex, `%s`/`%u` → `.*`, with and without a
  leading `Warning: `). PASS iff (a) the non-`readABRXNFile` lines are identical as sequences,
  and (b) each distinct `readABRXNFile` line appears in both texts with
  `1 <= countModified <= countOriginal`. Differing stack-frame lines are reported, not failed.

---

## Phase 1: Setup

**Purpose**: confirm the starting state and the environment.

- [X] T001 Verify preconditions and record them at the top of a new `FD/reproducibility-results.md`: `git diff --quiet 64efe1dc8 -- ADD CHK BUILD` succeeds; `git diff --quiet 64efe1dc8 -- TD/testConservedReactingMoieties.m TD/testBuildAtomAndBondTransitionMultigraph.m` succeeds; `~/repos/ReconXKG-cidev/ReconXKGtoCobra/models/subsystemSubModels/subsystemSubModels.mat` and `/media/JACK/repos/ctf/rxns/atomMapped_std` exist; `test/models/mat/Recon3D_301.mat` exists; MATLAB reports R2024b. **STOP** if any fails.
- [X] T002 Record in `FD/reproducibility-results.md` the console comparison rule above (research R5) as the rule in force, citing spec FR-009/FR-011 and Clarifications (Session 2026-09-22) as its authority.

---

## Phase 2: Foundational (baseline capture — BEFORE any `src/` edit)

**Purpose**: the golden snapshots and CI expected values, captured from the unmodified functions, and a harness that can compare against them.

**⚠️ CRITICAL**: no `src/` file may be edited until T010 has passed.

- [X] T003 Create `HARNESS` as `function buildRuntimeReproducibilityCheck(mode, fixtureNames)` with an openCOBRA header (VII-E). `mode` is `'capture'`, `'captureCI'`, `'compare'` or `'peakmem'`; `fixtureNames` defaults to `{'nglycan','phe','andest','chol','urea','tyr','bileacid','ci','ci_missing','ci_unparsable'}` (`'pufa'` only when named). Implement local helpers: (a) `makeBaselineDir()` — `git show 64efe1dc8:<path> > <tempname>/<file>` for `ADD`, `CHK`, `BUILD` via `system`, check each exit status, return the directory and an `onCleanup` that removes it; (b) `useBaseline(flag, baselineDir)` — `addpath(baselineDir, '-begin')` or `rmpath(baselineDir)`, then `clear functions; rehash;` and assert `which('addBondMappingsRXNFile')` resolves to the expected file; (c) `appendResults(text)` appending to `FD/reproducibility-results.md`; (d) in `'capture'`/`'captureCI'` modes, refuse (error) unless `git diff --quiet 64efe1dc8 -- ADD CHK BUILD` succeeds.
- [X] T004 In `HARNESS`, add `loadFixture(name)`: for the seven subsystem names load `subModels.<name>` from `subsystemSubModels.mat` with `RXNFileDir = '/media/JACK/repos/ctf/rxns/atomMapped_std'`; for `'ci'` use `readCbModel([CBTDIR filesep 'test' filesep 'models' filesep 'mat' filesep 'Recon3D_301.mat'])`, `extractSubNetwork(model, {'r0317'; 'ACONTm'; 'r0426'})` and `RXNFileDir = TD/data/rxnFiles`; for `'ci_missing'` and `'ci_unparsable'` use the CI submodel with `RXNFileDir = makeDerivedRxnDir('missing' | 'unparsable', subModel, TD/data/rxnFiles)`. Define the local function `makeDerivedRxnDir(kind, subModel, rxnFilesDir)` here: copy every `*.rxn` from `rxnFilesDir` into a `tempname` directory (removed by an `onCleanup` held by the caller); let `lastMapped` be the last `subModel.rxns` entry whose `.rxn` file exists; `'missing'` deletes `<lastMapped>.rxn`; `'unparsable'` overwrites it with its own first 4 lines (header only); `'firstBroken'` does the same to the first such entry; return the directory and the altered reaction's name. T009 and T012 reuse this function (T012 copies its body verbatim). For derived fixtures, `provenance` records the derived kind and the altered file's name in place of corpus counts. Add `provenance(name, model, RXNFileDir)` returning the E4 `provenance` fields (corpus path, top-level `.rxn` count, sorted `flagged_for_review/` names when that folder exists, submodel file and `datenum`, `nRxns`, `nMets`, `version`, `git rev-parse HEAD`, baseline `64efe1dc8`).
- [X] T005 In `HARNESS`, add `captureOutputs(model, RXNFileDir)` returning the E4 fields `outDefault`, `outDense` (`1 x 12` cells from `buildAtomAndBondTransitionMultigraph` with `options.sanityChecks = 1`, and additionally `options.denseBondMatrices = 1`), `classInfo` (`class`, `issparse` per output), `checkOut` (the ten quality fields of `modelOut` plus both counts from `checkABRXNFiles(model, RXNFileDir)`), `bondMappingsByRxn` (`rxnIds` and `tables`: `addBondMappingsRXNFile(rxn, RXNFileDir)` for every `model.rxns` entry whose `.rxn` file exists; on error store `ME.identifier`/`ME.message` in place of the table), and `consoleText` (one default-mode call run under `diary` to a `tempname` file, read back with `fileread`), and `decompBranch`: `'match'`, `'rxnFileCompartmented'` or `'modelCompartmented'`, from comparing the last character of the first `readABRXNFile` atom's `mets` (first `model.rxns` entry with an RXN file) with the last character of `model.mets{1}`, the same test as `CHK` lines 122-131.
- [X] T006 In `HARNESS`, add `captureCounts(model, RXNFileDir)`: `profile clear; profile on;` one default-mode call; `p = profile('info'); profile off;`. Return `readABRXNFile` `NumCalls` (sum over `FunctionTable` entries whose `FunctionName` is `readABRXNFile`); `energyConstructions` = sum over the `addBondMappingsRXNFile` entry's `ExecutedLines` rows whose line number is one of the lines matching `^\s*energy\s*=\s*table\(` in the file `which('addBondMappingsRXNFile')` currently resolves to; `energyRows` = sum over `bondMappingsByRxn` of `nnz(strcmp(table.mets, rxnId))`.
- [X] T007 In `HARNESS`, add `timeRuns(model, RXNFileDir, baselineDir, nRuns)`: one untimed warm-up per version, then `nRuns = 5` pairs alternating original (`useBaseline(true)`) and modified (`useBaseline(false)`), each timed with `tic`/`toc` around one default-mode call; return both run vectors, medians, ratio, and noise `(max - min)/2` of the original's runs. Add mode `'peakmem'` (`fixtureNames` = one fixture, plus a second argument `'original'`/`'modified'`) that, for `'original'`, first creates the baseline directory and calls `useBaseline(true)`, then runs one default-mode call and prints `VmHWM` parsed from `/proc/self/status`, and `peakMemory(name, version)` that launches it with `system('matlab -batch "initCobraToolbox(false); cd <FD>; buildRuntimeReproducibilityCheck(''peakmem'', {''<name>''}, ''<version>'')"')` and parses the printed kB value (add the optional third input `version` to the signature, handled with `exist`/`isempty`).
- [X] T008 In `HARNESS`, implement mode `'capture'` (per fixture: provenance, `captureOutputs`, `captureCounts`, 5 original runs timed, `peakMemory(name,'original')`; save `FD/snapshots/<name>-golden-snapshot.mat` with `-v7`; append a capture section) and mode `'compare'` (per fixture: load the snapshot; if `provenance` differs in corpus count, flagged list or submodel `datenum`, report "corpus changed since capture" and skip equality for that fixture; otherwise run `captureOutputs` on the current source and compare every output with `isequaln` (bond matrices 9-11 by value, `classInfo` separately), `checkOut`, every `bondMappingsByRxn` table, and `consoleText` under the console rule above; then `timeRuns` (repeat once on a shortfall), `captureCounts` on both versions, `peakMemory` on both; append PASS/FAIL per item with medians, ratio, noise, counts, `VmHWM` and the list of differing stack-frame lines).
- [X] T009 In `HARNESS`, implement mode `'captureCI'`, writing `TD/data/addBondMappingsRXNFileExpected.mat` (`rxnIds`, `bondMappings` for all 18 files in `TD/data/rxnFiles`, each from `addBondMappingsRXNFile(rxnId, TD/data/rxnFiles)`) and `TD/data/checkABRXNFilesExpected.mat` (for `base`, `missing`, `unparsable`: the ten quality-field vectors and both counts of `checkABRXNFiles`). Derived fixtures come from `makeDerivedRxnDir` (defined in T004). At capture, assert that `readABRXNFile` throws on the `'unparsable'` file and that `checkABRXNFiles` throws on `'firstBroken'` (**STOP** if either does not).
- [X] T010 Run `buildRuntimeReproducibilityCheck('capture')` and `buildRuntimeReproducibilityCheck('captureCI')` against the unmodified source, then `buildRuntimeReproducibilityCheck('compare')` as a harness self-check (still unmodified). Gates: all snapshot files and both expected-value files exist; bileacid `readABRXNFile` calls = 718 and `energyConstructions` = the number of loop iterations, i.e. the sum over all `addBondMappingsRXNFile` calls of (rows − energy rows) of the returned table (one construction per iterated row; the profiled count was 96,691); tyr's bond residual (3) and its report are recorded; the self-check compare is PASS on every equality and console item; `du -sh FD/snapshots` ≤ 10 MB; the `decompBranch` of each fixture is recorded. Optionally, if `pufa` is to be timed (FR-014), also run `buildRuntimeReproducibilityCheck('capture', {'pufa'})` now, while the source is unmodified. **STOP** on any failure, or ask the user before committing snapshots above 10 MB.

**Checkpoint**: baseline captured; `src/` edits may begin only after Phase 3's tests exist.

---

## Phase 3: User Story 3 — The changed helpers are covered by CI (Priority: P2)

**Goal**: automated tests that fail if `addBondMappingsRXNFile` or `checkABRXNFiles` drift, including the new pre-parsed call form.

**Independent Test**: run `testAddBondMappingsRXNFile` and `testCheckABRXNFiles` in `TD` with no external data; after Phase 4 both pass.

- [X] T011 [P] [US3] Create `TD/testAddBondMappingsRXNFile.m` following `documentation/source/guides/testTemplate.m` and the header style of `TD/testBuildAtomAndBondTransitionMultigraph.m`: `prepareTest();`; `cd` to the test folder and restore on exit; load `TD/data/addBondMappingsRXNFileExpected.mat`; for every `rxnIds{k}`: `bm2 = addBondMappingsRXNFile(rxnIds{k}, rxnFilesDir)`; `[atoms, bonds] = readABRXNFile(rxnIds{k}, rxnFilesDir)`; `bm4 = addBondMappingsRXNFile(rxnIds{k}, rxnFilesDir, atoms, bonds)`; `assert(isequaln(bm2, expected{k}))`, `assert(isequaln(bm4, expected{k}))`, and `assert(isequal(bm4.Properties.VariableNames, expected{k}.Properties.VariableNames))`. Also: `addBondMappingsRXNFile(id, dir, [], [])` equals `bm2` (empty falls back to parsing); `verifyCobraFunctionError('addBondMappingsRXNFile', 'inputs', {'noSuchReaction', rxnFilesDir})` for a missing file. No `evalc`, no warning suppression.
- [X] T012 [P] [US3] Create `TD/testCheckABRXNFiles.m`: `prepareTest();`; build the CI submodel exactly as T004 does; load `TD/data/checkABRXNFilesExpected.mat`; for `base` (the shipped directory) and for `missing` and `unparsable` (from `makeDerivedRxnDir`, copied verbatim from `HARNESS`, directory removed via `onCleanup`), call `checkABRXNFiles` and `assert(isequaln(...))` each of the ten quality fields and both counts against the stored values; assert `unparsable`'s `RXNParsedBool` entry for `lastMapped` is 0 and `missing`'s `RXNBool` entry is false; `verifyCobraFunctionError('checkABRXNFiles', 'inputs', {subModel, firstBrokenDir})` for `'firstBroken'`.
- [X] T013 [US3] Run both new tests against the unmodified source and record the outcome in `FD/reproducibility-results.md`. Expected: `testCheckABRXNFiles` passes; `testAddBondMappingsRXNFile` fails only at the first four-input call with "Too many input arguments" (proves it exercises the new form). **STOP** on any other failure.

**Checkpoint**: tests exist and pin the unmodified behaviour; source edits may begin.

---

## Phase 4: User Story 1 — Every existing caller sees exactly the same results (Priority: P1) 🎯 MVP

**Goal**: the three edits, each verified to leave every output, check, warning and error unchanged (except FR-009's fewer `readABRXNFile` repeats).

**Independent Test**: the four CI tests pass, and `buildRuntimeReproducibilityCheck('compare')` reports PASS for every equality and console item on every fixture.

- [X] T014 [US1] In `ADD`: change the signature (line 1) to `function [bondMappings] = addBondMappingsRXNFile(rxnfileName, rxnfileDirectory, atoms, bonds)`; add the second form to `USAGE:`; under `OPTIONAL INPUT:` (lines 10-12) document `atoms:` and `bonds:` as the tables `readABRXNFile(rxnfileName, rxnfileDirectory)` returns, used instead of reading the file when both are given and non-empty; add a `NOTE:` that tables from a different file or from `readBonds = 0` are outside the contract and not checked; append an `Author:` line for this feature. Replace the read at line 62 with `if ~exist('atoms', 'var') || isempty(atoms) || ~exist('bonds', 'var') || isempty(bonds)` … `[atoms,bonds] = readABRXNFile(rxnfileName,rxnfileDirectory);` … `end` (research R2). Leave lines 47-60 unchanged.
- [X] T015 [US1] In `ADD` loop (lines 150-184): delete the `energy=table(...)` statement at line 163 from the top of the loop body and insert that identical statement (same arguments, same `'variableNames',bondMappings.Properties.VariableNames`) as the first statement inside the `isReacting(i)<0` branch (line 164) and inside the `isReacting(i)>0` branch (line 173); keep the historical commented-out template (lines 158-162) above the first branch. Nothing else in the loop changes (research R3).
- [X] T016 [US1] Run `testAddBondMappingsRXNFile` and `testCheckABRXNFiles`; both must pass. **STOP** on failure.
- [X] T017 [US1] In `CHK`: immediately inside `if RXNBool(i)` (line 93) add `rxnParsedInBlock1 = false;`. In block 1, after the successful `readABRXNFile` at line 102, set `rxnParsedInBlock1 = true;` inside the `try`, and change line 118 to `[bondMappings] = addBondMappingsRXNFile(model.rxns{i},RXNFileDir,atoms,bonds);`. In block 2, wrap line 154 as `if ~rxnParsedInBlock1` … `[atoms,bonds] = readABRXNFile(rxn,RXNFileDir);` … `end` and change line 163 to `[bondMappings] = addBondMappingsRXNFile(rxn,RXNFileDir,atoms,bonds);`. Do not move or alter any other statement, `fprintf`, `try`, `catch` or `rethrow`; add a short comment citing FR-005/FR-006 (one reaction's parse, reused within the same iteration only). Append an `Author:` line.
- [X] T018 [US1] Run `testCheckABRXNFiles` and `testAddBondMappingsRXNFile`; both must pass. **STOP** on failure.
- [X] T019 [US1] In `BUILD` line 637 change the call to `[bondMappings] = addBondMappingsRXNFile(model.rxns{i},RXNFileDir,atoms,bonds);` (line 636 unchanged, research R1).
- [X] T020 [US1] In `BUILD` replace the loop at lines 808-813 (comment `%Add bond Elements` kept) with: `if height(dBTM.Nodes) > 0`; `bondElementList = dATME.Nodes.Element;`; `bondHeadElmts = bondElementList(full(dBTM.Nodes.BondHeadAtomIndex(:)));`; `bondTailElmts = bondElementList(full(dBTM.Nodes.BondTailAtomIndex(:)));`; `dBTM.Nodes.BondElmts = cellfun(@(a, b) [a '-' b], bondHeadElmts, bondTailElmts, 'UniformOutput', false);`; `end`, with a comment that the string is head-index element then tail-index element as before and that the empty case must not touch `dATME` (research R4). Append an `Author:` line to `BUILD`'s header.
- [X] T021 [US1] Run `TD/testConservedReactingMoieties.m`, `TD/testBuildAtomAndBondTransitionMultigraph.m`, `TD/testCheckABRXNFiles.m`, `TD/testAddBondMappingsRXNFile.m`; all must pass. Confirm `git diff --quiet 64efe1dc8 -- TD/testConservedReactingMoieties.m TD/testBuildAtomAndBondTransitionMultigraph.m` (SC-002). **STOP** on failure.
- [X] T022 [US1] Add a one-off check to `HARNESS` mode `'compare'` (and run it on the CI fixture): with `dBTM` from a default-mode call, set one `BondHeadAtomIndex` to `NaN` in a copy of the node table and confirm the vectorised expression from T020 errors, as the loop did (FR-004 edge case); record the result.
- [X] T023 [US1] Run `buildRuntimeReproducibilityCheck('compare')` on all eight fixtures. Gates: every output (default and dense), `classInfo`, `checkOut` and `bondMappings` item PASS (SC-001); console rule PASS (SC-006); tyr's bond residual 3 and its printed report unchanged. For `ci_missing` and `ci_unparsable`, the outputs, `checkOut` and console items PASS, and the console text still contains each pass's own failure line (`could not be parsed.`, `.rxn could not be parsed for atom mappings and was skipped.`, `.rxn could not be parsed for bond mappings and was skipped.`) exactly as many times as in the snapshot (spec Edge Case "Unparsable or missing RXN files"). On any FAIL, **STOP**, then bisect by reverting T015, T017/T019 or T020 individually (each is self-contained) and report which edit causes it.
- [X] T024 [US1] Static review (FR-008, SC-007): run `git diff 64efe1dc8 -- src | grep -nE '^[-+].*(warning|error|fprintf|disp|rethrow)\('` and confirm every hit is unchanged text (moved or re-indented only); confirm no `warning('off'`, `evalc` or `lastwarn` was added. Confirm that the `BondElmts` expression in `BUILD` is character-for-character the same as the expression T022 exercises in `HARNESS`. Record the results.

**Checkpoint**: MVP — behaviour proved unchanged on all fixtures.

---

## Phase 5: User Story 2 — Building the graphs takes less time on larger models (Priority: P2)

**Goal**: show the edits deliver the intended reductions without a memory cost.

**Independent Test**: the timing, count and memory sections of the compare run.

- [X] T025 [US2] From the T023 compare run (re-run `buildRuntimeReproducibilityCheck('compare', {<fixture>})` for any fixture that needs its timing repeated), record per fixture: both medians, ratio, noise, PASS if modified median ≤ original median + noise after at most one repeat (SC-004), and the profile reference (bileacid ~58 of 140 profiled s) for comparison only. **STOP** and report on a repeated shortfall.
- [X] T026 [US2] Record per fixture `readABRXNFile` calls and `energyConstructions` before and after. Gates on bileacid: calls ≤ 431 (expected 430 = 3r + 1), and after-`energyConstructions` = `energyRows` (SC-005). Check that every fixture's after-count equals `3r + 1` for its `r` mapped reactions; explain any difference.
- [X] T027 [US2] Record per fixture `VmHWM` for both versions; gate modified ≤ original + max(0.05 × original, 50 MB) (spec Edge Cases, research R6). Confirm by `git diff 64efe1dc8 -- src | grep -nE 'containers\.Map|persistent|global'` that no parse cache was added (FR-006).

**Checkpoint**: performance evidence recorded.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T028 [P] Check the edited headers of `ADD`, `CHK`, `BUILD` against `documentation/source/guides/documentationGuide.rst` (one space after `%`, four-space argument indent, blank line around keywords) and that no header claims more than FR-009 allows.
- [X] T029 [P] Optional (FR-014, SC-008): if a `pufa` snapshot was captured in T010, run `buildRuntimeReproducibilityCheck('compare', {'pufa'})` and record the outcome and times. This is not a gate. If no snapshot exists, record "not run".
- [X] T030 Run every test in `TD` (`dir(fullfile(TD, 'test*.m'))`, each in turn) and record pass/fail.
- [X] T031 Scope check (SC-007): `git diff --stat 64efe1dc8` lists only `ADD`, `CHK`, `BUILD`, `TD/testAddBondMappingsRXNFile.m`, `TD/testCheckABRXNFiles.m`, `TD/data/addBondMappingsRXNFileExpected.mat`, `TD/data/checkABRXNFilesExpected.mat`, `FD/*`, `CLAUDE.md` and `.specify/feature.json`; `readABRXNFile.m`, `identifyAtomEquivalenceClasses.m` and the untracked `.asv` are untouched.
- [X] T032 Append a summary to `FD/reproducibility-results.md`: per-requirement PASS/FAIL (FR-001 to FR-013, SC-001 to SC-007), the stack-frame differences observed, which `decompBranch` values the fixtures reached (any branch never reached is recorded as "not verified (no fixture reaches it)"), and behaviours not verified.
- [X] T033 Create the implementation receipt at `FD/agent-runs/<UTC-timestamp>-build-function-runtime/implementation-receipt.md` with exactly the sections Prompt, Final response (the verbatim final user-facing response), Diff summary, Tests, Unresolved issues (and optionally Other information).

---

## Dependencies & Execution Order

### Phase Dependencies

- Setup (T001-T002) → Foundational (T003-T010) → US3 (T011-T013) → US1 (T014-T024) → US2 (T025-T027) → Polish (T028-T033).
- T003-T009 edit the same file (`HARNESS`) and run in order; T010 needs all of them.
- No `src/` edit before T010 and T013 have passed.

### User Story Dependencies

- **US3** depends only on Foundational (expected values from T009).
- **US1** depends on US3 (its tests gate T016, T018, T021).
- **US2** depends on US1 (it measures US1's edits; its data come from the T023 compare run).

### Within User Story 1

- T014 → T015 → T016 (same file `ADD`, then test).
- T017 needs T014 (the four-input form); T019 needs T014; T020 is independent of T014-T019 in code but runs after T019 in the same file `BUILD`.
- T021 → T022 → T023 → T024.

### Parallel Opportunities

- T011 and T012 (different new test files).
- T028 and T029 (different files, no shared state).
- Within the harness runs, fixtures are independent but share one MATLAB session for alternating timing; do not run timing for two fixtures at once (it biases timing).

---

## Parallel Example: User Story 3

```text
Task: "T011 [US3] Create TD/testAddBondMappingsRXNFile.m"
Task: "T012 [US3] Create TD/testCheckABRXNFiles.m"
```

---

## Implementation Strategy

### MVP First (User Story 1)

1. Phases 1-2: capture everything from the unmodified source.
2. Phase 3: the two CI tests, run against the unmodified source.
3. Phase 4: the three edits one at a time, each followed by the tests; then the full compare.
4. **Stop and validate**: SC-001, SC-002, SC-006 all PASS — the feature is safe to merge even
   before the timing evidence.

### Incremental Delivery

- Each edit (T015 energy, T017+T019 parses, T020 `BondElmts`) is separately revertible and
  separately valuable; if one fails T023 and cannot be fixed within spec, it can be dropped
  and the other two delivered.
- Phase 5 adds the evidence the speed-up is real; Phase 6 closes out.

## Notes

- Never edit `readABRXNFile.m`, the atom loop or probe in `BUILD` (lines 187-360), the two existing tests, or any file outside the list in T031.
- `dATME` in T020 is whatever the bond loop last assigned; do not rebuild it.
- The console rule's treatment of stack-frame lines (T002) is set by spec FR-009/FR-011 (Clarifications, Session 2026-09-22).
