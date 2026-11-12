# Data model: Fix the R2026a fast-mode suite failures

No new data structures are added. This file states the existing state that the feature reads or changes, and the
rules it must keep.

## SOLVERS (global struct, set by `initCobraToolbox`)

- **Fields touched**: `SOLVERS.<name>.installed` and `SOLVERS.<name>.working` (logical) for `glpk`, `pdco`,
  `mosek` and `matlab`, in agent and runmat modes only.
- **Rule (agent and runmat modes)**: both flags are `true` if and only if that solver's local predicate holds
  (research R1); otherwise both stay `false`, the value every solver starts with. `gurobi` is unchanged.
- **Read by**: `getAvailableSolversByType` (via `prepareTest`), which lists a solver only when `.working` is true.
- **Default mode**: unchanged (FR-003).

## Default solver globals

- `CBT_EP_SOLVER`, `CBT_CLP_SOLVER` = `'mosek'` only if mosek's predicate holds; `CBT_NLP_SOLVER` = `'matlab'`
  only if matlab's predicate holds. Otherwise they keep the value they had before (empty in a fresh session).
- LP, MILP and QP defaults are set through `changeCobraSolver(..., 0)`, which already refuses an uninstalled
  solver; unchanged.

## MATLAB path (agent and runmat modes)

- **Invariant after start-up**: no path entry under the thermochemistry base folder contains `<filesep>new`
  (research R2), the same as after default start-up.

## Recorded error case (test fixtures, read-only)

- **Source**: `test/verifiedTests/analysis/testReactingMoieties/data/bondSubgraphReference.mat`
  (`fallbackCases`), `bondSubgraphPeelingReference.mat` (`peelingCases`) and
  `classifySubgraphIsomorphismReference.mat` (`errorCases`).
- **Fields used**: `errorIdentifier`, `errorMessage` (char), plus `outcome` for the extract cases. Fixtures are not
  modified (FR-005).

## Error-equivalence entry (new, a local constant in each parity test)

| Field | Meaning |
|---|---|
| `recordedIdentifier` | identifier in the R2024b fixture |
| `acceptedIdentifier` | identifier a later release raises for the same failure |
| `acceptedMessage` | that release's exact message |
| `release` | release where it was observed (documentation only) |

- **Rule**: a caught error matches a recorded case if and only if its (identifier, message) equals the recorded
  pair, or equals the (`acceptedIdentifier`, `acceptedMessage`) of an entry whose `recordedIdentifier` and
  recorded message belong to that case. Entries are listed in research R4.

## `delta` of `ecosystemQualitativeFVA`

- **Domain**: non-negative scalar (the zero threshold passed to `getQualitativeFluxStates`).
- **Default**: changes from `1e-9` to `getCobraSolverParams('LP', 'feasTol')`, read when the function is called.
- **Explicit value**: used as given, as before.
- **Effect**: the stored outputs `eco.qualVectors` and `eco.fvaResults` keep their meaning and shape. Only the
  zero threshold used to build `qualVectors` changes, and only when the caller gives no `delta`.
