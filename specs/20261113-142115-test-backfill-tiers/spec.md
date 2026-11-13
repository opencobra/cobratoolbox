# Feature Specification: Bottom-up test back-fill with defect quarantine

**Feature Branch**: `20261113-142115-test-backfill-tiers` (from `upstream/develop` at 5200aad48)

**Created**: 2026-11-13

**Status**: Draft

## Clarifications

### Session 2026-11-13

- Q: Which defect severities quarantine a function and its callers? → A: `wrong-result`, `error`
  and `unusable-option`; `cosmetic` and `limitation` use the input-level rule (FR-007).

**Input**: User description: "I want use to start writing the tests from down tiers up to up tiers
all the way and if there was an defect we document it and skip that function and functions
dependent on it. this way I want to reach the highest test coverage possible before the need for a
human review."

This is a characterization feature (Constitution III-Characterization): it writes tests that pin
the existing behaviour of functions that have no test, and it never changes a source function. It
adopts QUARANTINE (Constitution 1.8.0, III-Defects) for defects. Tests follow III-Naming,
III-Coverage and III-Defects, and Principle VII; none of those rules is restated here.

## Scope

On `upstream/develop` 5200aad48, `src/` outside `old/`, `deprecated/` and `external/` holds 1642
`.m` files. 557 have a test (`test<Name>.m`, or a test whose header names the file under
"Function under test:"); **1085 have none**. This feature gives each of the 1085 exactly one
outcome (tested, quarantined, blocked or excluded; see Key Entities). Existing tests are not
rewritten; they change only as FR-012 and FR-013 require.

Largest untested areas: analysis/thermo 89, reconstruction/demeter 88,
dataIntegration/metaboAnnotator 65, analysis/wholeBody 59, base/solvers 53,
visualization/metabolicCartography 46, analysis/topology 45, analysis/persephone 45,
reconstruction/refinement 44, analysis/multiSpecies 41, analysis/sampling 36, base/io 32.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Inventory and bottom-up order (Priority: P1)

The maintainer can see every untested function with its tier, whether it can be tested on the
reference machine (and if not, why), the functions it calls and the functions that call it, and
the order in which the campaign takes them: Tier 1 first, then Tier 2, Tier 3, Tier 4/5, and within
a tier every function after the functions it calls.

**Why this priority**: the order is what makes quarantine work. A defect in a helper must be found
before any of its callers is tested, otherwise tests would pin results built on the defect.

**Independent Test**: the ledger lists all 1085 functions with a tier and an initial status
(PENDING or EXCLUDED with a reason), and for every pair "g calls f" with both in the same tier,
f comes before g in the order.

**Acceptance Scenarios**:

1. **Given** the 1085 untested files, **When** the inventory is built, **Then** each has exactly
   one row with tier, status, reason (for EXCLUDED), callees and callers.
2. **Given** a file that is a script, a GUI or GUI callback, or needs internet, an external
   program, or a solver/toolbox licence missing on the reference machine for all its lines,
   **When** classified, **Then** it is EXCLUDED with that reason and no test is written.
3. **Given** two functions that call each other (a cycle), **When** ordered, **Then** they are
   taken together and a defect in either quarantines both.

---

### User Story 2 - Tier 1 tests (Priority: P1)

Every PENDING Tier 1 function (pure helpers on matrices, strings and structs; no genome-scale
model, no solver) gets a test, in the bottom-up order.

**Why this priority**: Tier 1 functions are the leaves of the call graph; most other functions
depend on them, and their tests are cheap and never skipped.

**Independent Test**: each Tier 1 row ends TESTED, QUARANTINED or BLOCKED; every TESTED function's
test passes on the reference machine with 100% line coverage of its function or documented
exemptions.

**Acceptance Scenarios**:

1. **Given** a PENDING Tier 1 function without defects, **When** tested, **Then** its new test
   covers every line (or documents exemptions), passes, and the row becomes TESTED.
2. **Given** a test that reveals a defect in the function, **When** recorded, **Then** the
   function becomes QUARANTINED (its test records the defect and asserts nothing about it) and
   every function that calls it, directly or indirectly, becomes BLOCKED by it.

---

### User Story 3 - Defect quarantine (Priority: P1)

Whenever a defect is found, the defect, the quarantined function and every blocked caller are
visible in one place, so the human reviewer can decide which defects to fix first.

**Why this priority**: it is the maintainer's chosen rule for defects and decides what is left for
human review.

**Independent Test**: for every QUARANTINED function the ledger names the defect and lists the
blocked callers; every BLOCKED function names at least one QUARANTINED function it calls; the
generated known-defects registry contains every defect.

**Acceptance Scenarios**:

1. **Given** a `wrong-result`, `error` or `unusable-option` defect found in f, **When** f is quarantined, **Then** no new test of f or of any
   caller of f asserts any result, and the ledger lists the callers with "blocked by f".
2. **Given** a function g whose test is in progress, **When** g turns out to call a newly
   quarantined function, **Then** g's test is not added and g becomes BLOCKED.
3. **Given** a defect found in a function h that already has a test (outside the 1085), **When**
   recorded, **Then** the defect is added to h's existing test header (its passing assertions stay)
   and h is listed as existing-defective: its untested callers become BLOCKED.

---

### User Story 4 - Tier 2 tests (Priority: P2)

Every PENDING Tier 2 function (model manipulation, no solver) gets a test in the bottom-up order,
with structural consistency assertions as Tier 2 requires.

**Independent Test**: as User Story 2, for Tier 2 rows.

---

### User Story 5 - Tier 3 tests (Priority: P3)

Every PENDING Tier 3 function (optimisation) gets a test that declares its requirements and checks
invariants of the solution, on the smallest model that reaches every branch.

**Independent Test**: as User Story 2, for Tier 3 rows; lines reachable only with a solver missing
on the reference machine are documented exemptions.

---

### User Story 6 - Tier 4/5 tests (Priority: P4)

Every PENDING function that needs a distributed model or first-run reference values gets its test
last, so these slower tests build on everything already tested.

**Independent Test**: as User Story 2, for Tier 4/5 rows; reference values state their origin
(first run, date, solver) as Tier 5 requires.

---

### User Story 7 - Ready for human review (Priority: P2)

At the end, the maintainer receives one pull request with all new tests, the ledger, the
regenerated known-defects registry, an independent review, a full-suite run and a summary of
coverage before and after.

**Independent Test**: the full suite on the reference machine has no failure caused by this
feature; the summary gives counts per status and per tier, the quarantine list ordered by number
of blocked callers, and the coverage gain.

### Edge Cases

- A defect in a widely used helper blocks many callers: accepted (maintainer decision); the summary
  ranks quarantined functions by the number of functions they block, so the reviewer sees which
  fixes unblock the most.
- A caller reaches f only through a function handle, `feval`, `eval` or a name built at run time:
  the static call graph misses it. Text references to f's name in the caller (handles, strings
  passed to `feval`/`str2func`) are counted as calls; a dependency found only while running a test
  is added to the graph and the caller becomes BLOCKED.
- A function name exists in several folders (shadowing): the file the MATLAB path resolves is the
  one tested; the others are listed with that reason.
- A local function inside a file is covered through its parent's test; it gets no ledger row of its
  own. Class files and their methods count as one row per file.
- A function needs a large model (for example a whole-body model) and the reference machine's
  memory limit: tested with the smallest model that reaches the code; if none fits, EXCLUDED with
  that reason.
- A function is stochastic: the test fixes the seed (Principle III).
- A function prints a lot or writes files: output is not suppressed (Principle VII); files go to a
  temporary folder that the test removes.
- A `cosmetic` or `limitation` defect (for example a typo in a message, or an input the function
  does not support): recorded in the header, the input skipped, and the function still TESTED.
- A defect is found in a function that is already QUARANTINED: the extra defect is added to the
  same test header.
- A test cannot be written for a reason that is not a defect (for example the behaviour cannot be
  pinned without an unavailable resource found only while testing): the row becomes EXCLUDED with
  the reason, and its callers are not blocked.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The feature MUST keep a ledger in the feature folder with one row per untested file:
  file, tier, status (PENDING, TESTED, QUARANTINED, BLOCKED, EXCLUDED), reason or blocking
  function, test file, and coverage result.
- **FR-002**: Each function's tier MUST be the lowest tier (Constitution III-Coverage) whose
  resources reach all its lines on the reference machine: no model and no solver → Tier 1; a model
  but no solver → Tier 2; a solver → Tier 3; a distributed model or first-run reference values
  needed → Tier 4/5.
- **FR-003**: The order MUST be bottom-up in the call graph (callees before callers, cycles taken
  together) and then by tier: a function's effective tier is the highest tier among itself and every
  untested function it calls, so no function is tested before an untested function it calls, in
  any tier.
- **FR-004**: The call graph MUST include static calls and text references to function names
  (handles, names passed to `feval`/`str2func`), restricted to functions in `src/`.
- **FR-005**: A file MUST be EXCLUDED, with its reason, when it is a script without a function, a
  GUI or GUI callback, needs internet, an external program, or a solver or toolbox licence missing
  on the reference machine for every line, or cannot run within the reference machine's memory.
- **FR-006**: Every TESTED function MUST have exactly one new test file `test<Name>.m` that follows
  III-Naming, declares its tier, opens with `prepareTest`, reaches 100% line coverage of the
  function or documents each exempt line with its reason, and passes on the reference machine.
- **FR-007**: A defect is any of the III-Defects severities found by a test. Defects of severity
  `wrong-result`, `error` or `unusable-option` MUST quarantine the function. Defects of severity
  `cosmetic` or `limitation` MUST follow the input-level rule instead: the defect is recorded in the
  header, only the affected input is skipped, and the function and its callers are still tested
  (maintainer decision 2026-11-13).
- **FR-008**: A QUARANTINED function's test file MUST follow III-Defects quarantine: header with the
  defect entry, every line exempt, body `prepareTest()` only.
- **FR-009**: Every function that calls a QUARANTINED function, directly or indirectly, MUST be
  BLOCKED by it and get no new test in this feature; the ledger names the blocking function. If such
  a call is found only after the caller was TESTED (a dependency found at run time), the caller's
  new test is removed and the caller, and every TESTED caller of it, becomes BLOCKED.
- **FR-010**: No source function MAY be changed (III-Characterization).
- **FR-011**: New tests MUST NOT suppress output (`evalc`) or warnings (Principle VII), MUST fix
  random seeds, and MUST leave no files, figures, global state or path changes behind (checked when
  each wave's tests are run together).
- **FR-012**: When a defect of a quarantining severity is found in a function that already has a
  test (outside the 1085), the defect MUST be added to that test's header by the input-level rule
  (its existing passing assertions stay; it is not rewritten into the quarantine layout), the
  function is listed as EXISTING-DEFECTIVE, and its untested callers become BLOCKED by it (User
  Story 3, scenario 3).
- **FR-013**: `test/known-defects.md` MUST be regenerated with the repository's generator after
  the last defect is recorded.
- **FR-014**: Every new test MUST be run with line coverage measurement on the reference machine;
  results are stored in the ledger.
- **FR-015**: The full test suite MUST run on the reference machine at the end; any failure MUST
  be shown not to come from this feature.
- **FR-016**: An independent review of the new tests (Codex if its account works, otherwise
  independent reviewer agents) MUST be recorded in the feature folder before the pull request.
- **FR-017**: The final summary MUST give counts per status and tier, the quarantined functions
  ranked by the number of functions they block, the excluded files grouped by reason, and line
  coverage of `src/` before and after.
- **FR-018**: All work MUST be on this branch and reach review as one pull request; commits are by
  the maintainer, without co-author lines, and never include submodule pointers.
- **FR-019**: The feature MUST preserve every public interface, diagnostic and file-location
  convention (no source change, FR-010).

### Key Entities

- **Ledger row**: one untested file; tier; status; reason, blocking function or defect; test file;
  coverage (lines, missed, exempt).
- **Status**: PENDING (not yet taken), TESTED (passing test, full coverage or documented
  exemptions), QUARANTINED (defect found; test records it), BLOCKED (calls a quarantined function,
  directly or indirectly), EXCLUDED (cannot be tested here; reason).
- **Call graph**: functions in `src/` and who calls whom (static calls and name references).
- **Defect entry**: III-Defects fields, in the test header of the defective function.
- **Quarantine list**: quarantined functions with their defect and the blocked callers.
- **Existing-defective list**: already-tested functions in which a quarantining defect was found
  (FR-012), with the defect and the callers they block; not rows of the 1085.

## Existing Contract *(characterization mode)*

- **Function(s) under test**: the 1085 untested files of `src/` (inventory in the ledger).
- **Current inputs / arities**: as each function's header and code define; each test covers the
  meaningful input and output arities (Principle III).
- **Current outputs**: pinned per function; values with independent derivations where possible,
  otherwise first-run references labelled Tier 5.
- **Invariants & expected results**: per tier (III-Coverage): structural consistency for Tier 2,
  feasibility, bounds and objective for Tier 3; justified tolerances; fixed seeds.
- **Coverage gap**: no test exists (inventory 2026-11-13 on 5200aad48).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All 1085 untested files have exactly one final status; none is PENDING.
- **SC-002**: Every TESTED function's test passes on the reference machine and covers 100% of the
  function's lines or documents each uncovered line with a reason.
- **SC-003**: Every QUARANTINED function has a defect entry; every BLOCKED function names a
  QUARANTINED function that it calls; the known-defects registry contains every defect.
- **SC-004**: No source file is changed (the branch diff contains only tests, test headers, the
  generated registry and the feature folder).
- **SC-005**: The full test suite on the reference machine has no failure attributable to this
  feature.
- **SC-006**: Line coverage of `src/` after the feature is reported next to the value before it, and
  the number of functions with a test rises from 557 by the number of TESTED and QUARANTINED rows.

## Assumptions

- Reference machine: MATLAB R2025a, Gurobi as the only commercial solver, no paid MATLAB toolboxes
  (this repository no longer needs them), memory-capped MATLAB sessions.
- "Untested" means no `test<Name>.m` for the file and no test naming it under "Function under
  test:" on 5200aad48; a function that is only exercised indirectly by another test counts as
  untested.
- Tests are characterization tests: where no independent reference exists, first-run values are
  used and labelled Tier 5.
- Excluded files are not a failure of the feature; they are listed for a machine or a person that
  has the missing resource.
- The campaign continues tier to tier without waiting for review; the maintainer reviews once, at
  the pull request.
- Size: about 1000 tests; the work is long. Progress is committed in steps on the branch; the
  branch is pushed only when the maintainer asks.

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1 / FR-001–FR-005 | — (ledger and call graph in the feature folder) | — (no source function) |
| US2 / FR-006, FR-011 | new Tier 1 `test<Name>.m` files | Tier 1 rows of the ledger |
| US3 / FR-007–FR-009, FR-012, FR-013 | quarantined `test<Name>.m` headers; `test/known-defects.md` | QUARANTINED rows |
| US4 / FR-006 | new Tier 2 `test<Name>.m` files | Tier 2 rows of the ledger |
| US5 / FR-006 | new Tier 3 `test<Name>.m` files | Tier 3 rows of the ledger |
| US6 / FR-006 | new Tier 4/5 `test<Name>.m` files | Tier 4/5 rows of the ledger |
| US7 / FR-014–FR-018 | full-suite run; review.md; summary | — (no source function) |
| FR-010, FR-019 / SC-004 | branch diff check | — (no source function) |
