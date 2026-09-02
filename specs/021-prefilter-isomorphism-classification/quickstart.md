# Quickstart: Validating the isomorphism prefilter

**Feature**: `021-prefilter-isomorphism-classification` | **Date**: 2026-09-02

## Prerequisites

* MATLAB R2024b+ with `initCobraToolbox` run, and any LP/MILP solver installed
  (`prepareTest('needsMILP', true)` is what `testConservedReactingMoieties.m`
  requires).
* This feature implemented per `plan.md` / `tasks.md`: new
  `src/analysis/topology/reactingMoieties/classifySubgraphIsomorphism.m`, and
  `findAndExtractMolecularGraphs.m` / `identifyConservedReactingMoieties.m` /
  `identifyIsomorphicClasses.m` routed through it (see
  `contracts/classifySubgraphIsomorphism.md`).
* For the Tyrosine benchmark step only: the external model/RXN-file paths
  from `spec.md`'s Assumptions section (or their adjusted equivalents).

## 1. CI-covered correctness check (US1 Independent Test, FR-008, SC-001)

```matlab
cd(fileparts(which('testConservedReactingMoieties')))
run('testConservedReactingMoieties.m')
```

**Expected**: passes with every existing assertion unchanged (diff
`test/verifiedTests/analysis/testReactingMoieties/testConservedReactingMoieties.m`
against its pre-feature version — only non-assertion lines, if any, may
differ, per SC-001).

## 2. Static structural check (US2 Independent Test, SC-006)

```bash
grep -rn "isisomorphic(" src/analysis/topology/reactingMoieties/
```

**Expected**: exactly one pairwise-comparison loop, inside
`classifySubgraphIsomorphism.m` (the three call sites' own inline loops are
gone; `identifyAtomEquivalenceClasses.m`'s unrelated candidate cross-check and
`identifyConservedReactingMoieties.m:1020`'s single-pair `MTG`/`MTG2`
comparison are pre-existing, out-of-scope call sites and are expected to
remain).

## 3. Scope-boundary check (SC-005)

```bash
git diff --name-only master... -- src/ | \
  grep -v -E "src/analysis/topology/reactingMoieties/(classifySubgraphIsomorphism|findAndExtractMolecularGraphs|identifyConservedReactingMoieties|identifyIsomorphicClasses)\.m"
```

**Expected**: empty output — no `src/` file outside
`src/analysis/topology/reactingMoieties/{findAndExtractMolecularGraphs.m,
identifyConservedReactingMoieties.m, identifyIsomorphicClasses.m,
classifySubgraphIsomorphism.m}` was touched, including other files within
the same `reactingMoieties` folder (e.g. `checkABRXNFiles.m`,
`readABRXNFile.m`, `addBondMappingsRXNFile.m` — FR-010).

## 4. Tyrosine benchmark reproducibility check (FR-009, SC-002, SC-003, SC-004; non-CI)

This step has a multi-minute runtime and depends on external model/RXN-file
paths not shipped in-repo — it is documented, not automated in CI (Principle
III's reproducibility-check fallback).

```matlab
% BEFORE implementing this feature (run once, on the pre-change code):
run('specs/021-prefilter-isomorphism-classification/tyrosineReproducibilityCheck.m')
% -> writes specs/021-prefilter-isomorphism-classification/tyrosine-golden-snapshot.mat

% AFTER implementing this feature:
run('specs/021-prefilter-isomorphism-classification/tyrosineReproducibilityCheck.m')
% -> re-runs the pipeline, asserts moietyFormulas/moietyGraphs/moietyVectors
%    equal the golden snapshot, and appends before/after isisomorphic call
%    counts and wall-clock time to
%    specs/021-prefilter-isomorphism-classification/tyrosine-reproducibility-results.md
```

**Expected**:
* `moietyFormulas`, `moietyGraphs`, `moietyVectors` identical to the golden
  snapshot (SC-004).
* Post-change total `isisomorphic` call count strictly lower than the
  pre-change baseline (2,678,455 + 96,562 + the `identifyIsomorphicClasses`
  baseline captured by the golden-snapshot run) — any nonzero reduction
  satisfies this; the actual percentage is recorded, not gated (SC-002, per
  the 2026-09-02 clarification).
* Classification-step wall-clock time recorded before and after, expected to
  be measurably lower (SC-003).

## 5. Manual isomorphism edge-case spot check (Edge Cases)

```matlab
% Singleton bucket: no isisomorphic call at all.
g = graph(1, 2);
[classes, firsts, subs] = classifySubgraphIsomorphism({g});
assert(isequal(classes, {1}) && isequal(firsts, 1) && isequal(subs, 1));

% Empty input: no error, trivial empty result.
[classes, firsts, subs] = classifySubgraphIsomorphism({});
assert(isempty(classes) && isempty(firsts) && isempty(subs));
```

**Expected**: both assertions pass without indexing errors or divide-by-zero
(Edge Cases: `numSubgraphs <= 1`).
