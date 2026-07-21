# Implementation Review

## Summary
Feature 012 is an additive, **print-and-docs-only** change to
`src/base/solvers/entropicFBA/entropicFluxBalanceAnalysis.m`: (US1/P1) document the GECKO/enzyme
surface added by 010 in the openCOBRA header; (US2/P2) make the `printLevel>1` KKT/thermo diagnostic
blocks enzyme-aware (enzyme stationarity `evarc + E'*y_N + D'*y_C + z_e` + the `E*e`/`D*e` primal
terms), guarded by `hasEnzymes` so non-enzyme output is byte-identical. No `solveCobraEP`/solver-call
change; no returned-solution change. Third feature in the entropic-FBA series (010, 011 merged).

## Embedded Core Commands Completed
- constitution: checked (v1.3.0, not regenerated)
- specify: done (spec.md; requirements.md 16/16)
- clarify: done (3 decisions → recommended defaults; Clarifications 2026-07-17)
- checklist: spec-quality requirements.md 16/16 (proportionate; no separate requirement-quality checklist)
- plan: done (plan.md + research.md + data-model.md + quickstart.md; Constitution Check PASS)
- tasks: done (15 tasks, 5 phases, T007 HARD GATE)
- analyze: done (0 blocking; 1 should-fix C1; 100% coverage)

## Cross-Artifact Analysis Summary
100% FR/SC/AC → task coverage; no unmapped tasks; no constitution violations. Single should-fix (C1):
tasks T008/T009 should state explicitly whether the `(regularised)` diagnostic variants also receive an
enzyme term (enzymes are linear ⇒ no d1²/d2² perturbation analog) — an implementation-time decision to
record in the receipt, not a blocker.

## Proposed Implementation Scope
- Tasks proposed: T001–T015 (Setup/Baseline, US1 header, US2 characterization HARD GATE, US2 enzyme
  diagnostics, Polish).
- First independently testable slice: **US1 (T004–T005)** — header docs, comments-only, zero numerical
  risk. US2 (T006–T011) is the substantive slice, gated behind the T007 non-enzyme characterization.
- Files likely to change: `src/base/solvers/entropicFBA/entropicFluxBalanceAnalysis.m`;
  `test/verifiedTests/analysis/testEntropicFBAgeckoDiagnostics/testEntropicFBAgeckoDiagnostics.m` (new).
- Files that should NOT change: `solveCobraEP.m` or any other solver source; the 010/011 tests; any
  public interface / model-field / solution-field-meaning / `.stat`/`.origStat`.

## Tests and Validation Expected (narrowest first)
1. `testEntropicFBAgeckoDiagnostics` (new) — non-enzyme characterization (T007 gate) + GECKO enzyme
   residual-small assertion + print-only solution-unchanged (mosek + pdco).
2. `testEntropicFBAgecko` (010) — still green (both backends).
3. `testEntropicFluxBalanceAnalysis` (011) — still green standalone.
4. `check_matlab_code` on the edited function — no NEW flags vs baseline (SC-005).

## Blocking Issues
None.

## Acceptable Risks
- C1 (regularised-variant enzyme-term explicitness) — resolve at implementation, document in receipt.
- Backend dual sign convention differs (mosek vs pdco, per 011) — mitigated by T003 (record sign) +
  T008/T009 (verify per backend); the GECKO assertion + non-enzyme characterization catch a wrong sign.
- Enzyme `model.E = 0` in the toy fixture ⇒ the `E*e` mass-balance term is exercised as zero; the
  stationarity + coupling `D*e` terms ARE exercised (toy has `model.D = -kcat`). A nonzero-`E` case is
  not required for CI but the residual derivation covers it.

## Human Approval
- Approved: intent yes (Gate 2)
- Approved option: Approve all tasks (T001–T015)
- Approved tasks/scope: all (T001–T015), T007 HARD GATE (non-enzyme characterization before enzyme edits)
- Required implementation invocation per constitution: explicit `/speckit-implement` (Principle VI) — NOT yet given
- Date (UTC): 2026-07-17
