# Contract: the `testAll` RunMat switch

**Switch**: the environment variable `COBRA_RUNMAT`. It is on only when equal to `'1'`, matching `COBRA_CI` and
`COBRA_PERF`.

| | `COBRA_RUNMAT` unset or not `'1'` | `COBRA_RUNMAT=1` |
|---|---|---|
| Toolbox root | `which('initCobraToolbox.m')` as before | folder of `testAll.m` from `mfilename('fullpath')`, then `..` (D6, D24) |
| Initialisation | `initCobraToolbox()` as before | `initCobraToolbox(false, 'runmat')` |
| End of run in CI | `exit()` as before | no `exit`; the script ends (D10) |
| `PERFORMANCE_REPORT` | read through `eval` inside its `exist` guard; value unchanged (D5, compile-time entry) | same |
| Everything else | unchanged | unchanged |

**MATLAB invariant (SC-003)**: with the switch off, every test's status equals the baseline's.
