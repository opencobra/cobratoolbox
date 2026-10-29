# Implementation Review

## Summary

Add `param.initialBasis` to `greedyExtremeRayBasis`. A supplied partial non-negative basis of
the requested nullspace is validated (exact sign, the derived accuracy target), reduced to a
maximal independent subset in supplied order, kept as immutable leading rows of `Zpos`
through every restart, and completed with only the missing `nullity - kept` extreme rays
(moietyRank Prop. prop:mr:left-basis (a)/(b)). In the targeted step, a `+d` vertex that is
accurate but dependent is re-solved with `-d` before a failure is counted (Prop. (c)). Status
reports the supplied/kept/dependent/rejected partition, `raysAdded`, `nSignRetries` and
`nLPSolves`. One source file and its existing test are edited.

## Embedded Core Commands Completed

- **constitution**: checked (v1.6.0)
- **specify**: done; 2 clarifications by the user (sign retry always on; right-mode
  `n x k`)
- **clarify**: done; 2 questions (kept > nullity: keep all and warn; `status.nLPSolves`)
- **checklist**:
  - `requirements.md` 16/16.
  - `numerics-compat.md` 35/35. It found 8 gaps, and the spec was amended. CHK017, CHK032
    and CHK035 were resolved in the plan (research R1, R5, R6).
- **plan**: done. Artifacts: research.md (R1–R9), data-model.md, contracts/, quickstart.md.
  Constitution Check PASS, with no Complexity Tracking.
- **tasks**: 26 tasks (T001–T026), 8 phases.
- **analyze**:
  - 0 critical, 0 high, 2 medium, 3 low.
  - Remediated with the user's approval: C1 (CI exercises the fixtures without gurobi),
    I1 (SC-005 wording), G1 (diff-scope check in T025), I2 (SC-004 excluded fields).
  - U1 (two defensive branches cannot be reached by a fixture) is accepted, to be reported
    in the receipt.

## Cross-Artifact Analysis Summary

Every FR and SC maps to at least one task. FR-014 and FR-015 (`findExtremePool` and the
solver untouched) are now verified by T025's diff-scope check. No constitution conflict.

**One planning decision changes the feature prompt.** Research R1 drops the separate
"`|g'w|` below tolerance" trigger.
- A dependent vertex always has `g'w ≈ 0`, so the rank test already catches every case the
  value test would.
- A zero-valued but independent vertex is a valid new ray (when `delta > 1`), and a value
  trigger would discard it.
- So the retry fires on the dependence verdict only. `g'w` is printed at `printLevel > 2`.
- Fixture 4 behaves identically under either reading. FR-008 is amended accordingly.
- **Please confirm this at Gate 2.**

## Proposed Implementation Scope

- **Tasks proposed**: T001–T026 (all).
- **First independently testable slice (MVP)**: Phases 1–3, T001–T011.
  - Baseline record on unmodified code.
  - Inert status scaffolding.
  - US1: fixtures 1–3 left mode, i.e. completing a supplied basis.
- **Files likely to change**:
  - `src/analysis/topology/extremeRays/optimalRays/greedyExtremeRayBasis.m`
  - `test/verifiedTests/analysis/testTopology/testGreedyExtremeRayBasis.m`
  - New, in the feature directory only: `baselineRecord.m`, `baseline-summary.md`,
    `fixture6RealModelCheck.m`, `fixture6RealModelCheck-expected.md`,
    `agent-runs/.../implementation-receipt.md`.
- **Files that should NOT change**:
  - `findExtremePool.m`, `nullspaceAccuracyTarget.m`, `checkNullspaceBasis.m`,
    `getRankLUSOL`.
  - Solver interfaces under `src/base/solvers/`.
  - `optimalExtremePoolDriver.m`, the root `.gitignore`, `external/`, `deprecated/`.

## Tests and Validation Expected (narrowest first)

1. `testGreedyExtremeRayBasis.m`, extended:
   - fixtures 1–4, left and right mode;
   - rejection reasons, dependence, and status fields on every path;
   - fixtures 1 and 3 run with any solver, fixtures 2 and 4 per vertex-returning solver.
2. `baselineRecord('compare')`: value-identical `Zpos`/`Z` and status on ecoli_core
   (left and right) and iDopaNeuroC, against a baseline recorded BEFORE any source edit.
   Divergence is allowed only where `nSignRetries > 0`.
3. `testCheckNullspaceBasis`, `testNullspaceAccuracyTarget`, unchanged.
4. `fixture6RealModelCheck.m` (local only):
   - iDopaNeuroC: 50 random `Zpos` rows plus one dependent sum row.
   - Recon3D: 125 random rows of `model.L` (251 x 5824, a previously computed `Zpos`). No
     atom-mapped iDopaNeuroC or Recon3D exists in the repo, so the prompt's fallback route
     applies.
5. `check_matlab_code` and `matlab-core:matlab-review-code` on both edited files.

Execution is via the `matlab` MCP server: R2026a, attached and verified. The `matlab-shared`
server currently fails to attach.

## Blocking Issues

None.

## Acceptable Risks

- The sign retry is a default-behaviour change (approved: always on). It is inert unless a
  dependent `+d` vertex occurs, and it is recorded as a header NOTE.
- Fixture 2's added ray is one of two admissible rays. The tests accept either.
- With full-support kept rows, the support-zeroing branch yields a zero objective, which is
  existing behaviour. The stall escalation then reaches the targeted step after 5 attempts.
  This costs a few LPs but cannot affect correctness.
- `getRankLUSOL` hides LUSOL's `inform` (open project defect). The independence decision for
  supplied rows inherits the same risk as the in-loop decision. Out of scope.
- The `keptExceedsNullity` and `keptRowFailedVerification` branches are defensive and are
  not exercised by any fixture (analyze U1). They will be listed as not verified.

## Human Approval

- Approved: yes
- Approved option: Approve all T001–T026 (Recommended); research R1 accepted
- Approved tasks/scope: T001–T026; implementation path `/speckit-implement`
- Required implementation invocation per constitution: `/speckit-implement`, or the
  agent-assign pipeline `/speckit-agent-assign-assign` → `/speckit-agent-assign-validate` →
  `/speckit-agent-assign-execute`, in series
- Date (UTC): 2026-10-26
