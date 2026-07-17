# Human Loop State

## Current State
- Status: Gate 2 approved (scope: P1+P2+3a, data sub-slice deferred); awaiting explicit /speckit-implement to begin Bundle 3
- Active feature directory: specs/013-relocate-vendored-code
- Last completed bundle: Bundle 2 (implementation preparation), committed 9e060f115
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
| 2026-07-17 | Gate 2 | Approve P1+P2+3a; defer data sub-slice | Authorize T001-T019 + T024-T027 on explicit /speckit-implement; T020-T023 (data/ + constitution amendment) deferred to a follow-up |

## Approved Implementation Scope
- Approved: yes (Gate 2, 2026-07-17) — pending the explicit /speckit-implement invocation before any edit
- Scope: slice — P1 (SAMMI) + P2 (Perl+GAMS) + P3 sub-slice 3a (orphans/generated/tutorial)
- Tasks approved: T001–T019, T024–T027
- Tasks deferred: T020–T023 (gated static-data sub-slice + the companion data/ constitution amendment)
- Files allowed (edit): src/visualization/SAMMIM/sammi.m; src/dataIntegration/fluxomics/c13solver/generateIsotopomerSolver.m; src/design/optForceGAMS/{optForceWithGAMS,findMustLWithGAMS,findMustLLWithGAMS,findMustUWithGAMS,findMustULWithGAMS,findMustUUWithGAMS}.m; src/base/solvers/gams/getAvailableGAMSSolvers.m; .gitignore; analysis/WEAKNESSES.md; analysis/ARCHITECTURE.md
- Files allowed (move/delete per manifest): SAMMI JS/CSS/HTML -> external/; c13solver/*.pl -> external/; optForceGAMS/*.gms + licememo.gms -> external/; orphans -> deprecated/; tutorial_eFBA.mlx -> tutorials/; delete wang/cache/*.mat + generated SAMMI HTML
- Files NOT allowed: .specify/memory/constitution.md; NIST .txt + .xlsx data files and their loaders (parse_Atomic_Weights...m etc.); taxa2proc_*.txt; anything not in the data-model manifest

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
