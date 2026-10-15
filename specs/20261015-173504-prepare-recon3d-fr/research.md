# Phase 0 Research: generateFullRowRankFR

All measurements below were taken on 2026-10-15 with MATLAB on this machine (MATLAB MCP session, COBRA Toolbox at `develop` 6d8cfea3f). Every probe script and its log are in `measurements/`:

- `probeFRrank.m` / `probeFRrank.log`
- `probeDependencies.m` / `probeDependencies.log`
- `probeAlgorithm.m` / `probeAlgorithm.log`

`probeAlgorithm.m` is a throwaway prototype of the algorithm, used only to expose the behaviour of the building blocks. It is not the deliverable.

## R1. Which Recon3T reproduces the spec's figures

**Decision**: the Recon3T acceptance evidence (SC-002) is measured on
`~/drive/sbgCloud/projects/variationalKinetics/data/Recon3T/Recon3DModel_301_xomics_input_VK_withL.mat` (variable `model`), with the default column selection `SConsistentRxnBool` (k = 8748).

**Rationale**: this file reproduces every figure in the description exactly:
- m = 5824, and rank of the internal `[F, R]` = 5809;
- 5 zero rows, exactly `idl_hs[e] M02560[e] M02561[e] M02909[e] protein[c]`;
- the six identical-row groups, including the five-member `HC00004/6/7/8/9[e]` group;
- the 14-term `pa_hs[e]` sum dependency.

The plain `Recon3DModel_301_xomics_input.mat` (the variationalKinetics copy, and the in-repo copy under `test/models/mat/`, which are identical) is a different model: m = 5835, rank 5826, 9 deficiencies.

**Consequence**: Recon3T is outside the repository, so SC-002 is discharged by a documented reproducibility script (`measurements/reproduceRecon3T.m`, written in implementation). The automated test runs the Recon3T case only when that file exists, and skips it otherwise (FR-017).

**Alternatives considered**: copying the 4.6 MB VK file into `test/models/` was rejected. It is a project-specific derivative, and Principle IX keeps such data out of the toolbox's test models.

## R2. iDopaNeuroC figures

**Decision**: SC-003 uses the measured values m = 1244 and rank 1243 (`papers/2023_iDopaNeuro/models/iDopaNeuroC.mat`, variable `iDopaNeuroC`, `SConsistentRxnBool`). The spec has been amended accordingly.

**Rationale**: the dependency is exactly as described: one identical pair, `dcholcoa[x]` and `ppcoa[x]`, occurring only in `r0698` and `RE1836X`. The description's 1240/1239 most likely came from a differently trimmed variant. The structural claim is unaffected; only the absolute counts differ. `iDopaNeuroCT.mat` already has full row rank (1312/1312).

## R3. The in-repo Recon3D as a CI-runnable large test

**Decision**: add SC-002b, which runs on `test/models/mat/Recon3DModel_301_xomics_input.mat` (loaded with `getDistributedModel`) in every CI run.

**Measured result**: m = 5835 and rank 5826, i.e. 9 deficiencies:
- no zero rows;
- the same six identical-row groups, with HC as a four-member group `HC00004/6/7/8[e]`, giving 3 + 5 = 8;
- the same `pa_hs[e]` sum dependency.

The prototype loop reaches full rank at m = 5812 and n = 10586 (14 reactions removed).

**Rationale**: this gives the test suite large-model coverage of all three remedy types without depending on files outside the repository.

## R4. Identical-row detection: exact equality

**Decision**: group rows with `unique(FR, 'rows', 'stable')`, i.e. exact equality, using the full row including coefficients. `tol` is not used for grouping.

**Rationale**: species that genuinely always occur together are stored with bit-identical coefficients. All six Recon3 groups and the iDopaNeuro pair are found by exact equality. A tolerance would risk merging species whose coefficients really do differ. Near-identical rows are left to step 3, where any resulting dependency gets a witness and is either remedied or reported.

## R5. Columns emptied by metabolite removal; duplicate checking restricted to internal reactions

**Findings**:
- `removeMetabolites(model, mets, false)` leaves the columns of their exchange reactions in place, now empty. On VK Recon3T, n stayed 10554 after removing the 5 zero-row metabolites.
- `checkDuplicateRxn(model, 'FR', ...)` compares **all** columns of `S`. After lumping, it therefore flagged empty external columns as duplicates of each other (`DM_PROTEIN`, `EX_M00510[e]`, and the warning "EX_arachcoa[e] has more than one replicate"). It found no internal duplicates on any of the three models.

**Decision**:
1. After every metabolite removal, call `removeTrivialStoichiometry` to drop the now-empty columns. Report each one in `report.removedRxns` with reason `emptyColumn`.
2. Call `checkDuplicateRxn(model, 'FR', 0, 0)` (detect only, no removal) before and after the lump rewrite. Keep only flagged reactions that are internal under the current `rxnBool` and are newly flagged after lumping (R5a). Remove them with `removeRxns`, and report them with reason `duplicateAfterLump`.
3. Repeat step 2 until no internal duplicate remains. This is needed because `checkDuplicateRxn` flags only one member of a group of more than two.

**R5a. Lumping cannot create a duplicate.** Proof sketch: if the members of group G have identical `[F, R]` rows, then every internal column contains either all members, each with the same coefficient, or none of them. The rewrite removes the non-representative members and keeps the representative with that same coefficient. Two columns j and l are therefore proportional (up to orientation) after the rewrite if and only if they were before. So the post-lump duplicate check can only ever re-find pre-existing duplicates, and FR-007 only removes *new* ones. The implementation therefore compares the internal duplicate sets before and after lumping, and removes only the difference, which is provably empty. The check is kept as a safety net, as the spec requires. The prototype agrees: no internal duplicates were flagged on any of the three models.

**Rationale**: an empty column carries no stoichiometry, so removing it changes no constraint and no rank; it is reported for transparency. Restricting duplicate removal to internal reactions honours the spec's exclusion of changes to exchange reactions. Calling with `removeFlag = 0` lets the function record exactly what it removes while still reusing the existing checker (FR-007, FR-014).

**Alternatives considered**: leaving empty columns in place was rejected. They pollute the duplicate check and produce a model that `verifyModel` may criticise.

## R6. `addReaction` side effects when rewriting an existing reaction

**Findings** (iDopaNeuroC `r0698`):
- `addReaction` emits `Warning: Reaction with the same name already exists in the model, updating the reaction` on every rewrite.
- It keeps the column position (786 → 786), bounds (when passed), `rules`, and `SConsistentRxnBool`.
- It normalises whitespace in `grRules`: `(10449 and 3032) or (3032 and 30)` becomes `( 10449 and 3032 ) or ( 3032 and 30 )`. This is semantically identical.
- It **blanks the subsystem** when the model stores `subSystems` entries as char (legacy layout): `'Bile acid synthesis'` becomes `{0×0 char}`. Passing `'subSystem'` explicitly preserves the text, but converts the entry to a cell.

**Decision**: each rewrite passes, explicitly:
- `'metaboliteList'` and `'stoichCoeffList'`: the original column minus the lumped-away members;
- `'lowerBound'` and `'upperBound'`;
- `'objectiveCoef'`;
- `'reactionName'` (when `rxnNames` exists);
- `'geneRule'` (when `grRules` exists);
- `'subSystem'`.

Afterwards, the function restores the original `subSystems` entry byte-for-byte, so the stored format is unchanged.

The `addReaction` warning is **not** suppressed (Principle VII-B). The spec's SC-007 is amended to say so.

The fixture tests assert that every reaction-indexed field of a rewritten reaction is unchanged, except `S`, plus `grRules` up to whitespace.

**Rationale**: FR-014 forbids changing `addReaction`. Restoring one field afterwards is bookkeeping, not a reimplementation, and it prevents silent loss of subsystem annotation, which is a Principle I defect.

**Follow-up (outside this feature)**: the subsystem blanking is a latent `addReaction` defect for legacy-layout models. It should be reported as a separate Spec Kit item, not fixed here.

## R7. Rank computation and the LUSOL fallback

**Findings**:
- `getRankLUSOL` returns `[rankA, p, q]` and does **not** expose the LUSOL `inform` code. On `inform = 7` it prints a message and still returns `mylu.rank()`, which may then be unreliable. It catches only thrown errors (falling back to `rank(full(A))`).
- Timings on VK Recon3T `[F, R]` (5824 × 17496): `getRankLUSOL` takes 0.27 s; sparse QR of `[F, R]ᵀ` (`qr(A, sparse(size(A,1),0), 0)`, column-pivoted, Q not formed) takes 0.02 s. Both give 5809. No `inform = 7` occurred on any of the three models.
- MATLAB `rank(full([F, R]))` on 5824 × 17496 means an SVD of a dense 815 MB matrix. That is unsuitable as a routine fallback at this scale.

**Decision**: rank is decided by a local helper that:
1. calls `getRankLUSOL(FR, 0)`;
2. always computes the sparse-QR rank as a cross-check (it is cheaper than LUSOL here);
3. if the two agree, records `rankMethod = 'getRankLUSOL'` (cross-checked);
4. if they disagree, which is the signature of an unreliable LUSOL factorisation such as `inform = 7`, uses the sparse-QR rank, records `rankMethod = 'sparseQR'` together with both values, and issues a visible `warning`.

The QR rank threshold is `max(size(FR)) * eps * max(abs(diag(Rq)))`.

Every deficiency the loop acts on is in any case certified by a witness (zero row, identical rows, or a null vector with residual ≤ `tol`). So a wrong rank can at worst stop the loop early; it cannot cause an uncertified edit.

**Alternatives considered**:
- Calling `lusol_obj` directly to read `inform` was rejected: it would duplicate `getRankLUSOL`'s internals (FR-014).
- Changing `getRankLUSOL` to return `inform` was rejected as out of scope.
- Capturing its console text with `evalc` was rejected (Principle VII-A).

**Configuration-surface audit (Principle IV)**: LUSOL (`lusol_obj`) is called through `getRankLUSOL` with its defaults:

| Setting | Default |
|---|---|
| `pivot` | `'TPP'` |
| `Ltol1` | 10 |
| `Utol1`, `Utol2` | eps^0.67 |
| `small` | eps^0.8 |
| `nzinit` | 0 (automatic) |

`[F, R]` is sparse and nonnegative, its entries are O(1) stoichiometric coefficients, and it has about 2 nonzeros per row-reaction incidence. Under threshold partial pivoting, rank revealing on such well-scaled data is reliable, and the measured LUSOL and QR ranks agree on all three models, so no default is overridden. The only known mismatch is storage (`inform = 7`) on larger matrices, which is handled by the cross-check rather than by overriding `nzinit`, since `getRankLUSOL` does not accept options. MATLAB's sparse `qr` (SuiteSparseQR) runs with its default ordering, which suits a matrix of this shape (measured at 0.02 s).

## R8. Left-null basis and the dead-end rule

**Decision**: step 3 runs only when there are no zero rows and no identical rows. The basis is formed as follows:
1. Factor `[F, R]ᵀ` with column-pivoted sparse QR, `[~, Rq, E] = qr(FRᵀ, sparse(size(FRᵀ,1), 0), 0)`, and let r be the QR rank.
2. For each dependent column t = 1, …, m − r, solve `c = Rq(1:r,1:r) \ Rq(1:r, r+t)`.
3. Set `y(E(r+t)) = 1` and `y(E(1:r)) = −c`.

The support is `{i : |y_i| > tol · max|y|}`, and the residual is `‖[F, R]ᵀ y‖∞`, which is checked to be ≤ `tol`.

A support species is a **dead end** if its row of `N` has exactly one nonzero, i.e. it occurs in exactly one internal reaction. The remedy removes, for every dead-end species in the support, its single internal reaction. It does so for all null vectors of the pass at once, then goes back to step 1.

**Measured**: on both Recon3 variants this yields one null vector with support 15 and residual exactly 0. It removes exactly the 14 reactions in SC-002. The next pass removes 15 zero-row species (`pa_hs[e]` plus the 14 ethanolamides) and the model reaches full rank. Because `pa_hs[e]` occurs only in those 14 reactions, removing fewer than all 14 would not break the dependency, so removing all of them is necessary, not over-eager.

**Rationale**: the basis built from the triangular QR factor is sparse whenever the dependencies are local, as they are here, and the residual check certifies each vector exactly.

**Stop rule**: if a pass reaches step 3 and no support contains a dead end, the function stops with `stopReason = 'irreducibleDependency'` and makes no edit (FR-010).

## R9. Defaults

| Parameter | Default | Justification |
|---|---|---|
| `printLevel` | 0 | openCOBRA convention; silent |
| `maxIterations` | 20 | Recon3T needs 4 editing passes plus 1 confirming pass; 20 leaves wide margin while bounding runtime |
| `remedy` | `'lump'` | spec FR-006 |
| `tol` | 1e-9 | the `[F, R]` entries are O(1) and the residuals measured are exactly 0; 1e-9 is far above round-off for back-substitution on these factors and far below any real coefficient |
| `rxnBool` | `param.rxnBool`, else `model.SConsistentRxnBool`, else `SIntRxnBool` from `findSExRxnInd` | spec *Background* |

**Representative rule**: the group member with the lowest row index in the current model, i.e. the first in `model.mets` order (`unique(..., 'stable')` already yields this). The rule is deterministic and recorded in each `lumpedGroups` entry.

**Conserved difference vectors**: for each non-representative member i, the vector `e_i − e_rep ∈ ℝ^m` (indexed by the model *before* lumping). It is stored sparsely in the report as a pair of metabolite IDs with coefficients `[+1, −1]`. Each is a left-null vector of the pre-lump `[F, R]`.

## R10. The "unchanged model" guarantee and column-selection bookkeeping

**Decision**: if `rxnBool` has to come from `findSExRxnInd`, it is computed on a **copy** of the model. Fields that `findSExRxnInd` adds are never written into `modelOut`. A full-rank input therefore returns `modelOut` that satisfies `isequal(modelOut, model)` (SC-006).

`rxnBool` is carried through edits as a logical vector aligned with `model.rxns`. It is re-indexed after every removal by reaction ID. Rewritten reactions keep their position, so no re-indexing is needed for them. Reaction removals use `removeRxns`, which also keeps `SConsistentRxnBool` aligned when that field exists.

## R11. MATLAB best-practice skill (Principle VII-F)

The registered `matlab-core:matlab-review-code` skill, the `matlab-programming:matlab-validate-function-arguments` skill, and the MATLAB MCP `guidelines://coding` resource are available. The implementation agent applies them, with the openCOBRA style guide controlling where they disagree (VII-G).

In particular, the function uses `exist`/`isempty` optional-argument handling (VII-D) rather than an `arguments` block. That matches the surrounding toolbox's idiom and its R2024b baseline.

## R12. Opt-in general removal (added 2026-10-15 after the user revised the plan)

**User decisions** (Gate 2 revision, human-loop.md):
1. The option is an opt-in **fallback**. The specific remedies run first, and general removal fires only in a pass that would otherwise stop with `irreducibleDependency`.
2. It removes the problematic **species and its reactions using `removeMetabolites`**.

**Decision**:
- `param.irreducibleRemedy = 'removeMetabolites'`; the default is `'stop'`.
- In such a pass, each witness picks one support species by FR-019:
  1. fewest reactions removed, i.e. nonzero columns of `S`, internal plus external, which is exactly what `'inclusive'` removal deletes;
  2. then fewest internal reactions;
  3. then earliest in `model.mets`.
- Duplicate choices collapse. All chosen species are removed in one call to `removeMetabolites(model, chosen, true, 'inclusive')`, followed by `removeUnusedGenes`, and control returns to step 1.

**Why this choice rule**: `'inclusive'` removal deletes every column containing the species, so minimising that count minimises collateral loss. The internal-count tie-break prefers deleting external columns, which the spec otherwise protects, only when the total is equal. Model order makes the rule deterministic.

**Measured** (`measurements/probeGeneralRemoval.m` / `.log`), on the irreducible fixture `r1: A+B->P`, `r2: C+D->P`, `r3: A+C->Q`, `r4: B+D->Q`:
- Pass 1: witness `{A,B,C,D}`. General removal chooses `A` (2 reactions, earliest) and removes `r1` and `r3`.
- Pass 2: witness `{B,C,D}`. `B` and `C` are now dead ends, so the dead-end remedy removes `r4` and `r2`.
- Pass 3: the model is empty (m = 0), which counts as full rank. With a backbone cycle `r5: P->Q`, `r6: Q->P` added, the result is `{P,Q}` with `{r5,r6}`, at rank 2 = m.

So the fixture for US5 (T033) uses the backbone variant, so that the result is non-trivial. The probe also shows general removal hands over to the specific remedies in later passes, as FR-018 requires.

**Termination (FR-021)**: every editing pass removes at least one metabolite or one reaction:
- step 1 removes metabolites;
- lumping removes metabolites;
- `removeRxns` removes reactions;
- dead-end removal removes reactions;
- general removal removes metabolites.

A pass that edits nothing ends the loop. So at most `m + n` editing passes occur. With the option on, the default `maxIterations = m + n` (input sizes) makes the guarantee unconditional. With the option off, the default stays 20 (R9).

**Alternatives rejected by the user**: removing the dependent species only (unbalances reactions); reactions only (harder to keep minimal and deterministic); a standalone mode that bypasses the specific remedies.

## R13. Side effects of the reused removal functions (found while probing R12)

**Findings**:
- `removeRxns(model, list)` (default `metRemoveMethod = 'exclusive'`) also removes metabolites that occur only in the removed reactions, and returns them as `metRemovedList`. It also removes coupling constraints exclusively involving them (`ctrsRemovedList`).
- In the probe, `B`, `C` and `D` vanished during the dead-end removal of `r2` and `r4`, without passing through the zero-row step.
- `removeMetabolites(..., true, 'inclusive')` removes reactions and returns `rxnRemovedList`.
- `removeTrivialStoichiometry` removes empty columns and then zero rows.

**Decision**: every edit is wrapped by a local `recordEdit` helper. It compares `mets`, `rxns` and, if present, `ctrs` before and after the edit:
- items explicitly targeted get the edit's own reason;
- any other metabolite that disappeared is reported as `orphaned`;
- any other reaction that disappeared as `emptyColumn`;
- any constraint in `removedCtrs`.

This guarantees contract item 5a, that the report accounts for the whole set difference, without depending on which reused function removed what. It replaces the earlier `emptyAfterRemoval` reason.

**Consequence for SC-002/SC-002b**: on Recon3T the 15 species orphaned by the dead-end removal still had external reactions, so they were removed by step 1 as `zeroRow` (probeAlgorithm.log, iteration 4). The expected `zeroRow` counts are unchanged. T035/T037 nonetheless assert the *union* of `zeroRow` and `orphaned` removals, so that the test does not depend on which of the two functions removed them.
