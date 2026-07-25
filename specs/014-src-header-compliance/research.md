# Phase 0 Research: src/ Function Header Documentation Compliance

## R1 — The documentation generator and the rules it actually enforces

**Decision**: Treat `sphinxcontrib-matlabdomain==0.18.0` (pinned in
`documentation/requirements.txt`, wired in `documentation/source/conf.py` with
`matlab_src_dir` = repo root, `matlab_auto_link="all"`) as the ground-truth parser, and
encode the human-readable rules from `documentation/source/guides/documentationGuide.rst`
as the checker's rule set. The guide is the canonical, repo-single-sourced statement of
what that generator expects (Constitution Principle X); the live website is its rendered
view.

**Rationale**: The guide enumerates exactly the constructs the generator keys on:
keyword blocks (`USAGE:`, `INPUT(S):`, `OPTIONAL INPUTS:`, `OUTPUT(S):`, `EXAMPLE:`,
`NOTE:`, `Author:`), the one-space-after-`%` rule (lines like `%text` are *ignored*),
the 4-space argument indentation (wrong indentation is an *error*), the colon-after-
argument-name rule, the `* .field - description` struct-field sub-bullet form (2 extra
spaces; space between `*` and `.`), the one-empty-comment-line-before-body rule, the
canonical signature spacing (a malformed signature is an *error* during generation), and
the `% ..`-prefixed lines that are deliberately ignored (used for `Author:`).

**Alternatives considered**: (a) Run the full Sphinx build as the checker — rejected as
the primary gate: it is heavy, needs the Python doc toolchain, and reports at page
granularity rather than per-rule/per-file, so it is retained only as a secondary oracle
(SC-004). (b) Reverse-engineer 0.18.0's parser source as the spec — rejected: the guide
is the constitution-sanctioned canonical source and is what human contributors follow;
matching the guide keeps agents and the generator aligned without coupling to a library
internal.

## R2 — Vendored / read-only exclusion set (FR-009)

**Decision**: Exclude from remediation, and mark as "excluded (vendored)" in the checker
report, using a two-part deterministic rule:

1. **Enumerated vendored subtrees** (authoritative):
   - `src/reconstruction/rBioNet/**` — 40 `.m`, 38 carry explicit licence/copyright
     notices (upstream rBioNet by Thorleifsson & Thiele).
   - `src/reconstruction/comparison/modelBorgifier/**` — 39 `.m`, all carry upstream
     authorship + citation (`Sauls, J. T., & Buescher, J. M. (2014)`,
     `johntsauls@gmail.com`).
2. **File-level licence guard**: any `src/*.m` whose header contains an explicit
   software-licence/redistribution notice (`SPDX-License`, `GNU General Public`,
   `redistribution and use`, `permission is hereby granted`, `is free software`) is
   excluded and reported as vendored. This catches ~6 scattered individually-vendored
   files (e.g. under `src/base/solvers`, `src/base/io`, `src/visualization/convert`,
   `src/design/optGene.m`).

**Explicitly IN scope** (candidates that turned out to be COBRA-authored, not vendored):
`src/visualization/cellDesigner/**` (author "Longfei Mao"),
`src/reconstruction/demeter/**` (author "Almut Heinken"),
`src/analysis/wholeBody/PSCMToolbox/**`, `src/visualization/metabolicCartography/**` —
none carry upstream third-party licences; they are remediated normally.

**Rationale**: The clarification set the bar at "code carrying upstream
authorship/licences." Provenance scanning shows only rBioNet and modelBorgifier meet it
at subtree scale; the named candidates cellDesigner and demeter do not. A "Please cite"
string alone is *not* used as an exclusion marker because COBRA-authored files also ask
users to cite the COBRA Toolbox; the citation-plus-upstream-author-email pattern in every
modelBorgifier file, by contrast, establishes vendored provenance for that whole subtree.

**Alternatives considered**: excluding all four named candidates (over-broad — would skip
~170 COBRA-authored files that legitimately need docs); a pure per-file heuristic with no
subtree list (fragile — some rBioNet/modelBorgifier files lack the licence string yet are
still part of the vendored package).

**Impact on scope**: excluded ≈ 79 files (40 + 39) plus ~6 scattered = ~85 of 1578;
in-scope ≈ 1493 `.m` files.

## R3 — Checker technology, placement, and CI-gate integration (FR-001, FR-013, SC-007)

**Decision**: Implement the checker in **MATLAB** as `checkFunctionHeaders.m` (rule
engine over one file's header → list of violations) plus `headerComplianceExclusions.m`
(returns the R2 exclusion globs), and expose it as a `matlab.unittest` test
`testHeaderCompliance.m`, all under `test/verifiedTests/documentation/`. The test is the
standing CI gate: it runs inside `test/testAll.m` and the `testAllCI_*` GitHub Actions
pipelines, headless, with no solver/internet/GUI.

**Rationale**: The primary CI harness for this repo is MATLAB `testAll` (Principle III
requires tests under `test/verifiedTests/<category>/`). A MATLAB test gives the standing
gate "for free" — no bespoke pipeline — and a single source of truth for the rules
(Principle X), avoiding a second Python re-implementation that could drift. `test/` is
the correct home per Principle IX (it is test tooling, not toolbox source, so it must not
go in `src/`). The new category directory `documentation/` mirrors the existing per-
domain test layout.

**Alternatives considered**: (a) a Python checker reusing the docs CI — rejected: two
rule engines (MATLAB gate + Python) = drift risk, and the enforcing gate belongs with
`testAll`. (b) placing the checker in `src/base/` as a public tool — rejected: adds
public API surface for a dev/test utility (scope control, Principle V), and pollutes the
generated website with a tool about the website.

**Performance note**: pure text parsing of ~1500 files in one MATLAB process is
sub-minute; the test adds negligible time to `testAll`. The test SHOULD support scoping
to a subfolder (argument or helper) so remediation agents can self-verify one leaf folder
quickly, while the CI run scans all of `src/`.

## R4 — Determining consumed inputs, name-value parameters, and used struct fields

This is the core interrogation problem for remediation (FR-004, FR-006). **Decision**:
each remediation unit derives header content from the code by the following procedure,
recorded here so every agent applies it uniformly:

- **Declared inputs/outputs**: parse the primary function signature. Every declared
  output gets an `OUTPUTS:` line; every declared input that is not pure `varargin` gets an
  `INPUTS:`/`OPTIONAL INPUTS:` line.
- **Name-value / `varargin` parameters actually consumed**: scan the body for the
  parameter-extraction pattern in use and document only the parameters the code reads:
  - `inputParser` → `addRequired`/`addOptional`/`addParameter('name', default, …)`;
  - direct `varargin` indexing / `numel(varargin)` switch ladders;
  - COBRA idioms: `getCobraSolverParams`, `parseSolverParameters`,
    `parseCobraVarargin`, `struct(varargin{:})` then `.field` reads.
  Parameters the function never reads MUST NOT be invented into the header (Edge Cases).
- **Struct fields used** (the "fields the function uses" bar from Clarifications):
  - for a struct-typed **input** `s`, collect field reads: `s\.(\w+)`, `isfield(s,'f')`,
    `s.(dynName)` where `dynName` is a literal set;
  - for a struct-typed **output** `s`, collect field writes: `s\.(\w+)\s*=`;
  - document each such field as `* .field - description`. Do **not** enumerate the whole
    struct schema (Clarifications) — only the used fields.
- **Field semantics**: for standard COBRA model fields, take the meaning from
  `documentation/source/guides/COBRAModelFields.rst` (e.g. `S`, `mets`, `rxns`, `lb`,
  `ub`, `c`, `b`, `csense`, `osense`, `genes`, `rules`, `grRules`); for LP/QP problem and
  solution structs, from `src/base/solvers/solveCobraLP.m` /
  `src/analysis/FBA/optimizeCbModel.m` headers (`A`, `.stat`, `.origStat`, `.full`,
  `.obj`, `.rcost`, `.dual`); otherwise infer conservatively from the assignment/use and
  do not fabricate meaning the code does not support (FR-006).

**Rationale**: A uniform, code-grounded procedure is what makes 1493 files remediable in
parallel without inventing semantics, and it is exactly the "interrogate the code" step
the user asked for. Cross-referencing the central schema keeps field descriptions correct
(Principle I) and single-sourced (Principle X).

**Alternatives considered**: documenting the full struct schema per function (rejected by
Clarifications — redundant, drift-prone); a purely signature-based header with no field
detail (rejected — fails FR-006 and the user's explicit "every field" requirement scoped
to used fields).

## R5 — Behaviour-preservation verification (FR-008, SC-005)

**Decision**: After each unit and again at the end, verify the diff touches only comment
and signature-whitespace lines via an automated check: for every changed `.m` file, the
set of *non-comment, non-blank* executable lines (after stripping trailing whitespace)
MUST be identical before and after (`git show HEAD:file` vs working copy, compared with
comment/blank lines removed). Any executable-line delta fails the unit.

**Rationale**: This is the objective, scriptable guarantee that a documentation-only
change did not alter behaviour, stronger than manual review across ~1500 files. It also
guards the one permitted exception (signature whitespace) by confirming the *tokenised*
signature is unchanged.

**Alternatives considered**: relying on `testAll` to catch regressions (necessary but not
sufficient — many src functions lack tests, per features 001/007 coverage work); manual
review only (does not scale to 1493 files).

## R6 — Work-unit decomposition for full fan-out (FR-011)

**Decision**: One work-unit per `src/` **leaf folder** (243 folders), each independently
checkable by scoping the checker to that folder. Tasks are grouped in `tasks.md` by
domain for readability, but each leaf folder is an atomic, independently-verifiable
assignment for the agent-assign pipeline, executed in a single full fan-out across all six
domains (per Clarifications). Excluded vendored subtrees produce no remediation unit.

**Rationale**: The leaf folder is the natural independent, conflict-free unit (agents
never touch the same file), matches the existing `src/<domain>/<subfolder>/` layout, and
keeps each unit small enough for one agent to read every file and interrogate the code
carefully. Per-folder scoping of the checker gives each agent an objective local
pass/fail before hand-off.

**Alternatives considered**: one unit per file (243→1578 units, unwieldy for `tasks.md`
and the pipeline); one unit per domain (a 605-file unit is too large for careful per-file
interrogation and struct-field work).
