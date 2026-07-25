# Phase 0 Research: CI coverage + skip-gate

Configuration-surface audit and decisions for the tools this feature introduces or activates.
Grounded in the actual repo state (see file:line references) and the CI environment (headless
`matlab` Docker image, `COBRA_CI=1`, gurobi + open-source solvers only).

## Decision 1 — Reuse the harness's existing MoCov coverage path

- **Decision**: Do not build a new coverage mechanism. Activate the one already in
  `test/testAll.m:64-71` and `:263-291` by provisioning MoCov + jsonlab and setting
  `MOCOV_PATH`/`JSONLAB_PATH` in the CI job.
- **Rationale**: `testAll.m:266-271` already calls
  `mocov('-cover','src','-profile_info','-cover_json_file','coverage.json','-cover_html_dir','coverage_html','-cover_method','profile','-verbose')`
  and prints `Covered Lines / Total Lines / Coverage %` (`:290`). The only reason coverage never
  runs is that `MOCOV_PATH`/`JSONLAB_PATH` are unset in `testAllCI_step1.yml`. Reusing it honours
  the spec constraint FR-003 and minimizes change.
- **Alternatives considered**: MATLAB's built-in `matlab.unittest` + `CodeCoveragePlugin`
  (Cobertura) — rejected because the harness runs tests as *scripts* via `runTestSuite.m`, not
  `matlab.unittest` suites, so adopting it would re-architect the harness (violates FR-009).

## Decision 2 — MoCov configuration surface & the added Cobertura output

- **MoCov options in play**: `-cover <dir>` (instrument `src`), `-cover_method profile` (uses
  `profile('info')`; MoCov also supports `file` line-instrumentation), `-cover_json_file`,
  `-cover_html_dir`, and — the one we add — `-cover_xml_file coverage.xml` (Cobertura XML).
- **Decision**: Add `'-cover_xml_file','coverage.xml'` to the existing `mocov(...)` call in
  `testAll.m` (single additive argument). Keep `-cover_method profile` (already used and correct
  for a script-run suite; `profile on` is set at `testAll.m:101`).
- **Rationale**: Codecov ingests Cobertura XML natively; producing it from the same MoCov run
  avoids a separate json→xml conversion tool. `coverage.json` + `coverage_html/` remain the
  self-contained artifact (FR-002). Adding an output path does not change any test outcome
  (behaviour-preserving, FR-010).
- **Cross-check vs environment**: `-cover_method profile` needs the MATLAB profiler, available
  headless; no display needed. Instrumenting only `src` (not `external/`, `test/`) keeps the
  coverage denominator correct (matches the spec's "toolbox source" and the existing call).
- **Alternative**: convert `coverage.json` → Cobertura in a node/python CI step — rejected as an
  extra moving part when MoCov emits Cobertura directly.

## Decision 3 — Provision MoCov + jsonlab in the CI Docker run

- **Constraint**: `testAllCI_step1.yml:41-76` runs a `docker run … matlab` with the repo mounted
  at `/work`; MATLAB has no assumed internet inside the container. MoCov/jsonlab are not in the
  repo today.
- **Decision**: Clone pinned MoCov + jsonlab on the **self-hosted runner host** (a step before
  `docker run`) into a workspace-local tooling dir (e.g. `$GITHUB_WORKSPACE/.ci-tools/MOcov` and
  `.ci-tools/jsonlab`), then pass `-e MOCOV_PATH=/work/.ci-tools/MOcov -e
  JSONLAB_PATH=/work/.ci-tools/jsonlab` into the container. Pin to a specific tag/commit for
  reproducibility.
- **Rationale**: Host-side clone keeps the container network-free, keeps the tools out of the
  toolbox source tree (Principle IX — not vendored into `src/`/`external/`), and is easy to cache.
  `.ci-tools/` is gitignored.
- **Alternatives**: (a) add MoCov/jsonlab as git submodules under `external/` — rejected:
  `external/` is read-only feature-wise (Principle V) and this is CI tooling, not a toolbox
  runtime dependency. (b) `git clone` inside the container — rejected: assumes container network
  and complicates the entrypoint.

## Decision 4 — Codecov upload is best-effort (never blocks the build)

- **codecov-action surface**: `token` (needed for private/self-hosted reliability),
  `files`/`file` (point at `coverage.xml`), `fail_ci_if_error` (default historically false;
  MUST be explicitly `false`), `flags`, `name`, `verbose`.
- **Decision**: Add a `codecov/codecov-action@v4` step with `files: ./coverage.xml`,
  `fail_ci_if_error: false`, `continue-on-error: true`, and the token from repo secrets (absent
  token ⇒ step degrades, build unaffected). Always precede it with an unconditional
  `actions/upload-artifact` of `coverage.xml` + `coverage_html/` so coverage is visible even when
  Codecov is skipped/unreachable (FR-002, FR-004, SC-006).
- **Rationale**: Satisfies "always a self-contained artifact + Codecov best-effort" and the
  Constitution III CI-reproducibility constraint (no hard dependency on an external service).
  `codecov.yml` already exists (comment layout only) and starts working once a report is fed.
- **Cross-check**: self-hosted runner + `permissions: contents: read` — Codecov PR comments need
  the app/token configured; if not present, the artifact path still delivers the number.

## Decision 5 — Skip-count gate reads the existing JUnit `skipped=` count

- **Source of truth**: `testAll.m:214` writes `<testsuite … skipped="%d" …>` with
  `numSkipped = sum(resultTable.Skipped)` (`:204`); `runTestSuite.m` sets `Skipped` from the
  `COBRA:RequirementsNotMet` error id. So the skip count is already in `testReport.junit.xml`.
- **Decision**: Add a CI step (bash/node, after the MATLAB run) that parses `skipped=` from
  `testReport.junit.xml`, reads the committed baseline `test/verifiedTests/.skip-baseline.json`
  (`{ "maxSkipped": <n>, "recordedOn": "<date>", "note": "..." }`), and emits
  `::warning::` (GitHub annotation) when `skipped > maxSkipped`. It **exits 0 regardless**
  (`continue-on-error` as a belt-and-braces). No MATLAB change needed for the gate.
- **Rationale**: Reuses existing accounting (FR-007), keeps the gate out of the MATLAB process,
  and enforces the resolved flag/warn-only policy (FR-008). The baseline is human-updatable when
  the environment intentionally changes.
- **Alternative**: hard-fail on exceed — explicitly deferred by the clarify decision.
- **Note on exit code**: `testAll.m:343-345` already makes the build red only on `sumFailed>0`;
  skips never affect it. The new step preserves that (warn only).

## Decision 6 — Backfill audit method (repeatable, conservative, auditable)

- **Scope**: 169 ungated `test*.m` (base 51, analysis 42, reconstruction 38, visualization 17,
  dataIntegration 12, design 9) — counted via `find test/verifiedTests -name 'test*.m'` (260)
  minus files that call `prepareTest` (91, counted with `grep` per file; note a whole-tree
  `rg -l prepareTest` under-reports to 48 due to an ignore-traversal artifact — use the per-file
  `grep` count).
- **Audit signal → declaration mapping** (per test, by static inspection):
  - calls `solveCobraLP`/`optimizeCbModel`/`fluxVariability`/FBA-family → `needsLP` (or
    `requireOneSolverOf` an LP set).
  - `solveCobraQP`/quadratic norms → `needsQP`; `solveCobraMILP`/MILP design → `needsMILP`;
    `solveCobraMIQP` → `needsMIQP`; `entropicFBA`/`solveCobraEP` → `needsEP`; NLP → `needsNLP`.
  - direct/`requiredSolvers` use of a named commercial solver (cplex/mosek/tomlab) → the matching
    `requiredSolvers`/`requireOneSolverOf` (mirrors how the 91 already-gated tests declare).
  - uses a MATLAB toolbox (e.g. `statistics`, `bioinformatics`, `optimization`,
    `distrib_computing`) → `requiredToolboxes` with the license-feature name per the map in
    `prepareTest.m:77-83`.
  - OS-specific (`isunix`/`ispc`/mex only on one OS) → `needsUnix`/`needsWindows`/`needsMac`.
  - hits a URL / `webread`/`urlread` → `needsWebAddress`; needs an external binary (`lrs`,
    `glpk` exe, etc.) → `requiredSoftwares`.
  - **no solver/toolbox/OS/binary/network usage** → record "none needed" (no `prepareTest`), so
    the audit is complete, not silently skipped.
- **Conservative default**: when a test's requirement is ambiguous, declare the requirement
  (prefer a graceful skip over a hard fail). Preserve each test's existing assertions unchanged.
- **Auditability (FR-006)**: produce `specs/001-ci-coverage-gating/audit/backfill-audit.csv`
  (columns: test path, category, detected signals, declaration added, "none-needed" flag) so the
  per-test outcome is reviewable. A helper grep/script generates the first-pass signals; a human
  (the implement phase) confirms and edits each test.
- **Batching**: one task/PR-review batch per category (6 batches) to keep review tractable
  (Assumptions), even though all 169 are in scope.

## Open items carried into tasks

- Exact MoCov/jsonlab pin (tag/commit) — set in the CI provisioning task.
- Whether a Codecov token exists for this fork's CI — if absent, the artifact path is the
  guaranteed coverage surface; document in quickstart.
- Initial baseline value for `.skip-baseline.json` — recorded from the first instrumented CI run
  (or a conservative current count) during implementation.
