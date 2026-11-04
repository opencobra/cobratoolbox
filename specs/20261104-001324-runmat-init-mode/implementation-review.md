# Implementation Review

## Summary

Add a `'runmat'` value to `initCobraToolbox`'s `mode`, and a `COBRA_RUNMAT=1` switch to `testAll`, so that both
files run their own start-up under RunMat. Every RunMat-specific code path is recorded as compatibility debt under
the new constitution clause VIII-Runtime (v1.8.0):
- a marker on each path;
- a register in `test/runtimeCompatibility/RunMat/`;
- reproducers;
- a re-check script that reports which workarounds RunMat no longer needs.

Planning research found that RunMat v0.6.2 cannot run toolbox functions that read `nargin` or a global, or that
are called with fewer arguments than declared (D27–D29). Success under RunMat is therefore narrowed to reaching
the first toolbox call and stopping on a registered defect (human decision "Narrow: mode + debt now").

## Embedded Core Commands Completed
- constitution: amended 1.7.1 → 1.8.0 (VIII-Runtime, IX role map, plan-template check); not yet committed
- specify: done; clarify: done (3 questions, plus the blocker decision during planning); checklist: done, all pass
- plan: done (plan.md, research.md, data-model.md, contracts/, quickstart.md; CLAUDE.md plan pointer updated)
- tasks: done (25 tasks)
- analyze: done (below)

## Cross-Artifact Analysis Summary

| ID | Class | Finding | Resolution |
|---|---|---|---|
| I1 | should-fix | FR-002 still requires initialisation to complete under RunMat; this contradicts the narrowed SC-001 | reword FR-002 (offered at Gate 2) |
| I2 | should-fix | US2 scenario 1 says no RunMat-specific code runs in default mode, but the D5 `eval` and the MATLAB-equivalent rewrites run in every mode | reword US2 scenario 1 (offered) |
| I3 | should-fix | traceability names a new `testInit/` test; the plan renames `testInstall/testInitCobraToolboxAgentMode.m` | fix the row (offered) |
| C1 | should-fix | FR-012 (supersedes the previous FR-008) has no task | fold into T021 (offered) |
| C2, U1, U2 | acceptable | sslVerify check for runmat mode; baseline commit wording; RunMat driver location | tighten in tasks (offered) |
| G1 | blocking for implementation only | the constitution amendment is not committed (FR-011 gate) | commit at the end of this bundle |

## Proposed Implementation Scope
- **Tasks proposed**: T001–T025.
- **First independently testable slice**: Phases 1–3 (T001–T012). That is the `'runmat'` mode in
  `initCobraToolbox`, the extended test, and the register with its reproducers and re-check script.
- **Files likely to change**:
  - `initCobraToolbox.m` and `test/testAll.m`;
  - `test/verifiedTests/base/testInstall/testInitCobraToolboxAgentMode.m`, renamed to `testInitCobraToolbox.m`;
  - the new `test/runtimeCompatibility/RunMat/**`;
  - the erratum in `specs/20261102-153951-runmat-compat/reports/`;
  - this feature's folder.
- **Files that should NOT change**: `external/**`, `deprecated/**`, every `.gitmodules` path, every other `src/**`
  file, and the uncommitted `findStoichConsistentSubset.m` change that was already in the working tree.

## Tests and Validation Expected (narrowest first)
1. `COBRA_TESTS=testInitCobraToolbox testAll` (MATLAB): runmat-vs-agent equality, the error for `'runmat'` with
   `updateToolbox`, and the invalid-mode message.
2. The four-case `PERFORMANCE_REPORT` check (MATLAB).
3. `test/runtimeCompatibility/RunMat/recheckRunMat.sh` (RunMat): markers match the register one to one.
4. The RunMat driver and `runmat_testall.sh` with `COBRA_RUNMAT=1`: stopping points are registered blocking
   defects.
5. The full MATLAB `testAll`, before and after: identical statuses (SC-003).

## Blocking Issues
- None for approval. G1 (commit the amendment) must happen before implementation starts.

## Acceptable Risks
- Each MATLAB `testAll` run takes more than 60 minutes and needs full clones.
- The RunMat binary lives in another session's scratch area. Its path is recorded, and the quickstart says how
  to rebuild it.
- Under v0.6.2, SC-001 and SC-002 are measurements of a stopping point, not of completion.

## Human Approval
- Approved: no
- Approved option:
- Approved tasks/scope:
- Required implementation invocation per constitution: `/speckit-implement` or the agent-assign pipeline
- Date (UTC):
