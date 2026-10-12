# Implementation Receipt: 026 Tier-1 test coverage batch 2

## Prompt

User: "good build the other 40" (after approving the first 10 tests), with the standing rule: never change any main function; document errors found in main functions and skip them. Run inline via /speckit-implement phases 3 and 4.

## Final response

Implemented all 50 Tier-1 characterization tests of batch 2 (rows 1-50 of the spec table; rows 1-10 were reviewed at the checkpoint). All 50 pass through the harness runner (runScriptFile) and as separate sections under the unit-test runner. Line coverage of the 50 functions is 1351/1407 (96.0%); every uncovered line is a documented exemption in the test header (defect branches, external tools, desktop-only line). No file under src/ was changed and no test creates files. Defects found were documented in the test headers and skipped, not fixed.

## Diff summary

New files: 50 test files under test/verifiedTests/ (folders: analysis/testExploration, testPersephone, testRumba, testSubspaces, testThermo, testTopology, testWholeBody; base/testCardOpt, testIO/testUtilities, testSolvers, testTools; dataIntegration/testChemoInformatics, testFitC13Data, testMetaboAnnotator; design; reconstruction/testDemeter, testModelBorgifier, testModelManipulation; visualization/testReconMap).
Spec folder files: spec.md, plan.md, research.md, data-model.md, quickstart.md, tasks.md, checklists/requirements.md, this receipt.
git diff --stat -- src: empty.

## Tests

Run through runScriptFile (the harness runner) from test/; coverage measured with the unit-test code-coverage plugin per function. Total harness time for all 50: about 2 s.

| Test | Result | Lines covered | Uncovered lines (documented exemptions) |
|---|---|---|---|
| testFindMatchingFieldEntries | passed | 21/21 | - |
| testNumToFormattedString | passed | 32/32 | - |
| testCalculateMetrics | passed | 27/28 | 38 |
| testCompareConditions | passed | 28/28 | - |
| testGmscale | passed | 51/51 | - |
| testReaction2sparse | passed | 26/26 | - |
| testLogmod | passed | 21/21 | - |
| testMaxstar | passed | 44/44 | - |
| testCreateBIGraph | passed | 33/33 | - |
| testCalculateFoodScore | passed | 37/38 | 46 |
| testCompareDiets | passed | 29/30 | 74 |
| testConvertNutrientsToMmol | passed | 28/28 | - |
| testSearcher | passed | 36/57 | 90 91 94 95 99 100 102 105 106 107 113 114 116 117 124 125 126 127 128 130 133 |
| testCalculateBMR | passed | 9/9 | - |
| testCompareMaleFemale | passed | 25/25 | - |
| testEvalObj | passed | 26/26 | - |
| testUpdateObj | passed | 31/31 | - |
| testGetDataBases | passed | 15/15 | - |
| testParseSBMLAnnotationField | passed | 40/40 | - |
| testParseSBMLAnnotationFieldRxn | passed | 14/14 | - |
| testParseSBMLNotesField | passed | 49/49 | - |
| testInitialBDCA | passed | 42/42 | - |
| testStopCritBDCA | passed | 28/33 | 34 35 36 38 39 |
| testInitialDuplo | passed | 44/45 | 122 |
| testStopCritDuplo | passed | 28/33 | 33 34 35 37 38 |
| testInitialization | passed | 33/33 | - |
| testHyperlink | passed | 8/9 | 29 |
| testParseGPR | passed | 23/23 | - |
| testParseMetNames | passed | 11/13 | 36 38 |
| testPreparseGPR | passed | 17/17 | - |
| testCalcDist | passed | 25/25 | - |
| testEditChemicalFormula | passed | 29/29 | - |
| testGetInchiData | passed | 34/34 | - |
| testCombination | passed | 30/30 | - |
| testSolveLin | passed | 20/20 | - |
| testScore_ridge | passed | 20/20 | - |
| testCleanUpMetabolite_structure | passed | 31/31 | - |
| testRemoveSmilesInchiKey | passed | 11/27 | 46 47 48 49 50 51 52 53 56 57 58 59 60 61 62 63 |
| testAnalyzeRxns | passed | 19/19 | - |
| testSeperateTransposeJoinOE | passed | 45/45 | - |
| testCheckInputData | passed | 40/40 | - |
| testMapMediumData2AGORA | passed | 18/18 | - |
| testBuildRxnEquations | passed | 38/39 | 62 |
| testBuildRxnEquationsFromName | passed | 39/40 | 63 |
| testNewCompsNewMets | passed | 16/16 | - |
| testRemoveDuplicateNames | passed | 20/20 | - |
| testCombineChildren | passed | 27/27 | - |
| testConvertIrrevFluxDistribution | passed | 10/10 | - |
| testReassignFwBwMatch | passed | 11/11 | - |
| testMakeColorGradient | passed | 12/12 | - |

Total: 1351/1407 lines (96.0%).

Not verified: CI coverage numbers (Codecov), other MATLAB versions or Octave, the full testAll run.

## Unresolved issues

Defects in source functions, documented in the test headers and skipped (not fixed):
- calculateMetrics: single-taxon Bray-Curtis values are wrong (sum along the row).
- calculateFoodScore: default translation set when nargin < 3 instead of < 4, so calls with fewer than 4 inputs fail.
- compareDiets: direction false errors (cell array multiplied by -1).
- searcher: non-iterative mode unusable (parser requires a cell, code reads a table property).
- createBIGraph: errors when no edges remain after removing the energy node.
- numToFormattedString: width argument ignored for array input.
- getDataBases: third output unassigned and mixed lists return empty results.
- parseSBMLAnnotationField: ChEBI ID keeps a stray "3A" prefix in the urn:miriam notation.
- InitialDuplo: misspelled field name makes the flag_x_error option unusable.
- StopCritBDCA, StopCritDuplo: criterion 1 uses undefined variable nhxk.
- Combination: k = 0 errors.
- getInchiData: negative q-charge gives NaN.
- parseMetNames: mixed or longer-compartment notations fall through to the last pattern (not tested).
- getDefaultValue: struct / function-handle input errors (no final else; not tested).
- buildRxnEquationsFromName: reversed-only reactions list the substrate on both sides.
- makeColorGradient: channels equal in both colours become 0.
- combineChildren: identical generated clauses delete the earlier clause.
- checkInputData: header name listed in removedStrains; equal headers skip the row removal.
- editChemicalFormula: removed elements stay with a zero count.
- removeSmilesInchiKey: generate branches need an external converter (not covered).
- hyperlink: HTML line only reached with the MATLAB desktop (not covered headless).

## Other information

Script tests with %% sections run as separate tests under the unit-test runner; shared variables are defined before the first section. Coverage was measured with a throwaway runner kept outside the repository.
