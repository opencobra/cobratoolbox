---
description: "Task list for feature 001-ci-coverage-gating"
---

# Tasks: Measure test coverage in CI and gate silent test-suite erosion

**Input**: Design documents from `specs/001-ci-coverage-gating/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md (all present)

**Tests**: This is CI/test-infrastructure + test-metadata work. Each behaviour-bearing task
carries the narrowest validation from quickstart.md (skip-path check, coverage-artifact check,
skip-gate check). No `src/` scientific code is edited.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: parallelizable (different files, no dependency on an incomplete task)
- **[Story]**: US1 / US2 / US3 (from spec.md); Setup/Polish carry no story label
- ⚠ **CI-YAML serialization**: every task that edits `.github/workflows/testAllCI_step1.yml`
  (T003, T004, T006, T007, T018) touches the **same file** and therefore MUST run sequentially,
  even across stories. They are never `[P]` with each other.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: keep regenerable coverage output and CI tooling out of version control.

- [x] T001 [P] Add `/.ci-tools/`, `coverage.json`, `coverage.xml`, `coverage_html/` to `.gitignore` (regenerable CI outputs / host-side tooling; Principle IX).

## Phase 2: Foundational

**Purpose**: none blocking. The three user stories are independent (US1 = coverage wiring,
US2 = test metadata, US3 = skip-gate CI step). No shared foundational code is required, so this
phase is intentionally empty; proceed to the stories.

---

## Phase 3: User Story 1 — Coverage measured & visible (Priority: P1) — MVP

**Goal**: CI produces a coverage % + a self-contained coverage artifact on every run, plus a
best-effort Codecov upload. Shippable alone.

**Independent test**: run CI (or locally with `MOCOV_PATH`/`JSONLAB_PATH` set); confirm the
coverage % prints (`testAll.m:290`) and `coverage.xml`/`coverage_html/` are uploaded as an
artifact regardless of Codecov (quickstart Scenario B).

- [x] T002 [US1] Add a runner-host step in `.github/workflows/testAllCI_step1.yml` (before the `docker run`) to clone pinned MoCov (`MOcov/MOcov`) and jsonlab (`fangq/jsonlab`) into `$GITHUB_WORKSPACE/.ci-tools/MOcov` and `.ci-tools/jsonlab` (pin to a specific tag/commit; skip if already present for caching).
- [x] T003 [US1] In the same `docker run` block of `.github/workflows/testAllCI_step1.yml`, add `-e MOCOV_PATH=/work/.ci-tools/MOcov -e JSONLAB_PATH=/work/.ci-tools/jsonlab` so `testAll.m:64-71` activates coverage. (⚠ same YAML file as T002 → sequential.)
- [x] T004 [P] [US1] In `test/testAll.m`, add `'-cover_xml_file','coverage.xml'` to the existing `mocov(...)` call (around line 266) — single additive argument, Cobertura output; do not change any other behaviour.
- [x] T005 [US1] Add an always-on `actions/upload-artifact` step in `.github/workflows/testAllCI_step1.yml` uploading `coverage.xml` and `coverage_html/` (name e.g. `coverage`). (⚠ same YAML file → after T003.)
- [x] T006 [US1] Add a best-effort `codecov/codecov-action@v4` step in `.github/workflows/testAllCI_step1.yml` with `files: ./coverage.xml`, `fail_ci_if_error: false`, `continue-on-error: true`, token from secrets. (⚠ same YAML file → after T005.)
- [x] T007 [US1] **Validate** locally via the MATLAB MCP: set `MOCOV_PATH`/`JSONLAB_PATH`, run a small `verifiedTests` subset through `testAll.m`, confirm the coverage % prints and `coverage.xml`/`coverage.json`/`coverage_html/` are produced (quickstart Scenario B). Record result.

**Checkpoint**: US1 delivers visible coverage independent of US2/US3.

---

## Phase 4: User Story 2 — Requirement-gated tests skip gracefully (Priority: P2)

**Goal**: all 169 ungated tests declare their requirements via `prepareTest`, so absent
resources produce skips, not errors.

**Independent test**: run the suite without a given commercial solver; confirm dependent tests
are Skipped (raising `COBRA:RequirementsNotMet`), 0 reported as errors (quickstart Scenario A).

- [x] T008 [US2] Create `specs/001-ci-coverage-gating/audit/backfill-audit.csv` (header: `testPath,category,detectedSignals,declarationAdded,noneNeeded,notes`) and populate first-pass signals with a grep helper over the 169 ungated tests (solveCobra*/optimizeCbModel/entropicFBA/named solvers/toolboxes/OS/webread/binaries). Blocks T009–T014.
- [x] T009 [P] [US2] Backfill `prepareTest` declarations into the **51** ungated tests under `test/verifiedTests/base/**` per `contracts/prepareTest-declaration.md`; keep assertions unchanged; record each per-test outcome (incl. `noneNeeded`) in `backfill-audit.csv`.
- [x] T010 [P] [US2] Backfill the **42** ungated tests under `test/verifiedTests/analysis/**` (same rules + audit record).
- [x] T011 [P] [US2] Backfill the **38** ungated tests under `test/verifiedTests/reconstruction/**` (same rules + audit record).
- [x] T012 [P] [US2] Backfill the **17** ungated tests under `test/verifiedTests/visualization/**` (same rules + audit record).
- [x] T013 [P] [US2] Backfill the **12** ungated tests under `test/verifiedTests/dataIntegration/**` (same rules + audit record).
- [x] T014 [P] [US2] Backfill the **9** ungated tests under `test/verifiedTests/design/**` (same rules + audit record).
- [x] T015 [US2] **Validate** via the MATLAB MCP: pick a sample backfilled test per category; confirm it is Skipped (`COBRA:RequirementsNotMet`) when its resource is absent (host lacks most solvers/toolboxes) and runs/passes unchanged when present (quickstart Scenario A). Confirm the audit CSV accounts for all 169 tests.

**Checkpoint**: US2 makes the red/green signal trustworthy; independent of US1/US3.

---

## Phase 5: User Story 3 — Skip-count tracked & gated (Priority: P3)

**Goal**: CI reports the skipped-test count and warns (never fails) when it exceeds a committed
baseline.

**Independent test**: force `skipped > baseline`; confirm a `::warning::` and a green build;
`skipped ≤ baseline` yields no warning (quickstart Scenario C).

- [x] T016 [US3] Create `test/verifiedTests/.skip-baseline.json` (`{ "maxSkipped": <int>, "recordedOn": "...", "environment": "gurobi-only Docker", "note": "..." }`) with a conservative initial value (refined in T020).
- [x] T017 [US3] Add a skip-gate step in `.github/workflows/testAllCI_step1.yml` (after the MATLAB run) that parses `skipped=` from `testReport.junit.xml`, compares to `.skip-baseline.json`, emits `::warning::` on exceed, reports the count, and always exits 0 (`continue-on-error: true`). (⚠ same YAML file → after T006.)
- [x] T018 [US3] **Validate**: simulate `skipped > maxSkipped` (temporarily lower the baseline against a local `testReport.junit.xml`); confirm the step emits `::warning::` and exits 0; and that `skipped ≤ maxSkipped` produces no warning (quickstart Scenario C).

**Checkpoint**: US3 closes the erosion loop; independent of US1/US2.

---

## Phase 6: Polish & Cross-Cutting

- [x] T019 Run the full quickstart (Scenarios A, B, C) end-to-end and record outcomes for the implementation receipt.
- [x] T020 Set `test/verifiedTests/.skip-baseline.json` `maxSkipped` from the first instrumented CI run's actual skipped count (or a documented conservative current count).
- [x] T021 Confirm no regression: CTRF pass/fail report still produced (FR-009/SC-004); `git diff --stat` touches ONLY `.github/workflows/`, `test/testAll.m`, `test/verifiedTests/**`, `.gitignore`, and `specs/001-ci-coverage-gating/**` — no `src/` scientific code.
- [x] T022 Finalize `backfill-audit.csv` (all 169 accounted for), update `human-loop.md`, and write the implementation receipt under `specs/001-ci-coverage-gating/agent-runs/<UTC>-<name>/implementation-receipt.md`.

---

## Dependencies & Execution Order

- **Setup (T001)** → before all.
- **US1**: T002 → T003 → T005 → T006 (all same YAML, sequential); T004 is `[P]` (edits `testAll.m`); T007 validates after T003–T006.
- **US2**: T008 → {T009–T014 in parallel `[P]`} → T015.
- **US3**: T016 → T017 (YAML, after T006) → T018.
- **Cross-story YAML lock**: T002, T003, T005, T006 (US1) and T017 (US3) serialize on `testAllCI_step1.yml`. If doing US1 and US3 together, land the US1 YAML edits first, then T017.
- **Polish (T019–T022)** → after the stories being shipped are done.

## Parallel Opportunities

- T004 (testAll.m) runs in parallel with the US1 YAML tasks.
- The six backfill tasks T009–T014 are fully parallel with each other (disjoint directories).
- US2 and US3 are independent of US1 except for the shared YAML lock (US3's T017).

## Implementation Strategy

- **MVP = User Story 1** (coverage visible on PRs) — shippable alone (T001–T007).
- Then US2 (the 169-test backfill, six parallel batches) for a trustworthy red/green signal.
- Then US3 (skip-count flag/warn gate) to catch future erosion.
- Task count: 22 (Setup 1, US1 6, US2 8, US3 3, Polish 4).
