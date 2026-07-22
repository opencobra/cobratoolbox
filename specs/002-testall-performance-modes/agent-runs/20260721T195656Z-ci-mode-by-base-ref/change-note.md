# Change note: CI mode now keyed on PR base branch (fast on develop, full on master)

**Date:** 2026-07-21
**Type:** post-implementation contract amendment, applied via
`DIRECT IMPLEMENTATION OVERRIDE` (Spec Kit workflow bypassed — this is NOT a
sanctioned `/speckit-implement` run, so it is recorded as a change note rather than
an implementation receipt).
**Carried by:** PR opencobra/cobratoolbox#2681, commit `f6d0794fb`
("Run CI in fast mode on develop PRs, full on master PRs"), branch
`fix-ci-coverage-matlab-cov-image`.

## What changed

Feature 002 originally specified that **CI always runs full mode** so the
`001-ci-coverage-gating` coverage/skip gate keeps its thorough baseline. In
practice `getCobraTestMode` enforced this by resolving `COBRA_CI == '1'` to `full`
at the **highest** precedence, ignoring any `CBT_TEST_MODE` / `COBRA_TEST_MODE`.

That is now relaxed: **CI runs fast by default; only pull requests targeting
`master` run full.** Rationale — fast mode gives quicker feedback on the common
develop-PR path while the thorough full-suite coverage baseline is preserved
exactly where it matters most (merges to `master`). Fast mode is designed to
preserve essentially the same coverage (FR-002 / SC-002 bound the drop at 5
percentage points), so develop-PR coverage remains meaningful.

## Spec items superseded (see spec.md)

- **Clarifications** (Session 2026-07-13): "CI runs **full** mode ... local/
  interactive runs default to **fast**." → CI now runs **fast** by default; **full**
  only for PRs whose base branch is `master`.
- **Edge Cases → "CI + coverage gate interaction"**: "CI therefore runs **full**
  mode ..." → superseded as above.
- **FR-012**: "In the CI environment the suite MUST run in full mode (regardless of
  the local default)." → superseded: CI runs full **only for `master`-targeted PRs**;
  otherwise fast. The coverage/skip gate baseline is retained for `master`.

A dated amendment entry pointing here was added to the spec.md Clarifications
section so the change is discoverable from the spec.

## Resolution order after this change (getCobraTestMode.m)

Highest precedence first:
1. global `CBT_TEST_MODE` (fast/full) — honoured even under CI;
2. env `COBRA_TEST_MODE` (fast/full) — honoured even under CI;
3. `COBRA_CI == '1'` → `full` **as a default** when neither 1 nor 2 is set;
4. otherwise `fast`.

The workflow (`testAllCI_step1.yml`) derives `COBRA_TEST_MODE` from
`${{ github.base_ref }}` (`master` → `full`, else `fast`; manual/dispatch with
empty base_ref → `fast`) and passes it as `-e COBRA_TEST_MODE`. `COBRA_CI=1`
stays set, so coverage generation and the JUnit/CTRF report are unaffected.

## Files changed

- `src/base/install/getCobraTestMode.m` — precedence reorder + help/NOTE update.
- `test/verifiedTests/base/testInstall/testGetCobraTestMode.m` — §4 rewritten:
  CI defaults to full with nothing explicit; an explicit env/global `fast`
  overrides it.
- `.github/workflows/testAllCI_step1.yml` — compute mode from `github.base_ref`,
  pass `-e COBRA_TEST_MODE`.

## Validation

- `testGetCobraTestMode` passes (1 passed / 0 failed) in MATLAB against the new
  precedence.
- Not yet exercised end-to-end in CI: confirmation that a develop PR actually runs
  fast (and a master PR full) comes only from the first real CI run on this branch,
  which is also gated by the sibling coverage fix in the same PR (matlab-cov image).

## Consistency note for a future Spec Kit pass

FR-012 and the two spec references above should be reconciled into the spec body
(not just annotated) if/when feature 002 is next revised through the normal Spec
Kit flow. The 5pp coverage-drop tolerance (FR-002 / SC-002) becomes operationally
live on develop PRs now that they run fast — worth confirming against the first
real coverage numbers once the matlab-cov coverage fix produces them.
