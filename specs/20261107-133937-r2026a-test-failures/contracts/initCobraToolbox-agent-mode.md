# Contract: `initCobraToolbox` agent and runmat modes, and git detection

Public contract surface (constitution Principle II): `initCobraToolbox(updateToolbox, mode)`. The signature, the
accepted modes and the default mode do not change.

## Agent and runmat modes: after the call returns

1. For each `s` in {glpk, pdco, mosek, matlab}: `SOLVERS.(s).installed == SOLVERS.(s).working ==` the local
   predicate of `s` (research R1). No validation problem is solved and no network or license-checkout call is made.
2. `SOLVERS.gurobi` follows the existing `which('gurobi')` rule.
3. `CBT_EP_SOLVER` and `CBT_CLP_SOLVER` are `'mosek'` only when mosek's predicate holds; `CBT_NLP_SOLVER` is
   `'matlab'` only when matlab's predicate holds.
4. No entry of `path` under the thermochemistry base folder contains `<filesep>new`.
5. Console output is unchanged: the single completion summary line.
6. Elapsed time grows by no more than 1 s (median of 5 runs; SC-002). The measured cost of the added checks is
   about 0.07 s.

## Default mode

7. Solver probing, path handling and output are unchanged (FR-003), except item 8.
8. Git detection: the "initialise repository and add remote" block runs only when `[CBTDIR filesep '.git']` is
   neither a folder nor a file. In a linked worktree (`.git` is a file) it does not run, and the shared
   repository's configuration is unchanged (FR-008, SC-005).

## Unchanged

- Idempotency guard (`CBT_INITIALIZED`), the `updateToolbox` semantics, the submodule gating and path saving.
