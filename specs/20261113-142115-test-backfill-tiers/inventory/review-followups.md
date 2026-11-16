# Follow-ups for the human review (outside this feature's scope)

Collected from the helpers' reports during waves 01–14. None of these is changed by this feature:
it adds tests for untested functions and never edits `src/` or existing tests (beyond the FR-012
defect entries). Items are grouped by what a follow-up change would touch.

## Existing tests that cover one of the new functions under another name (III-Naming)

A second, differently named file now exists for the function, or the legacy file is
multi-function. A later change should merge or rename them so that each function has one test.

| Function | Legacy test | Note |
|---|---|---|
| fvaJaccardIndex | `base/testTools/testJaccardIndex.m` | misnamed, no header |
| getCorrespondingCols, getCorrespondingRows | `analysis/testCorrespondingRowsCols/testCorrespondingRowsCols.m` | tests both functions |
| readNumpyArray, numpyBufferToArray | `base/testIO/testReadPythonFiles.m` | multi-function |
| ecosystem functions | `testEcosystemClustering.m`, `testEcosystemScenarios.m` | multi-function |
| rBioNet_search | `testRBioNetSaveLoad.m` | multi-function |
| formula2mets | `testLoadReaction.m` | multi-function |
| addKeyToKnownHostsCT | `base/testInstall/testAddKeyToKnownHosts.m` | multi-function; its error check passes only because of the gitCmd error |
| convertHypergraphToBipartiteGraph | `testConvertHypergraph2BipartiteGraph.m` | legacy name; defect recorded there (FR-012); the inventory counted the function as untested |
| transformXML2Map | `visualization/testCD/testCD.m` | legacy name; reaches 83 of 120 lines, misses undocumented; running it rewrites the tracked `glycolysisAndTCA_test.xml` (byte-identical afterwards) |
| visualizePathwayInEpistasis | `testVisualizeEpistasis.m` | legacy name; no prepareTest, misses lines 38, 53, 55, leaves a figure open |
| getNullSpace | `analysis/testNullspace/testNullspace.m` | legacy name; misses lines 22, 27, 35-40, 48-49, 57-58; no contract header |
| BDF, CSDF, DBDF, DCA, BDCA, the LM solvers | `testOptimizeVKmodel0.m` | exercises them through optimizeVKmodel0 (own tests now exist) |

## Existing tests with side effects

- `testFitC13Data` regenerates `slvrEMU_fast.m` (and siblings) inside `src/` through Perl on
  every run: a test that rewrites source files.
- `testCD` rewrites a tracked fixture (above).

## Source observations not recorded as defects (no test reaches them, or outside the function)

- `src/analysis/topology/FR/testCombinatorialDependentRows.m` is a source script whose name
  starts with `test`: a harness test of combinatorialDependentRows would clash with it.
- `componentContribution/old/invertProjection.m` (the copy on the MATLAB path; `old/` is outside
  the inventory) gives the same wrong `PL` for tall matrices as the excluded `new/` copy.
- `CSDF`: `nfxk` is never updated inside the loop, so the convergence rules may never fire
  (read, not run; CSDF is quarantined for other defects).
- `getRxnFromKegg`: function name differs from the file name; its output is never assigned
  (excluded: internet).
- `prepareInputData` line 212 reads `GenomeAnnotation.txt` while
  `writeReactionsFromPubSeedSpreadsheets` writes `genomeAnnotation.txt` (case-sensitive file
  systems); noted in prepareInputData's ledger row for its writer.
- metabotools pipeline: `defineUptakeSecretionProfiles` returns slope_cond2/slope_cond1 while
  `calculateQuantitativeDiffs` sorts as if the ratio were inverted, so the cond1/cond2 output
  names come out swapped in the documented pipeline (both functions quarantined for other
  defects); the secretion comments at its lines 102 and 108 contradict the code.
- `ConvexProgram` (excluded: no instance can be built without AdaptiveCholMex): its `LinearProgram`
  path can never run with the shipped `TwoSidedBarrier` (the PolytopeSamplerMatlab class lacks
  `rescale`/`distance`/`remove`; the matching class lives in `papers/2023_BarrierRound/...`, off the
  path), so it stops with 'unsupported now'. A module-level defect with no test file to carry it.
- `prepareTest`: `needsLinux` compares with `'glnx64'` instead of `'glnxa64'` (quarantined; no
  src test uses the option, but any future `needsLinux` test would always skip on Linux).
- Constitution III-Coverage names `buildToyModel1`/`buildToyModel2` as Tier 1 fixtures; no such
  functions exist (tests use `createModel` and `createToyModel*`). A constitution PATCH.

## Environment facts

- Open Babel (`obabel`) is installed but cannot run from MATLAB's `system()` (MATLAB's bundled
  libstdc++ lacks GLIBCXX_3.4.32); `prepareTest('requiredSoftwares', {'obabel'})` would not skip.
- `initCobraToolbox` removes the `src/analysis/thermo/*/new` folders from the path.
- MATLAB's Python has no pyarrow (COBRArrow cannot load); python3 is 3.12.
- Coverage sessions stall on R2025a after roughly 100–125 tests of the Tier 1 set: MATLAB's
  `Connector[#1]` thread spins at 100% in user space (no system call) and the next test or the
  session exit never completes; memory is far below the cap (3.3 GB of 12 GB). The same 129 tests
  run clean in one session without coverage, and 187 other tests run clean under coverage, so the
  full suite (no coverage) is not affected. The campaign's coverage checkpoints are therefore run
  in sessions of about 100 tests, each with a private temporary directory and an idle cap.
- chrrSampler / chrrExpSampler with toRound = 0: samples leave the bounds (minimum -6.1 for [0, 10]);
  the cause is in the external preprocess/genSamples code (reproduction in the wave 16 slice a
  record of chrrExpSampler). fluxVariability reported maxFlux 10 for R_in despite a coupling
  constraint R1 + R2 <= 8 in the chrrSampler set-up (wave 15 slice c record; not verified further).

