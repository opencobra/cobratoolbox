# Implementation Plan: Fix the safe Tier-1 known defects and document the rest

**Branch**: `20261102-140321-tier1-safe-defect-fixes` | **Date**: 2026-11-02 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/20261102-140321-tier1-safe-defect-fixes/spec.md`

## Summary

Fix the 62 table-A defects in 52 source functions with the smallest change that produces the
registry's EXPECTED behaviour (research R3/R4), extend each function's existing Tier-1 test to
assert the formerly skipped input and remove the fixed entry from its header, regenerate
`test/known-defects.md` (28 entries remain), and write `attention-defects.md` documenting the 28
table-B defects and the 8 new problems for maintainers. Work is split into independent groups by
source domain so groups can be implemented in parallel; each group verifies its tests with the
harness runner and line coverage.

## Technical Context

**Language/Version**: MATLAB R2025a; Python 3 for the registry tool.

**Primary Dependencies**: COBRA Toolbox on the path; base MATLAB only (tests stay Tier 1).

**Storage**: none; tests create no files.

**Testing**: existing script-style `test<Name>.m` files run by `test/testAll.m`; verified with
`runScriptFile` and line coverage measured with the code-coverage plugin (throwaway helper, see
[quickstart.md](quickstart.md)).

**Target Platform**: headless Linux CI and developer machines.

**Project Type**: MATLAB library (defect fixes + test updates).

**Performance Goals**: each changed test still runs in seconds.

**Constraints**: no change to table-B functions; public signatures unchanged (Principle II);
behaviour changes limited to those approved in spec FR-006.

**Scale/Scope**: 52 source files, 52 test files, 1 generated registry, 1 attention document.

## Constitution Check

*GATE: passed before research; re-checked after design: still passes.*

- **Scientific code quality**: model semantics untouched; the scientific fixes
  (`waterGibbsEnergyOfFormation`, `echelonNullspace`, `nullspaceLUSOLapply2Modes`,
  `projectOntoSubspace`, `assignQualDir`) are derived and verified in research R3.
- **Testing and reproducibility**: Principle III, III-Coverage, III-Naming, III-Defects (an
  entry is removed only when fixed, the formerly skipped input is then tested, the registry is
  regenerated). Commands in [quickstart.md](quickstart.md).
- **User experience and diagnostics**: console-only fixes restore line breaks and warning state;
  no output is suppressed (VII-A/VII-B; `setSimulationConstraints` now restores warnings).
- **Performance and numerical integrity**: no solver path changes; tolerances in tests justified.
- **External-solver configuration audit**: N/A — `setMosekParam` gains defaults for absent
  `feasTol`/`numTol` only in the SCLP profiles that currently error; no solver is invoked.
- **Spec-driven scope control**: edit only the 52 table-A source files, their 52 test files,
  `test/known-defects.md` (regenerated) and this feature folder. Read-only: table-B functions,
  `external/`, `deprecated/`, submodules.
- **MATLAB coding standards**: no `evalc`; warnings visible; any new optional argument uses
  `exist`/`isempty`; existing `nargin` contracts are not changed except where the defect is the
  `nargin` test itself (`calculateFoodScore`), which keeps the documented arity.
- **Parameter-setting fidelity**: N/A.
- **Artifact placement**: tests stay in their folders; documentation of this feature in
  `specs/20261102-140321-tier1-safe-defect-fixes/`.

## Project Structure

### Documentation (this feature)

```text
specs/20261102-140321-tier1-safe-defect-fixes/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── attention-defects.md     # US2 deliverable (written during implementation)
├── tasks.md
└── agent-runs/<UTC>-implement/implementation-receipt.md
```

### Source Code (repository root)

```text
src/<domain>/.../<function>.m          # 52 table-A functions (one-place fixes)
test/verifiedTests/<category>/test<Function>.m   # their existing tests, extended
test/known-defects.md                  # regenerated
```

**Structure Decision**: no new files outside this feature folder; no new test folders.

## Implementation groups (parallelisable)

| Group | Domain | Functions |
|-------|--------|-----------|
| G1 | analysis/exploration, igemRNA, sampling | numToFormattedString, printMetRxnInfo, findGenesAboveThresholdGT1, findGenesBelowThresholdGT1, removeCorrelRxns, chrrParseModel, calcSampleDifference, identifyCorrelSets |
| G2 | analysis/subspaces, thermo, topology | echelonNullspace, nullspaceLUSOLapply2Modes, projectOntoSubspace, assignQualDir, getMolecularWeight (newline only), acidDissociationConstant, waterGibbsEnergyOfFormation, integerizeS, createBIGraph |
| G3 | analysis/wholeBody | calculateFoodScore, calculateMacroOriginalDiet, compareDiets, compareBounds2Models, convertATPflux2StepNumer, setSimulationConstraints |
| G4 | base (io, solvers, utilities) | parseSBMLAnnotationField, inspectMosekProb, setMosekParam (SCLP only), StopCritBDCA, InitialDuplo, StopCritDuplo, getDefaultValue, isvar, mapAontoB |
| G5 | dataIntegration | compareXomicsModels, coreMetRxnAnalysis, getInchiData (p-layers only), sortAtomMappingIdx, Combination, cdv2idv, cleanUpMetabolite_structure, sanityCheckMetIds, mapExpressionToModel |
| G6 | design, reconstruction | augmentBOF, compareModels, buildRxnEquationsFromName, findRxnMatch, mergeTrxns, checkInputData, assignRxnWeights, checkPresentFields, flipRxnOrientation, getMetAbbr, updateMetNames |

## Complexity Tracking

No constitution violations; nothing to justify.
