# Contract: new functions in `src/base/utilities/toolboxFree/`

Every function supports exactly the syntax below (the union of what the call sites and tests use),
reproduces the MathWorks outputs the call sites read, and raises an error whose message names any
other option or argument it is given. Semantics, sources and UNCONFIRMED points per function:
[mathworks-semantics.md](../mathworks-semantics.md) (section given in brackets).

## Statistics (US1)

| Function | Syntax | Notes |
|---|---|---|
| `cobraAnova1` [G1 §1] | `[p, tbl, stats] = cobraAnova1(y, group, displayopt)` | y vector; group numeric/logical/cellstr/string/categorical; `'on'` accepted, draws nothing (documented); `tbl` cell layout as MathWorks; `stats` fields as MathWorks |
| `cobraKruskalwallis` [G1 §2] | `[p, tbl, stats] = cobraKruskalwallis(x, group, displayopt)` | tie-corrected H; chi-square p; same `'on'` rule; `tbl` layout matched (written to xlsx by a call site) |
| `cobraRanksum` [G1 §3] | `[p, h, stats] = cobraRanksum(x, y)`, `(..., 'method', 'exact'\|'approximate')`, `(..., 'alpha', a)` | MathWorks default exact/approximate rule; exact with ties on doubled mid-ranks; `stats.ranksum` (first sample, per doc), `stats.zval` for approximate; `'tail'` → error |
| `cobraTtest2` [G1 §4] | `[h, p, ci, stats] = cobraTtest2(x, y)` | equal variance, two-sided, alpha 0.05; `stats.tstat`, `.df`, `.sd`; name-value options → error |
| `cobraKstest2` [G1 §5] | `[h, p, ks2stat] = cobraKstest2(x1, x2)`, `(x1, x2, alpha, tail)`, `(..., 'Alpha', a, 'Tail', t)` | tails `'unequal'`, `'larger'`, `'smaller'`; asymptotic p formula reproducing the doc example |
| `cobraHygecdf` [G1 §6] | `p = cobraHygecdf(x, M, K, N)`, `(..., 'upper')` | scalar expansion; upper tail summed directly; invalid parameters → NaN |
| `cobraTiedrank` [G1 §8] | `[r, tieadj] = cobraTiedrank(x)` | column-wise, average ranks, NaN stays NaN; `tieflag`/`bidir` → error |
| `cobraKsdensity` [G1 §12] | `[f, xi, bw] = cobraKsdensity(x)` | default call only: normal kernel, Silverman bandwidth with MAD, 100-point grid, row outputs; any option → error |
| `cobraCmdscale` [G1 §13] | `[Y, e] = cobraCmdscale(D)` | D full matrix or pdist row vector; columns may differ from MathWorks only in sign |
| `cobraConfusionmat` [G1 §14] | `[C, order] = cobraConfusionmat(g, ghat)`, `(..., 'Order', order)` (`'ORDER'`/`'order'` accepted) | missing values removed; numeric/logical/cellstr/string/categorical |

## Curve fit and optimizers (US2)

| Function | Syntax | Notes |
|---|---|---|
| `cobraFitGauss1` [G2 §1] | `[fitresult, gof, output] = cobraFitGauss1(x, y, 'StartPoint', sp, 'Lower', lb, 'Upper', ub, 'Display', d)` | model a1·exp(−((x−b1)/c1)²); NaN/Inf removed and columns reshaped (prepareCurveData); `fitresult` struct with `a1`, `b1`, `c1`, `f` (handle); `gof`: `sse`, `rsquare`, `dfe`, `adjrsquare`, `rmse` |
| `cobraFminunc` [G2 §2] | `[x, fval, exitflag, output] = cobraFminunc(fun, x0, options)` | `options` struct; trust-region with `fun` returning `[f, g, H]` (`SpecifyObjectiveGradient`/`GradObj`, `HessianFcn`/`Hessian` = `'objective'`/`'on'`); `MaxIterations`/`MaxIter`, `OptimalityTolerance`/`TolFun`, `StepTolerance`/`TolX`, `FunctionTolerance`, `Display`; exitflag 1/2/3/0 as MathWorks |
| `cobraGa` [G2 §4] | `[x, fval, exitflag, output, population, scores] = cobraGa(problem)` with `problem.fitnessfcn`, `.nvars`, `.options` (struct) | options optGene sets: `PopulationType` `'bitstring'`, `PopulationSize` (vector → subpopulations), `CreationFcn`, `CrossoverFcn`, `MutationFcn`, `Vectorized`, `Generations`, `StallGenLimit`, `TimeLimit`, `StallTimeLimit`, `FitnessLimit`, `TolFun`, `MigrationDirection`, `MigrationInterval`, `MigrationFraction`, `EliteCount`, `CrossoverFraction`, `InitialPopulation`, `Display`, `OutputFcns`; `PlotFcns` → error (Global Optimization–only plot functions); population double 0/1 |

## Figures (US4)

| Function | Syntax | Notes |
|---|---|---|
| `cobraBoxplot` [G4 A1] | `h = cobraBoxplot(data, group, 'Labels', l, ...)` (options as used in makeViolinPlots) | draws lines tagged `'Box'`, `'Median'`, `'Upper Whisker'`, `'Lower Whisker'`, `'Outliers'` like MathWorks; quartiles by MathWorks' method |
| `cobraOptimalLeafOrder` [G4 A4] | `order = cobraOptimalLeafOrder(Z, D)` | Bar-Joseph, Gifford & Jaakkola 2001; Z in MathWorks linkage format |
| `cobraClustergram` [G4 A4] | `h = cobraClustergram(data, 'RowLabels', r, 'ColumnLabels', c, 'Colormap', m, 'Standardize', s, 'Cluster', k, 'Linkage', l, 'Distance', d, 'DisplayRange', v, 'Symmetric', tf, 'ImputeFun', f)` (options as used at the two call sites) | average linkage via `computeEcosystemLinkage`; returns the heat-map axes handle; row/column order equals MathWorks' dendrogram order |

## Regression and SVM (US3)

| Function | Syntax | Notes |
|---|---|---|
| `cobraFitglm` [G3 §2] | `mdl = cobraFitglm(tbl, formula, 'Distribution', d, 'LikelihoodPenalty', lp)` | d `'normal'`/`'binomial'`; lp `'none'`/`'jeffreys-prior'`; formula `y ~ t1 + t2 + ...` with `*`, `:`, `-`; categorical/text reference = first appearance; returns `cobraGeneralizedLinearModel` |
| `cobraFitlm` [G3 §5] | `mdl = cobraFitlm(x, y)` | vector x; returns `cobraLinearModel`; rank-deficiency warning kept |
| `cobraGeneralizedLinearModel`, `cobraLinearModel` | properties and methods: [data-model.md](../data-model.md) | `coefCI(mdl, alpha)`, `predict(mdl, X)`, `disp`; other MathWorks methods → error naming them |
| `cobraFitcsvm` [G3 §7] | `mdl = cobraFitcsvm(X, y)` | linear kernel, `BoxConstraint` 1, no standardisation, positive class = second class in sorted order as MathWorks; returns struct with `Beta`, `Bias`, `ClassNames`, `IsSupportVector`, `Alpha` |

## Error and warning identifiers

- Unsupported option: `COBRA:<function>:unsupportedOption` (message names the option).
- Unsupported model method: `COBRA:<class>:unsupportedMethod`.
- Warnings raised where MathWorks warns (iteration limit, perfect separation without penalty,
  rank-deficient design): `COBRA:<function>:<Reason>`; no other warnings.
