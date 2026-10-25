# Public Interface Contract: identifyConservedReactingMoieties and createBIGraph

This is the library's public contract surface for this feature (Constitution Principle II).
Both contracts are **unchanged**. This file exists to state precisely what "unchanged" means
here, because the entire feature is an internal rewrite behind these two signatures.

## Signatures (unchanged)

```matlab
[arm, moietyFormulae, reacting] = identifyConservedReactingMoieties(model, BG, dATM, options)
BIG = createBIGraph(BG)
```

No change to function names, argument order, arity, option fields, or return values (FR-004,
FR-005, SC-006). No help-header content changes, since nothing documented about behaviour
changes.

## Behavioural contract

| Surface | Contract |
|---|---|
| `ATM.Edges` after stage02 | Byte-identical (`isequal`) to the pre-change implementation for `Trans`, `HeadAtomIndex`, `TailAtomIndex`, `HeadAtom`, `TailAtom`, in the same row order (FR-001) |
| All other `ATM.Edges` columns, `nTransInstances`, `orientationATM2dATM` | Unmodified by the rewrite (FR-002) |
| `BIG.Nodes`, `BIG.Edges` | Byte-identical (`isequal`) to the pre-change implementation, including `Weight` (always 1 per instance) and `EdgeIndex`, for every property column present in `BG.Edges` (FR-003) |
| `arm`, `moietyFormulae`, `reacting` | Unchanged — both hotspots run upstream of every output-producing step, so identical intermediates imply identical outputs |
| `createBIGraph` callers | Exactly one production caller (`identifyConservedReactingMoieties.m:566`), unchanged; no new caller under `src/` (FR-008). Test and validation callers (`testCreateBIGraph.m`, the reproducibility harness) are permitted |
| Existing guards | The `sanityChecks` block after stage02 and `if ~isequal(BIG.Nodes, dATM.Nodes)` after the `createBIGraph` call must keep passing, unmodified and not weakened (FR-006) |

## Behaviour deliberately preserved, not repaired

Two pre-existing behaviours are inside the rewritten regions and are preserved exactly. Both
would be *changes* to the contract if "fixed" here, so both are out of scope (Principle VI —
each would need its own spec):

1. **`orientation == 0` rows take the reverse branch** when `options.sanityChecks` is `0`
   (research.md R1). The rewrite reproduces this, rather than treating `0` as an error or a
   no-op.
2. **Edge properties are assigned positionally after `addedge`**, which sorts by
   (source, target) (research.md R5, verified by MATLAB probe). This is safe only because
   `BG.Edges` arrives sorted. The rewrite keeps the same construction sequence and the same
   dependence on that input invariant.

## The one deliberate behaviour change

**Zero-edge input to `createBIGraph`** (no edges remain after the energy node is removed). Before this feature, the function crashed (`MATLAB:table:UnrecognizedVarNameDeleting`, `createBIGraph.m` line 81), because assigning `[]` to a table column deletes it. After this feature, it returns `BIG` with the non-energy nodes and a zero-row `Edges` table. This is the sole exception to the byte-identical rule above (spec FR-003, Clarifications): the old behaviour produced no output to be identical to. Pinned by `testCreateBIGraph.m` case (e).

## Performance (not part of the contract, but the reason for the change)

`tyr` fixture: ≥100x for stage02, ≥200x for `createBIGraph` (SC-004), measured with temporary
instrumentation that is reverted before commit. Performance is reported in the results file;
it is not asserted by any CI test and is subordinate to the `isequal` bar above.
