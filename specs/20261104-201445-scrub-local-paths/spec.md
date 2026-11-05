# Feature Specification: Remove local machine details from older feature records

**Feature Branch**: `20261104-201445-scrub-local-paths`

**Created**: 2026-11-04

**Status**: Draft

**Input**: User description: "Remove the maintainer's personal local-machine details from older feature records and scripts already published on the public develop branch, without losing anything those files need to work or to stay auditable. Benchmark scripts that use such paths at runtime must keep working. Implementation receipts get minimal, marked redaction as the constitution allows. Out of scope: rewriting upstream git history, other contributors' records, the project name as a word, solver and MATLAB versions and commit ids that record benchmark conditions, and src or test changes. The feature's own documents must not repeat any removed string."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Published records carry no personal machine details (Priority: P1)

The repository is public. A reader of the current `develop` tree must not be able to learn the
maintainer's home-directory layout, local project folders, session scratch folders or workstation
hardware from the older records.

**Why this priority**: This is the purpose of the feature; the maintainer asked for it.

**Independent Test**: Run the scan in `quickstart.md` over the whole tree. It reports no match in
any file the maintainer authored.

**Acceptance Scenarios**:

1. **Given** the feature is merged, **When** the tree is searched for the maintainer's home path in
   any form, including the form embedded in a scratch-folder name, **Then** there are no matches.
2. **Given** the feature is merged, **When** the benchmark records are read, **Then** they state no
   workstation core count or memory size.

---

### User Story 2 - Benchmark scripts keep working (Priority: P1)

Six benchmark scripts use the paths at runtime. Someone reproducing the results must be able to run
them from any clone, and must get a clear message where a private input is not supplied.

**Why this priority**: The maintainer required that nothing necessary is removed. Deleting these
paths without a replacement would break the scripts.

**Independent Test**: Run each script's path setup from a clone in a different location from the
original and confirm the toolbox and the `ref` folder are found.

**Acceptance Scenarios**:

1. **Given** a clone at any location, **When** a script needs the toolbox root, **Then** it finds it
   from its own file location or receives it as an argument.
2. **Given** the two differential scripts, **When** they run, **Then** they use the renamed reference
   functions already stored in the repository's `bench/ref` folder.
3. **Given** a script needs a private model or private code, **When** the input is supplied, **Then**
   it behaves as before; **When** it is not supplied and is needed, **Then** it stops with a message
   naming what to provide.
4. **Given** the benchmark logic, **When** the scripts are compared with their earlier versions,
   **Then** only the path handling has changed.

---

### User Story 3 - The audit trail stays intact (Priority: P2)

Old receipts and records are the project's audit trail. They must still say what they said, apart
from the personal details, and any receipt redaction must be visible.

**Why this priority**: The constitution allows minimal redaction of personal data in receipts only
when it is marked.

**Independent Test**: Diff each record against `develop`. Only lines holding a personal detail
change, and each edited receipt carries a redaction note.

**Acceptance Scenarios**:

1. **Given** a receipt link pointing at a local absolute path, **When** it is redacted, **Then** it
   points at the repository-relative file, so the link works for every reader.
2. **Given** an edited receipt, **When** it is read, **Then** a dated note states what was redacted.
3. **Given** a task in an older `tasks.md` that named a throwaway helper in a scratch folder, **When**
   it is edited, **Then** the task still says which helper was used and that it was not kept.

---

### Edge Cases

- A path sits inside a code comment read by nothing: it is replaced with the repository-relative
  path so the record of the input file survives.
- A private model is needed only by some benchmark stages: other stages run without it.
- A comparison in a record relies on runs being on the same machine: the record keeps that statement
  without naming the machine's size.
- Other contributors' records contain their own paths or machine details: they are not touched.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The current tree MUST contain no form of the maintainer's home path, including the
  form embedded in session scratch-folder names.
- **FR-002**: Benchmark records authored by the maintainer MUST NOT state workstation core count or
  memory size. Software versions, commit ids and imposed memory caps MUST stay, because they define
  the benchmark conditions.
- **FR-003**: The five benchmark scripts that used a fixed toolbox path MUST locate the toolbox from
  their own file location. `stageRun` keeps receiving it as an argument.
- **FR-004**: The two differential scripts MUST use the repository's `bench/ref` folder.
- **FR-005**: Private inputs to benchmark scripts MUST come from parameters or environment variables.
  A script that needs an input that is missing MUST stop with a message naming it.
- **FR-006**: Benchmark logic, seeds and output formats MUST NOT change.
- **FR-007**: Receipt edits MUST be limited to the personal details, and each edited receipt MUST
  carry a dated redaction note. All other text, including the recorded final response, MUST stay
  word for word.
- **FR-008**: Local absolute links in receipts MUST become repository-relative links to the same file.
- **FR-009**: The benchmark README MUST describe how the scripts now find their inputs.
- **FR-010**: Only the files listed in the Scope section, this feature's own directory, and the
  Spec Kit pointer `.specify/feature.json` MUST change. Nothing under `src` or `test` changes. No file is deleted.
- **FR-011**: The feature's documents, commit message and pull request MUST NOT repeat any removed
  detail.

### Scope: files to change

Receipts (minimal marked redaction):

- `specs/016-fastbarrier-fallback/agent-runs/20260814T140749Z-fastbarrier-fallback/implementation-receipt.md`
- `specs/017-buildgurobifrommodel-tests/agent-runs/20260817T121447Z-buildgurobifrommodel-characterization/implementation-receipt.md`
- `specs/019-full-site-search/agent-runs/20260817T170429Z-full-site-search-implement/implementation-receipt.md`
- `specs/019-full-site-search/agent-runs/20260819T110014Z-review-fixes/implementation-receipt.md`
- `specs/20261021-112509-recon-ci-scalability/agent-runs/20261022T180000Z-checkduplicate-removefieldentries/implementation-receipt.md`

Records:

- `specs/019-full-site-search/tasks.md`
- `specs/20260903-150733-canonicalize-subsystem-matrix/quickstart.md`
- `specs/20261021-112509-recon-ci-scalability/research.md`
- `specs/20261021-112509-recon-ci-scalability/bench/README.md`
- `specs/20261029-120000-checkmodelproperties-scalability/research.md`
- `specs/20261102-140321-tier1-safe-defect-fixes/tasks.md`
- `specs/20261102-142225-tier2-test-pilot/tasks.md`

Scripts:

- `specs/20261021-112509-recon-ci-scalability/bench/diffDup.m`
- `specs/20261021-112509-recon-ci-scalability/bench/diffRFE.m`
- `specs/20261021-112509-recon-ci-scalability/bench/profRun.m`
- `specs/20261021-112509-recon-ci-scalability/bench/runTest.m`
- `specs/20261021-112509-recon-ci-scalability/bench/stageRun.m`
- `specs/20261029-120000-checkmodelproperties-scalability/bench/ownCode.m`

Deprecated data (this feature is explicitly about this path, as Principle V requires):

- `deprecated/_testTopology/loop3b_neg_eq.ext`

### Out of scope

- Rewriting upstream git history. Older commits stay public.
- Other contributors' records, paths and machine details.
- The word ReconXKG and the reproducibility scripts that refer to it. It appears throughout other
  contributors' records and those scripts need their fixture locations.
- The shared CI runner's name.
- A permanent automated scanner.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The scan finds 0 matches for the maintainer's home path, in any form, across the tree.
- **SC-002**: 0 maintainer-authored benchmark records state workstation core count or memory size.
- **SC-003**: 6 of 6 scripts resolve their paths from a clone at a different location.
- **SC-004**: 100% of changed lines in the 19 listed files hold a personal detail, its replacement,
  a redaction note, or the path handling that replaces it.
- **SC-005**: 5 of 5 edited receipts carry a redaction note.
- **SC-006**: 0 files change outside the list, the feature directory and the Spec Kit pointer.

## Assumptions

- Removing a path from the current tree does not remove it from git history; the maintainer accepted
  this.
- The self-hosted CI runner's name is not a personal detail: it is the project's shared runner and is
  documented in a live workflow file. It stays, both there and in the older spec that mentions it.
- Home paths and hardware counts are personal data under the constitution's receipt redaction rule.
- The private model and code are not needed to confirm path handling. Runs that need them are
  checked only as far as the point where the private input is requested.

## Traceability

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1 / FR-001, FR-002, FR-011 | scan in `quickstart.md` | — (no source function) |
| US2 / FR-003, FR-004, FR-005 | path checks in `quickstart.md` | — (no source function) |
| US2 / FR-006, FR-009 | diff review of the scripts and README | — (no source function) |
| US3 / FR-007, FR-008 | diff review of the receipts and link check | — (no source function) |
| FR-010 | changed-file list against the Scope section | — (no source function) |
