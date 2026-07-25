# Phase 1 Data Model: CI coverage + skip-gate

This feature is CI/test-infrastructure; its "entities" are the small data objects that flow
through the pipeline, not database records.

## Entity: Coverage report

- **Represents**: line coverage of the toolbox source for one CI run.
- **Produced by**: MoCov, from `profile('info')`, over `src/` (`testAll.m:266-271`).
- **Fields / forms**:
  - `coverage.json` — MoCov JSON: `source_files[]` each with a `coverage` vector; covered lines
    = `nnz(coverage)`, total = `length(coverage)` (`testAll.m:280-290`).
  - `coverage.xml` — Cobertura XML (NEW output) consumed by Codecov.
  - `coverage_html/` — human-browsable report (existing).
  - Derived scalar: coverage % = `sum(covered)/sum(total)*100` (already printed).
- **Lifecycle**: regenerated every run; uploaded as a CI artifact; NOT committed.
- **Delta**: coverage % vs. the base branch — computed by Codecov when fed; when Codecov is
  unavailable the absolute % from the artifact is the fallback (no delta).

## Entity: Test requirement declaration

- **Represents**: the resources a single test needs, so `runTestSuite` can skip it gracefully.
- **Carried by**: a `prepareTest(...)` call near the top of a `test/verifiedTests/**/test*.m`.
- **Fields (keys, from `prepareTest.m:88-111`)**: `needsLP|QP|MILP|MIQP|NLP|EP|CLP` (bool),
  `requireOneSolverOf|requiredSolvers|useSolversIfAvailable|excludeSolvers` (cell of solver
  names), `requiredToolboxes|toolboxes` (license-feature names), `minimalMatlabSolverVersion`,
  `needsUnix|Linux|Windows|Mac` (bool), `needsWebAddress|needsWebRead` (url/bool),
  `requiredSoftwares` (cell of binaries).
- **State transition**: absent requirement met → test **runs** (assertions unchanged); requirement
  unmet → `prepareTest` throws `COBRA:RequirementsNotMet` → `runTestSuite` marks it **Skipped**.
- **Validation rule**: adding a declaration MUST NOT change a test's assertions or outcome when
  its requirements are present (FR-010); "none needed" is a valid, recorded outcome.

## Entity: Backfill audit record

- **Represents**: the per-test outcome of the requirement audit (auditability, FR-006).
- **Form**: `specs/001-ci-coverage-gating/audit/backfill-audit.csv`.
- **Fields**: `testPath, category, detectedSignals, declarationAdded, noneNeeded, notes`.
- **Lifecycle**: written during implementation; a planning/record artifact (not shipped in `src`).

## Entity: Skip baseline

- **Represents**: the maximum expected number of skipped tests for the CI environment.
- **Form**: `test/verifiedTests/.skip-baseline.json`
  `{ "maxSkipped": <int>, "recordedOn": "<YYYY-MM-DD>", "environment": "gurobi-only Docker",
    "note": "update when the CI solver/toolbox set intentionally changes" }`.
- **Compared against**: `skipped=` in `testReport.junit.xml` (`testAll.m:214`).
- **State transition**: `skipped ≤ maxSkipped` → silent pass; `skipped > maxSkipped` → GitHub
  `::warning::` annotation (build NOT failed — FR-008).
- **Update rule**: human-updatable when an environment change legitimately raises skips.

## Relationships

```
prepareTest declaration ──(unmet)──▶ COBRA:RequirementsNotMet ──▶ runTestSuite marks Skipped
      │                                                                   │
      │                                                     sum ─▶ testReport.junit.xml skipped=
      ▼                                                                   ▼
  backfill-audit.csv (record)                             skip-gate step vs .skip-baseline.json ─▶ ::warning::

MoCov(profile over src) ─▶ coverage.json / coverage.xml / coverage_html ─▶ artifact (always) + Codecov (best-effort)
```
