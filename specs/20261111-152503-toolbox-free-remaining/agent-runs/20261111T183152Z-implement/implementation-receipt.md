# Implementation receipt — 20261111-152503-toolbox-free-remaining

## Prompt

"In the step that we tried to remove the dependency of the codes to propriotery softwares and paid
toolboxes when I made the pull request there were still dozens of tests that were being skipped.
Why is that? ..." — "ok lets do the remaining do every remaining dependent function" — answers to
the clarifications (one spec, one PR; same algorithm class and same optimum for the optimizers;
`external/` untouched; statsmodels and scikit-learn as references; "if for any toolbox the results
dont match we skip them"; the second output of performRegressions must keep working: "cant we
rebuild exactly what the statistics toolbox return?") — "do the tasks and implementation your self
and then push it to my branch".

Run by `/speckit-implement` inline; three independent reviewer agents reviewed the code (Codex
unavailable, see below).

## Final response

`src/` (outside `old/` and `deprecated/`) now runs on base MATLAB for every toolbox function of the
inventory except five call sites left toolbox-gated because a faithful replacement could not be
shown to match: `mafdr`'s Storey default (performStatisticalAnalysis says so), `tsne`/`gscatter`
(producetSNEPlots), `fitglme` (performRegressions raises a clear error for mixed formulas only),
`fminunc`/`fmincon` in optimalScores, and `syms`/`pretty` in checkFullRowRankFRK. 23 new files in
`src/base/utilities/toolboxFree/` (21 functions, 2 model classes) replace anova1, kruskalwallis,
ranksum, ttest2, kstest2, hygecdf, tiedrank, ksdensity, cmdscale, confusionmat, fit('gauss1'),
fminunc (trust-region Newton), ga, fitcsvm, fitglm (incl. Firth), fitlm, boxplot, clustergram and
optimalleaforder; base MATLAB replaces geomean, normrnd, randsample, dataset, gname, HeatMap,
biograph and plotconfusion where exact. performRegressions' second output is a
`cobraGeneralizedLinearModel` with the MathWorks property names, layouts and values (only the class
name and Formula-as-text differ). Each new function has a Tier-1 test (100% line coverage or
documented exemptions) against MathWorks documentation examples, SciPy / statsmodels /
scikit-learn references and, where the toolbox is installed, a parity section.

## Diff summary

Branch `20261111-152503-toolbox-free-remaining`, 8 commits on upstream/develop `62812e7a4`.

- New: 23 files in `src/base/utilities/toolboxFree/`; 23 tests in
  `test/verifiedTests/base/testToolboxFree/`; `testRFASTCORMICS/testDiscretizeFPKM.m` (split from
  testRFASTCORMICS, needs no solver); feature folder (spec, plan, research, data model, contract,
  `mathworks-semantics.md`, `references/` scripts, `review.md`, this receipt).
- Changed call sites (41 files in `src/`): FEA, KLdistance, discretizeFPKM, createFitL/R, BDCA, DCA,
  optGene, optimalScores (ttest2, fitcsvm), performStatisticalAnalysis, retrieveModelStats,
  runNonparametricTests, dimensionalityReductionAndMultivariateAnalysis, compareTwoSamplesStat,
  score_KS, mgSimResCollect, plotMappingInfo, modelPredictiveCapacity, quanQualAcc,
  plotThermoKernelStats, plotThermoKernelExtractStats, analyseWBMsol, generateIsotopomerSolver,
  estimateDfGt0/DrGt0, createContextSpecificModel, eFlux, SWIFTCORE core and partition,
  performRegressions, CreateClusterAndRAtables, runPersephone, initPersephone, makeViolinPlots,
  correlateFluxWithTaxonAbundance, summarizeFeaturesOnTaxonLevels, plotEssentialRxns, model_stats,
  bio_draw_by_rxn, fastFVA, SteadyComPOAgr. No public interface changed.
- Existing tests: toolbox requirements removed from testRFASTCORMICS, testSWIFTCORE, testPartition,
  testSammi, testFEA, testMgPipe, testOptGene, testEFlux, testMoieties, testSteadyCom,
  testBiomassPrecursorCheck, testPaint4Net_bio_draw_by_rxn/_met (biograph self-skips);
  testOptimizeVKmodel0 gains a DCA/BDCA section. Kept, with the reason in the header:
  testSampleCbModel and testSampleCbModelRHMC (`external/` samplers), testCreatePanModels (external
  violinplot calls ksdensity), testConnectedComponents (bwlabel).
- `test/known-defects.md` regenerated (253 defects). `old/`, `deprecated/` and `external/`
  untouched; submodule pointers not committed.

## Tests

- SC-001 (`references/scanUnresolved.m`, re-run 2026-11-11 on R2025a without Statistics, Curve
  Fitting, Optimization, Global Optimization, Bioinformatics, Symbolic Math or Deep Learning
  toolboxes): toolbox names left in `src/` are exactly the five left-gated call sites above and the
  optional `matlab` solver backend (linprog, fmincon, optimoptions in solveCobraLP/solveCobraNLP);
  in `test/` only the parity sections of the testCobra* tests, which run only where the toolbox is
  installed.
- SC-002 (one session, line coverage): 23/23 new tests passed; 100% of executable lines covered
  except the documented exemptions (cobraFitGauss1: 11 safeguard lines; cobraFitglm: line 279, the
  Firth iteration limit). testDiscretizeFPKM passed (counts 1052/992/956, Tier 5).
- performRegressions end to end (scratch script, no test reaches it): binomial (Firth) and normal
  models fitted, the table and the second output read with the right types; a mixed formula raises
  the error naming fitglme.
- Static checks (cannot run here): optimalScores' fitcsvm/ttest2 lines (the rest of the function
  still needs fminunc/fmincon) and fastFVA's `getCurrentTask` guard (fastFVA needs CPLEX).
  SteadyComPOAgr's `spmd` guard was run: testSteadyCom passed with Parallel Computing installed
  and with it hidden.
- SC-003 full suite (`runTestSuite`, full mode, R2025a + Gurobi, no
  toolboxes, 2026-11-11): 629 tests, 598 passed, 28 skipped, 3 failed.
  - Toolbox skips: exactly four, as specified: testSampleCbModel, testSampleCbModelRHMC
    (statistics_toolbox), testCreatePanModels (statistics_toolbox), testConnectedComponents
    (image_toolbox).
  - Other skips (24): CPLEX (13, incl. testFastFVA, testMgPipe, testGeneMCS), MOSEK (3), NLP or EP
    solver (4), Minos/csh (1), cxcalc (1), and two web services (testEFlux: GEO returns a
    reCAPTCHA page; testReconMap: the MINERVA server refuses the test account).
  - Failures (3), none caused by this branch (`matlab.codetools.requiredFilesAndProducts` finds no
    file changed on the branch among their dependencies): testClassifySubgraphIsomorphism and
    testExtractBondSubgraphs compare MATLAB error identifiers recorded with another MATLAB release
    (R2025a raises different ones); testGenerateFullRowRankFR cannot read
    `Recon3DModel_301_xomics_input.mat`, which in this machine's `test/models` checkout is an HTML
    page saved by a failed download.

## Unresolved issues

- Codex review not run: the ChatGPT account of this machine rejected every model on 2026-11-11;
  three independent reviewer agents reviewed instead (`review.md`, 25 findings fixed or answered).
  Repeat with Codex when the account works.
- Parity with the MathWorks functions not run here (no toolboxes); the parity sections settle the
  items marked UNCONFIRMED in the headers, chiefly: ranksum's rank sum of the smaller sample
  (R14 source), ksdensity's kernel cut-off for n*m > 3e4 (R14), Firth standard errors, fitcsvm's
  bias, the boxplot quartile rule, and the clustergram colour range.
- Left toolbox-gated (spec, "Out of scope"): mafdr Storey, tsne/gscatter, fitglme,
  fminunc/fmincon in optimalScores, syms/pretty.
- Pre-existing defects found and not fixed (III-Defects; research R9): optimalScores `'exp'`
  argument count; summarizeFeaturesOnTaxonLevels:126 `ddataByFeature` undefined;
  retrieveModelStats:108 operator precedence; createContextSpecificModel calls undefined
  `findTranscriptionValue`; checkFullRowRankFRK:6 `makeLoopToyModel` missing; producetSNEPlots:263
  and 246–248; testFitC13Data:20 `solverPkgs`; gpSampler:205 `ACHRSamplerDistributedGeneral`
  missing; correlateFluxWithTaxonAbundance NaN correlations; plotThermoKernelExtractStats and
  `bio_findNearRxns` names differ from their file names; FEA with an empty rxnSet (testFEA header).
- testClassifySubgraphIsomorphism and testExtractBondSubgraphs fail on R2025a (error identifiers
  of another release); follow-up outside this feature.
- testEFlux downloads GEO data; NCBI currently answers with a reCAPTCHA page, so the test reports a
  missing web requirement and skips.
