# Quickstart: Validating the bond-transition node-identity index

**Feature**: `20260902-150020-eliminate-bond-transition-ismember-scans` | **Date**: 2026-09-02

## Prerequisites

* MATLAB R2024b+ with `initCobraToolbox` run, and any LP/MILP solver installed
  (`prepareTest('needsMILP', true)` is what `testConservedReactingMoieties.m` requires).
* This feature implemented per `plan.md` / `tasks.md`:
  `buildAtomAndBondTransitionMultigraph.m`'s bond-transition loop routed through the new
  `resolveAtomNodeIndex.m` helper and a once-built `dATMNodeIndexMap`
  (contracts/unchanged-public-contract.md).
* For the Tyrosine benchmark step only: the external model/RXN-file paths from `spec.md`'s
  Assumptions section (or their adjusted equivalents), consistent with features 021/022.

## 1. CI-covered correctness check (US1 Independent Test, SC-004)

```matlab
cd(fileparts(which('testConservedReactingMoieties')))
run('testConservedReactingMoieties.m')
```

**Expected**: passes with every existing assertion unchanged (diff
`test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m` against
its pre-feature version — no assertion added, removed, or altered, per SC-004).

## 2. New unit test for the extracted lookup helper (US2 Independent Test, SC-006)

```matlab
cd(fileparts(which('testResolveAtomNodeIndex')))
run('testResolveAtomNodeIndex.m')
```

**Expected**: passes, covering all three paths of `resolveAtomNodeIndex`'s contract
(contracts/unchanged-public-contract.md):
* a synthetic `nodeTable`/`nodeIndexMap` with a unique matching key returns the expected
  `atom`/`atomIndex` pair;
* a synthetic `nodeIndexMap` with no row for the requested key raises
  `resolveAtomNodeIndex:missingNodeIdentity` (Acceptance Scenario US2-2);
* a synthetic `nodeIndexMap` with two rows sharing the same key raises
  `resolveAtomNodeIndex:ambiguousNodeIdentity` (Acceptance Scenario US2-1).

## 3. Direct before/after comparison on an existing atom-mapped reaction (US1 Acceptance Scenario 1)

```matlab
% Pick any existing atom-mapped RXN file feeding a reaction with >=1 bond-transition.
[dATMBefore, ~, ~, ~, ~, ~, ~, dBTMBefore] = buildAtomAndBondTransitionMultigraph(model, RXNFileDir, options); % pre-change checkout
[dATMAfter,  ~, ~, ~, ~, ~, ~, dBTMAfter]  = buildAtomAndBondTransitionMultigraph(model, RXNFileDir, options); % post-change checkout
assert(isequal(dBTMBefore.Edges.HeadBondHeadAtom, dBTMAfter.Edges.HeadBondHeadAtom));
assert(isequal(dBTMBefore.Edges.HeadBondTailAtom, dBTMAfter.Edges.HeadBondTailAtom));
assert(isequal(dBTMBefore.Edges.TailBondHeadAtom, dBTMAfter.Edges.TailBondHeadAtom));
assert(isequal(dBTMBefore.Edges.TailBondTailAtom, dBTMAfter.Edges.TailBondTailAtom));
assert(isequal(dBTMBefore.Edges.HeadBondHeadAtomIndex, dBTMAfter.Edges.HeadBondHeadAtomIndex));
assert(isequal(dBTMBefore.Edges.HeadBondTailAtomIndex, dBTMAfter.Edges.HeadBondTailAtomIndex));
assert(isequal(dBTMBefore.Edges.TailBondHeadAtomIndex, dBTMAfter.Edges.TailBondHeadAtomIndex));
assert(isequal(dBTMBefore.Edges.TailBondTailAtomIndex, dBTMAfter.Edges.TailBondTailAtomIndex));
assert(isequal(dATMBefore.Nodes, dATMAfter.Nodes));
```

**Expected**: all assertions pass.

## 4. Scope-boundary check

```bash
git diff --name-only master... -- src/ test/ | \
  grep -v -E "src/analysis/topology/reactingMoieties/(buildAtomAndBondTransitionMultigraph|resolveAtomNodeIndex)\.m|test/verifiedTests/analysis/testReactingMoieties/testResolveAtomNodeIndex\.m"
```

**Expected**: empty output — no `src/`/`test/` file outside the two named source files and
the one new test file was touched, including everything already addressed by features
019-022.

## 5. Tyrosine benchmark reproducibility check (FR-007, FR-008, SC-001, SC-002, SC-003, SC-005; non-CI)

This step has a multi-minute runtime and depends on external model/RXN-file paths not
shipped in-repo — it is documented, not automated in CI (Principle III's
reproducibility-check fallback), consistent with features 021/022.

```matlab
% BEFORE implementing this feature (run once, on the pre-change code):
run('specs/20260902-150020-eliminate-bond-transition-ismember-scans/tyrosineReproducibilityCheck.m')
% -> writes specs/20260902-150020-eliminate-bond-transition-ismember-scans/tyrosine-golden-snapshot.mat

% AFTER implementing this feature:
run('specs/20260902-150020-eliminate-bond-transition-ismember-scans/tyrosineReproducibilityCheck.m')
% -> re-runs the pipeline, asserts arm.L / moietyFormulae / reacting.selectedReactionNames
%    equal the golden snapshot, and appends before/after cell.ismember /
%    tabular.dotReference call counts, their percentage reduction from the pre-feature-022
%    baselines, and wall-clock time to
%    specs/20260902-150020-eliminate-bond-transition-ismember-scans/tyrosine-reproducibility-results.md
```

**Expected**:
* `arm.L`, `moietyFormulae`, `reacting.selectedReactionNames` byte-identical to the golden
  snapshot (SC-003).
* Post-change total pipeline `cell.ismember` call count <=50,853 (<=10% of the
  pre-feature-022 baseline of 508,534) (SC-001).
* Post-change `tabular.dotReference` call count <=559,028 (<=30% of the pre-feature-022
  baseline of 1,863,426) (SC-002).
* Total pipeline wall-clock time on the Tyrosine benchmark does not regress relative to the
  post-feature-022 baseline of 55.0s (SC-005; a further reduction is expected but not
  gated).

## 6. Manual edge-case spot checks (Edge Cases)

* **Reaction with zero bond-transitions**: no repo fixture with a confirmed
  zero-bond-transition reaction is currently identified for this check. Before treating
  this sub-check as executed, either (a) locate an existing atom-mapped RXN file in
  `test/models/` (or the Tyrosine benchmark's own RXN-file directory) whose reaction has
  only atom-level changes and no bond transitions, and run
  `buildAtomAndBondTransitionMultigraph` on a model including it — it must complete
  without error, with `dATMNodeIndexMap` built but never queried that iteration — or (b)
  if no such fixture exists in the corpus, verify this edge case by code inspection instead
  (`dATMNodeIndexMap`'s construction in T005 has no dependency on any bond-transition
  existing, and the `for j = 1:max(bondMappings.bondTransitionNrs)` loop simply does not
  execute when a reaction has none), consistent with the spec's own Assumptions-section
  allowance for review-based verification where direct MATLAB execution of a specific
  scenario is not readily available.

  ```matlab
  [atoms, bonds] = readABRXNFile(zeroBondTransitionRxnfileName, RXNFileDir); % substitute a real fixture path here
  % (exercised indirectly via buildAtomAndBondTransitionMultigraph on a model including this
  % reaction — must complete without error.)
  ```

* **Duplicate or missing composite atom-identity key** (synthetic, via
  `testResolveAtomNodeIndex.m`): MUST raise `resolveAtomNodeIndex:ambiguousNodeIdentity` /
  `:missingNodeIdentity` respectively, not silently produce a wrong or empty match (see
  step 2 — this sub-check is fully executable as written, unlike the zero-bond-transition
  one above).

**Expected**: both checks behave as specified (Edge Cases, Acceptance Scenarios US1-4,
US2-1, US2-2).
