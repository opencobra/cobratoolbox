# Contract: a new test file

Applies to every test written in this feature. The binding rules are the constitution's
(III, III-Naming, III-Coverage, III-Defects, VII); this contract fixes only the layout so that
the ledger tools and reviewers can read every file the same way.

## Name and place

`test/verifiedTests/<category>/test<Area>/test<Name>.m`, `<Name>` = source file name with its first
letter capitalised (III-Naming). `<category>/test<Area>` = the existing folder for the source area;
a new `test<Area>` folder only if none matches. One file per source file; class files: one test
for the class.

## Header (in this order)

```
% The COBRAToolbox: test<Name>.m
%
% Purpose:
%     - <what the function does, what the test checks, and where expected values come from>
%
% Function under test:
%     src/<path>/<name>.m
%
% Tier (Constitution III-Coverage):
%     Tier <n> - <why this tier: what the test needs>
%
% Coverage exemptions:
%     <None. Every executable line is reached below.> | Line(s) <n>: <reason>; ...
%
% Known defects documented (NOT tested, NOT fixed here):
%     <None found.> | - DEFECT: ... SEVERITY: ... TRIGGER: ... OBSERVED: ... EXPECTED: ... LINES: ...
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, <date>.
```

Reference values with no independent derivation say so (Tier 5: first run, date, solver).

## Body

`currentDir = pwd;` → `cd` to the test folder → `prepareTest(...)` (no arguments for Tier 1/2;
requirements for Tier 3+) → `%%` sections, one per behaviour or branch, each with a comment saying
what it proves and why a tolerance was chosen → restore directory (and any state changed).
No `evalc`, no warning suppression; seeds fixed; temporary files in `tempname` folders that are
removed; figures invisible and closed.

## Quarantined function (III-Defects, quarantine)

Same header; "Coverage exemptions: every line — <name> is quarantined for the defect below
(feature 20261113-142115-test-backfill-tiers)"; the defect entry with its evidence; body = the
standard opening with `prepareTest()` and nothing that calls the function.
