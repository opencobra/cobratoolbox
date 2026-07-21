# Checklist: Relocation Safety & Backward-Compatibility (Requirements Quality)

**Purpose**: Pre-implementation quality gate — validate that the *requirements* for feature 013 are
complete, clear, consistent, and measurable enough to relocate vendored code/data safely without
regressions. These items test the spec, not the implementation.
**Created**: 2026-07-17
**Feature**: [spec.md](../spec.md)

## Requirement Completeness

- [ ] CHK001 - Are path-resolution requirements defined for all three reference mechanisms in use (computed-folder reads, `which`/`fopen` path-search reads, `cd`-then-shell-out)? [Completeness, Spec §FR-004]
- [ ] CHK002 - Is the "byte-identical move, not rewrite" requirement stated for every relocated asset class (code, static data, and deprecated-bound orphans)? [Completeness, Spec §FR-009]
- [ ] CHK003 - Does the spec require re-confirming a file is referenced nowhere before it is moved to `deprecated/`? [Completeness, Spec §FR-005]
- [ ] CHK004 - Is verification of `initCobraToolbox` path coverage (of `external/` and the resource path) required as an explicit early precondition? [Completeness, Spec Assumptions]
- [ ] CHK005 - Are requirements defined for keeping `cd`-then-shell-out working directories and their written outputs in a writable location after the move (the relocated tree may be read-only)? [Completeness, Spec Edge Cases]
- [ ] CHK006 - Is a destination-or-exclusion disposition specified for every enumerated asset (SAMMI JS/CSS/HTML, `demo.json`, `*.pl`, `*.gms`, `python/tmp/*`, NIST table, `.xlsx`, `.mlx`, `cache/*.mat`, generated SAMMI HTML, `taxa2proc_*.txt`)? [Coverage, Spec §FR-001..FR-011]

## Requirement Clarity

- [ ] CHK007 - Is the "dedicated resource path" for static data specified precisely, or is its deferral to `/speckit-plan` explicit and bounded (states what plan must decide)? [Clarity, Spec §FR-007]
- [ ] CHK008 - Is "wrapper-relative resolution" defined concretely (resolve from the wrapper's own file location, cwd-independent) rather than left as a vague adjective? [Clarity, Spec §FR-004]
- [ ] CHK009 - Is the "public MATLAB surface" that must not change defined checkably (function name, argument order, option names, documented behavior)? [Clarity, Spec §FR-003]
- [ ] CHK010 - Does the spec make clear whether "byte-identical" forbids incidental re-encoding (line endings, BOM) during the move? [Clarity, Spec §FR-009]

## Requirement Consistency

- [ ] CHK011 - Are the two disposal rules — orphans → `deprecated/` (FR-005) vs generated artifacts → remove+gitignore (FR-006) — consistent and mutually exclusive across the FRs and Assumptions? [Consistency, Spec §FR-005/§FR-006]
- [ ] CHK012 - Is `demo.json`'s disposition consistent across US1, US3, FR-005, and SC-002 (all say `deprecated/`, not `external/`)? [Consistency, Spec §US1/§US3/§FR-005/§SC-002]
- [ ] CHK013 - Is SAMMI's pre-existing remote-CDN/internet dependence consistently marked out of scope so it is not conflated with the local-asset relocation? [Consistency, Spec Assumptions]

## Acceptance Criteria Quality (Measurability)

- [ ] CHK014 - Is the "no new test failures vs baseline" criterion backed by a required baseline-capture step so it is objectively comparable? [Measurability, Spec §SC-004/§FR-010]
- [ ] CHK015 - Is the `src/` size-reduction criterion tied to a named measurement source (`analysis/metrics/…`) rather than asserted figures? [Measurability, Spec §SC-005]
- [ ] CHK016 - Is "each wrapper still resolves and uses its relocated asset" expressed as an objectively checkable per-wrapper outcome? [Measurability, Spec §SC-003]
- [ ] CHK017 - Can "no public signature changed" be objectively verified (e.g., bounded to path-resolution edits + moves in a diff)? [Measurability, Spec §SC-006]

## Scenario & Edge-Case Coverage

- [ ] CHK018 - Are requirements defined for the "`external/`/resource path not on the MATLAB path" failure scenario (wrapper-relative fallback)? [Coverage, Edge Case, Spec Edge Cases]
- [ ] CHK019 - Are requirements defined so that an absent optional tool (`perl`/`gams`) yields the same behavior as before the move (not counted as a regression)? [Coverage, Exception, Spec Edge Cases/Assumptions]
- [ ] CHK020 - Are requirements defined for name/case collisions when moving a file into an existing `external/` or `deprecated/` location? [Coverage, Edge Case, Spec Edge Cases]
- [ ] CHK021 - Are requirements defined for the case where a presumed-orphan file is found to be referenced at implementation time (relocate as code, do not deprecate/delete)? [Coverage, Edge Case, Spec §FR-005/Edge Cases]

## Dependencies & Assumptions

- [ ] CHK022 - Is the assumption that `initCobraToolbox` adds `external/` and the resource path to the MATLAB path documented AND flagged for early verification (not silently relied upon)? [Assumption, Spec Assumptions]
- [ ] CHK023 - Is the assumption that touched-domain tests skip/fail cleanly without `perl`/`gams` stated as something to confirm at baseline? [Assumption, Spec Assumptions]
- [ ] CHK024 - Is the dependency on a defined `tutorials/` destination for the `.mlx` documented? [Dependency, Spec §FR-008]

## Ambiguities, Conflicts & Traceability

- [ ] CHK025 - Does the spec avoid an open-ended gap by bounding what `/speckit-plan` must decide about the resource path (rather than leaving it fully unspecified)? [Ambiguity, Spec §FR-007/Clarifications]
- [ ] CHK026 - Is the tension between "full cleanup" intent and the `taxa2proc_*.txt` exclusion resolved by an explicit, justified out-of-scope statement? [Conflict, Spec §FR-011/Clarifications]
- [ ] CHK027 - Does every acceptance criterion map to a discharging test or a "no source function" artifact in the Traceability table (no orphan criteria)? [Traceability, Spec Traceability]

## Notes

- Depth: formal pre-implementation gate. Audience: maintainer/reviewer (author-run before Gate 2).
- Items are requirement-quality questions; a "no" answer means the spec needs tightening before
  planning, not that implementation is wrong.
- Clarifying questions were skipped: the request already fixed depth (formal gate) and the seven
  focus areas; no materially ambiguous scope remained.
