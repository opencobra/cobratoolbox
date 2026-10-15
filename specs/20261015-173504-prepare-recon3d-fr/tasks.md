---
description: "Task list for generateFullRowRankFR (full-row-rank [F,R] model preparation)"
---

# Tasks: Full-row-rank [F,R] model preparation (`generateFullRowRankFR`)

**Input**: Design documents from `specs/20261015-173504-prepare-recon3d-fr/`

**Prerequisites**: plan.md, spec.md, research.md (R1–R11), data-model.md, contracts/generateFullRowRankFR.md, quickstart.md

**Tests**: required. Spec FR-016 and FR-017, Principle III. Tests are written first, and each fixture's starting `[F, R]` structure is confirmed numerically before any assertion targets the function.

**Organization**: grouped by user story (spec.md):
- US1 (P1): zero rows and identical rows;
- US2 (P2): sum dependency through dead ends;
- US3 (P2): honest stop;
- US5 (P2): opt-in general removal guaranteeing full row rank;
- US4 (P3): unchanged full-rank model.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: can run in parallel (different files, no dependency on incomplete tasks)
- **[Story]**: US1–US4 from spec.md

## Path Conventions

- Source: `src/analysis/topology/FR/generateFullRowRankFR.m`. One file; the helpers are local functions.
- Test: `test/verifiedTests/analysis/testTopology/testGenerateFullRowRankFR.m`. One file (III-Naming); the fixture builders are local functions at the end of the script.
- Feature evidence: `specs/20261015-173504-prepare-recon3d-fr/measurements/`.
- Notation, report fields and reasons are exactly as in `data-model.md`. Guarantees are exactly as in `contracts/generateFullRowRankFR.md`.

---

## Phase 1: Setup (shared infrastructure)

**Purpose**: test scaffold and fixtures. The fixtures are verified numerically before the function exists.

- [X] T001 Create `test/verifiedTests/analysis/testTopology/testGenerateFullRowRankFR.m` following `documentation/source/guides/testTemplate.m`. It needs:
  - the header block (Purpose, Authors);
  - `prepareTest()` with no solver requirement;
  - `currentDir = cd(fileparts(which(mfilename)))`, with `cd(currentDir)` at the end;
  - `tol = 1e-9`;
  - a local helper `[F, R, FR] = frOf(model, rxnBool)` that computes `N = model.S(:, rxnBool)`, `F = max(-N, 0)`, `R = max(N, 0)` (for assertions only; not a copy of the function under test).
- [X] T002 In `testGenerateFullRowRankFR.m`, add local fixture builders. Each returns a COBRA model with fields `S`, `mets`, `rxns`, `lb`, `ub`, `c`, `b`, `csense`, `rxnNames`, `metNames`, `genes`, `rules`, `grRules`, `subSystems` (legacy char entries, to exercise R6), and `SConsistentRxnBool` marking the internal columns. Build them with `createModel` or by assembling the struct directly. The fixtures, with metabolites listed in this order:
  - `fixtureFullRank`: mets `A, B, C`; `r1: A -> B`, `r2: B -> C`, `r3: C -> A`.
  - `fixtureZeroRow`: `fixtureFullRank` plus met `X` and an external column `EX_X: X <=>`, which is not internal.
  - `fixtureIdenticalPair`: `fixtureFullRank` plus mets `P, Q` and `r4: A + P + Q -> B`.
  - `fixtureFiveGroup`: `fixtureFullRank` plus mets `G1..G5`, `r4: A + G1 + G2 + G3 + G4 + G5 -> B`, and `r5: B + G1 + G2 + G3 + G4 + G5 -> C`.
  - `fixturePreexistingDuplicate`: `fixtureIdenticalPair` plus `r5: 2 A + 2 P + 2 Q -> 2 B`.
  - `fixtureSumDependency`: mets `A, B, P, D1, D2, D3`; `ra: A -> B`, `rb: B -> A`, and `ri: A -> P + Di` for i = 1..3. Give r1 and r2 a shared GPR and r3 its own gene, so that `removeUnusedGenes` is exercised.
  - `fixtureIrreducible`: mets `A, B, C, D, P, Q`; `r1: A + B -> P`, `r2: C + D -> P`, `r3: A + C -> Q`, `r4: B + D -> Q`.
  - `fixtureIrreducibleBackbone`: `fixtureIrreducible` plus `r5: P -> Q` and `r6: Q -> P` (User Story 5; research R12).
  - `fixtureTwoPass`: `fixtureSumDependency` plus met `X` and external `EX_X: X <=>`. It needs a zero-row pass and then a dead-end pass (iteration-limit case).
- [X] T003 Verify every fixture's starting structure numerically in the MATLAB MCP session, before writing any assertion on the function, and record the output in `specs/20261015-173504-prepare-recon3d-fr/measurements/fixtureCheck.log`. Use `getRankLUSOL` and MATLAB `rank(full(FR))`, which is fine at this size. Expected:

  | Fixture | m | rank | Structure |
  |---|---|---|---|
  | fullRank | 3 | 3 | — |
  | zeroRow | 4 | 3 | `X` is the zero row |
  | identicalPair | 5 | 4 | `P`/`Q` identical |
  | fiveGroup | 8 | 4 | `G1..G5` identical |
  | preexistingDuplicate | 5 | 4 | — |
  | sumDependency | 6 | 5 | `y = e_P − e_D1 − e_D2 − e_D3` |
  | irreducible | 6 | 5 | `y = e_A − e_B − e_C + e_D`; no identical rows; every support species in ≥ 2 internal reactions |
  | irreducibleBackbone | 6 | 5 | same witness |
  | twoPass | 7 | 5 | `X` zero row plus the sumDependency witness |

  If any fixture deviates, fix the fixture (not the expectation) and re-run.

---

## Phase 2: Foundational (blocking prerequisites)

**Purpose**: the function skeleton that every story extends.

**⚠️ CRITICAL**: no user-story work begins until this phase is complete.

- [X] T004 Create `src/analysis/topology/FR/generateFullRowRankFR.m` with the canonical signature `function [modelOut, report] = generateFullRowRankFR(model, param)` and the full openCOBRA header (VII-E): USAGE, INPUTS, OPTIONAL INPUTS (each `param` field with its default from data-model.md), OUTPUTS (every `report` field from data-model.md), EXAMPLE, NOTE, Author. The NOTE states the definitions of `N`, `F`, `R` and the goal `rank([F, R]) = m`. Write the header in a neutral voice, with no agent instructions (Principle X).
- [X] T005 In `generateFullRowRankFR.m`, implement parameter handling with `exist`/`isempty` checks, not `nargin` (VII-D). Defaults: `printLevel = 0`, `remedy = 'lump'`, `tol = 1e-9`, `irreducibleRemedy = 'stop'`, and `maxIterations = 20`. When `irreducibleRemedy = 'removeMetabolites'`, the default `maxIterations` is instead `m + n` of the input (R12). Validation errors:
  - `generateFullRowRankFR:badRemedy` when `remedy` is not in {`lump`, `removeRxns`};
  - `generateFullRowRankFR:badIrreducibleRemedy` when `irreducibleRemedy` is not in {`stop`, `removeMetabolites`};
  - `generateFullRowRankFR:badRxnBool` when `param.rxnBool` has the wrong length.
- [X] T006 In `generateFullRowRankFR.m`, implement the local function `initReport`. It returns the report struct with every field from data-model.md present and initialised: empty struct arrays carry their declared fields at size 0×1 (including `removedCtrs`), `stopReason = ''`, `generalRemovalUsed = false`, and `flaggedForReview` is an empty struct array.
- [X] T007 In `generateFullRowRankFR.m`, implement the local function `recordEdit` (R13, contract 5a). It takes the model before and after one edit, the explicitly targeted metabolites and reactions with their reason, and the iteration:
  - targeted items are appended with the given reason;
  - every other metabolite missing from the after-model is appended with reason `orphaned`;
  - every other reaction missing is appended with reason `emptyColumn`, with `internal` from the pre-edit `rxnBool`;
  - every missing `ctrs` entry is appended to `removedCtrs`.

  Every edit in later tasks goes through `recordEdit`.
- [X] T008 In `generateFullRowRankFR.m`, implement column-selection resolution (research R10):
  1. use `param.rxnBool` if given;
  2. else `model.SConsistentRxnBool`;
  3. else call `findSExRxnInd` on a **copy** and take `SIntRxnBool`.

  Record `report.rxnBoolSource`. Carry `rxnBool` as a logical vector aligned with `model.rxns`, plus a helper that re-indexes it by reaction ID after any removal. If the **input** selects no column, stop with `stopReason = 'noInternalReactions'`. This check runs once, on the input only (analysis U1). If a later edit leaves no internal columns, `[F, R]` has only zero rows, step 1 removes them, and m = 0 counts as full row rank (keeps FR-021).
- [X] T009 In `generateFullRowRankFR.m`, implement the local function `decideRank(FR, iteration)` (research R7):
  - if `FR` has no rows (m = 0) or no columns, return rank 0 with method `'empty'` and skip both factorisations. An empty `[F, R]` (m = 0) counts as full row rank, which FR-021 relies on (analysis E1);
  - compute `getRankLUSOL(FR, 0)`;
  - compute the sparse-QR rank `qr(FR', sparse(size(FR,2),0), 0)` with threshold `max(size(FR))*eps*max(abs(diag(Rq)))`;
  - if they agree, return the LUSOL rank with method `'getRankLUSOL'`;
  - otherwise return the QR rank with method `'sparseQR'` and issue `warning('generateFullRowRankFR:rankDisagreement', ...)` naming both values.

  Append to `report.rankLog` and `report.rankMethod`.
- [X] T010 In `generateFullRowRankFR.m`, implement the main loop shell:
  - Fill `mBefore`, `nBefore` and `rankBefore`.
  - For `iteration = 1:maxIterations`: compute `FR`, `decideRank`, and break if `rank == m`. Otherwise dispatch to step 1, then step 2, then step 3 (stubs for now), each of which reports whether it edited the model.
  - If no step edits, stop.
  - After the loop, recompute rank and fill `mAfter`, `nAfter`, `rankAfter`, `fullRowRank` and `iterations`. Set `stopReason = 'maxIterations'` when the loop ended deficient without another stop reason.
  - Print a per-pass summary only when `printLevel >= 1`.
  - Return `modelOut = model` untouched when the first rank check is already full (SC-006).
- [X] T011 [P] Apply the MATLAB best-practice check (VII-F) to `generateFullRowRankFR.m`:
  - run the `matlab-core:matlab-review-code` skill and MCP `check_matlab_code`;
  - confirm there is no `evalc`, no warning suppression, and no `nargin`;
  - confirm any `try/catch` propagates `ME.stack`;
  - confirm openCOBRA style (VII-G) controls where it differs from the skill.

**Checkpoint**: the skeleton runs on `fixtureFullRank` and returns an initialised report.

---

## Phase 3: User Story 1 — repair zero rows and identical rows (Priority: P1) 🎯 MVP

**Goal**: remove zero rows and lump identical-row groups (or remove their reactions under `remedy = 'removeRxns'`), with a full report.

**Independent Test**: the zeroRow, identicalPair, fiveGroup and preexistingDuplicate fixtures, plus identicalPair with `remedy = 'removeRxns'`, each reach full row rank with exact report contents.

### Tests for User Story 1 (write first; confirm they fail against the Phase-2 skeleton)

- [X] T012 [P] [US1] In `testGenerateFullRowRankFR.m`, add the **zeroRow** case (US1-AS1, FR-005). Assert:
  - `fullRowRank`;
  - `rankAfter == mAfter == 3`;
  - `removedMets` is exactly `{X}` with reason `zeroRow`;
  - `removedRxns` is exactly `{EX_X}` with reason `emptyColumn` (R5);
  - `lumpedGroups` and `nullVectors` are empty.
- [X] T013 [P] [US1] In `testGenerateFullRowRankFR.m`, add the **identicalPair** case (US1-AS2, FR-006). Assert:
  - one `lumpedGroups` entry with `members = {P; Q}`, `representative = 'P'`, `rxnsRewritten = {r4}`, `differenceVectors = {{'Q', +1; 'P', -1}}`;
  - `removedMets` is `{Q}` with reason `lumped`;
  - the `r4` column contains exactly `A`, `P`, `B` with coefficients `-1, -1, +1`;
  - full row rank.
  - **Field preservation (R6, contract 4)**: every reaction-indexed field of `r4` other than `S` equals its input value, with `grRules` compared after removing whitespace. In particular `subSystems{r4}` is byte-identical, still a char entry.
- [X] T014 [P] [US1] In `testGenerateFullRowRankFR.m`, add the **fiveGroup** case (US1-AS3). Assert:
  - one group with members `G1..G5`, representative `G1`, and 4 difference vectors, each `{Gi, +1; G1, -1}` for i = 2..5;
  - `rxnsRewritten = {r4; r5}`;
  - 4 `lumped` removals;
  - full row rank.
- [X] T015 [P] [US1] In `testGenerateFullRowRankFR.m`, add the **identicalPair with `remedy = 'removeRxns'`** case (US1-AS4). Assert:
  - `removedRxns` is `{r4}` with reason `identicalRowGroup`;
  - the group is recorded with `representative = ''` and empty `rxnsRewritten`;
  - `P` and `Q` are removed in the same pass as `orphaned`, because `removeRxns` drops metabolites used only by removed reactions (R13);
  - full row rank.
- [X] T016 [P] [US1] In `testGenerateFullRowRankFR.m`, add the **preexistingDuplicate** case (US1-AS5, FR-007, R5a). Assert:
  - no `removedRxns` entry has reason `duplicateAfterLump`;
  - both `r4` and `r5` remain, both rewritten;
  - full row rank.

### Implementation for User Story 1

- [X] T017 [US1] In `generateFullRowRankFR.m`, implement step 1 (FR-005, R5):
  - find the zero rows of `FR`;
  - `removeMetabolites(model, mets, false)`, then `removeTrivialStoichiometry`, as one edit through `recordEdit`: targeted metabolites get `zeroRow`, and emptied columns become `emptyColumn` automatically;
  - then `removeUnusedGenes`;
  - re-index `rxnBool`.
- [X] T018 [US1] In `generateFullRowRankFR.m`, implement the local function `findIdenticalGroups(FR)` using `unique(FR, 'rows', 'stable')` (R4). It ignores zero rows and returns groups of ≥ 2 row indices in model order. The representative is the first member (R9).
- [X] T019 [US1] In `generateFullRowRankFR.m`, implement the local function `lumpGroup` for `remedy = 'lump'` (FR-006, R6):
  - for each internal reaction containing the group (found with `findRxnsFromMets` intersected with `rxnBool`), call `addReaction(model, rxnId, 'metaboliteList', ..., 'stoichCoeffList', ..., 'lowerBound', lb, 'upperBound', ub, 'objectiveCoef', c, 'reactionName', name, 'geneRule', grRule, 'subSystem', subSys)`, passing the original column minus the non-representative members;
  - then restore the original `subSystems` entry exactly;
  - then `removeMetabolites(model, others, false)` followed by `removeTrivialStoichiometry`, as one edit through `recordEdit` (reason `lumped`);
  - record `members`, `representative`, `rxnsRewritten`, `differenceVectors` and `iteration`.

  Do not suppress `addReaction`'s update warning (VII-B).
- [X] T020 [US1] In `generateFullRowRankFR.m`, implement the `remedy = 'removeRxns'` branch of step 2:
  - remove the internal reactions containing each group with `removeRxns` (reason `identicalRowGroup`), then `removeUnusedGenes`;
  - record the group with `representative = ''`.
- [X] T021 [US1] In `generateFullRowRankFR.m`, implement the local function `removeNewInternalDuplicates` (FR-007, R5, R5a):
  - call `checkDuplicateRxn(model, 'FR', 0, 0)` before and after the lump rewrite;
  - remove only reactions that are internal **and** newly flagged, with `removeRxns` (reason `duplicateAfterLump`);
  - repeat until none are newly flagged.
- [X] T022 [US1] Run `testGenerateFullRowRankFR` (cases T012–T016) through the MATLAB MCP session. All US1 cases must pass. Fix the source, not the expectations, unless a measured fixture fact (T003) contradicts an expectation; in that case record it in `measurements/fixtureCheck.log`.

**Checkpoint**: US1 is fully functional. This is the MVP: it repairs 14/15 Recon3T deficiencies and the whole of iDopaNeuroC.

---

## Phase 4: User Story 2 — sum dependencies through dead ends (Priority: P2)

**Goal**: certify the remaining dependencies with left-null witnesses, and remove dead-end reactions.

**Independent Test**: on the sumDependency fixture, the function finds one witness with residual ≤ `tol` and removes `r1..r3` (reason `deadEnd`). `P, D1, D2, D3` go in the same pass as `orphaned` (R13), and the model reaches full row rank.

### Tests for User Story 2

- [X] T023 [P] [US2] In `testGenerateFullRowRankFR.m`, add the **sumDependency** case (US2-AS1/AS2, FR-008, FR-009, SC-004). Assert:
  - exactly one `nullVectors` entry;
  - support `{P, D1, D2, D3}` with coefficients proportional to `[1, -1, -1, -1]`;
  - `residual <= tol`;
  - `remedy = 'deadEndRemoval'` and `rxnsRemoved = {r1; r2; r3}`;
  - `removedRxns` reasons are `deadEnd` for `r1..r3`;
  - `removedMets` is `{P, D1, D2, D3}` with reason `orphaned`, iteration 1 (R13);
  - the gene used only by `r3` is gone from `modelOut.genes` (FR-011);
  - `ra` and `rb` are unchanged;
  - full row rank, with m = 2.

  Also assert `flaggedForReview`: `r1..r3` share only substrate `A`, which is common to the whole remedy, so the list is empty.

### Implementation for User Story 2

- [X] T024 [US2] In `generateFullRowRankFR.m`, implement the local function `leftNullWitnesses(FR, tol)` (R8):
  - column-pivoted sparse QR of `FR'`;
  - for each dependent pivot column, build `y` from `Rq(1:r,1:r) \ Rq(1:r, r+t)`;
  - support `= find(abs(y) > tol*max(abs(y)))`;
  - `residual = norm(FR'*y, inf)`;
  - issue a `warning` if `residual > tol`; never silently accept such a vector.
- [X] T025 [US2] In `generateFullRowRankFR.m`, implement step 3's dead-end remedy (FR-009):
  - dead end = a support species whose row of `N` has exactly one nonzero;
  - collect the single internal reaction of every dead end across all witnesses of the pass, and remove them with `removeRxns` through `recordEdit` (reason `deadEnd`; orphans are captured automatically), then `removeUnusedGenes`, then re-index `rxnBool`;
  - record each witness's `support`, `coefficients`, `residual`, `remedy` and `rxnsRemoved`.

  Any species left in zero rows but still present (for example ones with external reactions, as on Recon3T) is handled by step 1 on the next pass.
- [X] T026 [US2] In `generateFullRowRankFR.m`, compute `flaggedForReview` per remedy (data-model.md): the pairs of removed reactions that share a substrate (F-support), excluding substrates common to every reaction in that remedy.
- [X] T027 [US2] Run `testGenerateFullRowRankFR` (T023 plus all US1 cases) through MCP. All must pass.

**Checkpoint**: US1 and US2 both work. Every structural deficiency type in Recon3T is covered.

---

## Phase 5: User Story 3 — stop honestly (Priority: P2)

**Goal**: no guessed edits. Return the witness and a stop reason.

**Independent Test**: the irreducible fixture returns `fullRowRank = false`, `stopReason = 'irreducibleDependency'`, a witness with `remedy = 'none'`, and a model `isequal` to the input.

### Tests for User Story 3

- [X] T028 [P] [US3] In `testGenerateFullRowRankFR.m`, add the **irreducible** case (US3-AS1, FR-010, contract 6). Assert:
  - `fullRowRank == false` and `stopReason == 'irreducibleDependency'`;
  - one `nullVectors` entry with support `{A, B, C, D}`, coefficients proportional to `[1, -1, -1, 1]`, `residual <= tol` and `remedy == 'none'`;
  - `removedMets`, `removedRxns` and `lumpedGroups` are empty;
  - `isequal(modelOut, model)`.
- [X] T029 [P] [US3] In `testGenerateFullRowRankFR.m`, add the **iteration-limit** case (US3-AS2): `fixtureTwoPass` with `param.maxIterations = 1`. Assert:
  - `stopReason == 'maxIterations'` and `fullRowRank == false`;
  - `iterations == 1`;
  - `removedMets` is `{X}` (`zeroRow`) and `removedRxns` is `{EX_X}` (`emptyColumn`);
  - `r1..r3` are not yet removed.

  Also run the same fixture with the default `maxIterations` and assert full row rank after the dead-end pass.
- [X] T030 [P] [US3] In `testGenerateFullRowRankFR.m`, add the error-path cases with `verifyCobraFunctionError`: `remedy = 'bogus'` raises `generateFullRowRankFR:badRemedy`, `irreducibleRemedy = 'bogus'` raises `generateFullRowRankFR:badIrreducibleRemedy`, and a wrong-length `rxnBool` raises `generateFullRowRankFR:badRxnBool`.

### Implementation for User Story 3

- [X] T031 [US3] In `generateFullRowRankFR.m`, complete the stop logic:
  - when step 3 finds no dead end in any support and `irreducibleRemedy == 'stop'`, record every witness with `remedy = 'none'`, set `stopReason = 'irreducibleDependency'`, make no edit, and leave the loop;
  - make sure the `maxIterations` and `noInternalReactions` paths also return a fully initialised report (SC-005).
- [X] T032 [US3] Run `testGenerateFullRowRankFR` (US1–US3 cases) through MCP. All must pass.

**Checkpoint**: every return path is covered.

---

## Phase 5b: User Story 5 — force full row rank by general removal (Priority: P2)

**Goal**: an opt-in fallback, `irreducibleRemedy = 'removeMetabolites'`, that removes the deterministically chosen problematic species together with all their reactions via `removeMetabolites`, guaranteeing full row rank.

**Independent Test**: `fixtureIrreducibleBackbone` with the option on ends at `{P, Q}` / `{r5, r6}` with full row rank. Every removal is reported (R12).

### Tests for User Story 5

- [X] T033 [P] [US5] In `testGenerateFullRowRankFR.m`, add the **general-removal** case (US5-AS1, FR-018–FR-021, SC-008) on `fixtureIrreducibleBackbone` with `irreducibleRemedy = 'removeMetabolites'`. Assert:
  - `fullRowRank`, `generalRemovalUsed == true`, `stopReason == ''`;
  - pass 1: one `nullVectors` entry with remedy `generalRemoval`, `chosenMet == 'A'` and `rxnsRemoved = {r1; r3}`. `removedMets` has `A` (`generalRemoval`); `removedRxns` has `r1` and `r3` (`generalRemoval`, `internal = true`);
  - pass 2: witness support `{B, C, D}` with remedy `deadEndRemoval`; `r2` and `r4` removed as `deadEnd`; `B, C, D` removed as `orphaned`;
  - final `modelOut.mets == {P; Q}` and `modelOut.rxns == {r5; r6}`, with `S` columns of `r5` and `r6` equal to the input (SC-008);
  - the union of report lists equals `setdiff(input, output)` for both mets and rxns (contract 5a).
- [X] T034 [P] [US5] In `testGenerateFullRowRankFR.m`, add the **option-is-inert** case (US5-AS2, US5-AS3). Run each US1/US2 fixture with `irreducibleRemedy = 'removeMetabolites'` and assert `isequal` `modelOut` and `report` (apart from `generalRemovalUsed`, which must be false) against the default run. Run `fixtureIrreducible` with the option off and assert the US3 result unchanged.
- [X] T035 [P] [US5] In `testGenerateFullRowRankFR.m`, add the **external-reaction** case (edge case: general removal touches external reactions). Take `fixtureIrreducibleBackbone` plus an external `EX_A: A <=>` and turn the option on. With FR-019, `A` now deletes 3 columns, so the choice moves to the next species with the fewest reactions (`B`, by model order among the ties). Assert:
  - the chosen species and its reactions, including its external reaction if any, are reported with `generalRemoval`, with correct `internal` flags;
  - full row rank;
  - the expected chosen species is first confirmed numerically and recorded in `measurements/fixtureCheck.log`.

### Implementation for User Story 5

- [X] T036 [US5] In `generateFullRowRankFR.m`, implement the local function `chooseGeneralRemoval(model, rxnBool, witnesses)` (FR-019). For each witness, sort its support by:
  1. the total number of nonzero `S` columns, ascending;
  2. the number of internal nonzero columns, ascending;
  3. the index in `model.mets`, ascending.

  Take the first; return the unique chosen species in order of first choice.
- [X] T037 [US5] In `generateFullRowRankFR.m`, branch step 3 when no dead end exists and `irreducibleRemedy == 'removeMetabolites'` (FR-018, FR-020):
  - call `[model, rxnRemovedList] = removeMetabolites(model, chosen, true, 'inclusive')` through `recordEdit`, with reason `generalRemoval` for the chosen species and for every reaction in `rxnRemovedList`;
  - then `removeUnusedGenes` and re-index `rxnBool`;
  - fill each witness's `remedy`, `chosenMet` and `rxnsRemoved`, and set `generalRemovalUsed = true`;
  - continue the loop.

  This branch must be unreachable in a pass where steps 1 or 2 or the dead-end remedy edited.
- [X] T038 [US5] Update the `generateFullRowRankFR.m` header (T004) to document `irreducibleRemedy`, the choice rule, the `m + n` default bound, and that external reactions containing a chosen species are removed. Write it in a neutral voice (Principle X).
- [X] T039 [US5] Run `testGenerateFullRowRankFR` (US1–US3 and US5 cases) through MCP. All must pass.

**Checkpoint**: the opt-in guarantee holds, and the default behaviour is unchanged.

---

## Phase 6: User Story 4 — leave a valid model untouched (Priority: P3)

**Goal**: return a full-rank input unchanged.

**Independent Test**: `fixtureFullRank` gives `isequal(modelOut, model)` and the empty-report invariant.

- [X] T040 [P] [US4] In `testGenerateFullRowRankFR.m`, add the **fullRank** case (US4-AS1, SC-006, data-model empty-report invariant). Assert:
  - `isequal(modelOut, model)`;
  - every change list is empty;
  - `fullRowRank`, `iterations == 1`, `stopReason == ''`;
  - `rankBefore == rankAfter == mBefore == mAfter == 3`.

  Repeat with `SConsistentRxnBool` removed from the fixture, so that the `findSExRxnInd` path is used. Assert `rxnBoolSource == 'findSExRxnInd'` and that `modelOut` has **no** added fields (R10).
- [X] T041 [P] [US4] In `testGenerateFullRowRankFR.m`, add the cross-cutting assertions run over every fixture case above:
  - every data-model.md report field exists (SC-005);
  - a second identical call returns `isequal` `modelOut` and `report` (contract 8, determinism);
  - running with `printLevel = 0` produces no output from `generateFullRowRankFR`'s own `fprintf` (SC-007). Capture with **`diary`, not `evalc`**, so warnings still reach the console (VII-A, VII-B; analysis D1):
    1. save `previousDiaryFile = get(0, 'DiaryFile')` and `previousDiaryState = get(0, 'Diary')`;
    2. write to `tempname`, call the function, then `diary off`;
    3. restore the previous diary file and state, and delete the temp file;
    4. read the temp file and assert that, after removing the lines of the expected `addReaction` warnings ("Warning: Reaction with the same name already exists in the model, updating the reaction"), it is empty.
  - As a static complement, T049 confirms that every `fprintf` and `disp` in the source sits under an `if printLevel ...` guard.
- [X] T042 [US4] Run the full `testGenerateFullRowRankFR` through MCP. All fixture cases must pass.

---

## Phase 7: Large-model acceptance (cross-story integration)

**Purpose**: SC-002, SC-002b and SC-003 on real models. These need US1 and US2.

- [X] T043 [P] In `testGenerateFullRowRankFR.m`, add the **in-repo Recon3D** case (SC-002b), using `model = getDistributedModel('Recon3DModel_301_xomics_input.mat')`. Assert:
  - `mBefore == 5835` and `rankBefore == 5826`;
  - the 6 lumped groups with exactly the members in SC-002b, with `HC00004/6/7/8[e]` as a 4-member group, and their `rxnsRewritten`;
  - one null vector with support 15 and `residual <= tol`;
  - `removedRxns` with reason `deadEnd` equal to the 14 SC-002 reactions;
  - `flaggedForReview` holds exactly HEPDECETH/PENDECAETH (`pe15_hs[e]`) and DIDECAETH/TETDECAETH (`pe12_hs[e]`);
  - `fullRowRank` and `mAfter == 5812`;
  - the species removed after the dead-end pass are asserted as the union of the `zeroRow` and `orphaned` reasons (R13);
  - a second run with `irreducibleRemedy = 'removeMetabolites'` gives an identical report and `generalRemovalUsed == false` (SC-008, US5-AS2).
- [X] T044 [P] In `testGenerateFullRowRankFR.m`, add the **iDopaNeuroC** case (SC-003), guarded by `exist(file, 'file')` and printing a skip notice when the `papers` submodule is absent. Assert:
  - before: 1244/1243;
  - one group `{dcholcoa[x]; ppcoa[x]}` with representative `dcholcoa[x]` and `rxnsRewritten = {r0698; RE1836X}` (order as found);
  - `subSystems` of `r0698` preserved (the R6 regression that was observed);
  - full row rank, with m = 1243.
- [X] T045 [P] In `testGenerateFullRowRankFR.m`, add the **Recon3T** case (SC-002), guarded by existence of `~/drive/sbgCloud/projects/variationalKinetics/data/Recon3T/Recon3DModel_301_xomics_input_VK_withL.mat` (built with `fullfile(getenv('HOME'), ...)`, never a hard-coded absolute path), and skipping otherwise. Assert:
  - the 5 zero rows exactly;
  - the 6 groups, with the 5-member HC group;
  - 9 lumped removals (the post-dead-end species asserted as the union of `zeroRow` and `orphaned`, R13);
  - one witness with support 15 and the 14 `deadEnd` removals;
  - the same `flaggedForReview`;
  - `fullRowRank` and `mAfter == 5795`.
- [X] T046 Create `specs/20261015-173504-prepare-recon3d-fr/measurements/reproduceRecon3T.m`, the documented reproducibility check. It runs `generateFullRowRankFR` on the VK Recon3T with `printLevel = 1` under `diary` to `reproduceRecon3T.log`, prints every report list, and ends with `verifyModel(modelOut)`. Run it through MCP and commit the log.
- [X] T047 Run the full `testGenerateFullRowRankFR` through MCP with all three large-model files present. All cases must pass, and the runtime must be recorded (plan target: Recon3-scale cases well under 1 minute each).

---

## Phase 8: Polish & cross-cutting concerns

- [X] T048 [P] Confirm that `test/testAll.m` discovers `testGenerateFullRowRankFR.m` through its normal `verifiedTests` scan (no registration edit expected). If an explicit list exists, add it there.
- [X] T049 [P] Re-run the MATLAB code check (MCP `check_matlab_code`) on both new files and resolve every message, or justify it in the receipt. Also confirm that every `fprintf`/`disp` in `src/analysis/topology/FR/generateFullRowRankFR.m` is guarded by `printLevel` (SC-007), and that neither file contains `evalc` (plan, VII-A).
- [X] T050 [P] Confirm the header of `generateFullRowRankFR.m` renders under the documentation generator conventions (VII-E spacing, keyword blocks) and contains no agent or LLM instructions (Principle X).
- [X] T051 Re-check the Constitution Check in `specs/20261015-173504-prepare-recon3d-fr/plan.md` against the delivered code:
  - no edits outside the two new files and `specs/…`;
  - no reused toolbox function modified (`git diff --stat develop` lists only the new files and the specs dir).
- [X] T052 Run every quickstart.md scenario (1–4) and confirm the expected outputs.
- [X] T053 Report the files changed, checks run, tests passed and failed, and behaviours not verified. List the three follow-up defects (plan § Follow-ups: `addReaction` subsystem blanking, `checkDuplicateRxn('FR')` empty-column duplicates, `getRankLUSOL` hidden `inform`) as recommended separate Spec Kit items.
- [X] T054 Create the implementation receipt `specs/20261015-173504-prepare-recon3d-fr/agent-runs/<UTC-timestamp>-prepare-recon3d-fr/implementation-receipt.md` with the sections Prompt, Final response (the actual final user-facing response, verbatim), Diff summary, Tests and Unresolved issues.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: none. T003 depends on T002.
- **Foundational (Phase 2)**: depends on Phase 1. T004 → T005 → T006 → T007 → T008 → T009 → T010 (same file, in sequence). T011 [P] once T010 exists.
- **US1 (Phase 3)**: depends on Phase 2. Tests T012–T016 first; then T017 → T018 → T019 → T020 → T021 (same source file); then T022.
- **US2 (Phase 4)**: depends on Phase 2. Its *test* is independent of US1, but its expected `orphaned` removals are recorded by `recordEdit` (T007), so T027 needs T007.
- **US3 (Phase 5)**: depends on Phase 2 plus T024 (witnesses). The irreducible fixture needs no US1 or US2 remedy.
- **US5 (Phase 5b)**: depends on Phase 2, T007 (`recordEdit`), T024 (witnesses) and T025 (dead-end remedy, which the general-removal fixture reaches in pass 2).
- **US4 (Phase 6)**: depends on Phase 2 only. T041's cross-fixture assertions run over all fixtures, so they run after US1–US3 and US5.
- **Large-model (Phase 7)**: depends on US1 and US2.
- **Polish (Phase 8)**: depends on everything.

### Within each story

The tests are written and seen to fail before the implementation. All source tasks touch the one file `generateFullRowRankFR.m`, so they run in sequence.

### Parallel Opportunities

- Test-writing tasks marked [P] (T012–T016, T023, T028–T030, T033–T035, T040–T041, T043–T045) all edit `testGenerateFullRowRankFR.m`. They are "parallel" in having no logical dependency, but if several agents are used, they MUST be serialised at the file level, or each written as a separate local-function block and merged by one agent.
- T011, T048, T049 and T050 are truly parallel (read-only or different files).
- Per project memory, all MATLAB agents share **one** MATLAB MCP session, so concurrent MATLAB runs do not speed anything up. Run MCP verification tasks one at a time.

---

## Parallel Example: User Story 1

```text
# Write the US1 tests together (single author, one file):
T012 zeroRow case | T013 identicalPair case | T014 fiveGroup case | T015 removeRxns case | T016 preexistingDuplicate case
# Then implement sequentially in generateFullRowRankFR.m:
T017 → T018 → T019 → T020 → T021 → T022 (MCP run)
```

---

## Implementation Strategy

### MVP First (User Story 1)

1. Phase 1 (fixtures verified numerically), then Phase 2 (skeleton).
2. Phase 3 (US1): zero rows and lumping. **Stop and validate**: iDopaNeuroC is already fully repaired at this point.

### Incremental Delivery

1. US2 adds dead-end removal, which completes Recon3T.
2. US3 adds the honest-stop guarantees.
3. US5 adds the opt-in general removal that guarantees full row rank.
4. US4 adds the unchanged-model guarantee and the cross-cutting invariants.
5. Phase 7 adds the large-model acceptance, Phase 8 polish and the receipt.

---

## Notes

- Do not modify any reused toolbox function (FR-014). Defects found go to the follow-ups list.
- Do not suppress any warning; `addReaction`'s update warning is expected output.
- Integer and count assertions use exact equality; residuals use `tol`.
- Commit after each phase checkpoint, in present tense with a first line of 72 characters or fewer (constitution, Git conventions).
