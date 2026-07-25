# Implementation Plan: src/ Function Header Documentation Compliance

**Branch**: `014-src-header-compliance` | **Date**: 2026-07-17 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/014-src-header-compliance/spec.md`

## Summary

Bring every in-scope `src/*.m` function header into conformance with the openCOBRA
documentation guide (`documentation/source/guides/documentationGuide.rst`) and style
guide, so the CI documentation build (`sphinxcontrib-matlabdomain==0.18.0`) generates
complete, correctly formatted pages. The work has two coupled deliverables: (1) a
MATLAB header-compliance checker delivered as a standing CI gate under
`test/verifiedTests/documentation/`, which encodes the guide's rules and emits a
per-file/per-rule/per-domain report; and (2) behaviour-preserving remediation of the
headers themselves — a `USAGE:` block, every consumed input and every declared output
on a dedicated line, and every struct field the function *uses* documented as a
`* .field - description` sub-bullet — applied in a full fan-out across all six domains
via the agent-assign pipeline, one work-unit per `src/` leaf folder. Vendored subtrees
carrying upstream authorship/licences are excluded and deferred to a follow-up feature.

## Technical Context

**Language/Version**: MATLAB R2024b+ (the checker and its test are MATLAB; remediation
edits are `%` comment text inside `.m` files). No new language is introduced.

**Primary Dependencies**: the documentation generator `sphinxcontrib-matlabdomain==0.18.0`
(already pinned in `documentation/requirements.txt`) is the ultimate parsing oracle; the
checker itself uses only base MATLAB (`fileread`, `regexp`, `dir`). No new dependency.

**Storage**: N/A. Inputs are `.m` source files; outputs are edited headers plus a
machine-readable compliance report (a feature-time measurement artifact).

**Testing**: `matlab.unittest` test `testHeaderCompliance.m` under
`test/verifiedTests/documentation/`, run by `test/testAll.m` and the `testAllCI_*`
GitHub Actions pipelines, headless (`matlab -batch`), no solver/internet/GUI. The test
is the standing CI gate (SC-007). The Sphinx parse over audited functions is the
secondary oracle (SC-004).

**Target Platform**: headless Linux CI in Docker (Xvfb for display), MATLAB `-batch`.

**Project Type**: MATLAB toolbox — documentation-tooling + mass header remediation.

**Performance Goals**: the checker scans all ~1578 `src/*.m` files in a single MATLAB
process in well under a minute (pure text parsing, no model/solver load); it must not
add meaningful wall-clock to `testAll`.

**Constraints**: behaviour-preserving — the verified diff contains only `%`-comment
text and, where strictly required, function-signature whitespace; zero executable-line
changes (SC-005). No solver, internet, or GUI dependency in the checker. Headless-CI
and MATLAB R2024b+ baseline are unaffected because no executable code changes.

**Scale/Scope**: 1578 `src/*.m` files (1511 functions, 67 scripts); 243 leaf folders;
6 domains (analysis 605, base 239, dataIntegration 248, reconstruction 316, design 60,
visualization 110). Vendored subtrees (see research.md) are excluded from that count.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Scientific code quality**: No model math, formulation, solver, or public interface
  is touched — the change is documentation-only and behaviour-preserving (FR-008). The
  one correctness surface is *accuracy of struct-field descriptions*: descriptions of
  COBRA model / LP-QP problem / solution struct fields (`S`, `mets`, `rxns`, `lb`, `ub`,
  `c`, `b`, `csense`, `osense`, `A`, `.stat`, `.full`, `.obj`, …) MUST match their
  established semantics per `COBRAModelFields.rst` and the code's actual usage
  (Principle I); descriptions are derived by interrogating the function body and MUST
  NOT fabricate meaning (FR-006).
- **Testing and reproducibility**: The narrowest test is `testHeaderCompliance.m`
  (`matlab.unittest`) asserting zero in-scope violations, run in `test/testAll.m` and
  CI. A committed baseline report (`specs/014-.../reports/baseline.md`) records the
  pre-remediation state for reproducible before/after measurement. A diff-only-comments
  check (SC-005) and the Sphinx parse (SC-004) are the supporting verifications.
- **User experience and diagnostics**: The checker prints a bounded per-domain summary
  gated behind a `printLevel` argument and writes a machine-readable report; it does not
  spam the console. Default output is the summary line count per domain.
- **Performance and numerical integrity**: No numerical behaviour changes; solution
  quality, status semantics, residuals, and objective values are untouched (no
  executable code changes). The only performance concern is checker runtime, bounded as
  above; no diagnostic/verification step is removed.
- **External-solver configuration audit**: N/A — the feature invokes no external solver
  or optimisation library. The checker performs text parsing only.
- **Spec-driven scope control**: Editable paths = in-scope `src/**/*.m` **header
  comment lines** (and signature whitespace only where the generator requires it) +
  new files under `test/verifiedTests/documentation/`. Read-only / excluded = vendored
  `src/` subtrees (research.md), `external/`, `deprecated/`, `binary/`, and every
  non-comment line of every source file. No new runtime dependency or abstraction is
  introduced.
- **MATLAB coding standards**: The checker follows VII-A…G — no `evalc` shadowing
  built-ins; warnings surfaced; `try/catch` includes `ME.stack`; optional args via
  `exist`/`isempty` not `nargin`; canonical signature spacing; and the openCOBRA header
  keyword format. The MATLAB best-practice skill (`matlab-review-code`) is consulted for
  the checker code (VII-F). Remediation touches only comment text.
- **Parameter-setting fidelity**: N/A — the feature renders no ported or literate
  output; it edits header comments in place (Principle VIII not engaged).
- **Artifact placement**: checker + test → `test/verifiedTests/documentation/` (test
  harness, Principle IX); excluded-subtree list → a data file beside the checker;
  baseline/measurement reports → `specs/014-src-header-compliance/reports/` (feature
  artifact, not committed into `src/`); header edits → in place in `src/**/*.m`. No
  generated artifact is written under `src/`. No file is relocated.

**Result**: PASS. No violations; Complexity Tracking is empty.

## Project Structure

### Documentation (this feature)

```text
specs/014-src-header-compliance/
├── plan.md              # This file
├── spec.md              # Feature specification (+ Clarifications)
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output — the rule set + work-unit model
├── quickstart.md        # Phase 1 output — how to run the checker + verify
├── contracts/
│   └── header-rules.md  # Phase 1 output — the checker's rule contract
├── reports/             # baseline.md + post-remediation reports (measurement)
└── tasks.md             # Phase 2 output (/speckit-tasks — NOT created here)
```

### Source Code (repository root)

```text
test/verifiedTests/documentation/          # NEW — the checker + CI gate
├── testHeaderCompliance.m                 # matlab.unittest test = standing CI gate
├── checkFunctionHeaders.m                 # rule engine: parse a header, return violations
├── headerComplianceExclusions.m           # returns the vendored/excluded path globs
└── checkCommentsOnly.sh                    # behaviour-preservation verifier (comments-only diff)

src/analysis/**/*.m                         # header-comment remediation (in place)
src/base/**/*.m                             # header-comment remediation (in place)
src/dataIntegration/**/*.m                  # header-comment remediation (in place)
src/design/**/*.m                           # header-comment remediation (in place)
src/reconstruction/**/*.m                   # header-comment remediation (in place, minus vendored)
src/visualization/**/*.m                    # header-comment remediation (in place)

test/testAll.m                              # (already) discovers the new category dir
```

**Structure Decision**: The checker lives in the test harness
(`test/verifiedTests/documentation/`) rather than `src/`, because it is CI/test
tooling, not toolbox source (Principle IX). It ships as a `matlab.unittest` test so it
runs automatically inside `test/testAll.m` and the `testAllCI_*` pipelines, giving the
standing gate required by SC-007 with no bespoke harness. Remediation edits are applied
in place to `src/**/*.m` headers, decomposed one work-unit per leaf folder (FR-011) for
parallel agent-assign execution. Measurement artifacts stay under the feature's
`specs/.../reports/` directory, never under `src/`.

## Complexity Tracking

> No Constitution Check violations. No entries.
