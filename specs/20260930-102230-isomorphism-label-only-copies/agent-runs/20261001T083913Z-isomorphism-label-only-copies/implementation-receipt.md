# Implementation receipt: 20260930-102230-isomorphism-label-only-copies

## Prompt

`/speckit-implement` (no arguments), run on branch `20260930-102230-isomorphism-label-only-copies` against `specs/20260930-102230-isomorphism-label-only-copies/tasks.md` (T001–T018). User interactions during the run:
- "progresS?" and "progress report" status requests;
- a usage-limit pause, then "continue";
- the gate decision "Accept current ratios" after external load disturbed the timing runs;
- the information that the RXN corpus had moved to `/media/JACK/repos/ctf/rxns/moiety_rxns/atomMapped_std`.

## Final response

The feature is complete. The isomorphism classification now compares label-only copies of the subgraphs, which makes the largest remaining cost in the conserved-moiety step about **10× faster**. Every output is identical to the pre-change code, and all 18 tasks are done.

| Check | Result |
|---|---|
| SC-001: identical outputs | Classification of the 39,916 real 1,960-reaction components is identical (checked three times). End-to-end `arm`, `moietyFormulae` and `reacting` match the 1,960-reaction golden. All 150 CI reference cases and 2 error cases match. 8-subsystem check 16/16 equal. |
| SC-002: classification speed | 243.7 s → 27.0 s (ratio **0.111**), and 303.2 s → 23.9 s (0.079) on the repeat. Target ≤ 0.20. |
| SC-003: end-to-end gate | **0.521** (median of 2 alternating pairs: 0.48 and 0.54) against ≤ 0.60. **PASS, under heavy external load**, accepted at your decision instead of the 5-run median. |
| SC-004: call count | `isisomorphic` calls unchanged: 39,204 at the component site, and 122,451 in total. |
| SC-005: tests | All 12 `testReactingMoieties` tests pass. |

**What changed**
- **`src/analysis/topology/reactingMoieties/classifySubgraphIsomorphism.m`** (+30/−1):
  - each subgraph gets a label-only copy, built once in the existing invariant loop after the labels are read, so errors still occur at the same point;
  - `isisomorphic` compares the copies;
  - a new local function `labelOnlyCopy` builds the copy: same nodes and edges, including directions, parallel edges and self-loops, with only the requested `NodeVariables`/`EdgeVariables`;
  - `NOTE` and author lines are updated.

  The three callers are unchanged, and no message changed.
- **Tests:** `testClassifySubgraphIsomorphism.m` is extended with the pre-change reference cases, call counts and errors (`data/classifySubgraphIsomorphismReference.mat`, 470 KB).
- **Feature directory:** plan documents, the baseline copy of the old helper, the capture and check scripts, the results file, and this receipt.

**Things you should know**
1. **The gate was not measured as specified.**
   - The first gate run was stopped by my background time limit before any timing was recorded.
   - The second run overlapped your `transport_025` Java batch, with a load average of about 33 on 12 cores, which slowed both helpers 1.5–2.4×.
   - At your decision, its first two pairs (0.48, 0.54) were accepted. Both are under 0.60, and both helpers were slowed together. A clean 5-run median on a quiet machine would settle it formally, and the classification ratio (0.08–0.11) suggests it would land well under 0.60.
2. **The RXN corpus moved during the 8-subsystem check.** Seven fixtures were re-run against `/media/JACK/repos/ctf/rxns/moiety_rxns/atomMapped_std` (the same 17,072 files), using a temporary copy of the check script with only the corpus path changed. That copy has been deleted, but the original script still points at the old path, so it will fail until it is updated or the corpus moves back.
3. **Another feature's file was changed.** Both check runs appended rows to `specs/20260921-154310-reacting-moiety-optimisation/reacting-optimisation-reproducibility-results.md`.
4. **Not verified:**
   - a quiet-machine 5-run gate;
   - default mode on the 1,960-reaction model;
   - MATLAB versions other than R2024b Update 8.

Nothing is committed.

## Diff summary

Modified (tracked):
- `src/analysis/topology/reactingMoieties/classifySubgraphIsomorphism.m`: +30/−1 (label-only copies, `labelOnlyCopy`, `NOTE`/`Author`).
- `test/verifiedTests/analysis/testReactingMoieties/testClassifySubgraphIsomorphism.m`: +49 (reference-case and error-case block; purpose and authors).
- `specs/20260921-154310-reacting-moiety-optimisation/reacting-optimisation-reproducibility-results.md`: +33 (rows appended by its own script, T013).
- `CLAUDE.md`, `.specify/feature.json`: plan pointer and active feature.

New (untracked):
- `test/verifiedTests/analysis/testReactingMoieties/data/classifySubgraphIsomorphismReference.mat` (469,912 bytes).
- `specs/20260930-102230-isomorphism-label-only-copies/`: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `quickstart.md`, `tasks.md`, `contracts/classifySubgraphIsomorphism.md`, `checklists/requirements.md`, `research-prototype/` (3 files), `baseline/classifySubgraphIsomorphism.m`, `captureClassifyReference.m`, `isomorphismLabelOnlyCheck.m`, `isomorphismLabelOnlyResults.md`, and this receipt.

Temporary, created and deleted: `specs/20260921-154310-reacting-moiety-optimisation/reactingOptimisationReproducibilityCheckTmpCorpus.m` (corpus path only).

## Tests

All runs used MATLAB R2024b Update 8. Full detail is in `isomorphismLabelOnlyResults.md`.

- **Unchanged helper (T007):** `testClassifySubgraphIsomorphism` PASS. Check self-check identical; calls 39,204 and 122,451 for both helpers.
- **Edited helper:**
  - T010: `testClassifySubgraphIsomorphism` PASS (2.3 s) and `testConservedReactingMoieties` PASS (23.3 s).
  - T011: classification identical, 243.7 → 27.0 s; end to end identical; call counts equal.
- **T012 gate:**
  - first attempt stopped by the background time limit; its equality section passed again (303.2 → 23.9 s);
  - second attempt: runs 1–2 baseline 554.7 / 862.2 s, source 268.6 / 469.5 s, median ratio 0.521; stopped at the user's decision.
  - quiet-machine re-run (2026-10-01 08:41 UTC, `CBT_ILO_TIMING_ONLY=1`, 5 alternating runs, load average 1.7–2.7 on 12 cores): baseline [397.2 527.7 414.4 452.0 438.4] s, source [221.5 207.5 224.5 200.2 224.7] s; median ratio **0.505**, PASS.
- **T013:** 16/16 EQUAL (`ci` in the first run; the other 7 against the moved corpus).
- **T014:** 12/12 `testReactingMoieties` PASS.
- **T015:** static review PASS.

## Unresolved issues

- **Gate:** resolved after the run. The quiet-machine 5-run median is 0.505 (PASS, limit 0.60), confirming the 0.521 accepted under load.
- **Stale corpus path:** resolved after the run. The corpus path was updated to `/media/JACK/repos/ctf/rxns/moiety_rxns/atomMapped_std` (one line each) in `reactingOptimisationReproducibilityCheck.m` and the eight earlier-feature capture/check scripts (021, 022, 029, 20260902, 20260921 build-runtime, 20260928 ×2, 20260929).
- **Carried over:** the `sanityChecks` defect in `identifyIsomorphicClasses.m:34`.
- **Nothing committed:** commit or push only on the user's instruction.

## Other information

- **VII-F:** the practice notes in `specs/20260928-100409-extract-bond-subgraphs-local-peeling/matlab-practice-notes.md` were applied.
- **Deviations recorded in the feature files:**
  - the spec's multi-variable edge case was corrected during research (cell values already raised an error);
  - the check script gained `CBT_ILO_TIMING_ONLY` for the gate re-run;
  - the gate result was accepted at the user's decision;
  - T013 used a temporary path-corrected copy.
- **Post-run gate re-run:** the quiet-machine 5-run gate listed under "Not verified" in the Final response was run on 2026-10-01 after implementation (results in `isomorphismLabelOnlyResults.md`, Timing 08:41 UTC). The Final response above is kept verbatim as delivered.
