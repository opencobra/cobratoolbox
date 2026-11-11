# Research: remaining toolbox-free replacements

Detailed per-function semantics, call sites and references: [mathworks-semantics.md](mathworks-semantics.md)
(sections G1–G4). This file records the decisions taken on them.

## R0 — Inventory method and corrections

- **Method**: `references/scanUnresolved.m` parses every `.m` file under `src/` and
  `test/verifiedTests/` with `getcallinfo` and lists called names that are not callable on base
  MATLAB R2025a + Parallel Computing after `initCobraToolbox`. A name counts as callable only if
  `exist` returns 2/3/5/6/8 **and** `which` resolves it with the exact case. The first version used
  `exist` alone and missed `HeatMap` (case-insensitive match to base `heatmap.m`) and `range`
  (`exist` = 7, a folder); the corrected scan is the one SC-001 repeats.
- **Inventory additions found by research** (not in the spec's first draft):
  `HeatMap` (Bioinformatics, plotEssentialRxns 70–82); `range` (Statistics, partition 73, 97);
  licence guards that stop call sites even after the function is replaced —
  `partition.m:34` (assert Bioinformatics), `analyseWBMsol.m:205` (Statistics, around tiedrank),
  `mgSimResCollect.m:115` (Statistics, forces `noPcoa`), `initPersephone.m:69` →
  `runPersephone.m:315` (Statistics gate of the whole statistics stage); Parallel Computing
  `Composite`, `labindex`, `numlabs`, `labSend`, `labReceive`, `labProbe` inside the same guarded
  SteadyComPOAgr branch as `spmd`; test code `parcluster` in `testSteadyCom.m:440` (not in
  try/catch) and `testSampleCbModel.m:24` (in try/catch).
- **Corrections**: `testConnectedComponents` is not stale — `connectedComponents` calls
  `external/analysis/graph_analysis/graph_analysis.m`, whose line 237 always calls `bwlabel`
  (Image Processing). `testPartition` is not stale (partition's licence assert and `range`).
  `redbluecmap` needs no replacement: plotEssentialRxns overwrites the colormap on the next line
  (`colormap(hm, mymap)`). `plotconfusion` is in an `if 0` branch (dead code). `biograph` was
  removed from MATLAB in R2022b, so bio_paint4Net cannot run today even with the toolbox.
- **False positives**: `simplify`, `highlight`, `numnodes`, `numedges` are base-MATLAB graph
  methods; other unresolved names are variables loaded from `.mat` files, solver APIs (`Cplex`,
  `mosekopt`, `gurobi_mex`, `cvx_*`, GAMS `rgdx`/`wgdx`) or pre-existing missing functions.

## R1 — Rule for functions that cannot reproduce the toolbox result

- **Decision (maintainer, 2026-11-11)**: "if for any toolbox the results don't match we skip
  them" → a function whose replacement cannot reproduce the MathWorks result is **left as it is**
  (toolbox-gated) and listed in the spec. For optimizers, "reproduce" means reaching the same
  optimum within tolerance (maintainer decision 2026-11-11, spec decision 2); for figures it means
  the same meaningful content; for everything else the same values within a justified tolerance.
- **Applied — left toolbox-gated**:

| Function / call site | Why it cannot match | Effect |
|---|---|---|
| `mafdr` default (Storey q-values), `performStatisticalAnalysis` with `BHFDR=false` (default from `analyzeMgPipeResults`) | Algorithm not documented; default `'Method','bootstrap'` is random [G1 §7] | mgPipe statistics keep Bioinformatics on that path; BH sites are replaced (R3) |
| `tsne` (and so all of `producetSNEPlots`, incl. `gscatter`) | Embedding coordinates are random and not unique; Barnes–Hut details undocumented [G3 §8] | DEMETER t-SNE plots keep Statistics |
| `fitglme` (mixed formulas in `performRegressions`) | Default MPL fitting internals undocumented; no independent reference for the binomial MPL estimator [G3 §3] | Mixed-effects regressions keep Statistics; the call site's existing try/catch path is unchanged |
| `fminunc`/`fmincon` in `optimalScores` | `'linear'` objective `1/(|cᵀw|+1)` has no minimizer (result set by the stopping rule); `'exp'` branch passes 6 arguments to a 5-argument objective and always falls back [G2 §3] | Both already sit in try/catch with a default-weights fallback; behaviour unchanged |
| `syms`/`pretty` in `checkFullRowRankFRK` | Not a match problem: the script cannot run at all (`makeLoopToyModel` is missing, line 6), so a replacement could not be tested | Left; defect recorded |

- **Applied — kept, with the residual risk stated** (the parity section settles it where the
  toolbox exists; if parity fails, R1 applies and the call site reverts to the toolbox call):
  Firth `fitglm` SE/p-value conventions (R7), `ksdensity` grid (R4), `ranksum` statistic for
  unequal samples (R4), `cmdscale` column signs (R4).

## R2 — Placement, naming, references (carried over from the first slice)

- New functions in `src/base/utilities/toolboxFree/`, named `cobra<MathWorksName>`; the formula
  parser and design-matrix builder shared by `cobraFitglm`/`cobraFitlm` are public
  (`cobraParseModelFormula`, `cobraBuildModelDesign`) so each has its own test (III-Naming); tests
  in `test/verifiedTests/base/testToolboxFree/`.
- References: SciPy 1.16.3, statsmodels 0.15.0, scikit-learn 1.9.1 in a virtual environment
  outside the repository (FR-016); scripts in `references/`, one per group; MathWorks
  documentation examples with published numbers wherever they exist (listed per function in the
  semantics note; e.g. the `fitglm` logistic example on base-MATLAB `patients.mat` is reproduced
  exactly by plain IRLS [G3 §2.6]).
- Parity sections compare with the MathWorks function only when its toolbox and licence are
  present, otherwise print a skip line (first-slice pattern).

## R3 — Base-MATLAB substitutions (no new function)

| Replaced | Substitute | Exact because |
|---|---|---|
| `mafdr(p,'BHFDR',true)` (FEA, dimRed) | existing `fdrBHadjustment` | same BH formula; NaN handling checked in its test [G1 §7] |
| `geomean(x)` | `exp(mean(log(x)))` (dim as at the call site) | definition; negative-input behaviour checked [G1 §9] |
| `normrnd(mu,sigma,...)` | `mu + sigma.*randn(...)` | MathWorks doc numbers reproduce bit-exactly with the same seed [G1 §10] |
| `randsample(n,k)` (tests only) | `randperm(n,k)'` | same draws for the same seed [G1 §11] |
| `range(x)` | `max(x)-min(x)` | definition |
| `dataset(...)` + export (generateIsotopomerSolver) | `fopen`/`fprintf` writing the same text | byte comparison; `writetable` quoting would break the Perl reader [G1 §15] |
| `HeatMap(...)` (plotEssentialRxns) | base `heatmap` with the same labels and colour limits | figure content (R6) |
| `gname(names)` (model_stats) | `dataTipTextRow` on the plotted line | click shows the name; nothing blocks headless [G4 A3] |
| `getCurrentTask` (fastFVA) | guarded by `isParallelToolboxAvailable`; task ID 1 when there is no task | doc: on the client `t` is empty [G4 B1] |
| `spmd` block (SteadyComPOAgr) | explicit guard; the existing serial branch (lines 132–147) runs | reached only with a pool [G4 B2] |
| `plotconfusion` | dead `if 0` branch removed | unreachable code |
| licence guards (partition, analyseWBMsol, mgSimResCollect, initPersephone) | removed or replaced by the checks that are still true (e.g. Statistics still needed for mixed formulas, R1) | their functions are now replaced |

## R4 — Statistics replacements (new functions)

`cobraAnova1`, `cobraKruskalwallis` (one-way ANOVA on tied ranks via `cobraAnova1`, as MathWorks
documents; no separate engine), `cobraRanksum`, `cobraTtest2`,
`cobraKstest2`, `cobraHygecdf`, `cobraTiedrank`, `cobraKsdensity`, `cobraCmdscale`,
`cobraConfusionmat`. Algorithms, call-site syntax and references per function: semantics note
G1 §1–§14 and summary table §16. Notable choices:

- `kruskalwallis` called with display `'on'` at two sites: the replacement draws nothing for
  `'on'` — both sites close or replace those figures immediately, so no saved output changes.
- `ranksum`: exact p-value with ties (doc mileage example p = 0.0043 reproduced); `stats.ranksum`
  follows the current doc ("rank sum of the first sample"); R14 used the smaller sample —
  UNCONFIRMED for current releases (R1 risk).
- `kstest2`: accepts the positional `(x1,x2,alpha,tail)` form used by `compareTwoSamplesStat`
  and name-value pairs; p-value per the asymptotic formula that reproduces the doc example (SciPy's
  p-value is a different method and is not the reference).
- `ksdensity`: default call only (normal kernel, Silverman bandwidth with MAD, 100 points, row
  output); grid ±3 bandwidths from R14, current UNCONFIRMED (R1 risk).
- `cmdscale`: eigen-decomposition of the double-centred matrix; tests allow column sign flips.
- `cobraTiedrank`: new — `cobraCorr`'s private rank helper returns a NaN column if any value is
  NaN, which `tiedrank` does not.

## R5 — Curve fit and optimizers (new functions)

- `cobraFitGauss1(x,y,'StartPoint',sp,'Lower',lb,'Display','off')` — replaces
  `prepareCurveData` + `fittype('gauss1')` + `fitoptions` + `fit` in createFitL/R; bounded nonlinear
  least squares (trust-region, analytic Jacobian), returns a struct with `a1`, `b1`, `c1`, an
  evaluation handle and `gof` (`sse`, `rsquare`, `dfe`, `adjrsquare`, `rmse`). Downstream reads only
  `.b1`, `.c1` and one `plot(fit,...)` under `figflag` [G2 §1]. Reference: SciPy `curve_fit`
  (`method='trf'`). Risk: the left fit on zero-padded data can reach a different local minimum;
  the test uses realistic FPKM-like data and the call sites' start points.
- `cobraFminunc(fun,x0,opts)` — BDCA/DCA only: trust-region Newton with the caller's gradient and
  Hessian (Steihaug–Toint CG; Nocedal & Wright 2006, §7.1). The subproblem Hessian is positive
  definite, so the minimizer is unique and the result matches. Only `x` is read [G2 §2].
- `cobraGa(problem)` — optGene: generational GA honouring the options optGene sets (custom
  creation/crossover/mutation, vectorized fitness, 4 subpopulations of 125 with forward migration,
  rank scaling, stochastic uniform selection, elite count, legacy stopping options) [G2 §4]. The
  four Global-Optimization plot functions optGene passes are dropped (they exist only in that
  toolbox). Correctness: OneMax and a knapsack whose optimum is known by enumeration, plus optGene on
  its test model reaching the same objective as the toolbox run's reference. Reproducibility tests
  stop on generations, not time (testOptGene uses `TimeLimit`, so its own run is not bit-reproducible).
  Population returned as double 0/1, as MathWorks documents for bitstrings (testOptGene line 53
  indexes with it; checked during implementation).

## R6 — Figures (new functions where no base equivalent draws the same content)

- `cobraBoxplot` (makeViolinPlots, `'BoxPlot'` type): draws lines tagged `'Box'`/`'Median'` like
  MathWorks so the call site's `findobj`/`patch` colouring keeps working; `boxchart` was rejected
  (different quartile method and object model) [G4 A1]. The default `'ViolinPlot'` path calls the
  external `violinplot`, which reaches `ksdensity` (`external/.../Violin.m:117`); left (external/
  read-only) and recorded.
- `cobraClustergram` (correlateFluxWithTaxonAbundance, summarizeFeaturesOnTaxonLevels): average
  linkage via the existing `computeEcosystemLinkage`, new `cobraOptimalLeafOrder` (Bar-Joseph et
  al. 2001), heat map in an ordinary axes returned as the handle so `set(h,...)`/`colorbar(h)` keep
  working [G4 A4]. Test asserts row/column order, labels, CData and colour limits.
- bio_paint4Net: replace only the drawing block of `bio_draw_by_rxn` (lines 448–612) with
  `digraph` + `plot` + `outedges`/`inedges` + `highlight`; outputs unchanged [G4 A6]; tests
  `testPaint4Net_bio_draw_by_rxn/_met` lose their `exist('biograph')` self-skip.

## R7 — Regression and SVM (new functions)

- `cobraFitglm(tbl, formula, 'Distribution', d, 'LikelihoodPenalty', lp)` — IRLS (normal,
  binomial) and Firth's modified score (Firth 1993; Heinze & Schemper 2002); formula forms that
  occur: `resp~x1+x2+...` with numeric and text/categorical predictors (reference level = first
  appearance, confirmed numerically), plus `*`, `:` and `-` for the published doc example.
  Coefficients: binomial p-values normal, normal-family t; `coefCI` uses t(DFE) for both (confirmed
  with published numbers) [G3 §2, §4].
- **Returned object (maintainer decision 2026-11-11: user scripts must keep working)**: a classdef
  `cobraGeneralizedLinearModel` whose property names, types and values follow MathWorks
  `GeneralizedLinearModel` for: `Coefficients` (table Estimate/SE/tStat/pValue, RowNames),
  `CoefficientNames`, `CoefficientCovariance`, `NumObservations`, `NumCoefficients`, `DFE`,
  `Rsquared` (Ordinary, Adjusted, LLR, Deviance, AdjGeneralized), `Deviance`, `LogLikelihood`,
  `Dispersion`, `DispersionEstimated`, `Distribution`, `Formula`, `Variables`, `ObservationInfo`,
  `Fitted`; methods `coefCI`, `predict`, `disp`. The class cannot be named
  `GeneralizedLinearModel` (FR-001), so `isa(...,'GeneralizedLinearModel')` differs; any other
  MathWorks method raises an error naming it. `cobraFitlm` returns the matching
  `cobraLinearModel` subset (`Coefficients`, `Rsquared`, `NumObservations`, `coefCI`).
- **Warnings**: `performRegressions` discards a model when any warning was raised during the fit.
  The replacements warn where MathWorks does (iteration limit, perfect separation without penalty,
  rank deficiency) with `COBRA:` identifiers and never otherwise (VII-B: warnings stay visible).
- **Firth conventions UNCONFIRMED** (SE from I(β̂)⁻¹, Wald p, unpenalised deviance; normal +
  jeffreys-prior = OLS expected): implemented as stated, tested against a NumPy modified-score
  script (Heinze & Schemper 2002); settled by parity (R1 risk). `firthlogist` could not be used:
  every release requires Python < 3.11 and the reference environment has Python 3.12 (T001,
  2026-11-11).
- The R2024b version gate in `performRegressions` (`ver >= 24.2` → Firth) is kept unchanged.
- `cobraFitcsvm` (optimalScores `'svm'`): linear kernel, defaults of the call (no standardisation,
  C = 1, positive class = the second class in sorted order, i.e. label 1 for {0,1}); only `Beta` is read and it is unique (strictly convex). SMO
  (Platt 1998; Fan, Chen & Lin 2005 working-set selection), the MathWorks default solver.
  Reference: scikit-learn `SVC(kernel='linear')`. Going through `solveCobraQP` was rejected: SVM
  training is not a COBRA model problem (Principle IV governs model optimisation) and it would add
  a solver requirement to a Tier-1 test.

## R8 — Tests and requirements

Verdicts per test: semantics note G4 Part C. After this feature:

- **Requirement removed** (12): testBiomassPrecursorCheck (line-91 assertion documented under
  III-Defects), testRFASTCORMICS (also its `assert(ver('curvefit'))`; add a
  `discretizeFPKM` section to cover R5's fit), testFEA, testSteadyCom (+ `parWorks =
  isParallelToolboxAvailable()`), testMgPipe (static: needs CPLEX), testSWIFTCORE, testPartition,
  testEFlux (parse the GEO SOFT tables in the test; keep `needsWebAddress`), testOptGene, testSammi,
  testPaint4Net_bio_draw_by_rxn, testPaint4Net_bio_draw_by_met (self-skips).
- **Kept** (4): testSampleCbModel, testSampleCbModelRHMC (external sampler code: `exprnd`,
  `kstest`, `adtest`, `norminv`), testConnectedComponents (external `graph_analysis` → `bwlabel`),
  testCreatePanModels (external `violinplot` → `Violin.m` → `ksdensity`, reached through
  plotBiomassTestResults/plotATPTestResults; the research note expected the error to be swallowed
  by a `try`, but the run on 2026-11-11 failed with "Undefined function 'ksdensity'"; its key is
  corrected from the never-matching `'Statistics Toolbox'` to `statistics_toolbox`).
- testMoieties: the requirement sits in an `if 0` block; the dead block is removed.
- Direct toolbox calls in tests switch: `hygecdf` → `cobraHygecdf` (testFEA:76), `randsample` →
  `randperm` (testSWIFTCORE:36, testSammi:151/156/186), `geosoftread` → local parser (testEFlux).

## R9 — Pre-existing defects found (III-Defects; not fixed here)

Recorded in the header of the test that covers each function (or listed in the receipt where no
test reaches the function): optimalScores `'exp'` argument count; summarizeFeaturesOnTaxonLevels:126
`ddataByFeature` undefined; retrieveModelStats:108 operator precedence (always false);
createContextSpecificModel calls undefined `findTranscriptionValue`; checkFullRowRankFRK:6
`makeLoopToyModel` missing; producetSNEPlots:263 and 246–248; testFitC13Data:20 `solverPkgs`;
fastFVA:529 `t.ID` on the client; gpSampler:205 missing `ACHRSamplerDistributedGeneral`;
correlateFluxWithTaxonAbundance NaN correlations; plotThermoKernelExtractStats name ≠ file name;
`bio_findNearRxns` name ≠ file name. Full list with lines: semantics note G4 "Pre-existing defects",
G1 §0.5, G2 §3, G3 §8.

## R10 — Review

As in the first slice: Codex (read-only) if the account accepts a model; otherwise independent
reviewer agents receiving only the code, the tests and the semantics note; findings in `review.md`.
