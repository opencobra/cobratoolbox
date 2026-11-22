# Implementation receipt — 20261120-144501-lrsspecifyrows-without-sed

## Prompt

The maintainer, 2026-11-20: "Can you fix this one? Follow-up I noticed: lrsSpecifyRows, which
lrsRun calls, uses GNU-style sed -i. That fails with macOS's BSD sed. It's outside this feature,
and I've noted it in review.md."

Run inline (spec, plan, tasks, then `/speckit-implement`) on the pull request's branch
`20261113-142115-test-backfill-tiers`, as for the lrsRun change, which the maintainer had accepted
into that pull request.

## Final response

Fixed and committed on the PR branch. Nothing is pushed yet. Say "push" and I'll push, which
updates the PR and re-runs CI.

**`lrsSpecifyRows` no longer uses `sed`.** I did this as a small Spec Kit feature, in
`specs/20261120-144501-lrsspecifyrows-without-sed/`.
- It now reads the lrs file in MATLAB, replaces the `*****` placeholders with `regexprep`, and
  writes the file back. That is base MATLAB only, option 1 of Principle XI, so it works on macOS,
  Linux and Windows.
- I checked its output against GNU `sed` byte for byte, including the edge case of six stars:
  `******` becomes `1*`, as with `sed`.

The same few lines held two defects already recorded in its test, so I fixed those too:
- A file that couldn't be opened gave "Unrecognized function or variable 'fileNameOut'" instead of
  its own error message.
- The file was never closed.

The defect registry drops from 863 to 861.

**Tests:**
- **`testLrsSpecifyRows`:** declares no requirements now. It used to need GNU `sed` on Unix, so
  macOS skipped it. It covers every line of the function, including a run with an empty `PATH`, the
  missing-file error, and a check that no file is left open.
- **`testLrsRun`:** its minimal `PATH` now holds only `lrs` and `which`.
- **Callers:** the ten lrs-related tests pass.

**PR description:** I updated
[pr-note.md](specs/20261120-140123-lrsrun-without-redund/pr-note.md). It now says two `src/` files
change, and that the registry lists 861 defects.

## Diff summary

- `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsSpecifyRows.m`: sed call replaced by
  fread/regexprep/fwrite; identifier closed; missing-file error fixed; outputs documented as 0 and ''.
- `test/verifiedTests/analysis/testLrsInterface/testLrsSpecifyRows.m`: Tier 1 without requirement;
  defect entries and exemptions removed; sections for placeholders (sed reference), empty PATH,
  unopenable file, missing begin/end, open files.
- `test/verifiedTests/analysis/testLrsInterface/testLrsRun.m`: minimal PATH lrs and which; header.
- `test/known-defects.md`: regenerated, 861 defects.
- `specs/20261120-144501-lrsspecifyrows-without-sed/`: spec, checklist, plan, research, data model,
  contract, quickstart, tasks, coverage records, this receipt.
- `specs/20261113-142115-test-backfill-tiers/`: ledger rows of lrsSpecifyRows and lrsRun, tasks
  T041, review.md, receipt addendum; `specs/20261120-140123-lrsrun-without-redund/pr-note.md`.
- `.specify/feature.json`: active feature directory.

## Tests

- New testLrsSpecifyRows against the old function: failed (file left open), as intended.
- Coverage (`coverage-after.jsonl`): testLrsSpecifyRows passed, 28 of 28 lines of lrsSpecifyRows
  (before: 20 of 22, lines 22-23 exempt); testLrsRun passed, 68 of 69 (line 156 non-Unix, exempt);
  no leftovers; `--verify-coverage` 0 problems; ledger `--check` 0 issues.
- testExtremePools, testExtremePathways, testLrsInterface and the seven other testLrs* tests passed.
- Registry regenerated and checked: 861 defects.

## Unresolved issues

- None for this feature. The pull request description must be updated by the maintainer
  (`pr-note.md`).
