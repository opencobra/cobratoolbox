# Phase 1 Data Model: 011-entropicfba-dual-fixes

This feature introduces no new persisted data and no new public fields. The "entities" below are the
existing solution-structure quantities the fixes touch; documenting their invariants keeps the
changes auditable against Principles I, II, and IV. No COBRA model field is added or redefined.

## E1 — Solution status & message (existing `solution`/`sol` fields)

- **`solution.stat`** (canonical): `0` = infeasible, `1` = optimal/feasible. **Invariant:** an
  infeasible EP — including one infeasible only via the enzyme cap — MUST yield `stat = 0` (never a
  thrown error). Unchanged for the feasible/optimal path.
- **`solution.origStat`**: solver-native status string (e.g. mosek `MSK_RES_OK` /
  `PRIMAL_INFEASIBLE_CER`). **Invariant:** preserved verbatim (Principle IV); this feature does not
  remap it.
- **`solution.messages`** (cell array of diagnostic strings): accumulates human-readable diagnostic
  text. **Invariant (new):** on any infeasible EP the collection is non-empty and contains an
  informative message for **every** `optimizeCbModel` diagnostic status, not only 0/1. The message
  identifies whether the LP part is feasible (EP-only infeasibility, e.g. enzyme cap) or infeasible.
- **`message`** (local scalar string in the `otherwise` branch): **Invariant (new):** defined on all
  code paths before use (root cause of the current crash is an undefined `message`).

State transition touched (infeasible EP):
```
entropicFluxBalanceAnalysis: solve EP
  └─ solution.stat == 1 → feasible path (UNCHANGED)
  └─ solution.stat ~= 1 → otherwise branch → optimizeCbModel diagnosis
        status 0 → message = "…LP part not feasible…"      (existing)
        status 1 → message = "…EP infeasible, LP feasible…" (existing)
        status other (2/-1/…) → message = generic default   (NEW — was undefined ⇒ crash)
     → solution.messages appended; return solution.stat = 0   (no throw)
```

## E2 — mosek infeasibility diagnostic name/size arrays (internal to `solveCobraEP`)

- **`prob.names.*` / diagnostic vectors** passed to the mosek LP-relaxation diagnostic
  (`msklpopt`, L995) when `sol.stat == 0`. **Invariant (corrected):** sized from the actual
  enzyme-augmented problem dimension (`size(EPproblem.A)` / `size(prob.a)`), so extra enzyme columns
  do not trigger `err_argument_dimension`. Not a public field; internal diagnostic bookkeeping only.

## E3 — Dual/KKT stationarity residual (internal diagnostic quantity in `solveCobraEP`)

- **`res2` / `tmp2`**: the dual-optimality residual compared to `optTol = 5e-5` (L1060–1072).
  - mosek (current): `res2 = (prob.c - prob.a'*y - z - F'*y_K)` over structural+`p` variables =
    linearized-cone stationarity over the full augmented vector (carries O(1) auxiliary-cone rows).
  - pdco (reference, clean): `res2 = c + d.*logx + A'*y + z` over structural variables (true
    reduced-coordinate KKT).
  - **Invariant (target, fix path):** the mosek residual is reported in the same reduced/structural
    coordinates as pdco, so `tmp2 ≤ optTol` for well-solved problems (enzyme and non-enzyme) and the
    warning no longer fires. **This quantity is diagnostic only** — changing how it is *computed*
    MUST NOT change `solution.full`/`v`/`e` (the primal), `solution.obj`, `.stat`, or `.origStat`.
  - **Invariant (regression):** the non-enzyme residual MUST NOT increase relative to the pre-change
    value (baseline ~2 reported on Recon3D; target ≤ optTol after the fix, never worse).

## E4 — Enzyme-constrained toy fixture (test-local, `buildEnzymeToy`)

- Existing local builder in `testEntropicFBAgecko.m`: `A →(R1) [R2 enzyme-catalysed] → B →(R3)`,
  `R3 lb = 2` forces flux; enzyme couples `v_R2 ≤ kcat·e`, `e ∈ [0, eMax]`.
- **New usage:** a **strictly-infeasible** instance with `kcat·eMax < 2` (e.g. `eMax` small at
  `kcat = 2`), so the LP relaxation (no enzyme) is feasible but the EP is infeasible via the enzyme
  cap. **Invariant:** the model is infeasible *because of* the enzyme bound, isolating the P1 path
  (addresses checklist CHK016). Deterministic; no random seed needed.
