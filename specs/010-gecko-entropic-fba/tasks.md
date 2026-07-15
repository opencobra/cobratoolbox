# Tasks: Optional GECKO support in entropicFluxBalanceAnalysis

**Input**: Design documents from `specs/010-gecko-entropic-fba/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md (all present)

**Tests**: mandatory (Constitution III). Characterization net FIRST (regression baseline), then the
GECKO path. Run via the MATLAB MCP (`run_matlab_test_file`), `prepareTest`-gated, mosek+pdco.

**Organization**: By user story. **STRICT ORDER: the non-GECKO characterization net (US2) must be
GREEN before the GECKO fold-in (US1) begins.** All edits confined to `src/base/solvers/entropicFBA/**`
and `test/verifiedTests/**`. `fluxes` method only; `fluxConc`/`fluxConcNorm` enzyme support is OUT.

## Format: `[ID] [P?] [Story] Description`

## Path note

Allowed: `src/base/solvers/entropicFBA/entropicFluxBalanceAnalysis.m` (additive) + a NEW
`src/base/solvers/entropicFBA/prepareEnzymeConstrainedEP.m`; tests + fixture under
`test/verifiedTests/`. NOT allowed: any public-interface/field/default-result change; `solveCobraEP`
signature; the AdaptGECKO fork (reference only); `fluxConc`/`fluxConcNorm` enzyme paths.

---

## Phase 1: Setup

- [X] T001 Confirm the scoped change surface (plan Change map): only `entropicFluxBalanceAnalysis.m`
  (additive, behind field detection) + the new `prepareEnzymeConstrainedEP.m` + tests/fixture. No
  default-path or interface change; `fluxes` method only.

## Phase 2: Foundational (Blocking Prerequisites)

- [ ] T002 Build a MINIMAL committed enzyme-constrained fixture (tiny model with `E`/`evarlb`/`evarub`/
  `evarc`/`D` in the `buildOptProblemFromModel` shape) beside its test under `test/verifiedTests/`;
  document its expected feasible solution. (Optionally derive via `gecko2CobraSplit` semantics; commit
  a tiny result, not a heavy model.)
- [X] T003 Reference-capture (research R1/R3): run the CURRENT `entropicFluxBalanceAnalysis` (`fluxes`,
  non-GECKO) on a small model under mosek AND pdco via the MATLAB MCP; record `.stat`/objective/flux/
  duals as pinned references for the characterization test.

## Phase 3: User Story 2 - Non-GECKO characterization net (Priority: P1) 🎯 baseline

- [X] T004 [P] [US2] Write `test/verifiedTests/.../testCharacterizeEntropicFBA/testCharacterizeEntropicFBA.m`:
  pin the current `fluxes` non-GECKO behaviour (`.stat` exact; objective/flux/duals within tol) under
  mosek AND pdco; `prepareTest`-gated; fixed seed; references from T003.
- [X] T005 [US2] Run T004 via MCP; confirm green + perturbation check (quickstart V1); confirm
  `git diff` shows `entropicFluxBalanceAnalysis.m` still unchanged (net written before any src edit).

**Checkpoint — GATE**: characterization net GREEN. US1 MUST NOT begin until this passes.

## Phase 4: User Story 1 - GECKO fold-in (Priority: P1) — gated on T005

- [ ] T006 [US1] Create `src/base/solvers/entropicFBA/prepareEnzymeConstrainedEP.m`: detect + validate
  `E`/`evar*`/`D` dimensions vs `S`/`C` (error with `ME.stack` on mismatch/partial), return the enzyme
  block (columns, bounds, objective, entropy-`d` entries). openCOBRA header, camelCase, no `nargin`.
- [ ] T007 [US1] Edit `entropicFluxBalanceAnalysis.m` (`fluxes`): behind field detection, fold the
  `[S E; C D]` block and append `evarlb/evarub`→`lb/ub`, `evarc`→`c` (mosek + pdco assembly points);
  apply the consistency auto-relax scoped to enzyme reactions (CQ1/FR-003a). **Enzymes LINEAR first**
  (`d=0`) to isolate the fold-in from the reindexing risk. Re-run T004 → non-GECKO unchanged.
- [ ] T008 [US1] Add entropy on enzyme columns (CQ2/FR-003): set enzyme `EPproblem.d>0`; update the
  post-solve unpacking + cone-dual reindexing (`nExpCone`, `Fty_K`, `auxPrimal`/`coneF`/`auxRcost`
  offsets) per backend so enzyme primal+duals extract correctly; keep enzyme columns strictly positive
  (log domain); add enzyme fields to the solution struct. Re-run T004 after → non-GECKO STILL unchanged.
- [ ] T009 [US1] Confirm (git diff + T004 green) the default (no-`E`) path is byte-for-byte preserved
  through both T007 and T008 (FR-002/010).

## Phase 5: User Story 1/3 - GECKO test, both backends

- [ ] T010 [US1] [US3] Write `test/verifiedTests/.../testEntropicFBAgecko/testEntropicFBAgecko.m`: solve
  the minimal fixture through the GECKO path under mosek AND pdco; assert feasibility, `[S E; C D]` +
  `evarlb/evarub` satisfaction, `evarc` objective contribution, entropy on enzyme columns, canonical
  `.stat`/`.origStat`. Run via MCP; document any mosek/pdco difference (research R6), don't degrade.
- [ ] T011 [US1] Dimension-mismatch/partial-field error test (FR-004): assert a clear error with stack.

## Phase 6: Polish & Cross-Cutting Concerns

- [ ] T012 `check_matlab_code` on `entropicFluxBalanceAnalysis.m` (NEW flags only — pre-existing flags
  in the 1795-line function are out of scope) and `prepareEnzymeConstrainedEP.m` (clean).
- [ ] T013 Run `quickstart.md` V1–V6; confirm existing entropic-FBA tests still pass; diff confined to
  `entropicFBA/**` + `test/verifiedTests/**` + `specs/010-...`; `grep -rl AdaptGECKO src/` → nothing.
- [ ] T014 Report files edited, checks run, pass/fail, unverified behaviour.
- [ ] T015 Write the implementation receipt under
  `specs/010-gecko-entropic-fba/agent-runs/<UTC-timestamp>-<short-name>/implementation-receipt.md`.

---

## Dependencies & Execution Order

- **Setup (T001)** → **Foundational (T002–T003)** → **US2 net (T004–T005)**.
- **T005 is a hard gate**: US1 (T006+) MUST NOT start until the non-GECKO net is green.
- **T006** (helper) → **T007** (linear fold-in) → **T008** (entropy + reindex) — strictly sequential;
  T004 re-run after T007 and T008 to catch any default-path regression immediately.
- **US3** backend coverage is inside T010. **Polish (T012–T015)** after the GECKO test.

## Implementation Strategy

- **Baseline first**: US2 characterization net (regression safety) before any src edit.
- **Isolate the risk**: land the linear fold-in (T007) green first, THEN add entropy-on-enzymes +
  reindexing (T008) — so if the cone-dual reindexing goes wrong it's localized to one step.
- Both backends verified in T010; document (don't silently degrade) any real mosek/pdco difference.

## Notes

- MATLAB standards on all new/edited `.m`: openCOBRA header, `exist`/`isempty` not `nargin`, warnings
  visible, `try/catch ME` propagates `ME.stack`, no `evalc` shadowing, camelCase.
- No task changes the public interface, existing outputs, default results, or `solveCobraEP`'s
  signature. No AdaptGECKO fork shipped.
