# Quickstart: Validate the test-naming-convention merge

Prerequisites: MATLAB with the COBRA Toolbox path set up (as in feature
017-buildgurobifrommodel-tests' quickstart — `addpath(genpath('src'))`,
`addpath(genpath('test'))`, `addpath(genpath('external'))` if `initCobraToolbox`'s
saved path isn't picked up by `-batch` on this machine).

## Run each merged/renamed test standalone

```matlab
>> cd(fullfile(CBTDIR,'test','verifiedTests','base','testSolvers'));    testSolveCobraLP
>> cd(fullfile(CBTDIR,'test','verifiedTests','analysis','testOptimizeCbModel')); testOptimizeCbModel
>> cd(fullfile(CBTDIR,'test','verifiedTests','base','testEntropicFBA')); testEntropicFluxBalanceAnalysis
>> cd(fullfile(CBTDIR,'test','verifiedTests','base','testSolvers'));    testBuildOptProblemFromModel
```

**Expected outcome**: each completes with its existing `Done.`/success `fprintf`
output for BOTH its original assertions and the newly-appended characterization
block's assertions (look for both the original file's messages, e.g. "Testing
optimizeCbModel cardinality optimisation...", and the appended block's, e.g.
"Characterizing optimizeCbModel with LP solver..."), with no error.

## Run through the real harness (proves suite integration + absence of the old names)

```matlab
>> cd(fullfile(CBTDIR,'test'));
>> [result, resultTable] = runTestSuite('test(SolveCobraLP|OptimizeCbModel|EntropicFluxBalanceAnalysis|BuildOptProblemFromModel)$');
>> disp(resultTable)
```

**Expected outcome**: exactly the merged/renamed files appear (their `test*.m`
name), each `passed`, none `skipped`/`failed` (skips are acceptable only if a
declared `prepareTest` requirement is genuinely unavailable in this environment —
gurobi/mosek are installed per this session's earlier `initCobraToolbox` run, so
none are expected here). Confirm no `testCharacterize*` filename appears in the
table at all.

## Confirm zero `testCharacterize*` files remain (SC-001)

```bash
find test -iname "testCharacterize*.m"
```

**Expected outcome**: empty.

## Confirm the constitution amendment (SC-005)

```bash
grep -n "III-Naming" .specify/memory/constitution.md
tail -5 .specify/memory/constitution.md   # confirm Version bumped to 1.5.0
```

**Expected outcome**: the new sub-clause heading is present; `**Version**: 1.5.0`
with an updated `**Last Amended**` date.

## Confirm live-doc references updated, historical receipts untouched (SC-006)

```bash
grep -rn "testCharacterizeSolveCobraLP\|testCharacterizeOptimizeCbModel\|testCharacterizeBuildOptProblemFromModel\|testCharacterizeEntropicFBA" specs/ \
  | grep -v "agent-runs/"
```

**Expected outcome**: empty (all live-doc references updated).

```bash
grep -rln "testCharacterizeSolveCobraLP\|testCharacterizeOptimizeCbModel\|testCharacterizeBuildOptProblemFromModel\|testCharacterizeEntropicFBA" specs/*/agent-runs/
```

**Expected outcome**: non-empty and byte-identical to before this feature (these
files are read-only per FR-008 — no diff expected against the pre-feature
repository state).

## Confirm no `src` changes (SC-004)

```bash
git diff --stat -- src/
```

**Expected outcome**: empty.
