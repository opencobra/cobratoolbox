# Feature Specification: src/ Function Header Documentation Compliance

**Feature Branch**: `014-src-header-compliance`

**Created**: 2026-07-17

**Status**: Draft

**Input**: User description: "Go through every .m file in src and check that the header comments comply with the COBRA Toolbox style guide, so it is compatible with the auto generation of website information by the CI on each function. Every input and output should be explained in at least one separate line in the header. If an input is a MATLAB structure, every one of the fields should also be explained; if they are not, interrogate the code to understand what they should be and improve the header. Parallelise the implementation with the agent-assign pipeline."

## Clarifications

### Session 2026-07-17

- Q: For a struct-typed input/output, which fields must the header document? → A: Only the fields the function actually reads or writes (not the entire struct type's schema). The central model-field schema remains single-sourced in `documentation/source/guides/COBRAModelFields.rst`.
- Q: How should clearly third-party/vendored subtrees under `src/` be handled? → A: Exclude them (read-only) from this feature and file a separate follow-up feature to remediate vendored docs deliberately, coordinated with the W9 relocation work (feature 013).
- Q: What should become of the header-compliance checker after this feature? → A: Deliver it as a standing CI gate that fails future changes which regress in-scope `src/` headers (wired into the test/CI harness), not merely a one-shot tool.
- Q: How aggressively should the agent-assign pipeline run across the 1578 files / 243 leaf folders? → A: Full fan-out — assign and execute all six domains in one pipeline run.

## User Scenarios & Testing *(mandatory)*

A COBRA Toolbox contributor edits a function under `src/` and relies on the
openCOBRA CI to regenerate the documentation website automatically from the
function's header. Today ~29% of functions lack a `USAGE:` block, ~31% lack an
`INPUT(S):` block, ~38% lack an `OUTPUT(S):` block, 426 functions document neither
inputs nor outputs, and 85 function files carry a completely empty header. The
generated website is therefore incomplete or wrong for a large fraction of the
public API, and struct-typed arguments (the COBRA model, LP/QP problem structs,
solution structs, parameter structs) rarely list their fields. This feature brings
every audited `src/` function header into conformance with the documentation guide
(`documentation/source/guides/documentationGuide.rst`) and style guide
(`.../styleGuide.rst`), which the constitution binds by reference (Principle VII-E),
so the Sphinx generator produces complete, correctly formatted pages.

### User Story 1 - Objective, repeatable compliance measurement (Priority: P1)

A maintainer needs to know, at any moment, exactly which `src/` function headers
violate which documentation-guide rules, without hand-inspecting 1578 files. This
story delivers an automated header-compliance checker that encodes the
documentation-guide rules and emits a per-file, per-rule, and per-domain report,
plus a committed baseline snapshot of the starting state.

**Why this priority**: Nothing downstream is measurable or verifiable without an
objective oracle. The checker is the acceptance mechanism for every later story and
the standing regression gate that keeps headers compliant after this feature closes.
It delivers immediate standalone value (a compliance dashboard for the codebase)
even if no header is remediated.

**Independent Test**: Run the checker over `src/`; confirm it lists violations with
file, line, rule id, and per-domain counts, exits non-zero when violations exist and
zero when none do, and reproduces the same result on re-run.

**Acceptance Scenarios**:

1. **Given** the current `src/` tree, **When** the checker runs, **Then** it
   produces a machine-readable report enumerating every header-rule violation by
   file and rule, and a per-domain summary count that matches the recorded baseline.
2. **Given** a function whose header is fully compliant, **When** the checker runs on
   it, **Then** it reports zero violations for that file.
3. **Given** a function that is missing an `OUTPUTS:` block for a declared output,
   **When** the checker runs on it, **Then** it flags that specific rule for that file.

### User Story 2 - Every input and output is documented (Priority: P2)

For each audited function, every declared input (including each name-value /
`varargin` parameter that the function actually consumes) and every declared output
is explained on at least one dedicated header line, in the correct keyword block,
with the guide's formatting (colon after the argument name, ≥4-space gap before the
description, one space after `%`, 4-space body indentation, `USAGE:` block present,
one blank comment line before the body).

**Why this priority**: This is the core of the request and the largest share of the
compliance gap. It is independently valuable: once a domain's inputs/outputs are all
documented, that domain's generated pages are usable even before struct fields are
expanded.

**Independent Test**: For a chosen domain, run the checker filtered to the
input/output-coverage and formatting rules; confirm zero violations and that a manual
spot-check of several functions shows each argument documented on its own line.

**Acceptance Scenarios**:

1. **Given** a function `function [a, b] = f(x, y, varargin)`, **When** the checker
   runs, **Then** it confirms `x`, `y`, each consumed `varargin` parameter, `a`, and
   `b` each appear on a dedicated, correctly formatted header line.
2. **Given** a function whose signature declares an output that the header omits,
   **When** remediation is applied, **Then** the header gains a correctly formatted
   line for that output describing what it holds.
3. **Given** a function header with `%text` (no space after `%`) or mis-indented
   argument lines, **When** remediation is applied, **Then** the formatting is
   corrected so the generator no longer ignores or errors on those lines.

### User Story 3 - Struct-typed arguments have their fields documented (Priority: P3)

For every input or output that is a MATLAB struct, each field the function reads or
writes is documented as a `* .field - description` sub-bullet under that argument, at
the guide's indentation. Where fields are currently undocumented, the function body
is interrogated to determine what each field is and holds, and an accurate
description is written.

**Why this priority**: Struct-field documentation is the deepest and most
labour-intensive layer and depends on the argument itself already being documented
(US2). It delivers the highest-fidelity pages (the COBRA model and solver structs are
the toolbox's central data contracts) but is the least blocking for basic page
generation.

**Independent Test**: For a set of functions that take/return structs, confirm the
checker's field-coverage rule passes and that a manual review shows each field's
description matches how the code uses it.

**Acceptance Scenarios**:

1. **Given** a function that reads `model.S`, `model.lb`, `model.ub`, and `model.c`,
   **When** remediation is applied, **Then** the header's `model` argument lists each
   of those fields as a `* .field - description` sub-bullet with an accurate meaning.
2. **Given** a function that returns a `solution` struct with fields set in the body,
   **When** remediation is applied, **Then** each returned field is listed and
   described consistent with what the code assigns to it.
3. **Given** a struct field whose meaning cannot be determined from the body,
   **When** remediation is applied, **Then** the header describes the field as far as
   the code supports and does not fabricate semantics beyond the evidence.

### Edge Cases

- **Script files (no function signature)**: 67 `src/*.m` files are scripts. They have
  no inputs/outputs; they require only a leading description comment block with correct
  `%`-spacing, and the `INPUT`/`OUTPUT`/`USAGE` keyword rules do not apply.
- **Vendored / third-party code still under `src/`**: some `src/` subtrees are
  vendored third-party code carrying upstream authorship and licences (e.g. rBioNet,
  modelBorgifier, cellDesigner, parts of demeter). These are read-only under
  Principles V and IX and MUST be excluded from remediation; the checker records them
  as excluded rather than editing them.
- **Multiple / nested functions in one file**: only the header of the primary
  (first) function in a file is parsed by the Sphinx generator; local/subfunction
  headers are not website-generated and are out of scope for the coverage rules.
- **`varargin` / `inputParser` name-value parameters**: parameters the function never
  actually consumes MUST NOT be invented into the header; only parameters the code
  reads are required to be documented.
- **Argument named but unused, or output assigned conditionally**: the header still
  documents the declared argument/output; the description reflects the conditional or
  optional nature where the code shows it.
- **Deliberately generator-ignored lines**: `Author:` provenance lines and other
  non-generated content use the `% ..` prefix so the generator skips them; this is
  correct and MUST be preserved, not "fixed" into generated content.
- **Behaviour-preserving guarantee**: no executable line, function name, argument
  name, argument order, or algorithm may change; only header comment text and, where
  strictly required for generator correctness, function-signature whitespace.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST provide an automated header-compliance checker that
  parses each `src/*.m` file's function header (the commented block between the
  function signature and the first line of code) and evaluates it against the
  documentation-guide rules, emitting a per-file, per-rule, and per-domain report.
- **FR-002**: The checker MUST record a committed baseline snapshot of the pre-
  remediation compliance state (per-domain and per-rule counts) so before/after
  progress is measurable and reproducible.
- **FR-003**: Every audited function header MUST contain a brief description line and
  a `USAGE:` block that shows the function signature.
- **FR-004**: Every input argument the function actually consumes — including each
  name-value / `varargin` parameter read by the body — MUST be documented on at least
  one dedicated line within an `INPUT:`/`INPUTS:` or `OPTIONAL INPUTS:` block, with a
  colon after the argument name and ≥4 spaces before the description.
- **FR-005**: Every output argument declared in the signature MUST be documented on at
  least one dedicated line within an `OUTPUT:`/`OUTPUTS:` block.
- **FR-006**: For every input or output that is a MATLAB struct, each field the
  function reads or writes MUST be documented as a `* .field - description` sub-bullet
  at the guide's indentation; where a field is undocumented, its description MUST be
  derived by interrogating the function body and MUST NOT fabricate semantics the code
  does not support.
- **FR-007**: Every audited header MUST satisfy the generator's formatting rules:
  exactly one space after `%`; body/argument lines indented 4 spaces after `%`; one
  empty comment line before the function body; canonical signature spacing (space
  after each comma, space before/after `=`); and provenance/`Author` lines prefixed
  with `% ..` so the generator ignores them.
- **FR-008**: The change MUST be behaviour-preserving: no executable code, function
  name, argument name, argument order, algorithm, or public interface (Principle II)
  may change. The verified diff MUST contain only comment and, where strictly
  necessary, signature-whitespace changes.
- **FR-009**: Third-party/vendored subtrees under `src/` and non-primary
  (local/sub)function headers MUST be excluded from the coverage rules and MUST NOT be
  edited; the checker MUST report the excluded set explicitly. Remediation of vendored
  headers is deferred to a separate follow-up feature coordinated with the W9
  relocation work (feature 013); this feature only enumerates and excludes them.
- **FR-013**: The header-compliance checker MUST be delivered as a standing CI gate —
  integrated into the test/CI harness so that a future change regressing an in-scope
  `src/` header (missing/malformed `USAGE`/`INPUT`/`OUTPUT`, undocumented used field,
  or formatting error) causes the check to fail — not merely a one-shot verification
  tool. The gate MUST run headless in CI and MUST NOT require solvers, internet, or GUI.
- **FR-010**: Script files (no function signature) MUST be held only to the
  description and `%`-spacing rules, not the `USAGE`/`INPUT`/`OUTPUT` keyword rules.
- **FR-011**: The work MUST be decomposable into independent per-leaf-folder units
  (243 leaf folders across the six `src/` domains) so it can be assigned and executed
  in parallel via the agent-assign pipeline, with each unit independently checkable.
- **FR-012**: After remediation, the Sphinx documentation build/parse MUST succeed
  for every audited function with no header-format error (no signature-parse error, no
  indentation error).

### Key Entities *(include if feature involves data)*

- **Function header**: the commented block between a function's signature and its
  first executable line; the unit the Sphinx generator parses into a website page.
- **Keyword block**: a header section introduced by a guide keyword (`USAGE:`,
  `INPUT(S):`, `OPTIONAL INPUTS:`, `OUTPUT(S):`, `EXAMPLE:`, `NOTE:`, `Author:`).
- **Struct argument field list**: the `* .field - description` sub-bullets under a
  struct-typed input/output (e.g. the COBRA model structure and its fields such as
  `S`, `mets`, `rxns`, `lb`, `ub`, `c`, `b`, `csense`, `rules`, `grRules`).
- **Compliance report / baseline**: the checker's machine-readable output and its
  committed pre-remediation snapshot used to measure progress.
- **Leaf-folder work unit**: one `src/` directory containing `.m` files, the atomic
  unit of parallel assignment and per-unit verification.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The header-compliance checker reports **zero violations** across all
  in-scope `src/*.m` files for the audited rules (description + `USAGE:` present,
  every input and output documented, struct fields documented, formatting correct).
- **SC-002**: Input/output coverage reaches **100%** of in-scope functions: every
  declared output and every consumed input/name-value parameter is documented on a
  dedicated header line (baseline: 62% have an `OUTPUT` block, 69% an `INPUT` block).
- **SC-003**: For every in-scope function that takes or returns a struct, **100%** of
  the fields the body reads or writes are documented as `* .field` sub-bullets.
- **SC-004**: The Sphinx documentation build/parse over the audited functions
  completes with **no header-format errors** (signature parse and indentation).
- **SC-005**: The verified `git diff` for the remediation contains **only** comment
  and signature-whitespace changes — **zero** changes to executable lines — confirmed
  by an automated diff check across every changed file.
- **SC-006**: Per-domain before/after compliance counts are recorded for all six
  domains, showing the movement from the baseline to zero in-scope violations.
- **SC-007**: The checker is wired into the CI harness as an enforcing gate: an
  intentionally malformed header in an in-scope file causes the CI check to fail, and
  the clean post-remediation tree passes it — both demonstrated headless with no
  solver/internet/GUI dependency.

## Assumptions

- The canonical rule source is the in-repo documentation guide and style guide
  (`documentation/source/guides/documentationGuide.rst`, `.../styleGuide.rst`); the
  live website is their generated view (Principle X) and is not an independent source.
- "Every input/output on a separate line" means each argument (and each consumed
  name-value parameter) has at least one dedicated line; multi-line descriptions for
  one argument are permitted and expected for structs.
- Only the primary (first) function per file is website-generated, so only its header
  is held to the coverage rules; subfunction headers are improved opportunistically
  but not gated.
- Vendored third-party subtrees under `src/` are identified from provenance markers
  (upstream author/licence headers, known package folders) and treated as read-only;
  the exact excluded set is enumerated and recorded during planning/checker setup, and
  their remediation is deferred to a separate follow-up feature (per Clarifications).
- The struct-field bar is "fields the function reads or writes", not the entire struct
  schema; the full COBRA model schema stays single-sourced in `COBRAModelFields.rst`.
- Where a struct field's meaning is genuinely underdetermined by the code, an honest
  best-effort description grounded in usage is acceptable; fabrication is not.
- The remediation is parallelised by leaf folder via the agent-assign pipeline with a
  full fan-out across all six domains in one run (per Clarifications); each spawned
  agent is bound by this constitution and confined to its assigned folder.
- The MATLAB baseline (R2024b+) and headless-CI constraints are unaffected because no
  executable code changes.

## Traceability

<!--
  Documentation/tooling feature: most criteria are discharged by the header-compliance
  checker and the Sphinx doc parse rather than a MATLAB verifiedTests test. The
  NO-SOURCE CONVENTION is used where no single source function is under test.
-->

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1 / FR-001, FR-002 | header-compliance checker run + committed baseline report | — (all in-scope src/*.m; no single source function) |
| US2 / FR-003, FR-004, FR-005, FR-007 | checker input/output-coverage + formatting rules = 0 violations per domain | — (per-domain src/*.m) |
| US3 / FR-006 | checker struct-field-coverage rule = 0 violations + manual field-accuracy spot-check | — (functions taking/returning structs, e.g. src/base/solvers/solveCobraLP.m, src/analysis/FBA/optimizeCbModel.m) |
| FR-008, FR-005 (behaviour preservation) | automated diff check: only comment/whitespace lines changed across all edited files | — (every edited src/*.m) |
| FR-009, FR-010 | checker exclusion report lists vendored subtrees and script files handled by the reduced rule set | — (vendored subtrees + src/*.m scripts) |
| FR-012 | Sphinx documentation build/parse over audited functions with no header-format error | — (all in-scope src/*.m) |
