# Data model

## Planning entities

- **Replacement**: MathWorks name, toolbox, replacement (new `cobra*` function, base-MATLAB
  substitute, or "left toolbox-gated" with reason), supported syntaxes, algorithm source, call
  sites. Source: spec inventory, research R1–R7, semantics note.
- **Reference value**: source (MathWorks documentation example, SciPy 1.16.3 / statsmodels
  0.15.0 / scikit-learn 1.9.1 script in `references/`, MathWorks function in a parity section),
  input, value, tolerance and why that tolerance.
- **Test requirement change**: test, requirement removed / kept, reason, verification (run on
  base MATLAB, or static when another requirement is unavailable).
- **Known defect**: function, DEFECT/SEVERITY/TRIGGER/OBSERVED/EXPECTED/LINES (III-Defects format),
  recording test.
- **Review finding**: function, finding, resolution (`review.md`).

## Model objects returned to users (FR-005b)

`cobraGeneralizedLinearModel` (returned by `cobraFitglm`) and `cobraLinearModel` (returned by
`cobraFitlm`) are value classes whose properties have the MathWorks names, types and layouts:

| Property | Type / layout | GLM | LM |
|---|---|---|---|
| `Coefficients` | table; variables `Estimate`, `SE`, `tStat`, `pValue`; `RowNames` = coefficient names | ✓ | ✓ |
| `CoefficientNames` | 1×p cell of char; `'(Intercept)'` first | ✓ | ✓ |
| `CoefficientCovariance` | p×p double | ✓ | ✓ |
| `NumCoefficients`, `NumEstimatedCoefficients`, `NumObservations`, `DFE` | double scalars | ✓ | ✓ |
| `Rsquared` | struct: `Ordinary`, `Adjusted` (GLM also `LLR`, `Deviance`, `AdjGeneralized`) | ✓ | ✓ |
| `Deviance`, `LogLikelihood`, `Dispersion`, `DispersionEstimated` | double / logical | ✓ | — |
| `SSE`, `SSR`, `SST`, `RMSE`, `MSE` | double | — | ✓ |
| `Distribution` | struct with `Name` (`'normal'`/`'binomial'`) | ✓ | — |
| `Formula` | char (MathWorks uses a formula object; `char(mdl.Formula)` text is matched) | ✓ | ✓ |
| `Variables` | the input table (or a table built from x, y) incl. excluded rows | ✓ | ✓ |
| `ObservationInfo` | table with `Weights`, `Excluded`, `Missing`, `Subset` | ✓ | ✓ |
| `Fitted` | GLM: table `Response`, `LinearPredictor`, `Probability`; LM: column vector | ✓ | ✓ |
| `LikelihoodPenalty` | char (`'none'`, `'jeffreys-prior'`) | ✓ | — |

Methods: `coefCI(mdl, alpha)` (t(DFE)-based for both, as MathWorks), `predict(mdl, Xnew)`
(response scale; table or matrix input in the variables of the fit), `disp` (summary in the
MathWorks layout). Any other MathWorks method name called on these objects
(e.g. `plotResiduals`, `step`, `anova`, `compact`) raises
`COBRA:cobraGeneralizedLinearModel:unsupportedMethod` naming it.

Validation: values computed once at construction (immutable); NaN rows excluded and flagged in
`ObservationInfo.Missing`; the warnings of R7 are issued during fitting, never on property access.

## Option structs

`cobraFminunc` and `cobraGa` take plain structs whose field names are the MathWorks option names
used at the call sites (current and legacy spellings accepted, unknown names → error naming the
option); full list in [contracts/toolboxFree-api.md](contracts/toolboxFree-api.md).
