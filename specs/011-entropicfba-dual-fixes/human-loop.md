# Human Loop State

## Current State
- Status: Bundle 3 (implementation) COMPLETE — all 19 tasks done, receipt written. Full net GREEN
  (mosek + pdco). AWAITING Gate 3.
- Active feature directory: specs/011-entropicfba-dual-fixes
- Last completed bundle: Bundle 3
- Source code modified by this workflow: yes (additive/corrective; Principle-II-safe). Diff confined to
  the four allowed files (entropicFluxBalanceAnalysis.m, solveCobraEP.m, testEntropicFBAgecko.m,
  testEntropicFluxBalanceAnalysis.m) + spec artifacts + CLAUDE.md pointer. Not committed.

## Bundle 3 outcome (2026-07-16)
- US1: `message` defined for all optimizeCbModel statuses; err_argument_dimension traced to
  buildOptProblemFromModel.m:315 (names.con), fixed in-scope by naming the toy coupling constraint.
- US2: `{k}`→`{1}`; Recon3D restricted to its stoichiometrically consistent subset (10 inconsistent
  mets under mosek LP) so entropicFBA accepts it — test now green (stat=1, ~2.5s solve).
- US3: **fixed** (not characterized). Reduced-cost sign error in the mosek `res2` KKT residual
  (`res2 = -2z`); backend-specific correction (mosek uses -sol.rcost). Residual 1.45→3e-7 (GECKO),
  1187→2.5e-8 (non-enzyme). Diagnostic-only change; primal / sol.rcost / .stat / .origStat unchanged.
- Receipt: agent-runs/20260716T203644Z-entropicfba-dual-fixes/implementation-receipt.md
- check_matlab_code: no NEW flags at edited sites (SC-005). Deviations recorded in tasks.md + receipt.

## Core Command Ledger
- constitution:   checked (v1.3.0; not regenerated)
- specify:        invoked (spec.md + checklists/requirements.md; validated 16/16)
- clarify:        invoked (1 question — US3 effort ceiling; Session 2026-07-16)
- checklist:      invoked (checklists/correctness.md, 19 requirement-quality items)
- plan:           invoked (plan.md + research.md + data-model.md + quickstart.md; Constitution Check PASS)
- tasks:          authored (19 tasks, 5 phases, T011 HARD GATE: net green before dual-residual change)
- analyze:        invoked (0 CRITICAL/HIGH; 1 MEDIUM F1 prepareTest-vs-existence-gate, 3 LOW; 100% coverage)
- implement:      invoked (/speckit-implement; all 19 tasks done; net green mosek+pdco; receipt written)

## Feature summary
Three concerns discovered during feature 010-gecko-entropic-fba (merged on develop):
1. (P1) `entropicFluxBalanceAnalysis.m` `otherwise` branch (~L1699): inner `switch
   solution_optimizeCbModel.stat` has only cases 0/1, no default → undefined `message` crash when the
   EP is infeasible but the LP pre-check passed (GECKO enzyme cap). Plus `solveCobraEP` mosek
   infeasibility diagnostic sizes `prob.names` from the pre-enzyme dimension → `err_argument_dimension`.
2. (P2) `testEntropicFluxBalanceAnalysis.m:29` references undefined `k` → errors standalone before
   the model loads; only "passes" in CI because a prior test leaves a stray `k`.
3. (P3) `testEntropicFBAgecko` mosek dual residual = 1.45 vs `optTol = 5e-5` (pdco clean). Enzyme-column
   dual/KKT residual `res2 = grad + Aty + rcost` in `solveCobraEP:1072`; 010 flagged it (F1), deferred.

## Human Decisions
| Date (UTC) | Gate | Option chosen | Consequence |
|---|---|---|---|
| 2026-07-16 | Clarify (US3) | Pursue the fix | Bundle 3 drives the mosek dual residual below optTol (deeper cone-dual reconstruction changes allowed), characterize-and-tolerate only if a correct fix is infeasible |
| 2026-07-16 | Gate 1 | Continue to plan/tasks/analyze | Proceed to Bundle 2 (plan + tasks + analyze + implementation-review.md); no source edits; stop at Gate 2 |
| 2026-07-16 | Gate 2 | Approve all (T001–T019) | Scope approved (intent); implementation still gated on an explicit /speckit-implement (Principle VI) before any edit |

## Approved Implementation Scope
- Approved: intent yes (Gate 2, 2026-07-16); edits pending explicit /speckit-implement (Principle VI)
- Scope: all (T001–T019), with the T011 HARD GATE (net green before the dual-residual change)
- Files allowed (if approved): src/base/solvers/entropicFBA/** ; test/verifiedTests/base/testEntropicFBA/** ;
  test/verifiedTests/analysis/testEntropicFBAgecko/** ; (regression only) test/verifiedTests/analysis/testCharacterizeEntropicFBA/**
- Files not allowed: any public-interface/field change; solveCobraEP/entropicFluxBalanceAnalysis signature;
  .stat/.origStat semantics; default (no-enzyme) feasible-path results

## Constitution Reconciliation Notes
- Implementation gate (Principle VI): editing entropicFluxBalanceAnalysis.m / solveCobraEP.m / tests
  requires an explicit `/speckit-implement`; a Gate 2 menu choice alone is NOT sufficient.
- Backward compat (Principle II): NO public interface / field / default-result / status-semantics change.
- Solver abstraction (Principle IV): route via solveCobraEP; canonical .stat, preserve .origStat;
  Phase-0 mosek config-surface audit for the dual-residual investigation.
- MATLAB standards (VII): warnings visible (VII-B), try/catch ME.stack (VII-C), no evalc suppression
  (VII-A), openCOBRA header on new/revised functions (VII-E), camelCase/filesep (VII-G).
- File placement (IX): src under src/base/solvers/entropicFBA/; tests under test/verifiedTests/**.
- Receipt: specs/011-.../agent-runs/<UTC-timestamp>-<short-name>/implementation-receipt.md (mandatory).
- Hooks: auto_execute_hooks=true. Per-phase git.commit hooks deferred (commit at bundle boundaries /
  on explicit request), per feature-010 precedent. before_specify git.feature hook created the branch.

## Checklist status
- checklists/requirements.md (spec quality): 16/16 pass.
- checklists/correctness.md (requirement quality): majority pass; deferred-to-plan items — CHK004
  (VII-C/A/E obligations → plan Constitution Check), CHK005 (exact mosek name array → research),
  CHK006 (message wording → plan), CHK007 (fix-infeasible fallback trigger → plan), CHK012 (numeric
  dual-residual target → plan), CHK016 (enzyme-cause isolation in fixture → test design).

## Pointers
- Spec: specs/011-entropicfba-dual-fixes/spec.md
- Implementation review: (pending Bundle 2)
- Implementation receipt(s): (pending Bundle 3)
- Related memory: entropicfba-infeasible-message-bug, testentropicfba-undefined-k-bug,
  solvecobralp-gurobi-inf-or-unbd-param-bug

## Open Risks and Ambiguities
- US3 fix pursuit touches a core solver's dual/cone reconstruction (highest risk); must not alter the
  primal solution or regress the non-enzyme dual residual (~2 on Recon3D).
- No independent golden output for GECKO → assert primal feasibility + KKT + status strings.
- Infeasible fixture must be infeasible specifically due to the enzyme cap (LP-feasible pre-check).
