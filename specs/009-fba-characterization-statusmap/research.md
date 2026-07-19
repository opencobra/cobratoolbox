# Phase 0 Research: LP/FBA characterization net + mapSolverStatus

All four research questions resolved. No `NEEDS CLARIFICATION` remains. Evidence is
grounded in the current source (line numbers below).

## R1 — Status-map inventory + config-surface audit (Principle IV)

**Decision:** `mapSolverStatus` MUST be keyed on **(solver, problemType, origStat)** because
the native→canonical `.stat` translation genuinely differs by solver AND problem type, and is
duplicated within files. It must reproduce each existing site EXACTLY, including latent quirks.

**Inventory (native origStat → canonical `.stat`; canonical: 1 optimal, 0 infeasible,
2 unbounded, 3 feasible/numerical, -1 other):**

- **solveCobraLP.m**
  - `dqqStatMap` cell array **duplicated at :419 and :555** (maps `sol.inform` → `{origStatText, stat}`); consumed at :435–436 and :571–572.
  - `lp_solve` inline (:661–668): 0→1, 3→2, 2→0, else −1.
  - `glpk` returns `stat` from `solveGlpk` directly (:610); `mosek` already factored to `mosek/parseMskResult.m` (:762); gurobi handled in its own block (elsewhere in file — the CI-relevant path).
  - `lindo` map is commented-out dead code (:620–642) — leave as-is (W17 out of scope).
- **solveCobraQP.m** — a cplex-family if-block **duplicated 3×** (:218–227, :268–277, :325–334): 1→1, 3→0, 2||4→2, 5||6→3, else −1; plus a qpng block (:375–381).
- **solveCobraMILP.m** — cplex MILP codes (different surface: 101/102→optimal, 103→infeasible, 118/119→unbounded, 106/108/110/112/114/117→other) repeated at :209–215, :302–311, :469–475; glpk (:149–162); gurobi (`resultgurobi.status`, :274–280).
- **solveCobraMIQP.m** — cplex MIQP (:127–136, :305–314), gurobi (:203–212, :268–282).

**Config-surface audit:** the "configuration surface" here is each solver's **status-code set**
per problem type (gurobi status strings/ints; cplex LP vs MILP code families; dqq `inform`;
tomlab `Inform`; glpk; lp_solve; mosek via `parseMskResult`). The representative instance for CI
is **gurobi** (LP/QP/MILP/MIQP); other solvers are audited from their code blocks and covered by
tests only where the solver is installed.

**Latent quirk to PRESERVE (not fix):** `stat == 106 || stat == 106` (106 repeated) appears in
MILP:215/311/475 and MIQP:314 — a probable typo (a second code was intended). Characterization
mode pins current behavior, so `mapSolverStatus` reproduces it verbatim. Recorded as a follow-up
defect (see Alternatives), NOT fixed in 009.

**Rationale:** exact reproduction is the whole point of a behavior-preserving refactor guarded by
the Part-1 net. **Alternatives considered:** (a) "clean up" the maps while consolidating —
rejected, that changes behavior and is W17/bug-fix territory needing its own spec; (b) a single
flat solver→stat map ignoring problemType — rejected, cplex LP and MILP codes collide (e.g. `3`
means infeasible for LP-cplex but is unused for MILP-cplex which uses 103), so problemType keying
is mandatory.

## R2 — Fixture strategy (portable status matrix)

**Decision:** tiny purpose-built models constructed in the test (a few reactions), not
genome-scale, so infeasible/unbounded/QP states are reproducible and fast (default/fast-mode
friendly):
- **Optimal:** a small feasible toy model with a clear objective.
- **Infeasible:** impose contradictory bounds (e.g. force a reaction flux outside a mass-balance-
  feasible range) → canonical `.stat == 0`.
- **Unbounded:** an objective reaction with no bounding constraint → `.stat == 2`.
- **Numerical (`.stat == 3`):** hard to trigger portably; characterize ONLY where reproducible on
  the available solver, otherwise omit (documented) — do not force a brittle case.
- **QP:** add an L2 `minNorm` on the toy model → QP path; `prepareTest('needsQP', true)`.

**Rationale:** portable across solvers, CI-fast, and the canonical `.stat` (not solver-native
codes) is the stable assertion. **Alternatives:** reuse a shipped model (e.g. `ecoli_core`) —
usable for the optimal case but heavier and doesn't cleanly give infeasible/unbounded; prefer
purpose-built for the status matrix, optionally add one shipped-model smoke case.

## R3 — Reference-value capture

**Decision:** capture references by running the CURRENT code on the fixtures **under MATLAB via
the MATLAB MCP** (`run_matlab_file`/`evaluate_matlab_code`) during implementation, recording
`.stat` (exact integer), `.f`/objective and mass-balance residual and duals `.w`/`.y` (assert
within justified `tol`, e.g. `1e-6`), with `rng` fixed and solver params pinned via
`changeCobraSolverParams`. Values are embedded as literals/`ref_*.mat` beside the test.

**Rationale:** "pin existing behavior" requires observing it on the CI-available solver (gurobi);
tolerances absorb solver/platform noise while integer `.stat` is pinned exactly.
**Alternatives:** hand-derive expected values — rejected, error-prone and not "characterization".

## R4 — mapSolverStatus signature, placement, rerouting

**Decision:**
- **Placement:** new subfolder `src/base/solvers/statusMapping/mapSolverStatus.m` (Principle IX
  new-subfolder rule).
- **Signature:** `function [stat, origStatText] = mapSolverStatus(solver, problemType, origStat)`
  with the openCOBRA help header (`USAGE`/`INPUTS`/`OUTPUTS`/`Author`), camelCase, `if singleCond`
  style. `solver` ∈ changeCobraSolver names; `problemType` ∈ {'LP','QP','MILP','MIQP'}; `origStat`
  the solver-native code. Returns canonical `stat` and (where the current site produces it, e.g.
  dqq) the `origStatText`.
- **Rerouting:** replace each inline map / duplicated block with a call to `mapSolverStatus`,
  leaving surrounding assignment of `solution.origStat`/`.stat` and the existing post-solve
  `.origStat` mutation (`solveCobraLP.m:1616`) UNCHANGED (W16 out of scope). The internal map
  tables live once inside the helper, keyed by (solver, problemType).
- **origStat preservation:** the helper does not alter `.origStat`; callers still assign the
  native value to `solution.origStat` exactly as today.

**Rationale:** one canonical home for the maps, minimal call-site change, no interface/field
change (Principle II). **Alternatives:** per-solver adapter files (the fuller W2/W3 vision) —
deferred; 009 does the single-helper consolidation only.

## Out-of-scope discoveries (recorded, not actioned)

- The `106 || 106` typo (R1) — candidate follow-up defect fix (own spec).
- The commented-out lindo block and deprecated timing APIs (W17) — untouched.
- `.origStat` post-solve mutation with warning strings (W16) — untouched.
