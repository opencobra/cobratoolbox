# Implementation Plan: Fix the three remaining core blockers and test what they unblock

**Branch**: `20261125-161147-blocker-fixes-two` | **Date**: 2026-11-25 | **Spec**: [spec.md](spec.md)

## Summary

Implement the three approved fixes (optimizeCardinality, checkMassChargeBalance,
changeGeneAssociation), each test-first, with an impact report. Then unblock the ledger rows that
no longer reach a defect and test them in waves, as in feature 20261120-161825-core-blocker-fixes
(T090).

## Technical Context

**Language/Version**: MATLAB R2024b+ (tested on R2025a)

**Primary Dependencies**: the back-fill feature's tools in
`specs/20261113-142115-test-backfill-tiers/tools/` (`run_coverage.sh`, `update_ledger.py`,
`slice_prompt.py`, `privacy_check.sh`), `.github/scripts/known_defects.py`

**Testing**: the fixed functions' tests with coverage; callers' tests via `runScriptFile`; joint
coverage per wave

**Constraints**: MATLAB only via the memory-safe wrapper, at most three sessions at a time;
interfaces unchanged

**Scale/Scope**: 3 source functions, their tests, and the rows they unblock (up to 162 plus rows
that become free as waves progress)

## Constitution Check

- **Scientific code quality**: each fix restores the documented or original behaviour and was
  reviewed with the maintainer; histories checked (decisions 2 and 3).
- **Testing and reproducibility**: full tests, test-first; callers' tests per fix; joint coverage
  per wave.
- **Backward compatibility**: checkMassChargeBalance keeps `[]` (Principle II); optimizeCardinality
  changes only runs that meet status 3; changeGeneAssociation extends gene fields that were left
  short, translates as before 2017, and sizes a new `rxnGeneMat` correctly.
- **Solver abstraction / configuration audit**: optimizeCardinality's status handling follows the
  canonical `.stat` semantics (status 3 = solution exists, not proven optimal). No solver option
  changes.
- **Dependency minimisation**: none added.
- **Scope control**: the three functions, their tests, new tests for unblocked rows, the ledger,
  seeds, registry and this feature folder.
- **MATLAB standards**: no nargin added, no evalc, no warning suppression; dated NOTEs.
- **Artifact placement**: records in this feature folder; back-fill records in the back-fill
  feature's inventory, as before.

**Gate result**: PASS.

## Design

1. **optimizeCardinality**: line 906 `case 1 || 3` -> `case {1, 3}`. Test: a full test of
   `test/verifiedTests/base/testCardOpt/testOptimizeCardinality.m` (now a quarantine file) on small
   hand-built problems, with a stand-in `solveCobraLP` (temporary folder first on the path) for the
   status cases, the cosmetic warm-start defect kept in the header.
2. **checkMassChargeBalance**: lines 235 and 260 test `isempty(imBalancedMass) ||
   strcmp(imBalancedMass{q, 1}, '')`; line 260 `p` -> `q`; help as in the spec. Test: new sections in
   the legacy `testMassChargeBalance.m` (model without exchanges, all mass balanced, one charge
   imbalanced, printLevel -1 file in a tempname folder and printLevel 2 output via diary); header
   entries updated. Remove the line of `existing-defective.tsv`.
3. **changeGeneAssociation**: `nGenes = length(model.genes)` after appending; translation of the
   rule's genes before `parseGPR` against the model genes; a missing requested `rxnGeneMat` created
   as `sparse(numel(model.rxns), nGenes)`. Test: full `testChangeGeneAssociation.m`.
4. **Unblocking**: after each fix, the function's ledger row becomes TESTED (apply a result record),
   its name is removed from every BLOCKED row's reason, rows with no blocker left become PENDING,
   and `propagate` re-blocks what still reaches another defect. Quarantine seeds of the fixed
   function are removed.
5. **Waves**: `--next-wave` per tier, helpers write tests (one slice each), the lead confirms
   quarantines and reach, applies, runs joint coverage, regenerates the registry, scans for
   privacy and commits per wave.
