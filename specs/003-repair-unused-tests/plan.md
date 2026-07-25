# Implementation Plan: Repair unused / non-contributing tests to enlarge coverage

**Branch**: `003-repair-unused-tests` | **Date**: 2026-07-13 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/003-repair-unused-tests/spec.md`

## Summary

Enlarge coverage by making non-contributing tests contribute — repairing tests broken
by their own bugs, broadening over-strict requirement declarations, installing the one
freely-obtainable external dependency that helps here (`lrs`), converting genuinely
un-runnable tests to clean skips, and removing a stray test whose target does not
exist. No assertion is weakened; no function-under-test behaviour changes beyond the
minimal fix to a test's own bug. Done = a pass-count increase with every identified
test accounted for (coverage confirmed in CI).

## Technical Context

**Language/Version**: MATLAB (R2026a locally; harness R2014b+)

**Primary Dependencies**: COBRA test harness (`runTestSuite`/`runScriptFile`),
`prepareTest` (requirement declarations), the bundled/apt `lrs` binary, and the
functions each repaired test targets.

**Testing**: Each touched test is re-run via the MATLAB MCP server before/after; must
pass on locally available solvers or skip cleanly. No new coverage tooling.

**Target Platform**: Linux (this machine); CI runs full mode (feature 002).

**Project Type**: MATLAB library test-suite maintenance (single project).

**Performance Goals**: N/A (correctness/coverage feature, not performance).

**Constraints**: Never weaken/remove/loosen an assertion or expected value (FR-002);
no public-interface/scientific change (FR-003); repaired tests behave in both fast and
full modes (FR-010); env-install changes surfaced to the user (FR-011); tests needing
absent deps skip cleanly, not error (FR-005).

**Scale/Scope**: The identified working set — ~10 fail/error + ~28 skip + 1 stray.
Environment bounds the env-install portion to the `lrs` trio (see research.md); the
rest of the env-dependent tests become clean skips.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Scientific code quality**: Repairs are confined to test code and requirement
  declarations. No model math, solver formulation, expected value, or public interface
  changes. A test's numeric assertions and tolerances are preserved exactly; solver-
  specific assertions are guarded to the solver they are valid for, never loosened.
- **Testing and reproducibility**: Narrowest check per test — run it via
  `mcp__matlab__run_matlab_test_file`/`runScriptFile` before and after and confirm the
  outcome (pass on available solvers, or clean skip). Whole-suite pass-count delta
  recorded; source-line coverage confirmed in CI (feature 001).
- **User experience and diagnostics**: A repaired-but-dependency-limited test reports a
  clean `COBRA:RequirementsNotMet` skip instead of an error. The `lrs` install step is
  surfaced as an explicit command for the user to run, not executed silently.
- **Performance and numerical integrity**: N/A for runtime; numerical integrity is
  protected by the no-loosening rule. No debug/verification step is removed.
- **External-solver configuration audit**: No solver configuration/option/default is
  changed. Requirement broadenings only widen *which* solver class satisfies a test;
  the solver's own settings are untouched. `lrs` is invoked through the existing
  `lrsInterface` with its current settings.
- **Spec-driven scope control**: Edit — individual `test/verifiedTests/**/test*.m`
  files (the identified failures + broadenable skips), and remove
  `test/test_myfunction.m`. Read-only — all `src/` functions under test (a function
  fix is a separate feature), expected-result fixtures. The bounded edit set is
  enumerated in tasks.md after per-test triage.
- **MATLAB coding standards**: Warnings stay visible; error stacks propagate; no
  `evalc` suppression, no `nargin` logic; fixes follow the openCOBRA test conventions
  (prepareTest requirement declaration, assert-with-tolerance).
- **Parameter-setting fidelity**: N/A (no ported/literate output).
- **Artifact placement**: Only existing test files edited/removed in place; no new
  artifacts except spec docs. Any `lrs` install touches the system, not the repo.

## Project Structure

### Documentation (this feature)

```text
specs/003-repair-unused-tests/
├── plan.md · research.md · spec.md · quickstart.md
├── audit/repair-catalogue.md   # per-test triage → outcome (from Phase 0)
├── checklists/requirements.md · human-loop.md · implementation-review.md
└── tasks.md                    # /speckit-tasks
```

### Source Code (repository root)

```text
test/verifiedTests/**/test*.m   # EDIT: the identified fail/skip tests (bounded set)
test/test_myfunction.m          # REMOVE: stray, target function absent
# read-only: src/** functions under test; expected-result .mat fixtures
# system (not repo): lrs binary (apt lrslib / bundled binary on PATH)
```

**Structure Decision**: Pure test-suite maintenance — edits stay in
`test/verifiedTests/**`, one stray file removed. No `src/` function is modified
(a genuine function bug would be a separate feature). The only non-repo action is the
user-surfaced `lrs` install.

## Complexity Tracking

| Deviation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|--------------------------------------|
| Env-install (lrs) touches system state | User chose the widest scope (Gate: "also attempt env-dependent"); lrs is freely installable and unblocks 3 real tests | Leaving lrs as a skip was the narrower option; rejected because the user explicitly opted to attempt env deps, and lrs is the one that is actually obtainable here. Mitigated by surfacing the install command rather than running it silently. |
