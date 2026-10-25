# Implementation receipt: 20260929-111453-conserved-moiety-table-hotspots

## Prompt

`/speckit-implement` (no arguments), run on branch `20260929-111453-conserved-moiety-table-hotspots` against `specs/20260929-111453-conserved-moiety-table-hotspots/tasks.md` (T001–T029). User interactions during the run:
- the choice "Re-run gate, 5 runs (Recommended)" after the first SC-003 timing run was disturbed;
- "continue" after the auto-mode classifier stopped giving verdicts;
- "progress report" and "any progress" status requests.

## Final response

All three stories have shipped, and the conserved-moiety step on the 1,960-reaction model is now **2.1× faster**: a median of 758 s before and 364 s after, a ratio of **0.479** against the 0.65 gate. Every output is identical to the pre-change code on all fixtures, and all 29 tasks are complete.

| Check | Result |
|---|---|
| SC-001: identical outputs | `arm`, `moietyFormulae` and `reacting` match on the 1,960-reaction model (conserved-only), all 6 CI golden cases (including the 2 sanity-mode cases, which raise the same error as before), and the 8-subsystem check (16/16 equal, plus tyr and ci in sanity mode). |
| SC-002: whole-graph calls | `graph.subgraph` went from 110,832 to 1 (the untouched `MTG` extraction), and `graph.subsasgn` from 271,845 to 70,206. |
| SC-003: gate | 0.479, from 5 alternating runs each (pre-change 715–761 s, new 355–367 s). |
| SC-004: per block (reported) | Reorientation 186 s → 0.4 s; component subgraphs 74 s → 14.5 s per set (runs twice); moiety graphs 132 s → 12.5 s; propagation 56.7 s → 3.1 s profiled. |
| SC-005: tests | All 12 `testReactingMoieties` tests pass, including the extended `testConservedReactingMoieties` and the new `testExtractPartitionSubgraphs`. |

**What changed**
- **`src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m`:**
  - reoriented atom transitions are swapped in one pass: one read of the edge table, then five whole-column writes;
  - both per-component subgraph sets, and the moiety graphs `arm.MG`, are built by the new helper;
  - moiety-index propagation visits only each class's members and writes all atoms in one pass, keeping the original loop as a fallback for non-unique `AtomIndex`;
  - an author line is added.

  No messages changed, and every `sanityChecks` block is byte-identical.
- **`src/analysis/topology/reactingMoieties/extractPartitionSubgraphs.m` (new):** returns the subgraph of every part of a node labelling. It groups nodes and edges once and builds each part from its own rows, identical to what `subgraph` returns.
- **Tests:**
  - `testConservedReactingMoieties.m` compares against 6 golden cases (`data/conservedReactingMoietiesReference.mat`, 672 KB, captured from `858feabc1`);
  - `testExtractPartitionSubgraphs.m` (new) checks the helper against `subgraph` on 50 random graphs and 3 fixed cases.
- **Feature directory:** plan documents, the capture and check scripts, the pre-change copy, the results file, three per-story revert patches, and this receipt.

**Things you should know**
1. **The first gate run was disturbed.** It measured a formal 0.650 (FAIL), with run times up to 2× their siblings during a Microsoft Defender scan (load average about 9 on 12 cores). At your decision it was re-measured with 5 runs on a quiet machine: 0.479. Both runs are in the results file.
2. **Existing defect: `sanityChecks = 1` stops with an error.** With sanity checks on, the conserved-moiety step stops in `identifyIsomorphicClasses.m:34` ("Inconsistent mapping of atoms to connected components."). The new code raises the identical error, and the golden cases lock that in. The sanity check itself is worth fixing in a separate feature.
3. **Sanity mode in the 8-subsystem check covered two fixtures.** Only tyr and ci have sanity snapshots, and both match. The script correctly refused to capture new snapshots for the other six, because `src/` is modified. Only its results file was appended to.
4. **Another feature's file was changed.** Running that check appended rows to `specs/20260921-154310-reacting-moiety-optimisation/reacting-optimisation-reproducibility-results.md`.
5. **Not verified:**
   - default mode on the 1,960-reaction model, which is out of scope (its MILP stage runs after the changed blocks);
   - MATLAB versions other than R2024b Update 8.

Nothing is committed. The local captures (1.1 GB of 1,960-reaction inputs) are in `~/repos/reconXmoieties/experiments/moietySizing/results/outputs/conservedMoietyHotspots/`.

## Diff summary

Modified (tracked):
- `src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m`: +77/−58. Author line; reorientation (old 424–435); first per-component loop (591–595); second per-component loop (1040–1044); propagation (1046–1066); moiety-graph loop (1152–1177).
- `test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`: +64. Golden comparison before and after the MILP gate, the `checkGoldenCase` local function, `global CBT_MILP_SOLVER`, and purpose/authors.
- `specs/20260921-154310-reacting-moiety-optimisation/reacting-optimisation-reproducibility-results.md`: +34. Rows appended by its own script (T023).
- `CLAUDE.md`, `.specify/feature.json`: plan pointer and active feature (from `/speckit-plan` and `/speckit-specify`).

New (untracked):
- `src/analysis/topology/reactingMoieties/extractPartitionSubgraphs.m`
- `test/verifiedTests/analysis/testReactingMoieties/testExtractPartitionSubgraphs.m`
- `test/verifiedTests/analysis/testReactingMoieties/data/conservedReactingMoietiesReference.mat` (671,990 bytes)
- `specs/20260929-111453-conserved-moiety-table-hotspots/`: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `quickstart.md`, `tasks.md`, `contracts/extractPartitionSubgraphs.md`, `checklists/requirements.md`, `research-prototype/` (2 probes), `identifyConservedReactingMoietiesBaseline.m`, `captureHotspotFixtures.m`, `conservedMoietyHotspotsCheck.m`, `conservedMoietyHotspotsResults.md`, `story1-reorientation.patch`, `story2-components.patch`, `story3-moiety-graphs.patch`, and this receipt.

Outside the repository (not committed): `~/repos/reconXmoieties/experiments/moietySizing/results/outputs/conservedMoietyHotspots/n1960-identifyInputs.mat`.

## Tests

All runs used MATLAB R2024b Update 8. Full tables are in `conservedMoietyHotspotsResults.md`.

- **Unchanged source (T007):** `testConservedReactingMoieties` PASS. n1960 identical; subgraph 110,832, subsasgn 271,845; propagation 55.9 s profiled.
- **Helper (T010):** `testExtractPartitionSubgraphs` PASS.
- **Story 1 (T013/T014):** both tests PASS; n1960 identical; subsasgn 172,090.
- **Story 2 (T017/T018):** both tests PASS; n1960 identical; subgraph 31,000; subsasgn 70,206; propagation 3.1 s.
- **Story 3 (T020/T021):** both tests PASS; n1960 identical, including `arm.MG`; subgraph 1.
- **T022 gate:**
  - first run: 0.650 (disturbed; not accepted);
  - 5-run re-measure: 0.479 PASS. Pre-change 715.3/761.3/758.1/758.9/755.0 s; new 354.8/363.9/363.5/363.0/367.3 s.
- **T023:** 8-subsystem check 16/16 EQUAL; sanity tyr and ci EQUAL (same error); the other six sanity fixtures have no snapshot and capture was refused.
- **T024:** 12/12 `testReactingMoieties` PASS.
- **T026 static review:** PASS.

## Unresolved issues

- **Existing defect:** `identifyIsomorphicClasses` sanity check (line 34) makes `sanityChecks = 1` unusable for `identifyConservedReactingMoieties`. It is preserved by design and needs its own spec.
- **Sanity snapshots missing:** six of the 8 subsystem fixtures have none (they could be captured on `develop`/`858feabc1` in a separate run).
- **Carried over:** the stale 021/022 corpus paths, and the latent non-termination in the preserved `extractBondSubgraphs` loop, both from earlier features.
- **Nothing committed:** commit or push only on the user's instruction.

## Other information

- **VII-F:** no MATLAB-conventions skill is registered. The practice rules in `specs/20260928-100409-extract-bond-subgraphs-local-peeling/matlab-practice-notes.md` were applied.
- **Deviations recorded in the feature files:**
  - capture records error outcomes for the sanity cases (the pre-existing defect);
  - the check script gained `CBT_CMH_TIMING_ONLY` for the gate re-measure;
  - the gate was re-measured with 5 runs, at the user's decision.
- **All three stories shipped.** No deferrals.
