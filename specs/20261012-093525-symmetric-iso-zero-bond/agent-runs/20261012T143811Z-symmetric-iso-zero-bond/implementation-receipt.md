# Implementation receipt: 20261012-093525-symmetric-iso-zero-bond

## Prompt

`/speckit-implement` (no arguments), run on branch `20261012-093525-symmetric-iso-zero-bond` against `specs/20261012-093525-symmetric-iso-zero-bond/tasks.md` (T001–T019).

User interactions during the run:
- a usage-limit pause, then "continue";
- "progress?";
- the gate decision "Optimise, then measure", given when the exact test as planned measured far over the SC-005 limit.

## Final response

The feature is finished: all 19 tasks are done and nothing is committed. Both blockers are fixed. Unlabelled classification is now exact and about 34% faster than before. RXN reactions with no bonds can be read and built.

| Check | Result |
|---|---|
| SC-001: stored 318-node pair | One class in at most 0.039 s (N = 3; limit 5 s). `isisomorphic` did not return within 60 min. |
| SC-002: tests | All 13 `testReactingMoieties` tests pass. That includes 150 classification reference cases with their call counts and the golden `testConservedReactingMoieties`. |
| SC-003: reconXmoieties, H-free corpus, moiety graphs on | pufa n = 514: identify 27.0 s (did not finish in 30 min before). Full pufa subsystem: identify 26.2 s, 271 moieties, 3,736 moiety graphs. Both have max\|L·N\| = 0 and 0 fallbacks. |
| SC-004: zero-bond reactions | Water and KCl transports read with an empty, correctly typed bond table, and a model containing water transport builds with zero decomposition residuals. |
| SC-005: classification time, 1,960-reaction model | Median 6.44 s against 9.79 s, a ratio of **0.658** (limit 1.10). Classification and candidate-pair count (49,009) are identical, with 0 fallbacks. |
| Exactness | 0 mismatches against `isisomorphic` on 3,000 random small graphs (simple, multigraph, self-loops, directed, cycles) and on 43,947 real pairs. |

**What changed**
- **`classifySubgraphIsomorphism.m`:** unlabelled pairs of the same graph class are decided in this order:
  1. identical edge lists are isomorphic by the identity map; this covers 78% of the pairs;
  2. a certificate computed once per subgraph (node hashes after four refinement rounds) rejects non-isomorphic pairs;
  3. joint colour refinement seeded with those hashes;
  4. a verified greedy individualisation pass;
  5. an exact individualisation-refinement search, falling back to `isisomorphic` after 1e5 search nodes.

  Fallbacks are counted by the new `'getFallbackCount'` action, which `'resetCallCount'` resets. Labelled calls are unchanged.
- **`readABRXNFile.m`:** a reaction with no bonds returns an empty bond table with the usual variables and types.
- **Not in the plan's file list:**
  - `checkABRXNFiles.m`: `max([])` turned the bond-transition total empty. It is now `max([0; …])`, and `testCheckABRXNFiles` has a new zero-bond assertion.
  - `buildAtomAndBondTransitionMultigraph.m`: `BTi2R` is now sized by bond-mapped reactions, not atom-mapped ones. The two counts are identical unless a reaction has no bonds, so existing outputs are unchanged.
- **Tests:** new `testReadABRXNFile.m`, and new cases in the classification, builder and `checkABRXNFiles` tests.
- **Fixtures:** the stored pair (5 KB), three implicit-H RXN files, and a `readABRXNFile` reference (6 KB).
- **`KNOWN_ISSUES.md`:** KI-001 is updated with the hydrogen-removal evidence, the second mechanism, what this feature fixes, and what stays open.

**Things you should know**
1. **The plan's algorithm was not enough.** The exact test as planned was correct but measured 2.61× slower than the baseline. At your choice, I optimised it (identity fast path, certificates, worklist refinement, greedy pass). Each change keeps the answer exact. All of this is recorded in `research.md` R9.
2. **`.gitignore` now ignores `/results/`.** The plan assumed it already did; it didn't.
3. **Load during timing:** T003 ran while one of your reconXmoieties MATLAB jobs was running (load 5–9). T011 alternates baseline and source runs, so the ratio holds.
4. **Not verified:**
  - MATLAB versions other than R2024b;
  - labelled-mode performance, which is unchanged by design;
  - networks other than pufa and the 1,960-reaction model;
  - zero-bond reactions inside the full pufa run, which the reconXmoieties script still excludes.

## Diff summary

Modified (tracked):
- `src/analysis/topology/reactingMoieties/classifySubgraphIsomorphism.m` (+370/−~10): exact unlabelled test (local functions `multiplicityAdjacency`, `isIsomorphicByRefinement`, `individualisationLevel`, `isMappedByColours`, `refineColours`, `colourWeights`, `refinementCertificate`), identity fast path, fallback counter and `'getFallbackCount'`, help NOTE and Author.
- `src/analysis/topology/reactingMoieties/readABRXNFile.m` (+15): typed empty bond columns; element columns created before the bond loop; provenance.
- `src/analysis/topology/reactingMoieties/checkABRXNFiles.m` (+5/−1): `nBondTransitions = max([0; bondTransitionNrs(:)])`; provenance.
- `src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m` (+7/−1): `BTi2R` columns = `nBondMappedRxns`; help line and provenance.
- `src/analysis/topology/reactingMoieties/KNOWN_ISSUES.md` (+36/−1): KI-001 update.
- `test/verifiedTests/analysis/testReactingMoieties/testClassifySubgraphIsomorphism.m` (+123): cases (a)–(f), header.
- `test/verifiedTests/analysis/testReactingMoieties/testBuildAtomAndBondTransitionMultigraph.m` (+38): zero-bond model case (g), header.
- `test/verifiedTests/analysis/testReactingMoieties/testCheckABRXNFiles.m` (+16): zero-bond count assertion, header.
- `.gitignore` (+3): `/results/`.
- `specs/20261012-093525-symmetric-iso-zero-bond/tasks.md` (all tasks `[X]`), `research.md` (+R9).

New (untracked):
- `test/verifiedTests/analysis/testReactingMoieties/testReadABRXNFile.m`
- `test/verifiedTests/analysis/testReactingMoieties/data/nearSymmetricBondComponentPair.mat` (5,463 bytes; `g1`, `g2` from reconXmoieties `lastUnlabelledPair_noH.mat`)
- `test/verifiedTests/analysis/testReactingMoieties/data/readABRXNFileReference.mat` (6,167 bytes; develop-captured tables)
- `test/verifiedTests/analysis/testReactingMoieties/data/rxn/{H2Ot,KCLt,ETOHt}_implicitH.rxn`
- `specs/20261012-093525-symmetric-iso-zero-bond/`:
  - `baseline/classifySubgraphIsomorphism.m` (verbatim f1581781c);
  - `captureBaseline.m`, `symmetricIsoTimingCheck.m`, `externalPufaCheck.sh`;
  - this receipt.

Generated, gitignored (`results/20261012-093525-symmetric-iso-zero-bond/`): baseline and after test/timing `.mat` files, logs, `n1960-bondEdgeLists.mat` (23 MB edge-list cache), `pairlog.mat`. A 38 GB `-v7.3` graph cache created during profiling was deleted.

## Tests

All runs used MATLAB R2024b on Linux.

- **T003 (develop f1581781c, before any source edit):**
  - 12/12 `testReactingMoieties` pass;
  - unlabelled classification of 44,631 bond-mapping components (49,009 candidate pairs): [16.35 14.38 12.51] s, median 14.38 s.
- **T015:** `testReadABRXNFile`, `testBuildAtomAndBondTransitionMultigraph`, `testCheckABRXNFiles`, `testAddBondMappingsRXNFile` and `testConservedReactingMoieties` pass. Two earlier failures were fixed: the `isSubstrate` type, and the `checkABRXNFiles`/`BTi2R` defects.
- **T010 (final source):** 13/13 `testReactingMoieties` pass.
- **Random check:** 3,000 cases, 0 mismatches against `isisomorphic`. A 200-node cycle against two 100-node cycles is decided correctly in 0.71 s. 0 fallbacks.
- **T011 (final source; N = 3, alternating baseline and source, load ~2):**
  - SC-001: [0.039 0.005 0.012] s;
  - SC-005: baseline [9.79 9.73 9.85] s, source [6.65 6.44 6.39] s; ratio 0.658, PASS;
  - classification identical to the baseline helper and to T003; 49,009/49,009 candidate pairs; 0 fallbacks.
  - An earlier T011 run of the unoptimised exact test gave 2.61 (FAIL) and led to the R9 optimisation.
- **T017:**
  - pufa n = 514: finished, identify 27.0 s, 297 moieties, 2,349 graphs;
  - full pufa: finished, identify 26.2 s, 271 moieties, 3,736 graphs;
  - both: max|L·N| = 0, 0 fallbacks; helper path confirmed as this branch.

## Unresolved issues

- KI-001 consequence 2 (hydrogen over-splitting with explicit hydrogens) stays open by design (FR-009; reconXmoieties spec 033).
- Whether other networks' components exceed the 1e5 search-node budget is unknown; the fallback count reports it.
- Nothing is committed: commit or push only on the user's instruction.

## Other information

- **VII-F:** no MATLAB-conventions skill is registered. I applied the practice notes from `specs/20260928-100409-extract-bond-subgraphs-local-peeling/matlab-practice-notes.md`.
- **T004:** no `evalc`, warnings visible, no try/catch added, no `nargin` in the edited files.
- **Scope deviations recorded in `research.md` R9:**
  - the extra edit to `checkABRXNFiles.m`;
  - the `BTi2R` fix, placed where T015 directed;
  - the identity fast path, certificates and greedy pass beyond R1–R3, approved by the maintainer's "optimise, then measure".
- **Post-run regression checks against develop f1581781c.** These were requested by the maintainer before committing (2026-10-12, 14:45–15:23 UTC). Script: `regressionChecks.m`; log: `results/20261012-093525-symmetric-iso-zero-bond/regressionChecks.log`; develop copies in `baseline/readerBuilder/`. All three pass:
  1. *End to end*: `identifyConservedReactingMoieties` on the 1,960-reaction model (conserved-only, moiety graphs on) was compared with the golden outputs of feature 20260928-100409.
     - `arm` (every field, 30,999 moiety graphs), `moietyFormulae` and `reacting` are identical;
     - total classification calls are 122,451, the same as feature 20260930; 0 fallbacks.
  2. *Builder*: `buildAtomAndBondTransitionMultigraph` on the same model and the std corpus. All 12 outputs are identical in value, class and sparsity (develop 397.2 s, source 401.9 s).
  3. *Reader*: `readABRXNFile` on all 17,072 std-corpus RXN files gives identical atoms and bonds tables for every file, with no errors in either version.

  The Final response above is kept verbatim as delivered.
