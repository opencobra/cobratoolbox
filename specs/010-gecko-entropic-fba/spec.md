# Feature Specification: Optional GECKO / enzyme-constrained model support in entropicFluxBalanceAnalysis

**Feature Branch**: `010-gecko-entropic-fba`

**Created**: 2026-07-15

**Status**: Draft

**Input**: User description: "Extend `entropicFluxBalanceAnalysis` so it optionally accepts the
extra column-variable fields (`model.E`, `model.evarlb`, `model.evarub`, `model.evarc`, `model.D`)
already understood by `buildOptProblemFromModel`, so enzyme-constrained (GECKO/ecModel) models can
be solved by entropic FBA. Absent fields → byte-for-byte current behaviour; present fields → fold
`[S E; C D]` and evar bounds/objective into the entropic problem. Harvest and consolidate the
existing `AdaptGECKO*` fork (outside the repo) back into the single main function rather than
shipping a parallel one. Must work under `param.solver = 'mosek'` and `'pdco'`. Characterize
current behaviour first (regression-safety), then add a GECKO test."

<!--
  CHARACTERIZATION MODE (partial): Part 3 back-fills a characterization test that pins the CURRENT
  (non-GECKO) behaviour of entropicFluxBalanceAnalysis (Constitution Principle III), so the additive
  GECKO change is provably regression-free. Parts 1–2 are additive new capability. See the "Existing
  Contract" section for the current behaviour Part 3 pins.
-->

## Clarifications

### Session 2026-07-15

- Q: CQ1 — When `E`/`D` are present, auto-relax the stoichiometric/flux-consistency check or gate it behind a param? → A: **Auto-relax, scoped to enzyme reactions.** Presence of `E`/`D` is the activation signal; the consistency check is automatically skipped ONLY for the enzyme-as-substrate reactions (not a blanket skip), matching the AdaptGECKO reference. No new param.
- Q: CQ2 — Do the entropy weights (`g`/`f`) apply to the enzyme-usage (`E`/evar) variables? → A (REVISED 2026-07-16, supersedes the initial answer): **Linear-only by DEFAULT; entropy is an OPTION, not the default.** There is currently no scientific justification for maximising the entropy of the `E`/`D` (enzyme-usage) variables, so the enzyme columns are treated as **linear** additional variables by default (`EPproblem.d = 0` for them). An entropy term on the enzyme columns is available **opt-in** via `param.enzymeEntropyWeight > 0` (experimental — the enzyme-dual correctness of the entropy path is not yet validated against a well-conditioned reference model; the entropic interior-point methods are ill-conditioned on tiny fixtures). *(Initial answer was "apply entropy to enzyme variables too"; revised because the maximisation lacks a scientific basis as a default.)*
- Q: CQ3 — Test-fixture strategy? → A: **Minimal committed fixture in CI; liver-GECKO full-mode-only** (cf. feature 006). A tiny committed enzyme-constrained model runs in routine CI; heavyweight liver-GECKO runs (external `.yml`) are gated to full test mode.

## User Scenarios & Testing *(mandatory)*

The users are COBRA modellers running enzyme-constrained (GECKO/ecModel) analyses — specifically the
Recon4IMD liver-GECKO kinetics work — plus every existing user of `entropicFluxBalanceAnalysis` whose
current results must not move. Value: GECKO models become solvable through the standard entropic-FBA
code path (today they can't), while ordinary models are untouched, and a divergent external fork is
retired into the maintained function.

### User Story 1 - GECKO / enzyme-constrained models solve through entropic FBA (Priority: P1)

A modeller with an enzyme-constrained model carrying `E`/`evarlb`/`evarub`/`evarc`/`D` calls
`entropicFluxBalanceAnalysis`. The function detects the optional fields, folds the `[S E; C D]` block
and the evar bounds/objective into the entropic problem handed to `solveCobraEP`, and returns a
feasible solution with flux **and** enzyme-usage values (and their duals) — where today it silently
ignores those fields and cannot represent the model.

**Why this priority**: This is the feature — it unblocks the Recon4IMD liver-GECKO kinetics work and
brings enzyme-constrained models onto the standard entropic-FBA path.

**Independent Test**: Run a small committed enzyme-constrained fixture through
`entropicFluxBalanceAnalysis`; confirm it returns an optimal/feasible solution whose flux and
enzyme-usage variables satisfy the `[S E; C D]` constraints and the evar bounds, within tolerance.

**Acceptance Scenarios**:

1. **Given** a model with valid `E`/`evar*`/`D`, **When** `entropicFluxBalanceAnalysis` is run,
   **Then** the returned solution contains flux and enzyme-usage variables satisfying `[S E; C D]`
   and the evar bounds, with canonical `.stat` set and `.origStat` preserved.
2. **Given** the same model, **When** the solution is inspected, **Then** the dual/objective fields
   reflect the evar objective (`evarc`) contribution, not just the flux objective.
3. **Given** a model whose `E`/`D` dimensions are inconsistent with `S`/`C`, **When** run, **Then**
   the function raises a clear error (with `ME.stack`) rather than silently mis-assembling the problem.

---

### User Story 2 - Default (non-GECKO) behaviour is byte-for-byte unchanged (Priority: P1)

A user with an ordinary model (no `E`/`evar*`/`D`) gets exactly today's numerical results — the
optional GECKO path is unreachable unless the fields are present. A characterization test, written
BEFORE the additive change, pins the current behaviour so any regression is caught.

**Why this priority**: The additive guardrail is as critical as the new capability — this function is
a core solver on which existing analyses depend (Principle II). No silent result drift is tolerable.

**Independent Test**: Run the characterization suite on representative non-GECKO models before and
after the change; confirm identical `.stat`, objective, flux, and dual values within tolerance.

**Acceptance Scenarios**:

1. **Given** a model without `E`/`evar*`/`D`, **When** `entropicFluxBalanceAnalysis` is run after the
   change, **Then** the solution equals the pre-change solution within tolerance (status exact).
2. **Given** the characterization suite, **When** a deliberate perturbation is introduced to the
   non-GECKO path, **Then** the suite fails (proving it pins behaviour).
3. **Given** the public interface, **When** compared before/after, **Then** argument order, field
   names/meanings, and default outputs are unchanged (Principle II).

---

### User Story 3 - The optional path works under both supported backends (Priority: P2)

The GECKO path runs under both `param.solver = 'mosek'` and `param.solver = 'pdco'`. Where the two
backends genuinely differ in what they can represent (e.g. cone rows / added-variable handling), the
difference is **documented** in the spec/plan rather than silently degraded.

**Why this priority**: Solver-abstraction integrity (Principle IV) and cross-surface fidelity
(Principle VIII spirit) — the community runs both backends; the capability must not be mosek-only by
accident, and any real limitation must be explicit.

**Independent Test**: Run the GECKO fixture under mosek and under pdco; confirm each returns a
feasible solution (or a documented, explicit limitation), with canonical `.stat`/`.origStat`.

**Acceptance Scenarios**:

1. **Given** the GECKO fixture, **When** run with `param.solver='mosek'` and with `'pdco'`, **Then**
   both return feasible solutions consistent within tolerance, OR any difference is documented.
2. **Given** a Phase-0 backend audit, **When** reviewed, **Then** it records how each backend handles
   the added variables/cone rows and any representational limits (Principle IV audit).

### Edge Cases

- **Fields absent**: no `E`/`evar*`/`D` → the function takes exactly today's code path (US2).
- **Partial fields**: some but not all of `E`/`evarlb`/`evarub`/`evarc`/`D` present → clear error or a
  documented completion rule (not silent mis-assembly).
- **Dimension mismatch**: `E` columns vs `evar*` length, `E` rows vs `S` rows, `D` vs `C`/evar → error
  with `ME.stack`.
- **Consistency-check interaction**: enzyme-as-substrate reactions may fail the stoichiometric/flux-
  consistency check; resolved (CQ1) — auto-relax the check scoped to those reactions when `E`/`D` are
  present, keeping it strict for all others.
- **Entropy weights**: resolved (CQ2) — `g`/`f` DO cover the `E`/evar columns (enzyme variables get an
  entropy term); the formulation and the problem handed to `solveCobraEP` must reflect this.
- **Backend divergence**: mosek vs pdco representational differences (US3) must be explicit.
- **Heavyweight fixture**: a real liver-GECKO model is large; any full run must be gated to full test
  mode (CQ3), not routine CI.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `entropicFluxBalanceAnalysis` MUST detect the optional column-variable fields (`model.E`,
  `model.evarlb`, `model.evarub`, `model.evarc`, `model.D`) via existence/emptiness checks (not
  `nargin`).
- **FR-002**: When those fields are ABSENT, the function MUST behave byte-for-byte as today (same code
  path, same numerical results, same outputs).
- **FR-003**: When present, the function MUST fold the `[S E; C D]` block and the evar bounds
  (`evarlb`/`evarub`) and objective (`evarc`) into the entropic problem handed to `solveCobraEP`, so
  the returned solution includes enzyme-usage variables and their duals. The enzyme-usage columns are
  treated as LINEAR additional variables by default (no entropy term — CQ2 revised: no scientific
  basis for maximising their entropy); an entropy term on them is available opt-in via
  `param.enzymeEntropyWeight > 0` (experimental, not the default).
- **FR-003a**: When `E`/`D` are present, the stoichiometric/flux-consistency check MUST be
  auto-relaxed scoped to the enzyme-as-substrate reactions only (driven by field presence, not a new
  param), leaving the check intact for all other reactions (CQ1).
- **FR-004**: The function MUST verify the dimensions of `E`/`evar*`/`D` against `S`/`C` and raise a
  clear error (including `ME.stack`) on mismatch or inconsistent partial specification.
- **FR-005**: The function MUST define how the enzyme-usage variables interact with the internal/
  external split (`SConsistentRxnBool`) and the existing `C*v <=> d` coupling handling.
- **FR-006**: The optional path MUST work under `param.solver = 'mosek'` AND `param.solver = 'pdco'`;
  any representational difference between backends MUST be documented, not silently degraded.
- **FR-007**: All solver-facing assembly MUST route through the existing
  `solveCobraEP`/`buildOptProblemFromModel` abstraction, stay compatible with `changeCobraSolver`, and
  set canonical `.stat` while preserving `.origStat` (Principle IV).
- **FR-008**: The public interface MUST NOT change: argument order, existing model field
  names/meanings, and default (no-`E`) outputs are unchanged (Principle II).
- **FR-009**: The reference `AdaptGECKO*` behaviour MUST be **consolidated into the single
  `entropicFluxBalanceAnalysis`** (behind optional-field detection); the plan decides which logic goes
  in the main function vs. a small shared pre-split helper (analogous to `gecko2CobraSplit`). No
  parallel/forked function ships.
- **FR-010**: A characterization test MUST pin the CURRENT (non-GECKO) behaviour of
  `entropicFluxBalanceAnalysis` (status, objective, flux, duals within tolerance), written before the
  additive change (Principle III), and run in `test/testAll.m`/CI, `prepareTest`-gated.
- **FR-011**: A new test MUST exercise a GECKO model through the optional path on a **minimal committed
  fixture**; any heavyweight liver-GECKO run MUST be gated to full test mode only (CQ3).
- **FR-012**: New source MUST live under `src/base/solvers/entropicFBA/`, tests under
  `test/verifiedTests/<category>/` (Principle IX); all new/changed MATLAB MUST meet Principle VII
  (no `evalc` suppression, warnings visible, `try/catch` propagates `ME.stack`, `exist`/`isempty` over
  `nargin`, openCOBRA help header).

### Key Entities *(the objects this feature touches)*

- **Optional model fields**: `E` (additional-variable matrix), `evarlb`/`evarub` (evar bounds),
  `evarc` (evar objective), `D` (matrix coupling the C-form constraints to the E variables) — already
  understood by `buildOptProblemFromModel`.
- **Target function**: `src/base/solvers/entropicFBA/entropicFluxBalanceAnalysis.m` (edited additively).
- **Downstream**: `solveCobraEP` (the entropic solver the assembled problem is handed to) and
  `buildOptProblemFromModel` (the `[S E; C D]`/evar-aware assembler).
- **Reference fork (to consolidate, then retire)**: `AdaptGECKOentropicFluxBalanceAnalysis.m`,
  `gecko2CobraSplit.m`, `AdaptGECKOsolveCobraEP.m`, `AdaptGECKOprocessFluxConstraints.m`,
  `protocol_*_entropicFBA.m` under the external Recon4IMD kinetics code tree.
- **Fixtures**: a minimal committed enzyme-constrained model; an optional full-mode liver-GECKO model
  (external `.yml`).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A committed enzyme-constrained fixture that today cannot be represented is solved by
  `entropicFluxBalanceAnalysis`, returning a feasible solution whose flux+enzyme variables satisfy
  `[S E; C D]` and the evar bounds within tolerance.
- **SC-002**: For representative non-GECKO models, `.stat` is identical and objective/flux/dual values
  match pre-change within tolerance (regression-free); a deliberate perturbation makes the
  characterization suite fail.
- **SC-003**: The GECKO fixture solves under BOTH `mosek` and `pdco` (or any difference is explicitly
  documented), with canonical `.stat`/`.origStat`.
- **SC-004**: Exactly one `entropicFluxBalanceAnalysis` exists (the `AdaptGECKO*` divergence is
  consolidated, not duplicated); no parallel function is added to `src/`.
- **SC-005**: No public-interface or existing-model-field change (verified by diff and by existing
  entropic-FBA tests still passing); new files placed under `entropicFBA/` and `verifiedTests/`.
- **SC-006**: Heavyweight liver-GECKO runs do not slow routine CI (gated to full mode), while the
  minimal fixture runs in CI.

## Existing Contract *(characterization mode — CURRENT non-GECKO behaviour Part 3 pins)*

<!-- To be completed precisely in planning by reading the 94 KB function; the shape below is the
     contract the characterization test must pin. -->

- **Function under test**: `entropicFluxBalanceAnalysis(model, param)` (exact signature to be
  transcribed in planning).
- **Current inputs**: a COBRA `model` (`S`, `lb`, `ub`, `c`, `b`, `csense`, optional `C`/`d` coupling,
  `SConsistentRxnBool`) and a `param` struct (including `param.solver ∈ {'mosek','pdco'}` and entropy
  weights `g`/`f`); `E`/`evar*`/`D` are **currently ignored**.
- **Current behaviour**: splits `S` into internal `N` / external `B` via `SConsistentRxnBool`, handles
  `C*v <=> d` coupling, assembles the entropic problem, hands it to `solveCobraEP`, and returns a
  solution with flux, duals, objective, and canonical `.stat`/`.origStat`.
- **Invariants to pin** (within justified tolerance, fixed seed where stochastic): `.stat`,
  objective, the flux vector, and dual quantities on a small feasible model, under each backend that
  is available.
- **Coverage gap**: `E`/`evar*`/`D` silently ignored; no direct characterization test pins the current
  entropic-FBA outputs (the regression baseline this feature needs).

## Assumptions

- Consumers are COBRA modellers (notably Recon4IMD liver-GECKO); no external end-user surface.
- The `E`/`evar*`/`D` field semantics match those `buildOptProblemFromModel` already implements for the
  LP/QP path (the single source of truth for these fields); this feature reuses that meaning.
- Reference values for the non-GECKO characterization (US2/FR-010) and the GECKO fixture (US1/FR-011)
  are captured by running the CURRENT / new code under MATLAB with an available backend (mosek/pdco),
  pinned with justified tolerances and fixed seeds.
- The `AdaptGECKO*` fork is the behavioural reference to harvest; where it diverges from the main
  function only to support enzymes, that divergence is folded behind optional-field detection.
- A minimal committed fixture is preferred for CI; the external liver-GECKO `.yml` is optional and
  full-mode-gated (CQ3), so CI stays fast and self-contained.
- The three deferred clarifications (CQ1–CQ3) are resolved in `/speckit-clarify` before `/speckit-plan`.

## Traceability

*(Per FR-001…; filled fully once tests are named in planning. Enzyme fixtures exercise
`src/base/solvers/entropicFBA/`.)*

| Acceptance criterion | Discharging test | src/<domain>/ function under test |
|----------------------|------------------|-----------------------------------|
| US1 / FR-001,003,004,005 — GECKO fold-in | `testEntropicFBAgecko` (new) | `src/base/solvers/entropicFBA/entropicFluxBalanceAnalysis.m` (+ shared split helper) |
| US2 / FR-002,008,010 — non-GECKO unchanged | `testCharacterizeEntropicFBA` (new, characterization) | `src/base/solvers/entropicFBA/entropicFluxBalanceAnalysis.m` |
| US3 / FR-006 — mosek + pdco | `testEntropicFBAgecko` (both backends) + Phase-0 audit | `entropicFluxBalanceAnalysis.m` → `solveCobraEP` |
| FR-007 — solver abstraction, `.stat`/`.origStat` | assertions in both new tests | `solveCobraEP` / `buildOptProblemFromModel` |
| FR-009, SC-004 — single consolidated function | grep: no parallel `AdaptGECKO*` in `src/` | `entropicFluxBalanceAnalysis.m` |
| FR-011, SC-006 — minimal CI fixture, full-mode heavy | fixture under `test/verifiedTests/`; full-mode gate | test fixtures |
