# Phase 1 Data Model: src/ Function Header Documentation Compliance

This feature has no runtime domain data. The "data model" is the set of structures the
**checker** produces and the **work-unit** decomposition that drives remediation.

## Entity: HeaderRule

A single compliance rule the checker evaluates against a function header. The full
catalog is the contract in [`contracts/header-rules.md`](./contracts/header-rules.md).

| Field | Type | Meaning |
|-------|------|---------|
| `id` | char (e.g. `H01`) | stable rule identifier used in reports and CI failures |
| `severity` | `error` \| `warning` | `error` blocks the CI gate; `warning` is reported only |
| `appliesTo` | `function` \| `script` \| `both` | which file kind the rule is evaluated on |
| `summary` | char | one-line human description (mirrors the documentation guide) |

## Entity: Violation

One rule failure at one location, emitted by `checkFunctionHeaders.m`.

| Field | Type | Meaning |
|-------|------|---------|
| `file` | char | repo-relative path of the `.m` file |
| `ruleId` | char | the `HeaderRule.id` that failed |
| `line` | double | 1-indexed line of the offending header line (0 if whole-header) |
| `detail` | char | specifics (e.g. `output "rxnIDexists" missing from OUTPUTS block`) |
| `severity` | `error` \| `warning` | inherited from the rule |

## Entity: FileClassification

How the checker triages each `src/*.m` file before applying rules.

| Value | Meaning | Rule set applied |
|-------|---------|------------------|
| `function` | first non-comment line is a `function` signature | full rule catalog |
| `script` | no `function` signature | description + `%`-spacing rules only (FR-010) |
| `excluded-vendored` | matches an R2 exclusion glob or file-level licence guard | none; reported as excluded |

## Entity: WorkUnit

The atomic unit of parallel remediation (FR-011, research R6).

| Field | Type | Meaning |
|-------|------|---------|
| `folder` | char | a `src/` leaf folder path (one of 243) |
| `domain` | enum | `analysis`\|`base`\|`dataIntegration`\|`design`\|`reconstruction`\|`visualization` |
| `files` | list<char> | the in-scope `.m` files in that folder (excludes vendored) |
| `baselineViolations` | int | violation count for the folder at baseline |
| `assignedAgent` | char | agent-assignments.yml entry (set by the assign step) |

Invariant: work-units partition the in-scope file set — every in-scope file belongs to
exactly one unit; excluded files belong to none. Two units never share a file (no write
conflict under parallel execution).

## Entity: ComplianceReport

The checker's machine-readable output (FR-001) and its committed baseline (FR-002).

| Field | Type | Meaning |
|-------|------|---------|
| `generatedFrom` | char | git ref / working-tree marker |
| `totals` | struct | in-scope file count, function/script split, excluded count |
| `perDomain` | table | domain → {files, filesWithViolations, violationsBySeverity} |
| `perRule` | table | ruleId → count |
| `violations` | list<Violation> | the full enumerated list |

The **baseline** is a `ComplianceReport` snapshot committed under
`specs/014-src-header-compliance/reports/baseline.md`; a **post-remediation** report is
produced the same way to show movement to zero in-scope `error`-severity violations
(SC-001, SC-006).

## State transition: a header over the feature lifecycle

```text
non-compliant (baseline)
   → [remediation unit edits header comments only]
   → checker: 0 error-severity violations for the file
   → diff check: only comment/whitespace lines changed (SC-005)
   → Sphinx parse: no header-format error (SC-004)
   → compliant (part of a clean domain in the post-remediation report)
```
