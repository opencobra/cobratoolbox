# MATLAB practice notes (Constitution VII-F): T005

**Skill search**: `.claude/skills/` has 13 entries, all Spec Kit commands. None covers MATLAB conventions or linting (`ls .claude/skills | grep -iE 'matlab|lint|style'` finds nothing). Per VII-F, the relevant MathWorks guidance is summarised below, and a project skill is proposed.

## Rules that apply to this change

Sources: MathWorks "Techniques to Improve Performance", "Preallocation", "Vectorization", and the `graph`/`digraph` reference pages; openCOBRA style guide (VII-G).

1. **Preallocate** arrays whose final size is known: `remaining = true(nEdges, 1)` and the `localPos` scratch vectors. Growing cells in the output loop (`bondSubgraphs{subgraphIndex, 1} = …`) is left as it was, to keep FR-007/FR-002 and the existing `%#ok<AGROW>` markers.
2. **Read graph properties once.** `G.Edges` and `G.Nodes` are dependent properties that build and return a full `table` on every access. Inside a loop over passes, reading them costs time proportional to the whole graph. Cache them in local variables before the loop.
3. **Avoid `ismember` over large sets inside loops.** Use logical masks (`remaining(rows) = false`) and direct index maps (`localPos(atoms) = 1:n`, reset afterwards) for pair-sized lookups.
4. **Vectorise one-time index construction** with `unique(…, 'rows')`, `accumarray(…, @(v) {sort(v)})` and `sparse`, not per-edge loops.
5. **`sortrows` on numeric matrices** is a stable, ascending, lexicographic sort, so a trailing original-row column gives deterministic tie-breaking (research R1).
6. **Table subscripting** (`T(rows, :)`) is costlier than numeric indexing. It is acceptable here because it is pair-sized and needed to produce the output tables unchanged.
7. **No Python-style refactors**: keep the MATLAB idioms of the surrounding code (1-based indexing, column vectors, `end` blocks, `camelCase`, comments in the existing density).
8. **openCOBRA (VII-G)**: spaces around operators and after commas; `if singleCondition` without parentheses; help header keywords (VII-E); no absolute paths inside functions.

## Proposal

Add a project skill, `.claude/skills/matlab-conventions/`, that captures rules 1–8 plus the constitution's VII-A to VII-G. Future features could then load it instead of repeating this search. This is a proposal only; it is not part of this feature.
