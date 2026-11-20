# Implementation receipt — 20261120-151023-doc-matches-code

## Prompt

The maintainer, 2026-11-20: "Ok fix the cosmetic ones that are there is inconsistency between text
and code. And change the text to match the code. dont change the code. Push it to a new branch. Use
speckit to do this. Once you solved that. And now you have new good functions write test functions
for them since you could not do that before because their defect. Now fixing these functions allow
to add more test functions Allow them now and lets increase the test coverage as much as possible"

The maintainer chose the scope "Docs + 6 quarantines": the cosmetic text fixes plus the quarantines
that rest only on help text, with no code change. On re-reading, five of those six qualified.

Two questions came in during the run:
- "how many remaining tests should we potentially write for the COBRA Toolbox to have over 90% test
  coverage?" This was answered during the run.
- "So in theory how much can we expand the code coverage by fixing these 8 functions?" This is
  answered in the final response.

Run inline: spec, plan, tasks, then implementation. Five helper agents ran the cosmetic slices and
two helper agents wrote the tests; the lead did the second reading, the checks and the records.

## Final response

**Fixing the 8 core blockers would roughly double coverage, in theory.** About 259 blocked
functions would have all their blockers cleared. Together with the 8 functions themselves, they hold
about 32,000 uncovered lines.
- If new tests covered all of those lines, coverage of `src/` would rise from 26% to about 48%.
- Tests usually reach 70–85% of a function's lines, which gives about 42–45%.
- 171 blocked functions would stay blocked by other defects.
- Fixing code tends to uncover more defects, as happened today with
  `deltaG0concFluxConstraintBounds`, so treat this as an upper bound.

**The documentation work is done** and pushed to a new branch, `20261120-151023-doc-matches-code`.
It starts from the PR branch, because it builds on that branch's tests and records. Only comment
lines changed, which a script checked byte for byte, line endings included. Every changed file's
test passes.

- **Cosmetic entries:** all 146 were classified.
  - **21 help texts corrected:** they contradicted code that was clearly deliberate. Examples: wrong
    defaults, wrong output names, descriptions the wrong way round.
  - **121 left alone:** they're about messages, printing or behaviour.
  - **4 left as real bugs:** the code is the mistake, so documenting it would record a bug as
    behaviour. For example, `processConcConstraints` defaults its unit to `10-3`, which is 7.
- **5 quarantined functions cleared and now fully tested:** `parseSolverParameters`,
  `changeCobraSolverParams`, `getElementalWeightMatrix`, `getEcosystemClusterDescriptor` and
  `transportReactionBool`. Every line is covered. `readSimPhenyCMPD` stays quarantined: on a closer
  look it's a real code bug, not a documentation problem.
- **The one unblocked caller, `deltaG0concFluxConstraintBounds`, turned out to be broken.** Every
  call fails at line 307, because it calls a function name that doesn't exist. I confirmed it in
  MATLAB, so it's now quarantined instead of tested.
- **Net result:** 5 more tested functions, and the registry drops from 861 to 837 defects. The
  details are in [review.md](specs/20261120-151023-doc-matches-code/review.md).

**Coverage gain from this round is small, as expected.** It adds about 170 lines; the real gain
needs the code fixes above. If you want those, the next step would be a Spec Kit feature that fixes
the 8 core blockers' code, one at a time, each with its own review.

## Diff summary

- `src/`: comment lines only, in 26 files: the 21 class-A fixes and the 5 quarantine help texts.
  Line counts and line endings are kept (`tools/comment_only_check.py`: 0 problems).
- `test/verifiedTests/`:
  - 21 test headers (class-A entries removed, Authors lines);
  - 5 quarantine tests rewritten as full tests;
  - new `analysis/testThermo/testDeltaG0concFluxConstraintBounds.m` (quarantine layout);
  - tidy-ups: the createGroupIncidenceMatrix_jankowski name entry, and old-text quotations in
    testCalculateEPSILON, testCmpMet, testExpa and testPlotQuantitativeFluxCoupling.
- `test/known-defects.md`: regenerated, 837 defects.
- `specs/20261113-142115-test-backfill-tiers/`: ledger (6 rows, plus 300 blocked reasons), review.md
  item 2 resolved.
- `specs/20261120-151023-doc-matches-code/`: spec, checklist, plan, tasks, brief, inventory, results,
  coverage records, guard, review, this receipt. `.specify/feature.json` points to this feature.

## Tests

- Tests of the 21 class-A source files (runScriptFile): 21 passed.
- Six new or rewritten tests with coverage (`coverage.jsonl`): all passed, nothing left behind.
  - parseSolverParameters: 37/37 lines.
  - changeCobraSolverParams: 9/9.
  - getElementalWeightMatrix: 70/70.
  - getEcosystemClusterDescriptor: 24/24.
  - transportReactionBool: 27/27.
  - deltaG0concFluxConstraintBounds: 0/269, quarantined, every line exempt.
- Ledger `--check`: 0 issues. `--verify-coverage`: 0 problems. Registry check: up to date.

## Unresolved issues

- The 4 class-C defects stay open, along with the follow-ups listed in review.md.
- deltaG0concFluxConstraintBounds needs code fixes: the name at line 307, and the old
  transportReactionBool call at line 297.
- readSimPhenyCMPD stays quarantined.
- The branch is stacked on the open pull request's branch. Merge after it, or retarget it.
