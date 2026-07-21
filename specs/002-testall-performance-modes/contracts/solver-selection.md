# Contract — fast-mode solver selection in `prepareTest`

Edit to `src/base/install/prepareTest.m`. The **public input/output contract is
unchanged**; only the default solver breadth in fast mode changes.

## Rule

Let `explicitMulti = any of {requiredSolvers, useSolversIfAvailable} is non-empty`
(these already cause multi-solver cell arrays today).

| Mode | `explicitMulti` | Result |
|------|-----------------|--------|
| full | any | unchanged from today |
| fast | true | unchanged (all requested solvers returned) — preserves cross-solver tests (FR-005) |
| fast | false | behave as `useMinimalNumberOfSolvers = true` → default solver per class only |

An explicit `useMinimalNumberOfSolvers` passed by a caller is still honoured in both
modes. An optional explicit opt-out (e.g. `'allSolvers', true`) forces the full set
even in fast mode for a test that must stay cross-solver but does not use
`requiredSolvers`.

## Invariants

- Requirement checks (needsLP/MILP/QP, toolboxes, OS, web) and the
  `COBRA:RequirementsNotMet` skip behaviour are unchanged — fast mode never turns a
  skip into a pass or vice-versa.
- Output struct shape unchanged (one cell field per solver class).
- No solver option/parameter/default is modified; only how many solvers are listed.
- Full mode is bit-for-behaviour identical to the pre-feature function.

## Coverage consequence

Tests that loop over `prepareTest`'s returned lists but assert solver-independent
results execute one solver in fast mode instead of N. Tests that request all solvers
explicitly are untouched. This is the primary source of the fast-mode speedup and the
bounded (≤5 pp) coverage reduction.
