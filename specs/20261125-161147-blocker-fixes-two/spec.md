# Feature Specification: Fix the three remaining core blockers and test what they unblock

**Feature Branch**: `20261125-161147-blocker-fixes-two`, from opencobra `develop` (b2ee95703, after
pull request #2728).

**Created**: 2026-11-25

**Status**: Approved decisions 1-3; implementation authorised.

**Input**: Maintainer, 2026-11-25, reviewing the blocking defects one by one ("walk me through each
defect one by one"): #1 "yes I agree with the fix lets continue to the next"; #2 "ok I agree with
the fix for mass balance function" (the revised fix that keeps `[]`); #3 "yes I agree with all
three, next one"; then "write the unblocked tests sofar and write every test that we can sofar and
push the tests".

## Context

After feature 20261120-161825-core-blocker-fixes, the back-fill ledger
(`specs/20261113-142115-test-backfill-tiers/inventory/ledger.tsv`) has no PENDING row: 224 TESTED,
319 QUARANTINED, 188 EXCLUDED, 354 BLOCKED. Three defective functions reach most BLOCKED rows:

| # | Function | Blocked rows reaching it | Only blocker |
|---|---|---|---|
| 1 | optimizeCardinality | 247 | 8 |
| 2 | checkMassChargeBalance | 239 | 1 |
| 3 | changeGeneAssociation | 128 | 22 |

Together they free 162 rows (every blocker of those rows is one of the three).

## Decisions

### 1. optimizeCardinality: approved 2026-11-25

- **Defect "An LP status 3 ends the iterations with status -1 instead of proceeding"** (line 906):
  `case 1 || 3` evaluates to `case true`, that is `case 1`, so status 3 falls to `otherwise`. Fix:
  `case {1, 3}`, as the sub-problem (line 1159, which prints "proceeding") and the final report
  (line 1059) already treat 1 and 3 alike.
- **Not included:** the cosmetic defect "the random warm start is not protected against infinite
  bounds"; it stays recorded.

### 2. checkMassChargeBalance: approved 2026-11-25 (revised version)

The empty `imBalancedMass` for a model whose reactions are all mass balanced predates 2017 and is
read as a deliberate convention: the original help placed "empty if no imbalanced reactions" on the
neighbouring output `imBalancedCharge`, whose code never empties it. Backward compatibility
(Principle II) keeps `[]`.

- **Keep** `imBalancedMass = []` when every reaction is mass balanced (lines 200-202).
- **Defect "printLevel -1 and 2 stop when every reaction is mass balanced and a charge is not"**
  (lines 235, 260): treat an empty `imBalancedMass` as "every reaction mass balanced" instead of
  indexing it.
- **Defect "stale index p"** (line 260): the `printLevel` 2 loop over `q` tests `imBalancedMass{p, 1}`;
  use `q`.
- **Help:** `imBalancedMass` gets "empty if every reaction is mass balanced";
  `imBalancedCharge` loses "empty if no imbalanced reactions" (it is always nRxn x 1). NOTE dated.
- **Registry:** the entry "imBalancedMass is [] instead of an nRxn x 1 cell" is not a defect of the
  code; it is resolved by the help correction.

### 3. changeGeneAssociation: approved 2026-11-25 (fixes a-c)

All three come from the 2017 refactoring `5f8e82a086`, which replaced the gene-by-gene loop with
`parseGPR`.

- **a. "New genes do not extend the other gene fields"** (lines 57-58, 88-90): update `nGenes` after
  the new genes are appended, so `extendModelFieldsForType` extends `proteins`, `geneNames` and the
  other gene fields with their defaults.
- **b. "Translated gene names are taken from the wrong positions"** (lines 71-72): restore the pre-2017
  behaviour. Translate the gene names of the rule (common name -> systematic name, each gene by its
  own position in `geneNameList`; a name not in the list is kept) before looking them up in
  `model.genes`, so a translated gene already in the model is reused, not added twice.
- **c. "A requested rxnGeneMat is created with one row per reaction up to the changed one"**
  (lines 66, 81): create a missing `rxnGeneMat` as reactions x genes before setting the row.

### Not included

readSimPhenyCMPD (#4 of the ranking) awaits the maintainer's decision and is not edited.

## User Scenarios & Testing

### User Story 1 - The three functions behave as documented (Priority: P1)

**Independent Test**: each fixed function has a full test, seen to fail on the old code and to
pass on the new, with every line covered or exempted in its header.

**Acceptance Scenarios**:

1. **Given** a stand-in `solveCobraLP` that returns status 3 for a sub-problem, **When**
   optimizeCardinality runs, **Then** the iterations proceed and the solution has status 1 or 3.
2. **Given** a model without exchange reactions whose reactions are all mass balanced and one
   charge-imbalanced, **When** checkMassChargeBalance runs with printLevel -1 or 2, **Then** it
   returns `imBalancedMass = []` and lists the charge-imbalanced reaction (in the file, or printed).
3. **Given** a model with `proteins`, **When** changeGeneAssociation adds a new gene, **Then** every
   gene field has as many entries as `genes`; translated names land on the right genes; a requested
   `rxnGeneMat` is reactions x genes.

### User Story 2 - Callers' results are reported (Priority: P1)

For each fix, the outputs that can change are named and the callers' tests are run
(`review.md`).

### User Story 3 - The unblocked functions get tests (Priority: P2)

Every row that no longer reaches a defect becomes PENDING and gets a test, a quarantine or an
exclusion, with the back-fill campaign's procedure (waves, confirmed quarantines, joint coverage,
registry), until no PENDING row remains.

## Requirements

- **FR-001**: Only the approved decisions are implemented; interfaces and output shapes are
  unchanged (Principle II), apart from the help corrections.
- **FR-002**: Each fixed function's test is written first and seen to fail on the old code.
- **FR-003**: Each fix has a dated NOTE in the help (VII-E).
- **FR-004**: Ledger, quarantine seeds, existing-defective list and registry are updated to match.
- **FR-005**: The back-fill campaign's rules apply to the unblocked rows (quarantine with
  confirmation, reach rule, late-edge rule, coverage exemptions in the header).
- **FR-006**: Commits as the maintainer, no co-author line, no submodule pointers; privacy scan
  before each commit; push when the maintainer asks (asked 2026-11-25: "push the tests").

## Success Criteria

- **SC-001**: The three tests pass with full coverage or documented exemptions.
- **SC-002**: The callers' tests that ran before still pass.
- **SC-003**: No PENDING row remains in the ledger at the end.
- **SC-004**: The registry is regenerated and `update_ledger.py --check` reports no issue.
