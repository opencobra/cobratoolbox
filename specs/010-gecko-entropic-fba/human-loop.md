# Human Loop State

## Current State
- Status: Implement Part 1 done — characterization net (US2, T001/T003/T004/T005) GREEN + committed.
  GECKO fold-in (US1: T002, T006-T011) + polish PAUSED at the pre-fold-in checkpoint (highest-risk work).
- MATLAB MCP: reachable (R2026a); testCharacterizeEntropicFBA green on ecoli_core under mosek + pdco.
- Receipt: agent-runs/20260715T212225Z-characterization-net/implementation-receipt.md
- Source modified: NONE yet (net is test-only). entropicFluxBalanceAnalysis.m UNCHANGED.
- To resume: T002 (minimal GECKO fixture) → T006 (helper) → T007 (linear fold-in) → T008 (entropy+reindex)
  → T010 (GECKO test both backends) → polish. F1/F2 risks stand.
- (Superseded) Status: Gate 2 approved (all tasks); AWAITING explicit /speckit-implement before any edit
- Active feature directory: specs/010-gecko-entropic-fba
- Last completed bundle: Bundle 2 (plan + tasks + analyze); implementation-review.md written
- Source code modified by this workflow: no

## Core Command Ledger
- constitution:   checked (v1.3.0; not regenerated)
- specify:        invoked (spec.md + checklists/requirements.md)
- clarify:        invoked (CQ1/CQ2/CQ3 resolved; see spec Clarifications Session 2026-07-15)
- checklist:      requirements.md present, 16/16 items pass
- plan:           invoked (research harvest via subagent; plan/research/data-model/quickstart)
- tasks:          authored (15 tasks, 6 phases, T005 hard gate: net green before GECKO fold-in)
- analyze:        invoked (0 blocking; F1/F2 should-fix on the entropy-on-enzymes formulation)
- implement:      pending (gated on explicit /speckit-implement per Principle VI; edits core src/ + test/)

## Key research finding
- The AdaptGECKO fork is a PARTIAL reference only: it represents enzymes as external reactions (no
  E/evar/D) and does NOT apply entropy to enzyme variables. 010 implements the E/evar*/D representation
  (buildOptProblemFromModel semantics) + NEW entropy-on-enzyme handling; harvest fork consistency-skip only.
- Primary risk (F1): entropy on enzyme columns grows nExpCone and re-indexes the post-solve cone-dual
  reordering (Fty_K) + offsets per method/backend — land linear fold-in first, then entropy.

## Constitution Reconciliation Notes
- Implementation gate (Principle VI): a Gate 2 menu choice is NOT sufficient — editing
  entropicFluxBalanceAnalysis.m / tests requires an explicit `/speckit-implement`.
- Additive change to a CORE solver (Principle II): NO public interface / field / default-result change.
- Solver abstraction (Principle IV): route via solveCobraEP/buildOptProblemFromModel; canonical .stat,
  preserve .origStat; Phase-0 mosek+pdco backend audit required.
- MATLAB standards (VII): no evalc suppression, warnings visible, try/catch ME.stack, no nargin,
  openCOBRA header, camelCase. File placement (IX): new src under src/base/solvers/entropicFBA/.
- Characterization mode (III, v1.3.0): Part 3 pins CURRENT non-GECKO behaviour first (regression net).
- Verification: MATLAB MCP (check_matlab_code, run_matlab_test_file, run/evaluate).
- Receipt: specs/010-.../agent-runs/<UTC-timestamp>-<short-name>/implementation-receipt.md.

## Clarify decisions (Session 2026-07-15)
- CQ1: auto-relax consistency check scoped to enzyme-as-substrate reactions when E/D present (no param).
- CQ2: apply entropy weights (g/f) to enzyme-usage variables too (FULL entropic treatment, not linear-only).
- CQ3: minimal committed CI fixture + liver-GECKO full-mode-only (cf. 006).

## Human Decisions
| Date (UTC) | Gate | Option chosen | Consequence |
|---|---|---|---|
| 2026-07-15 | Gate 1 | Continue to plan | Proceed to Bundle 2 (plan + tasks + analyze); no source edits |
| 2026-07-15 | Gate 2 | Approve all tasks (T001–T015) | Scope approved; implementation gated on explicit /speckit-implement (Principle VI) |

## Approved Implementation Scope
- Approved: intent yes (Gate 2, 2026-07-15); edits pending explicit /speckit-implement
- Scope: all (T001–T015), with the T005 hard gate (net green before GECKO fold-in)
- Files allowed (if approved): src/base/solvers/entropicFBA/** (entropicFluxBalanceAnalysis.m additive +
  shared split helper), test/verifiedTests/** (characterization + GECKO fixture)
- Files not allowed: any public-interface/field change; solveCobraEP signature; W-unrelated cleanup

## Pointers
- Implementation receipt(s): (none yet)
- Implementation review: specs/010-gecko-entropic-fba/implementation-review.md (pending)

## Open Risks and Ambiguities
- CQ2 (entropy on enzyme variables) is the more involved formulation; Phase-0 must determine how the
  AdaptGECKO fork handled it and how it folds into solveCobraEP.
- The 94KB entropicFluxBalanceAnalysis is large; additive detection must not perturb the default path.
- Reference fork is external (Recon4IMD kinetics tree) — harvest, do not depend on it at runtime.
- mosek vs pdco representational differences (document, don't silently degrade).
- Hooks: per-phase git auto-commit disabled; no commits without explicit request.
