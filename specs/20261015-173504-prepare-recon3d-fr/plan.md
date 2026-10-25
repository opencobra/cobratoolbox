# Implementation Plan: Full-row-rank [F,R] model preparation (`generateFullRowRankFR`)

**Branch**: `20261015-173504-prepare-recon3d-fr` | **Date**: 2026-10-15 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/20261015-173504-prepare-recon3d-fr/spec.md`

## Summary

Add one new function, `generateFullRowRankFR`. It edits a COBRA model until the internal half-stoichiometric matrix `[F, R]` has full row rank, and it returns a report of every edit and every witness. Each pass:
- removes zero rows;
- lumps (or, if asked, removes the reactions of) groups of identical rows, rewriting reactions with `addReaction`;
- for any remaining dependency, finds a certified left-null witness by sparse QR, and removes the dead-end reactions in its support.

If no admissible remedy exists, it stops and reports the witness. Alternatively, with the opt-in `irreducibleRemedy = 'removeMetabolites'`, it removes the deterministically chosen problematic species together with all their reactions via `removeMetabolites(..., true, 'inclusive')` and continues, which guarantees full row rank (User Story 5, research R12).

Phase-0 measurements (research.md) reproduce the Recon3T figures exactly and show that the in-repo Recon3D carries the same structure, so it can serve as a CI-runnable large test. They also expose three behaviours of the existing building blocks that the design must absorb without changing them:
- empty external columns left behind by metabolite removal;
- `checkDuplicateRxn('FR')` scanning external columns;
- `addReaction` blanking legacy char subsystems.

## Technical Context

**Language/Version**: MATLAB, R2024b baseline (verified on the local install).

**Primary Dependencies**: COBRA Toolbox functions only (contract § Dependencies); LUSOL through `getRankLUSOL`; MATLAB sparse `qr` (SuiteSparseQR).

**Storage**: N/A. Test fixtures are built in code. Large models are loaded from:
- `test/models/mat/Recon3DModel_301_xomics_input.mat` (in repo);
- `papers/2023_iDopaNeuro/models/iDopaNeuroC.mat` (submodule);
- the external VK Recon3T file (reproducibility script only).

**Testing**: `test/verifiedTests/analysis/testTopology/testGenerateFullRowRankFR.m`, run by `testAll`, declared with `prepareTest` (no solver needed).

**Target Platform**: headless Linux CI (`matlab -batch`), and desktop.

**Project Type**: library function.

**Performance Goals**: a full Recon3-scale run (5 passes) in well under 1 minute. Measured per pass: rank 0.3 s and QR 0.02 s; the cost is dominated by `addReaction` and `removeMetabolites` field updates. Correctness dominates; no witness check is skippable.

**Constraints**:
- no change to any reused toolbox function;
- no suppressed warnings;
- deterministic output.

**Scale/Scope**: genome-scale up to m ≈ 6×10³ and `[F, R]` ≈ 6×10³ × 1.8×10⁴, nnz ≈ 10⁵.

## Constitution Check

*GATE: checked before Phase 0, re-checked after Phase 1. PASS.*

- **Scientific code quality (I)**:
  - Objects and their dimensions are stated in data-model.md.
  - The function edits `S`, `mets`, `rxns` and the fields attached to them only through the toolbox's own manipulation functions.
  - Every edit is justified by a certified witness: a zero row, identical rows, or a null vector with residual ≤ `tol`.
  - Lumping keeps the representative's coefficients unchanged, which is exact because the rows are identical, and records the conserved difference vectors.
  - The `addReaction` subsystem blanking (R6) is neutralised so that annotation is preserved.
  - Biologically ambiguous cases (shared substrates) are flagged, not resolved.
  - General removal is opt-in, structurally determined, and fully reported. It never fires while a specific remedy applies, so the default behaviour and the Recon3T evidence are unchanged.
- **Testing and reproducibility (III)**:
  - One test file, `testGenerateFullRowRankFR.m` (III-Naming), under `test/verifiedTests/analysis/testTopology/`.
  - The fixture cases are those in the spec Traceability table.
  - The in-repo Recon3D case runs in CI.
  - The iDopaNeuroC and Recon3T cases skip when their files are absent.
  - Recon3T is also covered by `measurements/reproduceRecon3T.m` with a committed log (Principle III's documented reproducibility check).
  - Integer and count assertions use exact equality; residual assertions use `tol`.
  - The test sets no random seed because nothing is stochastic. `printLevel = 0`.
- **User experience and diagnostics**:
  - The report is fully initialised on every path (data-model.md).
  - With `printLevel = 0` the function is silent; with `printLevel ≥ 1` it prints one summary line per pass; with `printLevel ≥ 2` it prints each edit.
  - Rank disagreement between LUSOL and QR raises a visible warning.
- **Performance and numerical integrity (IV)**:
  - The QR cross-check runs on every rank decision and is cheaper than LUSOL, so integrity costs essentially nothing.
  - No verification step is skippable.
  - Residuals are reported, not merely thresholded.
- **External-solver configuration audit**: LUSOL defaults (`TPP`, `Ltol1` = 10, `Utol1`/`Utol2` = eps^0.67, `small` = eps^0.8, `nzinit` = 0) were cross-checked against the profile of `[F, R]`: sparse, nonnegative, O(1) entries. None is mismatched except storage on large inputs (`inform = 7`), which is handled by the QR cross-check because `getRankLUSOL` takes no options. SuiteSparseQR runs with its default ordering, measured at 0.02 s. Details in research R7. No LP/QP solver is invoked.
- **Spec-driven scope control (V)**:
  - New files: `src/analysis/topology/FR/generateFullRowRankFR.m`, the test, and `measurements/reproduceRecon3T.m` (+ log).
  - Read-only: every reused function, `external/`, `deprecated/`, `papers/`.
  - No new dependency.
  - Known defects found in building blocks (R5 duplicate scan over external columns; R6 subsystem blanking) are worked around and recorded as follow-ups, not fixed here.
- **MATLAB coding standards (VII)**:
  - no `evalc`;
  - warnings visible, including `addReaction`'s update warning;
  - no `try/catch` planned; any added one must propagate `ME.stack`;
  - optional arguments via `exist`/`isempty`, not `nargin` (VII-D);
  - full openCOBRA header (VII-E);
  - camelCase verb-noun local functions;
  - the `matlab-core:matlab-review-code` skill is applied (VII-F, R11).
- **Parameter-setting fidelity (VIII)**: N/A. No ported or literate output.
- **Artifact placement (IX)**:
  - The source sits next to the existing `[F, R]` tooling (`checkRankFR.m`, `combinatorialDependentRows.m`) in `src/analysis/topology/FR/`. A new subfolder was rejected because that folder already is the subfolder for this topic.
  - The test sits in the existing `testTopology` category.
  - Probe scripts, logs and the reproducibility script live in `specs/<feature>/measurements/`.
  - Nothing goes at the repository root.
- **Single-sourcing (X)**: the function header documents the behaviour. No rule is restated in CLAUDE.md or AGENTS.md.

## Design decisions (summary; rationale in research.md)

| # | Decision | Research |
|---|---|---|
| D1 | Identical rows are found by exact equality (`unique(FR,'rows','stable')`) | R4 |
| D2 | The representative is the lowest-index member; difference vectors are `e_i − e_rep` | R9 |
| D3 | Lump rewrite uses `addReaction` with explicit bounds, objective, name, GPR and subsystem, then restores the original `subSystems` entry | R6 |
| D4 | After any metabolite removal, `removeTrivialStoichiometry` drops emptied columns, reported as `emptyColumn` | R5 |
| D5 | Duplicates come from `checkDuplicateRxn(model,'FR',0,0)` (detect only), run before and after the lump; only internal reactions *newly* flagged are removed (provably none; safety net) | R5, R5a |
| D6 | Rank comes from `getRankLUSOL`, cross-checked by sparse QR; on disagreement the QR rank is used, with a warning, and both are logged | R7 |
| D7 | Left-null basis from column-pivoted sparse QR of `[F, R]ᵀ`; dead end = exactly one nonzero in its row of `N` | R8 |
| D8 | Defaults: `maxIterations` = 20, `tol` = 1e-9, `printLevel` = 0, `remedy` = `'lump'` | R9 |
| D9 | `findSExRxnInd` runs on a copy; `rxnBool` is tracked by reaction ID; a full-rank input is returned with `isequal` to the input | R10 |
| D10 | `flaggedForReview` holds reaction pairs in one dead-end remedy that share a substrate not common to the whole remedy | data-model.md |
| D11 | After any reaction removal, `removeUnusedGenes`; at `printLevel > 0`, `verifyModel` as an optional final check | FR-011, FR-014 |
| D12 | Opt-in general removal: `irreducibleRemedy = 'removeMetabolites'`, chosen by fewest total reactions, then fewest internal, then model order; one `removeMetabolites(..., true, 'inclusive')` call per pass; default `maxIterations = m + n` when on | R12 |
| D13 | Every edit is wrapped by `recordEdit`, which compares `mets`/`rxns`/`ctrs` before and after and reports side effects as `orphaned`, `emptyColumn` or `removedCtrs` | R13 |

### Fixture designs (to be confirmed numerically in the test-first task)

| Case | Construction | Expected |
|---|---|---|
| Zero row | 3 internal reactions plus `X` appearing only in `EX_X` | `X` removed (`zeroRow`); `EX_X` removed (`emptyColumn`) |
| Identical pair | `A + P + Q -> B`, `B -> A` | `{P, Q}` lumped to `P` |
| Five-member group | 5 co-substrates always together in 2 reactions | one group of 5; 4 difference vectors |
| `removeRxns` remedy | identical-pair fixture with `remedy = 'removeRxns'` | the group's reactions removed (`identicalRowGroup`) |
| Pre-existing duplicate | identical-pair fixture plus a reaction that is a scalar multiple of a group reaction | the duplicate check runs; nothing removed with `duplicateAfterLump`; the pre-existing duplicate is kept (R5a) |
| Sum dependency | `P` is produced together with a dead end `Dᵢ` by each of 3 reactions, and `P` occurs nowhere else internally | one null vector with support 4, 3 `deadEnd` removals, then 4 `zeroRow` removals |
| Irreducible | a dependency in which every support species occurs in ≥ 2 internal reactions and no rows are identical | `fullRowRank = false`, `irreducibleDependency`, `remedy = 'none'`, model unchanged in that pass |
| Iteration limit | sum-dependency fixture with `maxIterations = 1` | `stopReason = 'maxIterations'` |
| Full rank | small consistent network with full-row-rank `[F, R]` | `isequal(modelOut, model)`; empty lists |
| General removal | irreducible fixture plus backbone `r5: P->Q`, `r6: Q->P`, with `irreducibleRemedy='removeMetabolites'` | pass 1 `generalRemoval` of `A` with `r1, r3`; pass 2 `deadEnd` removal of `r4, r2` with `B, C, D` `orphaned`; final `{P, Q}`, `{r5, r6}`, full rank (R12) |

The test-first task MUST numerically confirm each fixture's initial `[F, R]` rank and dependency structure before any assertion is written against the function.

## Project Structure

### Documentation (this feature)

```text
specs/20261015-173504-prepare-recon3d-fr/
├── spec.md
├── plan.md                       # this file
├── research.md                   # Phase 0 (R1–R11)
├── data-model.md                 # Phase 1
├── quickstart.md                 # Phase 1
├── contracts/generateFullRowRankFR.md # Phase 1
├── checklists/requirements.md
├── measurements/                 # probe*.m + *.log (Phase 0); reproduceRecon3T.m + log (implementation)
├── tasks.md                      # /speckit-tasks
└── agent-runs/                   # implementation receipt
```

### Source Code (repository root)

```text
src/analysis/topology/FR/
└── generateFullRowRankFR.m            # NEW: main function + local helpers
                                  #   (computeFR, decideRank, findIdenticalGroups, lumpGroup,
                                  #    removeInternalDuplicates, leftNullWitnesses, initReport)
test/verifiedTests/analysis/testTopology/
└── testGenerateFullRowRankFR.m        # NEW: fixtures + in-repo Recon3D + optional iDopaNeuroC/Recon3T
```

**Structure Decision**: one source file with local functions, mirroring the single-file style of the neighbouring `checkRankFR.m`. No change to any existing file.

## Follow-ups (outside this feature; to be raised as separate Spec Kit items)

1. `addReaction` blanks legacy char `subSystems` entries when updating an existing reaction (R6).
2. `checkDuplicateRxn('FR')` treats empty columns as mutual duplicates and scans external columns (R5).
3. `getRankLUSOL` does not expose the LUSOL `inform` code, so callers cannot detect `inform = 7` (R7).

## Complexity Tracking

No constitution violations to justify.
