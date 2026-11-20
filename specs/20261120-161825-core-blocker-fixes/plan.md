# Implementation Plan: Fix the code defects of the core blocking functions

**Branch**: `20261120-161825-core-blocker-fixes` | **Date**: 2026-11-20 | **Spec**: [spec.md](spec.md)

## Summary

Fix the code defects of seven quarantined functions that block most BLOCKED functions, one function
at a time after the maintainer's review. Each fix gets a full test of the function, an impact report
(the callers whose outputs can change, and their tests run), and ledger and registry updates. When
all approved fixes are in, the functions they unblock get tests.

## Technical Context

**Language/Version**: MATLAB R2024b+ (tested on R2025a)

**Primary Dependencies**: the back-fill feature's tools (`run_coverage.sh`, `update_ledger.py`),
`.github/scripts/known_defects.py`

**Storage**: N/A

**Testing**: the fixed functions' tests with coverage; the callers' tests via runScriptFile

**Target Platform**: as the toolbox

**Project Type**: library (bug fixes)

**Performance Goals**: no change

**Constraints**: interfaces unchanged (Principle II); only approved decisions are implemented

**Scale/Scope**: up to 7 functions, their tests, and tests for the functions they unblock

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Scientific code quality**: Each fix restores documented behaviour, and each is reviewed with the
  maintainer before it is implemented. getCobraSolverParams: the documented priority (structure >
  global > default) holds for every calling form.
- **Testing and reproducibility**: Full tests of the fixed functions, plus caller tests run per fix.
- **User experience and diagnostics**: Settings made with changeCobraSolverParams take effect for
  every caller.
- **Performance and numerical integrity**: Results change only where the documented behaviour
  differs from the old behaviour. The impact report names those cases.
- **External-solver configuration audit**: getCobraSolverParams is the configuration surface itself.
  Its built-in defaults are unchanged, and the globals are empty after init (checked).
- **Dependency minimisation**: None added.
- **Spec-driven scope control**: Edit the approved functions and their tests, new tests for
  unblocked functions, and the back-fill ledger and registry. A function not yet approved is not
  edited.
- **MATLAB coding standards**: No nargin added, no evalc, no warning suppression; help updated with
  a dated note (VII-E).
- **Parameter-setting fidelity**: N/A.
- **Artifact placement**: Records in this feature folder.

**Gate result**: PASS.

## Design (per approved function)

1. **getCobraSolverParams.** Split `overRideDefaults` into `useGlobals` and `returnStructure`. The
   two-input form uses the globals without returning a structure. `'default'` returns a structure
   without using the globals. A structure input does both. The paramStructure override is applied
   whenever `isfield(paramStructure, ...)` holds. The help for paramStructureOut describes the fields
   that are set, with a NOTE. The test is a full test from the wave 02 version (git 7691bdd2e), with
   the three defect cases. Impact: the callers of the two-input form (`grep`), and their tests run.
