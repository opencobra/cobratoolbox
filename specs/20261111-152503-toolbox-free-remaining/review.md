# Independent review

Codex (read-only) could not run: on 2026-11-11 the ChatGPT account of the review machine still
rejected every model ("The 'gpt-5.5' model is not supported when using Codex with a ChatGPT
account"). As FR-015 allows, three independent reviewer agents reviewed the code instead, each
receiving only the code, the tests, `mathworks-semantics.md`, `research.md` and the contract, with
no edit rights (scratch files and a memory-capped MATLAB session only). The Codex review is to be
repeated when the account works again.

Severity: bug / fidelity risk / test gap / nit. Resolution: Fixed (with the change) or Answered.

## Group 1 — statistics (anova1, kruskalwallis, ranksum, ttest2, kstest2, hygecdf, tiedrank, ksdensity, cmdscale, confusionmat, call sites)

| # | Severity | Finding | Resolution |
|---|---|---|---|
| 1 | fidelity risk | `cobraRanksum` reported the rank sum (and z) of `x`; MathWorks' R14 source ranks the smaller sample first and reports its rank sum, and the reviewer recalls the current source doing the same; the documentation says "first sample". Only `stats.ranksum`/`zval` of unequal samples are affected (performStatisticalAnalysis, retrieveModelStats, runNonparametricTests); two-sided p-values are not | Fixed: the rank sum and z are those of the smaller sample (x when the sizes are equal), as the only available source code computes them; marked UNCONFIRMED in the header and settled by the parity section, which compares both with the first sample larger |
| 2 | fidelity risk | `cobraKsdensity` summed every kernel; R14 (and, recalled, the current statkscompute) uses only observations within the kernel cut-off (4 bandwidths for the normal kernel) when n*m > 3e4. discretizeFPKM passes ~20k genes, so it takes that path (differences up to 1.4% in the tails, 3.8e-5 of the peak) | Fixed: for n*100 > 3e4 only |z| <= 4 contributes; test checks the windowed sum (n = 25000) and the full sum at n = 300; UNCONFIRMED in the header (parity section) |
| 3 | nit | `cobraCmdscale` sorted with 'descend'; R14 sorts ascending and flips, which reverses the order of tied eigenvalues | Fixed: ascending sort then flipud; tied-eigenvalue case (equilateral triangle) added to the test |
| 4 | nit | `cobraKruskalwallis` with one group after NaN removal returned p = 0 (R14 arithmetic: NaN) | Fixed: p = NaN when there are fewer than two groups; tested |
| 5 | nit | `cobraRanksum` exact method on large samples would need tens of GB | Fixed: error naming the approximate method when the table would exceed 5e7 entries; tested |
| 6 | test gap | no test with the first sample larger under the approximate method | Fixed: the approximate case (25 vs 14) and the swapped order are asserted |
| — | — | anova1/kruskalwallis tables, ttest2, kstest2, hygecdf, tiedrank, confusionmat, and the statistics call sites (geomean, normrnd, randperm, range, licence guards, fprintf export) | No material finding |

## Group 2 — curve fit, optimizers, SVM (cobraFitGauss1, cobraFminunc, cobraGa, cobraFitcsvm, call sites)

| # | Severity | Finding | Resolution |
|---|---|---|---|
| 1 | bug | `cobraFminunc`: a NaN objective at a trial point gave a NaN ratio, so the radius never shrank and the start point was returned (reachable: FuncGradHessSub returns NaN when exp overflows) | Fixed: a non-finite trial value or NaN ratio rejects the step and shrinks the region; tested (objective NaN outside |x| < 1) |
| 2 | fidelity risk | `cobraFitGauss1` was Levenberg-Marquardt; MathWorks fits bounded models by trust-region reflective. On 80 realistic discretizeFPKM curve pairs, 1 of 160 fits collapsed (a1 -> 0, fitting nothing) where SciPy trf found the peak; LM is path-sensitive there | Fixed: replaced by trust-region reflective least squares (Branch, Coleman, Li 1999) written after SciPy's trf (Coleman-Li scaling, exact subproblem by SVD with More-Hebden iteration, reflective step selection, SciPy radius and termination rules). Re-run on the reviewer's 160 curves: no fit with a larger sum of squares than SciPy trf, largest b1 difference 3.3e-3 relative at the 1e-6 default tolerance (flat valley). A plain trust region without the Coleman-Li scaling was tried first and collapsed on 2 of 160, so the scaling matters. Test: 150 seeded random starts (c1 >= 0, sum of squares never above the start); 11 safeguard lines exempted with reasons |
| 3 | nit | initial damping of LM | Answered: obsolete (LM replaced) |
| 4 | nit | `cobraGa`: a cell `CreationFcn` ({handle, args}) failed; stall test uses the endpoint difference, not MathWorks' weighted average | Fixed (cell creation functions; tested). Stall rule: Answered, documented as a choice in the header (optGene's settings do not depend on it) |
| 5 | test gap | testOptGene stops on time, so rng(0) does not make it reproducible | Fixed: 'Generations', 20 added (the time limits stay); passes in 12 s |
| 6 | test nit | the copies of optGene's operators in testCobraGa had drifted (MaxKnockOuts > 0 guard, nargin default) | Fixed: copies made faithful |
| 7 | nit | `cobraFitcsvm` rebuilt numeric ClassNames from text (precision loss, logical returned as double); NaN rows of X not removed | Fixed: class levels from cobraGrp2idx's third output; rows with NaN predictors removed; both tested |
| 8 | test gap | testOptimizeVKmodel0 DCA/BDCA values are first-run (Tier 5) values of cobraFminunc itself | Answered: the subproblem solver is verified independently in testCobraFminunc (known optima, SciPy reference); the Tier-5 values guard the DC iteration, as the existing Tier-5 values of the other solvers in that test do |
| 9 | test gap | the discretizeFPKM section needs no solver but sat behind testRFASTCORMICS's solver gate | Fixed: moved into its own test testDiscretizeFPKM.m (also required by III-Naming: one test file per function), which declares no requirement |
| 10 | — | call-site shapes (createFitL/R fields, plotting, BDCA/DCA options, optGene options, optimalScores) | No material finding |

## Group 3 — regression models, figures, parallel guards

| # | Severity | Finding | Resolution |
|---|---|---|---|
| 1 | bug | `cobraClustergram` without RowLabels/ColumnLabels showed the tick positions 1..n instead of the permuted original numbers (the second branch of correlateFluxWithTaxonAbundance passes no column labels) | Fixed: default labels are the original row/column numbers, permuted like given labels; tested |
| 2 | fidelity risk | an unused category of a categorical predictor produced an all-zero dummy column and a RankDeficient warning, which the lastwarn gates turn into a dropped result | Fixed: only the levels that occur among the rows used get a column (as the header said); tested (no warning) |
| 3 | fidelity risk | model-object gaps: Formula is text; Residuals, ModelCriterion, NumPredictors, NumVariables, VariableNames missing; the hidden property VariableInfo had the MathWorks name with another type; unsupported methods give MATLAB's undefined-function error rather than a COBRA identifier; data-model.md listed Distribution.Name in lower case | Fixed: Residuals (Raw, Pearson), NumPredictors, NumVariables, VariableNames added to both classes; hidden property renamed DesignInfo; data-model.md corrected (Distribution.Name 'Normal'/'Binomial', unsupported methods raise MATLAB's error naming them, ModelCriterion and other residual types not provided). Formula as text: Answered (documented exception, FR-005b) |
| 4 | fidelity risk | `cobraFitlm` with text x: numbers in a string silently fitted, other text gave misleading errors | Fixed: x must be numeric, logical or categorical, otherwise an error naming the type; tested |
| 5 | fidelity risk | term and factor order follow the formula, not table variable order; the Formula text 'y ~ 1 + ...' could not be parsed back | Partly fixed: an explicit '1' is accepted ('-1' and '0' still raise errors). Order: Answered, UNCONFIRMED for MathWorks (semantics note G3 §6.4); the call sites give the variables in formula order, so their results do not depend on it |
| 6 | fidelity risk | bio_draw_by_rxn drew zero-flux edges in digraph's default blue, close to the negative-flux blue; isfield checks did not guard short name vectors | Fixed: edges drawn grey by default; name lookups guarded by length |
| 7 | fidelity risk | `cobraClustergram` 'Cluster','column'/'row' may be swapped relative to the MathWorks documentation ('column' clusters along the columns, which orders the rows) | Fixed to the documented meaning; tested (the call sites use 'all') |
| 8 | test gap | the high-leverage Firth reference value was itself not converged (NumPy loop stopped on the step) | Fixed: the reference script stops on the modified score (< 1e-13); new value [-0.3220608061458092 0.016919034773876736] agrees with the reviewer's full-Newton solve; tolerance tightened to 1e-6 |
| 9 | test gap | the paint4Net tests check only the outputs computed before drawing | Answered: the outputs are unchanged by the rewrite and asserted; the reviewer verified the colouring indices (72 green, 32 blue edges, node colours and markers); asserting graphics of these pre-existing tests is left as a follow-up |
| 10 | test gap | testCobraBoxplot did not check which colour reaches which group | Fixed: cols(1, :) is asserted on the last group's box |
| — | — | formula parsing and dummy coding, IRLS, SE and p-value conventions, no spurious warnings, performRegressions end to end, cobraOptimalLeafOrder, cobraBoxplot geometry, fastFVA and SteadyComPOAgr guards, testSteadyCom cleanup | No material finding |
