---

description: "Task list for classifying isomorphism on label-only copies"
---

# Tasks: Classify isomorphism on label-only copies

**Input**: Design documents from `specs/20260930-102230-isomorphism-label-only-copies/`

**Prerequisites**: plan.md, spec.md, research.md (R1–R6), data-model.md, contracts/classifySubgraphIsomorphism.md, quickstart.md

**Tests**: Required (Constitution III). The expected classifications are captured from the unchanged helper before the edit (T005).

**Organization**: a single user story (US1). The capture, test and check script are foundational.

## Format: `[ID] [P?] [Story] Description`

## Path conventions

- `FEATURE` = `specs/20260930-102230-isomorphism-label-only-copies`
- `SRC` = `src/analysis/topology/reactingMoieties/classifySubgraphIsomorphism.m`
- `TESTDIR` = `test/verifiedTests/analysis/testReactingMoieties`
- `OUT` = `~/repos/reconXmoieties/experiments/moietySizing/results/outputs`
- `BASE` = commit `f4a62639e`

Run MATLAB headless with absolute script paths: `/usr/local/MATLAB/R2024b/bin/matlab -batch "initCobraToolbox(false); run('/home/jackmcgoldrick/cobratoolbox/<path>')"`.

---

## Phase 1: Setup

- [X] T001 From the repository root, confirm `git merge-base --is-ancestor f4a62639e HEAD` and `git diff --quiet f4a62639e -- src/`. Confirm these files exist:
  - `OUT/extractBondSubgraphsPeeling/n1960-inputs.mat`
  - `OUT/extractBondSubgraphsPeeling/n1960-endToEnd-golden.mat`
  - `OUT/conservedMoietyHotspots/n1960-identifyInputs.mat`

  Stop and report if any check fails.
- [X] T002 [P] Create `FEATURE/baseline/classifySubgraphIsomorphism.m` from `git show f4a62639e:SRC`, verbatim, keeping the same function name so it can shadow the source on the path (plan, "Baseline timing"). Verify with `diff <(git show f4a62639e:SRC) FEATURE/baseline/classifySubgraphIsomorphism.m`, which must print nothing.

---

## Phase 2: Foundational (references, tests and check script on the unchanged helper)

**Do not edit `SRC` until T008 passes.**

- [X] T003 Create `FEATURE/captureClassifyReference.m`.
  1. **Guard**: `git diff --quiet f4a62639e -- SRC` via `system`. If it fails, raise the error `captureClassifyReference:srcModified`.
  2. **Random cases**: with `rng(1)`, build 30 subgraph lists. Port `randomGraph` and the list construction from `FEATURE/research-prototype/probeLabelOnly2.m`:
     - 12 subgraphs each, half of them isomorphic relabellings of a base graph made with `reordernodes`;
     - `graph` for odd list indices and `digraph` for even;
     - parallel edges and self-loops;
     - node variables `mets`, `Junk`, `AtomIndex`, and edge variables `mets`, `Weight`;
     - for every fifth list, 10 further edge variables (alternately numeric and cell) and 5 further node variables, so some cases carry many extra variables, as the real subgraphs do (FR-007).
  3. **Modes**: classify each list with the unchanged `classifySubgraphIsomorphism` in the modes `{}`, `{'NodeVariables','mets'}`, `{'EdgeVariables','mets'}`, `{'NodeVariables','mets','EdgeVariables','mets'}` and `{'NodeVariables',"mets"}` (a string value). Wrap each call in `classifySubgraphIsomorphism('resetCallCount')` and `n = classifySubgraphIsomorphism('getCallCount')`.
  4. **Save**: a struct array `referenceCases` with fields `subgraphs`, `options`, `isomorphismClasses`, `firstSubgraphIndices`, `subsequentSubgraphIndices` and `callCount`.
  5. **Error cases**: record the identifier and message of `classifySubgraphIsomorphism(list, 'NodeVariables', {'mets'})` (expected `MATLAB:table:IllegalVarSubscript`) and of `classifySubgraphIsomorphism(list, 'NodeVariables', 'nope')` (expected `MATLAB:table:UnrecognizedVarName`), into `errorCases` with fields `subgraphs`, `options`, `errorIdentifier` and `errorMessage`.
  6. **Output**: save to `TESTDIR/data/classifySubgraphIsomorphismReference.mat` with `-v7`, and print the size.

  Every `catch` reports `ME.stack(1)` (VII-C).
- [X] T004 Run T003. Record the file size, and the number of cases and classes.
- [X] T005 Extend `TESTDIR/testClassifySubgraphIsomorphism.m` (III-Naming: extend, not duplicate). Add a block that loads `data/classifySubgraphIsomorphismReference.mat`.
  - **Reference cases**: for each case, reset the counter, classify `c.subgraphs` with `c.options{:}`, and assert `isequal` on all three outputs and on the call count. Messages name the case index and the mode.
  - **Error cases**: assert the same identifier and message, following the pattern of the existing tests' error checks.
  - **Header**: update the `Purpose:` and `Authors:` comments (feature `20260930-102230`, FR-002, FR-004, FR-005, FR-007).

  Keep the existing assertions unchanged.
- [X] T006 [P] Create `FEATURE/isomorphismLabelOnlyCheck.m` (non-CI check; research R5).
  1. **Classification equality (SC-001, SC-002, SC-004)**:
     1. Load the ATG from `OUT/extractBondSubgraphsPeeling/n1960-inputs.mat`, and build `subgraphs = extractPartitionSubgraphs(ATG, conncomp(ATG)')`.
     2. Classify with `'NodeVariables', 'mets'` twice: with `FEATURE/baseline` at the front of the path (`addpath(baselineDir, '-begin')`, asserting that `which('classifySubgraphIsomorphism')` is the baseline file), then with it removed (`rmpath`, asserting that `which` is `SRC`).
     3. Time both, reset and read the call counter each time, and compare the three outputs with `isequal`.
  2. **End-to-end equality and total call count (SC-001, SC-004)**: load `OUT/conservedMoietyHotspots/n1960-identifyInputs.mat` and run `identifyConservedReactingMoieties(model, BG, dATM, struct('sanityChecks', 0, 'conservedMoietiesOnly', true))` twice, once with the baseline helper on the path and once with the source helper (asserting which is active each time). Reset the call counter before each run and read it after. Compare `arm`, `moietyFormulae` and `reacting` of the source-helper run with `OUT/extractBondSubgraphsPeeling/n1960-endToEnd-golden.mat` using `isequaln`. Assert that the two runs' total `isisomorphic` call counts are equal (all three call sites; the profile recorded 122,451), and report both. Keep the per-site count from step 1.
  3. **Gate (SC-003, unless `CBT_ILO_NO_TIMING=1`)**: 5 alternating runs (`CBT_ILO_TIMING_RUNS` overrides) of that same call, first with the baseline helper on the path and then without. Assert which file is active before each run, and log `uptime` before and after. Report the medians, the ratio (gate ≤ 0.60) and each run.
  4. **Output**: append a dated section (commit, `+modified`) to `FEATURE/isomorphismLabelOnlyResults.md`, creating it with a heading on first use.
  5. **Failure**: raise `isomorphismLabelOnlyCheck:mismatch` when outputs or counts differ, and `isomorphismLabelOnlyCheck:gate` when the gate fails, both after writing the results.
- [X] T007 Run the checks on the **unchanged** helper:
  1. `runtests('testClassifySubgraphIsomorphism')` must PASS.
  2. `CBT_ILO_NO_TIMING=1 isomorphismLabelOnlyCheck` must report identical classification with an equal call count (39,204 at this call site), and identical end-to-end outputs.

  Record the results.
- [X] T008 **Checkpoint**: T007 passes. The references are frozen, and `SRC` may now be edited.

---

## Phase 3: User Story 1 — Compare only the labels that matter (Priority: P1) 🎯 MVP

**Goal**: FR-002 to FR-006 and FR-010.

**Independent Test**: T010 to T012.

- [X] T009 [US1] Edit `SRC` (plan, Design steps 1–5):
  1. Add `labelOnlySubgraphs = cell(numSubgraphs, 1);` next to `nodeLabels`/`edgeLabels`.
  2. At the end of the invariant loop body, **after** the `nodeLabels{i}`/`edgeLabels{i}` reads, add `labelOnlySubgraphs{i} = labelOnlyCopy(subgraphs{i, 1}, nodeVarName, edgeVarName);`.
  3. Change the comparison to `isisomorphic(labelOnlySubgraphs{i}, labelOnlySubgraphs{j}, varargin{:})`.
  4. Add a local function after the main function:

     ```matlab
     function labelOnlySubgraph = labelOnlyCopy(subgraph, nodeVarName, edgeVarName)
     % Copy of a graph or digraph with the same nodes and edges (directions, parallel edges and
     % self-loops, in the same edge row order) that carries only the label variables compared
     [sourceNodes, targetNodes] = findedge(subgraph);
     if isa(subgraph, 'digraph')
         labelOnlySubgraph = digraph(sourceNodes, targetNodes, [], numnodes(subgraph));
     else
         labelOnlySubgraph = graph(sourceNodes, targetNodes, [], numnodes(subgraph));
     end
     if ~isempty(nodeVarName)
         labelOnlySubgraph.Nodes.(nodeVarName) = subgraph.Nodes.(nodeVarName);
     end
     if ~isempty(edgeVarName)
         labelOnlySubgraph.Edges.(edgeVarName) = subgraph.Edges.(edgeVarName);
     end
     end
     ```

  5. Extend the `NOTE` block with one paragraph, in the existing style: `isisomorphic` compares label-only copies built once per subgraph, because re-reading labels from full node and edge tables dominated its cost; the outputs, the candidate pairs and the call count are unchanged. Add a provenance line for this feature under `Author:`.
- [X] T010 [US1] Run `runtests('testClassifySubgraphIsomorphism')` and `runtests('testConservedReactingMoieties')`. Both must PASS; the second covers all three callers through its 6 golden cases.
- [X] T011 [US1] Run `CBT_ILO_NO_TIMING=1 isomorphismLabelOnlyCheck`.
  - **Expected**: classification identical, with the same call count (39,204); the ratio reported (SC-002, target ≤ 0.20; research measured 0.111); end-to-end identical, with the same total call count for the baseline and new helpers (SC-004).
  - **On failure**: revert `SRC` to `BASE`, stop, and report to the user.
- [X] T012 [US1] Run the gate: `isomorphismLabelOnlyCheck` with timing on (5 runs). Run it alone on a quiet machine, and record `uptime` before and after.
  - **Expected**: median ratio ≤ 0.60 (projected 0.40–0.47).
  - **On failure**: if the runs are inconsistent (any run more than 1.5× the median of its siblings) or the load average was high, report this to the user and ask whether to re-run. Otherwise stop and report the measured ratio.

---

## Phase 4: Polish & Cross-Cutting

- [X] T013 [P] Run `reactingOptimisationReproducibilityCheck.m` (absolute path, `CBT_RMO_NO_TIMING_GATE=1`). 16/16 must be EQUAL. Record the result in `FEATURE/isomorphismLabelOnlyResults.md`.
- [X] T014 [P] Run `runtests('test/verifiedTests/analysis/testReactingMoieties')`. All must PASS. Record the list.
- [X] T015 Static review of `git diff f4a62639e -- src/`:
  1. Changes are only in `SRC`: the new cell, the copy line, the `isisomorphic` arguments, the local function, and the `NOTE`/`Author` lines.
  2. No message text changed.
  3. No `evalc`, `nargin` or new `try/catch`.
  4. The copies are linear in size.

  Record the results.
- [X] T016 Run quickstart.md steps 1–5 against the final state, and record the status of each step.
- [X] T017 Report to the user:
  - files changed;
  - checks run;
  - tests passed and failed, with output;
  - SC-002 (classification ratio);
  - SC-003 (gate ratio);
  - SC-004 (call count);
  - behaviours not verified.
- [X] T018 Create `FEATURE/agent-runs/<UTC-timestamp>-isomorphism-label-only-copies/implementation-receipt.md`, with the sections Prompt, Final response (T017's response, verbatim), Diff summary, Tests, Unresolved issues and Other information.

---

## Dependencies & Execution Order

- **Phase 1**: T001, then T002.
- **Phase 2**: T003 → T004 → T005 → T007 (T007 also needs T006). T006 can be written in parallel with T003–T005. Then T008.
- **US1**: T009 → T010 → T011 → T012, after T008.
- **Phase 4**: after T012. T013 and T014 run in parallel, but not during T012's timing runs. Then T015 → T016 → T017 → T018.

## Parallel Example

```text
Stream A: T003 → T004 → T005
Stream B: T006 (check script)
Then: T007 → T008 → T009 → T010 → T011 → T012 → (T013 ∥ T014) → T015 → T016 → T017 → T018
```

## Implementation Strategy

- **MVP**: the whole feature is one story. Verify it (T010, T011), then gate it (T012).
- **Rollback**: a one-file revert (`git checkout f4a62639e -- SRC`) restores the previous behaviour.
