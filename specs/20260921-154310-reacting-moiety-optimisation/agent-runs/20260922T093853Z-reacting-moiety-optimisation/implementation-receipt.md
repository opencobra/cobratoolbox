# Implementation receipt: 20260921-154310-reacting-moiety-optimisation

## Prompt

`/speckit-implement` (no additional user input), run against the active feature
`specs/20260921-154310-reacting-moiety-optimisation/` (spec.md, plan.md, tasks.md; T001–T036).

## Final response

The speed-up of `identifyConservedReactingMoieties` is implemented, and it gives exactly the same results as before. The source changes aren't committed yet; only the pre-change snapshots were committed, before any code was touched (`4081fb6d1`).

**Results match (the main requirement):**
- All 16 comparisons against snapshots taken before the change are `EQUAL`: 7 subsystem fixtures plus the in-repo CI fixture, each in default and conserved-only modes. That covers `arm`, `moietyFormulae`, every field of `reacting` and the console output. The comparison also checks each field's type, sparsity and size, which a plain value comparison misses. `CRB2R` is still a sparse double.
- With `sanityChecks = 1`, `ci` and `tyr` raise the same error as before. That error is the known crash that predates this feature. For `tyr` it happens before any changed code, so that pairing doesn't test the rewrite.
- `testConservedReactingMoieties.m` passes and is unchanged from `develop`.
- A separate check runs copies of the old and new re-indexing and CRB2R code side by side on 10 edge cases: zero rows, one row, a missing bond, an untouched bond, and two inputs that force the fallback. All 10 match. The one-edge case is where the prototype was wrong, and it now matches.

**Speed-up (median of 3 runs, default mode):**

| Fixture | Reactions | Before | After | Speed-up |
|---|---|---|---|---|
| nglycan | 3 | 1.43 s | 1.12 s | 1.27× |
| phe | 14 | 2.75 s | 1.98 s | 1.39× |
| andest | 29 | 6.84 s | 4.70 s | 1.46× |
| chol | 61 | 19.56 s | 13.46 s | 1.45× |
| urea | 67 | 9.85 s | 6.30 s | 1.56× |
| tyr | 127 | 15.66 s | 9.54 s | 1.64× |
| bileacid | 145 | 45.96 s | 24.88 s | 1.85× |

No fixture got slower. On bileacid, under the profiler (relative figures), bond-subgraph extraction dropped from 42.3 s to 20.0 s, and the re-indexing and CRB2R blocks from 4.14 s to 0.06 s.

**What changed:**
- **`extractBondSubgraphs.m`:** each atom's component is now a direct lookup, and the edges still to process are read from arrays kept in step with each removal rather than rebuilt from the graph every step. There is a new optional third output, `bmgEdgeIndex`. The original algorithm is kept unchanged in a local function, which runs automatically for inputs the fast path can't handle.
- **`findAndExtractMolecularGraphs.m`:** each group's tables are joined in a single step instead of one subgraph at a time. There is a new optional fourth input, the edge-index cache from `extractBondSubgraphs`.
- **`identifyConservedReactingMoieties.m`:** four blocks only:
  - the two helper calls now pass the edge-index cache;
  - the two bond-to-component loops read that cache;
  - the reacting-bond and condensed reacting-bond graphs are re-indexed with `ismember`, and the condensed one gets a `reshape` for the one-edge case;
  - `CRB2R` is built from a sparse atom-to-reaction lookup, with a numeric-type check before the fast path.

  Each block keeps its original loop unchanged as a fallback.
- **New tests:** `testExtractBondSubgraphs.m` and `testFindAndExtractMolecularGraphs.m`, with the reference file `data/bondSubgraphReference.mat`. CI's test selection picks them up.

No existing error, warning, printed message or sanity check was removed or reworded. There are no `*Fast.m` files and no new options.

**Tests:** the CI test run that selects the tests relevant to this change gave 8 passed, 0 failed and 2 skipped. `testMoieties` and `testBiomassPrecursorCheck` were skipped because this machine has no Statistics Toolbox licence, which has nothing to do with this change.

**Not verified:**
- **Fallback branches in `identifyConservedReactingMoieties.m`:** the public function can't reach them. They rest on being unchanged copies of the original loops and on the 10-case side-by-side check.
- **Optional pufa timing (T029):** it takes up to 4 hours, so it wasn't run. Its task is left unchecked.
- **The full test suite:** it wasn't run; only the tests selected for this change were.

Full details are in `reacting-optimisation-reproducibility-results.md`, including the scope review, the timing table and suggested follow-ups.

## Diff summary

Source (`src/analysis/topology/reactingMoieties/`), not committed:
- `extractBondSubgraphs.m`: body rewritten; optional 3rd output `bmgEdgeIndex`; original algorithm kept word for word as the local fallback `extractBondSubgraphsByComponentScan`; `verLessThan` guard unchanged; help header updated.
- `findAndExtractMolecularGraphs.m`: body rewritten; optional 4th input `bmgEdgeIndex`, handled with `exist`/`isempty`; local function `assembleMolecularTransitionGraph`; help header updated.
- `identifyConservedReactingMoieties.m`: stage-09 call lines (847, 855); STEP B4 loops; stage 14a (`ismember`, original loop as fallback); stage 14b (`reshape` plus `ismember`, original loop as fallback); STEP 3 `CRB2R` (sparse incidence, original loop as fallback).

Tests (`test/verifiedTests/analysis/testReactingMoieties/`):
- new: `testExtractBondSubgraphs.m`, `testFindAndExtractMolecularGraphs.m` (not committed);
- new: `data/bondSubgraphReference.mat` (committed in `4081fb6d1`, captured from unmodified `src/`);
- unchanged: `testConservedReactingMoieties.m`.

Feature directory (`specs/20260921-154310-reacting-moiety-optimisation/`):
- committed in `4081fb6d1`: `captureStageNineInputs.m`, `captureBondSubgraphReferences.m`, `reactingOptimisationReproducibilityCheck.m` (at that commit), `snapshots/` (18 golden snapshots), and the results file (at that commit);
- modified since: `reactingOptimisationReproducibilityCheck.m` (T022 synthetic section), `reacting-optimisation-reproducibility-results.md`, `tasks.md` (checkboxes), `spec.md` (planning-phase amendments);
- planning artefacts, not committed: `plan.md`, `research.md`, `data-model.md`, `quickstart.md`, `contracts/`, `tasks.md`;
- this receipt.

Other: `CLAUDE.md` (plan pointer between the SPECKIT markers), `.specify/feature.json`.

## Tests

| Check | Result |
|---|---|
| T008 `testConservedReactingMoieties` on unmodified `src/` | PASS |
| T012 `testExtractBondSubgraphs`, `testFindAndExtractMolecularGraphs` on unmodified `src/` | PASS, PASS |
| T014 / T017 / T018 / T021 / T023: the three reacting-moiety tests after each rewrite step | PASS at every step |
| `testConservedReactingMoieties.m` unchanged (`git diff --quiet develop -- <file>`) | exit 0 |
| T018 partial COMPARE (ci, tyr, bileacid; default and conservedOnly) after the stage-09 edits | all EQUAL |
| T022 synthetic re-indexing section (10 cases) | 10/10 EQUAL |
| T024 full COMPARE (7 subsystem fixtures plus ci, default and conservedOnly) | 16/16 EQUAL (values, class, sparsity, size, console text); no fixture SLOWER |
| T025 sanity COMPARE (ci, tyr) | 2/2 EQUAL (same error outcome) |
| T026 static scope review | clean (see results file) |
| T032 `runTestSuite` with CI's selective filter | 8 passed, 0 failed, 2 skipped (no statistics_toolbox licence) |

## Unresolved issues

- T029 (optional pufa timing, up to 4 h) was not run; it was offered to the user. It is not a gate.
- The stage 14a, 14b and STEP 3 fallback branches cannot be reached through the public interface. They
  are covered only by the word-for-word-copy review and the T022 synthetic section (research R8).
- The `sanityChecks = 1` crashes that predate this feature remain (recorded as follow-ups; out of scope).
- The implementation is not committed. `src/`, the new tests and the planning artefacts await the
  user's commit.

## Other information

Environment: MATLAB R2024b Update 8, gurobi (MILP), Linux. Two MATLAB behaviours found during planning
were confirmed during implementation: a column vector indexed by a 1×2 index returns 2×1 (so stage 14b
needs the `reshape`), and `fix` of a cell array throws (so the CRB2R precondition needs `isnumeric`).
