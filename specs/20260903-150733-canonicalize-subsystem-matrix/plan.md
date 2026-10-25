# Implementation Plan: Subsystem Matrix Canonicalization

**Branch**: `20260903-150733-canonicalize-subsystem-matrix` | **Date**: 2026-09-03 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/20260903-150733-canonicalize-subsystem-matrix/spec.md`

**Note**: This template is filled in by the `/speckit-plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

**Update (2026-09-07, /speckit-plan)**: `/speckit-specify` re-ran and added **FR-011**/**SC-007** — a formal, testable requirement that `getModelSubSystems`, `sammi`'s `'subSystems'` grouping, and `verifyModel`'s field check must not mutate `model.subSystems` (previously only an Assumptions-section note under the old FR-007). This plan, research.md, data-model.md, quickstart.md, and contracts/ have been updated below to cite FR-011/SC-007 explicitly; no Constitution Check, Project Structure, or Complexity Tracking conclusion changes as a result — the non-mutation behavior was already the intended design, this only makes it independently tested (one `isequal` assertion per function, added to each function's existing test file, no new test file).

**Update (2026-09-07, /speckit-tasks)**: Task generation found that `model2JSON`'s premise "currently has no test file" (spec FR-009, this plan's III-Naming bullet below) is **false** — `test/verifiedTests/base/testIO/testModel2JSON` already exists, is git-tracked, and contains a real 6-model test, but is missing its `.m` extension and is therefore never discovered by `test/testAll.m` (research.md R7, added). The FR-009/SC-001 task is corrected below from "create new `testModel2JSON.m`" to "relocate the existing file to `test/verifiedTests/base/testIO/testModel2JSON/testModel2JSON.m` (preserving its existing 6-model coverage) and extend it" — see the corrected Project Structure and Constitution Check III-Naming bullet below.

**Update (2026-09-07, /speckit-implement)**: Direct execution during implementation found FR-003 as originally written was circular: `buildRxn2subSystem.m:73` already delegates its own name-enumeration to `getModelSubSystems`, so having `getModelSubSystems` call `buildRxn2subSystem` (as FR-003 said) recurses infinitely. It also found `getModelSubSystems.m`'s dedicated flat-cell-of-char branch is pre-existing unreachable dead code (research.md R8). FR-003 is corrected to require consolidating `getModelSubSystems`'s three overlapping branches into one, not calling `buildRxn2subSystem`. Execution also found `sammi.m`'s actual pre-fix failure is `unique()` at line 156 (not `ismember()` at line 160 as R4 originally quoted), and a second, independent defect in `makeSAMMIJson.m`'s generic per-field serializer that had to be worked around locally within `sammi.m` (research.md R4 amendments). None of these corrections change the Constitution Check, Project Structure, or Complexity Tracking conclusions below — no new file is touched beyond what was already planned.

## Summary

Finish canonicalizing reaction-subsystem handling by extending the `rxn2subSystem`/`subSystemNames` incidence-matrix approach (built in PR #2362, currently used only by `isReactionInSubSystem.m`, `findRxnsFromSubSystem.m`, and `isSameCobraModel.m`) to two more consumers and one validator, while fixing two confirmed defects: `model2JSON.m` silently drops all but the first subsystem name for a multi-subsystem reaction (research.md R3), and `verifyModel.m` has unconditionally suppressed all `subSystems` validation errors since a 2020 workaround (research.md R2). `getModelSubSystems.m` is refactored to share the matrix-construction logic for internal consistency (no output change — research.md R5), and `sammi.m`'s subsystem-grouping mode is fixed to stop erroring on nested-cell (multi-subsystem) models (research.md R4). `rxn2subSystem`/`subSystemNames` are registered as optional, derived fields in `COBRA_structure_fields.tab` so `verifyModel` can validate them instead of ignoring them. `model.subSystems` (all three legacy shapes) remains the untouched, authoritative interchange format throughout; `model2xls.m`/`xls2model.m` are out of scope (already correct).

## Technical Context

**Language/Version**: MATLAB, R2024b+ baseline (Constitution: Scientific Computing Constraints)

**Primary Dependencies**: None beyond the existing COBRA Toolbox `src/base/io/`, `src/analysis/exploration/`, `src/reconstruction/refinement/`, `src/reconstruction/modelGeneration/modelVerification/`, and `src/visualization/SAMMIM/` modules already involved; `sammi.m`'s test requires the `statistics_toolbox` (already declared via `prepareTest('requiredToolboxes', {'statistics_toolbox'})` in `testSammi.m`). No new external dependency.

**Storage**: N/A — all state is the in-memory COBRA model struct; the only file I/O touched is JSON export (`model2JSON.m`) and the tab-delimited field-definitions file (`COBRA_structure_fields.tab`).

**Testing**: MATLAB `test/testAll.m` harness; `test/verifiedTests/<category>/test<FunctionName>.m` per Constitution III/III-Naming. No solver required for any test in this feature (pure data-structure operations — FR-010).

**Target Platform**: Headless Linux CI (MATLAB `-batch`, Docker, Xvfb where a display is needed) — Constitution Scientific Computing Constraints. No GUI interaction in any test (Principle III), consistent with `sammi.m`'s `options.load = false` pattern already used in `testSammi.m`.

**Project Type**: Library (MATLAB toolbox) — single `src/` tree with a matching `test/verifiedTests/` tree; no frontend/backend split applies.

**Performance Goals**: None beyond "no regression" — `rxn2subSystem` construction is a single-pass `O(nRxns * nSubsystems)` operation already used by three functions in production; extending it to two more consumers does not change its asymptotic cost, and no function in scope is on a genome-scale hot path invoked per-solver-iteration.

**Constraints**: `model.subSystems` and its three legacy shapes MUST remain fully supported as input everywhere (spec FR-002, FR-007); no function signature or default-argument value may change (spec FR-008); no new required model field (spec Assumptions — `rxn2subSystem`/`subSystemNames` stay optional/derived); `getModelSubSystems`, `sammi`, and `verifyModel` MUST NOT mutate or remove `model.subSystems` as a side effect (spec FR-011).

**Scale/Scope**: 4 source files changed (`model2JSON.m`, `sammi.m`, `getModelSubSystems.m`, `verifyModel.m`) + 1 data file (`COBRA_structure_fields.tab`); 4 test files touched (1 new: `testModel2JSON.m`; 3 extended: `testSammi.m`, `testGetModelSubSystems.m`, `testVerifyModel.m` — each gaining one `isequal`-on-`subSystems` non-mutation assertion per FR-011/SC-007, no new test file for this); 4 already-converted functions and their 5 tests explicitly frozen (FR-008/SC-005).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Scientific code quality (Principle I)**: The `subSystems`/`rxn2subSystem`/`subSystemNames` fields are explicitly named in Principle I as an annotation field a feature may touch. No stoichiometric, bounds, objective, or status semantics are touched — this feature is purely reaction-annotation bookkeeping. `model.subSystems` remains the canonical interchange format (Principle II); the two derived fields are additive.
- **Testing and reproducibility (Principle III)**: Narrowest tests per Traceability (spec.md): `test/verifiedTests/base/testIO/testModel2JSON/testModel2JSON.m` (relocated via `git mv` from the existing, `.m`-less, currently-undiscovered `testModel2JSON` file — research.md R7 — not created from scratch); extensions to `testSammi.m`, `testGetModelSubSystems.m`, `testVerifyModel.m`. Each of those three extended test files also gains one `isequal(subSystemsBefore, model.subSystems)` non-mutation assertion (FR-011/SC-007) — no new test file, no new fixture beyond what each test already builds. All run via `test/testAll.m`/CI, no `prepareTest` solver requirement needed (FR-010) beyond `testSammi.m`'s existing `requiredToolboxes: {'statistics_toolbox'}`. Regression baseline: `testFindRxnsFromSubSystem.m`, `testIsReactionInSubSystem.m`, `testBuildRxn2subSystem.m`, `testWriteSBML.m` (which also exercises `isSameCobraModel`) MUST keep passing with unchanged assertion counts (FR-008/SC-005), verified by running them before and after implementation (quickstart.md step 2 and step 5). III-Naming: all touched/new test files already follow or will follow `test<FunctionName>.m` — `testModel2JSON.m` is the correctly-named file for `model2JSON.m`; the constitutionally-correct path `test/verifiedTests/base/testIO/testModel2JSON/testModel2JSON.m` currently holds no file (research.md R7), because the existing, git-tracked, 6-model `model2JSON` test instead sits one level up as the extensionless `test/verifiedTests/base/testIO/testModel2JSON` and is therefore never discovered by `test/testAll.m`'s `*.m` pattern. That existing file MUST be relocated (`git mv`) into the correct path with its `.m` extension restored and its 6-model coverage preserved verbatim, then extended with the multi-subsystem assertions — not left in place, and not duplicated by a second new file (III-Naming's one-file-per-function rule).
- **User experience and diagnostics**: No new user-facing parameter or CLI/UI surface. `verifyModel`'s diagnostic output (its `disp`/`fprintf` problem summary) gains real `subSystems` entries where a model is genuinely malformed, instead of silently hiding them — this is the intended fix (FR-006), not a regression; output stays gated behind the existing `silentCheck` option, unchanged.
- **Performance and numerical integrity**: No solver is invoked by any change in this feature (FR-010) — see Technical Context Performance Goals. `rxn2subSystem` construction remains the existing `O(nRxns * nSubsystems)` single pass; no repeated construction is introduced inside a loop (each of `getModelSubSystems`/`sammi` calls it once per invocation, matching how `isReactionInSubSystem`/`findRxnsFromSubSystem` already call it once per invocation today).
- **External-solver configuration audit**: N/A — no external solver or library is invoked by this feature.
- **Spec-driven scope control**: Source paths to edit: `src/base/io/json/model2JSON.m`, `src/visualization/SAMMIM/sammi.m`, `src/analysis/exploration/getModelSubSystems.m`, `src/reconstruction/modelGeneration/modelVerification/verifyModel.m`, `src/base/io/definitions/COBRA_structure_fields.tab`. Read-only (consulted, not edited): `src/reconstruction/refinement/buildRxn2subSystem.m`, `src/analysis/exploration/isReactionInSubSystem.m`, `src/analysis/exploration/findRxnsFromSubSystem.m`, `src/reconstruction/refinement/isSameCobraModel.m` (FR-008 pins these unchanged). Explicitly out of scope, not to be touched: `src/base/io/utilities/model2xls.m`, `src/base/io/utilities/xls2model.m` (spec: already correct). No new dependency, helper file, or abstraction beyond what `buildRxn2subSystem.m` already established — this feature reuses that existing matrix-construction logic rather than introducing a new one.
- **MATLAB coding standards**: No `evalc` use planned. Any `warning()` currently emitted by `isReactionInSubSystem.m`/`findRxnsFromSubSystem.m` when lazily building the matrix (`"...has been generated because it was not in the model."`) stays visible (Principle VII-B) and is not suppressed by the new callers. No `try/catch` swallowing planned; if one is introduced (e.g. in `getModelSubSystems`'s refactor) it MUST propagate `ME.stack` per VII-C. No `nargin`-based optional-argument handling planned for any changed function (VII-D N/A — no new optional arguments introduced). Existing openCOBRA help headers on all four changed functions MUST be updated to document any behavior clarified by this feature (VII-E). No MATLAB best-practice/linting skill is registered in this repo beyond the constitution's own VII-A–VII-G rules, which this plan follows directly (VII-F).
- **Parameter-setting fidelity**: N/A — this feature ports no code into another language or literate document.
- **Artifact placement (Principle IX)**: All five changed files already live at their correct, existing locations under `src/base/io/`, `src/visualization/`, `src/analysis/exploration/`, and `src/reconstruction/modelGeneration/modelVerification/` — no file is moved or newly placed outside an existing domain folder. The one new file, `test/verifiedTests/base/testIO/testModel2JSON/testModel2JSON.m`, lands in the already-existing (empty) test directory matching its function's existing location — no new directory structure is introduced. No generated output, diary, or notebook is produced by this feature.

## Project Structure

### Documentation (this feature)

```text
specs/20260903-150733-canonicalize-subsystem-matrix/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md        # Phase 1 output (/speckit-plan command)
├── quickstart.md        # Phase 1 output (/speckit-plan command)
├── contracts/           # Phase 1 output (/speckit-plan command)
│   ├── model2JSON.md
│   ├── sammi-subsystem-grouping.md
│   ├── getModelSubSystems.md
│   └── verifyModel-subsystems-field.md
├── checklists/requirements.md   # Spec-quality checklist (/speckit-specify)
└── tasks.md              # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

### Source Code (repository root)

This is a single-project MATLAB toolbox library (Constitution Principle IX): source lives under `src/<domain>/`, tests under the mirroring `test/verifiedTests/<category>/`. No frontend/backend or mobile split applies. Concrete paths touched by this feature:

```text
src/
├── base/
│   ├── io/
│   │   ├── json/
│   │   │   └── model2JSON.m                          # EDIT — FR-001, FR-002
│   │   └── definitions/
│   │       └── COBRA_structure_fields.tab             # EDIT — FR-005 (register 2 new rows)
├── analysis/
│   └── exploration/
│       ├── getModelSubSystems.m                       # EDIT — FR-003, FR-007, FR-011
│       ├── isReactionInSubSystem.m                    # READ ONLY — FR-008
│       └── findRxnsFromSubSystem.m                    # READ ONLY — FR-008
├── reconstruction/
│   ├── refinement/
│   │   ├── buildRxn2subSystem.m                       # READ ONLY — FR-008
│   │   └── isSameCobraModel.m                         # READ ONLY — FR-008
│   └── modelGeneration/
│       └── modelVerification/
│           └── verifyModel.m                          # EDIT — FR-006, FR-011
└── visualization/
    └── SAMMIM/
        └── sammi.m                                     # EDIT — FR-004, FR-007, FR-011

test/verifiedTests/
├── base/testIO/
│   ├── testModel2JSON                                 # RELOCATE (git mv) to testModel2JSON/testModel2JSON.m below — research.md R7
│   ├── testModel2JSON/testModel2JSON.m                # RELOCATED + EDIT — SC-001 (preserves existing 6-model coverage)
│   └── testWriteSBML.m                                # READ ONLY (regression baseline) — SC-005
├── analysis/
│   ├── testGetModelSubSystems/testGetModelSubSystems.m       # EDIT — SC-002, SC-007
│   ├── testFindRxnsFromSubSystem/testFindRxnsFromSubSystem.m # READ ONLY — SC-005
│   └── testIsReactionInSubSystem/testIsReactionInSubSystem.m # READ ONLY — SC-005
├── reconstruction/
│   ├── testBuildRxnSubSystem/testBuildRxn2subSystem.m  # READ ONLY — SC-005
│   └── testModelGeneration/testVerifyModel.m           # EDIT — SC-004, SC-007
└── visualization/testSammi/testSammi.m                 # EDIT — SC-003, SC-007
```

**Structure Decision**: Existing single-project MATLAB layout, unchanged. Every source file edited already exists at the path shown. `testModel2JSON.m` is not a new file: it is the existing, git-tracked `test/verifiedTests/base/testIO/testModel2JSON` (currently missing its `.m` extension and therefore invisible to `test/testAll.m` — research.md R7) relocated one level down into its own `testModel2JSON/` directory with the extension restored, matching the one-directory-per-test pattern its siblings (`testIsValidJSON/`, `testKEGG/`, `testUtilities/`) already use. No new subfolder, package, or cross-language surface is introduced.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

No Constitution Check violations. No new dependency, abstraction, project, or repository-layout change is introduced; every touched file already exists at its constitutionally-correct location, and the one new file follows the existing test-naming and placement conventions exactly.
