# Quickstart: Validating the table-object hotspot elimination

**Feature**: `022-eliminate-table-object-hotspots` | **Date**: 2026-09-02

## Prerequisites

* MATLAB R2024b+ with `initCobraToolbox` run, and any LP/MILP solver installed
  (`prepareTest('needsMILP', true)` is what `testConservedReactingMoieties.m` requires).
* This feature implemented per `plan.md` / `tasks.md`: `readABRXNFile.m`'s per-bond loop
  routed through a once-built lookup (contracts/unchanged-public-contracts.md), and
  `buildAtomAndBondTransitionMultigraph.m`'s two `EdgeTable`-building loops routed through
  plain-array accumulators.
* For the Tyrosine benchmark step only: the external model/RXN-file paths from `spec.md`'s
  Assumptions section (or their adjusted equivalents).

## 1. CI-covered correctness check (US1 + US2 Independent Test, FR-009, SC-001)

```matlab
cd(fileparts(which('testConservedReactingMoieties')))
run('testConservedReactingMoieties.m')
```

**Expected**: passes with every existing assertion unchanged (diff
`test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m` against
its pre-feature version — only non-assertion lines, if any, may differ, per SC-001).

## 2. Direct readABRXNFile before/after comparison (US1 Independent Test, FR-002)

```matlab
% Pick any existing atom-mapped RXN file with more than one bond.
[atomsBefore, bondsBefore] = readABRXNFile(rxnfileName, rxnfileDirectory); % pre-change checkout
[atomsAfter,  bondsAfter]  = readABRXNFile(rxnfileName, rxnfileDirectory); % post-change checkout
assert(isequal(bondsBefore.headAtomTransitionNrs, bondsAfter.headAtomTransitionNrs));
assert(isequal(bondsBefore.tailAtomTransitionNrs, bondsAfter.tailAtomTransitionNrs));
assert(isequal(bondsBefore.headAtomElements, bondsAfter.headAtomElements));
assert(isequal(bondsBefore.tailAtomElements, bondsAfter.tailAtomElements));
```

**Expected**: all four assertions pass (Acceptance Scenario 1).

## 3. Scope-boundary check (SC-006)

```bash
git diff --name-only master... -- src/ | \
  grep -v -E "src/analysis/topology/reactingMoieties/(readABRXNFile|buildAtomAndBondTransitionMultigraph)\.m"
```

**Expected**: empty output — no `src/` file outside
`src/analysis/topology/reactingMoieties/{readABRXNFile.m,
buildAtomAndBondTransitionMultigraph.m}` was touched, including
`addBondMappingsRXNFile.m`'s own internal redundant `readABRXNFile` call (FR-011,
out of scope) and everything already covered by feature 021.

## 4. Tyrosine benchmark reproducibility check (FR-010, SC-002, SC-003, SC-004, SC-005; non-CI)

This step has a multi-minute runtime and depends on external model/RXN-file paths not
shipped in-repo — it is documented, not automated in CI (Principle III's
reproducibility-check fallback).

```matlab
% BEFORE implementing this feature (run once, on the pre-change code):
run('specs/022-eliminate-table-object-hotspots/tyrosineReproducibilityCheck.m')
% -> writes specs/022-eliminate-table-object-hotspots/tyrosine-golden-snapshot.mat

% AFTER implementing this feature:
run('specs/022-eliminate-table-object-hotspots/tyrosineReproducibilityCheck.m')
% -> re-runs the pipeline, asserts dATM.Nodes/dATM.Edges/dBTM.Nodes/dBTM.Edges and the
%    sampled atoms/bonds tables equal the golden snapshot, and appends before/after
%    cell.ismember / tabular.dotAssign / tabular.dotReference call counts and wall-clock
%    time to specs/022-eliminate-table-object-hotspots/tyrosine-reproducibility-results.md
```

**Expected**:
* `dATM.Nodes`, `dATM.Edges`, `dBTM.Nodes`, `dBTM.Edges`, and the sampled `atoms`/`bonds`
  tables identical to the golden snapshot (SC-005).
* Post-change `cell.ismember` call count attributable to `readABRXNFile` +
  `buildAtomAndBondTransitionMultigraph` at least 90% lower than the pre-change baseline
  (508,474) (SC-002).
* Post-change `tabular.dotAssign` and `tabular.dotReference` call counts attributable to the
  same two functions each at least 70% lower than their pre-change baselines (717,081 and
  1,189,438 respectively) (SC-003).
* Wall-clock time for the parsing/graph-building portion reported before and after,
  averaged over at least 2 runs, not itself a pass/fail gate (SC-004).

## 5. Manual edge-case spot checks (Edge Cases)

```matlab
% Zero-bond RXN file: no indexing error, trivial bonds table.
[atoms, bonds] = readABRXNFile(zeroBondRxnfileName, rxnfileDirectory);
assert(height(bonds) == 0);

% Duplicate (met, metNr, instance) key or a bond referencing a non-existent atom: MUST
% still error (same as today), not silently produce a wrong or empty match.
try
    readABRXNFile(malformedRxnfileName, rxnfileDirectory);
    error('Expected an error for malformed/duplicate-key input, but none was thrown.');
catch ME
    disp(getReport(ME)); % confirm this is the same error class as the pre-change code
end
```

**Expected**: both checks behave identically to the pre-change implementation (Edge Cases,
Acceptance Scenarios 3-4).
