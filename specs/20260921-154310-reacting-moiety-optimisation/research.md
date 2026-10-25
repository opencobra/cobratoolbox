# Phase 0 Research: reacting-moiety optimisation of identifyConservedReactingMoieties

**Feature**: `20260921-154310-reacting-moiety-optimisation` | **Date**: 2026-09-21 | **Spec**: [spec.md](spec.md)

Every item was checked against the code on this branch (`64efe1dc8`, = `develop`) and the prototype in
`~/repos/reconXmoieties/experiments/moietySizing/scripts/reactingOptimisation/`
(`extractBondSubgraphsFast.m`, `findAndExtractMolecularGraphsFast.m`, `patch_reacting_optimisations.py`,
`validateReactingOptimisation.m`). Where this plan differs from the prototype, it says why. The MATLAB
behaviour cited in R4, R5 and R8 was checked with MATLAB R2024b in `-batch` mode during planning.

There are no open NEEDS CLARIFICATION items. The one scope contradiction found (whether the stage-09
call sites and STEP B4 loops may change) was settled with the user and written into the spec
(Clarifications, FR-010, SC-005).

---

## R1. `extractBondSubgraphs`: what replaces the per-step graph-table rebuilds (FR-003, FR-005, FR-007)

**Decision**: Rewrite the body in place using the prototype's three data-access changes. The peeling
algorithm and its loop structure stay the same.

1. **Atom to component lookups.** `compOfAtom(AtomIndex) = Component` and
   `nodesByComp{c} = sort(find(atoms2component == c))` are built once. They replace
   `ATG.Nodes.Component(ATG.Nodes.AtomIndex == i)` and `find(atoms2component == c)`, which each scan all
   atoms, twice per bond visited.
2. **Cached edge arrays for `BIGCopy`.** `endNodes` and `edgeIdx` are read from `BIG.Edges` once. They
   replace `BIGCopy.Edges.EndNodes(k, :)`, `numedges(BIGCopy)` and `BIGCopy.Edges.EdgeIndex`, each of
   which rebuilds the edge table. The cache has the same rows deleted every time `rmedge(BIGCopy, idsToRemove)`
   runs, so it always matches `BIGCopy.Edges` row for row. `rmedge` preserves the order of the remaining
   rows, so deleting the same row indices from the cache keeps them equal; the prototype checked this after
   every removal on all seven fixtures with its `verifyMirror` assertion.
3. **Layer peeling on a table, not a graph.** After `GBB = subgraph(...)`, only `GBB.Edges` and
   `GBB.Nodes` are read. The layer loop deletes rows from a local copy of the edge table (`GEdges(rows, :) = []`)
   instead of calling `rmedge(GBB, rows)` and then reading `GBB.Edges` again. `rmedge` on a digraph keeps
   the order of the remaining rows, so `unique(..., 'first')` sees the same sequence in both versions.

The `verLessThan('matlab','8.6')` guard and its `error('Requires matlab R2015b+')` are kept word for word
(FR-009). The prototype dropped them; this plan does not.

**Preconditions and fallback (FR-007).** The fast path is used only when all of the following hold:
`AtomIndex` is numeric, positive, whole and unique; every `Component` label is a positive whole number
no greater than `max(conncomp(ATG))`; `BIG.Edges.EndNodes` is numeric, positive and whole, and no greater
than `max(AtomIndex)`; and every end node maps to a component. Otherwise the original algorithm runs,
unchanged, as a **local function in the same file**. The original algorithm has to stay in the file:
once the body is rewritten there is no other copy to fall back to. This is not an option to choose the
old code (FR-010 forbids that). It runs only when the fast path's lookup arrays would be wrong, and the
original's result, or its error, is then what the caller gets.

- **Zero BIG edges**: the original never enters its `while` loop and returns `{}`/`{}`. The rewrite
  checks for this right after `conncomp` and returns the same `{}`/`{}` (and an empty `bmgEdgeIndex`).
  It does this before building any lookup array, because `zeros(max([]), 1)` fails on an empty `ATG`.
- **Non-numeric `EndNodes`** (a BIG with named nodes gives cellstr `EndNodes`): the fast path's
  precondition fails, so the original runs. The prototype handled this through `isnumeric`.

**Alternatives considered**:
- *Keep `rmedge` on `BIGCopy` and drop it altogether, using only the cache.* Rejected: `GBB = subgraph(BIGCopy, ...)`
  needs the live, shrunken `BIGCopy`. Keeping `rmedge` is also what makes the cache a true copy.
- *Replace `subgraph(ATG, ...)` and `addedge(combinedSubgraph, ...)` with table assembly.* Rejected for
  this feature: `bondSubgraphs{k}` is a graph whose `Nodes`/`Edges` tables must match exactly, and the
  prototype did not validate that change. It is a candidate follow-up.
- *Ship the prototype's `options.verifyMirror` debug input.* Rejected: it adds a public input, and the
  CI tests (R9) and golden snapshots (R10) already detect any drift in the cache through the outputs.

**Rationale**: these are the prototype's validated changes (stage-09 extraction: 31.4 s to 13.4 s on
bileacid, outputs `isequal` on all seven fixtures), with the dropped `verLessThan` guard restored and an
explicit zero-edge path added.

---

## R2. The edge-index cache (`bmgEdgeIndex`) and what "identical" means for it (FR-003, FR-004)

**Decision**: `extractBondSubgraphs` gets an optional third output,
`bmgEdgeIndex{m} = GEdges.EdgeIndex(firstOccurrenceIndices)` for layer `m`. It is a column of the
`EdgeIndex` values of the edges of `BMG{m}`, **in construction order**. Callers asking for two outputs
see no change.

**Contract**: `sort(bmgEdgeIndex{m})` equals `sort(BMG{m}.Edges.EdgeIndex)`. The order may differ because
`digraph(EdgeTable, NodeTable)` sorts edges by `(source, target)`. That order does not matter to any
consumer, because every consumer uses the cache as a set:
- `findAndExtractMolecularGraphs`: `ismember(BIG.Edges.EdgeIndex, vertcat(bmgEdgeIndex{group}))`, a
  membership test whose result `find` returns in `BIG.Edges` order;
- STEP B4 loop 1: `bonds2component(bmgEdgeIndex{i}) = i`, assigning the same scalar to every index;
- STEP B4 loop 2: `bonds2isomorphismClass(bmgEdgeIndex{conservedGroups(i)}) = bondSubsequentSubgraphIndices(i)`,
  the same.

**Alternatives considered**: sorting the cache into `BMG{m}.Edges` order (costs a sort per layer and
gains nothing, since every use is a set operation); not adding the cache (every consumer would read
`.Edges` on thousands of graph objects, the cost the prototype measured).

---

## R3. `findAndExtractMolecularGraphs` (FR-004, FR-005)

**Decision**: Rewrite the body in place with the prototype's changes:
- `CMTG`/`RMTG`: collect each subgraph's `Edges`/`Nodes` table in a cell array in group order and join
  them with one `vertcat`, instead of `x = [x; more]` once per subgraph. The accumulating form copies
  everything so far each time, so its cost is quadratic in the number of subgraphs (95.7% of this
  function's profile on tyrosine). A single `vertcat` in the same order gives the same tables row for row.
  `unique(nodes, 'rows')` and the `digraph` construction are unchanged.
- `CMG`/`RMG`: use `vertcat(bmgEdgeIndex{group})` from the new optional fourth input. If it is absent or
  empty, build it from `BMG{m}.Edges.EdgeIndex`, so a three-argument call behaves as before.
- Classification (`classifySubgraphIsomorphism`), `max(cellfun(@length, ...))` and `setdiff` are unchanged.
  They must be: `conservedGroup` and `reactingGroups` are outputs.

**Edge cases checked**:
- `classifySubgraphIsomorphism` returns `1 x numClasses` cells of **row** vectors (its help header).
  `reactingGroups` comes from `setdiff(1:n, ...)`, also a row. The original's `for idx = conservedGroup`
  therefore visits each index once, which is the same as `for q = 1:numel(group)`.
- An empty group: the original leaves the edges as `[]` and the nodes as `table()`. The rewrite keeps that
  exact pair (`edgesAll = []`, `nodesAll = table()`), so `digraph([], table())` gives the same graph.
- No subgraphs at all: the original fails at `isomorphicGroups{largestGroupIndex}` with an empty index.
  The rewrite keeps the same statement, so it fails the same way.

**Alternatives considered**: a separate helper file for the table assembly. Rejected: FR-010 limits new
files to tests; a local function in the same file is enough.

---

## R4. RBG re-indexing (stage 14a) (FR-006, FR-007)

**Decision**: `[~, newEndNodes] = ismember(edgeTable.EndNodes, nodeTable.AtomIndex)` replaces the
per-row, per-column `find`. `ismember` returns an index array the same size as its first input
(checked: a `0x2` input gives a `0x2` result), so zero-edge and one-edge inputs keep their shape.

**Fallback**: if `nodeTable.AtomIndex` has duplicates, or any location is `0` (an endpoint not found),
the original loop runs. In both cases the original raises an error: `find` returns several indices, or
none, and the scalar assignment fails ("Unable to perform assignment because the size of the left side
is 1-by-1 and the size of the right side is 1-by-0", checked in R2024b). `ismember` would instead
return the first match or `0` without complaint, and the failure would move or disappear. The fallback
keeps the original error and where it happens (Principle IV: no silent change of path).

**Rationale**: `nodeTable = ABG.Nodes(unique(EndNodes), :)` has one row per distinct endpoint, so when
`AtomIndex` is unique, `ismember`'s first-match position is the position `find` returns. Stage 14 took
2.7 s before and 0.009 s after on bileacid in the prototype.

---

## R5. Condensed_RBG re-indexing (stage 14b): a defect in the prototype (FR-006, FR-007)

**Decision**:

```text
endNodes   = RBG.Edges.EndNodes
components = reshape(RBG.Nodes.Component(endNodes), size(endNodes))
[~, endNodesModified] = ismember(components, uniqueComponents)
```

This relies on `RBG.Nodes.NewId = (1:n)'` having just been assigned, so the original
`find(RBG.Nodes.NewId == e)` is always `e`. It also relies on `componentTable.Component` being
`unique(RBG.Nodes.Component)` with `NewId = 1:k`, so the original `componentTable.NewId(Component == c)`
equals the position of `c` in `uniqueComponents`.

**The prototype's version is wrong for a Condensed_RBG with exactly one edge.** It computed
`RBG.Nodes.Component(RBG.Edges.EndNodes)` without `reshape`. When the source is a vector and the index is
a `1x2` vector, MATLAB returns a result shaped like the **source**, here `2x1` (checked in R2024b:
`c = [10;20;30]; size(c([1 3]))` gives `2 1`). The `2x1` result would then be assigned to
`edgeTable.EndNodes` for a single edge. None of the seven fixtures has a single reacting edge, which is
why the prototype never hit this. The `reshape` fixes it, and a single-edge case is added to the check
(see R10) and noted in the contract.

**Fallback**: the original loop runs if `RBG.Edges.EndNodes` is not numeric, or if any
`endNodesModified` is `0` (for example a `NaN` component: `unique` keeps each `NaN` separately, so
`Component == NaN` never matches and the original's assignment fails). The original's
`if ~isempty(idx)` branch cannot be reached when `NewId = 1:n`, so the rewrite does not lose it.

---

## R6. `CRB2R` build (stage 17) (FR-007, FR-008, FR-009)

**Decision**: use the prototype's sparse atom-to-reaction incidence, with a tighter precondition:

```text
atomToRxn = spones(sparse([headATM; tailATM](valid), [rxnCols; rxnCols](valid), 1, nAtomsMax, nRxns))
touch     = atomToRxn(atom1(rows), :) + atomToRxn(atom2(rows), :)
CRB2R     = sparse(foundIdx(touchRow), touchCol, 1, nCRB, nRxns)
```

Row `i` of `CRB2R` is the set of reactions with an atom transition that touches atom `a1` or atom `a2` of
bond `i`. That is exactly the original's `unique(rxnCols(headATM == a1 | tailATM == a1 | headATM == a2 | tailATM == a2))`
with columns `<= 0` removed. `find(touch)` returns each (row, column) pair once, so every stored value is
exactly `1`. The result is a sparse double of size `nCRB x nRxns`, the same class and value set as the
original's `sparse(nCRB, nRxns)` filled with `CRB2R(i, cols) = 1` (FR-008).

**Warnings (FR-008, FR-009)**: the original emits `warning('BondIndex %d not found.', b)` for each bond
whose `bondRowMap(b) == 0`, in increasing `i`, and prints nothing else in the loop. The rewrite emits the
same warnings, with the same text and in the same order, from a loop over `find(~foundInBG)'` before
building the matrix. The console output and `lastwarn` are therefore the same.

**Precondition, tightened from the prototype**: the fast path requires `atom1_all`, `atom2_all`, `headATM`
and `tailATM` to be **numeric**, whole and positive, and `bondIdx` to be whole, positive and no greater
than `maxBondIndex`. The prototype's `isAtomIdx` called `fix` on its argument, and `fix` of a cell
**throws** ("Undefined function 'fix' for input arguments of type 'cell'", checked in R2024b). A
`BG` with named nodes would therefore have crashed in the precondition check instead of falling back.
The bound on `bondIdx` keeps the original's behaviour for an out-of-range BondIndex: the original fails
at that bond, after emitting the warnings for earlier bonds, while a vectorised `bondRowMap(bondIdx)`
would fail before emitting any. Any failed precondition runs the original loop, kept verbatim in the
`else` branch.

**Empty inputs**: with `nCRB == 0`, `sparse(zeros(0,1), zeros(0,1), 1, 0, nRxns)` returns a `0 x nRxns`
sparse matrix (checked in R2024b: `sparse([], [], 1, 0, 5)` is `0x5` and sparse), the same as the
original.

**Rationale**: it removes the scan of every atom transition for every bond (`O(#bonds x #transitions)`).
The MILP that follows sees byte-identical data, so the solver is unaffected (R11).

---

## R7. STEP B4 bond-to-component loops (FR-010 as amended)

**Decision**: `bonds2component(bmgEdgeIndex{i}) = i` and
`bonds2isomorphismClass(bmgEdgeIndex{conservedGroups(i)}) = bondSubsequentSubgraphIndices(i)`, as in the
prototype. `CBSubgrahs = BMG(conservedGroups)` is still built, because `identifyIsomorphicClasses` takes it.

**Equivalence**: the original assigns `repelem(v, n)'` to the same index set. Assigning a scalar
instead gives the same values, including when an index is repeated. MATLAB also grows the target vector
the same way in both forms if an `EdgeIndex` exceeds `nBonds`. The loop order is unchanged, so where
an index appears in more than one BMG the last write still wins.

---

## R8. Where the unit-test inputs come from without changing `src/` (FR-013)

**Problem**: `BIG` and `ATG` exist only inside `identifyConservedReactingMoieties`, at the stage-09 call
(line 847 on `develop`). Feature 029 needed a similar capture and used a temporary hook in `src/`
(029 research R10).

**Decision**: capture the inputs with a **conditional breakpoint**, so `src/` is never touched:
`dbstop in identifyConservedReactingMoieties at 847 if captureStageNineInputs(BIG, ATG)`. The helper
function saves its arguments and returns `false`, so execution never stops. This was checked in R2024b
`-batch` mode during planning with a small probe function: the variable was saved and the function
returned its normal result. The line number is looked up at capture time, by searching for
`[bondSubgraphs, BMG] = extractBondSubgraphs(BIG, ATG);`, and not hard-coded.

The capture script (`captureBondSubgraphReferences.m`, in this feature directory) runs **on the
unmodified `develop` code, before any source change**. It then:
1. calls the unmodified `extractBondSubgraphs(BIG, ATG)` and
   `findAndExtractMolecularGraphs(BIG, BMG, bondSubgraphs)` on the captured inputs;
2. builds small synthetic inputs that break each fallback precondition of R1: duplicated `AtomIndex`,
   non-whole `AtomIndex`, a `Component` label greater than `max(conncomp)`, a BIG with named nodes, and a
   BIG with zero edges. It records the unmodified function's outcome for each: the outputs, or the error
   identifier and message;
3. saves everything to `test/verifiedTests/analysis/testReactingMoieties/data/bondSubgraphReference.mat`.
   The CI fixture is 3 reactions, so the file is small (target: under 1 MB). It sits next to the existing
   tracked fixtures, and `.gitignore` does not exclude that `data/` folder.

**Alternatives considered**: 029's temporary hook (it works, but it edits `src/` and has to be reverted);
rebuilding `ATG` in the test (it would duplicate about 300 lines of the function's internals, which could
then drift); synthetic inputs only (US3 scenario 1 requires the CI fixture).

**Not testable through a small input**: the fallbacks of the in-function blocks (R4, R5, R6) cannot be
reached through the public `identifyConservedReactingMoieties` interface. The inputs that would reach them
(duplicated atom indices, `NaN` components, non-numeric atom indices) fail earlier sanity checks or earlier
stages. FR-007 asks for a test "where a small input can trigger it", so for these three fallbacks the
evidence is: (a) each `else` branch is the original loop verbatim, checked by `git diff` review; and
(b) the precondition expressions are listed in the contract. This is stated in the tasks and not hidden.
The empty-input, single-row and fallback behaviour of these three blocks is instead checked by T022's
synthetic section, on verbatim copies of the original and optimised blocks that are guarded against drift.

---

## R9. CI test design (FR-013, SC-003, Principle III and III-Naming)

**Decision**: add two files, one per function:
- `testExtractBondSubgraphs.m`: loads `bondSubgraphReference.mat` and, on the CI-fixture inputs, checks
  that `[bondSubgraphs, BMG]` equal the reference. It compares class, `Nodes` and `Edges` tables with
  `isequal` for every cell, using a local comparison function (not the prototype's `compareGraphCells`,
  which is not added to `src/`). It checks both arities, 2 and 3 outputs. With 3 outputs it checks that
  `sort(bmgEdgeIndex{m})` equals `sort(BMG{m}.Edges.EdgeIndex)` for every `m`. For each synthetic
  fallback case it checks that the outcome equals the captured one: the same outputs, or the same error
  identifier and message.
- `testFindAndExtractMolecularGraphs.m`: on the reference inputs, checks all six outputs against the
  reference (`isequal` for the groups; graph tables for the four graphs). It checks the 3-input form, the
  4-input form with the cache, and the 4-input form with `[]`.

Neither function uses a solver or a toolbox beyond base MATLAB graph functions, so the tests call
`prepareTest` with no solver requirement. That still follows the harness convention, and the tests run on
every CI runner. Output is silent, no warnings are suppressed, and `evalc` is not used (Principle VII-A/B).

---

## R10. Golden-snapshot reproducibility check (FR-011, FR-012, SC-001, SC-004, SC-006)

**Decision**: add `reactingOptimisationReproducibilityCheck.m` in this feature directory, following the
structure of 029's `vectorizationReproducibilityCheck.m`. It checks for a snapshot to decide between
CAPTURE and COMPARE, uses the same corpus and subsystem-model paths, has an append-only results file, can
be resumed fixture by fixture, and records corpus provenance and the git commit. It differs from 029 as
follows:

| Aspect | Decision |
|---|---|
| What is compared | `arm`, `moietyFormulae` and every field of `reacting`, with `isequaln` (FR-002). Mismatches are listed field by field. `isequaln` alone ignores class and sparsity (`isequaln(sparse(A), full(A))` is true), so the comparison also checks class, `issparse` and size on every field, recursively (FR-008). |
| Modes | `default` and `conservedOnly` (`options.conservedMoietiesOnly = 1`), both with `sanityChecks = 0`. There is also a `sanity` pass (`sanityChecks = 1`) on tyr, selected with an environment variable as in 029 (FR-002, US1 scenario 4). |
| Outcome recorded | Either the outputs or the thrown error (identifier, message, top stack frame). This is needed because `sanityChecks = 1` has a known crash that predates this feature (see `testConservedReactingMoieties.m`, the 027 comment). An identical error counts as a match. |
| Console output (SC-006) | One extra call per fixture and mode, recorded with `diary` into a temporary file, stored in the snapshot and compared exactly. `diary` records the output while leaving it on screen, which Principle VII-A/B requires; `evalc` would hide it. The function prints no timings (its only `toc` is inside `if 0`), so its output does not vary between runs. |
| Timing (FR-012) | Median of 3 whole-function runs, default mode, with `diary` off. The "before" median is stored in the snapshot at capture; "after" is measured at compare. The check fails if after > before on any fixture. Following the spec's Timing-noise assumption, the results file notes that such a failure must be re-measured before it is treated as a real regression. |
| Targeted-stage timing on bileacid (FR-012) | One separate run under the MATLAB **profiler** (not included in the medians). Line times include the time spent in called functions, and they are summed over marker-delimited blocks of `identifyConservedReactingMoieties.m`: stage 09 from `STEP B1` to `%map BIG to connected component`, stage 14/17 from `%Reacting bond graph` to `STEP 4`. The block limits are found by searching the file text at run time, so they hold when line numbers change. No stage timers are added to `src/`. Profiler overhead makes these figures relative, so they are reported and do not gate. |
| Solver | The MILP solver name (`CBT_MILP_SOLVER`) is recorded at capture. At compare, a different solver is reported as `SOLVER MISMATCH` and not as a code regression (spec edge case "Set-cover solver"). |
| Snapshot storage | `specs/<feature>/snapshots/<fixture>-<mode>-golden-snapshot.mat`. A file over 10 MB is written to `~/repos/reconXmoieties/.../reactingOptimisation/` with a `.external.txt` pointer instead, as in 029 R7. |
| Synthetic single-edge case (R5) | A synthetic section checks the stage-14b block on a hand-built RBG with exactly one edge. It runs the original block and the new block on the same RBG and compares `endNodesModified`, so the prototype's shape defect cannot come back. |

**Order is critical**: CAPTURE (snapshots, timings, console text) and `captureBondSubgraphReferences.m`
**must both run on unmodified `develop` code before any task edits `src/`**. The tasks phase has to put
them in a first phase that blocks everything else.

**Alternatives considered**: re-measuring "before" at compare time from a `git worktree` of `develop`
(more robust to machine load, but it needs two toolbox copies on the path and differs from 029's
pattern); reusing the prototype's `validateReactingOptimisation.m` directly (it calls the generated,
instrumented copies, which are not in this repository).

---

## R11. External-solver configuration audit (Principle IV)

The only external solver involved is the MILP behind `solveCobraMILP` in STEP 4 (minimum set cover). This
feature does not change that call, its options (`printLevel = 0`, everything else at the COBRA default),
or the problem it receives. `A = -CRB2R(activeBonds, :)`, and `CRB2R` is required to be identical in size,
non-zeros, values and sparsity (FR-008, R6), so the solver's input is byte-identical. No solver default is
re-examined because no solver input changes. The snapshots record which solver was used (R10), since a
different solver could return a different equally optimal cover.

---

## R12. MATLAB best-practice skill discovery (Principle VII-F)

No project skill for MATLAB coding conventions is registered. The only MATLAB-related skill is
`speckit-human-loop`, which uses the MATLAB MCP server for verification. The rules that apply here are
MathWorks guidance on indexing, `ismember`, `sparse` and `vertcat`: build a sparse matrix from triplets
rather than by indexed assignment in a loop; grow arrays with one `vertcat` of a cell array rather than
repeated concatenation; watch the shape of vector-indexing-vector results (R5); and use `ismember` with
its location output for lookups. The openCOBRA style guide takes precedence where they conflict
(Principle VII-G). As in earlier features, adding a project MATLAB-conventions skill is proposed as a
follow-up, not done here.

---

## R13. Candidate follow-up features (FR-010: recorded, not done)

- Atom transition graph stage (superlinear in the prototype's timings).
- Moiety transition graph stage and `addBondInfoToMTG`.
- `identifyIsomorphicClasses` on `CBSubgrahs`.
- `subgraph`/`addedge` construction inside `extractBondSubgraphs` (R1, alternatives).
- The per-reaction graph rebuild inside `buildAtomAndBondTransitionMultigraph`.
- The `sanityChecks = 1` crash in the conserved-only path, which predates this feature (documented in
  `testConservedReactingMoieties.m`).
