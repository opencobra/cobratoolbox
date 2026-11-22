# Data model

## Ledger row (`inventory/ledger.tsv`, one row per untested file, tab-separated)

| Field | Meaning |
|---|---|
| `order` | position in the campaign order (tier, then callees before callers) |
| `file` | repository-relative path of the source file |
| `tier` | effective tier 1, 2, 3 or 4 (`4` means Tier 4/5); initial from R2, final as set by the test |
| `status` | PENDING, TESTED, QUARANTINED, BLOCKED, EXCLUDED |
| `reason` | EXCLUDED: why; QUARANTINED: defect title; BLOCKED: `blocked by <f>[, <g>]` |
| `flags` | `external-program`, `shadowed-name` (informational) |
| `cycle` | the other members of its call cycle, if any |
| `untested_callees` | untested `src/` functions it calls (must be done before it) |
| `callers` | every `src/` file that calls it |
| `test` | the test file written (TESTED, QUARANTINED) |
| `lines`, `missed`, `exempt` | executable lines of the function, uncovered lines, uncovered lines documented as exemptions |
| `wave` | wave number in which the row left PENDING |

`tools/build_inventory.py` writes the first nine fields; `tools/update_ledger.py` adds the
others from agent results (`contracts/agent-result.md`) and propagates blocking.

## Status transitions

```
PENDING ──test passes, coverage complete──────────────▶ TESTED
PENDING ──wrong-result / error / unusable-option──────▶ QUARANTINED ──(confirmed by 2nd reader)──▶ callers PENDING → BLOCKED
PENDING ──cosmetic / limitation───────────────────────▶ TESTED (defect in header, input skipped)
PENDING ──calls a QUARANTINED function────────────────▶ BLOCKED
PENDING ──cannot be tested here (R1, found at writing)─▶ EXCLUDED
```

TESTED ──late-discovered call to a QUARANTINED function (R6)──▶ BLOCKED (its new test removed;
its TESTED callers follow)

No other transition exists in this feature. QUARANTINED, BLOCKED and EXCLUDED are final; TESTED is
final unless the late-edge rule applies.

## Defect (in a test header, III-Defects format)

DEFECT, SEVERITY, TRIGGER, OBSERVED, EXPECTED, LINES; plus, in the ledger, `quarantine: yes/no`
(FR-007) and, for quarantines, `confirmed by: <reader>`.

## Wave

Set of PENDING rows of the lowest remaining tier whose untested callees are all final and not
QUARANTINED/BLOCKED (those would make the row BLOCKED instead). Split into slices of ≤ 10 rows,
one per helper agent.

## Existing-defective list (`inventory/existing-defective.tsv`)

Already-tested functions (outside the 1085) in which a quarantining defect was found (FR-012):
function, existing test, defect title, rows it blocks. Their tests keep their assertions and record
the defect by the input-level rule.

## Quarantine seeds (`inventory/quarantine-seeds.tsv`)

`<defective function><TAB><src file>`: files whose code reaches a defect confined to a call form
(constitution 1.8.1). A quarantined function without lines here is its own seed (every call
reaches the defect).

## Quarantine list (`inventory/quarantine.md`, generated)

One section per QUARANTINED function: defect, evidence, confirming reader, and the BLOCKED files it
blocks (directly and indirectly), sorted by the number of files blocked.

## Summary (`inventory/summary.md`, generated)

Counts by status × tier; excluded files grouped by reason; quarantine ranking; coverage before and
after (R10).
