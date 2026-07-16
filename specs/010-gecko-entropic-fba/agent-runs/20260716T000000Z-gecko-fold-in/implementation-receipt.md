# Implementation Receipt

**Feature**: 010-gecko-entropic-fba
**Run (UTC)**: 20260716T000000Z (Part 2 of implementation — GECKO enzyme fold-in; resumed from the checkpoint)
**Scope**: COMPLETE — the optional GECKO/enzyme-constrained path (US1: T002, T006–T011) and polish
(T012–T015) are done and green, on top of the characterization net from run 20260715T212225Z.

## Prompt

Human-loop run for feature 010, continued. User authorized the full fold-in at the checkpoint
("Full fold-in now (accept the risk)"), then, mid-implementation, gave an overriding scientific
correction: "there is currently no scientific justification for maximisation of entropy of the E,D
variables. That should be an option, but not the default."

## Final response

010 optional GECKO/enzyme-constrained support for entropicFluxBalanceAnalysis is implemented, green,
and Principle-II-safe. When `model.E`/`evarlb`/`evarub`/`evarc`/`model.D` are present the `[S E; C D]`
block and the evar bounds/objective are folded into the entropic problem under BOTH backends
(mosek + pdco); when absent the function is byte-for-byte unchanged.

Verified (MATLAB MCP, R2026a):
- testCharacterizeEntropicFBA (regression net) — PASS on mosek + pdco; non-GECKO `||v||` still within
  1% of the captured baseline (mosek 13.4347, pdco 13.4256).
- testEntropicFBAgecko (new) — PASS on mosek + pdco: a feasible enzyme-abundant case, an enzyme-limited
  case where the enzyme constraint binds exactly (`v_R2 == kcat*e`, `e` fully utilised), and an E/D
  dimension-mismatch that is rejected with a clear error (FR-004, fail-loud).
- Legacy testEntropicFluxBalanceAnalysis (Recon3D, non-GECKO) — PASS when its own pre-existing
  undefined-`k` bug is worked around (`k=1`); `solveCobraEP` feasible, OPTIMAL & MSK_RES_OK, KKT
  satisfied. That bug is unrelated to this feature (file untouched by 010) and is recorded to memory.

Design decision (overriding the initial CQ2 answer): the enzyme-usage columns are **linear additional
variables by DEFAULT** — there is no scientific justification for maximising their entropy. An entropy
term on the enzyme columns is available **opt-in** via `param.enzymeEntropyWeight > 0` (experimental;
its enzyme-dual correctness is not yet validated against a well-conditioned reference model, since the
entropic interior-point methods are ill-conditioned on tiny fixtures). The default (weight 0) leaves
`nnz(EPproblem.d)` and the exponential-cone count unchanged, so no cone-dual reindexing occurs on the
default GECKO path.

## Diff summary

- M `src/base/solvers/entropicFBA/entropicFluxBalanceAnalysis.m` (+52/-3): optional-field detection
  (`hasEnzymes`, `enzymeEntropyWeight` default 0), fold-in call in both the mosek and pdco `fluxes`
  assembly, and post-solve extraction of `solution.e` / `solution.z_e`. All new code is guarded by
  `hasEnzymes`; the no-E path is unchanged.
- A `src/base/solvers/entropicFBA/prepareEnzymeConstrainedEP.m` (new, offset-agnostic helper; appends
  the enzyme columns/bounds/objective and a `dEnzyme` entropy-weight vector to an assembled EPproblem;
  validates E/D/evar dimensions and fails loud).
- A `test/verifiedTests/analysis/testEntropicFBAgecko/testEntropicFBAgecko.m` (new).
- A `test/verifiedTests/analysis/testCharacterizeEntropicFBA/testCharacterizeEntropicFBA.m` (from run 1).
- A `specs/010-gecko-entropic-fba/**` (spec + design docs + tasks + receipts).
- No `AdaptGECKO*` fork file shipped in `src/`; the fork was consolidated into the guarded main path.

## Tests

- testCharacterizeEntropicFBA — PASS (mosek + pdco).
- testEntropicFBAgecko — PASS (mosek + pdco): feasible, binding, and dimension-error cases.
- Legacy testEntropicFluxBalanceAnalysis (Recon3D) — PASS on the non-GECKO path with `k=1`.
- check_matlab_code on the edited function — only pre-existing flags (unreachable/unused in the
  1795-line file); no NEW flags at the edit sites. prepareEnzymeConstrainedEP — clean.

## Unresolved issues

- Enzyme entropy path (`param.enzymeEntropyWeight > 0`) is experimental: mosek and pdco disagree ~10%
  on the tiny fixture and the enzyme duals were not independently validated. Follow-up: validate on the
  full-mode liver-GECKO model. Default (linear) path is unaffected.
- Strictly-infeasible GECKO case exercises a pre-existing infeasibility-diagnostic path
  (entropicFluxBalanceAnalysis.m:1699 undefined `message` + solveCobraEP mosek naming dim error);
  out of 010's additive scope, recorded to memory ([[entropicfba-infeasible-message-bug]]).
- Full-mode-only liver-GECKO test (CQ3's heavyweight half) not added — the committed minimal fixture
  covers the CI path; the liver-GECKO run is deferred with the entropy-dual validation above.
- Not pushed (on branch 007-ci-coverage-summary / 010 commits; awaiting Gate 3).
