# Phase 0 Research: Optional GECKO support in entropicFluxBalanceAnalysis

Grounded in a read-only harvest of the current function, the external AdaptGECKO fork,
`buildOptProblemFromModel`, and `solveCobraEP`. File:line citations throughout. No `NEEDS
CLARIFICATION` remains (CQ1–CQ3 resolved in clarify).

## R1 — Current `entropicFluxBalanceAnalysis` contract (the Existing Contract to pin)

- **Signature**: `[solution, modelOut] = entropicFluxBalanceAnalysis(model, param)` (line 1). 1795 lines.
- **`param`**: `printLevel`(1), `debug`(false), `solver` default **'mosek'** (valid {'pdco','mosek'}),
  `entropicFBAMethod` default 'fluxes' (also 'fluxConc','fluxConcNorm'), plus flux/conc bound params.
  Entropy weights `g` (flux) / `f` (conc) come from `model.g`/`model.f`, not `param`.
- **Flow**: splits `S` by `SConsistentRxnBool` → internal `N = S(:,cons)`, external `B = S(:,~cons)`
  (:236–240); coupling `C*v<=>d` split `C=model.C(:,cons)`, `D=model.C(:,~cons)` (:297–306). Decision
  vars (fluxes method): `vf`(n), `vr`(n), internal net `v` (pdco), external net `w`/`ve`(k). Assembles
  `EPproblem.A` (mosek fluxes `[N -N B; In -In Onk]` + `[C -C D]` coupling row, :1216-ish; pdco fluxes
  `[N -N Omn B; In -In -In Onk]` + `[C -C Ocn D]`, :854-857) with `blc/buc` (mosek) or `b/csense`
  (pdco), `c`, `lb/ub`, `osense`, `Q`, and the entropy selector **`d`**; hands to `solveCobraEP`.
- **Entropy selector `d`**: ONLY the first `2n` columns (`vf`,`vr`) get weight `g`; ALL other columns
  (incl. the external `w`/enzyme block) get `d=0` → linear-only (mosek :1151-1152, pdco :896-897).
- **Consistency check (reject logic)**: computes `SConsistentMetBool/RxnBool` via
  `findStoichConsistentSubset` if absent (:216-220); then **hard-errors if any metabolite is
  stoichiometrically inconsistent** (:232-234). Reactions are NOT rejected — they are split
  internal/external. The flux-consistency block is dead-coded (`if 0`).
- **Solution fields**: `.v`(scattered by SConsistentRxnBool), `.vf,.vr,.vt,.y_N,.z_*,.stat,.osense`,
  `+.y_C` (coupling), `+.x,.x0,.z_x*` (conc), `.time,.origStat` (from solveCobraEP). `modelOut` = input
  with processed `lb/ub`, `.cf,.cr,.g` appended.
- **E/evar/D**: grep confirms the current function references NONE of `model.E/evarlb/evarub/evarc/D`.

## R2 — Fork harvest: take the consistency-skip; do NOT copy the representation

The fork `AdaptGECKOentropicFluxBalanceAnalysis.m` (1969 lines) is a near-copy with three diffs — but
its enzyme REPRESENTATION differs from what feature 010 wants:

1. **Consistency skip (harvest this)**: the `findStoichConsistentSubset` call and the
   inconsistent-metabolite `error` are commented out (:299-325); the fork REQUIRES the caller to
   pre-set `SConsistentRxnBool` false for every enzyme reaction, routing them EXTERNAL.
2. **D-folding (already how coupling works)**: enzyme constraints live in `model.C`/`model.d`; `D` goes
   into the mosek matrix block (`[N -N B; In -In Onk; C -C D]`, :1216-1219) — done inside the function.
3. **enzymes as EXTERNAL reactions, NOT E/evar fields**: the fork has NO `E`/`evarc`/`evarlb`/`evarub`
   in the entropic path (grep: only a comment). Enzyme usages are columns of `S`→`B` and `C`→`D`; their
   bounds come from `vel/veu`, objective from linear `ce`.
4. **NO entropy on enzymes**: `EPproblem.d(1:2*n)=[g;g]`, everything else `d=0` (:1322-1324) — identical
   to the main function. **The fork treats enzymes as linear-only.**

`gecko2CobraSplit.m` (the field-producing adapter) DOES create `.E/.evar*/.D` — but it feeds
`buildOptProblemFromModel` (LP/QP), NOT the entropic path.

**Decision**: harvest the fork's *consistency-skip discipline* and its confirmation that D folds as
coupling rows; but implement feature 010 against the **`E`/`evar*`/`D` field representation**
(`buildOptProblemFromModel` semantics, R3), NOT the fork's external-reaction hack — that is cleaner,
single-sourced with the LP/QP path, and matches the spec. The fork stays a reference, then is retired.

## R3 — `E`/`evar*`/`D` semantics (target representation; `buildOptProblemFromModel.m`)

- `A = [S E; C D]`; `lb=[lb;evarlb]`; `ub=[ub;evarub]`; `c=[c;evarc]`; extra (enzyme) variables ordered
  AFTER all reaction variables; names `[rxns; evars]` (:188-195, :317-321).
- `E` = enzyme-variable columns in the metabolite (`S`) rows; `D` = same variables in the coupling
  (`C`) rows; `evarlb/ub` box bounds; `evarc` linear objective. Quadratic `F` is zero-padded over evar
  columns (evars carry no quadratic term there). This builder has NO entropy concept.

## R4 — CQ2 (entropy on enzyme variables): representable in BOTH backends, but re-indexes the unpacking

`solveCobraEP` keys entropy off the **`.d` vector** (`d(i)==0` ⇒ linear; `d(i)>0` ⇒ `x log x` entropy;
:41-43). Both backends handle arbitrary `d`:
- **mosek**: `nExpCone = nnz(d)` (:587), one `MSK_CT_PEXP` cone per `d>0` column (:675). A `d>0` enzyme
  column just adds a cone.
- **pdco**: closed-form entropy objective uses `deq` to pick entropy columns (`grad=ceq+deq.*logx`,
  :431-447). A `d>0` enzyme column adds an `x log x` term.

**No representational gap** — applying entropy to enzyme variables is supported under both solvers by
setting the enzyme columns' `EPproblem.d` entries `>0`.

**PRIMARY IMPLEMENTATION RISK**: the caller's post-solve unpacking HARD-CODES offsets assuming the exp
cones correspond exactly to the `vf,vr` block (`nExpCone`, `Fty_K` cone-dual reordering :681-700,
`auxPrimal`/`coneF`/`auxRcost` offsets). Giving enzyme columns `d>0` GROWS `nExpCone` and shifts every
downstream offset — so the enzyme-usage variable/dual extraction and the cone reordering MUST be
updated in lockstep, per method (fluxes/fluxConc) and per backend (mosek/pdco). This is the hard part;
entropy on enzymes also requires enzyme variables to be strictly positive (log domain) — enzyme-usage
`>= 0` bounds are natural, but a zero lower bound needs the same small-epsilon / domain handling the
existing `vf,vr` entropy vars use.

## R5 — CQ1 (consistency auto-relax scoped to enzyme reactions)

Under the `E`/`evar*`/`D` representation the enzyme pseudo-metabolites (`prot_*`) live in the coupling
(`C`) rows, not in `S` — so the `SConsistentMetBool` error (:232-234), which checks `model.S`, may not
even see them. Regardless, the resolution (CQ1) is: **when `E`/`D` are present, do not reject the
enzyme-as-substrate reactions for stoichiometric inconsistency** — scope the consistency handling so
the enzyme columns are treated as external/added variables (not required to be mass-balanced), while
the check stays strict for the genuine metabolic reactions. Harvest the fork's commented-out-skip
intent but implement it as a scoped, field-presence-driven relaxation (no new param), preserving the
error for non-enzyme inconsistency.

## R6 — Backend audit summary (Principle IV) & solver config surface

- Representative instances: the minimal committed enzyme fixture under BOTH `param.solver='mosek'` and
  `'pdco'`. Config surface: mosek exp/quad cones (`nExpCone=nnz(d)`, quad cones per `Q`), tolerances
  (`MSK_DPAR_INTPNT_TOL_PFEAS`, `MSK_DPAR_BASIS_TOL_X`); pdco entropy objective handle + its `deq`
  Hessian and the L/G→equality+slack reformulation.
- **Documented difference to watch**: any method (`fluxConc`) whose external/`w` block is shaped
  differently per backend must be re-checked when enzyme entropy columns are added; if a real backend
  limitation surfaces (e.g. cone-count / dual-reordering only wired for one method), document it in the
  spec/plan rather than silently degrading (per Principle VIII spirit) — likely scope 010 to the
  `fluxes` method first and note `fluxConc`/`fluxConcNorm` as follow-up.

## Decisions summary

- **D1**: Implement against `E`/`evar*`/`D` (buildOptProblemFromModel semantics), not the fork's
  external-reaction representation. Fork = reference for consistency-skip only; retire it.
- **D2**: Entropy on enzyme columns via `EPproblem.d>0` (CQ2) — new work; requires re-indexing the
  post-solve unpacking + cone-dual reordering per method/backend. Scope 010 to the **`fluxes`** method
  first; `fluxConc`/`fluxConcNorm` enzyme support is a documented follow-up.
- **D3**: Consistency auto-relax scoped to enzyme reactions, field-presence-driven (CQ1), no new param.
- **D4**: A small shared pre-split/validation helper under `entropicFBA/` (analogous to
  `gecko2CobraSplit`) validates E/evar/D dimensions and prepares the enzyme block; the fold-in and
  entropy-`d` assignment live in `entropicFluxBalanceAnalysis` behind field detection.
- **D5**: Characterize current non-GECKO `fluxes` behaviour (both backends) first; minimal committed
  enzyme fixture for CI; liver-GECKO full-mode-only.
