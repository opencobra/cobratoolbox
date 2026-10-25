# Data Model: per-edge and per-component table hotspots

All structures are local to one call of `identifyConservedReactingMoieties`. The outputs are unchanged.

## E1. ATG (atom transition graph, `graph`)

- **Nodes**: `Atom`, `AtomIndex` (`1..nAtoms` in the pipeline), `mets`, `AtomNumber`, `Element`, then `MoietyIndex`, `Component`, `IsomorphismClass` and `IsCanonical`, added during the function.
- **Edges**: 19 variables at line 847, including `EndNodes`, `Trans` (cell), `HeadAtomIndex`/`TailAtomIndex` (double), `HeadAtom`/`TailAtom` (cell) and `orientationATG2dATM` (double).

## E2. Reorientation mask (Story 1)

`orientationATG2dATM == -1`, a logical vector with one entry per transition (19,952 of 101,792 true on n1960).

**State change**: on masked rows only, head and tail are swapped for the atom index, the atom label and `Trans = [head '#' tail]`. No other row or variable changes.

## E3. Node partition → part subgraphs (Stories 2 and 3; helper `extractPartitionSubgraphs`)

| Use | Graph | Labelling | Edge mask | Parts | Consumers |
|---|---|---|---|---|---|
| Component subgraphs, first set (line 591) | ATG | `atoms2component` (from `conncomp`, `1..nComps`) | none | 39,916 | `classifySubgraphIsomorphism` (mets), `compElements`, component/class maps (`AtomIndex`, `TransIndex`) |
| Component subgraphs, second set (line 1040) | ATG with the added columns | the same | none | 39,916 | moiety-index propagation; `sanityChecks` mets |
| Moiety graphs `MG` → `arm.MG` (line 1150) | ABG | `ABG.Nodes.MoietyIndex` | `MoietyBondIndex` equals both end nodes' `MoietyIndex` | 30,999 | output `arm.MG` |

**Invariant**: `parts{k}` is identical to the pre-change `subgraph`-based result for the k-th ascending label (contract).

## E4. Moiety-index propagation (Story 2)

- **Inputs**:
  - `I2C` (sparse, classes × components);
  - `firstSubgraphIndices`;
  - the second-set subgraphs;
  - `ATG.Nodes.MoietyIndex`, where the canonical atoms are already numbered.
- **Step 1**: for each class `i`, the members `find(I2C(i,:) == 1)`, ascending, other than the first, get `Nodes.MoietyIndex` = the first member's.
- **Step 2**: for each non-first component `c`, `ATG.Nodes.MoietyIndex(nodesOfComponent{c}) = subgraphs{c}.Nodes.MoietyIndex`, valid when `AtomIndex` is unique. Otherwise the original `ismember` loop runs.
- **Output**: `ATG.Nodes.MoietyIndex` and the second-set subgraphs, identical to pre-change.
