# MATLAB testAll baseline (T004)

- Commit: aa51dcd2a (unchanged source), full local clone with submodules at the recorded commits
- Command: COBRA_CI=1 xvfb-run matlab -noFigureWindows -batch "set(0,'DefaultFigureVisible','off'); cd('<clone>/test'); testAll"
- MATLAB R2026a, 2026-11-02

- Test execution mode: full (set COBRA_TEST_MODE=full for the complete suite).
- 4 tests failed. 36 tests were skipped due to missing requirements.
The following tests failed:

```
The following tests failed:
testEcosystemToy.m
testClassifySubgraphIsomorphism.m
testExtractBondSubgraphs.m
testEntropicFluxBalanceAnalysis.m

```
