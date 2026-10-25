# Pre-implementation tests (T001) — 2026-10-03, branch @ 4e876fe97, unmodified source

MATLAB R2026a, MATLAB MCP session, LP solver gurobi (greedyExtremeRayBasis nominates gurobi itself).

| Test | Result | Elapsed |
|---|---|---|
| testGreedyExtremeRayBasis | PASS | 78.7 s |
| testFindExtremePathway (gurobi, glpk) | PASS | 2.4 s |

Note on a false failure: a first run reported testGreedyExtremeRayBasis FAILED at line 224
("the time budget must bound a run that rejects every candidate", elapsed 180.1 s). Cause:
the test is a SCRIPT that adds fields to whatever `param` already exists in the calling
workspace, and a diagnostic session had left `param.maxTime = 180` there. The test was
re-run after `clearvars`, and it passed. Not a defect in the routine. Every later
test run in this feature clears the workspace first.
