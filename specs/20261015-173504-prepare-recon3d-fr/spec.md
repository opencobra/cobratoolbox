# Feature Specification: Full-row-rank [F,R] model preparation (`generateFullRowRankFR`)

**Feature Branch**: `20261015-173504-prepare-recon3d-fr`

**Created**: 2026-10-15

**Status**: Draft

**Input**: User description: "Create `generateFullRowRankFR.m`, a COBRA Toolbox function that takes a model and returns a modified model whose forward/reverse stoichiometric matrix [F,R] has full row rank, together with a report of every change it made." Full source description:
`/tmp/claude-1000/-home-rfleming-drive-sbgCloud-projects-variationalKinetics-repo/0da515b9-1d1e-4c9b-b3cb-94b4d3762578/scratchpad/generateFullRowRankFR-speckit-prompt.md`
(definitions, signature, building blocks, algorithm, report, acceptance evidence, tests, out of scope). Its content is reproduced below as requirements, so this spec does not depend on that temporary file.

## Background and definitions

These objects follow Constitution Principle I (domain and dimension stated):

- `S ∈ ℝ^{m×n}`: the model's stoichiometric matrix. `m` is the number of metabolites (rows) and `n` the number of reactions (columns).
- `rxnBool ∈ {0,1}^n`: selects the **internal** reaction columns. The default is resolved in this order:
  1. `param.rxnBool` if the caller supplies it;
  2. otherwise `model.SConsistentRxnBool` if that field is present;
  3. otherwise `model.SIntRxnBool` as returned by `findSExRxnInd`.
- `N = S(:, rxnBool) ∈ ℝ^{m×k}`: the internal stoichiometric matrix.
- `F = max(-N, 0)` and `R = max(N, 0)`: the forward (substrate) and reverse (product) half-stoichiometric matrices, both in `ℝ^{m×k}_{≥0}`. They satisfy `N = R − F`.
- **Target condition:** `rank([F, R]) = m`, where `m` is the number of rows of the **returned** model's `S`.

Full row rank of `[F, R]` is the standing assumption of a convergence theorem for variational kinetics. Exchange, sink and demand columns are not part of `N`. Adding or editing them therefore cannot repair a deficiency. Only changes to internal reactions or metabolites can.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Repair the common deficiencies automatically (Priority: P1)

A modeller preparing a genome-scale model (for example Recon3T) for variational-kinetics analysis calls the function once. They get back a model whose `[F, R]` has full row rank. Zero rows and groups of identical rows are removed or lumped automatically, and every edit is listed in the report.

**Why this priority**: this is the core value of the feature. Zero rows and identical rows cause 14 of Recon3T's 15 rank deficiencies and the only one in iDopaNeuroC.

**Independent Test**: on hand-built fixtures with a zero row, an identical pair, and a five-member identical group, the returned model has full row rank. The report lists exactly the removed metabolites, the lumped groups with their representatives, and the conserved difference vectors.

**Acceptance Scenarios**:

1. **Given** a model in which one metabolite has a zero row in `[F, R]` (it occurs only in exchange reactions), **When** the function is called with default parameters, **Then** that metabolite is removed, `report.removedMets` names it, and `report.fullRowRank` is true.
2. **Given** a model with two metabolites whose `[F, R]` rows are identical, **When** the function is called with `remedy = 'lump'` (the default), **Then** the pair is replaced by one representative and every affected reaction is rewritten to use it. `report.lumpedGroups` records the group, the representative and the conserved difference vector, and the result has full row rank.
3. **Given** a five-member identical-row group (like `HC00004/6/7/8/9[e]`), **When** the function is called, **Then** all five collapse to one representative in a single recorded group.
4. **Given** an identical-row group, **When** the function is called with `remedy = 'removeRxns'`, **Then** the reactions containing the group are removed instead of lumped, and the report records the removal.
5. **Given** a model with an identical-row group, one of whose reactions already duplicates another reaction (under the `[F, R]` criterion) before lumping, **When** the function runs, **Then** the duplicate check after lumping runs, but it removes only duplicates *created* by lumping. The pre-existing duplicate is left in place, and the report shows no `duplicateAfterLump` removal. (Plan research R5a shows that representative-preserving lumping cannot create a duplicate, so the check is a safety net.)

---

### User Story 2 - Resolve sum dependencies through dead-end reactions (Priority: P2)

Some deficiencies are sum dependencies rather than identical rows. In Recon3T, the row of `pa_hs[e]` equals the sum of the rows of 14 N-acyl-ethanolamides. Each of these is a dead end, produced only together with `pa_hs[e]` by a single phospholipase-D reaction. The function finds such a dependency through a left-null-space witness, removes the dead-end reactions, and then re-runs the zero-row and identical-row steps.

**Why this priority**: it accounts for the last Recon3T deficiency. It also needs a null-space witness and an iteration loop, so it builds on User Story 1.

**Independent Test**: a fixture with a sum dependency over dead-end partners. The dead-end reactions are removed. The species they leave behind are removed too: in the same pass as `orphaned` when they occur nowhere else (`removeRxns` drops them), or on the next pass as `zeroRow` when they still have external reactions (as on Recon3T). The result has full row rank.

**Acceptance Scenarios**:

1. **Given** a fixture in which one row equals the sum of several rows whose species each occur in exactly one internal reaction, **When** the function is called, **Then** a left-null vector `y` is reported with its support, coefficients and residual `‖[F,R]ᵀ y‖`. The residual is 0 or below `tol`.
2. **Given** the same case, **Then** the dead-end reactions are removed and recorded as the remedy applied to that null vector. The orphaned species are removed and reported (`orphaned` in the same pass, or `zeroRow` on the next one; plan research R13), and the final model has full row rank.

---

### User Story 3 - Stop honestly on an irreducible dependency (Priority: P2)

When a dependency cannot be repaired by lumping or dead-end removal, the function makes no guessed edit. It returns the best model found so far with `report.fullRowRank = false`, a stop reason, and the witness null vector, so the modeller can decide what to do.

**Why this priority**: scientific correctness (Principle I). An edit that silently changes a model's biology is worse than a reported deficiency.

**Independent Test**: a fixture with a dependency where no species is a dead end and no rows are identical. The function returns `fullRowRank = false`, a non-empty witness and a stop reason, and makes no edit beyond earlier lawful steps.

**Acceptance Scenarios**:

1. **Given** an irreducible dependency, **When** the function is called, **Then** `report.fullRowRank` is false, `report.stopReason` states that no admissible remedy exists, and the report includes the witness `y` with its support and residual.
2. **Given** `maxIterations` is reached before full rank, **Then** the function returns the best model so far, `report.fullRowRank` is false, and `report.stopReason` names the iteration limit.

---

### User Story 4 - Leave an already-valid model untouched (Priority: P3)

If `[F, R]` already has full row rank, the function returns the model unchanged and a fully initialised report that records no edits.

**Why this priority**: it is cheap to guarantee and protects callers who run the function defensively.

**Independent Test**: a full-rank fixture. The returned model equals the input, and every change list in the report is empty.

**Acceptance Scenarios**:

1. **Given** a model whose `[F, R]` already has full row rank, **When** the function is called, **Then** `modelOut` is identical to `model`. `removedMets`, `removedRxns`, `lumpedGroups` and the null-vector list are all empty, `fullRowRank` is true, and the rank before equals the rank after, which equals `m`.

---

### User Story 5 - Force full row rank by general removal (Priority: P2)

A modeller who needs a full-row-rank `[F, R]` whatever it costs, for example to run a variational-kinetics solver at all, turns on a general-purpose option. The specific remedies (zero rows, lumping, dead ends) still run first. When a dependency is left that none of them can repair, the function no longer stops. It removes a problematic species together with every reaction it takes part in, using the toolbox's `removeMetabolites`, and continues until `[F, R]` has full row rank. Every removal is reported as general, so it can be told apart from the targeted remedies.

**Why this priority**: it turns the honest stop of User Story 3 into a guaranteed result when the user explicitly accepts losing species and reactions. It is opt-in, so the default behaviour and its evidence trail (User Stories 1–3) are unchanged.

**Independent Test**: on the irreducible fixture with the option on, the function returns `fullRowRank = true`. Every removed species and reaction appears in the report with reason `generalRemoval`, or with a later consequential reason (`zeroRow`, `deadEnd`, `emptyColumn`), and every surviving reaction keeps its stoichiometry exactly.

**Acceptance Scenarios**:

1. **Given** an irreducible dependency and `param.irreducibleRemedy = 'removeMetabolites'`, **When** the function is called, **Then**:
   - for each witness, one support species is chosen deterministically (FR-019);
   - the chosen species are removed together with every reaction they take part in, via `removeMetabolites(model, mets, true, 'inclusive')`;
   - the witness entry records remedy `generalRemoval`, the chosen species and the reactions removed;
   - the loop continues, and the final model has full row rank.
2. **Given** the same option on a model whose deficiencies are all repaired by the specific remedies (for example Recon3T), **When** the function is called, **Then** the result and report are identical to a run with the option off. General removal never fires while a specific remedy applies.
3. **Given** the option off (the default), **When** an irreducible dependency remains, **Then** behaviour is exactly User Story 3.

---

### Edge Cases

- **LUSOL storage failure**: on Recon3D-scale `[F, R]`, `getRankLUSOL` can fail with `inform = 7` (insufficient storage). The function must then fall back to another exact rank method (MATLAB `rank` or a sparse QR) and record in the report which method decided the rank.
- **Default column selection**: if neither `param.rxnBool` nor `model.SConsistentRxnBool` is present, `findSExRxnInd` supplies `SIntRxnBool`. If the model has no internal reactions at all, the function stops with a clear stop reason and does not error obscurely.
- **Representative choice**: when an identical-row group is lumped, the representative must be chosen deterministically, so repeated runs give the same report.
- **Coefficients in identical rows**: rows count as identical only if they match exactly, coefficients included. Rows that are only proportional are a different dependency and fall to step 3. (Plan research R4: exact equality, because stored coefficients of genuinely co-occurring species are bit-identical.)
- **Columns emptied by metabolite removal**: removing a zero-row or lumped-away metabolite can leave an external (exchange, sink or demand) column with no entries, for example `EX_idl_hs[e]`. Such an empty column is removed as a consequence, not as a remedy, and reported with reason `emptyColumn`. This is the only way the function touches external reactions, and it changes no constraint, because an empty column carries no stoichiometry. (Plan research R5.)
- **Field preservation under rewrite**: a reaction rewritten during lumping keeps its position, bounds, objective coefficient, name, GPR and subsystem. Only the lumped-away metabolites leave its column. (Plan research R6.)
- **Cascades**: removing a reaction can create new zero rows or new identical rows. `F` and `R` must be recomputed after every change, and the loop must continue until full rank or `maxIterations`.
- **Gene bookkeeping**: after any reaction removal, genes no longer referenced by any reaction are removed, so `modelOut` stays structurally valid.
- **General removal touches external reactions**: `removeMetabolites(..., true, 'inclusive')` removes **every** reaction containing the chosen species, including external ones such as its exchange, or a biomass or other multi-species external reaction. These are reported individually with reason `generalRemoval`. This is the one route by which an external reaction with stoichiometry can be removed, and only when the user has opted in. The selection rule (FR-019) prefers species whose removal deletes fewer reactions.
- **Termination of general removal**: every editing pass removes at least one metabolite or reaction, so the loop ends after at most `m + n` passes. With the option on, the default `maxIterations` is that bound, so full row rank is guaranteed unless the user sets a smaller limit. An empty `[F, R]` (m = 0) counts as full row rank.
- **Flagged ambiguous substrates**: HEPDECETH and PENDECAETH share the substrate `pe15_hs`, and DIDECAETH and TETDECAETH share `pe12_hs`. These may be mis-assigned substrates. The function must not alter them beyond the dead-end remedy, and the Recon3T evidence must flag them for human review.

## Requirements *(mandatory)*

### Functional Requirements

**Interface**

- **FR-001**: The toolbox MUST provide a function `[modelOut, report] = generateFullRowRankFR(model, param)`. It MUST accept any COBRA model. (The original description named it `prepareRecon3DFR`; it was renamed to `generateFullRowRankFR` at the user's request on 2026-10-15, because it is not specific to Recon3D.)
- **FR-002**: `param` MUST be optional. Its optional fields and defaults are:
  - `rxnBool`: resolved as in *Background*;
  - `printLevel`: default 0, silent;
  - `maxIterations`: a finite default chosen in the plan;
  - `remedy`: `'lump'` (default) or `'removeRxns'`;
  - `tol`: a justified numerical tolerance chosen in the plan;
  - `irreducibleRemedy`: `'stop'` (default; User Story 3) or `'removeMetabolites'` (User Story 5).

  Optional arguments are handled by existence/emptiness checks (Principle VII-D).
- **FR-003**: The function MUST carry the full openCOBRA help header (Principle VII-E) and keep console output gated behind `printLevel`.

**Algorithm**

- **FR-004**: The function MUST iterate until `rank([F, R]) = m` or `maxIterations` is reached, recomputing `F` and `R` from the current model after every change.
- **FR-005 (zero rows)**: Each iteration MUST first remove every metabolite whose `[F, R]` row is zero. This includes species that occur only in exchange or other external reactions. The removal MUST use the toolbox's existing metabolite-removal functions. A removed metabolite's entries in external columns go with it: single-metabolite external columns become empty and are removed (`emptyColumn`), while multi-metabolite external columns survive without that entry. Lumped-away metabolites (FR-006) behave the same way. (Reconciled at Gate 3, 2026-10-15; see contract item 5.)
- **FR-006 (identical rows)**: The function MUST group metabolites whose `[F, R]` rows are identical.
  - Under `remedy = 'lump'`, each group MUST be replaced by one deterministically chosen representative. Every affected reaction is rewritten with the toolbox's reaction-editing function, and the other members are then removed.
  - Under `remedy = 'removeRxns'`, the reactions containing the group MUST be removed instead.
  - For every group, the report MUST record the members, the representative (lump only), and the conserved difference vector(s).
- **FR-007 (duplicates after lumping)**: After lumping, reactions that have *become* duplicates under the `[F, R]` criterion MUST be detected with the existing duplicate-reaction checker in `'FR'` mode, removed, and reported. Duplicates that already existed before lumping MUST NOT be removed.
- **FR-008 (remaining dependencies)**: If rank is still deficient, the function MUST compute a sparse basis of the left null space of `[F, R]`. For each basis vector `y`, it MUST report:
  - the support (species and coefficients);
  - the residual `‖[F, R]ᵀ y‖`, confirmed to be 0 or below `tol`.
- **FR-009 (dead-end remedy)**: If the support of a null vector contains species that each occur in exactly one internal reaction (dead ends), the function MUST remove those reactions, record this as the remedy for that vector, and return to the zero-row step (FR-005).
- **FR-010 (no guessing)**: When `irreducibleRemedy = 'stop'` (the default), if neither lumping nor dead-end removal applies to a remaining dependency, the function MUST stop without editing the model further. (With `'removeMetabolites'`, FR-018 applies instead.) It MUST return the best model so far with `report.fullRowRank = false`, a stop reason, and the witness vector(s).
- **FR-018 (general removal, opt-in)**: When `param.irreducibleRemedy = 'removeMetabolites'` and a pass reaches the state of FR-010 (witnesses exist and none has a dead end in its support), the function MUST NOT stop. Instead it MUST remove the chosen species of every witness of that pass in one call, `removeMetabolites(model, chosenMets, true, 'inclusive')`, which removes the species together with every reaction they take part in. It then returns to the zero-row step (FR-005). General removal MUST NOT run in a pass where a specific remedy (FR-005, FR-006, FR-009) applies.
- **FR-019 (deterministic choice)**: For each witness, the chosen species is the support species whose removal deletes the fewest reactions: the number of columns of `S`, internal plus external, where its row is nonzero. Ties go to the fewest internal reactions, then to the earliest position in `model.mets`. When two witnesses would choose the same species, it is chosen once.
- **FR-020 (general-removal reporting)**: Each chosen species MUST be reported in `removedMets` with reason `generalRemoval`. Each reaction returned by `removeMetabolites` as removed MUST be reported in `removedRxns` with reason `generalRemoval`, flagged internal or external. The witness entry MUST record remedy `generalRemoval`, its chosen species and the reactions removed. `report.generalRemovalUsed` MUST be true whenever it fired.
- **FR-021 (guarantee)**: With the option on and `maxIterations` at its default, the function MUST return `fullRowRank = true` for every input that has at least one internal column.
- **FR-011 (gene cleanup)**: After any reaction removal, the function MUST remove genes that are no longer used, with the existing unused-gene remover.

**Rank computation**

- **FR-012**: Rank MUST be computed with `getRankLUSOL` by default. If LUSOL reports failure (for example `inform = 7`, insufficient storage), the function MUST fall back to an exact alternative (MATLAB `rank` or a sparse QR) and record in the report which method decided each reported rank.

**Report** (fully initialised on every return path, including early stops and the unchanged case)

- **FR-013**: `report` MUST contain:
  - `m` and `n` before and after;
  - rank before and after, and the rank method(s) used;
  - `fullRowRank`;
  - `removedMets`;
  - `removedRxns`, each with the reason for removal;
  - `lumpedGroups`, with representatives and conserved difference vectors;
  - one entry per left null vector found, with its support, coefficients, residual and the remedy applied (or "none");
  - the number of iterations;
  - `stopReason`, empty on success;
  - `generalRemovalUsed` (FR-020).

  The complete, authoritative field list, with types and reason codes, is `data-model.md` (it adds `removedCtrs`, `rxnBoolSource`, `rankLog` and `flaggedForReview`); this list is its summary (analysis U2).

**Reuse and placement**

- **FR-014**: The function MUST be built from existing toolbox functions and MUST NOT reimplement them or change them:
  - metabolite removal and trivial-stoichiometry cleanup (`removeMetabolites`, `removeTrivialStoichiometry`);
  - reaction removal and lookup (`removeRxns`, `findRxnsFromMets`, `findMetsFromRxns`);
  - reaction rewriting (`addReaction` with `'metaboliteList'` and `'stoichCoeffList'`);
  - duplicate detection (`checkDuplicateRxn(model, 'FR', ...)`);
  - `removeUnusedGenes`;
  - `findSExRxnInd`;
  - `getRankLUSOL`;
  - optionally `verifyModel` as a final structural check.
- **FR-015**: The new source file MUST be placed by role under `src/<domain>/` (Principle IX), next to the existing `[F, R]` rank tooling in `src/analysis/topology/FR/` (for example `checkRankFR.m`) unless the plan justifies a different location. No existing public function's interface may change (Principle II).

**Tests**

- **FR-016**: A test file `test/verifiedTests/<category>/testGenerateFullRowRankFR.m` (Principle III-Naming) MUST cover seven hand-built fixture cases, one per case:
  1. a zero row;
  2. an identical pair;
  3. a five-member identical group;
  4. a sum dependency with dead-end partners;
  5. an irreducible dependency (expects `fullRowRank = false`, a witness, and no guessed edit);
  6. an already-full-rank model (expects an unchanged model and an empty report);
  7. the irreducible fixture with `irreducibleRemedy = 'removeMetabolites'` (expects full row rank and only `generalRemoval` or consequential removals, User Story 5).

  Each case MUST assert the final rank and the exact report contents. The test MUST declare its requirements with `prepareTest` and run within `testAll`.
- **FR-017**: A larger test on Recon3T (and iDopaNeuroC) MUST check the acceptance counts in SC-002 and SC-003 when those models are available to the suite. It MUST skip gracefully, not fail, when they are not.

### Key Entities

- **Prepared model** (`modelOut`): a COBRA model whose internal `[F, R]` has full row rank, or the best model reached before a reported stop. Every edit to it is traceable in the report.
- **Report**: a structure listing every change and every diagnostic witness (FR-013).
- **Lumped group**: a set of metabolites with identical `[F, R]` rows, its chosen representative, the reactions rewritten, and the conserved difference vector(s) (for example `e_i − e_rep`).
- **Null-vector witness**: a vector `y ∈ ℝ^m` with `[F, R]ᵀ y ≈ 0`, reported with its support, coefficients, residual and the remedy applied.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All seven fixture cases (FR-016) pass, asserting exact final rank and exact report contents, and run within `testAll` in CI.
- **SC-002 (Recon3T)**: starting from m = 5824 and internal `[F, R]` rank 5809, the report accounts for all 15 deficiencies:
  - 5 zero rows: `idl_hs[e]`, `M02560[e]`, `M02561[e]`, `M02909[e]`, `protein[c]`;
  - 9 deficiencies from 6 identical-row groups:
    - `HC00004/6/7/8/9[e]` (`HDL_HSSYN`, `HDL_HSDEG`);
    - `malcoa[e]` and `arachcoa[e]` (`RE0569E`);
    - `CE5787[e]` and `CE5791[e]` (`RE2304E`);
    - `CE5868[e]` and `CE5869[e]` (`RE2445E`);
    - `cdpea[e]` and `12dgr120[e]` (`RE3267E`);
    - `M01820[e]` and `M00510[e]` (`HMR_0008`);
  - 1 sum dependency: `pa_hs[e]` against 14 N-acyl-ethanolamides, resolved by removing ARACHETH, DIDECAETH, DIHOLINETH, DOCOHEXETHc, DOCTETETH, HEPDECETH, HEXDECEETH, OLEETH, PELINETH, PENDECAETH, PEPALM, STEETH, TETDECAETH and TRIDECETH.

  The output has `fullRowRank = true`.
- **SC-003 (iDopaNeuroC)**: starting from m = 1244 and rank 1243 (measured with the default `SConsistentRxnBool` selection; the original description quoted 1240/1239, see plan research R2), `dcholcoa[x]` and `ppcoa[x]` (occurring only in RE1836X and r0698) are reported as one lumped group, and the output has full row rank.
- **SC-002b (in-repo Recon3D, runs in CI)**: on `test/models/mat/Recon3DModel_301_xomics_input.mat` (m = 5835, rank 5826), the report accounts for all 9 deficiencies: 0 zero rows; 8 from the same six identical-row groups, with `HC00004/6/7/8[e]` here a four-member group; and the same `pa_hs[e]` sum dependency, resolved by removing the same 14 reactions. The output has full row rank (m = 5812).
- **SC-004**: every reported null-vector witness has residual `‖[F, R]ᵀ y‖` equal to 0 or below `tol`.
- **SC-005**: on every return path (success, irreducible stop, iteration limit, unchanged model), every report field listed in FR-013 is present and initialised.
- **SC-006**: on the full-rank fixture, `modelOut` is identical to the input model.
- **SC-008 (general removal)**:
  - With `irreducibleRemedy = 'removeMetabolites'`, the irreducible fixture ends with `fullRowRank = true`.
  - The in-repo Recon3D gives a report identical to the default run, with `generalRemovalUsed = false` (US5-AS2).
  - In every test case, every surviving reaction's `S` column equals its input column, except reactions rewritten by lumping.
- **SC-007**: with `printLevel = 0` the function itself prints nothing. Warnings raised by the toolbox functions it calls (for example `addReaction`'s "Reaction with the same name already exists in the model, updating the reaction", once per rewritten reaction) still reach the console unsuppressed (Principle VII-B).

## Assumptions

- `m` in the target condition is the row count of the returned model's `S`. Removed metabolites reduce `m`, and the condition is checked on the model after edits.
- The default `remedy = 'lump'` keeps one representative and preserves reactions. `'removeRxns'` is the only alternative; choices between other biologically different remedies are out of scope.
- The representative of a lumped group is chosen deterministically (for example the first member in model order). The exact rule is fixed in the plan and recorded in the report.
- The Recon3T model used for SC-002 lives outside the repository (`~/drive/sbgCloud/projects/variationalKinetics/data/Recon3T/…`, as in earlier features). iDopaNeuroC lives in the `papers` git submodule (`papers/2023_iDopaNeuro/models/iDopaNeuroC.mat`). The large test therefore skips when either model is absent, and the Recon3T counts are also confirmed by a documented reproducibility check recorded in the feature directory.
- Rank is computed in exact or near-exact arithmetic on a sparse, nonnegative integer-valued `[F, R]`, so the default `tol` can be tight. The plan fixes it with a justification.
- No solver (LP/QP) is required. LUSOL is a factorisation library, not an optimisation solver, and its configuration surface is audited in the plan (Principle IV).

## Out of Scope

- Changing exchange, sink or demand reactions, with three documented exceptions:
  - removing a column that has become empty (always, reason `emptyColumn`);
  - dropping the entry of a zero-row or lumped-away metabolite from an external column that survives (FR-005);
  - only with the opt-in general removal, removing an external reaction that contains a chosen species (reason `generalRemoval`).
- Flux consistency, and thermodynamic or kinetic parameters.
- Any modification of the toolbox functions this feature uses.
- Choosing among biologically different remedies beyond the two `remedy` options and the opt-in general removal (FR-018), whose choice rule is purely structural (FR-019), not biological. In particular, HEPDECETH/PENDECAETH (shared substrate `pe15_hs`) and DIDECAETH/TETDECAETH (shared substrate `pe12_hs`) are flagged for review as possibly mis-assigned substrates and are not otherwise altered.

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1-AS1 / FR-005 | testGenerateFullRowRankFR — zero-row fixture | src/analysis/topology/FR/generateFullRowRankFR (placement per FR-015) |
| US1-AS2 / FR-006 | testGenerateFullRowRankFR — identical-pair fixture | generateFullRowRankFR |
| US1-AS3 / FR-006 | testGenerateFullRowRankFR — five-member-group fixture | generateFullRowRankFR |
| US1-AS4 / FR-006 (`removeRxns`) | testGenerateFullRowRankFR — identical-pair fixture, `remedy='removeRxns'` | generateFullRowRankFR |
| US1-AS5 / FR-007 | testGenerateFullRowRankFR — pre-existing-duplicate fixture (safety net; no removal) | generateFullRowRankFR |
| US2-AS1, US2-AS2 / FR-008, FR-009, SC-004 | testGenerateFullRowRankFR — sum-dependency dead-end fixture | generateFullRowRankFR |
| US3-AS1 / FR-010 | testGenerateFullRowRankFR — irreducible-dependency fixture | generateFullRowRankFR |
| US3-AS2 / FR-004 (`maxIterations`) | testGenerateFullRowRankFR — iteration-limit case | generateFullRowRankFR |
| US4-AS1 / SC-006 | testGenerateFullRowRankFR — full-rank fixture | generateFullRowRankFR |
| FR-012 (rank fallback) | testGenerateFullRowRankFR — rank-method field asserted | generateFullRowRankFR |
| SC-005 / FR-013 | testGenerateFullRowRankFR — report-field assertions on every path | generateFullRowRankFR |
| SC-002 | testGenerateFullRowRankFR — Recon3T case (skips if absent) + reproducibility check in feature dir | generateFullRowRankFR |
| SC-002b | testGenerateFullRowRankFR — in-repo Recon3D case | generateFullRowRankFR |
| SC-003 | testGenerateFullRowRankFR — iDopaNeuroC case (skips if submodule absent) | generateFullRowRankFR |
| SC-007 | testGenerateFullRowRankFR — silent at printLevel 0 | generateFullRowRankFR |
| US5-AS1 / FR-018, FR-019, FR-020, FR-021, SC-008 | testGenerateFullRowRankFR — irreducible fixture with `irreducibleRemedy='removeMetabolites'` | generateFullRowRankFR |
| US5-AS2 / SC-008 | testGenerateFullRowRankFR — in-repo Recon3D with option on equals option off | generateFullRowRankFR |
| US5-AS3 | testGenerateFullRowRankFR — irreducible case (option off, US3) | generateFullRowRankFR |
