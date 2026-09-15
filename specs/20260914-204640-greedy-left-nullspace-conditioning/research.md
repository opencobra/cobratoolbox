# Phase 0 Research: Measurements That Must Precede Any Remedy

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md) | **Date**: 2026-09-14

**Status: MEASURED 2026-09-14** (tasks T004-T011). Environment: `measurements/environment.md`.
Raw drivers: `measurements/run*.m`.

Every "Result" slot below is deliberately empty. They are filled during implementation,
from runs, not from reasoning. The spec forbids inventing the two numbers this document
exists to produce (the accuracy target, FR-002; the regime boundary, FR-006), and the
seed names an agent-chosen threshold as "exactly the failure mode to avoid here".

A finding that contradicts the hypothesis it tests is a **successful** measurement and
must be recorded as such.

---

## R1 — Is the post-solve truncation, not the LP floor, the operative cause?

**Sequenced first.** It can overturn the seed's diagnosis, and its answer selects the
remedy and the Gate-2 scope decision.

### The hypothesis

`findExtremePool.m:36-39` computes

```matlab
if ~exist('epsilon','var')                               % ALWAYS true: epsilon is never an argument
    feasTol = getCobraSolverParams('LP', 'feasTol');     % default 1e-6 (getCobraSolverParams.m:90)
    epsilon = feasTol*10;                                % => 1e-5 by default
end
```

and line 66 then executes

```matlab
x(abs(x)<epsilon)=0;      % zeroes every entry below 1e-5, AFTER the LP solved
```

The perturbed `x` is never re-checked against the LP constraints. Zeroing entries of
magnitude up to `1e-5` against stoichiometric coefficients of O(1)–O(10) injects a
residual into `S'*x` that the LP never sanctioned.

Two pieces of the seed's own evidence corroborate this, and neither was read this way
at the time:

- the seed reports that the entries of `L` "reach 1.252e-05" — i.e. the **smallest
  surviving entries sit just above the 1e-5 truncation floor**, which is the fingerprint
  of a hard threshold, not of a solver tolerance;
- the 8.8e5 within-matrix entry-magnitude ratio the seed classified as "a symptom, not
  the cause" is precisely what O(10) stoichiometry against a 1e-5 floor produces.

If this is right, the seed's stated operative cause — the `1e-6` **acceptance** test at
`greedyExtremeRayBasis.m:126` — is not the cause but a **filter**: it admits exactly
those rays where the truncation damage happened to land below `1e-6`. Tightening that
filter alone would then not improve attainable accuracy; it would reject more rays,
possibly all of them. That is the precise risk the seed flagged as "may not be
achievable", arriving from a different direction than expected.

### Procedure

1. Instrument a local copy of the ray computation so that both vectors are retained:
   `x_raw = sol.full` and `x_trunc = x_raw` with entries below `epsilon` zeroed.
   (During research this is a throwaway probe, not a committed change.)
2. Over at least 200 accepted and rejected rays drawn from at least two models of
   different size, record for each ray: `norm(S'*x_raw, inf)`,
   `norm(S'*x_trunc, inf)`, both scaled by `norm(S)*norm(x)`; the count of entries
   zeroed; and the largest magnitude zeroed.
3. Repeat under at least two LP solvers to separate solver behaviour from the
   truncation, which is solver-independent by construction.
4. Also record `sol.stat` / `sol.origStat` for each ray, so that rays from a
   non-optimal solve are not mistaken for tolerance effects.

### Decision rule, fixed in advance

- If `norm(S'*x_raw)` is **orders of magnitude smaller** than `norm(S'*x_trunc)`:
  truncation is the operative cause, the LP floor is not binding, and Regime A is
  reachable for more models than the seed expected. Proceed to the Gate-2 scope decision
  in `plan.md`.
- If the two are **comparable**: the hypothesis is refuted, the LP floor dominates, and
  R2 becomes the binding constraint. Record the refutation explicitly and prominently —
  it changes the feature's expected outcome toward Regime B.

### Result — **HYPOTHESIS REFUTED**

- Rays sampled: 200 (ecoli_core, iAF1260 x gurobi, mosek) + full greedy accumulation on
  iDopaNeuroC (105-ray basis, both solvers).
- Models: `ecoli_core_model`, `iAF1260`, `iDopaNeuroC` (internal, 1244 x 1710).
- Solvers: gurobi 1302, mosek 11.2 (glpk added for R2).

| iDopaNeuroC | gurobi | mosek |
|---|---|---|
| entries zeroed by the truncation | **0** | 1186 per ray, all dust (largest 1.134e-07) |
| per-ray raw residual, median | 0.000e+00 | 1.192e-12 |
| per-ray truncated residual, median | 0.000e+00 | 3.342e-14 |
| **assembled basis residual, absolute** | **1.185e-16** | 9.342e-09 |
| **assembled, scaled** | **1.707e-19** | 1.302e-11 |
| smallest surviving entry | 1.582e-05 | 2.488e-05 |

**Verdict: the truncation is NOT the operative cause.** Under gurobi it zeroes nothing at
all and the assembled residual is 1.185e-16 — exact. Under mosek it removes only dust and
*improves* the per-ray residual (1.192e-12 -> 3.342e-14). In no configuration measured did
truncation worsen a residual.

**The corroborating observation was real but misread.** The smallest surviving entries do
land at 1.58e-05 / 2.49e-05, closely matching the seed's reported 1.252e-05. But the cause
is the `sum(x) = 1` normalisation applied to rays with large internal dynamic range
(max/min ~ 3e4), not the `epsilon` floor. Their proximity to `epsilon = 1e-5` is a
coincidence of scale. The inference from "smallest entry sits near epsilon" to "epsilon
truncated it" was wrong, and the measurement that settles it is that gurobi truncates
**zero** entries while producing entries of the same magnitude.

### What displaces it

**The residual is dominated by SOLVER CHOICE.** Same model, same code path, same
tolerances: gurobi 1.185e-16, mosek 9.342e-09 — seven orders of magnitude apart. The
seed's measured 1.418e-07 is consistent with a mosek-class solve, not a gurobi one.

**A second, unlisted finding: the greedy search's hit rate is also solver-dependent, and
badly so.** gurobi accepted 101 rays from 22,027 attempts (0.46%) and **timed out at 600 s
without completing the basis**; mosek accepted 105 from 1,096 attempts (9.6%) in 44.6 s.
Under gurobi the routine today returns a 105-row `Zpos` of which only 101 rows are real and
4 are all-zero padding — defect FR-010 demonstrated empirically rather than by inspection.

---

## R2 — What residual floor can the LP actually deliver?

R1 only establishes whether truncation dominates. This establishes the floor beneath it
— the quantity the seed warned may cap the whole enterprise.

### Procedure

1. On **raw, untruncated** solutions only, measure `norm(S'*x_raw, inf)` absolute and
   scaled, across every LP solver installed here.
2. Sweep the solver's own feasibility and optimality tolerances downward and record
   where the achieved residual stops improving — that plateau is the floor.
3. Record it per solver: solvers do not share a floor, and the toolbox must not assume
   one (Principle IV).
4. Record solve time alongside, so the cost of a tighter tolerance is visible.

### Result

Raw (untruncated) residual on iDopaNeuroC, 20 rays per solver:

| Solver | median | max | rays clipped by the +-100 bounds |
|---|---|---|---|
| gurobi | 0.000e+00 | 0.000e+00 | 0 |
| glpk | 4.467e-27 | 1.110e-16 | 0 |
| mosek | 1.695e-12 | 3.064e-10 | 0 |

**There is no single floor: it is a per-solver property, spanning four orders of
magnitude.** gurobi and glpk deliver essentially exact vertices; mosek's interior-point
path delivers ~1e-12 per ray, accumulating to ~9e-09 across an assembled 105-ray basis.

- **Is the floor above or below the R3 target (1.193e-12 absolute)?** **Below it for
  gurobi and glpk** (by ~4 orders), **above it for mosek** (by ~4 orders). So Regime A is
  attainable — with an appropriate solver — and the seed's worry that the LP floor might
  cap the whole enterprise is **not** borne out in general, only for mosek.

---

## R3 — Derivation of the accuracy target (FR-002)

The target must come from what a rank determination needs, not from convenience.

### Procedure

1. State the derivation **symbolically first**. The augmented matrix's rank is
   unambiguous when the singular values that ought to be zero are separated from the
   smallest retained singular value by a margin that survives the tolerance sweep of
   FR-001. Express the largest admissible row residual in terms of: the smallest
   retained singular value of the augmented matrix; the norm of the augmented matrix;
   the width of the tolerance span that must agree (at least three orders of
   magnitude); and machine epsilon.
2. Only then substitute measured quantities from a representative case to obtain a
   number, and state both the symbolic form and the substituted value.
3. Sanity-check the derivation against the seed's measurements: the derived target must
   classify the measured `1.418e-07` (scaled `2.218e-09`) as **failing**, since that
   basis demonstrably destroyed the rank gap, and must classify a `~1e-16` exact basis
   as passing. A derivation that does not reproduce these two known outcomes is wrong.

### Result

**Symbolic derivation.** Let `M` be the augmented matrix a caller forms, `r` its
structural rank, and let a rank determination at relative tolerance `tau` count
`sigma_i > tau*sigma_1`. The rank is the same integer for every `tau` in a span
`[tau_min, tau_max]` iff

```text
(i)   sigma_{r+1}(M) <= tau_min * sigma_1(M)     <- ours to guarantee
(ii)  sigma_r(M)     >  tau_max * sigma_1(M)     <- a property of the caller's problem
```

Write the computed basis as `L = L0 + E`, with `L0*N = 0` exactly. Since the exact
augmented matrix has `sigma_{r+1} = 0`, Weyl's inequality gives
`sigma_{r+1}(M) <= ||E||_2`. The measurable residual is `R = L*N = E*N`, and the only
component of `E` that produces residual is the one in the row space of `N`, amplified by
at least the smallest non-zero singular value, so `||E||_2 <= ||R||_2 / sigma_min+(N)`.
Substituting into (i):

```text
||L*N||_2  <=  tau_min * sigma_1(M) * sigma_min+(N)
```

`tau_min = eps*max(size(M))` — the conventional numerical-rank tolerance and the tightest
any consumer would reasonably apply.

**Substituted for iDopaNeuroC**: `tau_min = 6.5592e-13`, `sigma_1(M) = 6.4077e+01`,
`sigma_min+(N) = 2.8382e-02` (rank 1139 of 1244), `||N||_2 = 6.4070e+01`, `||L||_2 = 1.0`.

```text
TARGET:  ||L*N||_2 <= 1.1929e-12       scaled: <= 1.8619e-14
```

**Reproduces the two known outcomes — yes, both:**

| Basis | scaled residual | vs target 1.862e-14 | Expected | Got |
|---|---|---|---|---|
| the seed's | 2.218e-09 | 1.2e5x too large | FAIL | **FAIL** |
| exact | ~1e-16 | passes | PASS | **PASS** |

**Independent validation by controlled perturbation.** Starting from an exact basis
(`null(N')`, residual 3.397e-14) and perturbing by known amounts, the augmented rank stays
unambiguously 1244 across `tau` in `[1e-9, eps*max(size(M))]` up to `||L*N||_2 = 7.340e-10`
and breaks at `6.942e-09`:

| perturbation | `||L*N||_2` | scaled | ranks (1e-9 .. eps*max) | correct? |
|---|---|---|---|---|
| 0 | 3.397e-14 | 5.301e-16 | 1244 1244 1244 1244 1244 | yes |
| 1e-13 | 6.203e-11 | 9.682e-13 | 1244 1244 1244 1244 1244 | yes |
| 1e-12 | 7.340e-10 | 1.146e-11 | 1244 1244 1244 1244 1244 | yes |
| **1e-11** | **6.942e-09** | 1.083e-10 | 1244 1244 1244 **1349 1349** | **no** |
| 1e-10 | 6.804e-08 | 1.062e-09 | 1244 1244 **1349** 1349 1349 | no |

The derived bound (1.193e-12) is therefore **~600x conservative** against the measured
crossing (~7e-10). That is correct behaviour for a *sufficient* condition: Weyl's
inequality assumes the error aligns adversarially with the singular subspace, which a
random perturbation does not. The derived bound is used as the target because it
*guarantees* the property; the measured crossing is recorded so a reviewer can see the
margin rather than mistake the bound for a tight characterisation.

**A subtlety worth recording, found during validation.** At perturbations of 1e-8 and
above, *every* tolerance agrees — on 1349, the full rank, which is uniformly **wrong**.
"All rank routines agree" is therefore NOT sufficient on its own; the agreement must be at
the structurally expected rank. FR-001's criterion must be read that way, and the test
written accordingly.

---

## R4 — The measured A/B regime boundary (FR-006)

### Procedure

1. Choose the grounding from the three the spec admits, and justify the choice against
   the other two rather than merely asserting it:
   - machine precision relative to `norm(S)`;
   - the R2 residual floor — attractive because it is the quantity that decides whether
     a usable basis is *obtainable*, which is precisely what the regime question asks;
   - a condition estimate of the operative matrix.
2. Measure the chosen quantity across a graded family of inputs spanning well-scaled to
   deliberately badly scaled, constructed by scaling rows/columns of a known-good matrix
   by controlled factors.
3. Locate the boundary where the accuracy target of R3 stops being attainable. That
   crossover *is* the boundary; it is measured, not chosen.
4. Verify behaviour either side of it, so the boundary is exercised in both directions
   (FR-019).

### Result

**Grounding chosen: the R2 solver residual floor, against the R3 target.** Regime B is
where the accuracy target *cannot be met even in principle* — where the target falls below
the residual the solver can actually deliver. This was preferred over the two alternatives
because it is the quantity that decides whether a usable basis is **obtainable**, which is
exactly what the regime question asks. Machine precision relative to `norm(S)` was rejected
as it says nothing about attainability; a bare condition estimate was rejected because it
does not reference the accuracy actually required.

Since `target = tau_min * sigma_1(M) * sigma_min+(Nop)`, the boundary is:

```text
Regime B   <=>   sigma_min+(Nop)  <  rho_floor / (tau_min * sigma_1)
```

With the measured `rho_floor = 1e-16` (gurobi/glpk, R2):

```text
threshold sigma_min+(Nop) = 2.3793e-06
iDopaNeuroC actual        = 2.8382e-02     -> Regime A, margin 11929x
```

**Graded family** (a fixed 10% of rows of `N` divided by a known factor `f`):

| f | `sigma_min+` | target | target/rho | regime |
|---|---|---|---|---|
| 1e0 | 2.8382e-02 | 1.1928e-12 | 1.19e+04 | A |
| 1e2 | 5.9676e-04 | 2.3344e-14 | 2.33e+02 | A |
| 1e4 | 5.9691e-06 | 2.3349e-16 | 2.33e+00 | A |
| **1e5** | 5.9691e-07 | 2.3349e-17 | 2.33e-01 | **B** |
| 1e8 | 5.9691e-10 | 2.3349e-20 | 2.33e-04 | B |

**Crossover between f = 1e4 and f = 1e5**, confirmed on both sides. The boundary is
measured and derived from quantities the problem defines; no constant was chosen.

---

## R5 — External-solver configuration audit (Constitution Principle IV)

For `solveCobraLP` as invoked by `findExtremePool`, enumerate the configuration surface
and cross-check every default against this problem's structural profile.

### Structural profile of the problem actually passed

- `A = [S'; ones(1,m)]`, sparse, ~2900 x ~1300 at genome scale; continuous; equality
  constraints throughout (`csense = 'E'`, `findExtremePool.m:63`).
- `b = [zeros(n,1); 1]` — a **normalisation row forcing `sum(x) = 1`**
  (`:53-54`).
- `lb = 0` when `positive` is set, else `-100`; `ub = 100` (`:56-61`) — **hard-coded**.
- `osense = -1` (maximise).

### Defaults already identified as suspect — part of the audit, not incidental

1. **`epsilon = 10 * feasTol` truncation** (`:36-39`, `:66`) — the R1 hypothesis. A
   post-solve modification of the solution that the solver never validated.
2. **`sum(x) = 1` normalisation** (`:53-54`) — on a model with ~1300 metabolites this
   drives mean entry magnitude to ~1e-3 and many entries far below that, until they meet
   the 1e-5 truncation floor. The normalisation and the truncation interact: **neither
   is harmful alone; together they destroy small entries.** Audit whether a different
   normalisation (for example `max(x) = 1`, or normalising after truncation rather than
   before) removes the interaction.
3. **Hard-coded `lb`/`ub` of ±100** (`:57-61`) — with `sum(x) = 1` these are unlikely to
   bind, but they are unexplained constants in a routine whose whole defect is an
   unexplained constant. Confirm by measurement whether any ray is clipped.
4. **`feasTol` read from global solver parameters** — so the truncation threshold moves
   when a user changes an unrelated global solver setting. Audit that coupling.

### Procedure

Enumerate the options `solveCobraLP` exposes for the installed solvers; record each
default and whether it suits this profile; record chosen overrides and the rationale;
cite the installed solver source and the representative instance used.

### Result

- **Solvers installed**: gurobi 1302, mosek 11.2, glpk, pdco. Not available: ibm_cplex,
  matlab. Session default at baseline: mosek.
- **Configuration surface** (`getCobraSolverParams.m:90-115`, defaults stated to be taken
  from Gurobi's own): `feasTol = 1e-6`, `optTol = 1e-6`, `objTol = 1e-6`,
  `timeLimit = 1e36`, `iterationLimit = 1000`, `intTol = 1e-12`, `NUMERICALEMPHASIS = 1`,
  `multiscale = 0`, `printLevel = 0`, `verify = 0`.

**Cross-check against this problem's structural profile** (sparse, all-equality,
continuous, ~1244 x 2954 at genome scale, simplex-normalised, non-negative orthant):

| Default | Verdict | Evidence |
|---|---|---|
| `feasTol = 1e-6` | **Mismatched to purpose.** A feasibility tolerance answers "is this point feasible"; this routine needs "is this direction numerically in the nullspace", which R3 shows requires ~1e-12. It also sets the truncation threshold at `10*feasTol`. | R3 target 1.193e-12 vs 1e-6 |
| `iterationLimit = 1000` | **Suspect but not binding here.** Low for a 2954-column LP; no ray hit it in these runs, but it is an unexplained default in a routine whose defect is an unexplained constant. | all solves returned `stat = 1` |
| `multiscale = 0` | **Relevant to Regime B and unused.** The toolbox already carries a flag meaning "this problem is multiscale"; a Regime-B diagnosis is precisely that condition, and the routine neither reads nor sets it. Recorded for US2. | not read by either file |
| `epsilon = 10*feasTol` truncation | **Harmless in every configuration measured** — R1. But it couples the truncation threshold to an unrelated *global* solver setting, so changing `feasTol` for another purpose silently moves it. | R1 |
| `sum(x) = 1` normalisation (`findExtremePool.m:53-54`) | **This is what makes entries small**, down to 1.6e-05 on iDopaNeuroC (max/min ~3e4 within a single ray). Not harmful to the residual, but it is the true source of the small entries the seed attributed to scaling. | R1 |
| hard-coded `lb`/`ub` = +-100 (`:57-61`) | **Never binds.** Measured directly: **0 rays** out of 60 touched the bound on iDopaNeuroC across three solvers. Unexplained but harmless. | R2 run |

- **Overrides chosen**: none for this slice. The accuracy requirement is discharged by
  verifying the returned object against the R3 target (FR-003), not by re-tuning the
  solver. The `feasTol`/purpose mismatch is addressed by FR-015a's clamp, not by changing
  a global default that other code depends on.
- **Is any ray clipped by the +-100 bounds?** **No** — 0 of 60.

---

## R6 — Fixture design

### Procedure

1. **Exactly-known non-negative left nullspace.** Construct small matrices whose left
   nullspace is known by construction rather than by computation — e.g. build `S` from a
   chosen non-negative `L` with `L*S = 0` exactly in rational arithmetic, so the
   expected answer carries no floating-point error of its own. Required variants: a
   square case; one with `m != n`; and one whose left nullspace is **empty**.
2. **Well-scaled genome-scale case, CI-available.** Survey models reachable without
   submodule content — `test/models/` and models loaded by existing topology tests — and
   choose one whose stoichiometry is well scaled. Record why it was chosen and its
   measured scaling, so the choice is auditable rather than convenient.
3. **Deliberately badly scaled case.** Derive it from a known-good matrix by controlled
   row/column scaling (shared with R4's graded family), so the degree of bad scaling is
   known exactly rather than found.
4. **`iDopaNeuroC` regression.** Loaded from `papers/2023_iDopaNeuro/models/` for the
   documented reproducibility check only. Not a CI test: `papers/` is a git submodule.

### Result

**Exact fixtures** — constructed so the answer is known by construction, verified in the
test before being used to judge the routine (a fixture asserted rather than checked is not
evidence). All integer, all exactly annihilating:

| Fixture | `S` | shape | exact `L` | nullity |
|---|---|---|---|---|
| F1 | closed cycle A->B->C->A | 3 x 3 (square) | `[1 1 1]` | 1 |
| F2 | open chain A->B->C | 3 x 2 (**m != n**) | `[1 1 1]` | 1 |
| F2b | two independent pools | 4 x 2 | `[1 1 0 0; 0 0 1 1]` | 2 |
| F3 | full row rank | 2 x 3 | *empty* | **0** |

**Genome-scale, CI-available**: `test/models/mat/iAF1260.mat` (1668 x 2382, nnz 9231,
left nullity 38) with `ecoli_core_model.mat` (72 x 95, left nullity 5) as the fast case.
Both ship with the test suite and depend on **no submodule content**, satisfying SC-011.
Measured: both yield assembled residual 0 (gurobi) / 3.0e-11 absolute, 4.3e-14 scaled
(mosek) — i.e. both are comfortably in Regime A and neither reproduces the defect.

**Badly scaled construction**: divide a fixed 10% of rows of a known-good `N` by a factor
`f`; the R4 crossover lies between `f = 1e4` and `f = 1e5`. The factor is known exactly
rather than found, so the fixture's regime is not itself a measurement.

**iDopaNeuroC**: `papers/2023_iDopaNeuro/models/iDopaNeuroC.mat`, 1244 x 1915 (internal
1244 x 1710, rank 1139, left nullity 105). `papers/` is a git submodule, so this is the
documented reproducibility check (SC-005), not a CI test.

---

## R7 — Which refinements preserve non-negativity? (FR-004)

Non-negativity is inviolable, and the obvious accuracy remedy destroys it.

### Procedure

Assess each candidate against two criteria — does it improve the residual, and does it
preserve `Zpos >= 0` — and record both. Candidates:

| Candidate | Preserves non-negativity? | To be assessed |
|---|---|---|
| Not truncating, or truncating only where provably safe | Expected yes — removing an operation cannot introduce negatives | residual gain; sparsity cost |
| Re-solving the ray with tighter solver tolerances | Yes — bounds keep `x >= 0` | gain vs. the R2 floor; runtime |
| Iterative refinement / re-projection onto `ker(S')` | **Not inherently** — projection can produce negatives | whether a non-negativity-preserving variant exists |
| Re-orthogonalising the assembled basis | **No** — stated in the spec's Assumptions | excluded by FR-004 |
| Exact/rational arithmetic on small problems | Yes | feasible size limit only |

For any candidate that does not inherently preserve non-negativity, determine whether a
constrained variant does (for example, projection restricted to the active non-negative
face), and if not, exclude it explicitly rather than silently.

### Result

| Candidate | Preserves `Zpos >= 0`? | Measured outcome |
|---|---|---|
| **Verify each row against the R3 target and drop those that fail** | **Yes, by construction** — it only ever removes whole rows, never modifies an entry | **SELECTED.** Discharges FR-003/FR-003a directly |
| Not truncating / truncating only where safe | Yes (removes an operation) | **No gain available** — R1 shows truncation never worsened a residual, and improved it under mosek. Rejected as pointless, not as harmful |
| Re-solving with tighter solver tolerances | Yes (bounds keep `x >= 0`) | Unnecessary for gurobi/glpk, which already sit ~4 orders below target; would not rescue mosek, whose floor is ~4 orders above |
| Iterative refinement / re-projection onto `ker(S')` | **Not inherently** — projection can produce negative entries | **Excluded.** Not needed once verify-and-drop suffices; a non-negativity-preserving variant would require projection onto the non-negative face, which is a constrained solve per ray and buys nothing here |
| Re-orthogonalising the assembled basis | **No** | **Excluded** by FR-004 |
| Exact/rational arithmetic | Yes | Unnecessary; reserved for small fixtures where the answer is known by construction anyway |

**Selected remedy: verify-and-drop.** It is *subtractive* — rows are either kept exactly as
the LP produced them or removed entirely — so non-negativity is preserved by construction
rather than by argument, and FR-004's assertion on the returned object can never fail as a
result of the remedy. Its cost is that a solver which cannot meet the target yields a
short or empty basis, which is the correct and informative outcome (FR-003a) rather than a
silently wrong one.

---

## Consolidated decisions

*To be completed once R1–R7 are measured. Each entry must carry Decision / Rationale /
Alternatives considered, and must cite the measurement that supports it.*

| # | Decision | Rationale | Alternatives considered |
|---|---|---|---|
| **D1** | **Do not change `findExtremePool.m`.** The Gate-2 scope extension is not exercised. | R1 refuted the truncation hypothesis: gurobi truncates 0 entries and achieves 1.185e-16; mosek's truncation only removes dust and improves the residual. There is no defect there to fix for this feature. | Option (a) direct edit and option (b) a defaulted parameter were both approved-in-principle at Gate 2; both are now unnecessary, and taking either would change a second public function for no measured gain. |
| **D2** | **Accuracy target = `tau_min * sigma_1(M) * sigma_min+(Nop)`**, `tau_min = eps*max(size(M))`. For iDopaNeuroC: 1.193e-12 absolute, 1.862e-14 scaled. | Derived from Weyl's inequality and the singular-value separation a rank determination needs (R3); validated against both known outcomes and by controlled perturbation. | A fixed constant (forbidden by FR-002); the measured crossing ~7e-10 (rejected as a *necessary* rather than *sufficient* condition, and specific to a random error direction). |
| **D3** | **Regime boundary: `sigma_min+(Nop) < rho_floor / (tau_min * sigma_1)`**, measured threshold 2.379e-06. | Grounded in attainability — the question the regime asks (R4). Crossover confirmed on a graded family between f=1e4 and f=1e5. | Machine precision relative to `norm(S)` (says nothing about attainability); a bare condition estimate (does not reference the required accuracy). |
| **D4** | **No solver-parameter overrides in this slice**; record the `feasTol` purpose-mismatch, the unused `multiscale` flag and the never-binding +-100 bounds. | R5: no default was measured to bind or to harm. The accuracy requirement is met by verifying the returned object, not by re-tuning a global. | Lowering the global `feasTol` (rejected: other code depends on it, and it would not fix mosek). |
| **D5** | **CI fixtures: F1, F2, F2b, F3 constructed exactly, plus `iAF1260` / `ecoli_core_model`.** iDopaNeuroC is the documented reproducibility check only. | R6; `papers/` is a submodule, so SC-011 forbids depending on it in CI. | Committing a fixture `.mat` (rejected: a constructed fixture carries no floating-point error of its own). |
| **D6** | **Remedy = verify-and-drop**, subtractive so non-negativity holds by construction. | R7. | Re-projection and re-orthogonalisation, both excluded for non-negativity; re-solving, which buys nothing measured. |

## Headline finding

**The operative cause is neither of the two candidates on the table.** It is not the
`1e-6` acceptance test (the seed's diagnosis) and it is not the `epsilon` truncation (this
plan's hypothesis). Measured on the same model, same code, same tolerances, the assembled
residual is **1.185e-16 under gurobi and 9.342e-09 under mosek** — seven orders of
magnitude apart. The accuracy of the returned basis is dominated by **which LP solver is
installed**, and the seed's 1.418e-07 is consistent with a mosek-class solve.

This is why FR-003's requirement to verify **on the returned object** rather than infer
accuracy from the acceptance path is the load-bearing requirement of the whole feature: it
is the only one that catches a defect whose cause lives outside this function entirely.
