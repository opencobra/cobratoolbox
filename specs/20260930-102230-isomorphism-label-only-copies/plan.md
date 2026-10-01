# Implementation Plan: Classify isomorphism on label-only copies

**Branch**: `20260930-102230-isomorphism-label-only-copies` | **Date**: 2026-09-30 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/20260930-102230-isomorphism-label-only-copies/spec.md`

## Summary

`classifySubgraphIsomorphism` spends most of its time in `isisomorphic` re-reading label variables from full node and edge tables: 273 s of 603 s profiled. The fix is to build, once per subgraph, a copy with the same class, nodes and edges (directions, parallel edges, self-loops) that carries only the requested `NodeVariables`/`EdgeVariables`, and to compare the copies. Research found:
- identical classifications in 240 random cases and on the real 1,960-reaction components;
- identical errors;
- 212 s → 24 s on the largest call site.

The invariants, the candidate pairs and the call count are unchanged. The three callers are not edited.

## Technical Context

**Language/Version**: MATLAB R2024b Update 8.

**Primary Dependencies**: base MATLAB `graph`/`digraph`/`isisomorphic`. No solver change.

**Storage**:
- **CI data**: `test/verifiedTests/analysis/testReactingMoieties/data/classifySubgraphIsomorphismReference.mat`, the expected classifications from `f4a62639e`.
- **Local data**: the existing 1,960-reaction captures of the previous two features.

**Testing**:
- `testClassifySubgraphIsomorphism.m` is extended (III-Naming).
- `testConservedReactingMoieties.m` is unchanged, and its golden comparison covers all three callers.
- There is a non-CI check script in this directory.

**Target Platform**: headless Linux.

**Project Type**: scientific MATLAB library.

**Performance Goals**:
- **SC-003 (gate)**: median of 5 runs ≤ 0.60 on the 1,960-reaction model.
- **SC-002 (reported)**: the component classification ≤ 0.20 of its old time. Research measured 0.111.

**Constraints**:
- Outputs are identical (`isequal`/`isequaln`).
- Errors are identical.
- No message changes.
- Memory is linear, with one copy per subgraph.

**Scale/Scope**: one source file, `classifySubgraphIsomorphism.m` (151 lines). The call sites classify 39,916, about 45,000 and about 45,000 subgraphs on the 1,960-reaction model.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Scientific code quality**: no algorithm change: the same invariants, pair order and class numbering. The signature and outputs are unchanged (Principle II). **PASS**
- **Testing and reproducibility**:
  - **CI**: expected classifications captured before the edit, for all three modes, `graph`/`digraph`, multigraphs, self-loops, the error cases and the call count.
  - **Non-CI**: the 1,960-reaction equality and gate, and the 8-subsystem check.

  **PASS**
- **User experience and diagnostics**: no message changes. The diagnostic call counter is unchanged. **PASS**
- **Performance and numerical integrity**: outputs are discrete class indices, compared with `isequal`, and performance is subordinate to correctness. **PASS**
- **External-solver configuration audit**: N/A. The graph-library behaviours are audited in R6. **PASS**
- **Spec-driven scope control**:
  - **Edited**: `src/analysis/topology/reactingMoieties/classifySubgraphIsomorphism.m` only: the invariant loop, the `isisomorphic` call, one local function and the `NOTE` block.
  - **Read-only**: its callers, every other `src/` file, and `external/`.

  **PASS**
- **MATLAB coding standards**:
  - no `evalc`, warning suppression, `nargin` or new `try/catch`;
  - openCOBRA header (VII-E);
  - VII-F practice notes from `specs/20260928-100409-…/matlab-practice-notes.md` applied.

  **PASS**
- **Parameter-setting fidelity**: N/A.
- **Artifact placement**:
  - **Source**: edited in place.
  - **CI data**: beside its test.
  - **Scripts, results, and the baseline copy**: in this directory. The baseline copy goes in `baseline/classifySubgraphIsomorphism.m`, and is put on the path only during baseline timing runs.

  **PASS**

**Post-design re-check**: all PASS. There are no new source files, no new public surface and no new dependencies.

## Design

In `classifySubgraphIsomorphism.m`:
1. Add `labelOnlySubgraphs = cell(numSubgraphs, 1);` beside the invariant arrays.
2. At the end of the existing invariant loop body, after `nodeLabels{i}`/`edgeLabels{i}` are read, set `labelOnlySubgraphs{i} = labelOnlyCopy(subgraphs{i, 1}, nodeVarName, edgeVarName);`. Placing it after the reads keeps every existing error at the same point (research R3).
3. In the pair loop, change `isisomorphic(subgraphs{i, 1}, subgraphs{j, 1}, varargin{:})` to `isisomorphic(labelOnlySubgraphs{i}, labelOnlySubgraphs{j}, varargin{:})`.
4. Add the local function `labelOnlyCopy(G, nodeVarName, edgeVarName)`, as specified in research R2.
5. Update the `NOTE` block to describe the label-only comparison, and add a provenance line.

**Baseline timing without editing callers**: `FEATURE/baseline/classifySubgraphIsomorphism.m` is a verbatim copy of `f4a62639e`'s helper. The check script alternates as follows:
1. `addpath(baselineDir, '-begin')`, then run `identifyConservedReactingMoieties`, which now resolves the baseline helper.
2. `rmpath(baselineDir)`, then run it again, which resolves the new helper.

It asserts which file is active before each run, using `which('classifySubgraphIsomorphism')`.

## Project Structure

### Documentation (this feature)

```text
specs/20260930-102230-isomorphism-label-only-copies/
├── spec.md, plan.md, research.md, data-model.md, quickstart.md
├── contracts/classifySubgraphIsomorphism.md
├── checklists/requirements.md
├── research-prototype/{probeIsomorphismLabels.m, probeLabelOnly2.m, classifySubgraphIsomorphismLabelOnly.m}
├── baseline/classifySubgraphIsomorphism.m      # NEW — verbatim f4a62639e helper (timing baseline only)
├── captureClassifyReference.m                  # NEW — CI expected classifications from unchanged helper
├── isomorphismLabelOnlyCheck.m                 # NEW — n1960 classification equality + call count, end-to-end equality, median-of-5 gate
├── isomorphismLabelOnlyResults.md              # NEW — generated
└── tasks.md
```

### Source Code (repository root)

```text
src/analysis/topology/reactingMoieties/
└── classifySubgraphIsomorphism.m               # MODIFIED — label-only copies for isisomorphic; NOTE

test/verifiedTests/analysis/testReactingMoieties/
├── testClassifySubgraphIsomorphism.m           # MODIFIED — reference cases, errors, call count
└── data/classifySubgraphIsomorphismReference.mat   # NEW
```

**Structure Decision**: the single toolbox layout. There is one edited source file, and the test data sits beside the tests.

## Implementation order (for `/speckit-tasks`)

1. **Baseline copy and CI reference capture, on unchanged `src/`**. The capture script is guarded by `git diff --quiet f4a62639e -- <helper>`.
2. **Extend `testClassifySubgraphIsomorphism` and run it**. It must pass on the unchanged helper.
3. **Check script and self-check on unchanged `src/`**: equality, and call count 39,204 at the component call site.
4. **Edit the helper** (Design steps 1–5). Then run `testClassifySubgraphIsomorphism`, `testConservedReactingMoieties` and the check script (equality only).
5. **Gate**: 5 alternating runs.
6. **Final checks**:
   - the 8-subsystem check;
   - all `testReactingMoieties` tests;
   - static review;
   - quickstart run;
   - report and receipt.

## Complexity Tracking

No constitution violations; no entries.
