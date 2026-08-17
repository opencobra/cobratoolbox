# Implementation Review

## Summary

Feature 011-entropicfba-dual-fixes makes three corrective changes to the entropic-FBA solver stack,
all surfaced during feature 010 (merged on `develop`), each additive/corrective with no public
interface, model-field, or `.stat`/`.origStat` change:

1. **(US1, P1)** Infeasible enzyme-constrained EP must not crash. In `entropicFluxBalanceAnalysis.m`
   the `otherwise` branch (~L1699) leaves `message` undefined when `optimizeCbModel` returns a status
   other than 0/1; and `solveCobraEP.m`'s mosek infeasibility diagnostic sizes its name arrays from
   the pre-enzyme dimension (`err_argument_dimension`). Fix both → return `stat = 0` with a populated
   `messages`.
2. **(US2, P2)** `testEntropicFluxBalanceAnalysis.m:29` indexes `solverPkgs.EP{k}` with `k`
   undefined → errors standalone. Fix the index; assertions unchanged.
3. **(US3, P3, highest risk)** The mosek GECKO dual-optimality residual (1.45 vs `optTol = 5e-5`;
   pdco clean). Per the Session 2026-07-16 clarification, **pursue the fix**: research established
   that for mosek `res2` equals the linearized-cone stationarity over the full augmented variable
   vector (auxiliary exp-cone rows carry O(1) contributions), whereas the clean pdco branch checks
   the true reduced-coordinate KKT — the ~2 on non-enzyme Recon3D and 1.45 on GECKO are the same
   coordinate artifact, not enzyme-specific. Fix = report the mosek dual residual in reduced/
   structural coordinates (matching pdco); characterize-and-tolerate only per the research.md R1
   decision rule if the residual proves genuine.

Requirements/plan/tasks are consistent (100% coverage, 0 blocking findings). The plan enforces
010-style gate ordering: land the two low-risk fixes + the strictly-infeasible test first, re-run the
regression net, then the higher-risk dual-residual work with the net re-run after.

## Embedded Core Commands Completed

- constitution: checked (v1.3.0) · specify: invoked · clarify: invoked (1 Q — US3 = pursue the fix) ·
  checklist: two checklists (requirements 16/16; correctness 19 items) · plan: invoked
  (research/plan/data-model/quickstart) · tasks: authored (19 tasks) · analyze: invoked (below).

## Cross-Artifact Analysis Summary

- Coverage: 16 requirements (10 FR + 6 SC) → 19 tasks, **100%**; HARD GATE at T011 (net green before
  the dual-residual change).
- Findings: **0 CRITICAL, 0 HIGH, 1 MEDIUM, 3 LOW.**
  - **F1 (MEDIUM, should-fix in-implementation)** FR-010 asks for `prepareTest` graceful-skip, but the
    existing 010 GECKO test gates via `exist('mosekopt','file')` + pdco fallback; the new infeasible
    case (T007) inherits that pattern. Resolution: accept the existing existence-gate (consistent with
    the file) or add `prepareTest`; decide in T007, record in the receipt. Not blocking.
  - **F2 (LOW)** T014 must detect the dual-optimality warning without suppressing it (VII-B) — use
    `lastwarn`/warning-state inspection, never `warning('off',…)`.
  - **F3 (LOW)** The numeric characterize-fallback tolerance is evidence-driven (intentional per the
    clarification); T012 records it.
  - **F4 (LOW)** FR-007/FR-008 map to review/assertion invariants (T017, T013/T014), not new tasks —
    correct by nature.
- No constitution MUST violation; Principle VI gate, receipt (T019), MATLAB standards (VII), and
  solver abstraction (IV) all honored.

## Proposed Implementation Scope

- **Tasks proposed**: T001–T019 (all), with the T011 HARD GATE.
- **First independently testable slice**: **US1 (T005–T008)** — the crash fix (highest value); with
  the trivial **US2 (T009–T010)** it forms the low-risk MVP that lands before US3.
- **Files likely to change** (the only four permitted, FR-009):
  - EDIT `src/base/solvers/entropicFBA/entropicFluxBalanceAnalysis.m` (define `message`, ~L1699)
  - EDIT `src/base/solvers/entropicFBA/solveCobraEP.m` (mosek diagnostic name sizing; dual residual)
  - EDIT `test/verifiedTests/base/testEntropicFBA/testEntropicFluxBalanceAnalysis.m` (undefined `k`)
  - EDIT `test/verifiedTests/analysis/testEntropicFBAgecko/testEntropicFBAgecko.m` (infeasible case +
    deterministic dual outcome)
  - NEW receipt + baseline under `specs/011-entropicfba-dual-fixes/agent-runs/`
- **Files that should NOT change**: any public signature/param/model-field/`.stat`/`.origStat`; the
  default (no-enzyme) feasible-path results; `testEntropicFluxBalanceAnalysis` (rerun only, edit only if a
  regression guard forces it); `optimizeCbModel`, `parseMskResult`, anything outside `entropicFBA/`.

## Tests and Validation Expected (narrowest first)

Via MATLAB MCP (mosek + pdco):
1. `testEntropicFluxBalanceAnalysis` — standalone, no undefined `k`, reaches the function (V1/SC-002).
2. `testEntropicFBAgecko` — new strictly-infeasible case returns `stat==0` + non-empty `messages`, no
   crash (V2/SC-001); feasible + binding cases unchanged; dual-optimality outcome deterministic
   (V3/SC-003).
3. `testEntropicFluxBalanceAnalysis` — no-enzyme `fluxes` path within the 010 baseline; non-enzyme dual
   residual not regressed (V5/SC-004).
4. `check_matlab_code` on the four files — no NEW flags vs baseline (V6/SC-005).
5. Diff review — no interface/field/status-semantics change (SC-006); diff confined to the four
   files (FR-009).

## Blocking Issues

None.

## Acceptable Risks

- **US3 dual-residual fix touches a core solver's post-solve KKT diagnostic** (highest risk). Mitigated
  by: landing it LAST behind the T011 hard gate; the fix targets a *reported* quantity only (primal,
  `.stat`, `.origStat` unchanged — asserted by T015/T017); the research.md decision rule falls back to
  characterize-and-tolerate if the residual proves genuine; the non-enzyme residual must not regress.
- **No independent golden GECKO output** — assert primal feasibility + KKT + status strings, not pinned
  duals (inherited from 010).
- **F1 (MEDIUM)** prepareTest-vs-existence-gate — resolved in T007, no rework.

## Human Approval

- Approved: intent yes (Gate 2, 2026-07-16); edits pending explicit `/speckit-implement`
- Approved option: **Approve all (T001–T019)**
- Approved tasks/scope: **all (T001–T019)**, with the T011 HARD GATE (net green before the
  dual-residual change)
- Required implementation invocation per constitution: explicit `/speckit-implement` (Principle VI) —
  a Gate 2 menu choice alone does NOT authorize edits. This feature edits core `src/` solver functions.
- Date (UTC): 2026-07-16
