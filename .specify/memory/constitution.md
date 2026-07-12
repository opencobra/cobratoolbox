<!--
Sync Impact Report
Version change: 1.0.0 -> 1.1.0
Modified principles:
- III. Testing, Reproducibility, And Continuous Integration (added openCOBRA
  test-guide conventions: prepareTest requirement declaration, assert-with-
  tolerance, input/output arity coverage, solution-feasibility checks, printLevel
  output control — bound by reference to the canonical test guide).
- VII. MATLAB Coding Standards And Agent Skill Discovery (added VII-G: openCOBRA
  Contribution Conventions — agents follow the same style guide, documentation/
  header-keyword format, and naming conventions as human contributors).
- IX. Repository File Organization And Artifact Placement (added the "new code goes
  in a new subfolder under the correct src/<domain>" rule and the PR-to-develop
  target from the contribution workflow).
Added principles:
- X. Documentation Single-Sourcing And No Instruction Leakage (each rule has one
  canonical home; project-authored agent-instruction files point to the constitution
  rather than restate it; agent/LLM instructions do not leak into general repository
  docs; per-agent Spec Kit command/skill mirrors are exempt generated machinery).
Modified sections:
- Scientific Computing Constraints (now cites the openCOBRA style, test, test-
  template, and documentation guides as the canonical contribution references).
- Development Workflow And Quality Gates (added Git commit-message conventions from
  the contribution guide).
Rationale for MINOR bump: one new principle plus materially expanded compliance
requirements in three principles; no principle removed or redefined.
Agent-agnostic note: this fork supports multiple Spec Kit agents (Claude via
`.claude/`, Codex and others via `.agents/`). All principles are agent-neutral;
`AGENTS.md` is the agent-neutral instruction file and `CLAUDE.md` is the Claude
surface — both are thin pointers to this constitution per Principle X.
Templates and runtime guidance:
- reviewed: .specify/templates/plan-template.md, spec-template.md, tasks-template.md
  (Constitution Check bullets remain applicable).
Follow-up TODOs:
- Consider a dedicated docs/agent-contribution-notes.md only if the by-reference
  binding below proves insufficient in review (avoid duplicating the online guide).
-->
<!--
Sync Impact Report
Version change: (VK constitution replaced) -> 1.0.0
Provenance: Spec Kit scaffolding imported from the variationalKinetics project.
The variational-kinetics-specific constitution (MOSEK exponential-cone numerics,
VarKinExp run layout) was NOT carried over. This is a fresh COBRA Toolbox
constitution authored for MATLAB-first, polyglot-bound constraint-based
reconstruction and analysis development.
Principles (initial ratification):
- I. Scientific And Numerical Correctness Of Constraint-Based Models
- II. Backward Compatibility And Public Interface Stability
- III. Testing, Reproducibility, And Continuous Integration
- IV. Solver Abstraction, Numerical Integrity, And Performance
- V. Spec-Driven Scope Control And Agent Discipline
- VI. Strict Spec-Driven Development Gate
- VII. MATLAB Coding Standards And Agent Skill Discovery
- VIII. Polyglot Interoperability And Cross-Language Fidelity
- IX. Repository File Organization And Artifact Placement
Supporting sections: Scientific Computing Constraints; Development Workflow And
Quality Gates; Implementation Receipt Ledger; Agent And Review Workflow;
Governance.
-->

# COBRA Toolbox Constitution

The COBRA Toolbox is a MATLAB library for COnstraint-Based Reconstruction and
Analysis of biochemical networks, maintained by the openCOBRA community. This
constitution governs how the toolbox — and this fork's evolution toward a
polyglot (MATLAB + Python + Julia) version with additional capabilities — is
developed under a spec-driven workflow. It is the single source of truth for how
to work in this repository and supersedes conflicting local habits.

It is agent-neutral: it binds every Spec Kit-compatible agent equally (for example
Claude via `.claude/`, Codex and others via `.agents/`) as well as human
contributors. Automated agents follow the same openCOBRA contribution conventions
as human contributors, with the additional discipline of the Spec Kit gate.

## Core Principles

### I. Scientific And Numerical Correctness Of Constraint-Based Models

All code changes MUST preserve the mathematical and biological meaning of the
constraint-based models the toolbox operates on. Implementation convenience,
shorter code, or faster runtime MUST NOT take priority over correctness.

The canonical COBRA model is a stoichiometric constraint system. The following
objects and their semantics MUST remain explicit and correct in code, comments,
specifications, and diagnostics:

* the stoichiometric matrix `S` (and coupling `C`/`d` where present) and its
  row/column correspondence to `mets` and `rxns`;
* reaction bounds `lb`/`ub`, objective `c`, right-hand side `b`, constraint sense
  `csense`, and optimization sense `osense`/`osenseStr`;
* gene–protein–reaction associations (`genes`, `rules`, `grRules`) and any
  subsystem, compartment, or annotation fields a feature touches;
* the distinction between a model's *definition* and the *result* of an analysis
  (FBA/FVA/sampling/optimization outputs), and between primal and dual quantities
  (fluxes `v`, reduced costs `w`, shadow prices `y`);
* feasibility and optimality status versus a returned candidate point.

Public model fields MUST remain consistent with the openCOBRA unified model-field
specification documented at https://opencobra.github.io/cobratoolbox/. New
mathematical objects introduced in comments, specifications, or documentation MUST
state their domain and dimensions; matrix–vector notation is preferred.

Rationale: the COBRA Toolbox is scientific software used across the metabolic
modelling community. A change that silently alters the stoichiometry, bounds,
objective sense, or status semantics is a scientific defect even if the code runs
without error.

### II. Backward Compatibility And Public Interface Stability

The COBRA Toolbox has a large installed user base and downstream dependents.
Public interfaces MUST remain backward-compatible unless a feature specification
explicitly approves and documents a breaking change with a migration path.

The following are public contract surfaces and MUST NOT change incompatibly
without explicit spec approval:

* exported function names, argument order, and documented option/parameter names;
* COBRA model structure field names and their meaning;
* solver-interface behaviour (`changeCobraSolver`, `solveCobraLP`,
  `solveCobraQP`, `solveCobraMILP`, `solveCobraMIQP`, and the solution-structure
  fields they return, including `.stat`/`.origStat`, `.full`, `.obj`);
* the initialization contract of `initCobraToolbox`.

Deprecation, not deletion, is the default: superseded functionality moves to
`deprecated/` (or is shimmed with a deprecation warning) rather than being removed
outright, so existing user scripts continue to run. New optional arguments MUST
default to the historical behaviour.

Rationale: reproducibility of published analyses depends on stable interfaces.
Silent interface drift breaks user pipelines and invalidates prior results.

### III. Testing, Reproducibility, And Continuous Integration

Every behavioural change MUST include the narrowest practical automated test
before it is considered complete, integrated into the existing harness rather than
a bespoke one. This principle adopts the openCOBRA test guide (cited in Scientific
Computing Constraints) as its binding detail; the rules below are the load-bearing
subset that agents most often need.

* New or changed behaviour MUST be covered by a test under
  `test/verifiedTests/<category>/` that runs within `test/testAll.m` and the CI
  pipelines (GitHub Actions `testAllCI_*`, `.artenolis.yml`, and `codecov.yml`
  coverage). Every new code module ships with a corresponding test.
* Tests MUST declare their requirements with `prepareTest` (for example
  `solvers = prepareTest('needsLP', true)`, `requireOneSolverOf`,
  `requiredSolvers`, `requiredToolboxes`, `needsUnix`/`needsWindows`/`needsMac`)
  so they skip gracefully when a required solver, toolbox, or OS is unavailable
  rather than failing spuriously.
* Tests MUST use `assert`-based checks; equality asserts are for integer/discrete
  values only, and floating-point comparisons MUST use a justified tolerance
  (for example `tol = 1e-9; assert(abs(a - b) < tol)`). Use
  `verifyCobraFunctionError` (or equivalent) for expected-failure paths.
* Where a function has optional inputs/outputs, tests SHOULD cover the meaningful
  input/output arities, and optimization tests MUST verify that a returned solution
  actually satisfies the imposed constraints — not merely that a call returned.
* Tests MUST keep console output minimal (gated behind `verbose`/`printLevel`),
  avoid internet access and GUI interaction, and fix random seeds so they are
  reproducible and CI-friendly (headless Linux/Docker).

Where a full automated test is not yet practical, a documented reproducibility
check (a script plus expected output/trace and the reason automation is deferred)
is the minimum acceptable substitute. After implementation the contributor MUST
report files changed, checks run, tests passed, tests failed, and behaviours not
yet verified.

Rationale: a single successful run is not evidence. The toolbox needs reproducible
CI-backed evidence that the intended behaviour changed for the intended reason and
that nothing else regressed. Declaring requirements via `prepareTest` is what keeps
the community's heterogeneous solver installations green.

### IV. Solver Abstraction, Numerical Integrity, And Performance

The toolbox supports many optimization solvers behind a unified interface.
Changes MUST preserve that abstraction and MUST NOT bind analysis code to a single
solver's idioms.

* New solver support or solver-facing changes MUST go through the
  `solveCobra*`/`buildOptProblemFromModel` layer, MUST remain compatible with
  `changeCobraSolver`, and MUST map solver-native statuses onto the toolbox's
  canonical `.stat` semantics, preserving `.origStat`. Analysis code MUST avoid
  solver-specific assumptions and remain solver-independent where possible.
* Performance improvements MUST preserve numerical meaning first. Optimisations
  MUST NOT suppress warnings, remove material diagnostics, skip verification, or
  silently substitute a different algorithmic or solver path.
* Performance is a standing objective strictly subordinate to correctness. A
  performance change MUST NOT degrade returned solution quality — objective value,
  feasibility, primal/dual values, or status semantics. Genome-scale models have
  thousands of reactions and metabolites: prefer sparse matrices and vectorised
  operations, and avoid repeated solver calls inside loops.
* For each external solver or library a feature invokes, the plan or a Phase-0
  research note MUST enumerate the relevant configuration surface (options,
  tolerances, and defaults) and cross-check the defaults against the structural
  profile of the problem data actually passed (sparsity, dimensions, scale, integer
  vs continuous). Mismatched defaults MUST be identified and overridden, with the
  chosen settings and rationale recorded.

Rationale: the most common performance defect in this domain is a library default
that is wrong for the problem's data structure. A configuration-surface audit
catches it before it causes a runtime or memory blow-up, while the solver
abstraction keeps analyses portable across the community's solver installations.

### V. Spec-Driven Scope Control And Agent Discipline

Functional changes, new capabilities, and refactors MUST be driven by a feature
specification, implementation plan, and task list. Each change MUST stay within
the smallest coherent dependency set needed for the active feature.

New dependencies, helper files, frameworks, abstractions, or repository-layout
changes MUST be justified by a feature need and documented in the plan. Read-only,
historical, `deprecated/`, `external/`, or vendored third-party paths MUST NOT be
edited unless the feature is explicitly about those paths.

For substantial changes, the relevant file(s) MUST be read and mapped before
editing. Grep-only edits are insufficient for algorithmic changes. A patch that
fixes one local line while breaking surrounding model, solver, or I/O logic is not
acceptable. Agent-generated patches MUST be reviewed for scientific meaning, not
only syntactic correctness.

Rationale: controlled scope prevents unrelated code movement in a large toolbox
from masking the behaviour under review.

### VI. Strict Spec-Driven Development Gate

Implementation work MUST NOT begin from an ordinary natural-language request. The
default route for any non-trivial code, test, solver, algorithm, data-model,
interface, build-file, script, or source-controlled implementation-artifact change
is the Spec Kit workflow.

Ordinary requests such as "fix this", "implement this", "make the code do this",
"apply the above advice", "try again", "now edit the code", or "add this function"
MUST NOT by themselves authorize implementation edits. Such requests MUST be
treated as requests to enter or continue the Spec Kit workflow unless the required
artifacts already exist and the user explicitly invokes the implementation phase.

For any non-trivial implementation change, the required phase order is:

```text
constitution
specify
clarify, if requirements are ambiguous
plan
tasks
analyze, if available
implement
```

The implementation phase MUST NOT begin until the active feature has an approved
or current `spec.md`, `plan.md`, and `tasks.md`, any required clarification or
analysis artifacts, and no unresolved blockers that would make implementation
speculative.

Implementation files may be modified only when the user explicitly invokes the
implementation phase with the agent's implementation command (for example
`/speckit.implement`, `/speckit-implement`, or `$speckit-implement`), or a direct
instruction that explicitly says: `Run the Spec Kit implementation phase for the
active feature`. A request that merely describes what should be implemented is not
sufficient.

These requirements are agent-neutral: they apply identically whichever agent or
model is in use (Claude, Codex, or another Spec Kit-compatible agent). Where a rule
names an agent-specific command, directory, or response label, the equivalent
artifact for the active agent satisfies the rule.

Planning-only prompts MUST stop before code edits. If the user asks for a prompt,
plan, design, explanation, debugging advice, research, or Spec Kit planning, the
agent MUST produce or update only permitted planning artifacts and MUST stop
before implementation.

Brownfield changes are not exempt. Existing-code and bug-fix work MUST either
attach to an active feature whose `spec.md`, `plan.md`, and `tasks.md` cover the
change, or create/update those artifacts before implementation.

Direct implementation without the full Spec Kit workflow is allowed only when the
user explicitly uses this exact override phrase:

```text
DIRECT IMPLEMENTATION OVERRIDE: bypass Spec Kit for this change.
```

When that exact override is present, the agent MUST keep the change minimal, state
that the Spec Kit workflow was bypassed, record the reason, run or identify
appropriate validation, and recommend backfilling a Spec Kit artifact if the change
is more than a trivial local correction. Without that exact override phrase, direct
code changes are prohibited.

When implementation occurs through the Spec Kit implementation phase, the
implementation receipt is mandatory (see Implementation Receipt Ledger).
Implementation is not complete unless the receipt exists.

If the user asks for direct code changes before Spec Kit prerequisites exist, the
agent MUST refuse to edit code and report the next required Spec Kit phase, briefly,
naming the next command (for example `/speckit.specify`, `/speckit.tasks`, or
`/speckit.implement`).

Every implementation decision MUST be auditable back to the constitution, the
active feature specification, the plan, a specific task in `tasks.md`, and the
implementation receipt. This principle has precedence over convenience, speed, and
agent initiative. When in doubt, the agent stops before editing code and asks which
Spec Kit phase to run next.

Rationale: accidental direct edits can change scientific behaviour or break a public
interface without a reviewable requirement, plan, task, or receipt. The gate makes
implementation traceability a non-negotiable safety property.

### VII. MATLAB Coding Standards And Agent Skill Discovery

All MATLAB code written or modified in this repository MUST comply with the
following mandatory rules, which apply to every agent, contributor, and automated
workflow.

#### VII-A. evalc Suppression Prohibition

`evalc` MUST NOT be used to call a function whose side effects (warnings,
diagnostic output, console text) are being deliberately suppressed. The only
permitted use is to capture output text that cannot be obtained otherwise, and the
captured output variable MUST use a unique name that does not shadow any MATLAB
built-in (never `summary`, `max`, `min`, `size`, `length`, `error`, `warning`, and
the like).

#### VII-B. Warning Visibility

MATLAB warnings MUST NOT be suppressed, routed away, or swallowed. Any warning a
called function emits MUST surface to the console so a developer or agent can
observe and act on it. When a warning appears during development or testing, the
agent MUST read and act on the warning text before proceeding; warnings such as
"Identifier X does not refer to the external function" identify latent defects, not
cosmetics.

#### VII-C. Try/Catch Error Propagation With Stack

Every `try/catch ME` block MUST propagate full `ME` information when reporting or
re-throwing. `ME.stack` MUST be included in any diagnostic string or log that
records the failure (at minimum `ME.message` plus `ME.stack(1).file` and
`ME.stack(1).line`). Catch blocks MUST NOT reduce the error to only `ME.message`,
and MUST NOT be used to bypass or defer a fixable defect.

#### VII-D. Optional Arguments Without nargin

New or refactored functions SHOULD prefer explicit existence/emptiness checks over
`nargin` for optional-argument handling:

```matlab
if ~exist('varName', 'var') || isempty(varName)
    varName = defaultValue;
end
```

This pattern is robust to both absent arguments and explicitly passed empty values.
Where an existing public function's argument contract is defined by `nargin`,
changing it is an interface change subject to Principle II and MUST NOT be done
incidentally.

#### VII-E. Function Documentation And Provenance

New or substantially revised functions MUST carry the openCOBRA help header so the
Sphinx documentation generator can parse it. The header is the commented block
between the signature and the first line of code, and MUST use the keyword blocks
`USAGE:`, `INPUTS:`/`INPUT:`, `OPTIONAL INPUTS:`, `OUTPUTS:`/`OUTPUT:`, `EXAMPLE:`,
`NOTE:`, and `Author:` as applicable. Formatting rules that the generator enforces
(and that agents therefore MUST follow): one space after `%`; argument lines
indented four spaces after `%` with a colon after each argument name; one empty
line before/after each keyword and one empty comment line before the function body;
lines beginning `% ..` are ignored by the generator. The function signature MUST be
spaced canonically, for example
`function [a, b] = someFunction(in1, in2)`. Documentation MUST be updated in the
same change as the behaviour it describes.

#### VII-F. MATLAB Best-Practice Skill Discovery

Before writing or significantly revising MATLAB code, the implementing agent MUST
(1) search for a registered skill covering MATLAB coding conventions or linting and
apply it if present; (2) if none exists, perform a targeted search of authoritative
MATLAB best-practice sources (MathWorks documentation, the MATLAB Style Guidelines
cited in the openCOBRA style guide), summarise the applicable rules, and propose
adding a project skill. Agents MUST NOT assume that general software-engineering
practice translates directly to MATLAB's conventions around vectorisation,
pre-allocation, handle classes, and function scoping, and MUST NOT propose
Python-style refactors of MATLAB code.

#### VII-G. openCOBRA Contribution Conventions

Agents and human contributors follow the same openCOBRA contribution conventions;
the canonical statement is the style, documentation, and test guides cited in
Scientific Computing Constraints, and it is binding by reference rather than
restated in full here. The load-bearing conventions are: descriptive `camelCase`
names with a verb–noun structure for functions and an `is`/`Is` prefix for booleans;
spaces around operators and after commas; `if singleCondition` without parentheses;
platform-independent paths using `filesep` and `pwd` (never absolute paths encoded
in a function); sanity checks that raise a `warning` or `error` on unexpected
state; and output kept minimal and gated behind `verbose`/`printLevel`. Where these
conventions and a MATLAB best-practice skill (VII-F) disagree, the openCOBRA guide
controls for this repository.

Rationale: MATLAB has a language-specific defect corpus and the openCOBRA project
has an established, documentation-generator-coupled convention set. Binding agents
to the same conventions as human contributors keeps the codebase uniform and keeps
the automatic documentation build green, without duplicating the guide's text
(Principle X).

### VIII. Polyglot Interoperability And Cross-Language Fidelity

The fork's goal is a polyglot COBRA Toolbox (MATLAB plus Python and/or Julia
capabilities). Cross-language work MUST preserve a single source of truth and MUST
NOT let language bindings silently diverge from the MATLAB reference behaviour.

* The COBRA model schema and the semantics of an analysis are language-neutral
  contracts. A Python or Julia binding, port, or wrapper MUST reproduce the MATLAB
  reference result within a justified tolerance, and any deliberate difference MUST
  be documented in the feature spec.
* New language surfaces MUST live in a clearly delimited subtree with that
  language's own package layout and dependency manifest (see Principle IX), and MUST
  be covered by tests that check parity against the MATLAB reference on at least one
  representative model.
* When MATLAB code is ported, reused, or rendered into another language or a
  literate document, parameter-setting code MUST NOT be silently dropped. Wherever a
  parameter assignment is not translated into executable target-language code, its
  effect MUST still be surfaced — the parameter name together with the value or
  expression it is set to (for example `param.* = ...`), placed with the prose that
  describes it. No descriptive parameter label may be shown with a blank value.

Rationale: reproducibility and comprehension across languages. A polyglot toolbox is
useful only if each language surface computes the same science; a port that keeps
the prose but discards the parameter assignments leaves users unable to tell what
was actually configured.

### IX. Repository File Organization And Artifact Placement

Every file MUST be placed by its role, honouring the established COBRA Toolbox
layout. New Spec Kit work MUST NOT reorganise the existing tree except through an
explicit repository-layout feature.

The binding role map for this repository is:

* `src/` — toolbox source code, organised by domain: `analysis/` (methods that
  analyse existing models), `base/` (shared utilities, IO, solver helpers),
  `dataIntegration/` (omics/experimental-data integration), `design/` (strain-design
  and intervention algorithms), `reconstruction/` (model construction/curation), and
  `visualization/` (plots, diagrams). New code SHOULD be added as a **new subfolder**
  under the most appropriate domain (for example `src/analysis/myNewAnalysisTool/`).
  Source only; generated artifacts MUST NOT be committed here.
* `test/` — the test suite: `test/verifiedTests/<category>/test*.m`, run via
  `test/testAll.m` and the CI harness. Small test fixtures/models live with the
  tests that consume them (or under `test/models/`).
* `tutorials/` — user-facing tutorials and their assets.
* `documentation/` and `DevelopersDocumentation/` — documentation sources for the
  Sphinx site; generated HTML is not committed to source.
* `external/` — third-party/vendored code. Treated as read-only; not edited as part
  of feature work (Principle V).
* `binary/` — compiled binaries and platform artifacts (executables only).
* `papers/` — paper-associated code and data.
* `deprecated/` — retired code kept for backward compatibility; read-only, not the
  place to start new work.
* `.specify/` — Spec Kit machinery (templates, scripts, extensions, memory);
  `.claude/` and `.agents/` — per-agent Spec Kit command/skill surfaces.
* `specs/<NNN-feature-name>/` — per-feature Spec Kit artifacts (`spec.md`,
  `plan.md`, `tasks.md`, research/analysis, and `agent-runs/` receipts).
* repository root — project-level metadata and configuration only (for example
  `README.rst`, `LICENSE.md`, `initCobraToolbox.m`, `CLAUDE.md`, `AGENTS.md`,
  `.gitignore`, CI configs). One-off scratch files and generated output MUST NOT
  accumulate at the root.

Contributions target the `develop` branch of the upstream repository via pull
request. When creating or relocating a file, its destination MUST be chosen by role:
toolbox source → a subfolder under the correct `src/<domain>/`; test or fixture →
`test/`; new-language source → its language subtree with its own manifest; tutorial
→ `tutorials/`; documentation source → `documentation/`; third-party code →
`external/`; retired code → `deprecated/`; Spec Kit artifact → `specs/<feature>/`.

Rationale: a large, widely-used toolbox stays reviewable only when source, tests,
docs, vendored code, and generated artifacts remain cleanly separated and the
existing community layout is respected.

### X. Documentation Single-Sourcing And No Instruction Leakage

Documentation and instructions MUST be single-sourced: every rule, convention, or
piece of guidance has exactly one canonical home, and other files point to it rather
than restating it. Duplicated prose drifts out of sync and creates ambiguity about
which copy governs.

* This constitution is the single canonical source for how to work in this
  repository. Project-authored agent-instruction files — notably `CLAUDE.md` and
  `AGENTS.md` — MUST be thin pointers to this constitution and the Spec Kit workflow.
  They MUST NOT restate, summarise at length, or fork the principles; a brief
  orientation plus links is the allowed content.
* Established openCOBRA conventions (model-field spec, style guide, documentation
  guide, test guide) remain canonical in their published location; this constitution
  binds to them by reference (Principles III, VII, IX) and MUST NOT copy their text.
* Agent- or LLM-specific instructions MUST NOT leak into general repository
  documentation — `README.rst`, files under `documentation/`, `DevelopersDocumentation/`,
  `tutorials/`, or function help headers. Those artifacts are for humans and the
  documentation build and MUST remain agent-neutral. Guidance meant for automated
  agents belongs in the constitution (canonical) or the per-agent Spec Kit surfaces.
* Exemption: the per-agent Spec Kit command and skill mirrors under `.claude/` and
  `.agents/` necessarily carry the same operational content across agents. They are
  generated machinery maintained by the Spec Kit tooling (`/speckit-*` workflows),
  not hand-maintained project documentation, and are exempt from the single-file
  rule — but they still MUST NOT contradict this constitution.

When two documents disagree, the canonical source controls and the derivative copy
is the defect to fix. Changes to canonical rules go through the owning workflow
(`/speckit-constitution` for this file; the openCOBRA guides for their conventions),
never by editing a pointer file.

Rationale: single-sourcing prevents the classic failure where `CLAUDE.md`,
`AGENTS.md`, and a README slowly disagree about the rules, and it keeps human-facing
documentation free of agent-specific instructions that would confuse contributors
and the documentation generator.

## Scientific Computing Constraints

Implementation plans MUST cite the stable references that govern their feature where
those exist. The canonical openCOBRA contribution references — binding by reference
under Principles III, VII, IX, and X — are:

* the contribution overview and unified model-field specification:
  https://opencobra.github.io/cobratoolbox/stable/contributing.html and the
  documentation root https://opencobra.github.io/cobratoolbox/;
* the style guide: https://opencobra.github.io/cobratoolbox/docs/styleGuide.html;
* the documentation/header guide:
  https://opencobra.github.io/cobratoolbox/docs/documentationGuide.html;
* the test guide and test template:
  https://opencobra.github.io/cobratoolbox/docs/testGuide.html and
  https://opencobra.github.io/cobratoolbox/docs/testTemplate.html;
* `.github/CONTRIBUTING.md` (which links the above);
* the solver-interface sources under `src/base/solvers/` and the test harness
  (`test/testAll.m`, `test/verifiedTests/`) with CI configuration.

The supported MATLAB baseline is R2024b or newer, and CI runs MATLAB headless
(`matlab -batch`) on Linux inside Docker (with a display provided by Xvfb and, where
available, Gurobi). Code MUST run headless and MUST NOT depend on GUI-only functions
or OS-specific absolute paths.

Feature specifications MUST define success criteria measurable in the project
domain — for example feasibility/optimality preserved, reproducible solver status
handling, objective values within tolerance, interface compatibility, passing CI,
coverage maintained, or documented parity between language surfaces. If a governing
convention is not written down anywhere, the feature specification MUST state it
directly.

## Development Workflow And Quality Gates

Before implementation, the plan MUST pass a Constitution Check documenting:

* scientific/model-correctness boundaries;
* required tests or reproducibility checks and how they run in CI (including the
  `prepareTest` requirement declarations, per Principle III);
* backward-compatibility impact on public interfaces, model fields, or solver
  behaviour (and explicit approval for any break);
* solver-abstraction and numerical-integrity constraints, including the
  configuration-surface audit for any external solver;
* cross-language fidelity expectations where applicable;
* file-placement decisions under Principle IX and single-sourcing under Principle X.

Any violation MUST be listed in Complexity Tracking with a reason and the rejected
simpler alternative. Tasks MUST be ordered so tests are created before or with the
behaviour they verify, and each user story or slice MUST be independently testable.

Git commit messages follow the openCOBRA convention: present tense ("Add feature",
not "Added feature"); first line 72 characters or fewer; reference issues and pull
requests where relevant; include `[documentation]` in the message when only
documentation changes. The Spec Kit `git` extension may automate commits at phase
boundaries; its messages MUST still respect this convention.

Code review MUST confirm that public interfaces remain compatible or the break is
approved; model, solver, and status semantics remain correct or are deliberately
changed and documented; tests and CI pass; performance changes do not hide
numerical failure; generated output stays out of source directories; and no rule is
duplicated across documentation files (Principle X).

A numerical or solver change is not complete until the relevant execution path has
been inspected and the narrowest practical verification has passed, or the remaining
gap is explicitly stated.

### Implementation Receipt Ledger

Every Spec Kit implementation run MUST write an implementation receipt under the
resolved active feature directory at:

```text
<FEATURE_DIR>/agent-runs/<UTC-timestamp>-<short-task-or-run-name>/implementation-receipt.md
```

The directory name `agent-runs/` is agent-neutral. Implementation is not complete
until that receipt exists. The receipt MUST record only the standard categories:

* Prompt
* Final response
* Diff summary
* Tests
* Unresolved issues

The `Final response` section MUST contain the actual final user-facing agent
completion response — not a paraphrase, compressed summary, or reconstruction. The
receipt MUST exclude live interim progress messages, command-by-command commentary,
and raw full chat transcripts unless the user explicitly requests them. Minimal
redaction is allowed only for secrets, credentials, or personal data, and MUST be
marked. A brief `Other information` section is permitted for concise context that
does not fit the five categories.

## Agent And Review Workflow

Reasoning-focused review and coding-focused implementation are complementary,
regardless of which agent or model performs each role. This workflow is
agent-agnostic: the same expectations apply to Claude, Codex, or any other Spec
Kit-compatible agent, and to human reviewers.

Review SHOULD cover algorithm and model interpretation, solver-status semantics,
interface-compatibility judgement, and diagnostic design, prioritising scientific
correctness, solver compatibility, test coverage, numerical stability, and
performance for large models over stylistic concerns. Implementation agents SHOULD
apply patches, run tests, update files, produce diffs, check syntax, and report
changed files and test outcomes. Implementation agents MUST NOT be asked to make
broad algorithmic or interface changes without a specification stating the intent,
affected execution paths, expected results, and verification plan.

## Governance

This constitution supersedes conflicting local workflow habits, templates, and ad
hoc implementation preferences. The Strict Spec-Driven Development Gate
(Principle VI) has precedence over convenience, speed, and agent initiative.

Amendments require: an update to this file; a Sync Impact Report; review of
dependent Spec Kit templates; and review of any affected runtime guidance or agent
instructions (`CLAUDE.md`, `AGENTS.md`). Feature plans and reviews MUST check
constitution compliance before implementation and again before completion.

Versioning follows semantic versioning:

* MAJOR: incompatible governance changes, principle removals, or redefinitions that
  invalidate existing approved plans;
* MINOR: new principles, new governance sections, or materially expanded compliance
  requirements;
* PATCH: clarifications, wording fixes, or non-semantic refinements.

When a feature conflicts with the constitution, the constitution controls unless the
feature first amends it through this governance process.

**Version**: 1.1.0 | **Ratified**: 2026-07-12 | **Last Amended**: 2026-07-12
