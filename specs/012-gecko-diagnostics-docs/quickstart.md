# Quickstart / Validation: enzyme-aware diagnostics + GECKO header docs (012)

Prerequisites: `initCobraToolbox`; mosek + pdco available (`changeCobraSolver`); MATLAB MCP server.
All runs via the MATLAB MCP (`run_matlab_file` / `evaluate_matlab_code`), mosek + pdco.

## V1 — Header documents the GECKO surface (US1, FR-001/FR-002)
`help entropicFluxBalanceAnalysis` (or read the header): OPTIONAL INPUTS lists `model.E`, `model.D`,
`model.evarlb`, `model.evarub`, `model.evarc`, `model.evars` and `param.enzymeEntropyWeight`; OUTPUT
lists `solution.e` and `solution.z_e`. `git diff` of the function shows ONLY comment/header lines
changed (no executable statement).

## V2 — Function still runs unchanged after the header edit
`testEntropicFBAgecko` and `testEntropicFluxBalanceAnalysis` still pass (mosek + pdco); `check_matlab_code`
shows no NEW flags vs the baseline.

## V3 — Non-enzyme diagnostic invariance (US2 characterization, FR-004/SC-004)
Solve a non-enzyme model (ecoli_core or Recon3D consistent subset) at `printLevel = 2` and compare the
printed diagnostic blocks (or recomputed residual values) to the pre-change reference — IDENTICAL under
both backends.

## V4 — Enzyme stationarity residual is small (US2, FR-003/FR-008/SC-003)
Solve `buildEnzymeToy(3,2)` at `printLevel = 2` under mosek + pdco; recompute
`model.evarc + model.E'*y_N + model.D'*y_C + solution.z_e` (sign per backend) and assert its inf-norm
≤ tolerance (target ≤ ~1e-3, same order as the existing optimality residuals), where the enzyme-omitting
expression was several orders larger.

## V5 — Print-only guarantee (FR-005/SC-006)
For both `buildEnzymeToy(3,2)` and a non-enzyme model, the returned `solution.v`, objective,
`solution.stat`, and `solution.origStat` are unchanged within 1e-6 vs the pre-change values.

## V6 — Scope confinement (FR-009)
`git diff --stat develop...HEAD` touches only `entropicFluxBalanceAnalysis.m` and the one new test file
(plus `specs/012/**` and pointer files). No change to `solveCobraEP.m`.
