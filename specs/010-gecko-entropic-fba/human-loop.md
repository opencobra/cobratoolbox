# Human Loop State

## Current State
- Status: Bundle 3 (implement) COMPLETE — all 15 tasks green. Bundle 4 verification done; AWAITING Gate 3.
- MATLAB MCP: reachable (R2026a). testEntropicFluxBalanceAnalysis + testEntropicFBAgecko both GREEN under
  mosek + pdco. Legacy testEntropicFluxBalanceAnalysis (Recon3D) passes on the non-GECKO path (its own
  pre-existing undefined-`k` bug worked around with k=1; file untouched by 010, recorded to memory).
- Receipts: agent-runs/20260715T212225Z-characterization-net/ (Part 1) +
  agent-runs/20260716T000000Z-gecko-fold-in/ (Part 2, this run).
- Source modified: entropicFluxBalanceAnalysis.m (+52/-3, all guarded by hasEnzymes; no-E path unchanged)
  + NEW prepareEnzymeConstrainedEP.m. No AdaptGECKO fork shipped in src/.
- KEY DECISION (overrides initial CQ2): enzyme columns are LINEAR by default; entropy is opt-in via
  param.enzymeEntropyWeight > 0 (experimental). No scientific basis to maximise enzyme entropy by default.
- Active feature directory: specs/010-gecko-entropic-fba
- Last completed bundle: Bundle 3 (implementation) + Bundle 4 (verification)
- Source code modified by this workflow: yes (additive; Principle-II-safe)

## Core Command Ledger
- constitution:   checked (v1.3.0; not regenerated)
- specify:        invoked (spec.md + checklists/requirements.md)
- clarify:        invoked (CQ1/CQ2/CQ3 resolved; see spec Clarifications Session 2026-07-15)
- checklist:      requirements.md present, 16/16 items pass
- plan:           invoked (research harvest via subagent; plan/research/data-model/quickstart)
- tasks:          authored (15 tasks, 6 phases, T005 hard gate: net green before GECKO fold-in)
- analyze:        invoked (0 blocking; F1/F2 should-fix on the entropy-on-enzymes formulation)
- implement:      invoked (/speckit-implement; all 15 tasks done — net + linear fold-in + entropy opt-in)

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
| 2026-07-15 | Checkpoint | Full fold-in now (accept the risk) | After net committed, proceed to the highest-risk GECKO fold-in |
| 2026-07-16 | Correction | Enzyme entropy: option, not default | No scientific basis to maximise E/D entropy → linear default, param.enzymeEntropyWeight opt-in (revised CQ2) |

## Approved Implementation Scope
- Approved: intent yes (Gate 2, 2026-07-15); edits pending explicit /speckit-implement
- Scope: all (T001–T015), with the T005 hard gate (net green before GECKO fold-in)
- Files allowed (if approved): src/base/solvers/entropicFBA/** (entropicFluxBalanceAnalysis.m additive +
  shared split helper), test/verifiedTests/** (characterization + GECKO fixture)
- Files not allowed: any public-interface/field change; solveCobraEP signature; W-unrelated cleanup

## Pointers
- Implementation receipt(s): agent-runs/20260715T212225Z-characterization-net/implementation-receipt.md
  (Part 1) + agent-runs/20260716T000000Z-gecko-fold-in/implementation-receipt.md (Part 2)
- Implementation review: specs/010-gecko-entropic-fba/implementation-review.md

## Bundle 4 verification (2026-07-16)
- Diff scope confined to src/base/solvers/entropicFBA/**, test/verifiedTests/**, specs/010/** (+ .specify/feature.json). ✓
- No AdaptGECKO* fork shipped in src/. ✓  Signature of entropicFluxBalanceAnalysis unchanged. ✓
- testEntropicFluxBalanceAnalysis — PASS (mosek + pdco); non-GECKO ||v|| within 1% of baseline. ✓
- testEntropicFBAgecko — PASS (mosek + pdco): feasible, binding (v_R2==kcat*e), dimension-error. ✓
- Legacy testEntropicFluxBalanceAnalysis (Recon3D) — PASS on non-GECKO path (k=1 workaround). ✓
- check_matlab_code — only pre-existing flags; no NEW flags at edit sites; helper clean. ✓
- Commits on branch: cd8c1f53e (net) + 95c9f85f5 (linear fold-in) + ca42ec095 (entropy opt-in). Not pushed.
- Follow-ups → memory: entropicfba-infeasible-message-bug, testentropicfba-undefined-k-bug,
  entropy-dual validation on full-mode liver-GECKO (deferred).

## Open Risks and Ambiguities
- CQ2 (entropy on enzyme variables) is the more involved formulation; Phase-0 must determine how the
  AdaptGECKO fork handled it and how it folds into solveCobraEP.
- The 94KB entropicFluxBalanceAnalysis is large; additive detection must not perturb the default path.
- Reference fork is external (Recon4IMD kinetics tree) — harvest, do not depend on it at runtime.
- mosek vs pdco representational differences (document, don't silently degrade).
- Hooks: per-phase git auto-commit disabled; no commits without explicit request.
