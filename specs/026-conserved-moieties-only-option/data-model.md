# Phase 1 Data Model: Conserved-Moieties-Only Option

No new persistent data entities are introduced. This feature adds one input field and
changes the shape of one existing output field under one new condition.

## `options.conservedMoietiesOnly` (input, new)

- **Type**: MATLAB logical scalar (boolean).
- **Default**: `false` (field absent, or explicitly `false`) — today's full-computation
  behavior, unchanged.
- **When `true`**: the function performs only the conserved-moiety computation and returns
  before the reacting-moiety section runs.
- **Validation**: none beyond MATLAB's own truthiness coercion, consistent with the
  function's existing `options.sanityChecks`/`options.useOpenSourceMoietyTools` fields (no
  type-checking is done on those either).

## `arm` (output, unchanged in content)

- Unchanged: this feature does not add, remove, or alter any field of `arm`. The same code
  that populates `arm.MRH`, `arm.MTG`, `arm.L`, `arm.M2M`, `arm.M2R`, and every other
  documented field runs identically whether or not `conservedMoietiesOnly` is set — the
  option only decides whether execution continues into the reacting-moiety section
  afterward, which does not write to `arm`.

## `moietyFormulae` (output, unchanged in content)

- Unchanged: produced by the same conserved-moiety code path in both modes.

## `reacting` (output, new "not computed" state added)

- **Existing (default / `conservedMoietiesOnly = false`) state**: unchanged — the struct the
  reacting-moiety section already populates (`selectedReactionNames`, and the fields
  `buildReactingMoietyTables`/`displayReactingMoieties` consume), exactly as today.
- **New (`conservedMoietiesOnly = true`) state**:
  - `reacting.computed` (logical): `false`.
  - No other fields are present (see research.md's "Shape of `reacting`" decision).
  - Distinguishing rule for callers: `~isfield(reacting, 'computed') || reacting.computed`
    is `true` exactly when a genuine reacting-moiety result is present; the new
    `struct('computed', false)` state is the only case where this evaluates to `false`.

## State transitions

None — this is a single, stateless function call whose two output "shapes" for `reacting`
are selected once, at call time, by `options.conservedMoietiesOnly`. There is no persisted
state and no transition between the two shapes within a single call.
