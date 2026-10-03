# Implementation Receipt: Subsystem Matrix Canonicalization — Review Remediation

**Feature**: `20260903-150733-canonicalize-subsystem-matrix`
**Date**: 2026-09-07 (UTC timestamp `20260907T131645Z`)
**Branch**: `20260903-150733-canonicalize-subsystem-matrix`

## Prompt

The user pasted three `chatgpt-codex-connector` PR review comments (bot review, on
commit `a9cdcb790`) verbatim and asked for them to be addressed:

1. P2, `src/visualization/SAMMIM/sammi.m`: "Handle models with no named subsystems" —
   when every reaction's `subSystems` is empty, `buildRxn2subSystem` returns an empty
   `subSystemNames`, the grouping loop runs zero times, `dat` is never created, and
   `structParse(model, dat)` throws an undefined-variable error.
2. P2, `src/visualization/SAMMIM/sammi.m`: "Avoid warning when optional subsystem
   fields are absent" — the `warning('The "rxn2subSystem" field has been
   generated...')` fires on every routine `sammi(model,'subSystems',...)` call that
   hasn't precomputed the derived fields (the common case), which is noisy and can
   fail in environments that treat warnings as errors.
3. P1, the implementation receipt (`agent-runs/20260907T120858Z-.../implementation-receipt.md`):
   "Use the required implementation-receipt categories" — the receipt didn't use the
   constitution's mandated `Prompt`/`Final response`/`Diff summary`/`Tests`/`Unresolved
   issues` structure, and its file list omitted `.specify/feature.json`, `CLAUDE.md`,
   `checklists/requirements.md`, and `data-model.md`.

## Final response

Fixed all three findings.

**P2 #1 (undefined `dat`)**: initializing `dat = struct('name',{},'rxns',{})` before
the grouping loop stopped the "undefined variable" crash, but exposed a *second*,
deeper defect one layer down — with zero named subgraphs, `structParse` reduces the
model to zero reactions, and `makeSAMMIJson.m:40` unconditionally indexes
`model.(fds{i}){1}` on what is now an empty cell, throwing `Index exceeds array
bounds`. This is a general robustness gap (would hit any `sammi()` call reduced to
zero reactions, not just via `subSystems`), so I added a one-line, purely-additive
guard there (`~isempty(model.(fds{i}))`) rather than leaving the edge case still
broken. Verified both the `''`-per-reaction and `{}`-per-reaction shapes no longer
throw.

**P2 #2 (noisy warning)**: removed the `warning(...)` call from `sammi.m`'s ephemeral
matrix-build path. Unlike `isReactionInSubSystem.m`/`findRxnsFromSubSystem.m` (which
keep their own analogous warnings — out of scope, unchanged), building this matrix
here is the expected, routine path for a plain `sammi(model,'subSystems',...)` call on
a model that only has the legacy `subSystems` field, not a fallback worth flagging on
every invocation.

Codified both fixes as a new `testSammi.m` case 13 (verified standalone, same
Statistics-Toolbox-license limitation as the original run — see Unresolved issues),
and re-ran the full existing verification suite (case 12 oracle, cases 0–3 regression,
and all 7 runnable non-`sammi` tests) to confirm nothing else broke.

**P1 (receipt format)**: restructured `agent-runs/20260907T120858Z-.../implementation-receipt.md`
into the mandated five categories, and corrected its diff summary to list all 24 files
from commit `a9cdcb790` (previously it covered only the 9 source/test files and
narratively described the spec-kit doc changes without listing them). This second
receipt, for the review-remediation round itself, also follows that format from the
start.

## Diff summary

4 files changed (uncommitted at time of writing), 123 insertions(+), 118 deletions(-):

- `src/visualization/SAMMIM/sammi.m` (+9/−1): initialize `dat` as an empty struct
  array before the grouping branches; remove the noisy `warning(...)` call from the
  ephemeral-matrix-build path.
- `src/visualization/SAMMIM/makeSAMMIJson.m` (+1/−1): guard
  `model.(fds{i}){1}` against an empty field (`~isempty(model.(fds{i})) &&`).
- `test/verifiedTests/visualization/testSammi/testSammi.m` (+20): new case 13 —
  zero-named-subsystems must not throw; a routine `subSystems` call must not warn.
- `specs/20260903-150733-canonicalize-subsystem-matrix/agent-runs/20260907T120858Z-canonicalize-subsystem-matrix/implementation-receipt.md`
  (restructured, ~209 lines touched): mandated-category rewrite, complete 24-file
  diff summary.

## Tests

| Check | Result |
|---|---|
| Zero-named-subsystems (`subSystems` = `''` for every reaction) via `sammi(...,'subSystems',...)` | PASS (did not throw), verified standalone |
| Zero-named-subsystems (`subSystems` = `{}` for every reaction) | PASS (did not throw), verified standalone |
| Routine `subSystems` call without a pre-built `rxn2subSystem`/`subSystemNames`: no warning emitted (`lastwarn`) | PASS, verified standalone |
| `testSammi` case 12 (equivalence oracle + nested-cell grouping + non-mutation), re-run after these fixes | PASS |
| `testSammi` cases 0–3 regression, re-run after these fixes | PASS |
| Full 7-of-8 regression run (`testGetModelSubSystems`, `testFindRxnsFromSubSystem`, `testIsReactionInSubSystem`, `testBuildRxn2subSystem`, `testWriteSBML`, `testVerifyModel`, `testModel2JSON`) | PASS, unaffected by these `sammi`/`makeSAMMIJson`-only changes |

## Unresolved issues

- **`testSammi.m` still cannot run in full in this environment** (same
  `statistics_toolbox` license gap as the original run — unrelated to and unchanged
  by this round). New case 13 was verified via a standalone script outside the
  toolbox gate, same method as the original run's case 12. Recommend a CI run before
  merge, same as before.
- The `makeSAMMIJson.m:40` guard is intentionally minimal (empty-check only); it does
  not audit every other field-serialization line in that function for the same class
  of unconditional-indexing risk, since only this one was reachable from this
  feature's own new code path.
- Not yet committed or pushed at time of writing; the user will handle commit/push
  and reply to the reviewer.

## Other information

Both receipts now exist under this feature's `agent-runs/`: the original
`20260907T120858Z-canonicalize-subsystem-matrix/` (implementation) and this one,
`20260907T131645Z-review-remediation/` (review fixes), rather than silently folding
this round's changes into the first receipt under its original timestamp.
