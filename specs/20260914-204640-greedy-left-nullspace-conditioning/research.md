# Phase 0 Research: Measurements That Must Precede Any Remedy

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md) | **Date**: 2026-09-14

**Status: PROCEDURES DEFINED, MEASUREMENTS NOT YET TAKEN.**

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

### Result

*Not yet measured.*

- Rays sampled: —
- Models used: —
- Solvers used: —
- `norm(S'*x_raw, inf)`, absolute / scaled: —
- `norm(S'*x_trunc, inf)`, absolute / scaled: —
- Entries zeroed per ray (median / max): —
- Largest magnitude zeroed: —
- **Verdict (confirmed / refuted)**: —

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

*Not yet measured.*

- Per-solver floor (absolute / scaled): —
- Tolerance at which the plateau begins: —
- Cost of reaching it: —
- **Is the floor above or below the R3 accuracy target?**: —

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

*Not yet measured.*

- Symbolic form: —
- Representative case used: —
- Numeric target, absolute / scaled: —
- Reproduces the two known outcomes (1.418e-07 fails, ~1e-16 passes)?: —

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

*Not yet measured.*

- Grounding chosen, and why not the other two: —
- Graded family and scaling factors used: —
- Crossover point: —
- Behaviour confirmed either side: —

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

*Not yet measured.*

- Solvers installed and versions: —
- Configuration surface enumerated: —
- Defaults mismatched to the profile: —
- Overrides chosen, with rationale: —
- Is any ray clipped by the ±100 bounds?: —

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

*Not yet determined.*

- Exact fixtures and their construction: —
- Genome-scale model chosen, and its measured scaling: —
- Badly scaled construction and its factor: —

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

*Not yet assessed.*

- Candidate selected, with measured residual gain: —
- Non-negativity preserved (asserted on the returned object): —
- Candidates excluded, and why: —

---

## Consolidated decisions

*To be completed once R1–R7 are measured. Each entry must carry Decision / Rationale /
Alternatives considered, and must cite the measurement that supports it.*

| # | Decision | Rationale | Alternatives considered |
|---|---|---|---|
| D1 | *(pending R1)* | — | — |
| D2 | *(pending R2, R3)* | — | — |
| D3 | *(pending R4)* | — | — |
| D4 | *(pending R5)* | — | — |
| D5 | *(pending R6)* | — | — |
| D6 | *(pending R7)* | — | — |
