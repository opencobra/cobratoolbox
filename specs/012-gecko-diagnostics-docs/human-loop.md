# Human Loop State

## Current State
- Status: Bundle 3 (implementation) COMPLETE — all 15 tasks green; receipt written. AWAITING Gate 3.
- Active feature directory: specs/012-gecko-diagnostics-docs
- Last completed bundle: Bundle 3 (implementation) + Bundle 4 verification (inline)
- Source code modified by this workflow: yes (additive, print-and-docs-only; Principle-II-safe)

## Bundle 3 outcome (2026-07-17)
- US1: header documents the GECKO/enzyme surface (comments-only; zero executable diff, SC-002).
- US2: enzyme-aware diagnostics in the pdco (~L1004-1044) and mosek (~L1369-1440) 'fluxes' blocks,
  guarded by hasEnz: enzyme stationarity line `evarc + E'*y_N + D'*y_C + z_e` (+z_e both backends) plus
  the E*e / D*e primal terms. pdco residual 1e-8, mosek 0. Non-enzyme output byte-identical (FR-004).
- Sign: +z_e for both (solution.z_e is raw rcost like the block's z_ve). Verified on binding toy(1,2).
- Bonus: pdco coupling primal 4.2 -> 7.1e-8 once D*e included.
- Receipt: agent-runs/20260717T000000Z-gecko-diagnostics-docs/implementation-receipt.md (+ baseline.md)
- check_matlab_code: 34 flags (all pre-existing, no new); new test clean. Deviations in receipt.

## Core Command Ledger
- constitution:   checked (v1.3.0; not regenerated)
- specify:        invoked (spec.md + checklists/requirements.md 16/16 pass, no NEEDS CLARIFICATION)
- clarify:        invoked (3 decisions resolved to recommended defaults; Clarifications Session 2026-07-17)
- checklist:      spec-quality requirements.md re-validated 16/16 (proportionate; no separate requirement-
                  quality checklist generated for this print-and-docs feature)
- plan:           invoked (plan.md + research.md + data-model.md + quickstart.md; Constitution Check PASS)
- tasks:          authored (15 tasks, 5 phases; T007 HARD GATE: non-enzyme characterization before enzyme edit)
- analyze:        invoked (0 blocking; 1 should-fix C1 regularised-variant explicitness; 100% coverage)
- implement:      invoked (/speckit-implement; all 15 tasks done; net green mosek+pdco; receipt written)

## Feature summary
Third feature in the entropic-FBA series (010 added optional GECKO/enzyme support; 011 fixed the
infeasible-crash / legacy-test / mosek dual-residual defects — both merged to develop + pushed).
012 is additive, print-and-docs-only, on entropicFluxBalanceAnalysis.m:
- US1 (P1): document the GECKO/enzyme surface in the openCOBRA header (model.E/D/evarlb/evarub/evarc/
  evars, param.enzymeEntropyWeight, solution.e/solution.z_e). Comments only.
- US2 (P2): make the printLevel>1 KKT/thermo diagnostic blocks enzyme-aware (ce + E'*y_N + D'*y_C +
  z_ve and the enzyme mass-balance/coupling terms); print-only, non-enzyme output byte-identical
  (characterization, Principle III).

## Three flagged defaults for clarify
1. Enzyme-KKT: derive analytically + verify vs both backends' duals (default) vs empirically match.
2. Blocks in scope: ALL printLevel>1 biochemistry/derived/thermo blocks (default) vs only "Thermo".
3. Test strategy: GECKO residual-small assertion + non-enzyme characterization (default) vs docs-only.

## Constitution Reconciliation Notes
- Implementation gate (Principle VI): editing entropicFluxBalanceAnalysis.m / adding a test requires an
  explicit `/speckit-implement`; a Gate 2 menu choice alone is NOT sufficient.
- Backward compat (Principle II): NO public interface / model-field / solution-field-meaning / default
  (non-enzyme) result OR printed-diagnostic change; Part 2 is print-only.
- Solver abstraction (Principle IV): diagnostics computed from the already-returned solution; NO change
  to solveCobraEP or any solver call.
- MATLAB standards (VII): VII-E Sphinx-parseable header, VII-B warnings visible, VII-A no evalc
  suppression, VII-G camelCase/filesep. File placement (IX): src stays under src/base/solvers/entropicFBA/.
- Characterization (III): Part 2 pins the CURRENT non-enzyme printed-diagnostic output first.
- Receipt: specs/012-.../agent-runs/<UTC-timestamp>-<short-name>/implementation-receipt.md (mandatory).
- Allowed edit set (FR-009): entropicFluxBalanceAnalysis.m + one test under test/verifiedTests/.
- Hooks: auto_execute_hooks=true; per-phase git.commit deferred to bundle boundaries / on request.

## Human Decisions
| Date (UTC) | Gate | Option chosen | Consequence |
|---|---|---|---|
| 2026-07-16 | Route (post-011) | Close 011, then new feature | 011 merged+pushed; 012 opened for GECKO docs + enzyme-aware diagnostics |
| 2026-07-16 | 011 Gate 3 | Merge to develop & push | 011 landed on develop (4388f554a) |
| 2026-07-17 | 012 Clarify | All 3 to recommended defaults | Enzyme-KKT analytic+verify; ALL blocks in scope; residual-assertion + characterization |
| 2026-07-17 | 012 Gate 1 | Continue to plan/tasks/analyze | Proceed to Bundle 2 (plan + tasks + analyze); no source edits; stop at Gate 2 |
| 2026-07-17 | 012 Gate 2 | Approve all tasks (T001–T015) | Scope approved (intent); implementation still gated on an explicit /speckit-implement (Principle VI) before any edit |
| 2026-07-17 | /speckit-implement | Explicit implement invocation | Bundle 3 authorized; all 15 tasks implemented + verified |
| 2026-07-17 | 012 Gate 3 | Merge to develop & push | 012 merged to develop (1dd2d6890) and pushed |

## Approved Implementation Scope
- Approved: intent yes (Gate 2, 2026-07-17); edits pending explicit /speckit-implement (Principle VI)
- Scope: all (T001–T015), with the T007 HARD GATE (non-enzyme characterization green before enzyme edits)
- Files allowed (if approved): src/base/solvers/entropicFBA/entropicFluxBalanceAnalysis.m ;
  one new test under test/verifiedTests/<category>/
- Files not allowed: solveCobraEP.m or any other solver source; any public-interface / model-field /
  solution-field-meaning / default-result / non-enzyme printed-diagnostic change

## Pointers
- Spec: specs/012-gecko-diagnostics-docs/spec.md
- Implementation review: specs/012-gecko-diagnostics-docs/implementation-review.md
- Implementation receipt(s): agent-runs/20260717T000000Z-gecko-diagnostics-docs/implementation-receipt.md
  (+ baseline.md)
- Related memory: entropicfba-infeasible-message-bug, testentropicfba-undefined-k-bug,
  buildoptproblemfrommodel-namescon-dim-bug

## Open Risks and Ambiguities
- Deriving the enzyme-column KKT correctly for both backends (mosek/pdco dual conventions differ — 011
  found an opposite rcost sign in solveCobraEP res2); the diagnostics must use the same convention the
  returned solution.z_e / duals follow.
- Characterization must prove the non-enzyme diagnostic output is byte-identical — the change must be
  strictly guarded by enzyme-presence.
- Print-only guarantee: no returned-field change; verify v/objective/.stat/.origStat within 1e-6.
