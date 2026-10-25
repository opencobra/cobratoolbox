# Feature Specification: Test that blocks function-name conflicts

**Feature Branch**: none (work stays on `develop`)

**Created**: 2026-10-12

**Status**: Draft

**Input**: User description: "Write tests that fail when someone adds a function with the same name as a previous COBRA Toolbox function or a MATLAB built-in function, and whose error says why it failed."

## Why this matters

MATLAB runs the first function with a given name that it finds on the path and silently
ignores the others. A toolbox function that has the same name as another toolbox function,
or as a MATLAB function, either hides that other function or is hidden by it, so calls
change behaviour without any error. This is easy to do by accident in a toolbox with about
1,600 functions in many folders.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A new function with a duplicate toolbox name is rejected (Priority: P1)

A contributor adds `src/analysis/foo/mapMetabolites.m`, but another `mapMetabolites.m`
already exists elsewhere in the toolbox. The test suite fails, and the error says which two
files clash, why that is a problem, and what to do.

**Why this priority**: duplicate names inside the toolbox are the most common mistake and
the one the maintainers can fully control.

**Independent Test**: add a function whose name already exists elsewhere in `src/`; the
name-conflict test fails with a message naming both files.

**Acceptance Scenarios**:

1. **Given** two functions with the same file name in different `src/` folders that are not
   recorded as known, **When** the test runs, **Then** it fails and lists both paths.
2. **Given** a name that differs only by letter case from another function, **When** the test
   runs, **Then** it fails (such names are the same on case-insensitive systems).
3. **Given** no new conflicts, **When** the test runs, **Then** it passes.

---

### User Story 2 - A new function that shadows a MATLAB function is rejected (Priority: P1)

A contributor adds `src/base/utilities/union.m`, which has the name of a MATLAB function. The
test fails and says that the function would hide, or be hidden by, the MATLAB function,
showing where that MATLAB function lives.

**Why this priority**: shadowing a MATLAB function can break code far outside the toolbox.

**Independent Test**: add a function named after a MATLAB built-in; the test fails with a
message that names the MATLAB file.

**Acceptance Scenarios**:

1. **Given** a toolbox function with the same name as a MATLAB built-in or a MATLAB toolbox
   function that is installed, **When** the test runs, **Then** it fails and shows the
   location of the MATLAB function.
2. **Given** a name that exists only as a method inside a MATLAB class folder, **When** the test
   runs, **Then** it is not reported (a class method does not shadow a plain function).

---

### User Story 3 - The error explains the problem and the way out (Priority: P1)

Whoever sees the failure understands from the message alone why it failed and what to do.

**Why this priority**: the user asked explicitly that the error indicates why the test failed.

**Independent Test**: read the failure text for each kind of conflict.

**Acceptance Scenarios**:

1. **Given** any conflict, **When** the test fails, **Then** the message states the function
   name, the conflicting file or MATLAB location, one sentence on why it matters (only the
   first function on the path is used and the other is silently ignored), and how to fix it
   (rename the new function, or, if the duplication is intentional and reviewed, record it as
   known with a reason).
2. **Given** several conflicts at once, **When** the test fails, **Then** all are listed in one
   message, not only the first.

---

### User Story 4 - Existing conflicts do not break the suite (Priority: P1)

The toolbox already has conflicts today (for example old and new copies of thermodynamics
functions, two functions called `demo`, and a function that shares a name with a MATLAB
function). They are recorded as known, each with a reason, so the test passes today and only
new conflicts fail.

**Why this priority**: a test that fails on day one would be switched off.

**Independent Test**: run the test on the current repository; it passes. Remove one recorded
entry; it fails and names that function.

**Acceptance Scenarios**:

1. **Given** the recorded known conflicts, **When** the test runs on the current repository,
   **Then** it passes.
2. **Given** a recorded conflict that no longer exists (the function was renamed or removed),
   **When** the test runs, **Then** it still passes but reports that the entry can be removed.

---

### Edge Cases

- Functions in `private/`, `@class/` and `+package/` folders are not on the global path; they
  are ignored for name conflicts.
- A name that appears only inside `test/` or `tutorials/` is out of scope; the check covers
  the toolbox source folder and the vendored `external/` folder.
- Old and new copies of the same function that live in folders named `old` and `new` are
  reported like any other duplicate unless recorded as known.
- A conflict with a MATLAB toolbox that is not installed on the machine cannot be detected on
  that machine; the test reports only conflicts it can see and says which MATLAB it used.
- The test must not leave files behind and must not change the MATLAB path of later tests.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: A test in the verified-tests suite MUST fail when a function in the toolbox
  source folder has the same file name as another function in the toolbox source folder or the
  vendored external folder, ignoring `private/`, `@class/` and `+package/` folders.
- **FR-002**: The same test MUST fail when such a function has the same name as a MATLAB
  built-in function or a function of an installed MATLAB toolbox, determined on the machine
  that runs the test.
- **FR-003**: Names that differ only by letter case MUST be treated as the same name.
- **FR-004**: Conflicts that already exist MUST be recorded in one known-conflicts file, each
  with the function name, the kind of conflict and a short reason; the test MUST pass for
  recorded conflicts and fail for any conflict that is not recorded.
- **FR-005**: The failure message MUST list every unrecorded conflict with: the function name,
  the conflicting path(s) (including the MATLAB location when it is a MATLAB function), why it
  matters, and how to resolve it, including how to record an intentional, reviewed duplicate.
- **FR-006**: A recorded entry whose conflict no longer exists MUST NOT fail the test; it MUST
  be reported as removable.
- **FR-007**: The test MUST be self-checking: it MUST prove, on a small temporary tree created
  and removed by the test, that a duplicate toolbox name, a MATLAB built-in name and a
  case-only difference are detected with an explanatory message, and that a clean tree passes.
- **FR-008**: The test MUST follow the constitution's testing rules (tier declaration,
  requirements declared at the start, assertions, readable header, no files left behind, no
  change to the MATLAB path or to any `src/` file).
- **FR-009**: The test MUST pass on the current repository.
- **FR-010**: The repository MUST contain no personal information in the files added.
- **FR-011**: The change-based pull-request test selection MUST run this test whenever a
  function file under the toolbox source folder is added, renamed or changed, even though the
  test does not mention that function by name (otherwise a new, unreferenced function would
  select no test at all).

### Key Entities

- **Conflict**: a function name that exists more than once on the MATLAB path, or that exists
  in the toolbox and in MATLAB.
- **Known-conflicts file**: the reviewed list of conflicts that already existed when the check
  was introduced, each with a reason.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: On the current repository the test passes, and every one of the 23 duplicate
  names and the MATLAB-shadowing names found today is recorded with a reason.
- **SC-002**: Adding a function with an existing toolbox name makes the test fail with a
  message that contains both file paths, in a demonstration run.
- **SC-003**: Adding a function named after a MATLAB function makes the test fail with a
  message that contains the MATLAB file location, in a demonstration run.
- **SC-004**: Every failure message contains the five items of FR-005, checked by the test's
  own self-check.
- **SC-005**: The test runs in under 30 seconds on the full source tree.
- **SC-006**: `git diff --stat -- src` is empty and the test leaves no file behind.
- **SC-007**: Given a change list that contains only a new function file under the source
  folder, the test selection output includes this test.

## Assumptions

- The check runs in MATLAB with the toolbox initialised, which is how the whole suite runs.
- The known-conflicts file is plain text that people can read and edit by hand; it lives with
  the test.
- A MATLAB toolbox that is installed on the CI machine but not on a developer machine may
  produce a conflict only in CI; this is acceptable and the message says which MATLAB was used.
- The exact test name, folder and file format are decided in the plan.

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1, US2, US3 / FR-001..003, FR-005, FR-007 | the new name-conflict test (self-check section and repository scan) | — (no source function; checks the whole source tree) |
| US4 / FR-004, FR-006, FR-009, SC-001 | the same test, with the known-conflicts file | — (no source function) |
