# Implementation receipt — 20261120-140123-lrsrun-without-redund

## Prompt

The maintainer, 2026-11-20, after the CI fix for testLrsRun had declared `redund`:
"But we aim to minimise our dependency on third party toolboxes and proprietary applications so can
we use alternative functions or code it our selves so that these tests are not skipped? Add this
goal to the constitution."

The follow-up instructions:
- "1 - you can include the fix in the PR it is ok."
- "2 - Yes do the feature with speckit."
- "3 - This rule ... Is encouraged as much as possible. But when there is no way we can use
  proprietory softwares. BUt if we can reverse engineer them and make a local version of them we
  would."

Run by `/speckit-implement` inline, on the pull request's branch `20261113-142115-test-backfill-tiers`.

## Final response

All three are done and committed on the PR branch. Nothing is pushed yet. Say "push" and I'll push,
which updates the PR and re-runs CI.

**1–2. `lrsRun` no longer needs `redund`.** I did this as its own Spec Kit feature, in
`specs/20261120-140123-lrsrun-without-redund/` (spec, plan, tasks, then implementation).
- **`lrsRun`:** with `redund = 0` it now runs `lrs` a second time, on a temporary copy of its facet
  output that ends with the `redund 0 0` option. It no longer calls the `redund` program. The dead
  `sed` route is gone, the facet output is no longer touched, and the temporary file is removed even
  if `lrs` fails. File names, the interface and the error identifier are unchanged.
- **`testLrsRun`:** now declares only `lrs`. New checks cover:
  - a run where only `lrs`, `which` and `sed` are available;
  - an `lrs` that fails in the redundancy step;
  - that `lrsRun` leaves no stray files.
- **Results:**
  - Coverage reaches every line except the non-Unix branch.
  - The whole test passes on a `PATH` without `redund`; before the change, that run failed with the
    same exit 127 CI showed.
  - The ten lrs-related tests, `testExtremePools` and `testExtremePathways` among them, pass as
    before.
  - On five example inputs, `lrs` with the option, the installed `redund` and COBRA's bundled `lrs`
    gave identical rows.

**3. Constitution 1.10.0.** Principle XI is now a strong preference, not an absolute rule. Code takes
the first option that works:
1. base MATLAB;
2. a free component we already ship or require;
3. our own reimplementation, a local version of the proprietary function;
4. only then the proprietary software, justified in the plan and declared, so its tests are skipped,
   not failed, where it isn't installed.

On "reverse engineer", I worded it as rebuilding from public documentation and observed behaviour,
never by copying or decompiling proprietary code. That is how the toolbox-free functions were made,
and it keeps us within licence terms, which often forbid decompiling.

**Your PR description needs updating:** it still says "No file under `src/` is changed", which is
no longer true. Replacement text, covering the CI fixes, the `lrsRun` change and the constitution
amendments, is in
[pr-note.md](specs/20261120-140123-lrsrun-without-redund/pr-note.md), ready to paste.

**Follow-up I noticed:** `lrsSpecifyRows`, which `lrsRun` calls, uses GNU-style `sed -i`. That fails
with macOS's BSD `sed`. It's outside this feature, and I've noted it in review.md.

## Diff summary

- `src/analysis/topology/extremeRays/lrs/lrsInterface/lrsRun.m`: redundancy step through lrs's
  `redund 0 0` option on a temporary copy, deleted by onCleanup; `sed` route, `uselrsRedundOption`
  and the unused `redundCmd` removed; help text (`.redund`, NOTE) updated.
- `test/verifiedTests/analysis/testLrsInterface/testLrsRun.m`: requirement lrs only; new checks
  (facet output untouched, no extra files, no temporary leftovers, run with only lrs/which/sed on
  the PATH, lrs failing in the redundancy step); header (Purpose, Tier, exemption line 156, Authors).
- `specs/20261120-140123-lrsrun-without-redund/`: spec, checklist, plan, research, data model,
  contract, quickstart, tasks, coverage records, pr-note, this receipt.
- `specs/20261113-142115-test-backfill-tiers/`: ledger row of lrsRun (exempt 156), tasks T040,
  review.md note, receipt addendum.
- `.specify/feature.json`: active feature directory.

## Tests

- testLrsRun against the old lrsRun with the new checks: failed in the run without redund (exit
  127), as intended; against the new lrsRun: passed.
- Coverage (`coverage-after.jsonl`): passed, 68 of 69 executable lines, missed only 156 (non-Unix,
  exempt); no leftovers; `--verify-coverage` 0 problems. Before (`coverage-before.jsonl`): 65 of 69.
- Whole test on a PATH without redund: passed.
- testExtremePools, testExtremePathways, testLrsInterface and the seven other testLrs* tests:
  passed before and after.
- Ledger `--check` 0 issues; registry unchanged (863 defects).

## Unresolved issues

- lrslib 7 or later is assumed for `redund = 0` (bundled: 7.3).
- `lrsSpecifyRows` uses GNU `sed -i` (fails on macOS); outside this feature.
- The pull request description must be updated by the maintainer (`pr-note.md`).
