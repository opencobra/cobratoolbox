# Implementation Review

## Summary

Feature 010 adds optional GECKO/enzyme-constrained support to `entropicFluxBalanceAnalysis`
(additive, behind `E`/`evar*`/`D` detection), applying entropy weights to enzyme variables (CQ2),
scoped consistency relaxation (CQ1), under both mosek and pdco (`fluxes` method), with a
characterization net pinning current behaviour first. Research showed the external AdaptGECKO fork is
only a partial reference (external-reaction representation, no enzyme entropy) — 010 implements the
cleaner `E`/`evar*`/`D` representation + new entropy-on-enzyme handling. Requirements/plan/tasks are
consistent (100% coverage, 0 blocking).

## Embedded Core Commands Completed

- constitution: checked (v1.3.0) · specify: invoked · clarify: invoked (CQ1–CQ3) · checklist: 16/16 ·
  plan: invoked (research/plan/data-model/quickstart) · tasks: authored (15 tasks) · analyze: invoked (below)

## Cross-Artifact Analysis Summary

- Coverage: ~20 requirements (FR + SC) → 15 tasks, **100%**; T005 hard gate (net green before fold-in).
- Findings: **F1** (should-fix, HIGH-risk) entropy-on-enzymes reindexing (`Fty_K`/offset bookkeeping)
  per method/backend — mitigated by landing the linear fold-in (T007) first, then entropy (T008), with
  the net re-run after each; enzyme DUAL correctness is the weakest-verified part. **F2** (should-fix)
  the GECKO fixture has no independent golden output, so T010 asserts constraint satisfaction +
  optimality (KKT) conditions, not pinned golden values. **F3/F4** acceptable (representation choice;
  `fluxes`-only scope). **0 blocking.**

## Proposed Implementation Scope

- **Tasks proposed**: T001–T015 (all), with the T005 gate.
- **First independently testable slice**: **US2 characterization net (T001–T005)** — the regression
  baseline; independently valuable (pins current entropic-FBA behaviour, which has no direct test today).
- **Files likely to change**:
  - EDIT `src/base/solvers/entropicFBA/entropicFluxBalanceAnalysis.m` (additive, `fluxes` method)
  - NEW `src/base/solvers/entropicFBA/prepareEnzymeConstrainedEP.m`
  - NEW tests + minimal fixture under `test/verifiedTests/`
  - NEW receipt under `agent-runs/`
- **Files that should NOT change**: default (no-`E`) path/results, `entropicFluxBalanceAnalysis`
  signature/existing outputs, `solveCobraEP` signature, any existing model field meaning, the
  `fluxConc`/`fluxConcNorm` enzyme paths, the AdaptGECKO fork (reference only).

## Tests and Validation Expected (narrowest first)

Via MATLAB MCP (mosek + pdco):
1. `testEntropicFluxBalanceAnalysis` — pins current `fluxes` non-GECKO behaviour (both backends); re-run
   after T007 and T008 as the regression guard.
2. `testEntropicFBAgecko` — minimal fixture through the GECKO path; assert constraint satisfaction +
   optimality (not golden values), evarc objective, entropy on enzymes, `.stat`/`.origStat`, both backends.
3. dimension-mismatch error test; `check_matlab_code`; existing entropic-FBA tests; quickstart V1–V6.

## Blocking Issues

None.

## Acceptable Risks

- F1 (should-fix): entropy-on-enzymes reindexing is the hard part; isolate via linear-first (T007) then
  entropy (T008); enzyme dual correctness weakly verified — assert primal constraint satisfaction strongly.
- F2 (should-fix): no golden GECKO reference → assert feasibility + KKT, not pinned outputs.
- F3/F4: `E`/`evar*`/`D` representation (partial fork harvest) and `fluxes`-only scope — by design,
  documented; `fluxConc` enzyme support is a follow-up.

## Human Approval

- Approved: intent yes (edits pending explicit implement invocation)
- Approved option: **Approve all tasks** (Gate 2, 2026-07-15)
- Approved tasks/scope: **all (T001–T015)**, with the T005 hard gate
- Required implementation invocation per constitution: explicit `/speckit-implement` (Principle VI) —
  a Gate 2 menu choice alone does NOT authorize edits. This feature edits a core `src/` solver function.
- Date (UTC): (pending)
