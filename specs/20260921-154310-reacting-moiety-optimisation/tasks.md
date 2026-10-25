---
description: "Task list for the reacting-moiety optimisation of identifyConservedReactingMoieties"
---

# Tasks: Speed up identifyConservedReactingMoieties' bond-subgraph, reacting-bond-graph and CRB2R stages, without changing its results

**Input**: Design documents from `specs/20260921-154310-reacting-moiety-optimisation/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/function-interface.md](contracts/function-interface.md), [quickstart.md](quickstart.md)

**Tests**: This is a behaviour-preserving numerical refactor, so tests are required (Constitution III; spec FR-011 and FR-013). The evidence comes in three layers: (1) golden snapshots from **unmodified** `develop` compared with `isequaln`; (2) `testConservedReactingMoieties.m` passing unmodified; (3) two new CI tests whose references were captured before the change.

**Organization**: tasks are grouped by user story. **Execution order differs from priority order on purpose**. Phase 2 must capture every reference from unmodified code before `src/` is touched. Phase 3 (US3, the CI tests) comes before Phase 4 (US1, the rewrites), because Constitution "Development Workflow" requires tests to be written before or with the behaviour they verify. US1 is still the P1 acceptance gate and the MVP.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: can run in parallel (different files, no dependency on an unfinished task)
- **[Story]**: US1 = identical results (P1), US2 = faster (P2), US3 = CI coverage (P2)

## Conventions used by every task

- `FD` = `specs/20260921-154310-reacting-moiety-optimisation`
- `SRC` = `src/analysis/topology/reactingMoieties`
- `TST` = `test/verifiedTests/analysis/testReactingMoieties`
- `ICRM` = `SRC/identifyConservedReactingMoieties.m`. Line numbers refer to `develop` @ `64efe1dc8` and are only a guide. Locate every block by the text quoted in the task.
- Headless MATLAB: `/usr/local/MATLAB/R2024b/bin/matlab -batch "initCobraToolbox(false); changeCobraSolver('gurobi','all',0); <command>"`, run from the repository root. Record the MILP solver in use: capture and compare **must** use the same one.
- Every MATLAB file written must follow Constitution VII:
  - no `evalc` (capture console output with `diary`);
  - no suppressed warnings;
  - every `catch ME` records `ME.identifier`, `ME.message` and `ME.stack(1).file`/`.line`;
  - new optional inputs use `exist(...,'var') || isempty(...)`, not `nargin`;
  - openCOBRA style: camelCase, spaces around operators, `filesep`/`fullfile`, no absolute paths inside `src/` or `test/` functions.
- **FORBIDDEN in this feature** (FR-009, FR-010):
  - changing or removing any existing `error`, `warning`, `fprintf` or sanity check;
  - adding an option to choose old or new code;
  - adding any `*Fast.m` file;
  - editing `TST/testConservedReactingMoieties.m`, `createBIGraph.m`, `buildAtomAndBondTransitionMultigraph.m`, `identifyIsomorphicClasses.m` or `classifySubgraphIsomorphism.m`;
  - editing any part of `ICRM` outside the four blocks named in T018–T021;
  - overwriting a golden snapshot.

---

## Phase 1: Setup (verification tooling, no source changes)

**Purpose**: write the capture helper, the capture script and the reproducibility check. None of them edits `src/`.

- [X] T001 Confirm the baseline, and record the results in a new "Baseline" section at the top of `FD/reacting-optimisation-reproducibility-results.md` (create the file with a heading and that section). Check each of the following:
  - `git diff --quiet develop -- src/ test/` exits 0;
  - `git rev-parse HEAD` shows the commit;
  - the corpus `/media/JACK/repos/ctf/rxns/atomMapped_std` and `~/repos/ReconXKG-cidev/ReconXKGtoCobra/models/subsystemSubModels/subsystemSubModels.mat` both exist;
  - `test/models/mat/Recon3D_301.mat` exists;
  - `changeCobraSolver('gurobi','MILP',0)` returns true (if it does not, stop and ask the user which solver to use for capture and compare);
  - MATLAB version is `version`.
- [X] T002 [P] Create `FD/captureStageNineInputs.m`, a helper function used as a conditional-breakpoint condition (research R8).
  - Signature: `function tf = captureStageNineInputs(BIG, ATG)`.
  - It saves `BIG` and `ATG` with `save(captureFile, 'BIG', 'ATG')` to the path in environment variable `CBT_RMO_CAPTURE_FILE`. If that variable is empty, it raises `error('captureStageNineInputs:noCaptureFile', ...)`.
  - It returns `false`, so execution never stops.
  - Give it an openCOBRA help header (`USAGE:`, `INPUTS:`, `OUTPUT:`, `NOTE:` saying that it is used only by `captureBondSubgraphReferences.m`).
- [X] T003 [P] Create `FD/captureBondSubgraphReferences.m`, a script, per research R8 and data-model "Unit-test reference". Steps:
  1. Refuse to run (`error`) unless `git diff --quiet develop -- src/` is clean. Run the check with `system`, from the repository root found via `fileparts(mfilename('fullpath'))`.
  2. Build the CI fixture exactly as `TST/testConservedReactingMoieties.m` does:
     - `readCbModel(fullfile(CBTDIR,'test','models','mat','Recon3D_301.mat'))`;
     - `extractSubNetwork(model, {'r0317';'ACONTm';'r0426'})`;
     - `buildAtomAndBondTransitionMultigraph(subModel, fullfile(TST,'data','rxnFiles'), options)` with `options.directed = 0; options.sanityChecks = 1`.
  3. Find the call line in `ICRM`. Read the file with `fileread`, split it into lines, and take the single line whose `strtrim` equals `[bondSubgraphs, BMG] = extractBondSubgraphs(BIG, ATG);`. Assert there is exactly one.
  4. Capture the inputs:
     - `setenv('CBT_RMO_CAPTURE_FILE', <tempname>.mat)`;
     - `dbstop('in','identifyConservedReactingMoieties','at',num2str(line),'if','captureStageNineInputs(BIG, ATG)')`;
     - call `identifyConservedReactingMoieties(subModel, BG, dATM, struct('directed',0,'sanityChecks',0,'conservedMoietiesOnly',true))`. Stage 09 runs in this mode, and it needs no MILP;
     - `dbclear all`, in an `onCleanup` so it also runs on error;
     - load `BIG` and `ATG`.
  5. Record the reference outputs:
     - `ciExpected.bondSubgraphs`, `ciExpected.BMG`: output of `[bondSubgraphs, BMG] = extractBondSubgraphs(BIG, ATG)`;
     - the six `ciExpected.*` fields: output of `findAndExtractMolecularGraphs(BIG, BMG, bondSubgraphs)`.
  6. Build the struct array `fallbackCases`, each with fields `name, BIG, ATG, outcome, bondSubgraphs, BMG, errorIdentifier, errorMessage, errorTopFrame`. Each case mutates a copy of the captured inputs:
     - `duplicateAtomIndex`: `ATG.Nodes.AtomIndex(2) = ATG.Nodes.AtomIndex(1)`;
     - `nonIntegerAtomIndex`: `ATG.Nodes.AtomIndex = ATG.Nodes.AtomIndex + 0.5`;
     - `componentLabelOutOfRange`: `ATG.Nodes.Component(1) = max(conncomp(ATG)) + 1`;
     - `namedBIGNodes`: add `BIG.Nodes.Name = cellstr("a" + string((1:numnodes(BIG))'))`;
     - `zeroBIGEdges`: `BIG = rmedge(BIG, 1:numedges(BIG))`.
     Run the **unmodified** `extractBondSubgraphs` on each case inside `try/catch ME`, and store either `outcome = 'ok'` with the outputs, or `outcome = 'error'` with `ME.identifier`, `ME.message` and `errorTopFrame = sprintf('%s:%d', ME.stack(1).file, ME.stack(1).line)` (Constitution VII-C). Print one line per case giving the outcome and, for errors, the identifier and `errorTopFrame`.
  7. Save `ciInputs` (`BIG`, `ATG`), `ciExpected`, `fallbackCases` and `provenance` (git commit, `version`, UTC capture time) to `TST/data/bondSubgraphReference.mat` with `-v7`. Print the file size, and emit a `warning` if it is over 1 MB.
- [X] T004 [P] Create `FD/reactingOptimisationReproducibilityCheck.m`, a script, per research R10 and data-model "Golden snapshot". Use `specs/029-vectorize-atm-loops/vectorizationReproducibilityCheck.m` as the structural template, and copy and adapt its local helpers (`corpusProvenance`, `currentGitCommit`, `ternary`, `yesNo`, the fixture pipeline and the external-pointer logic). Requirements:
  - **Fixtures**:
    - `{'nglycan','phe','andest','chol','urea','tyr','bileacid'}` from `subsystemSubModels.mat`;
    - `ci`, the CI fixture built as in T003 step 2 from in-repo data. It is needed for FR-002's `sanityChecks = 1` on the CI fixture;
    - `pufa`, used only with `CBT_RMO_TIMING_ONLY=1`.
    Build `dATM`/`BG` once per fixture with `buildAtomAndBondTransitionMultigraph`, using the same options as 029's pipeline. Do not include that build in any timing.
  - **Modes**:
    - `default` (`sanityChecks = 0`);
    - `conservedOnly` (`sanityChecks = 0, conservedMoietiesOnly = 1`);
    - `sanity` (`sanityChecks = 1`, default reacting mode), run only when `CBT_RMO_SANITY=1`.
    Without `CBT_RMO_SANITY`, run `default` and `conservedOnly`. `CBT_RMO_FIXTURES` gives a comma-separated subset, and any unknown name is an error.
  - **Selecting capture or compare**: CAPTURE if neither `FD/snapshots/<fixture>-<mode>-golden-snapshot.mat` nor its `.external.txt` pointer exists, COMPARE otherwise. Before any CAPTURE, refuse (`error`) unless `git diff --quiet develop -- src/` is clean. Never overwrite an existing snapshot.
  - **Outcome call**: call `identifyConservedReactingMoieties` inside `try/catch ME`. Store either `arm`, `moietyFormulae`, `reacting`, or `errorIdentifier`, `errorMessage`, `errorTopFrame` (from `ME.stack(1)`).
  - **Console capture (SC-006)**: make one separate call wrapped in `diary(tmpFile)` / `diary off`. Read it back with `fileread` and delete the temporary file. Do not use `evalc`.
  - **Timing (FR-012)**: in `default` mode only, 3 further calls with `tic/toc`, diary off. Store `wholeFunctionSeconds` and their `median`.
  - **Targeted-stage timing** (bileacid, `default` mode only): one further call under `profile on -history`. From `profile('info')`, take the `FunctionTable` entry whose `FileName` ends in `identifyConservedReactingMoieties.m` and sum `ExecutedLines(:,3)` over two blocks, whose line ranges are found by text search in the current file:
    - `stage09`: from the line containing `STEP B1` to the line before `%map BIG to connected component`;
    - `stage14to17`: from `%Reacting bond graph` to the line before `STEP 4`.
    Store them as `targetedStageSeconds`. Label them "profiled (relative)" in the report.
  - **Solver**: store `CBT_MILP_SOLVER` (global) at capture. At compare, a different solver gives status `SOLVER MISMATCH`, which is reported separately from a code difference.
  - **Compare**:
    - if the outcomes are both `ok`: compare `arm`, `moietyFormulae` and `reacting` with a local function `[isSame, diffPaths] = compareStrictly(a, b, path)`. It returns false, and records the field path, when any of these differ:
      - `class(a)` vs `class(b)`;
      - `issparse(a)` vs `issparse(b)`;
      - `size(a)` vs `size(b)`;
      - `isequaln(a, b)`.
      For structs it compares the sorted field-name sets and then recurses into each field. For cell arrays it recurses into each element. For graph/digraph objects it compares class and `isequaln` of `Nodes` and `Edges`. The status is `DIFF` (values differ) or `CLASS DIFF` (class, sparsity or size differ), listing every `diffPaths` entry. `isequaln` alone is not enough: it ignores class and sparsity (`isequaln(sparse(A), full(A))` is true), and FR-008 requires the sparsity class to be unchanged;
    - if both are `error`: the identifier and message must be equal;
    - console text: `strcmp`;
    - timing: after median ≤ before median, in `default` mode, **for the seven subsystem fixtures only**. Otherwise the status is `SLOWER`. The results note must say "re-measure before treating as failure" (spec Assumptions: timing noise). The `ci` fixture's timing is recorded, with status `TIMING (not gated)`, because at about 1 s its median is dominated by noise; SC-004 covers only the seven subsystem fixtures.
  - **Snapshot contents**: every field listed in data-model "Golden snapshot", including `corpusProvenance`, `gitCommit`, `capturedAt`, `nReactions`, `nMetabolites`. Snapshots over 10 MB go to `~/repos/reconXmoieties/experiments/moietySizing/results/outputs/reactingOptimisation/`, with a pointer file, as in 029 R7.
  - **Results file**: append one row per fixture and mode to `FD/reacting-optimisation-reproducibility-results.md`, with columns: Run (UTC) | Fixture | Mode | CAPTURE/COMPARE | Status | arm eq | moietyFormulae eq | reacting eq (differing fields) | console eq | median s before -> after (ratio) | targeted stages s before -> after | Solver | Corpus (.rxn count) | Commit | Notes.
  - **Exit**: after all fixtures, call `error` if any fixture has status `DIFF`, `CLASS DIFF`, `ERROR` or `SLOWER`, so that `matlab -batch` exits non-zero. `SOLVER MISMATCH` also counts as a failure, with a distinct message.
  - **Timing gate switch**: when `CBT_RMO_NO_TIMING_GATE=1`, `SLOWER` is recorded as `SLOWER (not gated)` and does not count toward the final `error`. `DIFF`, `CLASS DIFF`, `ERROR` and `SOLVER MISMATCH` still fail.
  - **Stubs**: provide `CBT_RMO_MODE=synthetic`, which dispatches to a local function `runSyntheticReindexingSection(resultsPath)`. **Leave that function as a stub that raises `error('not yet implemented: T022')`**; T022 fills it in. `CBT_RMO_TIMING_ONLY=1` skips the snapshot comparison and runs only the timing calls, then appends a timing row (used for pufa).

**Checkpoint**: three scripts exist and `src/` is untouched (`git diff --quiet develop -- src/`).

---

## Phase 2: Foundational — capture from UNMODIFIED code (BLOCKING)

**Purpose**: every reference in this feature must come from the pre-change code (FR-011, FR-013). **No `src/` edit may begin until T009 is committed.**

- [X] T005 Run `FD/captureBondSubgraphReferences.m` headless (see Conventions). Verify that:
  - `TST/data/bondSubgraphReference.mat` exists;
  - `numel(ciExpected.BMG) > 0`;
  - `fallbackCases` has the 5 named cases, each with `outcome` set.
  Record, in the results file "Baseline" section, each case's outcome (`ok` or `error`, with the identifier). That tells US3 what each fallback must reproduce.
- [X] T006 Run `FD/reactingOptimisationReproducibilityCheck.m` in CAPTURE mode, with the default environment (all 7 subsystem fixtures plus `ci`, modes `default` and `conservedOnly`). Expected runtime is about 60–90 min (5 calls per fixture in `default` mode, 2 in `conservedOnly`; bileacid alone takes about 97 s per call before the change). Verify that each of the 16 fixture/mode pairs has a snapshot or pointer and a `CAPTURE` row, that the `default` rows have before medians, and that the bileacid row has `stage09`/`stage14to17` profiler sums. If a fixture fails in CAPTURE, record its error (it becomes the reference outcome) and do not change `src/`.
- [X] T007 Run the same check with `CBT_RMO_SANITY=1` and `CBT_RMO_FIXTURES=ci,tyr` (FR-002, US1 scenario 4). Verify that two `sanity` snapshots have been captured. An `error` outcome is acceptable: `testConservedReactingMoieties.m` documents a crash with `sanityChecks = 1` that predates this feature, and the snapshot then records that error as the expected outcome.
- [X] T008 Run `TST/testConservedReactingMoieties.m` headless on unmodified code (`cd` to `TST`, then `testConservedReactingMoieties`), and record in the results file whether it passed. This is the SC-002 baseline.
- [X] T009 Commit the capture artefacts before any source change:
  - `FD/captureStageNineInputs.m`, `FD/captureBondSubgraphReferences.m`, `FD/reactingOptimisationReproducibilityCheck.m`;
  - `FD/snapshots/*`;
  - `FD/reacting-optimisation-reproducibility-results.md`;
  - `TST/data/bondSubgraphReference.mat`.
  Message: `Capture golden snapshots before reacting-moiety optimisation` (openCOBRA convention: present tense, ≤72 chars), ending with the Co-Authored-By trailer. Confirm with `git diff --quiet develop -- src/` that `src/` is still unmodified in this commit.

**Checkpoint**: references frozen and committed. Source edits may now begin.

---

## Phase 3: User Story 3 — the rewritten functions are covered by CI (Priority: P2; ordered first so tests come before the code)

**Goal**: automated CI tests that fail if `extractBondSubgraphs` or `findAndExtractMolecularGraphs` outputs drift (FR-013, SC-003).

**Independent Test**: run `testExtractBondSubgraphs` and `testFindAndExtractMolecularGraphs` headless. Both pass on the self-contained fixture with no external data. In this phase they are run against **unmodified** code, which confirms that the reference and the test logic agree.

- [X] T010 [P] [US3] Create `TST/testExtractBondSubgraphs.m` using the layout of `documentation/source/guides/testTemplate.m`:
  - Header comment: `% The COBRAToolbox: testExtractBondSubgraphs.m`, `% Purpose:`, `% Authors:`.
  - Save `currentDir`, `cd` to `fileparts(which('testExtractBondSubgraphs'))`, and restore the directory at the end.
  - Call `prepareTest()`. There is no solver requirement, because only MATLAB graph functions are used.
  - Load `data/bondSubgraphReference.mat`.
  - **CI case**: `[bondSubgraphs, BMG] = extractBondSubgraphs(ciInputs.BIG, ciInputs.ATG)`. Assert that `size` equals the reference size, and that each cell is graph-equal using a local function `isGraphEqual(A, B)` which is true when `strcmp(class(A), class(B)) && isequal(A.Nodes, B.Nodes) && isequal(A.Edges, B.Edges)`. Add a companion `areGraphCellsEqual` for cell arrays.
  - **Fallback cases**: loop over `fallbackCases`. For `outcome == 'ok'`, call the function and assert graph-equality with the stored outputs. For `outcome == 'error'`, call it inside `try/catch ME`, assert that an error occurred, and assert that `ME.identifier` and `ME.message` equal the stored ones. If the call raises an error when `ok` was expected, or raises a different error, the assert message must include `ME.identifier`, `ME.message` and `ME.stack(1).file`/`.line` (Constitution VII-C). The stored `errorTopFrame` is not compared: the file path differs after the rewrite, when the error comes from the local fallback function.
  - Every `assert` carries a message naming the case (for example `sprintf('extractBondSubgraphs output differs from pre-change reference (%s)', name)`).
  - No console output except on failure.
  - Local functions go at the end of the script file, which MATLAB R2016b+ allows.
- [X] T011 [P] [US3] Create `TST/testFindAndExtractMolecularGraphs.m` in the same layout:
  - Call `prepareTest()` and load the same reference.
  - Take `bondSubgraphs`/`BMG` from `ciExpected`, so this test does not depend on `extractBondSubgraphs`.
  - Call `[CMTG, RMTG, CMG, RMG, conservedGroup, reactingGroups] = findAndExtractMolecularGraphs(ciInputs.BIG, ciExpected.BMG, ciExpected.bondSubgraphs)`.
  - Assert that `conservedGroup` and `reactingGroups` are `isequal` to the reference (value and orientation), and that the four graphs pass `isGraphEqual` against the reference.
  - Use the same local-function and assert-message conventions as T010.
- [X] T012 [US3] Run both new tests headless on **unmodified** code (after T010 and T011). Both must pass. If either fails, fix the **test or the capture**, never `src/`, and re-run. Then check CI selection: run `python3 .github/scripts/select_tests.py --help` to find its arguments, and do a dry run with the changed-file list `src/analysis/topology/reactingMoieties/extractBondSubgraphs.m`. Confirm that `testExtractBondSubgraphs`, `testFindAndExtractMolecularGraphs` and `testConservedReactingMoieties` are selected, and record the output in the results file.

**Checkpoint**: US3 test files exist and pass on the pre-change code. The arity checks for the new optional argument are added in US1 (T015, T017), once the argument exists.

---

## Phase 4: User Story 1 — every existing caller gets exactly the same results (Priority: P1) 🎯 MVP

**Goal**: rewrite the three targeted areas in place. `arm`, `moietyFormulae`, `reacting`, the console output and every diagnostic stay identical (FR-001–FR-010).

**Independent Test**: `testConservedReactingMoieties.m` passes unmodified. The reproducibility check in COMPARE mode reports every fixture and mode `EQUAL`, including console text and the `sanity` pass.

### Helper functions (research R1–R3)

- [X] T013 [US1] Rewrite the body of `SRC/extractBondSubgraphs.m` in place, per research R1/R2 and the contract.
  - **Signature**: `function [bondSubgraphs, BMG, bmgEdgeIndex] = extractBondSubgraphs(BIG, ATG)`.
  - **Help header** (keep the existing text and add):
    - an `OPTIONAL OUTPUT:` block for `bmgEdgeIndex`: a cell array the same size as `BMG`, where `bmgEdgeIndex{m}` holds the `EdgeIndex` values of the edges of `BMG{m}`, as a set, in construction order;
    - a `NOTE:` saying that outputs are identical to the original algorithm, and that the original algorithm is used automatically when the node or edge indices do not allow the lookup-array implementation.
  - **Body, in this order**:
    1. The existing `verLessThan('matlab','8.6')` / `error('Requires matlab R2015b+')` / `atoms2component = conncomp(ATG)'; nComps = max(atoms2component);` block, **verbatim**.
    2. If `numedges(BIG) == 0`: set `bondSubgraphs = {}; BMG = {}; bmgEdgeIndex = {};` and `return`.
    3. Build `atomIdxATG = full(ATG.Nodes.AtomIndex)`, `compATG = full(ATG.Nodes.Component)`, `endNodes = BIG.Edges.EndNodes`, `edgeIdx = BIG.Edges.EdgeIndex`.
    4. Evaluate the precondition:
       - `atomIdxATG`, `compATG` and `endNodes` are **numeric**, `>= 1` and whole;
       - `atomIdxATG` is unique;
       - `compATG <= nComps`;
       - `endNodes <= max(atomIdxATG)`;
       - then build `compOfAtom = zeros(max(atomIdxATG),1); compOfAtom(atomIdxATG) = compATG;` and require `all(compOfAtom(endNodes(:)) > 0)`.
       Check `isnumeric` **before** any comparison, so a cell or string never throws.
    5. If the precondition fails: `[bondSubgraphs, BMG] = extractBondSubgraphsByComponentScan(BIG, ATG, atoms2component);`, then `bmgEdgeIndex = cellfun(@(g) g.Edges.EdgeIndex, BMG, 'UniformOutput', false);` and `return`.
    6. Otherwise build `nodesByComp = accumarray(atoms2component(:), (1:numel(atoms2component))', [nComps, 1], @(v) {sort(v(:))});`. Then run the peeling loop exactly as in `~/repos/reconXmoieties/experiments/moietySizing/scripts/reactingOptimisation/extractBondSubgraphsFast.m` lines 90–160:
       - read the cached `endNodes`/`edgeIdx`;
       - `GEdges = GBB.Edges; GNodes = GBB.Nodes;`;
       - peel layers by deleting rows with `GEdges(rows,:) = []`;
       - after every `BIGCopy = rmedge(BIGCopy, idsToRemove)`, run `endNodes(idsToRemove,:) = []; edgeIdx(idsToRemove) = [];`;
       - keep the `component1 == component2` guard and its explanatory comment;
       - keep the `k` reset logic (`ismember(k, idsToRemove)`).
       Do **not** port the prototype's `options`/`verifyMirror` input.
  - **Local function** `extractBondSubgraphsByComponentScan(BIG, ATG, atoms2component)`: the **original** body from `develop`, from `bondSubgraphs = {};` through the end of the outer `while`, verbatim, including its comments, except that it takes `atoms2component` as an argument instead of recomputing it. Keep `nComps` if the original body uses it (it does not). Give it a one-paragraph comment saying that it is the original algorithm, kept as the fallback required by FR-007.
- [X] T014 [US1] Run `TST/testExtractBondSubgraphs.m` and `TST/testConservedReactingMoieties.m` headless. Both must pass. If the extract test fails, diff the offending cell's `Nodes`/`Edges` against the reference and fix `SRC/extractBondSubgraphs.m`. Never edit the reference.
- [X] T015 [US1] Extend `TST/testExtractBondSubgraphs.m` with the new arity (FR-003):
  - on the CI case, call `[bs3, bmg3, bmgEdgeIndex] = extractBondSubgraphs(...)`;
  - assert that `bs3`/`bmg3` equal the 2-output results;
  - assert `iscell(bmgEdgeIndex) && isequal(size(bmgEdgeIndex), size(BMG))`;
  - assert that for every `m`, `isequal(sort(bmgEdgeIndex{m}(:)), sort(bmg3{m}.Edges.EdgeIndex(:)))`;
  - repeat the set check for every `ok` fallback case.
  Run the test, which must pass.
- [X] T016 [US1] Rewrite the body of `SRC/findAndExtractMolecularGraphs.m` in place, per research R3.
  - **Signature**: `function [CMTG, RMTG, CMG, RMG, conservedGroup, reactingGroups] = findAndExtractMolecularGraphs(BIG, BMG, bondSubgraphs, bmgEdgeIndex)`.
  - **Help header**: add an `OPTIONAL INPUT:` block for `bmgEdgeIndex` (the third output of `extractBondSubgraphs`; if omitted or empty it is read from `BMG`), and a `NOTE:` saying that outputs are identical to the previous implementation.
  - **Body**:
    - keep Step 1 verbatim (the `classifySubgraphIsomorphism` call, `max(cellfun(@length, ...))`, `setdiff`), including its comment;
    - `CMTG = assembleMolecularTransitionGraph(bondSubgraphs, conservedGroup); RMTG = assembleMolecularTransitionGraph(bondSubgraphs, reactingGroups);`;
    - `if ~exist('bmgEdgeIndex', 'var') || isempty(bmgEdgeIndex)`, then `bmgEdgeIndex = cellfun(@(g) g.Edges.EdgeIndex, BMG, 'UniformOutput', false);`;
    - build `CMG`/`RMG` from `bigEdges = BIG.Edges`, with `find(ismember(bigEdges.EdgeIndex, vertcat(bmgEdgeIndex{group})))` and `digraph(bigEdges(ids,:), BIG.Nodes)`;
    - keep the trailing commented-out `fprintf` block unchanged.
  - **Local function** `assembleMolecularTransitionGraph(bondSubgraphs, groupIdx)`, as the prototype's `assembleTransitionGraph`:
    - an empty group gives `edgesAll = []; nodesAll = table();`;
    - otherwise collect `Edges`/`Nodes` into cells in group order and `vertcat` them;
    - then `nodesAll = unique(nodesAll, 'rows'); G = digraph(edgesAll, nodesAll);`.
- [X] T017 [US1] Extend `TST/testFindAndExtractMolecularGraphs.m` with the new arity (FR-004):
  - with `cacheFromBMG = cellfun(@(g) g.Edges.EdgeIndex, ciExpected.BMG, 'UniformOutput', false)`, check that the 4-input call with that cache gives six outputs equal to the reference;
  - check the 4-input call with `[]`;
  - check the 4-input call with a cache whose cells are each reversed (`flipud`), proving that the order does not matter (research R2).
  Run both new tests and `TST/testConservedReactingMoieties.m`. All must pass.

### identifyConservedReactingMoieties.m blocks (research R4–R7)

- [X] T018 [US1] In `ICRM`, edit **only** the stage-09 call lines and the two STEP B4 loops (research R7; FR-010 as amended):
  - replace `[bondSubgraphs, BMG] = extractBondSubgraphs(BIG, ATG);` with `[bondSubgraphs, BMG, bmgEdgeIndex] = extractBondSubgraphs(BIG, ATG);`;
  - replace `... = findAndExtractMolecularGraphs(BIG, BMG, bondSubgraphs);` with the same output list and `(BIG, BMG, bondSubgraphs, bmgEdgeIndex)`;
  - replace the body of `for i = 1:length(BMG) ... end` (currently the `currentComponentEdgeIndices`/`repelem` lines) with `bonds2component(bmgEdgeIndex{i}) = i;`;
  - replace the body of `for i = 1:length(CBSubgrahs) ... end` with `bonds2isomorphismClass(bmgEdgeIndex{conservedGroups(i)}) = bondSubsequentSubgraphIndices(i);`.
  Keep the surrounding STEP B1–B4 comment blocks. Add a one-line comment above each loop: `% edge indices come from the extractBondSubgraphs cache (same set as BMG{i}.Edges.EdgeIndex)`. `CBSubgrahs = BMG(conservedGroups);` stays, because `identifyIsomorphicClasses` takes it. Then:
  - run `TST/testConservedReactingMoieties.m`, which must pass;
  - run the check with `CBT_RMO_FIXTURES=ci,tyr,bileacid CBT_RMO_NO_TIMING_GATE=1` in COMPARE mode. `conservedOnly` must be `EQUAL`, since only stage 09 has changed so far. The `default` rows are also expected to be `EQUAL`. `SLOWER` is not judged yet.
- [X] T019 [US1] In `ICRM`, stage 14a (research R4): replace the block that starts `newEndNodes = zeros(size(edgeTable, 1), 2);` and runs through the end of its `for i = 1:size(edgeTable, 1) ... end` loop with the following.
  - Compute `[~, newEndNodes] = ismember(full(edgeTable.EndNodes), full(nodeTable.AtomIndex));`.
  - The condition for keeping that result is `numel(unique(nodeTable.AtomIndex)) ~= height(nodeTable) || any(newEndNodes(:) == 0)`. If it is true, execute the **original** `newEndNodes = zeros(...)` + `for` loop verbatim, in an `if` branch. That reproduces the original error.
  - Add a comment explaining that `nodeTable.AtomIndex` is unique, so `ismember`'s first-match location equals `find`'s, and that the original loop is kept for inputs where it is not (FR-007).
  - `edgeTable.EndNodes = newEndNodes;` and everything after it stay unchanged.
- [X] T020 [US1] In `ICRM`, stage 14b (research R5): replace the block from ` % Initialize the new EndNodes vector` / `endNodesModified = zeros(size(RBG.Edges.EndNodes));` through the end of the nested `for i ... for j ... end end` loop with the following.
  - `rbgEndNodes = RBG.Edges.EndNodes;`
  - `if isnumeric(rbgEndNodes)`, then `endpointComponents = reshape(RBG.Nodes.Component(rbgEndNodes), size(rbgEndNodes)); [~, endNodesModified] = ismember(full(endpointComponents), full(uniqueComponents));`. Otherwise `endNodesModified = [];`.
  - `if ~isnumeric(rbgEndNodes) || any(endNodesModified(:) == 0)`, execute the **original** initialisation and nested loop verbatim.
  - **The `reshape` is mandatory.** Without it a one-edge graph gives a `2x1` result (research R5). Add a comment saying so.
  - `componentTable`, `uniqueComponents`, `newIds`, `edgeTable.EndNodes = endNodesModified;` and `COndensed_RBG = graph(edgeTable, componentTable);` stay unchanged.
- [X] T021 [US1] In `ICRM`, STEP 3 `CRB2R` (research R6): keep every line from `cEdges  = Condensed_RBG.Edges;` through `[~, rxnCols] = ismember(dATM.Edges.rxns, model.rxns);` unchanged. Wrap the `for i = 1:nCRB ... end` loop as follows.
  - Add a local anonymous function `isPositiveWholeNumeric = @(v) isnumeric(v) && all(v(:) >= 1) && all(v(:) == fix(v(:)));`. It must test `isnumeric` first (the prototype's check throws on cells).
  - The fast-path condition is `isPositiveWholeNumeric(atom1_all) && isPositiveWholeNumeric(atom2_all) && isPositiveWholeNumeric(headATM) && isPositiveWholeNumeric(tailATM) && isPositiveWholeNumeric(bondIdx) && all(bondIdx <= maxBondIndex)`.
  - **Fast path** (the prototype's stage-17 block in `patch_reacting_optimisations.py`):
    - `rowsInBG = bondRowMap(bondIdx); foundInBG = rowsInBG > 0;`;
    - `for iMissing = find(~foundInBG)'`, emit `warning('BondIndex %d not found.', bondIdx(iMissing));` with the **identical text**;
    - `validTr = rxnCols > 0;`;
    - `nAtomsMax = max([0; atom1_all(:); atom2_all(:); headATM(:); tailATM(:)]);`;
    - `atomToRxn = spones(sparse([headATM(validTr); tailATM(validTr)], [rxnCols(validTr); rxnCols(validTr)], 1, nAtomsMax, nRxns));`;
    - `foundIdx = find(foundInBG);`;
    - `touch = atomToRxn(atom1_all(rowsInBG(foundIdx)), :) + atomToRxn(atom2_all(rowsInBG(foundIdx)), :);`;
    - `[touchRow, touchCol] = find(touch);`;
    - `CRB2R = sparse(foundIdx(touchRow), touchCol, 1, nCRB, nRxns);`.
  - **`else`**: the original `for` loop verbatim, including its `warning` and `continue`.
  - Keep `CRB2R = sparse(nCRB, nRxns);` before the `if`, so the fallback starts from the same state.
  - Add a comment explaining the incidence formulation and the fallback (FR-007, FR-008).
- [X] T022 [US1] Implement `runSyntheticReindexingSection(resultsPath)` in `FD/reactingOptimisationReproducibilityCheck.m`, replacing the T004 stub (research R4, R5, R6, R8, R10).
  - **Guard**: it holds three pairs of local functions, each an original/optimised pair:
    - stage 14b: `condensedEndNodesOriginal(RBG, uniqueComponents, componentTable)` / `condensedEndNodesOptimised(...)`;
    - stage 14a: `rbgEndNodesOriginal(edgeTable, nodeTable)` / `rbgEndNodesOptimised(...)`;
    - STEP 3: `crb2rOriginal(bondIdx, bondRowMap, atom1_all, atom2_all, headATM, tailATM, rxnCols, nCRB, nRxns, maxBondIndex)` / `crb2rOptimised(...)`.
    Each original is a verbatim copy of the pre-change block taken from `git show develop:<ICRM>`, and each optimised function is a verbatim copy of the T019, T020 or T021 block. Before running any case, the section asserts that each optimised block's key lines appear verbatim in `fileread(<ICRM>)`, so the copies cannot drift from the source. The key lines are: the `reshape(...)` and `ismember(...)` lines for 14b; the `ismember(full(edgeTable.EndNodes)...` line for 14a; and the `atomToRxn = spones(sparse(...` and `CRB2R = sparse(foundIdx(touchRow)...` lines for STEP 3.
  - **Cases** (the RBGs are built by hand with node variables `AtomIndex`, `Component` and `NewId = (1:n)'`):
    1. stage 14b, exactly **one** edge;
    2. stage 14b, three edges across three components;
    3. stage 14b, **zero** edges;
    4. stage 14a, zero reacting edges (`edgeTable` of height 0);
    5. stage 14a, exactly one edge;
    6. STEP 3, `nCRB == 0`;
    7. STEP 3, one bond whose `BondIndex` is absent from `bondRowMap` (row 0). The `BondIndex %d not found.` text, captured with `lastwarn`, must be identical for both versions;
    8. STEP 3, `nRxns` columns but no transition touching the bond (an all-zero row);
    9. stage 14b with a `NaN` in `RBG.Nodes.Component`. Both functions are called inside `try/catch ME`, and both must raise an error with the same `ME.identifier` and `ME.message`. That shows the optimised block's fallback reproduces the original failure (FR-007);
    10. STEP 3 with `headATM` stored as a cell array of numbers. The optimised block must take its fallback and produce the same outcome as the original, whether that is an equal result or the same error.
  - For each case, the outputs are compared with `compareStrictly` (T004): class, `issparse`, size and value. Errors are compared by identifier and message. Every `catch ME` that records an unexpected failure includes `ME.stack(1)`. One `EQUAL`/`DIFF` row per case is appended to the results file.
  - Run it with `CBT_RMO_MODE=synthetic`. All ten rows must be `EQUAL`.

### US1 acceptance gate

- [X] T023 [US1] Run `TST/testConservedReactingMoieties.m`, `TST/testExtractBondSubgraphs.m` and `TST/testFindAndExtractMolecularGraphs.m` headless. All must pass. Then run `git diff --quiet develop -- test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`, which must exit 0 (SC-002).
- [X] T024 [US1] Run `FD/reactingOptimisationReproducibilityCheck.m` in COMPARE mode with the default environment (7 fixtures plus `ci`; `default` and `conservedOnly`). Every row must show `arm`, `moietyFormulae`, `reacting` and console text `EQUAL` (SC-001, SC-006). Also assert, directly on the loaded snapshot and the new output, `issparse(reacting.CRB2R)` and `strcmp(class(reacting.CRB2R), 'double')` for every fixture in `default` mode (FR-008).
  - **On any `DIFF`**: stop. Find the first divergent intermediate by re-running that fixture with the pre-change blocks swapped back in one at a time, in a scratch copy outside `src/`. Fix the rewrite. **Never** edit or recapture a snapshot, and never loosen a comparison.
  - `SLOWER` rows are handled in US2 (T027), not here.
- [X] T025 [US1] Run the check with `CBT_RMO_SANITY=1` and `CBT_RMO_FIXTURES=ci,tyr` in COMPARE mode (FR-002, US1 scenario 4). Both rows must be `EQUAL`: identical outputs, or an identical error identifier and message.
- [X] T026 [US1] Static scope and diagnostics review (FR-009, FR-010, SC-005), recorded as a "Scope review" section in the results file.
  1. `git diff develop --stat` lists only these files:
     - `SRC/extractBondSubgraphs.m`, `SRC/findAndExtractMolecularGraphs.m`, `ICRM`;
     - `TST/testExtractBondSubgraphs.m`, `TST/testFindAndExtractMolecularGraphs.m`, `TST/data/bondSubgraphReference.mat`;
     - `FD/**`, `CLAUDE.md` (plan pointer only), `.specify/feature.json`.
  2. `git diff develop -U0 -- src/ | grep -E '^-.*\b(error|warning|fprintf|sanityChecks)\b'` prints nothing, or only lines that reappear verbatim in a fallback branch or local function. Check each such line by hand and list it.
  3. `git diff develop -- <ICRM>` hunks fall only inside the four blocks of T018–T021.
  4. `ls SRC/*Fast*.m` finds nothing.
  5. `grep -n "options\." <the diff of ICRM>` shows no new option field.
  6. Record that the in-function fallbacks (T019, T020, T021) cannot be reached through the public interface. Their evidence is the verbatim-copy review in step 2 (research R8, contract table).

**Checkpoint**: US1 met. This is the MVP: identical results with the optimised code in place.

---

## Phase 5: User Story 2 — large models identify their moieties faster (Priority: P2)

**Goal**: show, and report, that the whole function is not slower on any fixture, and report the targeted-stage gain on bileacid (FR-005, FR-006, FR-012, FR-014; SC-004, SC-007).

**Independent Test**: the results file holds, for each of the 7 fixtures, the before and after median of 3 runs and their ratio, with after ≤ before, plus bileacid's `stage09`/`stage14to17` sums before and after.

- [X] T027 [US2] From the T024 rows, check every fixture's `default` row: after median ≤ before median. For a `SLOWER` fixture, re-run the timing only (`CBT_RMO_TIMING_ONLY=1`, `CBT_RMO_FIXTURES=<name>`) up to two more times, on an otherwise idle machine, and record every run. Treat it as a failure only if, after both re-measurements, the smallest after median still exceeds the before median by more than 5% or by more than the spread (max − min) of the before runs, whichever is larger. In that case stop and report to the user; do not change the gate.
- [X] T028 [US2] Add a "Timing summary" section to `FD/reacting-optimisation-reproducibility-results.md` containing:
  - a table of fixture | reactions | before median s | after median s | ratio;
  - the prototype's reference ratios for comparison (spec Background: 1.4x–2.0x; bileacid 97.4 s → 49.4 s, tyrosine 31.8 s → 17.5 s), marked as reference, not a gate;
  - the bileacid profiled `stage09` and `stage14to17` sums, before → after, labelled relative (profiler overhead);
  - a sentence on US2 scenario 3, stating that inputs outside the fast path's preconditions are covered by the US3 fallback cases (T010, T015).
- [ ] T029 [P] [US2] OPTIONAL, not a gate (FR-014, SC-007): run `CBT_RMO_FIXTURES=pufa CBT_RMO_TIMING_ONLY=1` under a wall-clock limit of 4 h, using `timeout 4h` around the MATLAB call. Append its outcome (completed with its time, or did not finish within 4 h) to the timing summary. Skip it if the user declines the multi-hour run, and record that it was skipped.

**Checkpoint**: US2 is reported and the timing gate is evaluated.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [X] T030 [P] Check the help headers of `SRC/extractBondSubgraphs.m` and `SRC/findAndExtractMolecularGraphs.m` against `documentation/source/guides/documentationGuide.rst`:
  - one space after `%`;
  - argument lines indented 4 spaces with a colon;
  - blank comment lines around keywords;
  - canonical signature spacing;
  - no agent-specific wording (Principle X).
- [X] T031 [P] Review all files touched in this feature against Constitution VII and record the review in the results file:
  - `grep -n "evalc\|nargin\|warning('off'\|warning off"` on the changed or added `.m` files finds nothing new (`nargin` may only appear in unchanged original code);
  - every `catch ME` records `ME.stack(1)`;
  - no added line in `src/` or `test/` uses an absolute path.
  Also record that no MATLAB-conventions skill is registered and that one is proposed as a follow-up (research R12).
- [X] T032 Run the `testReactingMoieties` folder through the harness: `setenv('COBRA_TESTS','testReactingMoieties'); cd test; testAll` headless (or `runTestSuite('testReactingMoieties')` if `testAll` requires CI environment variables). Record the pass, fail and skip counts in the results file.
- [X] T033 Run the [quickstart.md](quickstart.md) steps 1–3 once more as a final validation, and confirm that the results agree with T023–T026.
- [X] T034 Record the candidate follow-up features from research R13 in the results file's closing "Follow-ups" section. Record them only; implement none of them.
- [X] T035 Report to the user: files changed, checks run, tests passed or failed, the timing table, and behaviour not verified. The last must include the in-function fallbacks that the public interface cannot reach, and pufa if it was skipped.
- [X] T036 Create the implementation receipt `FD/agent-runs/<UTC-timestamp>-reacting-moiety-optimisation/implementation-receipt.md`, with the sections Prompt, Final response (the actual final user-facing response, verbatim), Diff summary (every changed file), Tests, and Unresolved issues. Follow the Constitution's Implementation Receipt Ledger and `specs/029-vectorize-atm-loops/agent-runs/*/implementation-receipt.md` as a format example.

---

## Dependencies & Execution Order

### Phase dependencies

- **Phase 1 (Setup)**: none. T002, T003 and T004 are different files and can be written in parallel after T001.
- **Phase 2 (Foundational)**: needs Phase 1, and **blocks every later phase**. T005 needs T002 and T003. T006 and T007 need T004. T008 is independent. T009 needs T005–T008.
- **Phase 3 (US3)**: needs T009 (the reference is committed). T010 ∥ T011, then T012.
- **Phase 4 (US1)**: needs T012 (the tests exist before the code changes).
  - T013 → T014 → T015 (extract).
  - T016 needs T013, because the cache is produced there, then T017.
  - T018 needs T013 and T016.
  - T019, T020 and T021 edit the same file (`ICRM`), so they run **sequentially** after T018.
  - T022 needs T020.
  - T023–T026 need T018–T022.
- **Phase 5 (US2)**: needs T024 (the timings come from that run). T029 is optional and independent of T027/T028.
- **Phase 6 (Polish)**: needs Phases 4 and 5. T030 ∥ T031. T036 comes last.

### User story dependencies

- **US3** needs only Foundational. It is independently deliverable and gives CI coverage even before any rewrite.
- **US1** needs Foundational, and needs US3's test files so that the tests come before the code. Its acceptance does not depend on US2.
- **US2** needs US1's COMPARE run. A speed-up is acceptable only when US1 holds (spec US2 priority rationale).

### Within each story

- The reference is captured before any code change. The tests are written before the functions they cover. Each source rewrite is followed immediately by its test run (T014, T017, T018). All `ICRM` edits are sequential.

---

## Parallel Opportunities

```text
# Phase 1, after T001 (three different files):
T002  FD/captureStageNineInputs.m
T003  FD/captureBondSubgraphReferences.m
T004  FD/reactingOptimisationReproducibilityCheck.m

# Phase 3 (two different test files, same read-only reference):
T010  TST/testExtractBondSubgraphs.m
T011  TST/testFindAndExtractMolecularGraphs.m

# Phase 5/6 (independent of each other):
T029  optional pufa timing (long-running, background)
T030  help-header review
T031  Constitution VII review
```

Tasks that are **not** parallel: T019, T020 and T021 (same file); T013 and T016 (T016 consumes T013's new output); and every Phase 2 capture run against the Phase 4 edits.

---

## Implementation Strategy

### MVP (US1)

1. Phase 1 → Phase 2. **Stop and confirm that the capture was committed with `src/` unmodified** (T009).
2. Phase 3 (US3 tests, passing on the pre-change code).
3. Phase 4 (US1). **Stop and validate**: T023–T026 all green. This is the MVP: faster code that gives identical results.

### Incremental delivery

1. Phases 1–2: frozen references (reviewable on their own).
2. Phase 3: CI coverage of the two helpers (useful even if the rewrite were abandoned).
3. Phase 4: the rewrites, each verified straight away. Extraction first (T013–T018), because it is the largest measured cost; then the stage 14/17 blocks.
4. Phase 5: the timing report and gate.
5. Phase 6: reviews, the harness run and the receipt.

### Rollback

Each `src/` task is small and verified straight away. If a COMPARE mismatch cannot be resolved, revert that block only (`git checkout develop -- <file>` for the helper files, or reverse the hunk in `ICRM`). The snapshots and tests stay valid, because they were captured from `develop`.
