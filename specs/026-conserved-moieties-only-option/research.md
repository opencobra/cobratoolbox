# Phase 0 Research: Conserved-Moieties-Only Option

No open NEEDS CLARIFICATION markers remain in plan.md's Technical Context — this feature is
small and self-contained enough that Phase 0 mainly records the decisions already made while
writing spec.md, plus the confirmation of one investigation done directly against the code.

## Decision: New option field name and default

- **Decision**: `options.conservedMoietiesOnly` (boolean, default `false`).
- **Rationale**: Matches this function's existing options-struct naming style
  (`sanityChecks`, `useOpenSourceMoietyTools` — camelCase, verb/noun or adjective-noun,
  boolean flags default to today's behavior). Default `false` preserves Principle II
  backward compatibility exactly.
- **Alternatives considered**: `options.skipReacting` (rejected — names the mechanism, not
  the intent, and reads awkwardly next to the function's other options which name what they
  *enable*, not what they *skip*); a separate function wrapper instead of an options field
  (rejected — the PI's request explicitly asked for "an option to the reacting code," not a
  new entry point, and a wrapper would not by itself save the reacting-moiety compute cost
  unless it also duplicated the early-return logic, so it doesn't reduce risk).

## Decision: Where the skip happens

- **Investigation**: Read `identifyConservedReactingMoieties.m` in full. Confirmed the
  conserved-moiety computation completes at `arm.L = L;` (current line ~1459), immediately
  followed, with no guard, by `%% Reacting moiety (bond-level) analysis` (current line
  ~1461), which runs unconditionally through six steps (duplicate-edge removal, bond-index
  mapping, CRB2R construction, minimum-set-cover MILP solve, reacting-moiety computation,
  and storing results into `reacting`).
- **Decision**: Insert the new option's early-return check immediately after `arm.L = L;`
  and before the `%% Reacting moiety (bond-level) analysis` comment — this is the one point
  in the function where the conserved-moiety computation is provably complete and the
  reacting-moiety computation has not yet started.
- **Rationale**: Minimizes the diff, keeps the conserved-moiety code path byte-identical in
  both modes (it is literally the same code, just followed or not followed by more code),
  and needs no restructuring of the existing six-step reacting-moiety block.
- **Alternatives considered**: Wrapping the entire reacting-moiety block in an `if
  ~conservedMoietiesOnly ... end` (rejected — a large diff touching ~250 lines invites
  accidental changes to that block and is harder to review than a two-line early return; the
  function already has a single `return`-free, `function ... end`-delimited body with no
  other early returns, so introducing one is a small, legible precedent rather than a novel
  pattern).

## Decision: Shape of `reacting` in conserved-only mode

- **Decision**: `reacting = struct('computed', false);` — a struct with exactly one field,
  `computed`, set to `false`.
- **Rationale**: Satisfies spec FR-004 (must be unambiguously distinguishable from a real
  result) with the smallest possible surface: any caller can check
  `isfield(reacting, 'selectedReactionNames')` or, more robustly,
  `~isfield(reacting, 'computed') || reacting.computed` before trusting `reacting`'s other
  fields, without this feature needing to enumerate and null out every field the reacting-
  moiety section would otherwise have populated (which would silently go stale the next time
  that section's output shape changes).
- **Alternatives considered**: `reacting = [];` (rejected — indistinguishable from "not yet
  assigned" in a debugger and does not self-document why); populating every real field with
  empty/NaN placeholders (rejected — brittle, must be kept in sync with the six-step
  reacting-moiety block by hand, and spec FR-004 explicitly warns against anything that could
  be mistaken for a genuine result).

## Decision: Test placement and fixture reuse

- **Investigation**: Confirmed `test/verifiedTests/analysis/testReactingMoieties/` already
  contains exactly one test file for this function, `testConservedReactingMoieties.m`
  (356 lines), which builds a small deterministic 4-metabolite/3-reaction Recon3D subnetwork
  from a self-contained `data/rxnFiles` fixture shipped beside the test, and already calls
  `identifyConservedReactingMoieties` once (full mode) with `tol = 1e-8`.
- **Decision**: Extend this file in place; reuse its existing `subModel`, `BG`, `dATM`, `N`,
  and `tol` variables for the new conserved-only call and comparison, immediately after the
  existing full-mode call and its assertions.
- **Rationale**: Principle III-Naming requires exactly one test file per function; the
  spec's own Clarifications resolved the equivalence check to this existing fixture only (no
  larger/real-network validation in scope).
