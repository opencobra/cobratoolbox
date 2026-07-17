# Human Loop State

## Current State
- Status: Bundle 1 (requirements preparation) in progress
- Active feature directory: specs/013-relocate-vendored-code
- Last completed bundle: Bundle 0 (detection)
- Source code modified by this workflow: no

## Core Command Ledger
- constitution:   checked (v1.3.0 present; implementation gated on explicit /speckit-implement)
- specify:        invoked (spec.md written, requirements.md checklist all-pass)
- clarify:        pending
- checklist:      pending
- plan:           n/a (Bundle 2)
- tasks:          n/a (Bundle 2)
- analyze:        n/a (Bundle 2)
- implement:      n/a (Bundle 3, gated)

## Human Decisions
| Date (UTC) | Gate | Option chosen | Consequence |
|---|---|---|---|
| 2026-07-17 | Pre-spec scoping (AskUserQuestion) | Two features; W9 full cleanup; hybrid layering direction | 013 = W9 relocation (this feature); 014 = base layering inversion (separate, later) |

## Approved Implementation Scope
- Approved: no
- Scope: (pending Gate 2)
- Tasks approved: —
- Tasks deferred: —
- Files allowed: — (no source edits before Gate 2 + explicit /speckit-implement)
- Files not allowed: all src/tests/build until approved

## Pointers
- Spec: specs/013-relocate-vendored-code/spec.md
- Requirements checklist: specs/013-relocate-vendored-code/checklists/requirements.md
- Pre-spec design note: ~/.claude/plans/specify-a-fix-to-happy-squirrel.md (covers 013 + planned 014)
- Implementation receipt(s): (none yet — will live under agent-runs/<UTC>-<name>/implementation-receipt.md)
- Implementation review: specs/013-relocate-vendored-code/implementation-review.md (Bundle 2)

## Open Risks and Ambiguities
- Static-data destination convention (external/ vs dedicated resource path) — for /speckit-clarify.
- taxa2proc_{a2a,agora}_out.txt: regenerated output vs input fixture — for /speckit-clarify; no deletion until resolved.
- initCobraToolbox coverage of external/ on the MATLAB path — verify early in implementation; loaders hardened regardless.
- entropicFluxBalanceAnalysis active development is in feature 014 scope, not here.
