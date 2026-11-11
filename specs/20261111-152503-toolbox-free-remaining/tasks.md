---
description: "Tasks for the remaining plain-MATLAB toolbox replacements"
---

# Tasks: Plain-MATLAB replacements for the remaining paid-toolbox functions

**Input**: `specs/20261111-152503-toolbox-free-remaining/` — spec.md, plan.md, research.md,
mathworks-semantics.md (G1–G4), data-model.md, contracts/toolboxFree-api.md, quickstart.md

**Tests**: required (Principle III, FR-010–FR-014). One Tier-1 test per new function.

## Procedure for every new function (applies to every task that creates one)

1. Read its section of `mathworks-semantics.md`, its row in `contracts/toolboxFree-api.md`, the
   matching decision in `research.md`, and every call site (spec inventory). Support exactly the
   contract's syntax; any other option/argument → `error('COBRA:<name>:unsupportedOption', ...)`
   naming it.
2. Write `src/base/utilities/toolboxFree/<name>.m` from documented formulas and cited
   publications (never copy MathWorks code), base MATLAB only, openCOBRA help header (USAGE,
   INPUTS, OPTIONAL INPUTS, OUTPUTS, NOTE: "Plain-MATLAB replacement for <MathWorks function>
   (<toolbox>); supported syntaxes ...; semantics: specs/20261111-152503-toolbox-free-remaining/
   mathworks-semantics.md <section>"), `exist`/`isempty` optional arguments, no `evalc`, no
   suppressed warnings, `try/catch` keeps `ME.stack`. Reuse the first-slice functions
   (`cobraNormcdf`, `cobraTcdf`, `cobraTinv`, `cobraChi2cdf`, `cobraFcdf`, `cobraGrp2idx`,
   `cobraPdist`) where they fit.
3. Reference values: compute in `specs/20261111-152503-toolbox-free-remaining/references/<group>.py`
   with the reference virtual environment (SciPy 1.16.3 / statsmodels 0.15.0 / scikit-learn
   1.9.1; run with `python -I`), print full precision, paste into the test with a comment naming
   script, library and version. Use MathWorks documentation numbers wherever published.
4. Test `test/verifiedTests/base/testToolboxFree/test<Name>.m` (Tier 1, `prepareTest()` with no
   arguments; header: purpose, tier, function, references, coverage exemptions, known defects
   "None found." or entries, author/date): one `%%` section per call-site syntax and per edge case
   from the semantics note; the unsupported-option error via `verifyCobraFunctionError`; a parity
   section that runs only when the MathWorks function exists and its licence is available,
   otherwise prints `skipped: <toolbox> not installed`. Tolerances justified in comments. Fixed
   seeds for random code. Figures created invisible and closed.
5. Run the test through the memory-capped MATLAB wrapper (`runScriptFile` + coverage helper):
   it must pass with 100% line coverage of the function or listed exemptions.

**Call-site procedure**: read the whole function first (Principle V); change only the toolbox
call lines (and the lines that consume their outputs when the output type differs); no interface
change; run the call-site file's existing test where its other requirements are met, otherwise
verify statically and say so in the receipt.

**MATLAB resource rule (all tasks)**: MATLAB only through the machine's memory-capped wrapper,
at most three MATLAB sessions at once across all concurrent workers; never raise memory above
6 GB without exclusive mode.

## Phase 1: Setup

- [X] T001 Create the reference scripts skeleton `specs/20261111-152503-toolbox-free-remaining/references/{g1_stats,g2_fit_optim,g3_regression,g4_figures}.py` (shared helper for printing full-precision values) and confirm the reference venv imports scipy, statsmodels, sklearn; try `pip install firthlogist` into it (record success or failure in research.md R7)

## Phase 2: Foundational (blocks US1 and US3)

- [X] T002 [P] Write `cobraTiedrank` (contract G1 §8) and `test/verifiedTests/base/testToolboxFree/testCobraTiedrank.m` (references: scipy.stats.rankdata) — used by cobraRanksum and cobraKruskalwallis
- [X] T003 [P] (no separate engine, analyze C1) `cobraKruskalwallis` is implemented as one-way ANOVA on tied ranks by calling `cobraAnova1` internally and converting to the chi-square statistic, as MathWorks documents; nothing to create in this task beyond confirming the design in research.md R4

## Phase 3: User Story 1 — statistical tests, distributions, utilities (P1)

**Goal**: US1. **Independent test**: every `testCobra*` of this phase passes on base MATLAB; changed call sites' tests pass or are statically verified.

- [X] T004 [P] [US1] `cobraHygecdf` + test (G1 §6; scipy.stats.hypergeom; doc values)
- [X] T005 [P] [US1] `cobraAnova1` + test (G1 §1; doc beam-strength example; scipy f_oneway)
- [X] T006 [P] [US1] `cobraKruskalwallis` + test (after T002, T005; G1 §2; doc example p = 0.0018; scipy kruskal; `tbl` layout incl. empty cells)
- [X] T007 [P] [US1] `cobraRanksum` + test (after T002; G1 §3; doc mileage example p = 0.0043; exact with ties; `'method'` exact/approximate; `stats.ranksum` of the first sample as single switch documented UNCONFIRMED)
- [X] T008 [P] [US1] `cobraTtest2` + test (G1 §4; scipy ttest_ind equal_var=True)
- [X] T009 [P] [US1] `cobraKstest2` + test (G1 §5; positional and name-value; doc example p-values; ks_2samp statistic)
- [X] T010 [P] [US1] `cobraKsdensity` + test (G1 §12; default call only; bandwidth vs doc; values vs NumPy normal-kernel sum on the MATLAB grid)
- [X] T011 [P] [US1] `cobraCmdscale` + test (G1 §13; NumPy eigh reference; compare up to column sign)
- [X] T012 [P] [US1] `cobraConfusionmat` + test (G1 §14; sklearn confusion_matrix with labels; 'Order'/'ORDER'/'order'; missing values)
- [X] T013 [US1] Switch call sites: anova1, kruskalwallis, ranksum in `performStatisticalAnalysis.m`, `retrieveModelStats.m`, `runNonparametricTests.m`, `dimensionalityReductionAndMultivariateAnalysis.m`, `compareTwoSamplesStat.m` (ranksum/ttest2/kstest2), `score_KS.m`; ttest2 in `optimalScores.m` (only that line); hygecdf + `mafdr(...,'BHFDR',true)` → `fdrBHadjustment` in `FEA.m` and `dimensionalityReductionAndMultivariateAnalysis.m`; in `performStatisticalAnalysis.m` replace mafdr only on the `BHFDR=true` path, keep the Storey default path calling `mafdr` (left toolbox-gated, R1) with a clear error naming the Bioinformatics Toolbox when it is absent
- [X] T014 [US1] Switch call sites: tiedrank in `analyseWBMsol.m`; ksdensity in `KLdistance.m`, `discretizeFPKM.m`; cmdscale in `mgSimResCollect.m`, `plotMappingInfo.m`, `dimensionalityReductionAndMultivariateAnalysis.m`; confusionmat in `modelPredictiveCapacity.m`, `quanQualAcc.m`, `plotThermoKernelExtractStats.m`, `plotThermoKernelStats.m`
- [X] T015 [US1] Base substitutions (research R3): geomean in `createContextSpecificModel.m`, `estimateDfGt0.m`, `estimateDrGt0.m`; normrnd in `eFlux.m`, `SWIFTCORE/core.m`; `range` → `max-min` in `SWIFTCORE/partition.m`; `dataset` export in `generateIsotopomerSolver.m` → `fopen`/`fprintf` byte-identical (compare against the documented dataset export format in G1 §15)
- [X] T016 [US1] (partition, analyseWBMsol, mgSimResCollect done; the runPersephone gate is lifted in T034 once fitglm/fitlm are replaced) Licence guards (FR-008a): remove `assert(license(...bioinformatics...))` in `partition.m:34`; remove the Statistics guard around tiedrank in `analyseWBMsol.m:205`; remove the `noPcoa` Statistics guard in `mgSimResCollect.m:115`; leave `initPersephone` and its `statToolboxInstalled` output unchanged (public interface, analyze I1); first trace every function `performStatsPersephone` reaches and, only if all are replaced or guarded, stop gating `runPersephone.m:315` on `statToolboxInstalled` (otherwise record why it stays); make `performRegressions` raise an error naming the Statistics Toolbox only when a mixed-effects formula is given without it

## Phase 4: User Story 2 — curve fit and optimizers (P1)

**Goal**: US2. **Independent test**: optimizer tests reach known optima; Gaussian fit matches SciPy; testRFASTCORMICS, testOptGene pass on base MATLAB.

- [X] T017 [P] [US2] `cobraFitGauss1` + test (G2 §1; scipy.optimize.curve_fit method='trf' with the same bounds/start points; realistic FPKM-like density data for both left and right fits; gof fields)
- [X] T018 [US2] Switch `createFitL.m`, `createFitR.m` to `cobraFitGauss1`; in `discretizeFPKM.m` replace `plot(fit, ...)` under `figflag` by plotting `fitresult.f` over the current x-limits; keep `.b1`/`.c1` reads unchanged
- [X] T019 [P] [US2] `cobraFminunc` + test (G2 §2; trust-region Newton with user gradient and Hessian, Steihaug–Toint CG; Rosenbrock, convex quadratics, BDCA-like subproblem; scipy.optimize.minimize trust-ncg/trust-exact references; option names current and legacy; exit flags)
- [X] T020 [US2] Switch `BDCA.m`, `DCA.m`: `optimoptions('fminunc',...)` → options struct, `fminunc` → `cobraFminunc`; run any existing varKin test, else verify on a small kinetic problem in the receipt
- [X] T021 [P] [US2] `cobraGa` + test (G2 §4; OneMax and enumerable knapsack optima; seeded reproducibility with generation-based stopping; subpopulations and migration; custom creation/crossover/mutation; vectorized fitness; exit flags and `output` fields; `PlotFcns` error)
- [X] T022 [US2] Switch `optGene.m` (reference for "same objective", analyze A1: the objective of the knock-out set found is compared with an independent optimum of testOptGene's problem — exhaustive enumeration of knock-out sets up to the test's size limit with the LP solver — or with the documented optimum if the test states one): `gaoptimset` → options struct, `ga` → `cobraGa`, drop the four Global-Optimization plot functions (document in the header); remove `gads_toolbox` from `testOptGene.m` and run it on base MATLAB (check the population row indexing at line 53)

## Phase 5: User Story 6 — tests that only needed a toolbox (P1)

**Goal**: US6. **Independent test**: each changed test runs on base MATLAB (or statically verified where it needs CPLEX) and passes.

- [X] T023 [US6] (after T004, T013) testFEA: `hygecdf` at line 76 → `cobraHygecdf`; remove bioinformatics and statistics requirements; run
- [X] T024 [US6] (after T015, T016) testSWIFTCORE (`randsample` → `randperm(n,k)'`), testPartition: remove requirements; run both
- [X] T025 [US6] (after T015) testEFlux: parse the two GEO SOFT tables with a local function in the test (block between `!sample_table_begin` and `!sample_table_end`; ID_REF, VALUE); remove `bioinformatics_toolbox`, keep `needsWebAddress`; run
- [X] T026 [US6] testSammi (`randsample` → `randperm` at lines 151, 156, 186), testCreatePanModels (malformed `'Statistics Toolbox'` key corrected to `statistics_toolbox` and kept: the external violinplot calls ksdensity, found by running it), testMoieties (remove the dead `if 0` requirement block): remove requirements; run
- [X] T027 [US6] (after T010, T017, T018) testRFASTCORMICS: remove `statistics_toolbox` and the `assert(ver('curvefit'))`; add a `discretizeFPKM` section (with `figflag` off) asserting the discretization thresholds against values computed from the SciPy reference of T017; run
- [X] T028 [US6] testBiomassPrecursorCheck: remove the requirement; run; the line-91 failure turned out to be the stale biomass identifier `Biomass_Ecoli_core_N(w/GAM)-Nmet2` (now `Biomass_Ecoli_core_w_GAM`), so only BIOMASS2 was the objective; identifier corrected in the test, no source defect; test passes
- [X] T029 [US6] (after T014, T016) testMgPipe: remove `statistics_toolbox` (keep `ibm_cplex`); verify statically that the reached path (mgSimResCollect cmdscale) no longer needs a toolbox
- [X] T030 [US6] testSampleCbModel, testSampleCbModelRHMC, testConnectedComponents (and testCreatePanModels, T026): keep the requirement; add to each header the external function that needs the toolbox and the reason (external/ read-only)

## Phase 6: User Story 3 — regression and SVM (P2)

**Goal**: US3. **Independent test**: fits match statsmodels / doc numbers; model objects expose the MathWorks property layout; performRegressions runs on base MATLAB for non-mixed formulas.

- [X] T031 [US3] Public helpers `src/base/utilities/toolboxFree/cobraParseModelFormula.m` and `cobraBuildModelDesign.m`, each with its own test `testCobraParseModelFormula.m`, `testCobraBuildModelDesign.m` (III-Naming; analyze C1) (G3 §6: `y ~ t1 + t2`, `*`, `:`, `-`; numeric, logical, cellstr, string, categorical predictors; reference level = first appearance for text, first category for categorical; NaN rows excluded; MathWorks coefficient names and order)
- [X] T032 [US3] `cobraLinearModel` (classdef) + `cobraFitlm` + tests `testCobraLinearModel.m`, `testCobraFitlm.m` (data-model.md; statsmodels OLS; rank-deficiency warning `COBRA:cobraFitlm:RankDeficient`; `coefCI`, `predict`, `disp`; unsupported method error)
- [X] T033 [US3] `cobraGeneralizedLinearModel` (classdef) + `cobraFitglm` + tests `testCobraGeneralizedLinearModel.m`, `testCobraFitglm.m` (G3 §2: IRLS normal/binomial, Firth modified score; doc logistic example on base-MATLAB `patients.mat` reproduced; statsmodels GLM; firthlogist or NumPy Firth reference; coefCI t(DFE) with the published Poisson CI check; warnings exactly where MathWorks warns: iteration limit, perfect separation without penalty, rank deficiency — and no others)
- [X] T034 [US3] Switch `performRegressions.m` (non-mixed path → `cobraFitglm`, `coefCI` stays as method call; mixed path unchanged, gated per T016), `CreateClusterAndRAtables.m` and `dimensionalityReductionAndMultivariateAnalysis.m` (`fitlm` → `cobraFitlm`); update `performRegressions` help: second output holds `cobraGeneralizedLinearModel` objects without the toolbox (same properties; class name differs); add a performRegressions section to an existing PERSEPHONE test if one exists, else verify with a small table in the receipt
- [X] T035 [P] [US3] `cobraFitcsvm` + test (G3 §7; SMO with Fan–Chen–Lin working-set selection; sklearn SVC(kernel='linear', C=1) Beta within tolerance; class order); switch the `fitcsvm` line in `optimalScores.m`

## Phase 7: User Story 4 — figures (P2)

**Goal**: US4. **Independent test**: headless figure tests assert groups, order, labels, CData, colour limits, node/edge sets.

- [X] T036 [P] [US4] `cobraBoxplot` + test (G4 A1; tags 'Box'/'Median'/whiskers/outliers; MathWorks quartile and whisker rule); switch `makeViolinPlots.m` boxplot path
- [X] T037 [P] [US4] `cobraOptimalLeafOrder` + test (Bar-Joseph et al. 2001; brute-force optimal order on small trees as reference) then `cobraClustergram` + test (G4 A4; uses `computeEcosystemLinkage`, `cobraPdist`); switch `correlateFluxWithTaxonAbundance.m`, `summarizeFeaturesOnTaxonLevels.m`
- [X] T038 [US4] `plotEssentialRxns.m`: `HeatMap(...)` → base `heatmap` with the same labels, colormap and colour limits; drop the overwritten `redbluecmap`; `model_stats.m:393`: `gname` → `dataTipTextRow` on the plotted line; `plotThermoKernelExtractStats.m`: remove the dead `plotconfusion` branch
- [X] T039 [US4] `bio_draw_by_rxn.m`: replace the biograph drawing block (lines ~448–612) with `digraph` + `plot` + `outedges`/`inedges` + `highlight`; outputs unchanged; remove the `exist('biograph')` self-skip in `testPaint4Net_bio_draw_by_rxn.m` and `testPaint4Net_bio_draw_by_met.m`; run both

## Phase 8: User Story 5 — parallel leftovers (P2)

- [X] T040 [US5] `fastFVA.m:529`: guard `getCurrentTask` with `isParallelToolboxAvailable`; task ID 1 when `t` is empty; `SteadyComPOAgr.m:586`: explicit guard so the `spmd`/`Composite`/`lab*` branch runs only with the toolbox and an open pool, else the existing serial branch; `testSteadyCom.m`: `parWorks = isParallelToolboxAvailable()` before `parcluster`, remove `statistics_toolbox`; run testSteadyCom (testFastFVA needs CPLEX: static)

## Phase 9: User Story 7 — review (P3)

- [X] T041 [US7] Independent review of every new function and call-site change (Codex read-only if the account accepts a model, else independent reviewer agents given only code, tests and mathworks-semantics.md); record findings and resolutions in `specs/20261111-152503-toolbox-free-remaining/review.md`
- [X] T042 [US7] Fix or answer every finding; re-run affected tests

## Phase 10: Polish

- [X] T043 Record every pre-existing defect found (research R9) in the covering test headers (III-Defects format); regenerate `test/known-defects.md` with its generator
- [X] T044 Re-run `references/scanUnresolved.m` (SC-001): only left-gated call sites and the `matlab` solver backend remain; record the output summary in the receipt
- [X] T045 Run all new tests in one MATLAB session with coverage (SC-002, FR-011); re-run existing tests of every changed call-site file that can run here (SC-005)
- [ ] T046 Full test suite on base MATLAB + Gurobi (SC-003): count skips by reason; exactly four toolbox skips
- [ ] T047 Write `agent-runs/<UTC>-implement/implementation-receipt.md` (Prompt, Final response, Diff summary, Tests, Unresolved issues)
- [ ] T048 Scan staged files for machine paths, keys, licences and private names; commit as the maintainer (no co-author line; never the submodule pointers `binary`, `papers`, `tutorials`, `test/models`, `external/analysis/octave-networks-toolbox`); push the branch to `origin` with upstream tracking

## Dependencies & Execution Order

- T001 first. T002, T003 before T005–T007. Function tasks before their call-site tasks
  (T013 after T004–T009; T014 after T010–T012; T018 after T017; T020 after T019; T022 after T021;
  T034 after T031–T033). US6 test tasks after the call sites they exercise (noted inline).
- US3 (T031→T032→T033→T034) and US4 (T036–T039) are independent of US1/US2 apart from shared
  first-slice functions; US5 (T040) independent.
- Review (T041–T042) after all implementation; polish last; T046 after everything else but T047–T048.

## Parallel opportunities

- Phase 2–3 functions: T002, T003, T004, T008, T009, T010, T011, T012 together; then T005–T007.
- T017, T019, T021 (US2 functions) in parallel with US1 functions.
- T035, T036, T037 in parallel with US3's T031–T033 chain.
- Constraint: at most three MATLAB sessions at once across all workers.

## Implementation strategy

MVP = Phases 1–5 (US1, US2, US6: statistics, fit/optimizers, test requirements), which remove the
largest share of skips. Then US3, US4, US5; review and polish. One PR at the end (maintainer
decision).
