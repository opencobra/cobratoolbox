# Feature request (Spec Kit seed prompt)

**Target**: `greedyExtremeRayBasis` — left-nullspace basis accuracy, and graceful
diagnosis of badly scaled `model.S`.

**How to use this file**: hand its "Prompt" section below to
`/speckit-human-loop` in this repository (`fork-cobratoolbox`). It is a seed for
specification, not a specification. Nothing in it authorises a code edit;
Principle VI's gate applies as usual.

**Provenance**: the evidence below was measured on 2026-09-14 during
`varkin` feature `054-maximum-certified-support-lp` and its follow-on exploration
`specs/20260914-202303-augmentation-scaling/exploration.md` (entries E5–E12,
V3–V5) in the repository at
`/home/rfleming/drive/sbgCloud/projects/variationalKinetics/code`. Every number
quoted is a measurement, not an estimate; each is reproducible from that
exploration.

---

## Prompt

Improve `greedyExtremeRayBasis` so that, for a reasonably well scaled input
`model.S`, the non-negative left-nullspace basis it returns is accurate enough
that a stoichiometric matrix augmented with it has a **well-defined numerical
rank**. Where `model.S` is badly scaled, and therefore likely to produce a badly
scaled augmented matrix whatever the basis routine does, diagnose that condition
and return gracefully with a recommendation to repair `model.S`, rather than
returning a basis that will silently destroy the rank gap downstream.

### The defect, as measured

`greedyExtremeRayBasis.m:126` accepts each computed ray iff

```matlab
if norm(model.S'*x, inf) > param.feasTol     % param.feasTol default 1e-6 (:61-62)
```

Each row of the returned basis is therefore an LP solution accepted at an
**absolute 1e-6 residual**. The function's own caller comments this accurately —
`driver_optimizeVKmodel_VK1to3m.m:668` (in `varkin`) calls the result "a
approximation to a non-negative basis".

On `iDopaNeuroC` the consequence is:

| Quantity | Measured |
|---|---|
| `norm(L*N, inf)` | **1.418e-07** (scaled by `‖L‖·‖N‖`: 2.218e-09) |
| the same for an exact basis | ~1e-16 |
| passes `feasTol = 1e-6`? | yes, with 7× margin |

Downstream, `varkin`'s `createCyclicModel` forms `S_cyc = [N, -I; 0, L]`
(1344 × 2942, with `L` 104 × 1344). Splicing in a matrix whose 104
left-nullspace directions are accurate only to 1e-7 makes those directions
**soft**: the 104 smallest singular values of `S_cyc` smear across 1e-11 … 1e-17
instead of sitting at machine zero, and the rank gap disappears.

| Rank of `S_cyc` by | Value |
|---|---|
| structure, if `L` spans the left nullspace: `1344 − 104` | **1240** |
| SVD at relative 1e-9 | **1240** (exactly) |
| SVD at relative 1e-12 / `eps·max(m,n)` | 1255 / 1265 |
| `getRankLUSOL` | **1261** (+21) |
| `getNullSpace` | **1271** (+31) |

Because `getNullSpace` over-estimates the rank, the basis `Z` it returns is short
by 31 columns and satisfies `norm(N*Z, inf) = **14.1**` — it is not a nullspace
basis at all. Any consumer of `ker(S_cyc)` that does not independently verify the
residual gets a confident, well-formed, wrong answer.

The unaugmented counterpart is clean, which isolates the cause: rank 1136 at all
three tolerances, all routines agreeing, `norm(N*Z, inf) = 2.15e-13`.

### What is NOT the cause — do not repeat this mistake

The augmented matrix has an 8.8e5 within-matrix entry-magnitude ratio (`L`
entries reach 1.252e-05 against O(1)–O(10) stoichiometry), and that was the first
diagnosis offered. **It is a symptom, not the cause.** The operative cause is the
1e-6 *acceptance tolerance*. Merely rescaling `L`, or equilibrating `S_cyc`,
would not tighten the residual that created the softness. See exploration V4.

### Two required regimes

**Regime A — reasonably well scaled `model.S`.** Return a basis accurate enough
that the augmented matrix has an unambiguous numerical rank: the same integer
from `getRankLUSOL`, from `getNullSpace`, and from SVD across a range of
tolerances spanning several orders of magnitude. The accuracy target must be
derived from what a rank computation actually needs, not chosen for convenience,
and must be stated with its derivation.

**Regime B — badly scaled `model.S`.** Detect this and **return gracefully with a
recommendation to repair `model.S`**. Do not return a basis that will pass the
current guards and destroy the rank gap downstream. The return must make the
diagnosis unmissable to a caller that does not read warnings: a status field, not
only a printed message. Say what is badly scaled, by how much, and what repair is
indicated.

The boundary between A and B must itself be **measured and justified**, not
invented. An agent-chosen threshold is exactly the failure mode to avoid here;
ground it in a quantity the problem already defines — machine precision relative
to `norm(S)`, the residual floor the LP solver can actually deliver, or a
condition estimate — and show the evidence.

### Do not prejudge the fix

Candidates, none of which may be assumed to work:

- Tightening `param.feasTol` for ray acceptance. **May not be achievable**: the
  rays are LP solutions and the LP solver's own feasibility tolerance may floor
  the attainable residual. Measure this before relying on it.
- Iterative refinement or re-projection of each accepted ray onto `ker(S')`
  before storing it.
- Re-orthogonalising or cleaning the assembled basis afterwards — note this must
  preserve **non-negativity**, which is the whole point of this routine and is
  not preserved by ordinary orthogonalisation.
- Exact or rational arithmetic on small problems only.

Whatever is chosen, non-negativity of `Zpos` is a hard requirement, not a
preference.

### A second, independent defect in the same file

`greedyExtremeRayBasis.m:54-58`:

```matlab
if ~isfield(param,'maxNewBasisTime')     % tests the WRONG field
    param.maxTime = 100;
end
if ~isfield(param,'maxNewBasisTime')
    param.maxNewBasisTime = 10000;
end
```

The first guard tests `maxNewBasisTime` but assigns `maxTime`. A caller supplying
`maxNewBasisTime` and not `maxTime` leaves `param.maxTime` **never set**.
Compounding it, `param.maxTime` is documented at `:30` but never read: both
timeout checks (`:157`, `:161`) test `param.maxNewBasisTime`, so there is
effectively **no total-time budget**, only a per-basis one applied twice.

Fix this, or defer it explicitly with a reason. Do not fix it silently as a
side effect.

### Interface and cross-repository constraints

- The public signature `[Zpos, Z] = greedyExtremeRayBasis(model, param)` has
  callers outside this repository — notably
  `driver_optimizeVKmodel_VK1to3m.m:686` in `varkin`. Preserve backward
  compatibility or version the change deliberately; a silent change to the
  default acceptance tolerance changes results for every existing caller and is
  a breaking change even though nothing errors.
- **The downstream guards are in `varkin`, not here, and MUST NOT be edited by
  this feature.** For the record, they are inadequate and the `varkin` side needs
  its own feature:
  - `createCyclicModel.m:223-225` checks `norm(L*S,'inf') <= param.feasTol` —
    right in intent, but 1e-6 is roughly nine orders of magnitude too loose to
    certify a rank-defining property.
  - `createCyclicModel.m:227-229` checks spanning one-sidedly
    (`size(L,1) < size(S,1) - rankS`); at the measured rank that is `104 < 83`
    and at the correct rank `104 < 104`, both false, so it **cannot** detect rank
    over-estimation.
  - `driver_optimizeVKmodel_VK1to3m.m:691-693` errors with `'model.L does not
    span left nullspace'` but compares only a row count and never evaluates
    `L*N`.
  State in the plan what `varkin` would need to assert once this function is
  fixed, so that work can be specified there. Do not make the change.

### Acceptance

- Small fixtures whose non-negative left nullspace is known exactly, including at
  least one with `m ≠ n` and one where the left nullspace is empty.
- A well-scaled genome-scale case where the augmented matrix's rank is shown
  unambiguous: one integer from `getRankLUSOL`, `getNullSpace` and SVD across
  tolerances spanning several orders of magnitude.
- A deliberately badly scaled case that must return the Regime-B diagnosis and
  must **not** return a basis.
- Regression on `iDopaNeuroC`: it must either yield a basis that gives the
  augmented matrix an unambiguous rank, or diagnose. Either is an acceptable
  outcome; silently returning today's basis is not.
- Every guard exercised against the failure it guards, not only against success.
- Report `norm(L*S)` in **both** absolute and scaled form, the nullity implied by
  the basis against the rank computed independently, non-negativity of `Zpos`,
  and runtime — per case, with the replicate count stated.

### Reporting discipline

Report measured coverage and cost. Do not promise a particular attainable
residual, a particular runtime, or that any given model will fall in Regime A —
which model falls where is a finding of this work, not an input to it. If the
achievable residual turns out to be floored by the LP solver, say so plainly;
that is a legitimate and valuable outcome, and it would mean Regime B is the
correct answer for more models than expected.

---

## Reproducing the evidence

All measurements above come from read-only probes against the frozen instances
`data/interim/iDopaNeuroC_problem_{1,2}.mat` in `varkin`, using
`loadVKProblemInstance`, `getNullSpace`, `getRankLUSOL` and `svd(full(N))`. The
probe scripts were deliberately not committed (throwaway diagnostics are not
deliverables); the exploration records what each measured and why. Re-derivation
is a matter of loading each instance and evaluating `norm(L*N,inf)`,
`svd(full(S))`, and the two rank routines.
