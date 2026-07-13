# Requirements Quality Checklist: CI Coverage & Skip-Gate

**Purpose**: Validate that the requirements in spec.md for CI coverage measurement,
`prepareTest` backfill, and the skip-count flag/warn gate are complete, clear, consistent,
measurable, and constitution-aligned — before planning. ("Unit tests for the requirements.")
**Created**: 2026-07-13
**Feature**: [spec.md](../spec.md)

## Requirement Completeness

- [x] CHK001 Are requirements defined for *where* coverage is measured (which paths are counted as the coverage denominator, e.g. `src/`)? [Completeness, Spec §FR-001]
- [x] CHK002 Is the behaviour specified for the case where there is no base branch to diff against (first run), so a coverage delta cannot be computed? [Edge Case, Spec §Edge Cases]
- [x] CHK003 Are requirements defined distinguishing coverage-*measurement* failure from coverage-*upload* failure, with different consequences for each? [Completeness, Spec §FR-004]
- [x] CHK004 Does the spec state what constitutes the auditable record of the full ungated-test backfill (per-test outcome: requirement declared vs. none needed)? [Completeness, Spec §FR-006]
- [x] CHK005 Are the `prepareTest` requirement categories in scope enumerated (solvers, toolboxes, OS, external binaries) rather than left implicit? [Completeness, Spec §FR-005]
- [x] CHK006 Is the source of the skip-count baseline specified (how the baseline value is established and stored)? [Gap, Spec §FR-008]
- [x] CHK007 Are requirements present for how an intentional environment change updates the skip-count baseline rather than warning forever? [Completeness, Spec §Edge Cases]

## Requirement Clarity & Measurability

- [x] CHK008 Is "coverage" quantified as a specific, measurable metric (line coverage percentage) rather than an unqualified term? [Clarity, Spec §FR-001]
- [x] CHK009 Is the coverage-instrumentation runtime bound stated as a measurable value or method, rather than the vague "agreed bound"? [Ambiguity, Spec §SC-006, §FR-012]
- [x] CHK010 Is "best-effort" Codecov upload defined precisely enough to be verifiable (i.e. the build outcome is independent of Codecov reachability)? [Clarity, Spec §FR-002, §FR-004]
- [x] CHK011 Is "flag/warn" defined concretely enough to be objectively observed in a CI run (what artifact/output carries the warning)? [Measurability, Spec §FR-007, §FR-008]
- [x] CHK012 Can SC-002 ("0 dependent tests reported as errors due to the missing solver") be objectively measured against the run output? [Measurability, Spec §SC-002]
- [x] CHK013 Is the skip-count "exceeds baseline" comparison expressed as a definite rule (absolute count vs. delta, threshold value/tolerance)? [Clarity, Spec §FR-008]

## Requirement Consistency

- [x] CHK014 Are the coverage-destination requirements consistent between the Clarifications entry, FR-002/FR-004, SC-001/SC-006, and the Assumptions? [Consistency, Spec §Clarifications, §FR-002]
- [x] CHK015 Is the backfill scope stated consistently as "all currently-ungated tests" everywhere (User Story 2, FR-006, SC-002, Assumptions) with no residual "first-slice/phased" language? [Consistency, Spec §FR-006]
- [x] CHK016 Is the skip-gate policy consistently "flag/warn, not hard-fail" across US3, FR-008, SC-003, and Assumptions? [Consistency, Spec §FR-008]
- [x] CHK017 Do the success criteria (SC-001..SC-006) each trace to at least one functional requirement without contradiction? [Consistency, Spec §Success Criteria]

## Constitution Alignment (Principles II / III / IV)

- [x] CHK018 Do the requirements explicitly forbid changing public interfaces, model fields, and solver-status semantics (`.stat`/`.origStat`)? [Coverage, Spec §FR-010]
- [x] CHK019 Is it required that a backfilled test's assertions are unchanged when its requirements are met (metadata-only change)? [Clarity, Spec §FR-010, US2 scenario 2]
- [x] CHK020 Do the requirements state the CI environment constraints (headless Linux/Docker, gurobi + open-source solvers only) that the feature must satisfy? [Completeness, Spec §Assumptions, §FR-012]
- [x] CHK021 Is the narrowest reproducibility check defined (a requirement-gated test skips when its resource is absent and runs when present; CI emits coverage + skip-count)? [Acceptance Criteria, Spec §FR-011]
- [x] CHK022 Are any new network/secret dependencies (Codecov token) identified and required to be non-blocking, per CI-reproducibility (Principle III)? [Completeness, Spec §FR-012, §SC-006]

## Backward Compatibility of the Test Harness

- [x] CHK023 Do the requirements state that `test/testAll.m` → `test/runTestSuite.m` script-execution behaviour is preserved? [Consistency, Spec §FR-009]
- [x] CHK024 Is preservation of the `COBRA:RequirementsNotMet` skip-detection mechanism explicitly required (not replaced by a new gating mechanism)? [Consistency, Spec §FR-009, §Assumptions]
- [x] CHK025 Is continuity of the existing JUnit→CTRF pass/fail PR report required with no regression? [Coverage, Spec §FR-009, §SC-004]

## Scope Boundaries, Assumptions & Anti-Goals

- [x] CHK026 Is it explicitly required that no test is deleted, disabled, or weakened, and that a real failure must not be converted into a skip? [Coverage, Spec §Edge Cases, §Assumptions]
- [x] CHK027 Is the hard-fail hardening of the skip gate explicitly recorded as out-of-scope/deferred so scope is bounded? [Boundary, Spec §FR-008]
- [x] CHK028 Is the method for deciding a test's required resources documented (inspection; conservative default = declare the requirement when ambiguous)? [Assumption, Spec §Assumptions]
- [x] CHK029 Given the full-backfill scope (~200 tests), is there a requirement that the work be decomposed into reviewable batches even though all are in-scope? [Completeness, Spec §Assumptions, §FR-006]

## Notes

- Every item interrogates the *requirements text*, not implementation behaviour.
- Traceability: 28/29 items cite a spec section or a `[Gap]`/`[Ambiguity]` marker (>80%).
- Items CHK002, CHK006 carry `[Gap]`/underspecification signals worth confirming in `/speckit-plan`; they are not blocking for Gate 1 but should be resolved during planning.
