# Pre-Plan Red-Team Checklist: [FEATURE NAME]

**Purpose**: Surface risk BEFORE planning. This checklist is **findings-only**: it
MUST NOT edit `spec.md`, `plan.md`, or `tasks.md` (Constitution Principle VI). Any
real issue it surfaces is resolved through the normal spec-edit flow, not by this
checklist.
**Created**: [DATE]
**Feature**: [Link to spec.md]
**Run**: before `/speckit-plan`. Instantiate to
`specs/<feature>/checklists/red-team.md`, complete the items, and record findings
below — do not modify the spec to "fix" a finding here.

<!--
  Each item is a probing question. Check it `[X]` once you have DELIBERATELY
  considered it and recorded any finding (or "none") in the Findings section.
  Add or remove questions per feature; keep the three category headings.
-->

## Integrity gaps

- [ ] RT001 Does any acceptance criterion lack a test (or check) that could actually discharge it?
- [ ] RT002 Is any public interface, model field, or solver-status semantic touched without an approved, documented break (Principle II)?
- [ ] RT003 Does every `[X]`-able unit of work have a real, verifiable artifact behind it (no phantom completion)?

## Silent failures

- [ ] RT004 Could any step fail without surfacing — a suppressed warning, a swallowed error, a skipped verification, an `evalc` hiding output (Principle VII)?
- [ ] RT005 Is there a tolerance, seed, status, or default that could let a test PASS spuriously (false green)?
- [ ] RT006 Does any performance/skippable path remove a diagnostic or verification instead of gating it behind a default-on parameter (Principle IV)?

## Cross-spec drift

- [ ] RT007 Does the spec contradict the constitution, or a still-active/adjacent feature?
- [ ] RT008 Do the templates, plan, or referenced paths still match the CURRENT constitution version (no stale references to renamed/removed sections)?
- [ ] RT009 Is any rule stated in two canonical places (single-sourcing violation, Principle X)?

## Findings

<!--
  Record findings here. Classify each: blocking / should-fix / acceptable / deferred.
  Do NOT edit spec.md/plan.md/tasks.md to resolve them — route through the normal flow.
-->

- (none recorded yet)
