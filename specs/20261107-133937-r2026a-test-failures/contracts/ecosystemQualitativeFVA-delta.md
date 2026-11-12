# Contract: default zero threshold of `ecosystemQualitativeFVA`

Signature unchanged: `eco = ecosystemQualitativeFVA(eco, varargin)`, with the name-value option `'delta'`.

| Call | Zero threshold used | Before this feature |
|---|---|---|
| no `'delta'` | `getCobraSolverParams('LP', 'feasTol')` at call time | `1e-9` |
| `'delta', x` | `x` | `x` |

- The validation of an explicit `delta` (non-negative numeric scalar) is unchanged.
- The help text states the new default, the reason (a flux within the solver's feasibility tolerance of zero
  cannot be told apart from zero by that solver), and how to get the old behaviour (`'delta', 1e-9`).
- `getQualitativeFluxStates` (no solver) keeps its `1e-9` default.
- Approved behaviour change: spec Clarifications 2026-11-12, FR-006, FR-007.
