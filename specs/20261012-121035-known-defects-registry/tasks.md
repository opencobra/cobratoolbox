---

description: "Task list for the known-defects registry (Constitution III-Defects)"
---

# Tasks: Known-defects registry for test headers

**Input**: Design documents from `/specs/20261012-121035-known-defects-registry/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [contracts/defect-entry-format.md](contracts/defect-entry-format.md), [research.md](research.md), [data-model.md](data-model.md), [quickstart.md](quickstart.md)

**Tests**: the tool has its own automated tests (FR-010); the 55 MATLAB tests are re-run to prove the header rewrite changed nothing. No `src/` file may change; no test assertion may change.

**Organization**: grouped by user story. Work stays on `develop`; no branch is created. No personal information in any file.

## Format: `[ID] [P?] [Story] Description`

## Phase 1: Setup

- [ ] T001 Confirm the baseline: on `develop`, `git diff --stat -- src` empty, `python3 --version` works, and the 55 test files of features 025 and 026 exist (list them from their spec tables).
- [ ] T002 Record, in the session scratchpad (not committed), the list of non-comment lines of each of the 55 test files, to prove later that only comment lines changed.

---

## Phase 2: Foundation - the tool and its tests (US2, US3)

- [ ] T003 [US2] Write the unit tests `.github/scripts/test_known_defects.py` (stdlib `unittest`, temporary directory trees): valid entry parsed; several entries; continuation lines; `None found.` (with trailing explanation); missing field; duplicate field; unknown severity; bad LINES; line beyond the source length; function path missing; duplicate title for one function across files; free text under the heading rejected; file with `Function under test:` but no heading rejected; file with neither ignored; deterministic output and ordering; `|` escaping; check mode passes/fails/returns 2 on invalid entries. Write them first and confirm they fail without the tool.
- [ ] T004 [US1] [US2] Implement `.github/scripts/known_defects.py`: header block extraction, the contract grammar, validation with `file:line: message` errors, deterministic Markdown rendering (notice, counts, summary table, per-function sections), working from any directory (`--root`, default repository root).
- [ ] T005 [US3] Add the command-line layer: default writes `test/known-defects.md`; `--check` compares in memory and exits 0 / 1 (stale, with the regeneration command) / 2 (invalid entries); `--root`.
- [ ] T006 Run the unit tests until they pass.

**Checkpoint**: the tool works on synthetic trees.

---

## Phase 3: User Story 4 and 1 - back-fill and first registry (Priority: P1/P2)

**Goal**: all 55 headers conform and the first registry lists every known defect once.

**Independent Test**: tool exits 0; each defect of the batch-2 receipt appears exactly once; the 55 tests pass; non-comment lines unchanged.

- [ ] T007 [US4] Re-read the 5 pilot test headers (getDefaultValue, getIDPositions, verifyRuleSyntax, getMetAbbr, extendIndicesInDimenion) and the 50 batch-2 headers; list every defect note, using `known_defects.py` lint output (T004) to find non-conforming headers.
- [ ] T008 [US4] Rewrite the defect notes of the batch-1 (pilot) and the batch-2 headers in the standard format by comment-only edits; use the heading `Known defects documented (NOT tested, NOT fixed here):` in all 55 files; tests with no defect say `None found.`; keep "Coverage exemptions" text as it is.
- [ ] T009 [US4] Verify only comment lines changed (compare with T002) and `git diff --stat -- src` is empty.
- [ ] T010 [US1] Generate `test/known-defects.md`; compare its entries with the defect list of the batch-2 receipt and the pilot re-read: every defect exactly once (SC-001).
- [ ] T011 [US4] Re-run all 55 tests through the harness runner; all pass.

---

## Phase 4: User Story 3 - CI check and documentation (Priority: P2)

- [ ] T012 [US3] Add one step to `.github/workflows/testAllCI_step1.yml` before the test-selection step: run the tool's unit tests and `known_defects.py --check` (no MATLAB).
- [ ] T013 [US3] Document the generator, the check, the entry format reference and the regeneration command in `.github/scripts/README.md`.
- [ ] T014 [US3] Demonstrate the check: passes on the clean tree; fails (exit 1) after hand-editing the registry; fails after editing a header entry without regenerating; fails (exit 2) after a malformed entry; then restore.

---

## Phase 5: Polish

- [ ] T015 Determinism: generate twice from two different working directories; outputs byte-identical (SC-002); time under 10 seconds (SC-005).
- [ ] T016 Scan every added or changed file under `specs/20261012-121035-known-defects-registry/`, `.github/`, `test/known-defects.md` and the 55 headers for personal information; none (SC-007).
- [ ] T017 Write the implementation receipt in `specs/20261012-121035-known-defects-registry/agent-runs/<UTC-timestamp>-known-defects-registry/implementation-receipt.md` (Prompt, Final response, Diff summary, Tests, Unresolved issues).
- [ ] T018 Commit on `develop` (author from the local git configuration, no co-author line); do not push.

---

## Dependencies & Execution Order

Phase 1 -> Phase 2 (T003 before T004) -> Phase 3 -> Phase 4 -> Phase 5. T007 needs the tool (T004) for lint output. The CI step (T012) comes after the registry exists so the check passes on first run.

## Implementation Strategy

MVP = Phase 2 + 3: a working tool and a complete first registry. Then the CI wiring. Total tasks: 18.
