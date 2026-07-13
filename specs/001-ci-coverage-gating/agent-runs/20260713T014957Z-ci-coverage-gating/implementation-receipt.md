# Implementation Receipt

**Feature**: 001-ci-coverage-gating — Measure test coverage in CI and gate silent test-suite erosion (architecture weakness W8)
**Run (UTC)**: 20260713T014957Z
**Branch**: 001-ci-coverage-gating

## Prompt

`/speckit-implement` for the active feature, executing the Gate-2-approved full scope
(tasks T001–T022) through the Spec Kit human-loop. Constitution Principle VI authorization was
given by the explicit `/speckit-implement` invocation.

## Diff summary

CI/test-infrastructure + test-metadata only. **No `src/` scientific code, no public interface,
model field, or solver-status semantic change.**

- `.github/workflows/testAllCI_step1.yml` (+76): provision MoCov + jsonlab on the runner host
  into `.ci-tools/` and set `MOCOV_PATH`/`JSONLAB_PATH` (best-effort — build unaffected if
  absent); pass those env vars into the Docker run; always upload `coverage.xml`/`coverage_html`
  as an artifact; best-effort `codecov/codecov-action` (`fail_ci_if_error: false`,
  `continue-on-error: true`); flag/warn skip-count gate that parses `skipped=` from
  `testReport.junit.xml`, compares to the baseline, emits `::warning::` on exceed, and always
  exits 0.
- `test/testAll.m` (+13/−4): add `'-cover_xml_file','coverage.xml'` (Cobertura) to the existing
  `mocov(...)` call, and wrap the coverage block in try/catch so a coverage-tool failure warns
  (with `ME.stack`) rather than failing the already-reported pass/fail run (FR-004; VII-C).
- `test/verifiedTests/.skip-baseline.json` (new): provisional skip-count baseline
  (`maxSkipped: 260`, documented as pending CI calibration).
- `.gitignore` (+5): ignore `.ci-tools/`, `coverage.json`, `coverage.xml`, `coverage_html/`.
- **34 test files** under `test/verifiedTests/` (+3 lines each, additions only): a `prepareTest`
  requirement guard (comment + call + blank) — base 6, analysis 17, reconstruction 4,
  dataIntegration 3, design 3, visualization 1. Of the 169 ungated tests, **34 needed a guard**
  and **135 are solver-free (none-needed, recorded)**. Assertions and solver-selection logic
  byte-for-byte unchanged. Declarations: mostly `needs*` type gates (`needsLP`/`needsMILP`/
  `needsQP`, combined where used); only two genuine hard-pins — `requiredSolvers {'mosek'}`
  (`testInitCobraToolboxAgentMode`, which hard-asserts mosek) and `requiredSolvers {'gurobi'}`
  (`testMinSpan`, where `detMinSpan` refuses to run without gurobi). No spurious `requiredSolvers`
  `{'ibm_cplex'}` was applied (each cplex mention was a loop option, not a dependency).
- `specs/001-ci-coverage-gating/**`: spec, clarify, plan, research, data-model, contracts,
  quickstart, tasks, checklists, `audit/backfill-audit.csv` (169-row audit), `audit/notes.md`,
  human-loop.md, implementation-review.md, and this receipt.

Commits on the branch: `cddaea549` (spec), `5dd07ac62` (plan/tasks/analysis), `476be143e`
(Gate 2 record), `1084a49d0` (US1+US3+setup), plus the US2 backfill commit.

## Tests

- **Static analysis (MATLAB Code Analyzer via MCP)**: `test/testAll.m` and sampled backfilled
  files (`testSparseLP`, `testInitCobraToolboxAgentMode`, `testenumOptimalSols`, `testOptKnock`)
  — **no new issues**; all flagged items pre-existing. Every backfill diff is additions-only
  (verified `git diff --numstat`: 0 deletions across the 34 files).
- **YAML**: `testAllCI_step1.yml` validated (`yaml.safe_load`).
- **Skip-count gate (bash logic)**: warn path — `skipped=235 > baseline=10` → `::warning::`
  emitted, exit 0; normal path — `235 ≤ 260` → no warning. (quickstart Scenario C ✅)
- **Live skip-path (fresh `matlab -batch`, `initCobraToolbox(false,'agent')` in 2.8 s)** —
  this host has working mosek/glpk/pdco; gurobi is installed-but-not-working:
  - `prepareTest('requiredSolvers',{'gurobi'})` → **threw `COBRA:RequirementsNotMet` → SKIP** ✅
    (proves the guard causes a graceful skip when the resource is absent — SC-002, SC-005)
  - `prepareTest('requiredSolvers',{'mosek'})`, `needsLP`, `needsMILP` (all available) → run ✅
  - **End-to-end**: `test/verifiedTests/design/testTheoretMaxProd.m` ran to completion with the
    inserted `needsLP` guard and its assertions passed (run path unaffected when requirement met).
- **Coverage production**: `test/testAll.m` already computes and prints coverage when
  `MOCOV_PATH`/`JSONLAB_PATH` are set; the added `-cover_xml_file` emits Cobertura. Full coverage
  run requires MoCov (not installed on this host) → validated by design + CI wiring; a CI run on
  a PR to `develop` will produce the coverage %/artifact (SC-001).

## Unresolved issues

- **Skip baseline is provisional** (`maxSkipped: 260`, a never-fires ceiling chosen so the gate
  does not destabilize CI on first rollout). Calibrate to the real value from the first
  instrumented CI run (T020; documented in the JSON `note`).
- **MoCov/jsonlab pinning**: the CI provisioning step currently clones the default branch of
  each; pin to a verified tag/commit for full reproducibility (TODO noted in the workflow).
- **Codecov token**: if this fork's CI has no `CODECOV_TOKEN`, the always-on coverage artifact is
  the guaranteed surface (the upload is best-effort by design).
- **MATLAB MCP session**: an early validation script called `restoredefaultpath`, which removed
  the MCP toolbox from the session path and disabled the MCP `evaluate`/`run` tools for the rest
  of this session (the static `check_matlab_code` tool was unaffected). Live validation was
  completed via a fresh `matlab -batch` instead. Recover the MCP by restarting the MATLAB
  session. This is a tooling artifact, not a code defect.
- **Two self-guarded tests left none-needed** (`testTranslateMetagenome2AGORA` `if ispc` no-op on
  Linux; `testAddKeyToKnownHosts` checks `system('ssh-keyscan')` status). Converting the former to
  `prepareTest('needsWindows','needsWebAddress')` so it reports *skipped* rather than a silent
  pass is a possible future refinement (would change reported status; deferred).

## Final response

(The user-facing completion message for this run is reproduced verbatim in the assistant's final
turn message that follows this receipt in the conversation; it summarizes the 34-guard backfill,
the coverage + skip-gate wiring, the passing skip-path/run-path validations, the no-`src/`-change
scope guarantee, and presents Gate 3.)
