# MATLAB testAll baseline (T001, SC-003)

- Commit: `afe0fac8f` (source identical to the branch base `87573f1e8`). Full local clone, with submodules at the
  recorded commits.
- Command: `COBRA_CI=1 xvfb-run -a matlab -noFigureWindows -batch "set(0,'DefaultFigureVisible','off'); cd('<clone>/test'); testAll"`
- MATLAB R2026a, 2026-11-04.
- Result: 538 tests; 495 passed, 7 failed, 36 skipped (`testAll-before.csv`, from `testReport.junit.xml` via
  `specs/20261102-153951-runmat-compat/tools/compare_testall.py csv`).
- Failed:
  - testEcosystemToy, testClassifySubgraphIsomorphism, testExtractBondSubgraphs, testEntropicFluxBalanceAnalysis,
    which also failed in the previous feature's baseline;
  - testCheckNullspaceBasis, testGreedyExtremeRayBasis, testGreedyExtremeRayBasisResume, which come from the
    `089-large-model-solver-speed` work in this branch's history.
- Note: in the run after this feature, `testInitCobraToolboxAgentMode.m` appears as `testInitCobraToolbox.m`
  (renamed in T007). The comparison must pair the two names.
