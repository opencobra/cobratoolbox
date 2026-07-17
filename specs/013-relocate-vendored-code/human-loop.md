# Human Loop State

## Current State
- Status: Bundle 2 complete; awaiting Gate 2 decision
- Active feature directory: specs/013-relocate-vendored-code
- Last completed bundle: Bundle 2 (implementation preparation)
- Source code modified by this workflow: no

## Core Command Ledger
- constitution:   checked (v1.3.0 present; implementation gated on explicit /speckit-implement)
- specify:        invoked (spec.md written, requirements.md checklist all-pass)
- clarify:        invoked (Session 2026-07-17, 3 answers encoded)
- checklist:      invoked (relocation-safety.md, 27 requirement-quality items)
- plan:           invoked (research.md D1-D9, data-model.md manifest, quickstart.md, plan.md; PASS with 1 tracked item)
- tasks:          invoked (tasks.md, 27 tasks, 6 phases, MVP=US1)
- analyze:        invoked (100% coverage; 0 CRITICAL, 1 HIGH governance gate, 2 MEDIUM, 2 LOW)
- implement:      n/a (Bundle 3, gated on Gate 2 + explicit /speckit-implement)

## Human Decisions
| Date (UTC) | Gate | Option chosen | Consequence |
|---|---|---|---|
| 2026-07-17 | Pre-spec scoping (AskUserQuestion) | Two features; W9 full cleanup; hybrid layering direction | 013 = W9 relocation (this feature); 014 = base layering inversion (separate, later) |
| 2026-07-17 | Clarify (AskUserQuestion) | Static data -> dedicated resource path; taxa2proc excluded; orphans -> deprecated/ | Encoded into spec.md Clarifications/FRs |
| 2026-07-17 | Gate 1 | Continue to Bundle 2 | Proceed to plan -> tasks -> analyze -> implementation-review; stop at Gate 2 |

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
