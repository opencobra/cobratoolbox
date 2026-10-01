# Contract: `classifySubgraphIsomorphism` (unchanged interface)

```matlab
[isomorphismClasses, firstSubgraphIndices, subsequentSubgraphIndices] = classifySubgraphIsomorphism(subgraphs, varargin)
classifySubgraphIsomorphism('resetCallCount')
n = classifySubgraphIsomorphism('getCallCount')
```

## Unchanged (FR-001, FR-002, FR-004, FR-005)

- **Outputs**: for every input, all three outputs are `isequal` to those at commit `f4a62639e`.
- **Candidate pairs and call count**: the candidate pairs, their order and the diagnostic call count are the same.
- **Errors**:
  - `MATLAB:table:UnrecognizedVarName` for a missing label variable;
  - `MATLAB:table:IllegalVarSubscript` for a cell-valued option;
  - `classifySubgraphIsomorphism:UnknownAction`.

  Each keeps its identifier and message, and is raised at the same point: the invariant loop, before any comparison.
- **Callers**: `identifyConservedReactingMoieties` (`'NodeVariables', 'mets'`), `identifyIsomorphicClasses` (`'EdgeVariables', 'mets'`) and `findAndExtractMolecularGraphs` (plain) are not edited.

## Changed internally (FR-003)

Each `isisomorphic` call compares **label-only copies** of the two subgraphs, built once per subgraph in the invariant loop. Each copy:
- has the same class (`graph`/`digraph`) and `numnodes`;
- has `EndNodes` equal to `G.Edges.EndNodes` row for row, keeping directions, parallel edges and self-loops;
- carries only the parsed `NodeVariables` name as a node variable and the parsed `EdgeVariables` name as an edge variable, and nothing when neither is given.

This is not observable outside the helper: the copies are never returned.
