# Implementation Review

## Summary

Add `generateFullRowRankFR` (src/analysis/topology/FR/). It edits a COBRA model until its internal `[F, R]` has full row rank, using these remedies in order:
1. zero-row removal;
2. identical-row lumping (or reaction removal);
3. dead-end removal certified by a left-null witness;
4. as a new **opt-in fallback**, general removal of the problematic species and all their reactions via `removeMetabolites(..., true, 'inclusive')`. This guarantees full row rank.

Every edit and every side effect is reported. It is verified on hand-built fixtures, the in-repo Recon3D (CI), iDopaNeuroC and Recon3T.

## Embedded Core Commands Completed

- constitution: checked v1.6.0
- specify, plan, tasks, analyze: done (2026-10-15)
- clarify: not run; no markers were raised, and the revision's design questions were asked directly
- checklist: requirements.md passes

## Cross-Artifact Analysis Summary

| ID | Severity | Class | Finding | Fix (artifacts only) |
|---|---|---|---|---|
| D1 | CRITICAL | blocking | T041 uses `evalc` to check silence, which also captures the `addReaction` warnings (VII-B) and contradicts the plan's "no `evalc`" | capture with `diary` to a temporary file instead |
| F1 | HIGH | blocking | FR-010 "MUST stop" conflicts with FR-018 "MUST NOT stop" | qualify FR-010 with "when `irreducibleRemedy = 'stop'`" |
| F2 | MEDIUM | should-fix | User Story 2 text says orphans are removed "on the next pass"; they actually go in the same pass as `orphaned` (R13) | reword the spec |
| F3 | MEDIUM | should-fix | The Out of Scope "no exchange changes" bullet is unqualified | name the two documented exceptions |
| U1 | MEDIUM | should-fix | Unclear whether `noInternalReactions` is checked every pass; a per-pass check could break the FR-021 guarantee | check the input only |
| U2 | MEDIUM | should-fix | FR-013's field list is incomplete compared with data-model.md | point FR-013 to data-model.md |
| C1 | LOW | acceptable | Some tasks don't cite the FR/SC IDs they cover | optional |
| C2 | LOW | acceptable | quickstart has no general-removal scenario | add scenario 5 |

## Proposed Implementation Scope

- **Tasks proposed**: T001–T054.
- **First independently testable slice**: Phases 1–3 (T001–T022). This is the MVP: zero rows and lumping, which fully repair iDopaNeuroC and 14 of Recon3T's 15 deficiencies.
- **Files likely to change**:
  - `src/analysis/topology/FR/generateFullRowRankFR.m` (new)
  - `test/verifiedTests/analysis/testTopology/testGenerateFullRowRankFR.m` (new)
  - `specs/20261015-173504-prepare-recon3d-fr/measurements/{fixtureCheck.log, reproduceRecon3T.m, reproduceRecon3T.log}`
  - the receipt
- **Files that should NOT change**: every reused toolbox function (`removeMetabolites`, `removeRxns`, `addReaction`, `checkDuplicateRxn`, `getRankLUSOL`, `findSExRxnInd`, `removeTrivialStoichiometry`, `removeUnusedGenes`, …), plus `external/`, `deprecated/` and `papers/`.

## Tests and Validation Expected

1. Narrowest: `testGenerateFullRowRankFR` fixture cases through the MATLAB MCP session (`run_matlab_test_file`).
2. The in-repo Recon3D case in the same file (CI): 5835/5826 → 5812 at full rank.
3. iDopaNeuroC (skipped if the submodule is absent) and Recon3T (skipped if the file is absent), plus `measurements/reproduceRecon3T.m` with its log.
4. `check_matlab_code` on both new files; `git diff --stat develop` showing only new files.

## Blocking Issues

- None. D1, F1, F2, F3, U1, U2 and C2 were fixed on 2026-10-15, and the re-analysis is clean.
- E1 fixed at Gate 2. C1 (optional ID citations) accepted as is.

## Acceptable Risks

- Recon3T evidence lives outside the repository (R1).
- Three upstream defects are worked around, not fixed (plan § Follow-ups).
- General removal is purely structural, not biological, and is opt-in.

## Human Approval

- Approved: yes
- Approved option: "Fix E1, approve all (Recommended)"
- Approved tasks/scope: T001–T054 (all); E1 fixed in T009 and data-model.md
- Implementation path: set by the user's invocation (core implementer or agent-assign pipeline)
- Required implementation invocation per constitution: `/speckit-implement`, or `/speckit-agent-assign-assign` → `/speckit-agent-assign-validate` → `/speckit-agent-assign-execute`
- Date (UTC): 2026-10-15
