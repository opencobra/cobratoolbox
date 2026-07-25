# Implementation Receipt

**Feature**: 012-gecko-diagnostics-docs
**Run (UTC)**: 20260717T000000Z (gecko-diagnostics-docs)
**Scope**: COMPLETE — all 15 tasks (T001–T015). Additive, print-and-docs-only change to
`entropicFluxBalanceAnalysis.m` + one new test. Merged series: 010 (GECKO support), 011 (dual/crash/test
fixes), both on develop.

## Prompt

Human-loop run for feature 012. User approved all tasks at Gate 2 and sent `/speckit-implement`.
Feature: (US1) document the GECKO/enzyme surface in the openCOBRA header; (US2) make the printLevel>1
KKT/thermo diagnostics enzyme-aware (print-only), with non-enzyme output unchanged.

## Final response

012 is implemented, green, and Principle-II-safe.

- **US1 (header, comments-only)**: the openCOBRA header now documents `model.E/D/evarlb/evarub/evarc/
  evars`, `param.enzymeEntropyWeight` (linear default; experimental opt-in), and `solution.e`/`solution.z_e`.
  `git diff` confirms zero executable change (SC-002); `check_matlab_code` no new flags.
- **US2 (enzyme-aware diagnostics, print-only, guarded by `hasEnz`)**: in BOTH the pdco and mosek
  `'fluxes'` diagnostic blocks the printed KKT read-out now includes (i) the enzyme-column stationarity
  `|| evarc + E'*y_N + D'*y_C + z_e ||` (a NEW line), (ii) the `E*e` term in the primal mass-balance
  residual, and (iii) the `D*e` term in the coupling primal residual. When no enzyme fields are present
  every addition is a no-op (`enzMB=enzCoup=0`, the enzyme line is not printed), so non-enzyme output is
  byte-identical (verified on Recon3D via testEntropicFluxBalanceAnalysis).

Verified (MATLAB MCP, R2026a, mosek + pdco):
- `testEntropicFBAgeckoDiagnostics` (new) — PASS both backends: non-enzyme diagnostics carry no enzyme
  line (FR-004); GECKO enzyme stationarity printed with residual **1e-8 (pdco, tight)** / **0 (mosek)**;
  print-only (solution at printLevel 2 == printLevel 0 within 1e-6).
- `testEntropicFBAgecko` (010) — PASS. `testEntropicFluxBalanceAnalysis` (011) — PASS, diagnostic blocks
  unchanged.
- Bonus: the pdco coupling primal `|| C*(vf-vr)+s_C-d ||` dropped 4.2 → 7.1e-8 once `D*e` was included.

## Diff summary

- M `src/base/solvers/entropicFBA/entropicFluxBalanceAnalysis.m`: header docs (US1) + guarded enzyme
  terms in the pdco ("Optimality conditions (unregularised)") and mosek ("Optimality conditions
  (biochemistry)") `'fluxes'` blocks (US2). All US2 additions inside `if hasEnz`. No signature/field/
  `.stat`/`.origStat`/solver-call change.
- A `test/verifiedTests/analysis/testEntropicFBAgeckoDiagnostics/testEntropicFBAgeckoDiagnostics.m` (new;
  `check_matlab_code` clean).
- A `specs/012-gecko-diagnostics-docs/**`. No change to `solveCobraEP.m` (FR-009).

## Tests

- testEntropicFBAgeckoDiagnostics — PASS (mosek + pdco): non-enzyme invariance + GECKO enzyme residual
  (pdco < 1e-4) + print-only.
- testEntropicFBAgecko — PASS. testEntropicFluxBalanceAnalysis — PASS.
- check_matlab_code: function 34 flags = baseline (all pre-existing, no new flags at edit sites, SC-005);
  new test 0 flags.

## Deviations (vs tasks.md, recorded per constitution)

- **Block line numbers (T008/T009)**: tasks said pdco ~L420–532 and mosek ~L763+. The baseline (T001)
  showed those are the `fluxesConcentrations` blocks; the DEFAULT `'fluxes'` method actually uses the
  pdco block at ~L1004–1044 ("Optimality conditions (unregularised)") and the mosek block at ~L1369–1440
  ("Optimality conditions (biochemistry)"). The edits were applied to the correct `'fluxes'` blocks.
  Same allowed file — a factual line-number correction, not a scope change.
- **Enzyme reduced-cost sign (T003/R5)**: determined to be **`+z_e` for BOTH backends** — the enzyme
  reduced cost `solution.z_e` is extracted from raw `solution.rcost` (010) exactly like the block's
  external-reaction `z_ve`, and both blocks use `+z_ve` in the working `ce + B'*y_N + z_ve` line. pdco
  confirms `+z_e` decisively on the binding toy (resid 1e-8 with O(1) duals). NB: `buildEnzymeToy(3,2)`
  is NON-binding (enzyme duals ~1e-7 noise), so the residual assertion uses the BINDING `buildEnzymeToy(1,2)`
  (T010 used (1,2) not (3,2)). On the tiny toy mosek's dual is degenerate/ill-conditioned (its own
  external `ce+B'*y_N+z_ve` residual is O(1)), so the tight enzyme-KKT assertion is pdco-only; mosek
  asserts finiteness — matching how 010/011 handled mosek-tiny-toy ill-conditioning.
- **Regularised variants (analyze C1)**: the enzyme stationarity is added to the primary unregularised
  optimality block. The `(regularised)` variant would need a `+ (d1^2)*e` enzyme perturbation term; since
  enzyme columns are LINEAR by default (no entropy/regularisation on them) and enzyme entropy is
  experimental/off, that term is 0 and the regularised enzyme line was intentionally not added.

## Unresolved issues

- mosek coupling primal `|| C*(vf-vr)+s_C-d ||` still shows `Inf` on the tiny toy — a PRE-EXISTING mosek
  slack (`s_C`) extraction/display issue, independent of enzymes (the enzyme `D*e` term is correctly
  included). Out of 012's scope; candidate follow-up.
- Enzyme-entropy path (`param.enzymeEntropyWeight > 0`) diagnostics not covered (experimental; the
  stationarity would gain an entropy term). Deferred with the 010 enzyme-dual-validation follow-up.
- Not pushed (awaiting Gate 3).
