# Human Loop State

## Current State
- Status: Bundle 1 complete; awaiting Gate 1 decision
- Active feature directory: specs/001-ci-coverage-gating
- Last completed bundle: Bundle 1 (requirements preparation)
- Source code modified by this workflow: no

## Core Command Ledger
- constitution:   checked (read .specify/memory/constitution.md v1.2.0; not regenerated)
- specify:        invoked (spec.md + checklists/requirements.md written; validation passed)
- clarify:        invoked (3 questions asked+answered; Clarifications session 2026-07-13 added)
- checklist:      invoked (checklists/ci-coverage.md, 29 requirements-quality items)
- plan:           n/a (Bundle 2)
- tasks:          n/a (Bundle 2)
- analyze:        n/a (Bundle 2)
- implement:      n/a (Bundle 3, gated)

## Clarify outcomes (Session 2026-07-13)
- Coverage destination: self-contained artifact ALWAYS + Codecov best-effort (never blocks build)
- Backfill scope: ALL currently-ungated tests (complete backfill, not phased) — large scope
- Skip-gate policy: flag/warn + recorded baseline (no hard-fail on rollout; hardening deferred)

## Human Decisions
| Date (UTC) | Gate | Option chosen | Consequence |
|---|---|---|---|
| (pending) | Gate 1 | — | — |

## Approved Implementation Scope
- Approved: no
- Scope: (undecided)
- Tasks approved: —
- Tasks deferred: —
- Files allowed: —
- Files not allowed: src/ scientific code, model schema, solver dispatch (no behaviour change)

## Pointers
- Implementation receipt(s): (none yet; will live under specs/001-ci-coverage-gating/agent-runs/<UTC>-<name>/implementation-receipt.md per constitution)
- Implementation review: specs/001-ci-coverage-gating/implementation-review.md (Bundle 2)

## Deferred hooks (this workflow's commit policy)
- Per-phase git-commit hooks (auto_execute_hooks: true) are DEFERRED to one commit per bundle
  to reduce prompt noise. Bundle 1 will commit spec + clarify + checklist together before Gate 1.
- speckit.agent-context.update (after_specify/after_plan): deferred; agent context points at
  plan.md once Bundle 2 produces it.

## Open Risks and Ambiguities
- Coverage destination (Codecov vs. self-contained artifact) — external service/secret
  dependency; to be resolved in clarify.
- First prepareTest backfill slice size — scope driver; to be resolved in clarify.
- Skip-count gate policy (flag vs. hard-fail on rollout) — CI stability; to be resolved in clarify.
