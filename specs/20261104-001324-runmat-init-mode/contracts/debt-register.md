# Contract: RunMat debt register and re-check

**Location**: `test/runtimeCompatibility/RunMat/` (constitution VIII-Runtime, IX).

## `debtRegister.md`

**Table *Workarounds***: one row per `% RUNTIME-DEBT(RunMat:<id>)` marker occurrence. Columns:
`Defect | File | Construct | MATLAB behaviour replaced | Removal condition | Reproducer`.

**Table *Blocking defects without a workaround***: columns
`Defect | Effect on COBRA | Files affected | Reproducer`. These rows have no marker.

## `repro/<id>/`

- `<id>.m`: at most 10 lines; a script, or a script plus helper files.
- `expected.txt`: the MATLAB R2026a output of `<id>.m`, run in that folder.
- Optional `mode.txt`: `run` (default) or `test-list`, for runner-level defects.

## `recheckRunMat.sh RUNMAT [REPO_ROOT]`

1. For each `repro/<id>/`, copy it to a fresh temporary folder, run it under RunMat, drop lines that start with
   `WARN`, and compare the result with `expected.txt`.
2. Print one line per defect: `<id>\t(still needed|removable)\t<first differing line>`.
3. Count the `RUNTIME-DEBT(RunMat:` markers under `REPO_ROOT` (in the `.m` files, excluding `specs/`) and
   compare them with the *Workarounds* rows, by file and defect. Print each mismatch.
4. Exit 0 when the markers match the register, and 1 otherwise. *Removable* entries do not fail the run; they
   are reported.
