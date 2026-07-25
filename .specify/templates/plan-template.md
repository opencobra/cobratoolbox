# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]

**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `/speckit-plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

[Extract from feature spec: primary requirement + technical approach from research]

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: [e.g., Python 3.11, Swift 5.9, Rust 1.75 or NEEDS CLARIFICATION]

**Primary Dependencies**: [e.g., FastAPI, UIKit, LLVM or NEEDS CLARIFICATION]

**Storage**: [if applicable, e.g., PostgreSQL, CoreData, files or N/A]

**Testing**: [e.g., pytest, XCTest, cargo test or NEEDS CLARIFICATION]

**Target Platform**: [e.g., Linux server, iOS 15+, WASM or NEEDS CLARIFICATION]

**Project Type**: [e.g., library/cli/web-service/mobile-app/compiler/desktop-app or NEEDS CLARIFICATION]

**Performance Goals**: [domain-specific, e.g., 1000 req/s, 10k lines/sec, 60 fps or NEEDS CLARIFICATION]

**Constraints**: [domain-specific, e.g., <200ms p95, <100MB memory, offline-capable or NEEDS CLARIFICATION]

**Scale/Scope**: [domain-specific, e.g., 10k users, 1M LOC, 50 screens or NEEDS CLARIFICATION]

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Scientific code quality**: [Identify formulation/solver/interface
  boundaries touched; cite applicable docs and compatibility requirements]
- **Testing and reproducibility**: [Name the narrowest tests, MATLAB commands,
  fixtures, logs, or reproducibility checks required for this feature]
- **User experience and diagnostics**: [State expected diagnostic/reporting,
  status, print-level, file-location, or workflow behavior]
- **Performance and numerical integrity**: [State runtime, memory, diagnostic
  volume, residual, scaling, or solver-status constraints and measurements.
  State any performance goal and confirm it is subordinate to solution quality
  (objective, residuals, status, certificate quality must not degrade). If any
  debug/diagnostic/trace/verification step is made skippable for speed, confirm
  it is gated behind a documented, default-on parameter, not removed]
- **External-solver configuration audit**: [For each external solver/library
  this feature invokes, enumerate its relevant configuration surface (options,
  parameters, defaults) and cross-check every default against the problem data's
  structural profile — sparsity, cone types, dimensions, scale. Identify and
  override any default mismatched to that profile (e.g. dense path over sparse
  data), record the chosen settings and rationale, and cite the installed solver
  source/docs and the representative instance used. Write N/A if no external
  solver is invoked]
- **Spec-driven scope control**: [List source paths to edit, read-only paths to
  avoid, migration boundary, and any justified new dependency or abstraction]
- **MATLAB coding standards**: [Confirm: no evalc shadowing built-ins, warnings
  visible, try/catch propagates ME.stack, diary active, no nargin, relevant
  MATLAB best-practice skill consulted or proposed]
- **Parameter-setting fidelity**: [For any feature that ports, reuses, or renders
  code into another language / a literate document: confirm parameter-setting code
  (param.*, model.*, solver options) is not dropped — each parameter's value is
  surfaced as a natural-language translation with the prose that describes it, with
  no blank parameter labels (Principle VIII). Write N/A if the feature renders no
  ported/literate output]
- **Artifact placement**: [For every file this feature creates, moves, or emits,
  confirm its destination follows the Principle IX / docs/repository-layout.md
  placement procedure: src/ holds source only, including diagnostic/analysis
  tooling (no generated .html, executed notebooks, diaries, tables, figures);
  dependency/environment manifests stay at their module root and never under
  logs/; raw immutable input data -> data/, with tracked binary/.mat via Git LFS
  (IX-G) and explicit *.mat un-ignore carve-outs; test fixtures live beside their
  tests; executable scripts -> bin/ (executables only); regenerable output ->
  results/ (gitignored); curated tracked renders -> reports/; run/experiment
  output written into the in-repo results/ tree bundled per run, never a
  hard-coded external path; retired content -> old/ or archive/ (root or nested,
  read-only). List any file whose placement changes]

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md        # Phase 1 output (/speckit-plan command)
├── quickstart.md        # Phase 1 output (/speckit-plan command)
├── contracts/           # Phase 1 output (/speckit-plan command)
└── tasks.md             # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```text
# [REMOVE IF UNUSED] Option 1: Single project (DEFAULT)
src/
├── models/
├── services/
├── cli/
└── lib/

tests/
├── contract/
├── integration/
└── unit/

# [REMOVE IF UNUSED] Option 2: Web application (when "frontend" + "backend" detected)
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# [REMOVE IF UNUSED] Option 3: Mobile + API (when "iOS/Android" detected)
api/
└── [same as backend above]

ios/ or android/
└── [platform-specific structure: feature modules, UI flows, platform tests]
```

**Structure Decision**: [Document the selected structure and reference the real
directories captured above]

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
