# Implementation receipt — 20261102-140321-tier1-safe-defect-fixes

## Prompt

"use spec kit to fix the ones that are not problematic and affecting anything. write tests for
them. document the ones that needs our attention but does not affect Tier 2. (I assume based on
what you said there is no other group that has a bug and affect Tier 2) Then start writing tests
for TIer 2. Do all with speckit. commit and push under my accounts name not claude"

Implementation phase run by `/speckit-implement`; the US1 tasks were executed by six parallel
helper agents (one per group G1-G6 of plan.md), integration, US2, US3 and polish inline. One
receipt covers the whole run.

## Final response

The safe Tier-1 defects are fixed and tested. Of the 62 table-A defects, 59 were fixed in 50
source functions, 2 had already been fixed upstream (their stale entries were removed and their
triggers are now asserted), and 1 (`compareBounds2Models`, missing-reaction list type) was moved
to the attention list because its fix would change the output type of working calls. All 54
changed test files pass in one MATLAB session and no function's line coverage decreased. The
known-defects registry was regenerated: 33 defects in 28 functions remain (28 planned, 1 moved,
1 new defect found in `coreMetRxnAnalysis`, and 3 defects that were already written in two test
headers but never reached the registry because of a header-format slip, now repaired). The
attention document `attention-defects.md` covers every remaining registry entry and 16 problems
that are not in the registry, with priority, reach, effect of a fix, published-results impact,
Tier-2 exposure and recommendation. No known defect can silently change a Tier-2 result;
`removeFieldEntriesForType` (model manipulation) raises an error for models with `grRules` but no
`rules`, which a Tier-2 test would see as a failure, not a wrong reference.

## Diff summary

- `src/`: 50 files (table-A fixes; one-place changes, help headers updated where the documented
  behaviour changed). No table-B file changed (checked against the spec tables).
- `test/verifiedTests/`: 53 test files of table-A functions (new sections for the formerly
  skipped inputs, entries removed, exemptions/Purpose/Authors updated) plus header-format repair
  in `testCheckDuplicateRxn.m` and `testRemoveFieldEntriesForType.m`.
- `test/known-defects.md`: regenerated (90 → 33 entries).
- `specs/20261102-140321-tier1-safe-defect-fixes/`: spec, plan, research, data-model, quickstart,
  tasks, checklist, attention-defects.md, this receipt. `CLAUDE.md` plan pointer,
  `.specify/feature.json`.

## Tests

- Per function (helper agents): baseline and final run of each test through `runScriptFile`
  with line coverage of its source file (code-coverage plugin, Cobertura); every test passed and
  no covered/total ratio decreased; 13 functions gained coverage.
- Integration: all 54 changed test files run in one MATLAB R2025a session via `runScriptFile`:
  54 passed, 0 failed.
- Registry: `python3 .github/scripts/known_defects.py` exits 0 (33 defects); no table-A title
  remains.
- Scientific checks: `waterGibbsEnergyOfFormation` −237.14 kJ/mol at 298.15 K (tabulated
  −237.13); `echelonNullspace` ‖L·S‖ ≈ 1e−16; `nullspaceLUSOLapply2Modes` adjoint identity for a
  non-involutive permutation.

## Unresolved issues

- Moved to table B: `compareBounds2Models` missing-reaction list (output-type change).
- Behaviour changes within the approved scope worth noting: `assignQualDir` returns double
  instead of logical; `numToFormattedString` arrays without `nChar` now use the documented width
  8; `mapAontoB` now rejects mismatched key classes whose names have equal length;
  `compareXomicsModels`, `mapExpressionToModel`, `StopCritBDCA/Duplo`, `getDefaultValue` and
  `Combination` raise errors where they printed a message or left outputs unassigned.
- New problems documented, not fixed: see `attention-defects.md` N1-N16.
- Not verified: entropic FBA concentration methods with MOSEK (licence expired on the test
  machine); DEMETER end to end (no Statistics Toolbox).
