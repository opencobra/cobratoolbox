# Implementation receipt — 20261113-142115-test-backfill-tiers

## Prompt

"I want use to start writing the tests from down tiers up to up tiers all the way and if there was an
defect we document it and skip that function and functions dependent on it. this way I want to reach
the highest test coverage possible before the need for a human review."

The maintainer's answers to the clarifying questions:
- skip the defective function and its callers;
- deliver one PR at the end;
- amend the constitution (quarantine rule, 1.8.0 and 1.8.1);
- only serious severities quarantine;
- the two-input form of getCobraSolverParams: "Document it to defects and document the problem. and treat it as defeacts";
- blocking follows "Reach the defect", and "Block the 308" was accepted;
- "continue with the speckit your self to the end".

Later instructions:
- "continue on fable", "continue";
- "Continue the development and writing the tests. My 5hr limit will be restarted at 7:40 pm so dont continue after that.";
- "ok do it" (the remaining waves and closing tasks);
- "wait and start at 3 am".

Run by `/speckit-implement`. The lead (Claude) ran procedure W per wave with general-purpose helper
agents, one per slice, and confirmed every quarantine as second reader. Independent reviewer agents
did the final review, because Codex rejected the model (see review.md).

## Final response

Every untested `src/` file was classified bottom-up by tier: 1085 files, 0 left PENDING.

| Status | Files |
|---|---|
| TESTED | 201 |
| QUARANTINED | 270 |
| BLOCKED | 429 |
| EXCLUDED | 185 |

The breakdown by tier, the exclusion reasons and the quarantine ranking are in `inventory/summary.md`.

- **TESTED:** each function has a test with independently derived expected values. Every missed line is listed as exempt, with a reason.
- **QUARANTINED:** each function has a test in quarantine layout. The header records its defects, the test asserts nothing, and each quarantine was confirmed by a second reader.
- **BLOCKED:** the function reaches a quarantined defect through some chain of calls (constitution 1.8.1). Call-form seeds are in `inventory/quarantine-seeds.tsv`.
- **EXCLUDED:** the function is a script, a GUI, needs interactive input or the internet, or cannot run here. The reason is recorded for each file.

`test/known-defects.md` lists 826 defects.

Line coverage of `src/`, without the four generated c13 solver files, rose from 22.2% to 27.4%.
With those files (119,455 lines) included, it rose from 12.1% to 60.4%. 701 files have at least one
covered line, up from 497.

## Diff summary

The branch has 42 commits on top of upstream/develop.

| Path | Files | Content |
|---|---|---|
| `test/verifiedTests/` | 473 | 471 new tests (201 TESTED, 270 quarantine layout), plus defect entries in 2 existing tests (FR-012, `inventory/existing-defective.tsv`) |
| `test/known-defects.md` | 1 | regenerated registry |
| `specs/20261113-142115-test-backfill-tiers/` | about 237 | spec, plan, research, tasks, contracts, tools, inventory (ledger, waves, results, confirmations, coverage records, review), review.md, this receipt |
| `.specify/memory/constitution.md` | 1 | 1.8.0 quarantine rule, 1.8.1 reach rule |
| `.specify/feature.json` | 1 | feature pointer |

`git diff --name-only upstream/develop... -- src` is empty (SC-004). No submodule pointer is committed.

## Tests

- **Wave checks:** each wave's tests were run together with coverage. `update_ledger.py --verify-coverage`
  reported 0 problems for every wave. Any missed line not listed as exempt counts as a problem.
- **Tier checkpoints:**
  - Tier 1: 316 tests, run in five sessions of about 110 tests.
  - Tier 2: 148 tests, run in two sessions of 74.
  - Tier 3: 7 tests.

  All passed with coverage. Tier 4/5 had no testable row.
- **Review re-runs:** the 14 tests changed by the review all passed with coverage, and nothing was left behind.
- **Full suite (SC-005):** `runTestSuite` at commit 330b44ce1 on the reference machine (R2025a with
  Gurobi, no paid toolboxes, 2026-11-17). 1100 tests ran in 1413 s: 1068 passed, 30 skipped and 2 failed.
  - Failures: testClassifySubgraphIsomorphism and testExtractBondSubgraphs. Both are legacy tests that
    this branch did not change, and `src/` is unchanged. They failed the same way in the 2026-11-11
    full run of the toolbox-free feature: they compare MATLAB error identifiers recorded with another
    release. Neither is attributable to this feature.
  - Skips, all for environment reasons:
    - CPLEX: 11
    - statistics or image toolbox: 4
    - MOSEK: 3
    - NLP, EP or other missing solvers: 7
    - cxcalc: 1
    - web services: 2
    - full-mode-only XomicsToModel tests: 2
  - The 29 tests changed after commit 330b44ce1 (review revisions and header edits) were re-run with
    coverage, or had only their header comments changed.
- **Ledger check** (`update_ledger.py --check`): 0 issues. No row is PENDING, every BLOCKED row reaches
  a QUARANTINED one, and every QUARANTINED row has a confirmed defect.

## Unresolved issues

The full list is in `review.md` (section "For the human review") and `inventory/review-followups.md`.
The main ones:

1. **Missed defects among TESTED functions.** In the review sample, 12 of 40 TESTED functions had a
   defect that should have quarantined them. All 12 are now quarantined. The other 173 TESTED
   functions were not reviewed. A full review of them is recommended before merging.
2. **Quarantines that rest only on help text.** Seven quarantines rest only on help text that contradicts code
   which looks deliberate, among them parseSolverParameters (wide reach) and changeCobraSolverParams.
   A documentation fix would clear each one and unblock its callers.
3. **isSameCobraModel is quarantined,** yet many existing tests use it as their oracle (review-followups).
4. **Reviewer-reported defects not reproduced.** The reviewers report defects in already-quarantined
   functions that were not reproduced and are not in the registry (review.md, item 3).
5. **The coverage stall.** On R2025a, coverage sessions stall after about 100–125 tests: MATLAB's
   Connector thread spins. Checkpoints were therefore run in chunks. The full suite without coverage
   is not affected.
6. **Not pushed.** No push and no PR yet. Both wait for the maintainer (FR-018).

## Addendum, 2026-11-17: follow-up review of every TESTED test (T027–T030)

Maintainer: "continue building but stop before 80% of 5h usage limit". The receipt's first unresolved
issue was a review of the 173 TESTED functions outside the T021 sample, and that review is now done.
`review.md` has the details, in the section "Follow-up: every remaining TESTED test".

- **Review:** five code-only reviewer agents returned 147 OK, 5 WEAK and 21 WRONG. Four helpers
  reproduced every finding in MATLAB R2025a. The lead confirmed each quarantine and set its reach.
- **Status changes:** 21 functions moved from TESTED to QUARANTINED. transformKEGG2Model is now BLOCKED
  and its test was removed: its callee mapMetName2KEGGID has an `error` recorded by a test written
  before this feature, and is now in `inventory/existing-defective.tsv`. Five tests were strengthened,
  and four got non-quarantining entries.
- **Ledger:**

  | Status | Files |
  |---|---|
  | TESTED | 179 |
  | QUARANTINED | 291 |
  | BLOCKED | 430 |
  | EXCLUDED | 185 |

  `--check` reports 0 issues.
- **Registry:** `test/known-defects.md` lists 848 defects.
- **Tests:** the 30 changed tests were re-run together with coverage. All passed, nothing was left
  behind, and `--verify-coverage` found 0 problems.
- **Coverage** of `src/`, without the generated c13 solvers, went from 22.2% before the feature to
  26.5% (27.4% before this follow-up; quarantined tests do not count). Including those files, it went
  from 12.1% to 59.9%.
- **Unresolved issue 1 is now resolved.** Issues 2–6 still stand. Three are new:
  - multiProductionEnvelope and generateChemicalDatabase have tests from before this feature but call
    newly quarantined functions.
  - checkRankFR hard-codes the solver 'gurobi5'.
  - Two reaches rest on moderate confidence.

  All three are listed in `review.md`.

T031–T033, the same day: the defects reported in already-quarantined functions (review.md items 3 and 4)
were reproduced and added to 14 quarantine tests, with 2 triggers corrected. No status changed. The 14
tests pass with coverage, and the registry lists 863 defects. Unresolved issue 4 is resolved.
