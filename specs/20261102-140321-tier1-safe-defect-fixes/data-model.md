# Data model: safe Tier-1 defect fixes

## Table-A defect (fixed)

- Fields: function, source path, test path, registry title, severity, TRIGGER, EXPECTED, reason
  it is safe (spec table A).
- Transition: `documented` → `fixed`. On fixing: the source is changed; the test asserts EXPECTED
  on TRIGGER; the header entry is removed (header says "None found." when no entry remains) and
  a line "Fixed by feature 20261102-140321-tier1-safe-defect-fixes: <title>" is added to the
  Purpose block; coverage exemptions are updated.
- Alternative transition (FR-007): `documented` → `moved to table B` with a reason; the header
  entry stays.

## Table-B defect (documented)

- Fields: function, registry title, severity, reachable paths, measured or assessed effect,
  published results affected (yes/no/unknown), Tier-2 exposure, recommendation.
- No transition in this feature; the header entry stays unchanged.

## New problem

- Fields: location (file:line), reproduction, effect, recommendation. Lives only in
  `attention-defects.md`.

## Attention document entry format

```text
### <function> — <registry title or problem title>
- Severity: <registry severity or "not registered">
- Reached from: <callers / tutorials / papers>
- Effect of a fix: <measured result or assessment>
- Published results affected: <yes / no / unknown, with reason>
- Tier-2 exposure: <none, with reason>
- Recommendation: <action and who decides>
```
