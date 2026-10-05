# Research: Return buildAtomAndBondTransitionMultigraph's bond matrices as sparse

**Feature**: `20260921-125236-sparse-bond-matrices` | **Date**: 2026-09-21

Line numbers refer to
`src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m` at
`develop` commit `97ecfc596`.

## R1: One-pass construction of `M2BiE` and `M2BiW` (FR-005)

**Decision**: Replace the two per-metabolite loops (lines 883-893) with one `ismember`
over the bond nodes and two `sparse` calls:

```matlab
nModelMets = length(model.mets);
[isModelMetBond, bondMetRow] = ismember(dBTM.Nodes.mets, model.mets);
bondCols = find(isModelMetBond);
M2BiE = sparse(bondMetRow(isModelMetBond), bondCols, 1, nModelMets, nBonds);
M2BiW = sparse(bondMetRow(isModelMetBond), bondCols, ...
    double(full(dBTM.Nodes.BondType(isModelMetBond))), nModelMets, nBonds);
```

**Why it is exactly equivalent to today's loops**:

- **Uniqueness.** Today's loop sets row `i` wherever `dBTM.Nodes.mets` equals
  `model.mets(i)`. A bond could match more than one row only if `model.mets` had
  duplicates. The function already raises `error('duplicate metabolites')` for that at
  line 159, before this code runs. So each bond column has at most one row, which
  `ismember`'s `loc` output gives exactly.
- **Same comparison.** Both versions use `ismember` on the same cellstr arrays, so a
  metabolite ID matches, or fails to match, the same way in both.
- **Energy pseudo-nodes.** Their `mets` value is a reaction ID, which is not in
  `model.mets`. `isModelMetBond` is false for them, so their columns hold no entries,
  as today.
- **Bond-less metabolites** (for example protons) are never a `bondMetRow` target, so
  their rows are all zero, as today.
- **Column order.** Columns are `1:nBonds` in `dBTM.Nodes` order, and `bondCols` keeps
  that order.
- **No summing of duplicates.** `sparse` adds together entries that share an
  `(i, j)` pair. Every `(i, j)` here is distinct because each column appears once, so
  no entry is summed.
- **`BondType` values.** Today `M2BiW(i,bondId) = BondType(bondId)` stores the value
  as `double`. `double(full(.))` reproduces that whether `BondType` is stored sparse
  (the `full(dBTM.Nodes.BondType)` at line 825 suggests it may be) or as an integer
  or `single` class (`sparse` accepts only `single`/`double`/`logical` values, and a
  `single` value would give a `single` matrix; research R9 rule 2). A value of 0 is stored as an
  implicit zero, and `full` gives 0, which is `isequal` to today's explicit 0. A `NaN`
  is stored explicitly and survives `full`.
- **Class.** `sparse(..., 1, ...)` is sparse `double`, not `logical`, so the only
  class-level difference from today is `issparse` (FR-001).
- **Zero bonds.** If `nBonds == 0`, `sparse([], [], [], m, 0)` is an `m x 0` sparse
  matrix, and `full` of it is `isequal` to `zeros(m, 0)`. Whether the function even
  reaches this point is decided earlier and does not change.

**Cost**: one `ismember` (sort-based, O((b + m) log(b + m))) instead of m calls that
each scan all b bond nodes, O(m * b) string comparisons in total.

**Alternatives considered**:
- *A key-product construction* (`A = sparse(1:m, key)`, `B = sparse(key, 1:b)`,
  `M2BiE = A*B`) handles duplicate `model.mets` exactly. It was rejected because
  duplicates are already an error at line 159, so it would add complexity for no
  benefit.
- *Keeping the loops but allocating sparse* was rejected. Assigning into a sparse
  matrix row by row costs O(nnz) per assignment, which is worse than dense, and the
  m * b scan would remain.

## R2: `BTi2R` (FR-006)

**Decision**: Drop the `full(...)` around the existing
`sparse((1:nTransInstances)', transInstance2rxns, 1, nTransInstances, nMappedRxns)`
(line 898) and leave everything else unchanged.

**Rationale**: the dimensions (`nMappedRxns` from the atom-side `N`, line 414), the
row-to-reaction lookup (against `model.rxns(rxnBondMappedBool)`), and any error `sparse`
raises for a zero or out-of-range column index all come from the same `sparse` call, so
they are preserved exactly (spec Edge Case "`BTi2R` column count"). Each row has exactly
one entry, so no entries are summed.

## R3: Where dense mode is applied (FR-002, FR-007)

**Decision**: Build the three matrices sparse in both modes. Immediately after
construction, before the residual check, run:

```matlab
if options.denseBondMatrices
    M2BiE = full(M2BiE);
    M2BiW = full(M2BiW);
    BTi2R = full(BTi2R);
end
```

**Rationale**: with `denseBondMatrices = 1`, everything after this point (the residual
check, the mismatch report, and the returned values) runs on the same classes and
values as today, so dense mode matches the original function exactly, including every
printed number. The construction code is shared by both modes, so the two modes cannot
diverge in values.

**Alternative rejected**: converting only at return. The residual check and mismatch
report would then always run on sparse matrices, and dense mode would no longer match
the original function's printed output exactly, weakening FR-002 and FR-008.

## R4: Residual check and mismatch report on sparse matrices (FR-007, FR-008)

**Decision**: Leave lines 953-976 unchanged. They work on sparse matrices as they are:

- `res` becomes sparse. `max(max(abs(res)))~=0` gives a sparse logical scalar, and `if`
  accepts it. An empty `res` gives an empty result, and `if` treats it as false, the
  same as today.
- **The residual is exact in both modes.** `M2BiE` entries are 0/1, and `N` and
  `BTiE` entries are small integers. `BondType` values are single, double, triple or
  resolved formal types, all integers or exact binary fractions. Every product and sum
  in `res` is therefore exactly representable, and the result does not depend on the
  order of summation or on storage class. This is why the zero-residual outcome and
  its warning are the same in both modes.
- **The printed `N2` values match.** `D` has `1./d` on its diagonal, and those values
  are not exact binary fractions, so the order of summation matters. Evaluation runs
  left to right:
  1. `D*M2BiE` is one multiplication per entry.
  2. `*BTiE`: every `BTiE` column has exactly two nonzeros (asserted by the sanity
     checks), so each entry is a sum of two terms. Adding two floating-point terms
     gives the same result in either order.
  3. `*BTi2R` adds up, for each reaction, the transitions of that reaction. The
     full-times-sparse and sparse-times-sparse kernels both accumulate a column's
     nonzeros in ascending row order. Adding the extra zero terms that the full
     version includes does not change a partial sum.

  So the two modes should produce bit-identical values. MATLAB does not document its
  kernels' accumulation order, however, so this argument is confirmed by FR-015
  assertion (e), which compares the full printed report across modes.
- **Metabolites with zero bonds.** For these, `d = 0` and `1./d = Inf`. With a dense
  `M2BiE` their `N2` row is `NaN`; with a sparse one it is 0. Such rows are never
  printed: their `M2BiE` row is zero, so their `res` row is zero, and the loop prints
  only entries where `res(i,j) ~= 0`. The printed text is therefore unaffected.

**Fallback if FR-015 (e) fails**: stop and report to the user. A fix would change
expressions in the mismatch report, which FR-009 permits only as far as FR-007
requires. That needs a spec note before it is implemented, not an improvised change.

## R5: Option handling and documentation (FR-004)

**Decision**: Add a new option default next to the existing two (lines 150-155):

```matlab
if ~isfield(options,'denseBondMatrices')
    options.denseBondMatrices=0;
end
```

Like the other options, it is treated as true or false (`if options.denseBondMatrices`),
with no extra validation. The header's `OPTIONAL INPUT` list (lines 75-76) gets a
`* .denseBondMatrices` bullet. The `M2BiE`/`M2BiW`/`BTi2R` output descriptions
(lines 139-141) get a note: "sparse by default (changed in feature
20260921-125236-sparse-bond-matrices); set `options.denseBondMatrices = 1` for the
historical full matrices". The existing, inaccurate `USAGE` line (line 58) is out of
scope (FR-009) and is left as it is.

## R6: CI test design (FR-015)

**Decision**: add a new file,
`test/verifiedTests/analysis/testReactingMoieties/testBuildAtomAndBondTransitionMultigraph.m`.

- **Requirements**: `prepareTest()` with no flags. The function needs no solver, and
  the call still makes the test follow the harness convention.
- **Fixture**: the same Recon3D subnetwork `testConservedReactingMoieties.m` uses:
  `Recon3D_301.mat`, `extractSubNetwork(model, {'r0317';'ACONTm';'r0426'})`, and the
  shared `data/rxnFiles`. It adds no new data files.
- **(a)-(c)**: call the function twice, with default options and with
  `denseBondMatrices = 1`. Assert the matrices' `issparse` and `class`, that the other
  nine outputs are `isequaln` across modes, and that the three matrices have equal
  sizes and `isequal(full(default), dense)`.
- **(d)**: recompute both residuals from the outputs, using the same boolean
  derivations the function uses for `N`. Assert both are exactly zero in both modes.
- **(e) Inconsistent fixture**: copy the sub-model and double one stoichiometric
  coefficient of a bond-bearing metabolite in `r0317`. The atom mappings and bond
  mappings come from the RXN files, not from `S`, so construction still succeeds, and
  both residuals become nonzero. The atom-side report and its warning also fire; that
  is expected and stays visible. Assert that the bond inconsistency warning is raised
  in both modes. Assert that the full console text of the call is identical between
  modes and contains
  `Inconsistency between reaction stoichiometry and bond mapped reactions`.
- **Capturing console text**: record it with `diary` to a `tempname` file, not `evalc`.
  `diary` copies console output and still shows it, so warnings stay visible
  (Principle VII-B), and VII-A's restriction on `evalc` does not arise. The test saves
  the user's `get(0,'Diary')` and `get(0,'DiaryFile')` state and restores it with an
  `onCleanup`. It detects the warning by matching the captured text, because `lastwarn`
  holds only the most recent warning.
- **Sanity checks**: every call uses `options.sanityChecks = 1`, matching the existing
  test, so the sanity-check paths also run on sparse matrices.

**Alternative rejected**: `evalc` capture. It routes warnings into a string instead of
the console, which conflicts with VII-B.

## R7: Golden-snapshot reproducibility check (FR-012, FR-013)

**Decision**: create `specs/20260921-125236-sparse-bond-matrices/reproducibilityCheck.m`.
Its structure follows the feature 021/022 and 20260902 `tyrosineReproducibilityCheck.m`
scripts: capture mode or compare mode depending on whether a snapshot exists, and an
append-only results `.md` file. It differs from them in these ways:

- **Captured layer**: all twelve outputs of `buildAtomAndBondTransitionMultigraph`, not
  the downstream `arm.L`. The three matrices are saved sparse (the spec's Assumptions
  allow this), and the dense class of the originals is recorded as metadata.
- **Comparison**: `isequaln`. It is identical to `isequal` except that `NaN == NaN`,
  which is needed because `dBTM`/`dATME` node tables can hold `NaN` (for example the
  `mapAontoBOld` fill-ins at lines 787-793), and with `isequal` an unchanged output
  would compare unequal to itself. In capture mode the script checks that the snapshot
  compares equal to itself.
- **Fixtures**:
  - **Required**: tyrosine (`subModels.tyr`; 127 reactions and 197 metabolites in the 2026-09-17 `subsystemSubModels.mat`, previously 139 reactions) and the CI fixture.
  - **Also covered, self-contained and cheap**: the five bond-key sub-models under
    `test/.../data/` (crn, coaM, coaX, coaR, crnM) and the hand-built MACACI/rh_14817
    model. All use the shared `data/rxnFiles`.
  - **Not covered**: the reconXmoieties pilot fixtures (FR-012 lists them as SHOULD).
    They depend on that repository's staged data and on the feature 029 harness, which
    is not merged; the results file records this.
- **Tyrosine corpus**: the path used by features 021/022
  (`/media/JACK/repos/ctf/rxns/atomMapped_standardised`) no longer exists (0 files). The
  corpus now lives at `/media/JACK/repos/ctf/rxns/old/atomMapped_standardised`
  (17,224 `.rxn` files), a frozen "old" copy that is less likely to change than the
  active `atomMapped_std` (edited on 2026-09-21). The script uses it.
- **Corpus provenance** (FR-012): the corpus path, the `.rxn` count, and a SHA-256 hash
  of the sorted `name<TAB>bytes<TAB>mtime` listing (the change indicator). All three
  are stored in the snapshot and in every results entry. In compare mode, a changed
  indicator raises the error `reproducibilityCheck:CorpusChanged`, so a data change is
  never reported as a code regression.
- **Decomposition status** (SC-003): for each fixture and mode, the script records
  both residual maxima and whether either inconsistency warning appears in the diary
  text, using the same `diary` capture as R6. **CI fixture**: zero residuals and no
  inconsistency warning are required. **Every other fixture, including tyrosine**: the
  original residuals, warnings and printed bond mismatch report are recorded; after the
  change they must be identical, not necessarily zero. (Capture on 2026-09-21 found the
  tyrosine fixture already inconsistent in the original function: bond residual 3 from
  a tym[c]/34hpp[c] bond-count mismatch in the corpus. The user chose this rule, spec
  SC-003.) For all fixtures, the bond mismatch report text (empty when consistent) is
  compared against the original's in both modes. SC-001 applies to every fixture unchanged.
- **Extra fixtures for spec coverage**: `ci_noBond` is the CI fixture with
  `options.bondTransitionMultigraph = 0`, first five outputs only (the only outputs assigned in that mode; verified 2026-09-21) (US1 acceptance
  scenario 4). `noRxnFiles` is the CI sub-model with its `rxns` renamed to IDs that
  have no RXN file (e.g. `strcat(rxns, '_none')`), covering the degenerate-input edge
  case. For it, the script captures either the outputs or the error `identifier` and
  `message` (propagated with `ME.stack(1)` per VII-C), and requires the same outcome
  after the change.
- **Storage** (SC-004, FR-013): `whos` bytes for the three matrices in sparse form and
  in dense form, and the ratio. The ≤10% gate is checked only on fixtures with ≥ 50
  metabolites and ≥ 50 reactions, which means tyrosine.
- **Snapshot size**: saved with `-v7` (compressed). If the file is over 10 MB, the
  script prints a warning and the implementer stops to ask before committing it. The
  three earlier snapshots were committed, but they were about 3 KB each.

## R8: Timing the fill step (FR-013, SC-005)

**Decision**: the reproducibility check contains two local functions:

- `fillBondMatricesOriginal(modelMets, nodeMets, bondType, nBonds)`: a verbatim copy of
  lines 883-893.
- `fillBondMatricesModified(...)`: a verbatim copy of the new construction (R1).

Each is run 5 times on the tyrosine fixture's `model.mets` and `dBTM.Nodes`, and the
median `tic`/`toc` is recorded. The *before* median is measured in capture mode, while
the source is still unmodified, and saved in the snapshot. The *after* median is
measured in compare mode. SC-005 passes if the after median is ≤ the before median.

Two checks confirm each copy matches the real code:

1. **Output equality**: each copy's output must be `isequaln` (after `full`) to the
   `M2BiE`/`M2BiW` that the real function returns in the same run.
2. **Source match**: the modified copy's non-blank code lines must appear, in order, in
   the source file.

**Rationale**: the fill step's only inputs are `model.mets`, `dBTM.Nodes.mets`,
`dBTM.Nodes.BondType` and `nBonds`, so running a copy of the code on the function's own
data times exactly that code without instrumenting `src/`. Adding timing code to the
function was rejected: it would change the function's source beyond the three matrices
(FR-009, SC-006).

**Alternative rejected**: the profiler's per-line timings (`profile info`,
`ExecutedLines`). The profiler adds overhead to every line executed, and the original
loop executes about 2m lines against a handful for the new code. That would inflate the
before figure and bias the comparison in the change's favour.

## R9: MATLAB best-practice consultation (Principle VII-F)

**Skill search**: no registered skill covers MATLAB coding conventions or linting (the
skills listed in this session are Spec Kit, artifact and document skills only).

**Targeted search of authoritative sources** (MathWorks documentation, 2026-09-21):

1. *Accessing Sparse Matrices*
   (https://www.mathworks.com/help/matlab/math/accessing-sparse-matrices.html): "it's
   best to construct sparse matrices all at once using a construction function, like
   the sparse or spdiags functions". Assigning into a compressed-sparse-column matrix
   inside a loop "needs to shift multiple entries … during each pass", and the page's
   example of preallocating with `spalloc` and filling element by element was about
   140x slower than one `sparse` call. **Applied**: R1 and R2 build every matrix with
   one `sparse(i,j,v,m,n)` call; no sparse matrix is assigned into by index.
2. *sparse* (https://www.mathworks.com/help/matlab/ref/sparse.html): repeated `(i,j)`
   pairs are summed for `double` and combined with `any` for `logical`; "Any elements
   in `v` that are zero are ignored"; `v` may be `single`, `double` or `logical`
   (integer types only for `i` and `j`), and a `single` `v` gives a `single` matrix.
   **Applied**: R1 relies on every `(i,j)` being distinct, so nothing is summed. It
   passes `double(full(BondType))`, so the class is always `double` and integer or
   sparse `BondType` storage is accepted. Dropped zeros compare equal after `full`.
3. *isequal* (https://www.mathworks.com/help/matlab/ref/double.isequal.html): "isequal
   does not consider data type when it tests for equality", and NaN is unequal to
   itself (use `isequaln`). **Applied**: every value comparison uses `isequaln`, and
   `class` and `issparse` are always checked separately (R7, FR-015).
4. MATLAB Style Guidelines (the style guide the openCOBRA guide cites): vectorise
   instead of looping, and put no hard-coded absolute paths in toolbox functions.
   **Applied**: R1 is vectorised. Absolute paths appear only in the feature-local
   `reproducibilityCheck.m` (a Spec Kit artifact, not toolbox source), as in the
   021/022/20260902 precedent.

**Proposal (VII-F(2))**: add a project skill `matlab-best-practice` recording rules 1-4
plus the openCOBRA conventions of VII-G, through a separate, spec-driven change. This
feature does not create it.
