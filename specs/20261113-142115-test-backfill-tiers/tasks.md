# Tasks: Bottom-up test back-fill with defect quarantine

**Input**: Design documents from `specs/20261113-142115-test-backfill-tiers/`
(spec.md, plan.md, research.md, data-model.md, contracts/, quickstart.md)

**Tests**: this feature's product is tests. Each wave's tests are run with coverage before the wave
is committed; the full suite runs at the end.

`F` = `specs/20261113-142115-test-backfill-tiers`. MATLAB only through the memory-capped wrapper,
at most 3 sessions at once (research R7).

## Wave procedure W (used by the tier phases)

A wave is formed, written, verified and committed as follows (research R4–R7, R11):

1. `python3 $F/tools/update_ledger.py $F --next-wave <tier>` writes `$F/inventory/waves/wave<NN>.tsv`
   (PENDING rows of that tier whose untested callees are all final and none QUARANTINED/BLOCKED) and
   splits it into slices of ≤ 10 rows.
2. One helper agent per slice, at most 3 running at a time, each briefed with
   `$F/inventory/agent-brief.md`, the slice rows and the contracts; each writes its tests under
   `test/verifiedTests/`, runs them with coverage and writes
   `$F/inventory/results/wave<NN>-<slice>.jsonl` (`contracts/agent-result.md`).
3. Every record with a quarantining defect is checked by a second reader (a different agent or the
   lead) who reproduces the trigger from the source; unconfirmed defects go back to the writer and
   the row is tested normally.
4. `python3 $F/tools/update_ledger.py $F --apply $F/inventory/results/wave<NN>-*.jsonl` updates rows,
   adds extra edges, propagates BLOCKED (R6) and rewrites `$F/inventory/quarantine.md`.
5. All tests of the wave run together once with coverage → `$F/inventory/coverage/wave<NN>.jsonl`;
   the run compares the MATLAB path, global variables, open figures, the working folder and the
   temporary folder before and after (FR-011); `update_ledger.py $F --verify-coverage
   $F/inventory/coverage/wave<NN>.jsonl` must report 0 problems (a failure, leftover state or an
   undocumented missed line is fixed before step 6).
6. `python3 .github/scripts/known_defects.py` (if any defect was recorded); stage, then
   `$F/tools/privacy_check.sh && git commit ...` (the check fails on machine paths, names or keys);
   commit as the maintainer without co-author line, never staging submodule pointers.

## Phase 1: Setup (Shared Infrastructure)

- [X] T001 Copy the coverage tool of feature 20261104-115314-test-coverage-100 to `$F/tools/measureCoverage.m` (header names both features) and add `$F/tools/run_coverage.sh <list> <out>` that runs it through the memory-capped wrapper
- [X] T002 Sync the local `test/models` checkout to the recorded commit 75c070d01 (local only, research R8) and verify every `test/models/mat/*.mat` is a MAT file; record the result in `$F/inventory/environment.md`
- [X] T003 Write `$F/tools/update_ledger.py` (adds the data-model fields to `$F/inventory/ledger.tsv`; `--next-wave`, `--apply`, `--check`, `--summary`; blocking propagation R6; generates `$F/inventory/quarantine.md` and `$F/inventory/summary.md`)
- [X] T004 [P] Coverage baseline (R10): executable-line counts of the 1085 untested files from one coverage run with an empty test, and covered lines of the 557 tested files from `specs/20261104-115314-test-coverage-100/coverage-runs/zz-final-*.jsonl` → `$F/inventory/coverage-before.tsv`

## Phase 2: Foundational (Blocking Prerequisites)

- [X] T005 Write the helper brief `$F/inventory/agent-brief.md`: constitution sections to read (III, III-Naming, III-Coverage, III-Defects incl. quarantine, VII), `contracts/test-file.md`, `contracts/agent-result.md`, severity rule FR-007, defect criteria (research R5), test placement (R8), fixtures, the MATLAB wrapper and slot discipline, what never to touch (src/, other tests, ledger, git)
- [X] T006 Pilot: the lead runs procedure W on the first 5 Tier 1 rows itself (wave 01), checks tools, brief and contracts end to end, and corrects them before any agent is launched

**Checkpoint**: tools, brief and contracts proven on 5 functions.

## Phase 3: User Story 1 — Inventory and bottom-up order (Priority: P1) 🎯 MVP

**Goal**: every untested file has a row, a tier and an order position. **Independent test**:
`update_ledger.py --check` reports 1085 rows, no callee after its caller within a tier.

- [X] T007 [US1] Add `--check` order and completeness checks to `$F/tools/update_ledger.py` and run them on `$F/inventory/ledger.tsv`; record the output in `$F/inventory/summary.md`
- [X] T008 [US1] Review the 155 inventory exclusions and the 62 `external-program` flags by reading each file's code; correct misclassifications in `$F/inventory/ledger.tsv` with reasons (scripts that only define data, GUIs whose logic functions are callable, etc.)

## Phase 4: User Story 2 — Tier 1 tests (Priority: P1)

**Goal**: no Tier 1 row PENDING. **Independent test**: every Tier 1 TESTED/QUARANTINED test passes
with complete or documented coverage.

- [X] T009 [US2] Run procedure W for Tier 1 waves until `update_ledger.py --next-wave 1` returns no row; tests in `test/verifiedTests/<category>/test<Area>/`
- [X] T009a [US3] Severity consistency audit (research R5, consistency rule from wave 09): every `cosmetic`/`limitation` entry written so far is checked against the rule; entries where a documented input fails when used are raised to `error`/`unusable-option` and their functions quarantined (tests converted, call-form seeds recorded); result in `$F/inventory/severity-audit.md`
- [X] T010 [US2] Tier 1 checkpoint: re-run every Tier 1 test of this feature with coverage → `$F/inventory/coverage/tier1.jsonl`; all pass. (Coverage sessions on R2025a stall after roughly 100–125 tests of this set, a MATLAB Connector thread spinning, see `inventory/review-followups.md`; the same tests run clean in one session without coverage. Checkpoints are therefore run as consecutive coverage sessions of at most ~110 tests, one at a time, with the runner's idle cap, and merged.)

## Phase 5: User Story 3 — Defect quarantine (Priority: P1)

**Goal**: quarantines evidence-based and visible. **Independent test**: `update_ledger.py --check`
finds a confirmed defect for every QUARANTINED row and a quarantined reach for every BLOCKED row.

- [ ] T011 [US3] After each tier checkpoint, regenerate `$F/inventory/quarantine.md` (ranking by files blocked) and check every quarantine has a second-reader confirmation in the ledger
- [ ] T012 [US3] FR-012: for a quarantining defect found in an already-tested function, add the entry to that function's existing test header by the input-level rule (assertions unchanged), list it in `$F/inventory/existing-defective.tsv` and propagate blocking to its untested callers; apply the late-edge rule (FR-009, research R6) when `--apply` adds an edge from a TESTED row to a QUARANTINED one

## Phase 6: User Story 4 — Tier 2 tests (Priority: P2)

- [X] T013 [US4] Run procedure W for Tier 2 waves until none PENDING
- [ ] T014 [US4] Tier 2 checkpoint → `$F/inventory/coverage/tier2.jsonl`; all pass

## Phase 7: User Story 5 — Tier 3 tests (Priority: P3)

- [ ] T015 [US5] Run procedure W for Tier 3 waves until none PENDING (Gurobi; requirements declared; CPLEX-only lines exempt)
- [ ] T016 [US5] Tier 3 checkpoint → `$F/inventory/coverage/tier3.jsonl`; all pass

## Phase 8: User Story 6 — Tier 4/5 tests (Priority: P4)

- [ ] T017 [US6] Run procedure W for Tier 4/5 waves until none PENDING (models via getDistributedModel; reference values labelled Tier 5)
- [ ] T018 [US6] Tier 4/5 checkpoint → `$F/inventory/coverage/tier4.jsonl`; all pass

## Phase 9: User Story 7 — Ready for human review (Priority: P2) and Polish

- [ ] T019 [US7] `update_ledger.py --check`: no PENDING row (SC-001); every BLOCKED row reaches a QUARANTINED one; every QUARANTINED row has a confirmed defect (SC-003)
- [ ] T020 [US7] Regenerate `test/known-defects.md` with `.github/scripts/known_defects.py` (FR-013)
- [ ] T021 [US7] Independent review (R9): Codex if the account accepts a model, otherwise reviewer agents given only code and tests; at least one TESTED test per source area, every Tier 5 reference, every QUARANTINED entry; findings and resolutions in `$F/review.md`; fixes re-run
- [ ] T022 [US7] Coverage after (R10) and `$F/inventory/summary.md` (counts by status × tier, exclusions by reason, quarantine ranking, coverage before/after) (SC-006)
- [ ] T023 [US7] SC-004: `git diff --name-only upstream/develop... -- src` is empty
- [ ] T024 [US7] Full suite on the reference machine (SC-005); failures compared with the base commit's; result in the receipt
- [ ] T025 Implementation receipt `$F/agent-runs/<UTC>-implement/implementation-receipt.md` (Prompt, Final response, Diff summary, Tests, Unresolved issues)
- [ ] T026 Final privacy scan and commit; push and PR only when the maintainer asks (FR-018)

## Dependencies & Execution Order

- Setup (T001–T004) → Foundational (T005–T006) → US1 (T007–T008) → Tier phases in order:
  US2 (Tier 1) → US4 (Tier 2) → US5 (Tier 3) → US6 (Tier 4/5). Tiers are strictly sequential (the
  maintainer's bottom-up order); within a tier, waves are sequential and slices of a wave parallel.
- US3 (T011–T012) runs alongside every tier phase (after each wave/checkpoint).
- US7 (T019–T026) after the last tier.

## Parallel Opportunities

- T004 parallel to T003.
- Within a wave: up to 3 slices in parallel (one MATLAB session each); second-reader checks of
  different quarantines in parallel.

## Parallel Example: a Tier 1 wave

```text
Agent A: slice wave05-a (10 rows) → results/wave05-a.jsonl
Agent B: slice wave05-b (10 rows) → results/wave05-b.jsonl
Agent C: slice wave05-c (7 rows)  → results/wave05-c.jsonl
Lead: confirm quarantines → --apply → re-run wave with coverage → commit
```

## Implementation Strategy

MVP = US1 + the pilot wave (T001–T008): the inventory, tools and process proven on 5 functions.
Then tiers bottom-up, committing each wave so progress survives interruptions (the ledger is the
resume point: re-running `--next-wave` continues where the last commit left off).

## Notes

- No task changes `src/`. A task that would need a source change stops and records a defect.
- Mark tasks [X] as completed; a tier task is complete when `--next-wave <tier>` returns nothing.
