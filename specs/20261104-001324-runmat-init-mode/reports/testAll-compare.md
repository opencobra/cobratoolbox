# MATLAB testAll (COBRA_CI=1, R2026a) after the change

## T027 (current): full clone at e2179c882

538 tests: Passed 495, Failed 7, Skipped 36 (same counts as the baseline).

```
before 537 tests, after 537 tests, 2 differences
testInitCobraToolbox.m	absent	Passed
testInitCobraToolboxAgentMode.m	Passed	absent
```

The two lines are one pair: testInitCobraToolboxAgentMode.m was renamed to testInitCobraToolbox.m (T007); it passed before and passes after. No other status changed, including the 65 tests that call test/verifyCobraFunctionError.m (T026-T027). SC-003 holds.

## T022 (superseded): full clone at 5625ee3ef

Same counts and the same two-line rename pair.
