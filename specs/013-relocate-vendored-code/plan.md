# Implementation Plan: Relocate vendored third-party code and static data blobs out of `src/`

**Branch**: `013-relocate-vendored-code` | **Date**: 2026-07-17 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/013-relocate-vendored-code/spec.md`

## Summary

Relocate vendored non-MATLAB code, static third-party data, orphan scratch, committed generated
artifacts, and a misplaced tutorial out of `src/`, leaving only thin MATLAB wrappers in `src/`.
The change is behavior-preserving: every moved file is byte-identical, and no public MATLAB function
name/signature/documented behavior changes — only the *path-resolution inside the wrappers* is edited,
using the established `CBTDIR = fileparts(which('initCobraToolbox'))` anchor (because `external/` is
added to the MATLAB path only selectively, not wholesale — see research D1). Delivered as three
independently testable slices matching the spec's user stories: **P1 SAMMI**, **P2 Perl+GAMS**,
**P3 data/orphans/generated/tutorial**.

## Technical Context

**Language/Version**: MATLAB (openCOBRA COBRA Toolbox); non-MATLAB assets relocated: JavaScript, Perl,
GAMS. Repo is polyglot-aware (MATLAB + planned Python/Julia).

**Primary Dependencies**: `initCobraToolbox` (init + `CBTDIR` anchor); optional external tools `perl`,
`gams` (may be absent — tests skip).

**Storage**: file relocation only; destinations `external/<domain>/`, `deprecated/`, `tutorials/`, and
a new `data/<domain>/` (gated — see Complexity Tracking).

**Testing**: MATLAB MCP — `mcp__matlab__run_matlab_test_file`, `run_matlab_file`, `check_matlab_code`.
Per-domain baseline captured before any move; compared after each slice.

**Target Platform**: MATLAB on Linux/macOS/Windows (path handling via `filesep`/`CBTDIR`).

**Project Type**: repository-layout / hygiene feature (single project, `src/` tree).

**Performance Goals**: N/A (no solver/algorithm behavior changes). Success is measured by `src/` size
reduction (SC-005) and zero test regressions (SC-004).

**Constraints**: behavior-preserving; no public signature change (II); moves byte-identical (FR-009);
CBTDIR-anchored resolution, never `cwd`/bare `fopen`/`which('<asset>')` (D1); default runtime behavior
of edited wrappers preserved (e.g. SAMMI default output location).

**Scale/Scope**: ~20 code/data files relocated across 5 domains + ~4–7 wrapper edits + `.gitignore` +
docs update marking W9 resolved. `taxa2proc_*.txt` excluded (Clarifications).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Scientific code quality**: No formulation/solver/interface behavior touched. GAMS/OptForce and c13
  wrappers shell out to external tools; only the resolved script/model *path* changes, not invocation
  semantics or results. **PASS**.
- **Testing and reproducibility**: Narrowest tests = touched-domain suites (visualization/SAMMI,
  fluxomics c13, design/optForce, chemoInformatics molecularWeight, thermo groupContribution) + smoke
  (`sammi`, `getMolecularMass`/`computeElementalMatrix`). Baseline captured pre-move; compared per slice
  (SC-004). Reproducibility via MATLAB MCP. **PASS**.
- **User experience and diagnostics**: No diagnostic/print-level/status changes. File-location
  convention *is* the subject: `src/` becomes source-only for the targeted classes; generated HTML/cache
  no longer committed. **PASS**.
- **Performance and numerical integrity**: N/A — no solver/residual/scaling behavior. No debug/verify
  step is made skippable. **PASS (N/A)**.
- **External-solver configuration audit**: N/A — no external *solver* configuration surface is invoked
  or changed (GAMS is shelled out with unchanged arguments; no LP/QP solver options touched). **PASS
  (N/A)**.
- **Spec-driven scope control**: This IS the explicit repository-layout feature that authorizes the
  moves (V/IX). Source paths edited: the wrappers listed in data-model.md. Read-only/avoid: any
  file not in the manifest; `taxa2proc_*.txt`. New convention introduced: top-level `data/` — see
  Complexity Tracking. **PASS with tracked item**.
- **MATLAB coding standards**: Wrapper edits keep warnings visible, propagate `ME.stack`, use
  `filesep`/`CBTDIR` (never absolute hard-coded paths), no `evalc` shadowing, no `nargin`-based arg
  handling introduced. `check_matlab_code` run on each edited wrapper. **PASS**.
- **Parameter-setting fidelity**: N/A — no ported/literate output rendered. **PASS (N/A)**.
- **Artifact placement (IX)**: Destinations by role: third-party code → `external/`; retired/orphan →
  `deprecated/`; tutorial → `tutorials/`; generated → removed + gitignored; static third-party data →
  new `data/` (role not yet in the IX map — tracked). **PASS with tracked item**.

**Gate result: PASS** — with one tracked complexity (the `data/` convention) that gates only the P3
static-data sub-slice, not P1/P2 or the rest of P3.

## Project Structure

### Documentation (this feature)

```text
specs/013-relocate-vendored-code/
├── plan.md              # This file
├── research.md          # Phase 0 (D1–D9 decisions)
├── data-model.md        # Phase 1 relocation manifest
├── quickstart.md        # Phase 1 validation guide
├── spec.md              # Feature spec (Bundle 1)
├── human-loop.md        # Orchestration state
└── checklists/          # requirements.md, relocation-safety.md
```

(No `contracts/`: this feature exposes no new external interface. The preserved contract is the set of
unchanged public wrapper signatures, verified by diff scope — SC-006.)

### Source Code (repository root)

```text
src/                         # wrappers STAY here; only path-resolution edited
├── visualization/SAMMIM/    # EDIT sammi.m (CBTDIR template + script-src); MOVE *.js/*.css/index.html → external/; demo.json → deprecated/; delete generated *.html
├── dataIntegration/
│   ├── fluxomics/c13solver/ # EDIT generateIsotopomerSolver.m; MOVE *.pl → external/
│   └── chemoInformatics/molecularWeight/  # EDIT parse_Atomic_Weights...m; MOVE NIST .txt → data/
├── design/optForceGAMS/     # EDIT optForceWithGAMS.m, findMust*WithGAMS.m; MOVE *.gms → external/
├── base/
│   ├── solvers/gams/        # EDIT getAvailableGAMSSolvers.m; MOVE licememo.gms → external/
│   └── io/python/tmp/       # MOVE (orphan) → deprecated/
├── reconstruction/metaboRePort/           # MOVE VMH_reactionList.xlsx → data/ (+ harden loader)
├── analysis/wholeBody/PSCMToolbox/.../inputData/  # MOVE Parsed_hmdbConc.xlsx → data/
├── analysis/thermo/groupContribution/wang/cache/  # DELETE *.mat + gitignore
└── visualization/entropicFBA/tutorial_eFBA.mlx    # MOVE → tutorials/analysis/

external/                    # destination for vendored CODE (mirrors src/<domain>/, already exists)
deprecated/                  # destination for orphans (already exists; underscore-prefixed subdirs)
tutorials/                   # destination for the .mlx (already exists; per-domain subdirs)
data/                        # NEW top-level for static third-party DATA (gated — Complexity Tracking)
.gitignore                   # ADD generated-artifact patterns (wang/cache, SAMMI generated HTML)
analysis/WEAKNESSES.md, analysis/ARCHITECTURE.md  # UPDATE to mark W9 resolved (Principle X)
```

**Structure Decision**: Single-project `src/` tree. Wrappers remain in `src/`; assets move to their
role-correct homes; resolution is CBTDIR-anchored. Slice ordering P1 → P2 → P3, each independently
testable; the P3 static-data sub-slice is gated on the `data/` constitution amendment.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|--------------------------------------|
| New top-level `data/` role (not in constitution IX v1.3.0 role map) | User clarify chose a dedicated resource path *separate from* `external/`; `binary/` is compiled binaries only; static data must leave `src/` (the weakness) | Reusing `external/` rejected (clarify said separate); keeping data in `src/` rejected (it is the W9 defect). Resolution: a companion `/speckit-constitution` amendment adds the `data/` role; the P3 static-data sub-slice is gated on it. P1, P2, and the orphan/generated/tutorial parts of P3 need no new convention and proceed regardless. |
