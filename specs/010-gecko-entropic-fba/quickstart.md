# Quickstart / Validation Guide: Optional GECKO support in entropicFluxBalanceAnalysis

Validation runs MATLAB (via the MCP: `run_matlab_test_file`, `check_matlab_code`,
`run_matlab_file`). Local mosek + pdco available. Run from repo root after `initCobraToolbox`.

## Prerequisites

- On branch `010-gecko-entropic-fba`, implementation applied. mosek and pdco available.

## V1 — Non-GECKO behaviour byte-for-byte unchanged (FR-002/008/010, SC-002)

1. Run `testCharacterizeEntropicFBA` under mosek and pdco; confirm green (`.stat` exact; objective/
   flux/duals within tol vs the pinned pre-change references).
2. Perturbation check: nudge a pinned reference → the suite MUST fail (proves it pins behaviour).
3. `git diff` shows the default (no-`E`) code path is preserved (detection guards the new path).

## V2 — GECKO model solves through the optional path (FR-001/003/003a/005, SC-001)

1. Run `testEntropicFBAgecko` on the minimal committed enzyme fixture under mosek AND pdco.
2. Confirm a feasible solution whose flux + enzyme-usage variables satisfy `[S E; C D]` and the
   `evarlb/evarub` bounds within tol; the objective reflects the `evarc` contribution; enzyme columns
   carry an entropy term (CQ2); canonical `.stat` set, `.origStat` preserved.

## V3 — Both backends (FR-006, SC-003)

1. The GECKO fixture solves under `param.solver='mosek'` and `param.solver='pdco'`; results consistent
   within tol OR any difference explicitly documented (research R6). No silent degradation.

## V4 — Errors on bad fields (FR-004)

1. Feed E/evar/D with mismatched dimensions (or partial specification) → clear error incl. `ME.stack`.

## V5 — Interface unchanged + single function (FR-008/009, SC-004/005)

1. `git diff` shows no change to the `entropicFluxBalanceAnalysis` signature or existing outputs, and
   no change to `solveCobraEP`'s signature.
2. `grep -rl AdaptGECKO src/` → nothing (no forked/parallel function shipped); only
   `prepareEnzymeConstrainedEP.m` added under `entropicFBA/`.

## V6 — Standards + scope (Principle VII/IX)

1. `check_matlab_code` on the edited function + new helper: clean (no NEW flags; pre-existing flags in
   the 1795-line function are out of scope).
2. Diff confined to `src/base/solvers/entropicFBA/**`, `test/verifiedTests/**`, `specs/010-...`.
3. `fluxConc`/`fluxConcNorm` enzyme paths untouched (documented follow-up).

## Done when

V1–V6 pass and the implementation receipt is written under
`specs/010-gecko-entropic-fba/agent-runs/<UTC-timestamp>-<short-name>/`.
