# Implementation Review

## Summary

Feature **001-ci-coverage-gating** (addresses architecture weakness W8) is planned and ready for
an implementation decision. It makes CI measure and publish test coverage, backfills
`prepareTest` requirement declarations into all currently-ungated tests so they skip (not
hard-fail) when a resource is absent, and adds a flag/warn skip-count gate. No scientific code,
public interface, model field, or solver-status semantic changes. No source edits have been made.

## Embedded Core Commands Completed

- constitution: checked (v1.2.0; not regenerated)
- specify: spec.md + checklists/requirements.md (validation passed)
- clarify: 3 decisions resolved (Session 2026-07-13)
- checklist: checklists/ci-coverage.md (29 requirements-quality items)
- plan: plan.md (Constitution Check = PASS), research.md, data-model.md, contracts/, quickstart.md
- tasks: tasks.md (22 tasks)
- analyze: cross-artifact consistency — 1 HIGH inconsistency found and corrected; otherwise clean

## Cross-Artifact Analysis Summary

- **Requirement coverage**: 12/12 FRs and 3/3 user stories map to ≥1 task; 22/22 tasks map to a
  requirement; 0 unmapped tasks; 0 critical issues.
- **Resolved during analyze (HIGH)**: the ungated-test count was mis-stated as 212 (inherited
  from an undercounting whole-tree `rg -l prepareTest`, which reports 48 vs the true 91 gated).
  Verified true counts: **260 total, 91 gated (35%), 169 ungated (65%)**; corrected across spec,
  plan, research, and tasks. The per-category batch counts (base 51, analysis 42, reconstruction
  38, visualization 17, dataIntegration 12, design 9 = 169) are authoritative.
- **Clarifications consistency**: coverage = always-on artifact + best-effort Codecov;
  backfill = all 169 ungated; skip gate = flag/warn + baseline — consistent across spec/plan/tasks.
- **Constitution**: PASS; no violations; Complexity Tracking empty.

## Proposed Implementation Scope

- **Tasks proposed**: T001–T022 (full feature). Organized as Setup (T001), US1/P1 coverage
  (T002–T007, the MVP), US2/P2 backfill (T008–T015), US3/P3 skip gate (T016–T018), Polish
  (T019–T022).
- **First independently testable slice**: **User Story 1 (T001–T007)** — CI coverage
  measurement + artifact + best-effort Codecov. Shippable alone; validated by quickstart Scenario B.
- **Files likely to change**:
  - `.github/workflows/testAllCI_step1.yml` (provisioning, env vars, artifact upload, Codecov,
    skip-gate steps)
  - `test/testAll.m` (one additive `mocov` argument: `-cover_xml_file coverage.xml`)
  - `test/verifiedTests/**/test*.m` (add `prepareTest(...)` to 169 tests; assertions unchanged)
  - `test/verifiedTests/.skip-baseline.json` (new, tracked)
  - `.gitignore` (ignore `.ci-tools/` + coverage outputs)
  - `specs/001-ci-coverage-gating/audit/backfill-audit.csv` (new, planning record)
- **Files that should NOT change**: any `src/` scientific code, the COBRA model schema,
  `src/base/solvers/**` dispatch, `deprecated/`, `external/`, `binary/`, and the solver-status
  semantics. `test/runTestSuite.m` and `testAllCI_step2.yml` stay unchanged.

## Tests and Validation Expected (narrowest first)

1. **Skip-path (narrowest)** — via MATLAB MCP, run one backfilled test whose resource is absent
   on the host (R2026a has only M2HTML + Matrix Computation toolboxes, so most solver/toolbox
   tests skip): confirm `COBRA:RequirementsNotMet` → Skipped, not Errored; and that it
   runs/passes unchanged when the resource is present. (quickstart Scenario A; SC-002, SC-005)
2. **Coverage** — set `MOCOV_PATH`/`JSONLAB_PATH`, run a small subset via `testAll.m`; confirm
   the coverage % prints and `coverage.xml`/`coverage.json`/`coverage_html/` are produced.
   (Scenario B; SC-001, SC-006)
3. **Skip gate** — force `skipped > baseline`; confirm `::warning::` + green build (exit 0).
   (Scenario C; SC-003)
4. **Regression** — CTRF pass/fail report still produced; `git diff --stat` touches only the
   allowed paths. (FR-009, SC-004)

## Blocking Issues

None. The one HIGH analyze finding (miscount) was corrected before this review.

## Acceptable Risks

- **Scope size**: US2 backfills 169 tests. Mitigated by six independent per-category batches
  (T009–T014, all `[P]`) and an auditable `backfill-audit.csv`. The MVP (US1) is shippable
  without US2.
- **MoCov/jsonlab provisioning on the self-hosted runner** depends on network at CI time to
  clone the pinned tools; if unavailable, coverage degrades but the pass/fail run is unaffected
  (measurement-failure path, FR-004).
- **Codecov token** may be absent for this fork; the always-on artifact is the guaranteed
  coverage surface (best-effort upload, FR-004/SC-006).
- **Local validation coverage**: the host cannot run gurobi-only CI end-to-end; local validation
  exercises the skip path and coverage tooling, with full CI behaviour confirmed on a PR.

## Human Approval

- Approved: no
- Approved option: (pending Gate 2)
- Approved tasks/scope: (pending)
- Required implementation invocation per constitution: an explicit `/speckit-implement` (Principle
  VI). A Gate 2 menu choice alone does NOT authorize source edits.
- Date (UTC): (pending)
