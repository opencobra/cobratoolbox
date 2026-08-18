# Phase 0 Research: 011-entropicfba-dual-fixes

Purpose: resolve the technical unknowns before implementation — (a) the mosek dual-optimality
diagnostic audit and the fix/characterize decision rule; (b) the infeasible-EP control-flow map;
(c) confirmation that pdco is already clean and why. All line references are to the current
`develop` (feature 010 merged).

---

## R1 — mosek dual-optimality residual audit (Principle IV configuration-surface audit)

### What the warning checks

`src/base/solvers/entropicFBA/solveCobraEP.m`:

- `optTol = 5e-5` hardcoded (L1066).
- `res2 = grad + Aty + sol.rcost` (L1060); `tmp2 = norm(res2, inf)` (L1061).
- Warning at L1069–1073 fires when `tmp2 > optTol`, guarded only by
  `~(length(A)==1 && strcmp(param.solver,'pdco'))` (L1071).

### How `grad`, `Aty`, `sol.rcost` are formed per backend

**mosek** (optimal branch, L929–970):
- `sol.full = x(1:size(A,2))`, `sol.dual = -y(1:size(A,1))`, `sol.rcost = -z(1:size(A,2)+p)` (L931–933).
- `grad = prob.c - F'*y_K; grad = grad(1:size(A,2)+p)` (L967–968).
- `Aty = -prob.a'*y; Aty = Aty(1:size(A,2)+p)` (L969–970).
- Cone dual `y_K` reconstructed/reordered from `k` at L875–878; `F'*y_K` is the affine-conic
  (exponential + quadratic cone) dual contribution.

Therefore, for mosek,
`res2 = (prob.c - F'*y_K) + (-prob.a'*y) + (-z)`, restricted to the first `size(A,2)+p` entries
`= (prob.c - prob.a'*y - z - F'*y_K)(1:size(A,2)+p)`
which is **exactly** mosek's linearized-cone stationarity `sol.T.tot` computed at L881/886. So the
warning is reporting mosek's own KKT stationarity in the **linearized-cone coordinates**, over the
full augmented variable vector that includes the auxiliary exponential-cone variables (`tf, tr, xf,
xr, yf, yr, mtf, mtr`, named at L775–796).

**pdco** (L447–517): solves the entropy problem directly and checks
`res2 = grad + A'*y + z` with `grad = c + d.*logx (+ Q*x)` (L499–502, L510/516) — i.e. stationarity
in the **original (reduced) entropy coordinates** on the structural variables. This is clean
(residual below `optTol`).

### Leading hypothesis

The mosek residual is evaluated in the **linearized-cone coordinates**, where the entropy is
represented through auxiliary exponential-cone variables whose stationarity rows carry O(1)
contributions (entropy involves `log` of near-zero values, so the associated cone duals are large).
pdco checks the **true reduced-coordinate** KKT condition and is clean. The 1.45 (GECKO) and ~2
(non-enzyme Recon3D) are the **same artifact of the coordinate system**, not an enzyme-specific
defect. This is consistent with: (i) the identical order of magnitude with and without enzymes;
(ii) `grad` already containing `-F'*y_K` (so a naive "missing cone dual" explanation is refuted).

**Intended fix (fix path).** Compute the mosek dual-optimality residual in the structural/original
coordinates matching pdco — i.e. evaluate `c + d.*logx + (A over original constraints)'*sol.dual +
sol.rcost` on the structural (flux + enzyme) variables only, excluding the linearized-cone auxiliary
rows — so the reported residual reflects the true entropy-problem KKT condition and falls to ~0 for
both enzyme and non-enzyme cases. This changes only a **reported diagnostic quantity**, never the
primal, `.stat`, or `.origStat`.

### Alternative causes to rule in/out during the spike

- **A2 — cone-dual convention/scaling.** mosek's exponential-cone dual has an `exp(1)` factor
  (visible at L926). If `y_K` used in `F'*y_K` for the stationarity check needs a different
  scaling/sign than the one used for feasibility, `sol.T.tot` would be non-zero even in cone
  coordinates. Distinguishable from the leading hypothesis by which rows carry the residual.
- **A3 — row misalignment.** `grad`, `Aty`, `sol.rcost` are each truncated to `1:size(A,2)+p`; if
  `p` (coupling `C`/`D` rows) or the enzyme columns shift an index, the summed rows could
  misalign. Enzyme columns enter `A`/`F` via 010's `prepareEnzymeConstrainedEP`; check that
  `size(A,2)+p` bounds the structural+coupling block consistently for the enzyme-augmented problem.
- **A4 — genuinely large KKT residual (characterize outcome).** If, after evaluating stationarity
  in the correct reduced coordinates, the residual is still ≫ `optTol` and a hand-computed KKT check
  agrees, the solution is genuinely only approximately dual-optimal (entropy ill-conditioning). Then
  characterize: document it, and make `testEntropicFBAgecko` assert primal feasibility + KKT + status
  strings and tolerate the residual.

### Decisive experiment (Bundle 3, read-only diagnostics first)

Run under mosek with `param.debug = 1` (and `printLevel > 1`) on:
1. the GECKO feasible toy (`buildEnzymeToy(3, 2)`), and
2. the non-enzyme Recon3D (`testEntropicFluxBalanceAnalysis` model).

Dump `sol.T` (columns `tot, c, Aty, z, Ftdoty, Fty_K`) and identify **which variable rows** carry
the residual (by the `prob.names.var` labels). Compute the reduced-coordinate residual
`c + d.*logx + A'*sol.dual + sol.rcost` on the structural variables and compare.

**Decision rule:**
- If the residual is carried by the **auxiliary cone rows** and the reduced-coordinate residual is
  `< optTol` → leading hypothesis confirmed → **fix** by reporting the reduced-coordinate residual
  (both backends then agree and pass).
- If the residual is carried by **structural/enzyme rows** and scales with the enzyme block →
  investigate A2/A3 (a real enzyme-dual assembly defect) → **fix** the assembly.
- If the reduced-coordinate residual is **also** `≫ optTol` on non-enzyme Recon3D → **characterize**
  (A4): genuine ill-conditioning, document + tolerate, since it predates enzymes and is not a
  regression this feature introduced.

### Config-surface note

No mosek *option* default is being changed (the `setMosekParam` surface, cones, and tolerances are
untouched). The only change under consideration is the **post-solve residual formula**. `optTol =
5e-5` remains the threshold; if the characterize outcome holds, the test tolerates the documented
residual rather than loosening this shared threshold.

---

## R2 — Infeasible-EP control-flow map

Two independent defects lie on the infeasible-enzyme-constrained path:

1. **`solveCobraEP` infeasibility diagnostic (mosek).** On `sol.stat == 0` with `param.solver ==
   'mosek'` (L982–998), the code re-solves the LP relaxation via
   `msklpopt(EPproblem.c, EPproblem.A, EPproblem.blc, EPproblem.buc, EPproblem.lb, EPproblem.ub, …)`
   (L995) to classify the infeasibility, then sets `message` with a proper `otherwise` default
   (L1000–1007) — this block is itself robust. The reported `err_argument_dimension` /
   `prob.names`-sizing failure (see memory `entropicfba-infeasible-message-bug`) must be reproduced
   under the strictly-infeasible enzyme fixture to pin the exact throwing line: candidate is a
   dimension mismatch between the enzyme-augmented `EPproblem.A` and one of the vectors passed to
   `msklpopt`, or a name-array built at the pre-enzyme size. **FR-003** requires sizing any such
   name/vector from the actual problem dimension (`size(prob.a,1)`/`size(prob.a,2)` /
   `size(EPproblem.A)`), not a stale pre-enzyme count.

2. **`entropicFluxBalanceAnalysis` `otherwise` branch (backend-agnostic).** When `solution.stat ~=
   1`, the `otherwise` branch (L1699–1716) re-runs `optimizeCbModel(model,'min',[],1,param)` (L1702)
   and `switch`es on `solution_optimizeCbModel.stat` handling only `case 0` (L1704) and `case 1`
   (L1707); with **no default**, `message` is undefined for any other status (2 unbounded, -1/other),
   so `solution.messages = [...; message]` (L1712) or `cellstr(message)` (L1714) throws
   `Unrecognized function or variable 'message'`. **FR-001** requires `message` to be defined for
   every status — initialise it before the `switch` (a generic "EP infeasible; optimizeCbModel
   returned status N" default) or add an `otherwise` case.

For a GECKO model infeasible only via the enzyme cap: `optimizeCbModel` does not see `E`/`evar`/`D`
so its LP pre-check reports feasible (status 1), the EP is genuinely infeasible, and control reaches
both sites. Fixing (2) alone makes the function return `stat = 0` with a message; fixing (1) removes
the earlier mosek diagnostic crash so the clean status is actually reached.

**Decision:** fix both. (1) is minimal (dimension sizing in the diagnostic). (2) is a one-line
initialisation. The strictly-infeasible fixture (`buildEnzymeToy` with `evarub` such that
`kcat*evarub < 2 = R3 lower bound`) drives both under mosek.

---

## R3 — Why pdco is already clean

The L1071 guard `~(length(A)==1 && strcmp(param.solver,'pdco'))` suppresses the warning only for a
1-row `A` under pdco (a noted small-problem quirk, `%todo, why does pdco choke on small A?`). For
the GECKO toy `A` has 2 rows, so the guard does **not** apply — pdco is clean because it checks
stationarity in the true reduced entropy coordinates (`grad = c + d.*logx`, `res2 = grad + A'*y +
z`, L499–517), which the interior-point method satisfies to tolerance. This is the reference
"correct" residual the mosek fix should reproduce (R1). pdco's cleanliness is therefore evidence for
the leading hypothesis, not a separate path to change.

---

## Consolidated decisions

- **Decision (US1/FR-001)**: initialise `message` before the inner `switch` in the
  `entropicFluxBalanceAnalysis` `otherwise` branch. *Rationale*: defined for all statuses; minimal;
  feasible path untouched. *Alternatives*: add an `otherwise` case (equivalent; initialisation is
  simpler and also covers the two existing cases if their text is later reordered).
- **Decision (US1/FR-003)**: size the mosek infeasibility-diagnostic name/vector arrays from the
  actual (enzyme-augmented) problem dimension. *Rationale*: removes `err_argument_dimension` for
  augmented problems; localised to the diagnostic path. *Alternatives*: skip the diagnostic when
  enzymes present — rejected (loses the LP-vs-EP infeasibility classification).
- **Decision (US2/FR-005)**: replace `solverPkgs.EP{k}` with `solverPkgs.EP{1}` (single required
  solver is mosek). *Rationale*: minimal, runs standalone, preserves assertions. *Alternatives*: a
  `for k = 1:numel(solverPkgs.EP)` loop — heavier; the test body is written for a single solver.
- **Decision (US3/FR-006)**: pursue the fix — report the mosek dual-optimality residual in the
  structural/original coordinates (matching pdco), confirmed by the R1 debug-table experiment;
  characterize-and-tolerate only under the R1 A4 outcome. *Rationale*: user clarification; corrects a
  diagnostic without touching the primal. *Alternatives*: loosen `optTol` — rejected (masks real
  dual failures and changes a shared threshold).
- **Decision (fixture)**: add the strictly-infeasible case to the existing `testEntropicFBAgecko`
  (reusing `buildEnzymeToy`) rather than a new file. *Rationale*: co-located with the feasible/binding
  GECKO cases it complements; one fixture builder. *Alternatives*: dedicated test file — more files,
  no benefit at this scale.

All Technical-Context unknowns resolved; no NEEDS CLARIFICATION remains.
