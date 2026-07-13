# Implementation Review

## Summary

Feature `002-testall-performance-modes` adds a fast (default) vs full test-suite
execution mode plus an opt-in profiling report, without changing any scientific
assertion, expected value, tolerance, or public interface. Fast mode removes
redundant work (multi-solver loops on solver-independent tests, large-SBML
re-parsing, dead waits, duplicated model builds); full mode reproduces today
exactly and is what CI runs. The design centres on a new mode resolver
(`getCobraTestMode`) and reuses `prepareTest`'s existing `useMinimalNumberOfSolvers`
capability as the main trimming hook.

## Embedded Core Commands Completed

- constitution: checked (v1.2.0; reconciliation applied)
- specify: ✅ spec.md
- clarify: ✅ 2 clarifications integrated (CI=full; ≤5 pp coverage)
- checklist: ✅ requirements.md all-pass
- plan: ✅ plan.md + research.md + data-model.md + contracts/ + quickstart.md
- tasks: ✅ tasks.md (T001–T020)
- analyze: ✅ 0 critical, 1 high (disclosed constitution tradeoff), 4 low

## Cross-Artifact Analysis Summary

100% requirement→task coverage (18 requirements, 20 tasks, 0 unmapped). One HIGH
finding: fast-as-default makes cross-solver re-verification default-off locally, a
tension with the Performance principle's "default-on verification" language. It is
disclosed in plan.md Complexity Tracking and mitigated (CI runs full; ≤5 pp coverage
bound; documented revert). This is a Gate 2 acceptance decision, and the user
directed fast-default explicitly.

## Proposed Implementation Scope

- **Tasks proposed**: T001–T020.
- **First independently testable slice (MVP)**: US1 = Phase 1 (T001) + Phase 2
  (T002–T004) + Phase 3 (T005–T013) — the fast-by-default speedup, verifiable via
  quickstart §2–§3 (per-test pass in both modes; fast subset faster; coverage ≤5 pp).
- **Files likely to change**: `src/base/install/getCobraTestMode.m` (new),
  `src/base/install/prepareTest.m`, `test/testAll.m`, a bounded set of
  `test/verifiedTests/**/test*.m` (testGpSampler, testSimulatePairwiseInteractions,
  testReadSBML, testTest4HumanFctExt, testMultiProductionEnvelopeInorg,
  testModelBorgifier, testWriteSBML, testJoinModelsPairwiseFromList), a new
  `test/verifiedTests/base/testInstall/testGetCobraTestMode.m`, `.gitignore`,
  `documentation/source/**` (contributor note).
- **Files that should NOT change**: solver internals, `src/` algorithm/analysis
  code, expected-result `.mat` fixtures, other tests' assertions.

## Tests and Validation Expected (narrowest first)

1. `testGetCobraTestMode.m` — unit test of the resolver (all branches, incl.
   CI-forces-full). Run via `mcp__matlab__run_matlab_test_file`.
2. Each edited test run in BOTH modes — pass/fail/skip identical to pre-edit.
3. Representative-subset fast-vs-full — wall-time lower; coverage ≤5 pp drop;
   `testFVA`/`testdynamicRFBA` still fail/error (not masked).
4. `mcp__matlab__check_matlab_code` on all new/edited files.

## Blocking Issues

None (0 critical).

## Acceptable Risks

- C1 (fast-default verification tradeoff) — accepted subject to Gate 2 sign-off;
  mitigated by CI-full + ≤5 pp + documented revert.
- Coverage delta and speedup are hardware/solver-dependent; validated on the local
  multi-solver machine and bounded, not guaranteed identical elsewhere.

## Human Approval

- Approved: intent yes (edits still gated on explicit implement invocation)
- Approved option: "Approve all tasks" (Gate 2)
- Approved tasks/scope: T001–T020 (full scope); C1 fast-default tradeoff accepted
- Required implementation invocation per constitution: explicit `/speckit-implement`
  (or the exact override phrase) — a Gate 2 menu pick alone does not authorize edits.
  **Awaiting this invocation before any source edit.**
- Date (UTC): 2026-07-13
