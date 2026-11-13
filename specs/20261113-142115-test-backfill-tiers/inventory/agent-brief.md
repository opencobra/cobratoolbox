# Brief for a test-writing helper (feature 20261113-142115-test-backfill-tiers)

You write characterization tests for a slice of up to 10 functions of the COBRA Toolbox that have
no test. You work in the repository root (`git rev-parse --show-toplevel`). `F` below means
`specs/20261113-142115-test-backfill-tiers`. Your prompt names your wave number `NN`, your slice
letter `s` and gives the slice rows (file, tier, flags, untested callees, callers).

## Read first (binding)

1. `.specify/memory/constitution.md`, Principle III with III-Characterization, III-Naming,
   III-Coverage, III-Defects (including "Quarantine in back-fill campaigns"), and Principle VII
   (VII-A to VII-G). These rules win over anything here.
2. `$F/contracts/test-file.md` (layout of every test) and `$F/contracts/agent-result.md` (what you
   return).
3. Examples of well-formed tests: Tier 1 `test/verifiedTests/base/testToolboxFree/testCobraTiedrank.m`;
   Tier 3 opening and solver loop `test/verifiedTests/base/testCardOpt/testSparseLP.m`.

## What to do for each function of your slice

1. Read the source file completely, its header (USAGE, INPUTS, OUTPUTS) and the functions it calls.
   Decide the behaviour to pin from the documentation and the code. Never change any file under
   `src/`.
2. Check that no test of that name exists: `find test -name 'test<Name>.m'` (Name = file name with
   the first letter capitalised). If one exists, stop for that row and report it in `notes`.
3. Place the test in the existing `test/verifiedTests/<category>/test<Area>/` folder that holds the
   tests of other files from the same `src/` folder (look them up with grep on "Function under
   test"); if none, use `test/verifiedTests/<category>/test<LastSrcFolder>/` (category = first
   folder under `src/`, e.g. analysis, base, dataIntegration, reconstruction, visualization, design).
4. Write the test per the contract: header (purpose, function under test, tier, coverage exemptions,
   known defects, authors with today's date), `prepareTest` opening, one `%%` section per behaviour
   or branch with a comment saying what it proves and why a tolerance was chosen.
   - Inputs: hand-built; small models with `createModel` (src/reconstruction/refinement/createModel.m)
     or `getDistributedModel('ecoli_core_model.mat')`; larger models only when the code needs them
     (say why in the header). Load a model once per file.
   - Expected values: independently derived where possible (hand calculation, a mathematical
     property, the documentation). If not possible, record the first run's value and label it
     Tier 5 in the header (date, solver).
   - Tier 3: declare solvers with `prepareTest('needsLP', true, ...)` (or needsMILP/needsQP), loop
     over the solvers returned as in testSparseLP, and assert invariants (status, S*v = b within
     tolerance, bounds, objective), never one flux vector among several optima.
   - Cover every executable line. A line may stay uncovered only with a documented reason:
     unavailable solver or toolbox (name it), GUI, OS-specific branch, needs internet or an external
     program, defective input skipped (III-Defects), or unreachable by any input (dead code; say
     why). List each such line number under "Coverage exemptions".
   - Errors the function raises by design: test them with `verifyCobraFunctionError`.
   - No `evalc`, no warning suppression, seeds fixed (`rng(<n>)`), figures closed, temporary files
     only in a `tempname` folder removed at the end, `cd(currentDir)` at the end, no globals or path
     changes left behind (the coverage tool reports leftovers in its `leftover` field; fix them).
5. Run your tests with coverage (step "Running" below), read the missed lines, add sections or
   exemptions, and repeat until every test passes, every missed line is exempt, and `leftover` is
   empty.

## Defects

A defect is behaviour that contradicts the function's documentation, an independent derivation, or
the evident intent of the code, with an input the documentation allows (inputs it does not allow
are not defects). Severities (III-Defects): `wrong-result`, `error`, `unusable-option`, `cosmetic`,
`limitation`.

- `cosmetic` or `limitation`: record the defect in the header (standard entry), skip only the
  affected input, list the lines it leaves uncovered as exemptions, and test everything else:
  status `TESTED`, defect with `"quarantine": false`.
- `wrong-result`, `error` or `unusable-option`: the function is QUARANTINED. Write the quarantine
  layout of the contract: the header with the defect entry (with the exact trigger and what you
  observed in MATLAB), "Coverage exemptions: every line — <name> is quarantined for the defect
  below (feature 20261113-142115-test-backfill-tiers)", body = the standard opening with
  `prepareTest()` and nothing that calls the function. Status `QUARANTINED`, defect with
  `"quarantine": true`. Put the minimal reproduction (MATLAB lines) in `notes` so that a second
  reader can confirm it.
- If a defect lies in a function your function calls (not in your function), say so in `notes`
  with the callee's name and the reproduction; do not quarantine your function for it.

## When a row cannot be tested here

Status `EXCLUDED` with the reason (every line needs internet, an external program, an unavailable
solver or licence, a GUI or interactive input; or the code cannot run within the memory limit).
Do not create a test file for it.

## Running (MATLAB)

Never start MATLAB directly. Write a list file in a temporary folder (`mktemp -d`), one line per
test: `<test path>|<source path>` (repository-relative), and run

```
$F/tools/run_coverage.sh <list file> <output.jsonl> [timeout seconds]
```

It prints one `COVREC` line per test; the JSON lines hold `status`, `message`, `lines`, `hits`
(0 = missed) and `leftover`. Run all tests of your slice together where possible (one MATLAB
session at a time per helper; the machine allows three sessions in total and the tool waits for a
free one). A run killed for memory prints `MATLAB-SAFE-KILLED`: reduce the model or the test.

Read a run with `$F/tools/coverage_report.py <output.jsonl>` (one line per test: status, missed
lines, leftover state, message).

## Lessons from the pilot (wave 01)

- Probe before you document: confirm every suspected defect and every unusual behaviour with a
  short MATLAB run (a scratch function in your temporary folder, run through the same wrapper:
  `~/.local/bin/matlab-safe --timeout 300 -batch "initCobraToolbox(false); addpath('<tmp>'); probe"`),
  and quote what MATLAB printed in OBSERVED.
- Globals: if the test (or a function it calls, such as `CobraSolverState.get` or
  `initCobraToolbox`) creates globals, take `globalsBefore = who('global')` before the first such
  call and remove `setdiff(who('global'), globalsBefore)` at the end; restore any global the test
  changes to its saved value; save and restore the solver state with `CobraSolverState.get/restore`.
- Global variables, solver paths or toolbox state can be set to hand-built values to reach
  branches without the real installation (see `testGetCobraSolverVersion.m`), as long as everything
  is restored.

## What you return

Write `$F/inventory/results/waveNN-s.jsonl`, one record per row of your slice, exactly as
`contracts/agent-result.md` says (`lines` = number of executable lines from the final coverage run,
`missed` = missed line numbers, `exempt` = the missed lines you documented). Add run-time calls to
`src/` functions that your row's `untested_callees` does not list to `extra_edges`.

Your final message: one line per row (`<name>: STATUS — short note`) plus anything the lead must
decide. Do not edit `src/`, other tests, the ledger, the brief, or git state (no add, no commit).
