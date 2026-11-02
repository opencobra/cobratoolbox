# MATLAB testAll after the US1 rewrites (T030, SC-003)

- Commit: 0b548ede1 (all US1 rewrites), full local clone with submodules at the recorded commits, as for T004
- Command: COBRA_CI=1 xvfb-run matlab -noFigureWindows -batch "set(0,'DefaultFigureVisible','off'); cd('<clone>/test'); testAll"
- MATLAB R2026a, 2026-11-02
- Result: 537 tests, 496 passed, 5 failed, 36 skipped (`testAll-after.csv`)

## Comparison with the baseline

`python3 tools/compare_testall.py compare baseline/testAll-before.csv reports/testAll-after.csv`:

```
before 536 tests, after 536 tests, 1 differences
testSurfNet.m	Passed	Failed
```

(537 rows hold 536 distinct test names in both runs.) The other four failures are the baseline failures:
testEcosystemToy, testClassifySubgraphIsomorphism, testExtractBondSubgraphs and testEntropicFluxBalanceAnalysis.

## The difference, traced

- Commit: 934536abd (explicit `name()` calls, T013–T014).
- `testSurfNet.m` line 191: `clear surfNet` became `clear surfNet()`. That line is command syntax, so `clear`
  received the text `surfNet()`, cleared nothing, and `surfNet`'s persistent model survived; the next assertion
  (line 196) expects the error for an empty persistent model.
- Cause: `explicit_calls.py` recognised command syntax only when the listed name started the statement
  (`name arg`), not when it was an argument (`word name`). The calls category has no parse-tree check
  (research.md R5), and the analyzer reports no message for this line, so the verification passed.
- Fix: the tool skips every argument of a command-syntax statement (a statement that starts with a non-keyword
  identifier, a space and an identifier, number or text). Rerun on the pre-commit content of all 133 files, the
  fixed tool gives the committed result for 132 files; for `testSurfNet.m` it keeps `clear surfNet` and still
  writes `surfNet();`. No other file of the commit has a command-syntax statement with a rewritten argument.

## Confirmation

`COBRA_CI=1 COBRA_TESTS=testSurfNet testAll`, on the baseline clone and on the after clone with the fixed file:
both `testSurfNet.m` passed, 0 failures. With this file fixed, the comparison has no difference.
The full suite was not rerun after the fix; only `testSurfNet.m` changed.
