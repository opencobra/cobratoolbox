# Feature Specification: Plain-MATLAB replacements for the remaining paid-toolbox functions

**Feature Branch**: `20261111-152503-toolbox-free-remaining` (from `upstream/develop` at 62812e7a4)

**Created**: 2026-11-11

**Status**: Draft

**Input**: User description: "ok lets do the remaining do every remaining dependent function"
(after reviewing why tests of PR #2720 still skipped). Second and final slice after
`specs/20261103-120403-toolbox-free-replacements`.

## Why

PR #2720 replaced the Parallel Computing pool calls and 16 Statistics functions, but a run on
base MATLAB still skips dozens of tests, and about 45 source files still fail without a paid
toolbox. A MATLAB call-graph scan (2026-11-11, `getcallinfo` over `src/` and
`test/verifiedTests/`, base MATLAB R2025a plus Parallel Computing; names that do not resolve
on that installation, filtered to MathWorks toolbox functions) found the inventory below. The
goal is that `src/` (outside `old/` and `deprecated/`) runs on base MATLAB, and that every test
whose only reason to skip is a paid toolbox runs.

## Scope

### Inventory (call sites in `src/` outside `old/`/`deprecated/`, unless marked *test*)

| Toolbox | Function | Call sites |
|---|---|---|
| Statistics | `anova1` | performStatisticalAnalysis |
| Statistics | `kruskalwallis` | performStatisticalAnalysis, retrieveModelStats, dimensionalityReductionAndMultivariateAnalysis, runNonparametricTests |
| Statistics | `ranksum` | performStatisticalAnalysis, retrieveModelStats, runNonparametricTests, compareTwoSamplesStat |
| Statistics | `ttest2` | compareTwoSamplesStat, optimalScores |
| Statistics | `kstest2` | compareTwoSamplesStat, score_KS |
| Statistics | `hygecdf` | FEA; *test* testFEA |
| Statistics | `geomean` | createContextSpecificModel, estimateDfGt0, estimateDrGt0 |
| Statistics | `tiedrank` | analyseWBMsol |
| Statistics | `normrnd` | eFlux, SWIFTCORE/core |
| Statistics | `randsample` | *test* testSWIFTCORE, testSammi |
| Statistics | `ksdensity` | KLdistance, discretizeFPKM |
| Statistics | `cmdscale` | mgSimResCollect, plotMappingInfo, dimensionalityReductionAndMultivariateAnalysis |
| Statistics | `confusionmat` | modelPredictiveCapacity, quanQualAcc, plotThermoKernelExtractStats, plotThermoKernelStats |
| Statistics | `dataset` | generateIsotopomerSolver |
| Statistics | `fitlm` (+ `coefCI`) | CreateClusterAndRAtables, dimensionalityReductionAndMultivariateAnalysis, performRegressions |
| Statistics | `fitglm` (incl. Firth `'LikelihoodPenalty','jeffreys-prior'`) | performRegressions |
| Statistics | `fitglme` | performRegressions |
| Statistics | `fitcsvm` | optimalScores |
| Statistics | `tsne` | producetSNEPlots |
| Statistics (plots) | `boxplot`, `gscatter`, `gname` | makeViolinPlots, producetSNEPlots, rBioNet model_stats |
| Bioinformatics | `mafdr` | FEA, performStatisticalAnalysis, dimensionalityReductionAndMultivariateAnalysis |
| Bioinformatics | `clustergram`, `redbluecmap` | correlateFluxWithTaxonAbundance, summarizeFeaturesOnTaxonLevels, plotEssentialRxns |
| Bioinformatics | `biograph`, `getedgesbynodeid` | bio_paint4Net bio_draw_by_rxn |
| Bioinformatics | `geosoftread` | *test* testEFlux |
| Curve Fitting | `fit`, `fittype('gauss1')`, `fitoptions`, `prepareCurveData` | rFASTCORMICS createFitL, createFitR |
| Optimization | `fminunc` (trust-region, user gradient and Hessian), `optimoptions` | varKin BDCA, DCA |
| Optimization | `fminunc`, `fmincon` | modelBorgifier optimalScores |
| Global Optimization | `ga`, `gaoptimset` | design/optGene |
| Symbolic Math | `syms`, `pretty` | topology/FR/checkFullRowRankFRK |
| Deep Learning | `plotconfusion` | plotThermoKernelExtractStats |
| Parallel Computing | `getCurrentTask` (inside `parfor`) | fastFVA |
| Parallel Computing | `spmd` (+ `Composite`, `labindex`, `numlabs`, `labSend`, `labReceive`, `labProbe` in the same guarded branch) | SteadyComPOAgr |
| Statistics | `range` | SWIFTCORE partition (added after research, R0) |
| Bioinformatics | `HeatMap` | plotEssentialRxns (added after research, R0) |
| Licence guards | `assert(license('test','bioinformatics_toolbox'))`, `license('test','Statistics_Toolbox')` and `statToolboxInstalled` gates | partition, analyseWBMsol, mgSimResCollect, initPersephone → runPersephone |
| Parallel Computing (*test*) | `parcluster` | testSteadyCom, testSampleCbModel |

### Left toolbox-gated (maintainer rule, 2026-11-11)

"If for any toolbox the results don't match we skip them": a function whose replacement cannot
reproduce the MathWorks result is left as it is and listed here (research R1):

| Function / call site | Reason |
|---|---|
| `mafdr` Storey default (`performStatisticalAnalysis`, `BHFDR=false`) | algorithm undocumented, default bootstrap random |
| `tsne` and `gscatter` (`producetSNEPlots`) | embedding coordinates random and not unique |
| `fitglme` (mixed formulas in `performRegressions`) | default fitting method internals undocumented; no reference for binomial |
| `fminunc`, `fmincon` (`optimalScores`) | `'linear'` objective has no minimizer; `'exp'` branch never runs (pre-existing defect); both already fall back to default weights |
| `syms`, `pretty` (`checkFullRowRankFRK`) | the function cannot run at all (missing `makeLoopToyModel`), so no replacement could be tested |

`redbluecmap` needs no replacement (its colormap is overwritten on the next line) and
`plotconfusion` sits in dead code that is removed.

### Out of scope

- `linprog`, `fmincon` and `optimoptions` inside `solveCobraLP` and `solveCobraNLP`: they are the
  optional `matlab` solver backend chosen with `changeCobraSolver`, the same kind of choice as
  CPLEX or MOSEK (Principle IV).
- `external/` (read-only, Principles V and IX). PolytopeSampler's `distribution_test` (`exprnd`,
  `kstest`, `adtest`, `norminv`) and Volume-and-Sampling (`exprnd`) keep their toolbox calls, so
  `testSampleCbModel` and `testSampleCbModelRHMC` keep their Statistics requirement;
  `graph_analysis` calls `bwlabel`, so `testConnectedComponents` keeps its Image Processing
  requirement (maintainer decision 2026-11-11); the external `violinplot` reaches `ksdensity`, so
  the default violin-plot path of `makeViolinPlots` keeps needing Statistics.
- `old/` and `deprecated/` folders.
- Solver, web-access and external-program requirements of tests (CPLEX, MOSEK, MINOS, `lrs`,
  `cxcalc`, network URLs): they are not paid MATLAB toolboxes.
- Fixing pre-existing defects that a newly running test reveals (recorded per III-Defects; a
  fix is a separate feature).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Statistical tests, distributions and small utilities run on base MATLAB (Priority: P1)

A user without the Statistics or Bioinformatics Toolbox runs FEA, the microbiome statistics,
PERSEPHONE's non-parametric tests, sample comparisons, eFlux, SWIFTCORE, KL distance,
rFASTCORMICS discretisation, the thermodynamic estimators and the confusion-matrix reports, and
gets the same numbers as a user who has the toolboxes.

**Why this priority**: these are the most common remaining dependencies (about 25 files) and
the replacements are well-defined formulas with published references.

**Independent Test**: each replacement has its own test that compares it with SciPy or
statsmodels reference values and with MathWorks documentation examples, and, when the toolbox
is installed, with the MathWorks function itself.

**Acceptance Scenarios**:

1. **Given** base MATLAB, **When** a call site calls the replacement with the syntax it uses
   today, **Then** the outputs (values, p-values, statistics structures, sizes, orientation,
   ordering) match the MathWorks function within a stated tolerance (exact for counts, ranks,
   labels and orderings).
2. **Given** an option the replacement does not support, **When** it is passed, **Then** an
   error names the option.
3. **Given** a fixed random seed, **When** `normrnd` or `randsample` replacements draw numbers,
   **Then** they return the same numbers as the MathWorks function with that seed where the
   MathWorks algorithm is documented, and otherwise the same distribution (stated in the test).

---

### User Story 2 - Curve fitting and optimizers run on base MATLAB (Priority: P1)

A user without Curve Fitting, Optimization or Global Optimization Toolbox runs rFASTCORMICS
(Gaussian fits of expression densities), the varKin BDCA/DCA solvers and OptGene
(modelBorgifier's optimizers are left toolbox-gated, see Scope).

**Why this priority**: rFASTCORMICS and OptGene are user-facing pipelines that fail outright
without the toolboxes; BDCA/DCA are solver methods used by kinetic analyses.

**Independent Test**: each optimizer is tested on problems with a known optimum (and on the
problems its call sites build); the Gaussian fit is tested against SciPy `curve_fit` and against
the MathWorks result when Curve Fitting is installed.

**Acceptance Scenarios**:

1. **Given** a problem with a known optimum, **When** the unconstrained trust-region replacement
   (user gradient and Hessian) or the genetic-algorithm replacement is run, **Then** it reaches that optimum within the stated tolerance; identical
   iterates to MathWorks are not required (maintainer decision 2026-11-11).
2. **Given** a fixed random seed, **When** the genetic algorithm runs twice, **Then** both runs
   return the same result.
3. **Given** expression data, **When** the Gaussian fit runs, **Then** amplitude, centre and
   width match the reference within the stated tolerance, and the goodness-of-fit fields used by
   the call sites are returned.
4. **Given** OptGene on its test model, **When** it runs without Global Optimization Toolbox,
   **Then** the knock-out set it finds attains the same objective as with the toolbox (within
   tolerance), and its outputs keep their documented names and shapes.

---

### User Story 3 - Regression and machine-learning models run on base MATLAB (Priority: P2)

A user without the Statistics Toolbox runs PERSEPHONE regressions (linear, generalised linear
with and without Firth's penalty), the cluster/relative abundance tables and modelBorgifier SVM
scoring. Mixed-effects regressions and the DEMETER t-SNE plots stay toolbox-gated (see Scope).

**Why this priority**: these are the largest algorithms in scope; they serve specialised
pipelines (PERSEPHONE, modelBorgifier).

**Independent Test**: each model-fitting replacement is compared with statsmodels or
scikit-learn fits of the same data (coefficients, standard errors, p-values, confidence
intervals, log-likelihood, predictions), and with the MathWorks function when installed.

**Acceptance Scenarios**:

1. **Given** the formulas, distributions and options the call sites pass, **When** the
   replacement fits the model, **Then** every model property the call sites read (for example
   coefficient table, `coefCI`, deviance, R-squared, p-values) matches the reference within the
   stated tolerance.
2. **Given** data for which MATLAB's fit fails or warns (separation, rank deficiency, no
   convergence), **When** the replacement runs, **Then** it behaves the way the call site expects
   (the call site's `try/catch` path or warning is still reached).
3. **Given** a user script that reads the fitted models returned by `performRegressions` (for
   example `regressions.x.Coefficients`, `regressions.x.Rsquared.Adjusted`,
   `coefCI(regressions.x)`, `predict(regressions.x, tbl)`), **When** it runs without the toolbox,
   **Then** it gets the same property names, layouts and values as with the MathWorks model object
   (maintainer decision 2026-11-11); a MathWorks method that is not reproduced raises an error that
   names it.

---

### User Story 4 - Figures and reports draw on base MATLAB (Priority: P2)

A user without Statistics or Bioinformatics Toolbox gets the box plots, clustered heat maps,
essential-reaction heat maps, point labels in rBioNet statistics and reaction maps
(bio_paint4Net), headless or with a display.

**Why this priority**: figures do not change results, but their call sites currently stop with
an error before later, non-graphical outputs are produced.

**Independent Test**: each figure replacement is run headless; the test checks the figure
content that carries meaning (groups, ordering, values, labels, colour limits, clustering order,
node and edge sets), not pixels.

**Acceptance Scenarios**:

1. **Given** the inputs a call site passes, **When** the replacement draws, **Then** the figure
   shows the same groups, values, order and labels as the MathWorks figure, and the call site's
   other outputs are unchanged.
2. **Given** `model_stats` labelling, **When** the user clicks a point, **Then** its name is
   shown, as `gname` did, using a base-MATLAB interactive mechanism; headless, the call does not
   block.
3. **Given** bio_paint4Net inputs, **When** the map is drawn, **Then** the outputs
   (`involvedMets`, `deadEnds`, `deadRxns`) are the same as before and the drawn graph has the
   same nodes, edges and highlighted edges (MathWorks removed `biograph` in R2022b, so this also
   makes bio_paint4Net run again on current MATLAB).

---

### User Story 5 - Parallel leftovers run serially without the Parallel Computing Toolbox (Priority: P2)

A user without the Parallel Computing Toolbox runs the code paths in fastFVA and SteadyCom that
use task information or `spmd`.

**Why this priority**: the first slice made pools optional; these two constructs remain.

**Independent Test**: the behaviour of `getCurrentTask` and `spmd` without the toolbox is
established on a MATLAB without it (or a documented equivalent check), and each call site runs
serially with the same results.

**Acceptance Scenarios**:

1. **Given** no Parallel Computing Toolbox, **When** the code reaches the task query or the
   `spmd` block, **Then** no error is raised and the results equal the parallel run's results.

---

### User Story 6 - Tests that only needed a toolbox run (Priority: P1)

A maintainer running the test suite on base MATLAB plus Gurobi sees no test skipped for a paid
toolbox, except the four that depend on `external/` code.

**Why this priority**: this is what the maintainer asked about: CI skipped dozens of tests.

**Independent Test**: a scan of every test's declared requirements, and a run of each changed
test on base MATLAB.

**Acceptance Scenarios**:

1. **Given** a test whose code no longer reaches a paid-toolbox function, **When** it runs on
   base MATLAB, **Then** it declares no toolbox requirement and passes (or skips only for a
   solver, web or program requirement).
2. **Given** a test that calls a toolbox function directly (`randsample`, `hygecdf`,
   `geosoftread`), **When** it runs, **Then** it uses the replacement instead.
3. **Given** a test that fails once its toolbox requirement is removed because of a pre-existing
   defect (for example `testBiomassPrecursorCheck`, line 91), **When** the requirement is removed,
   **Then** the defect is documented in the test header under III-Defects, the affected input is
   skipped, and the test passes.
4. **Given** a stale requirement (`testRFASTCORMICS`, `testBiomassPrecursorCheck`) or one made unnecessary by this feature (`testPartition` once
   `partition` drops its licence assertion and `range`), **When** the requirement is removed,
   **Then** the test passes on base MATLAB.
5. **Given** a test that depends on `external/` code calling a toolbox
   (`testSampleCbModel`, `testSampleCbModelRHMC`, `testConnectedComponents`,
   `testCreatePanModels`), **When** the suite
   runs, **Then** it keeps its requirement and its header states the external function and reason.

---

### User Story 7 - Independent review (Priority: P3)

**Independent Test**: every new function is reviewed against the MathWorks semantics note by
Codex (read-only) or, if the Codex account still rejects every model, by independent reviewer
agents that receive only the code, the tests and the semantics note; every finding is fixed or
answered in `review.md`.

### Edge Cases

- NaN and Inf inputs: propagated, ignored or rejected exactly as the MathWorks function does.
- Ties in rank tests (`ranksum`, `kruskalwallis`, `tiedrank`); small samples where MathWorks uses
  exact p-values instead of the normal approximation.
- One group or empty groups in `anova1`/`kruskalwallis`; unequal variances in `ttest2`
  (`'Vartype'` if a call site uses it).
- `mafdr` with `'BHFDR', true` (the existing `fdrBHadjustment` already reproduces it) versus
  Storey's default q-values if a call site uses the default.
- `hygecdf` at the support boundaries; `geomean` with zeros or negative values.
- `confusionmat` class order and `'Order'` option; missing classes.
- `ksdensity` bandwidth selection (MathWorks rule), support options, evaluation points.
- `cmdscale` with non-Euclidean distances (negative eigenvalues).
- Regression: categorical predictors and reference levels, interactions in formulas, perfect
  separation (Firth), rank-deficient designs. (Random-effects edge cases are out of scope:
  `fitglme` is left toolbox-gated.)
- Optimizers: starting point already optimal; bounds equal; non-convergence (exit flags and
  messages the call sites read).
- Figure functions without a display (`-batch`, Xvfb).
- `dataset` → `table`: downstream code that indexes the result must keep working.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: New functions live in `src/base/utilities/toolboxFree/` (the folder of the first
  slice), are named `cobra<MathWorksName>` (for example `cobraRanksum`), and never shadow a
  MathWorks function name.
- **FR-002**: Where base MATLAB or the toolbox already offers an exact equivalent, the call site
  uses it directly instead of a new function (for example `fdrBHadjustment` for
  `mafdr(p, 'BHFDR', true)`, `table` for `dataset`, a base plotting function for a plot when the
  figure content is the same); each such substitution is listed with its justification.
- **FR-003**: Each replacement supports every syntax and option used by a call site in `src/`
  (outside `old/`/`deprecated/`) and by the tests, reproduces the MathWorks outputs the call sites
  read, and raises an error naming any unsupported option.
- **FR-004**: Each new function carries the openCOBRA help header stating the MathWorks function
  it reproduces, the supported syntaxes and the source of the algorithm (publication or
  documentation), per VII-E.
- **FR-005**: Optimizer replacements implement the same algorithm class as the MathWorks
  function (trust-region Newton using the caller's gradient and Hessian for `fminunc`; a genetic
  algorithm for `ga`); correctness is reaching the known optimum within a stated tolerance and
  returning the exit information the call sites read.
- **FR-005a**: A function whose replacement cannot reproduce the MathWorks result (values within a
  justified tolerance; the same optimum for optimizers; the same meaningful content for figures)
  is left toolbox-gated and listed in Scope; if a parity section later shows a kept replacement
  does not match, that call site reverts to the toolbox call under the same rule.
- **FR-005b**: Model-fitting replacements whose results the code returns to the user
  (`performRegressions`' second output) return an object with the MathWorks property names,
  layouts and values and the methods `coefCI`, `predict` and `disp`; any other MathWorks method
  raises an error naming it. Documented exceptions: the class name, and `Formula`, which holds the
  formula text instead of a formula object.
- **FR-006**: Random-number replacements accept the caller's random stream state (seeded with
  `rng`) and are reproducible; where the MathWorks algorithm is documented, they reproduce its
  draws for the same seed.
- **FR-007**: Figure replacements run headless and draw the same meaningful content (groups,
  values, order, labels, clustering, node and edge sets); `gname`'s click-to-label behaviour is
  kept with a base-MATLAB mechanism that does not block when there is no display.
- **FR-008**: `getCurrentTask` and `spmd` call sites run without the Parallel Computing Toolbox
  with unchanged results.
- **FR-008a**: Licence guards that stop a call site whose toolbox functions are now replaced are
  removed; guards that protect a left toolbox-gated function stay, with a message naming it.
- **FR-009**: Every call site in the inventory switches to its replacement or base-MATLAB
  equivalent; no public interface of an existing function changes (Principle II), and each
  call site's results are unchanged when the toolbox is installed (parity).
- **FR-010**: One Tier-1 test per new function (III-Naming), declaring no requirement, with
  values checked against MathWorks documentation examples where they publish numbers and against
  reference values computed by SciPy 1.16, statsmodels or scikit-learn (library and version
  stated in the test header); a parity section compares with the MathWorks function only when its
  toolbox is installed and otherwise prints a skip message, so the test passes on base MATLAB.
- **FR-011**: 100% line coverage of every new function, or every uncovered line listed with its
  reason (III-Coverage).
- **FR-012**: Tests stop calling toolbox functions directly and drop every toolbox requirement
  that the code they exercise no longer needs; each change is verified by running the test on
  base MATLAB (or, where it also needs an unavailable solver, verified statically and stated so).
  Requirements stay for `testSampleCbModel`, `testSampleCbModelRHMC`, `testConnectedComponents`
  and `testCreatePanModels` (`external/` code), with the reason written in their headers.
- **FR-013**: A pre-existing defect revealed by a test that newly runs is documented in that
  test's header under III-Defects (affected input skipped, lines exempted); the source function
  is not changed in this feature, and `test/known-defects.md` is regenerated.
- **FR-014**: Existing tests of every changed call-site file pass on this machine (base MATLAB
  plus Gurobi) wherever their other requirements are met.
- **FR-015**: Independent review (FR-007 of the first slice: Codex read-only, or independent
  reviewer agents if Codex cannot run) of every new function and of the call-site changes;
  findings and resolutions recorded in `review.md`.
- **FR-016**: Reference values are produced by scripts kept in the feature folder; the Python
  packages used for references are installed outside the repository and are not a dependency of
  the toolbox.
- **FR-017**: One pull request to `develop`, commits as the maintainer with no co-author line,
  only this feature's files staged (never the local submodule pointers).

### Key Entities

- **Replacement function**: MathWorks name, toolbox, new name or base-MATLAB equivalent,
  supported syntaxes, algorithm source, call sites.
- **Reference value**: source (MathWorks documentation, SciPy/statsmodels/scikit-learn with
  version, MathWorks function), input, value, tolerance and its justification.
- **Test requirement change**: test, requirement removed or kept, reason, verification run.
- **Review finding**: function, finding, resolution.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A repeat of the call-graph scan (`references/scanUnresolved.m`) on base MATLAB finds
  0 calls to the inventory functions in `src/` outside `old/`, `deprecated/`, the optional
  `matlab` solver backend and the left toolbox-gated call sites listed in Scope.
- **SC-002**: Every new test passes on base MATLAB; parity sections pass wherever the toolbox is
  installed.
- **SC-003**: In a run of the full test suite on base MATLAB plus Gurobi, exactly four tests skip
  for a paid toolbox (`testSampleCbModel`, `testSampleCbModelRHMC`, `testConnectedComponents`,
  `testCreatePanModels`; corrected from three on 2026-11-11: the external violinplot reached by
  testCreatePanModels calls `ksdensity`);
  every other skip names a solver, web address or external program.
- **SC-004**: Every replacement matches its references within the tolerance stated in its test;
  every optimizer reaches the known optimum of each test problem within its stated tolerance.
- **SC-005**: Existing tests of changed call-site files pass as before (none newly failing).
- **SC-006**: Every review finding is fixed or answered in `review.md`.

## Assumptions

- This machine has base MATLAB R2025a with the Parallel Computing Toolbox only; Gurobi 11 is the
  solver. Parity sections for the other toolboxes therefore skip here and run on any installation
  that has them; CI has Gurobi and the same toolbox situation as far as the skip reports show.
- The MathWorks documentation is the authority for semantics; where it is silent, the behaviour
  is recorded as UNCONFIRMED in the semantics note and settled by the parity sections where the
  toolbox is available.
- statsmodels and scikit-learn (installed in a scratch virtual environment outside the repo) and
  SciPy 1.16 are the independent references (maintainer decision 2026-11-11).
- `spmd` and `getCurrentTask` behaviour without the toolbox was established during planning
  (research R3): both are reached only when a pool exists, and are guarded explicitly.
- The figure content that carries meaning is defined per call site during planning; pixel
  equality with MathWorks figures is not a goal.

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1 / FR-003, FR-006, FR-010 | `testCobra<Name>` per statistics/distribution replacement under `test/verifiedTests/base/testToolboxFree/` | `src/base/utilities/toolboxFree/cobra<Name>` |
| US2 / FR-005, FR-010 | `testCobra<Name>` per optimizer and fit replacement; `testOptGene`, `testRFASTCORMICS` | `src/base/utilities/toolboxFree/cobra<Name>`; `src/design/optGene`; `src/dataIntegration/transcriptomics/rFASTCORMICS/*` |
| US3 / FR-003, FR-005b, FR-010 | `testCobra<Name>` per regression / learning replacement; tests of the model classes | `src/base/utilities/toolboxFree/cobra<Name>`; `src/analysis/persephone/performRegressions` |
| FR-005a / Scope (left toolbox-gated) | — (no source function): listed in Scope and research R1; SC-001 scan exceptions | left call sites |
| FR-008a | existing tests of the guarded call sites (testPartition, testMgPipe) | `partition`, `mgSimResCollect`, `analyseWBMsol`, `initPersephone` |
| US4 / FR-007 | `testCobra<Name>` per figure replacement; existing tests of the figure call sites | `src/base/utilities/toolboxFree/cobra<Name>`; figure call sites in the inventory |
| US5 / FR-008 | `testFastFVA` (CPLEX; static where unavailable), `testSteadyCom` | `src/analysis/FVA/fastFVA/fastFVA`; `src/analysis/multiSpecies/SteadyCom/subroutines/SteadyComPOAgr` |
| US6 / FR-012, FR-013 | every test listed in the plan's requirement table | functions those tests cover |
| US1–US6 / FR-009, FR-014 | existing tests of each changed call-site file | call sites in the inventory |
| US7 / FR-015 | — (no source function): `review.md` | new functions |
| SC-001 | — (no source function): repeat of the call-graph scan, recorded in the receipt | `src/` |
