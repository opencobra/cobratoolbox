# Contract: skip-count gate

A CI step that surfaces the skipped-test count and warns (never fails) when it rises above a
committed baseline.

## Inputs

- `testReport.junit.xml` — produced by `testAll.m` (`skipped="%d"` attribute on `<testsuite>`,
  = `sum(resultTable.Skipped)`).
- `test/verifiedTests/.skip-baseline.json` — `{ "maxSkipped": <int>, "recordedOn": "...",
  "environment": "...", "note": "..." }`.

## Behaviour

```
skipped   := parse skipped= from testReport.junit.xml
maxSkip   := .skip-baseline.json .maxSkipped
report skipped as a visible CI output          # FR-007
if skipped > maxSkip:
    emit  ::warning:: "Skipped tests <skipped> exceeds baseline <maxSkip> (silent erosion?)"
# ALWAYS exit 0 — never fail the build (FR-008); step also continue-on-error
```

## Guarantees

- The build's red/green is **unchanged** by this step (only `sumFailed>0` reds the build).
- The step is deterministic given the two inputs; no network.
- The baseline is human-updatable: an intentional environment change updates
  `.skip-baseline.json` in the same PR (with a `note`).

## Out of scope (deferred)

- Hard-failing the build on skip increase (the clarify decision chose flag/warn on rollout).
- Per-category skip thresholds (single global count for now).
