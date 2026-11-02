# Implementation Review

## Summary

Make COBRA source in `src/`, `test/` and `initCobraToolbox.m` acceptable to RunMat through a bounded set of
MATLAB-equivalent mechanical rewrites. Each rewrite is verified file by file against MATLAB's own parse tree and
code analyzer, and end to end by an unchanged MATLAB `testAll` result. Then measure how far `testAll` gets under
RunMat and report the RunMat defects found. `external/`, `deprecated/` and submodules are untouched.

## Embedded Core Commands Completed
- constitution: checked (v1.7.1)
- specify: done; branch `20261102-153951-runmat-compat` in worktree `../fork-cobratoolbox-runmat`
- clarify: done (4 decisions, including the post-research scope decision)
- checklist: done (`checklists/requirements.md`, all pass)
- plan: done (`plan.md`, `research.md`, `quickstart.md`; no data model or contracts: there are no entities or
  interfaces)
- tasks: done (`tasks.md`, 26 tasks)
- analyze: done (below)

## Cross-Artifact Analysis Summary

| Finding | Class | Resolution |
|---|---|---|
| Spec US1 named RunMat's per-file checker, but research (R5) rejected it for runner discovery | should-fix | fixed in spec.md (US1 test, scenario 1, traceability) |
| Every FR maps to at least one task: FR-001 T008/T012; FR-002 T009; FR-003 T010–T011; FR-004 T013–T014, T018; FR-005 T017; FR-006 T015; FR-007/FR-013 T032; FR-008 T018; FR-009 T007; FR-010 T030; FR-011 T031 and each category task; FR-012 the tools; FR-014 T019 | — | coverage complete |
| Every SC maps to a task: SC-001 T016; SC-002 T031; SC-003 T030; SC-004 T019; SC-005 T020 | — | coverage complete |
| Constitution VII-C exception (empty `catch`) | acceptable | in plan Complexity Tracking, with justification |
| Large mechanical diff; merge friction with open branches (main checkout's uncommitted `greedyExtremeRayBasis.m`) | acceptable risk | one commit per category; tools re-runnable after merging |
| The FR-003 accept check (tree equal except the added `catch`) is defined only in prose in T011 | should-fix during T011 | implement it as an option in `parseTreeEquivalence.m` and record it in quickstart |
| `testAll` under RunMat may still stop at start-up (D4/D6/D10) | acceptable (per Clarification) | the stopping point is the reported result |

No blocking issues.

## Proposed Implementation Scope
- **Tasks proposed**: T001–T020 and T030–T033 (all).
- **First independently testable slice**: Phases 1–3 (T001–T016) plus T030. US1, verified MATLAB-equivalent.
- **Files likely to change**:
  - about 765 files (function terminators), about 141 (separators), 44 (empty `catch`) and an estimated 100–150
    (`name()`) under `src/` and `test/`;
  - `test/testAll.m` and `initCobraToolbox.m`;
  - new files only under `specs/20261102-153951-runmat-compat/`.
- **Files that should NOT change**: `external/**`, `deprecated/**`, every `.gitmodules` path (`binary`,
  `test/models`, `tutorials`, `papers`, the submodules under `external/`), and any file outside `src/`, `test/`,
  `initCobraToolbox.m` and the feature directory.

## Tests and Validation Expected (narrowest first)
1. Per file: `tools/parseTreeEquivalence.m` (identical MATLAB parse tree) for FR-001/FR-002.
2. Per file: `tools/analyzerSnapshot.m`; no new analyzer message (all categories).
3. T017: the four-case MATLAB check of the `PERFORMANCE_REPORT_ON` value.
4. RunMat runner discovery count by category (T016).
5. End to end: MATLAB `testAll` before (T004) and after (T030), the same pass/fail/skip per test.

## Blocking Issues
None.

## Acceptable Risks
- Merge friction, as above.
- Each MATLAB `testAll` run takes more than 60 minutes; both runs happen in the background.
- RunMat may not get past start-up; this is reported.

## Human Approval
- Approved: yes, pending the explicit invocation
- Approved option: "Approve first slice (Recommended)"
- Approved tasks/scope: T001–T016 and T030 (Phases 1–3 plus the MATLAB before/after comparison)
- Implementation path: core implementer (`/speckit-implement`)
- Required implementation invocation per constitution: `/speckit-implement` (or the agent-assign pipeline), or `Run the Spec Kit implementation phase for the active feature`
- Date (UTC): 2026-11-02
