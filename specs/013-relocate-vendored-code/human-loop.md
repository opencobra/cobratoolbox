# Human Loop State

## Current State
- Status: Bundle 3 implemented (P1+P2+P3a; T019 tutorial and 3b data deferred); awaiting Gate 3 closeout
- Active feature directory: specs/013-relocate-vendored-code
- Last completed bundle: Bundle 3 (approved implementation) — commits 3280fc7d0 (P1), e4e425373 (P2), 26c6bf664 (P3a)
- Source code modified by this workflow: yes (wrappers re-anchored on CBTDIR; vendored assets relocated)

## Core Command Ledger
- constitution:   checked (v1.3.0 present; implementation gated on explicit /speckit-implement)
- specify:        invoked (spec.md written, requirements.md checklist all-pass)
- clarify:        invoked (Session 2026-07-17, 3 answers encoded)
- checklist:      invoked (relocation-safety.md, 27 requirement-quality items)
- plan:           invoked (research.md D1-D9, data-model.md manifest, quickstart.md, plan.md; PASS with 1 tracked item)
- tasks:          invoked (tasks.md, 27 tasks, 6 phases, MVP=US1)
- analyze:        invoked (100% coverage; 0 CRITICAL, 1 HIGH governance gate, 2 MEDIUM, 2 LOW)
- implement:      invoked (/speckit-implement) — P1+P2+P3a delivered; T019+3b deferred

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
- Implementation receipt: specs/013-relocate-vendored-code/agent-runs/20260717T071421Z-relocate-vendored-code/implementation-receipt.md (+ baseline.md)
- Implementation review: specs/013-relocate-vendored-code/implementation-review.md (Bundle 2)

## Open Risks and Ambiguities
- DEFERRED T019: tutorial_eFBA.mlx -> tutorials/ blocked (tutorials/ is a git submodule; needs a submodule commit + pointer bump). Tutorial left in src/.
- DEFERRED 3b: static data -> data/ needs a companion /speckit-constitution amendment adding the data/ role (not yet in IX v1.3.0).
- Deviation: demo.json was a live testSammi fixture (not dead) -> moved to the test dir + testSammi.m updated (user-approved), not deprecated/.
- Companion edit: checkGAMSSolvers.m fixed alongside getAvailableGAMSSolvers.m (both resolve licememo.gms).
- Working-tree noise (not 013): externally-installed agent-assign extension modified constitution.md/AGENTS.md/CLAUDE.md/extensions and added agent-assign skills — excluded from all 013 commits.
- taxa2proc_{a2a,agora}_out.txt: out of scope (left in place).
