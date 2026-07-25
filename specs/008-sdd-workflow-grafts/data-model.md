# Data Model / Change Contracts: Native SDD-workflow grafts

There is no runtime data model. The "entities" are the SDD machinery artifacts
this feature changes; each has a change contract and (where it will be edited) a
minimal wording draft so implementation is mechanical. Drafts are indicative; the
`/speckit-constitution` and template edits finalize exact text.

## E1 — `.specify/templates/spec-template.md` (edited)

Two additive changes; no existing section removed or reordered.

### E1a — `## Traceability` section (Graft #1, FR-001/FR-002)

Appended after `## Assumptions` (end of file). Draft:

```markdown
## Traceability

<!--
  One row per acceptance criterion. Map each criterion to the test that discharges
  it and to the src/<domain>/ function under test.
  NO-SOURCE CONVENTION: for a documentation/tooling feature that exercises no
  source function, name the artifact or check that discharges the criterion in the
  last column and write "— (no source function)" in the test column where none
  applies. Every acceptance criterion appears exactly once; no orphan rows.
-->

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| [US1 / FR-00X] | [testName under test/verifiedTests/<category>/] | [src/<domain>/<function>] |
```

### E1b — In-template Characterization Mode (Graft #2, FR-004)

An optional guidance comment after the `**Input**` line:

```markdown
<!--
  CHARACTERIZATION MODE (optional): if this feature back-fills a test for an
  EXISTING untested function (Constitution Principle III, characterization
  clause), fill the "Existing Contract" section below to capture CURRENT behaviour
  instead of net-new requirements; Functional Requirements then assert that
  existing contract. Delete this block and the section for greenfield work.
-->
```

plus an optional section after `## Requirements`:

```markdown
## Existing Contract *(characterization mode only)*

- **Function(s) under test**: src/<domain>/<function>
- **Current inputs / arities**: [existing signature and optional-arg behaviour]
- **Current outputs**: [returned values / fields / files]
- **Invariants & expected results**: [with justified tolerances; fixed seed if stochastic]
- **Coverage gap**: [why it is currently untested — from CI coverage, features 001/007]
```

Both blocks reference the Principle III clause by name and do NOT restate it
(Principle X).

## E2 — `.specify/memory/constitution.md` (edited ONLY via `/speckit-constitution`)

Graft #2 clause (FR-003). New labelled sub-clause under **Principle III**. Draft:

```markdown
#### III-Characterization: Legacy Back-Fill Mode

An untested legacy function surfaced by CI coverage MAY be brought under test with
a CHARACTERIZATION feature: (1) select the untested `src/<domain>/` function from
coverage; (2) document its EXISTING contract (current inputs, outputs, invariants,
tolerances) rather than proposing new behaviour; (3) write the narrowest
characterization test that pins that existing behaviour (fixed seed and justified
tolerance where output is solver- or randomness-dependent), integrated into
`test/testAll.m` and CI. A characterization feature MUST NOT change the function
under test; if a defect is found, that is a separate, spec-driven change. This is
the single canonical description of the pattern (features 004 and 006 are prior
instances).
```

Expected version bump: MINOR (1.2.0 → 1.3.0) with a Sync Impact Report; dependent
templates reviewed (`spec-template.md` gains the referencing Characterization Mode
block). `/speckit-constitution` owns the final wording, exact heading, and bump.

## E3 — `.specify/templates/checklist-template.md` (edited)

Graft #3 phantom-completion assertion (FR-005). A STANDING section retained in
every generated checklist, placed so the sample-block "do not keep" warning does
not apply to it. Draft:

```markdown
## Completion Integrity *(standing — always retained)*

- [ ] Every `[X]` task in `tasks.md` maps to a real diff hunk (or a named non-code
  artifact) AND to verification evidence: a test that actually ran, or an
  equivalent validation check for non-code work (e.g. checklist re-validation,
  diff-scope check). No task is checked off without both.
```

## E4 — `.specify/templates/red-team-checklist-template.md` (NEW file)

Graft #4 (FR-006/FR-007). New template under `.specify/templates/`; a contributor
copies it to `specs/<feature>/checklists/red-team.md` and completes it BEFORE
`/speckit-plan`. Findings-only. Draft skeleton:

```markdown
# Pre-Plan Red-Team Checklist: [FEATURE NAME]

**Purpose**: Surface risk before planning. FINDINGS ONLY — this checklist MUST NOT
edit spec.md, plan.md, or tasks.md (Constitution Principle VI). Real issues are
resolved through the normal spec-edit flow.
**Run**: before `/speckit-plan`.

## Integrity gaps
- [ ] RT001 Does any acceptance criterion lack a test that could discharge it?
- [ ] RT002 Any public interface / model field / solver status touched without an approved break?

## Silent failures
- [ ] RT003 Could any step fail without surfacing (suppressed warning, swallowed error, skipped check)?
- [ ] RT004 Any tolerance / seed / status assumption that could pass spuriously?

## Cross-spec drift
- [ ] RT005 Does the spec contradict the constitution or another active feature?
- [ ] RT006 Do the templates/plan referenced still match the current constitution version?

## Findings
- (record findings here; do not edit the spec to resolve them)
```

## E5 — Per-domain module index (NOT created)

Graft #5 resolved to DROP (see `research.md` R1). No `documentation/` file. The
recorded determination in `research.md` + `plan.md` is the deliverable (FR-008).

## Backward-compatibility contract (FR-011)

All edits are additive to templates or a new file; no existing per-feature artifact
(`spec.md`, `plan.md`, `tasks.md`, `checklists/`, `human-loop.md`,
`implementation-review.md`, `agent-runs/`) changes shape. Features 001–007 require
no migration: they simply predate the new optional/standing sections.

## Gate-safety contract (FR-010)

No entry adds or edits a hook in `.specify/extensions.yml`; no `src/**`, `test/**`,
or build/CI file is touched. The only new file is `E4` under `.specify/templates/`.
