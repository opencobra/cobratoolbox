# Contract: CI outputs

The CI job (`testAllCI_step1.yml`) MUST continue to emit its existing outputs and add coverage +
skip-gate outputs. This is the observable contract reviewers and downstream steps depend on.

## Preserved (no regression — FR-009)

- `testReport.junit.xml` — JUnit written by `testAll.m` under `COBRA_CI=1`.
- `ctrf/ctrf-report.json` — CTRF conversion (`junit-to-ctrf`), uploaded as artifact `testReport`.
- `pr_number.txt` — artifact `pr_number`.
- Build red/green driven only by test failures (`sumFailed>0`), unchanged.

## Added

| Output | Form | Guarantee |
|---|---|---|
| Coverage artifact | `coverage.xml` (Cobertura) + `coverage_html/` + `coverage.json`, uploaded via `actions/upload-artifact` | ALWAYS uploaded when coverage measurement succeeds (FR-002) |
| Coverage % in log | `Covered Lines: … Coverage: …%` (already printed by `testAll.m:290`) | Present whenever `MOCOV_PATH`/`JSONLAB_PATH` are set |
| Codecov upload | `codecov/codecov-action` with `files: ./coverage.xml`, `fail_ci_if_error: false`, `continue-on-error: true` | best-effort; MUST NOT fail the build (FR-004, SC-006) |
| Skip-count warning | GitHub `::warning::` annotation when `skipped > maxSkipped` | never fails the build (FR-008) |

## Failure semantics

- Coverage *measurement* failure (MoCov errors) → the coverage step is reported failed/absent
  explicitly; it MUST NOT silently show a green build with no coverage (FR-004). The pass/fail
  test report still completes.
- Coverage *upload* (Codecov) failure/unreachable → logged, step continues, build unaffected.
- Skip-gate step → warn only; exits 0 regardless.
