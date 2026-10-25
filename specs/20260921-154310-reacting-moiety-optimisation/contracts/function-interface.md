# Interface Contract: identifyConservedReactingMoieties, extractBondSubgraphs, findAndExtractMolecularGraphs

This is the Principle II contract surface for this feature. The public function is **unchanged**. The two
helper functions each gain one optional argument, and callers that do not use it are unaffected.

## Signatures

```matlab
% unchanged
[arm, moietyFormulae, reacting] = identifyConservedReactingMoieties(model, BG, dATM, options)

% unchanged 2-output form; new optional 3rd output
[bondSubgraphs, BMG] = extractBondSubgraphs(BIG, ATG)
[bondSubgraphs, BMG, bmgEdgeIndex] = extractBondSubgraphs(BIG, ATG)

% unchanged 3-input form; new optional 4th input
[CMTG, RMTG, CMG, RMG, conservedGroup, reactingGroups] = findAndExtractMolecularGraphs(BIG, BMG, bondSubgraphs)
[CMTG, RMTG, CMG, RMG, conservedGroup, reactingGroups] = findAndExtractMolecularGraphs(BIG, BMG, bondSubgraphs, bmgEdgeIndex)
```

- No option field is added to `identifyConservedReactingMoieties`, and no option selects the old or new
  code (FR-010).
- `bmgEdgeIndex` (4th input) follows the VII-D pattern: `if ~exist('bmgEdgeIndex', 'var') || isempty(bmgEdgeIndex)`,
  then it is built from `BMG{m}.Edges.EdgeIndex`. Omitting it and passing `[]` behave the same.
- Help headers (VII-E): `extractBondSubgraphs` gets an `OPTIONAL OUTPUT:` block for `bmgEdgeIndex`, and
  `findAndExtractMolecularGraphs` an `OPTIONAL INPUT:` block. Each gets a `NOTE:` that the result is
  identical to the pre-change algorithm and that the original algorithm runs when the fast path's
  preconditions fail. No agent-specific wording goes in the headers (Principle X).

## Behavioural contract

| Surface | Contract | Requirement |
|---|---|---|
| `arm`, `moietyFormulae`, every field of `reacting` | `isequaln` to the pre-change function, in `default`, `conservedMoietiesOnly = 1` and `sanityChecks = 1` modes; when the pre-change function raised an error, the same error | FR-001, FR-002, SC-001 |
| `bondSubgraphs`, `BMG` | For each cell: same class, `isequal` `Nodes` and `Edges` tables, same cell order | FR-003 |
| `bmgEdgeIndex{m}` | Same **set** as `BMG{m}.Edges.EdgeIndex`; the order is unspecified (construction order) | FR-003, research R2 |
| six outputs of `findAndExtractMolecularGraphs` | `isequal` groups; `isequal` `Nodes`/`Edges` for the four graphs; the same whether the cache is given or not | FR-004 |
| `CRB2R` | Same size, non-zeros, values (all `1`), and `issparse` | FR-008 |
| `BondIndex %d not found.` | Emitted under the same conditions, with the same text, in the same order | FR-008, FR-009 |
| Every `error`, `warning`, `fprintf` and sanity check in the three files | Unchanged in text and firing conditions; `git diff` must show none of them removed or edited. `verLessThan` and its error in `extractBondSubgraphs` are kept | FR-009, SC-005 |
| Console output of the whole function | Identical text on every covered fixture | SC-006 |

## Fast-path preconditions and fallbacks (FR-007)

When a precondition fails, the original algorithm runs and gives the original result, or raises the
original error.

| Block | Fast path requires | Fallback | Test that reaches the fallback |
|---|---|---|---|
| `extractBondSubgraphs` | `AtomIndex` numeric, positive, whole and unique; `Component` whole, in `1..max(conncomp)`; `BIG.Edges.EndNodes` numeric, positive, whole, `<= max(AtomIndex)`, each mapped to a component | local function holding the original body; with 3 outputs, `bmgEdgeIndex` is built from its `BMG` | `testExtractBondSubgraphs.m` synthetic cases |
| `extractBondSubgraphs`, zero edges | (special case) | returns `{}`, `{}`, `{}` directly, as the original's loop is never entered | `testExtractBondSubgraphs.m` `zeroBIGEdges` |
| Stage 14a (RBG) | `nodeTable.AtomIndex` unique; every endpoint found (`ismember` location > 0) | original per-edge `find` loop, verbatim | not reachable through the public interface (research R8); checked by `git diff` review |
| Stage 14b (Condensed_RBG) | `RBG.Edges.EndNodes` numeric; no location `0` | original nested loop, verbatim | not reachable through the public interface; the one-edge shape case is checked by the synthetic section of the reproducibility check (research R5) |
| STEP 3 (`CRB2R`) | `atom1_all`, `atom2_all`, `headATM`, `tailATM` numeric, whole, positive; `bondIdx` whole, in `1..maxBondIndex` | original per-bond loop, verbatim | not reachable through the public interface; checked by `git diff` review |

## Behaviour deliberately preserved, not repaired

- The crash with `sanityChecks = 1` in the conserved-only path, which predates this feature (documented in
  `testConservedReactingMoieties.m`), is reproduced, not fixed. The snapshot records the error, and the
  comparison requires the same error.
- The original's in-loop `if ~isempty(idx)` in stage 14b cannot be reached when `NewId = 1:n`. No
  behaviour depends on it, and the fallback keeps it.
