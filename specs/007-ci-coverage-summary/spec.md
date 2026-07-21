# Feature Specification: CI coverage summary + line-by-line link

**Feature Branch**: `007-ci-coverage-summary`

**Created**: 2026-07-14

**Status**: Draft

**Input**: User description: "Surface a code-coverage summary with a line-by-line link in the CI result (fork-PR-safe)."

## Context

Feature 001 (CI coverage gating) already makes the CI compute per-line source
coverage during a full-mode `testAll` run: it produces a Cobertura `coverage.xml`,
a `coverage.json`, and a `coverage_html/` report (per-file, line-by-line), uploads
them as a `coverage` build artifact, and best-effort-uploads `coverage.xml` to
Codecov. A separate `workflow_run` job posts a test-result comment on the PR.

The gap this feature closes: the coverage *number* is buried in the MATLAB run log
and the line-by-line report is only reachable by downloading the artifact, so a
reviewer looking at a CI result sees no coverage summary and no clickable path to
the line-by-line detail. For fork→upstream pull requests (the normal contribution
path here, e.g. `rmtfleming:develop` → `opencobra:develop`), the CI run receives no
repository secrets and only a read-only token, so the Codecov comment cannot be
relied on to fill this gap. This feature surfaces the already-computed coverage in
a channel that works for fork PRs. It does not change how coverage is measured.

## Clarifications

<!-- Populated by /speckit-clarify -->

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Coverage summary visible on the CI run (Priority: P1)

A reviewer (or the contributor) opens the CI run for a pull request and, without
downloading anything or leaving GitHub, sees a coverage summary: the overall
coverage percentage and the covered/total line counts for the run.

**Why this priority**: This is the core value — an at-a-glance coverage number
attached to the run itself. It is the one piece that must work on every run,
including fork PRs where no secrets are available, so it is built on the run's job
summary (which needs no token or secret).

**Independent Test**: Trigger the coverage CI on a branch/PR; confirm the run's
summary page shows a coverage percentage and covered/total lines matching the value
the run computed (the log line `Covered Lines: X, Total Lines: Y, Coverage: Z%`).

**Acceptance Scenarios**:

1. **Given** a CI run where coverage was computed, **When** the run finishes,
   **Then** the run's job summary shows the overall coverage % and covered/total
   line counts.
2. **Given** a fork→upstream pull request (no secrets, read-only token), **When**
   the run finishes, **Then** the same coverage summary still appears on the run
   (it does not depend on Codecov or on any secret).
3. **Given** a run where coverage was NOT computed (coverage tooling absent or
   MoCov failed), **When** the run finishes, **Then** the summary states coverage
   was not computed this run and the build result (pass/fail) is unchanged.

---

### User Story 2 - One click from the summary to the line-by-line coverage (Priority: P1)

From that summary, the reviewer can reach the line-by-line coverage — which source
lines are covered and which are not — in one obvious step.

**Why this priority**: A number alone does not let a reviewer investigate *what* is
uncovered. The whole point of the request is to make the line-by-line result
reachable. Pairing the link with the summary (P1) is what makes the summary
actionable.

**Independent Test**: From the CI run summary, follow the provided link(s) and
arrive at the per-file, line-by-line coverage (the `coverage_html` report via the
run's `coverage` artifact, and/or the Codecov file view) for that run.

**Acceptance Scenarios**:

1. **Given** the coverage summary on the run, **When** the reviewer looks at it,
   **Then** it contains a link to the line-by-line coverage report (the `coverage`
   artifact containing `coverage_html/`, and/or the Codecov file view).
2. **Given** the linked line-by-line report, **When** the reviewer opens it,
   **Then** they can see, per source file, which lines are covered and uncovered.
3. **Given** coverage was not computed this run, **When** the reviewer reads the
   summary, **Then** no broken/dead link is shown (the link is present only when the
   report exists).

---

### User Story 3 - Coverage summary on the pull request itself (Priority: P3)

The coverage summary and line-by-line link also appear as a comment on the pull
request, so a reviewer sees coverage in the PR conversation without opening the run.

**Why this priority**: Convenience/visibility improvement. It is lower priority
because (a) it requires the privileged `workflow_run` path (the same mechanism the
existing test-result comment uses) to comment on fork PRs, and (b) the run-level
summary from US1/US2 already satisfies the core "displays in the CI result with a
link" requirement. Deliverable independently, after US1/US2.

**Independent Test**: Open a fork→upstream PR; after CI completes, confirm a PR
comment contains the coverage % and a link to the line-by-line coverage, and that
it does not disturb the existing test-result comment.

**Acceptance Scenarios**:

1. **Given** a completed coverage run for a fork PR, **When** the privileged
   post-run reporting job runs, **Then** a PR comment shows the coverage summary and
   a link to the line-by-line coverage.
2. **Given** repeated runs on the same PR, **When** new coverage is produced,
   **Then** the PR is not spammed with unbounded duplicate coverage comments
   (updates or a single coverage comment, consistent with the existing report).
3. **Given** coverage was not computed for a run, **When** the reporting job runs,
   **Then** it does not post a misleading coverage comment and does not fail.

---

### Edge Cases

- **Coverage not produced**: `coverage.xml`/`coverage.json` missing (tooling not
  provisioned, or MoCov errored best-effort). The summary must say so plainly and
  the build result must not change.
- **Malformed/empty coverage file**: present but unparseable or zero total lines.
  Treated as "not computed" — no divide-by-zero, no crash, no build failure.
- **Fork PR (no secrets, read-only token)**: the run-level summary must still
  appear; anything needing write/secret access is confined to the privileged
  post-run job.
- **Artifact retention/expiry**: a link to the artifact points at the run; if the
  artifact has expired the summary still shows the number (the link may 404 upstream
  of this feature's control — acceptable, the number is the durable part).
- **Very large file list**: the "least-covered files" detail must be bounded (a
  fixed top-N) so the summary stays readable.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The CI MUST display a code-coverage summary on the CI run result,
  containing at least the overall coverage percentage and the covered/total line
  counts for that run.
- **FR-002**: The coverage summary MUST be produced through a channel that works for
  fork→upstream pull-request runs that receive no repository secrets and a read-only
  token (i.e., it MUST NOT depend on Codecov or any secret to appear on the run).
- **FR-003**: The coverage summary MUST include a link to the line-by-line coverage
  result for that run — the `coverage_html` report (via the run's `coverage`
  artifact) and/or the Codecov file view — when such a report exists.
- **FR-004**: The coverage summary SHOULD include a bounded list of the least-covered
  source areas (a fixed top-N of files by lowest coverage) to make the summary
  actionable; this is best-effort and MUST degrade to the overall figure if the
  per-file detail is unavailable.
- **FR-005**: When coverage was not computed for a run (coverage input absent,
  empty, or unparseable), the summary MUST clearly state that coverage was not
  computed this run, MUST NOT show a broken line-by-line link, and MUST NOT fail the
  build.
- **FR-006**: The feature MUST preserve all existing feature-001 CI behavior — the
  `coverage` artifact upload, the best-effort Codecov upload, and the skip-count
  gate — and MUST NOT alter the pass/fail semantics of the test run or the coverage
  gate/threshold.
- **FR-007**: The feature MUST define the narrowest reproducibility check that proves
  the behavior: given a representative `coverage.xml`/`coverage.json`, the
  summary-rendering logic produces the expected coverage percentage and line counts,
  and given a missing/empty input produces the "not computed" message — verifiable
  without a full CI run.
- **FR-008**: The summary MUST be derived from the coverage artifacts already
  produced by the run (the Cobertura/JSON/HTML outputs); the feature MUST NOT change
  what counts as a covered line, and SHOULD avoid adding any new dependency to the
  MATLAB coverage computation (parse existing outputs rather than re-measuring).
- **FR-009**: If the pull-request coverage comment (User Story 3) is delivered, it
  MUST be emitted from the privileged post-run reporting job (not the unprivileged
  test run), MUST NOT create unbounded duplicate comments on repeated runs, and MUST
  coexist with the existing test-result comment.

### Key Entities *(include if feature involves data)*

- **Coverage result**: the per-run coverage data already emitted by the test run —
  overall covered lines, total lines, percentage, and per-file line coverage —
  materialized as the Cobertura XML, the JSON, and the HTML report.
- **CI run summary**: the run-attached, secret-free surface on which the coverage
  summary is displayed.
- **Line-by-line report**: the per-file, per-line covered/uncovered rendering (the
  HTML report inside the `coverage` artifact, and/or the Codecov file view) that the
  summary links to.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: On a coverage-producing CI run, a reviewer can read the overall
  coverage % and covered/total lines directly on the run without downloading any
  artifact — in one view, zero downloads.
- **SC-002**: From that summary, the reviewer reaches the line-by-line coverage for
  the run in at most one click/navigation step.
- **SC-003**: The coverage summary appears on 100% of coverage-producing runs
  including fork→upstream PR runs (no dependence on secrets/Codecov for the
  run-level summary).
- **SC-004**: The displayed overall percentage and line counts match the values the
  run computed (the `Covered Lines/Total Lines/Coverage` the test run reports),
  exactly (same rounding) or within a stated rounding tolerance.
- **SC-005**: On a run where coverage was not computed, the summary states so and the
  build's pass/fail outcome is identical to what it would be without this feature
  (no new failures introduced).
- **SC-006**: The reproducibility check (FR-007) passes: representative coverage
  input renders the expected summary, and missing/empty input renders the
  "not computed" message — both without a full CI run.

## Assumptions

- The CI run already produces `coverage.xml` (Cobertura), `coverage.json`, and
  `coverage_html/` when coverage tooling is provisioned (feature 001); this feature
  consumes those and does not re-measure coverage.
- The run's per-run summary surface (job summary) is available without secrets and is
  the reliable channel for fork-PR runs; the privileged post-run job is the only
  place able to comment on fork PRs (as the existing test-result comment already
  demonstrates).
- The primary contribution path is fork→upstream pull requests, so fork-PR behavior
  is the design center, not an edge case.
- "Line-by-line coverage result" is satisfied by the `coverage_html` report and/or
  the Codecov file view; enabling/installing Codecov on the upstream repository is
  out of scope — the feature must not depend on it.
- Changing the coverage threshold, the coverage gate, or the skip-count baseline is
  out of scope (owned by feature 001).
