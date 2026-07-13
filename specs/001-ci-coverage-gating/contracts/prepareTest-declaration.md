# Contract: prepareTest requirement declaration

How a backfilled test declares its requirements. The mechanism is unchanged — this contract
fixes *how the backfill uses it* so all 212 edits are uniform and behaviour-preserving.

## Placement

A `prepareTest(...)` call is added near the top of the test (after the header comment and any
`global CBTDIR`/path save, before the test body), mirroring the 48 already-gated tests. When the
test uses the returned solver struct, capture it: `solvers = prepareTest(...);`.

## Signal → key mapping (from research.md Decision 6)

| Test uses | Declaration |
|---|---|
| `optimizeCbModel`, `solveCobraLP`, FVA, most FBA | `prepareTest('needsLP', true)` or `requireOneSolverOf` |
| `solveCobraQP` / quadratic | `'needsQP', true` |
| `solveCobraMILP` / MILP design | `'needsMILP', true` |
| `solveCobraMIQP` | `'needsMIQP', true` |
| `entropicFBA` / `solveCobraEP` | `'needsEP', true` |
| NLP path | `'needsNLP', true` |
| named commercial solver required | `'requiredSolvers', {'ibm_cplex'}` / `'requireOneSolverOf', {...}` |
| MATLAB toolbox | `'requiredToolboxes', {'statistics_toolbox'}` (license names per `prepareTest.m:77-83`) |
| OS-specific | `'needsUnix'|'needsWindows'|'needsMac', true` |
| URL / webread | `'needsWebAddress', '<url>'` |
| external binary (`lrs`, …) | `'requiredSoftwares', {'<name>'}` |
| none of the above | NO `prepareTest`; record `noneNeeded=true` in the audit CSV |

## Invariants (MUST hold — verified in Bundle 4)

1. The test's assertions and computational body are **unchanged**; only the requirement
   declaration (and optional `solvers = ...` capture) is added.
2. When requirements are met, the test runs and passes exactly as before (FR-010, SC-004).
3. When a requirement is absent, `prepareTest` throws `COBRA:RequirementsNotMet`, so
   `runTestSuite` counts the test as **Skipped**, never Errored/Failed (SC-002).
4. Conservative default: if unsure, declare the requirement (skip > hard-fail). No test is
   deleted, disabled, or has a real failure masked as a skip.
