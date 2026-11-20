# Feature Specification: lrsRun without the separate redund program

**Feature Branch**: `20261113-142115-test-backfill-tiers` (the open pull request's branch; the
maintainer asked for this fix to go into that pull request, 2026-11-20)

**Created**: 2026-11-20

**Status**: Draft

**Input**: User description: "lrsRun without the separate redund program (Constitution 1.10.0,
Principle XI). Maintainer (2026-11-20): '1 - you can include the fix in the PR it is ok. 2 - Yes do
the feature with speckit.'" The full description is kept in the conversation record and summarised
under Context.

## Context

`lrsRun` (src/analysis/topology/extremeRays/lrs/lrsInterface/lrsRun.m) runs the lrs program of
lrslib to convert between vertex/ray descriptions (V-representations) and inequality descriptions
(H-representations) of a polyhedron. With `param.redund = 0` and facet enumeration, it then removes
redundant inequalities by running a second program, `redund`.

- COBRA's own lrslib for Linux (`binary/glnxa64/bin/lrs`, lrslib 7.3) and the CI machine of the pull
  request have `lrs` but no `redund`. On them this documented option fails (exit status 127), and
  `testLrsRun` must declare `redund` as a requirement, so CI skips the whole test.
- Since lrslib 7, `redund` is the same program as `lrs`: on Debian/Ubuntu `/usr/bin/redund` is a link
  to `lrs`. `lrs` itself removes redundant inequalities when its input carries the option line
  `redund 0 0` after `end`. On 2026-11-20 this gave the same irredundant H-representation as `redund`,
  row for row, on four inputs, with the installed lrs 7.1 and the bundled lrs 7.3. The inputs: the
  quadrant of testLrsRun, an lrs facet-enumeration output, a two-variable example, and a 3-D example
  with an equality (`linearity`) and redundant rows.
- `lrsRun` already contains a route that uses this option (lines 128-135), but it is switched off. It
  would edit lrs's intermediate output file in place with `sed`, replacing every occurrence of
  `end` in that file, not only the `end` line.

Constitution 1.10.0, Principle XI, option 2: a capability is taken from a component the code already
requires (`lrs`) rather than from a further program.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Remove redundant facets with lrs alone (Priority: P1)

A researcher computes the irredundant facets of a polyhedron with
`lrsRun(name, struct('redund', 0))` on a machine that has COBRA's lrs but no separate `redund`
program, which includes COBRA's own Linux binaries and the project CI.

**Why this priority**: today this documented option fails on those machines, and the test of
`lrsRun` cannot run on CI.

**Independent Test**: run `lrsRun` with `redund = 0` and facet enumeration on a machine (or `PATH`)
with `lrs` and no `redund`; the output file holds the irredundant facets.

**Acceptance Scenarios**:

1. **Given** a V-representation file `q7_noR.ext` of the quadrant and a machine with `lrs` but no
   `redund`, **When** `lrsRun('q7', struct('redund', 0, 'facetEnumeration', 1))` runs, **Then** it
   returns `q7_noR_noR.ine`, which holds the two facets x1 >= 0 and x2 >= 0, without the trivial row
   1 >= 0 that lrs writes to `q7_noR.ine`.
2. **Given** the same call, **When** it finishes, **Then** `q7_noR.ine` (lrs's facet output) still
   holds the facets lrs wrote, the trivial row included, and no other file is left in the folder
   beyond those two.
3. **Given** a machine that also has `redund`, **When** the same call runs, **Then** the result is the
   same: `redund` is not used.

### User Story 2 - Test of lrsRun runs on CI (Priority: P1)

A maintainer relies on CI to check `lrsRun`.

**Why this priority**: a skipped test verifies nothing (Principle XI).

**Independent Test**: `testLrsRun` declares only `lrs`, passes with `redund` absent from the `PATH`,
and reaches every executable line of `lrsRun` apart from the documented exemptions.

**Acceptance Scenarios**:

1. **Given** a `PATH` with `lrs` but no `redund`, **When** `testLrsRun` runs, **Then** it passes (it
   is not skipped).
2. **Given** a failing `lrs` in the redundancy step, **When** `lrsRun` runs it, **Then** it raises
   `lrsRun:commandFailed`, naming the command and its exit status, as for the other commands.

### Edge Cases

- The lrs output contains comment lines (starting with `*`) after `end`, and its count line is
  first written as `*****`. `lrsRun` already fixes the count with `lrsSpecifyRows` before the
  redundancy step; the redundancy input must carry the corrected count (bundled lrs 7.3 crashes on
  `*****`).
- A file name or comment containing the letters `end` must not be altered.
- An H-representation with an equality (`linearity`) keeps it in the output.
- Shell-script mode, vertex enumeration and `redund = 1` behave exactly as before.
- Non-Unix machines: unchanged (lrsRun prints that they are not supported).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: With `param.redund = 0` and facet enumeration, `lrsRun` MUST remove redundant
  inequalities with the `lrs` program alone, using lrs's `redund` option, and MUST NOT call a program
  named `redund`.
- **FR-002**: The returned file name MUST stay as today: lrs writes its facets to `<m>.ine` and the
  irredundant facets go to `<m>_noR.ine`, where `<m>` is the model name as lrsRun forms it (`q7`
  becomes `q7_noR`, so `q7_noR_noR.ine` is returned; `q8.ext` becomes `q8`, so `q8_noR.ine` is
  returned). The irredundant facets in that file MUST be the same as those `redund` produced.
- **FR-003**: `lrsRun` MUST NOT modify lrs's facet output file (`<m>.ine`) or any input file
  to add the option, and MUST NOT leave a temporary file in the working folder.
- **FR-004**: A non-zero exit status of the redundancy step MUST raise `lrsRun:commandFailed` with
  the command, status and output, as for the other commands; the printed command line shows the
  command run.
- **FR-005**: All other behaviour (inputs, defaults, vertex enumeration, `redund = 1`, shell-script
  mode, the messages for a missing lrs and for non-Unix machines) MUST stay unchanged (Principle II).
- **FR-006**: The help text of `lrsRun` MUST describe the redundancy removal as done by lrs, and the
  NOTE on failing commands MUST no longer name `redund` as a separate program.
- **FR-007**: `testLrsRun` MUST declare only `lrs` (no `redund`), MUST check FR-001 to FR-004 and
  the scenarios above, including a run with no `redund` on the `PATH`, and MUST state its coverage
  exemptions for the changed lines.
- **FR-008**: The narrowest reproducibility check is `testLrsRun`, run with coverage of `lrsRun`
  and once with a `PATH` that has `lrs` but no `redund`.

### Key Entities

- **H-representation file (`.ine`)**: lrs's inequality description: optional `linearity` line,
  `begin`, a count line (rows, columns, number type), one row per inequality, `end`, then options
  and `*` comment lines.
- **Redundancy option**: the line `redund 0 0` after `end`, telling lrs to remove the redundant rows
  of the H-representation and write the remaining ones.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: On a machine with lrs and no `redund`, `lrsRun` with `redund = 0` and facet
  enumeration completes and its output equals what `redund` produces, on every example of
  `testLrsRun`.
- **SC-002**: `testLrsRun` declares no requirement other than `lrs` and passes both with and without
  `redund` on the `PATH`; on CI it runs instead of being skipped.
- **SC-003**: `testLrsRun` reaches every executable line of `lrsRun` except the documented
  exemptions (non-Unix branch), and leaves no file behind.
- **SC-004**: No other file of `src/` changes; the callers of `lrsRun` (`extremePools`,
  `extremePathways` and others) keep their tests' results.

## Assumptions

- lrslib 7.0 or later, which has the `redund` option of lrs; COBRA bundles 7.3 and current Linux
  distributions ship 7.x. Older lrslib (before 2018) is not supported for `redund = 0`; it is not
  supported by the bundled binaries either.
- The temporary input carrying the option is written to the system temporary folder (it cannot
  collide with the user's files) and removed after the call, on success and on failure.
- Scope: `lrsRun.m` and `testLrsRun.m`, plus this feature's records; recorded in the pull request
  description and in the back-fill feature's review.md.

## Traceability

| Acceptance criterion | Test | Source function |
|---|---|---|
| US1-1 irredundant facets with lrs alone, no `redund` on the `PATH` | testLrsRun, section "redund = 0" run with `redund` hidden | src/analysis/topology/extremeRays/lrs/lrsInterface/lrsRun.m |
| US1-2 lrs's facet output unchanged, no temporary file left | testLrsRun, section "redund = 0" | lrsRun.m |
| US1-3 same result when `redund` is installed | testLrsRun, section "redund = 0" (normal `PATH`) | lrsRun.m |
| US2-1 test runs without `redund` | testLrsRun, prepareTest declares only lrs; run with `redund` hidden | lrsRun.m |
| US2-2 failing lrs in the redundancy step raises lrsRun:commandFailed | testLrsRun, section "a failing lrs" | lrsRun.m |
