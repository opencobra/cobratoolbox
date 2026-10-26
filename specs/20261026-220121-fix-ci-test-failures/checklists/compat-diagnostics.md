# Compatibility & Diagnostics Requirements Checklist: Fix four CI test failures

**Purpose**: Unit-test the requirements (spec.md) for backward compatibility of the rank
routine and lrs driver (Principle II), warning visibility and error-stack rules (VII-B,
VII-C), test skip conventions and failure-path coverage (III), and the binary submodule
bump risk.
**Created**: 2026-10-26
**Audience / timing**: reviewer at Gate 2. Depth: standard.
**Feature**: [spec.md](../spec.md)

Items marked `[X]` are satisfied by the spec as written; items left `[ ]` are gaps the
plan must resolve (or the spec must be amended) before Gate 2.

## Requirement Completeness

- [X] CHK001 - Are requirements stated for every one of the five failing tests, each with a confirmed or explicitly hypothetical cause? [Completeness, Spec §Background]
- [X] CHK002 - Does the spec require an error on every non-zero exit status of both lrs and redund, not only lrs? [Completeness, Spec §FR-002]
- [X] CHK003 - Is the inverted shell-script status test called out as its own requirement? [Completeness, Spec §FR-003]
- [X] CHK004 - Does the spec require the rank routine's and lrs driver's help headers (NOTE/print-level description) to be updated in the same change (VII-E)? [Gap]
- [X] CHK005 - Is deletion of the credential-bearing unreachable branch of testReconMap a stated requirement? [Completeness, Spec §FR-007a]
- [X] CHK006 - Are the other shipped executables changed by the binary bump, and the tests that use them, enumerated so their outcome can be reported? [Gap, Spec §FR-010, Edge Cases]

## Requirement Clarity

- [X] CHK007 - Is "once per MATLAB session" defined precisely (e.g. what resets it: `clear functions`, `clear all`, a new MATLAB process)? [Ambiguity, Spec §FR-005]
- [X] CHK008 - Is the stable warning identifier named, so that the test filter (FR-005a) and users can refer to it? [Ambiguity, Spec §FR-005, §FR-005a]
- [X] CHK009 - Is the minimum content of the fallback warning stated (message plus first stack frame file and line)? [Clarity, Spec §FR-005]
- [X] CHK010 - Is the content of the lrs/redund failure error stated (command, exit status, command output when available)? [Clarity, Spec §FR-002]
- [X] CHK011 - Is "any authentication refusal" in US3-1 defined by an observable reply (the exact text(s) that count), so it cannot swallow other failures? [Ambiguity, Spec §US3-1, §US3-4]
- [X] CHK012 - Is the "if practical" qualifier on the FR-002/FR-003 tests replaced by a decision (tested, or a documented reproducibility check per Principle III)? [Ambiguity, Spec §FR-009]

## Requirement Consistency

- [X] CHK013 - Is once-per-session warning (FR-005) consistent with VII-B "warnings MUST NOT be suppressed", i.e. the first occurrence always reaches the console at every print level? [Consistency, Spec §FR-005, Clarifications]
- [X] CHK014 - Is the test-side filter limited to the single named warning, so other output still fails testGenerateFullRowRankFR? [Consistency, Spec §FR-005a, §US2-6]
- [X] CHK015 - Do FR-006 (outputs identical) and SC-004 (bit-for-bit on working-LUSOL fixtures) agree in scope? [Consistency, Spec §FR-006, §SC-004]
- [X] CHK016 - Is the change in default diagnostic output (fallback/inform-code text no longer printed at the default print level 0) acknowledged as a diagnostic-semantics change under Principle II, and is FR-008's "no changed print-level default" consistent with it? [Conflict, Spec §FR-004, §FR-008]
- [X] CHK017 - Is US1-1 (tests pass with the new binary) separable from US1-2/3 (driver error handling), so either can be verified independently? [Consistency, Spec §US1]

## Acceptance Criteria Quality

- [X] CHK018 - Is SC-001's expected outcome per test explicit (four pass, ReconMap skipped while the account is refused)? [Measurability, Spec §SC-001]
- [X] CHK019 - Is SC-003 countable (exactly one warning on first call, none later, rank equality)? [Measurability, Spec §SC-003]
- [X] CHK020 - Is SC-005's scope bounded to named folders (topology and rank)? [Measurability, Spec §SC-005]

## Scenario & Edge Case Coverage

- [X] CHK021 - Are the four ReconMap outcomes (refused, unreachable, accepted, other reply) each specified? [Coverage, Spec §US3]
- [X] CHK022 - Is the "LUSOL interface file not on the path" branch covered, as well as the "LUSOL call errors" branch? [Coverage, Spec §US2-5]
- [X] CHK023 - Is the lrs-exits-0-but-empty-output case scoped out explicitly? [Edge Case, Spec §Edge Cases]
- [X] CHK024 - Is the requirement for the ReconMap skip path to restore the working directory and the shared credentials stated as a requirement rather than only an edge-case note? [Gap, Spec §Edge Cases]
- [X] CHK025 - Is the test approach for an unrunnable lrs constrained to not modify the shipped binary? [Coverage, Spec §Assumptions]

## Dependencies & Assumptions

- [X] CHK026 - Is the getRankLUSOL hypothesis for the CI printLevel failure marked unconfirmed, with the missing evidence (CI log) named? [Assumption, Spec §Background, §Assumptions]
- [X] CHK027 - Is the choice to bump the whole binary pointer (rather than lrs alone) justified? [Assumption, Spec §Assumptions]
- [X] CHK028 - Is rotation of the exposed MINERVA password noted as a user action outside the repository? [Dependency, Spec §Clarifications]
- [X] CHK029 - Is the remaining conflict with Principle III's "avoid internet access" for testReconMap acknowledged as out of scope? [Assumption, Spec §Assumptions]

## Notes

- First pass: 21/29 satisfied. CHK004, CHK006, CHK007, CHK008, CHK011, CHK012, CHK016
  and CHK024 were closed by amending spec.md (FR-005, FR-005a, US3-1, FR-007b, FR-008,
  FR-009, FR-010, FR-011). Now 29/29; no new user decision was needed.
