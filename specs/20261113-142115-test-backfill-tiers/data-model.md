# Data model

## Ledger row (`inventory/ledger.tsv`, one row per untested file, tab-separated)

| Field | Meaning |
|---|---|
| `order` | position in the campaign order (tier, then callees before callers) |
| `file` | repository-relative path of the source file |
| `tier` | 1, 2, 3 or 4 (Tier 4/5); initial from R2, final as set by the test |
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

No other transition exists in this feature. TESTED, QUARANTINED, BLOCKED and EXCLUDED are final
(R6 covers a TESTED file that reaches a quarantine through a late-discovered edge: its row stays
TESTED and gets a note).

## Defect (in a test header, III-Defects format)

DEFECT, SEVERITY, TRIGGER, OBSERVED, EXPECTED, LINES; plus, in the ledger, `quarantine: yes/no`
(FR-007) and, for quarantines, `confirmed by: <reader>`.

## Wave

Set of PENDING rows of the lowest remaining tier whose untested callees are all final and not
QUARANTINED/BLOCKED (those would make the row BLOCKED instead). Split into slices of ≤ 10 rows,
one per helper agent.

## Quarantine list (`inventory/quarantine.md`, generated)

One section per QUARANTINED function: defect, evidence, confirming reader, and the BLOCKED files it
blocks (directly and indirectly), sorted by the number of files blocked.

## Summary (`inventory/summary.md`, generated)

Counts by status × tier; excluded files grouped by reason; quarantine ranking; coverage before and
after (R10).
