# T022: MATLAB testAll (COBRA_CI=1, R2026a) after the change, full clone at 5625ee3ef

After: 538 tests: Passed 495, Failed 7, Skipped 36 (same counts as the baseline).

```
before 537 tests, after 537 tests, 2 differences
testInitCobraToolbox.m	absent	Passed
testInitCobraToolboxAgentMode.m	Passed	absent
```

The two lines are one pair: testInitCobraToolboxAgentMode.m was renamed to testInitCobraToolbox.m (T007, git mv); it passed before and passes after. No other test changed status, so SC-003 holds. The 7 failures are the baseline's.
