# Research: safe Tier-1 defect fixes

Inputs: the impact analysis of 2026-11-02 (caller graph over `src/`, `tutorials/` `.m`/`.mlx`,
`papers/`; call-site reading; MATLAB R2025a runs comparing each original function with a
one-line fix placed first on the path; `src/` untouched during the analysis).

## R1 — Classification rule

- **Decision**: a defect is fixed here (table A) only if its fix cannot change a result that
  existing toolbox code, a tutorial or a paper produces today: (a) no caller, (b) the defect
  currently raises an error, (c) console text only, (d) trigger unreachable from every caller,
  (e) measured to have no numerical effect. Everything else is documented (table B).
- **Rationale**: Tier-2 references are about to be recorded; fixes that move existing results
  need a maintainer decision and possibly a community notice.
- **Alternatives considered**: fix every defect (rejected: changes published/tutorial paths
  without review); fix none (rejected: leaves 62 harmless defects in place).

## R2 — Defects moved from A to B during planning (FR-007)

- `searcher` (non-iterative search): the cumulative branch reads `database` both as a table
  (`database.description`, `database{...,3}`) and as a cell array (`database(:,1)`), and the
  exclusion filter edits `selection` instead of `totGroup`. The intended database format cannot
  be established from the source, so no fix is made.
- `bilinearDecomposition`: in the "0 substrates, 3 or more products" and "1 substrate, 3 or more
  products" branches the real reaction produces the fake metabolite `nMet+x+1`, while every fake
  reaction consumes `nMet+x` (the convention of all other branches). Because `A = [I 0]` hides
  fake metabolites, the built-in check passes and the defect only errors when the index exceeds
  the matrix (the "lone reaction" trigger). Correcting the index changes `B` for inputs that
  succeed today and are consumed by `checkRankFR` and `checkModelProperties`.

## R3 — Fixes that need a reference or a derivation

- `waterGibbsEnergyOfFormation`: ΔfG(T) = ΔfH(T) − T·ΔfS(T) with
  ΔfH(T) = ΔfH°(298.15) + [H(T)−H(298.15)]_water − [..]_H2 − ½[..]_O2 and
  ΔfS(T) = S_water − S_H2 − ½ S_O2, all from NIST Shomate equations (water liquid 298–500 K,
  already in the function; H2 gas 298–1000 K: A=33.066178, B=−11.363417, C=11.432816,
  D=−2.772874, E=−0.158558, F=−9.980797, G=172.707974, H=0; O2 gas 100–700 K: A=31.32234,
  B=−20.23531, C=57.86644, D=−36.50624, E=−0.007374, F=−8.903471, G=246.7945, H=0). Check:
  the coefficients reproduce the tabulated S°(298.15) of H2 (130.68), O2 (205.15) and liquid
  water (69.95 J/(mol K)), and give ΔfG° = −237.14 kJ/mol at 298.15 K (tabulated −237.13).
  Values at 310.15 K and 350 K: −235.19 and −228.81 kJ/mol.
- `echelonNullspace`: probe on S = [1 0 1 2; 0 1 1 3; 1 1 2 5]: ‖L·S‖ = 4.9 with
  L = [−L0 I]·P and 7e−16 with [−L0 I]·Pᵀ (left); ‖S·Lᵀ‖ = 7.4 versus 8e−16 with Pᵀ (right).
  Decision: L = [−L0 I]·Pᵀ in both branches; the header formulas are corrected to Pᵀ (the
  registry entry's "holds only with P" is a typo for Pᵀ; the test already asserts the Pᵀ form).
- `nullspaceLUSOLapply2Modes`: mode 1 computes W(p,:) = Z, i.e. Z_full = Cinv·Π·L⁻ᵀ[0; I] with
  (ΠX)(p,:) = X. Its transpose applied to V is [0 I]·L⁻¹·Πᵀ·Cinvᵀ·V and (ΠᵀV) = V(p,:).
  Decision: mode 2 uses `V = V(p,:)` instead of `V(p,:) = V`; verified by ⟨Z V1, V2⟩ = ⟨V1, Zᵀ V2⟩.
- `projectOntoSubspace`: move the two sanity checks after the defaults are created, use the
  absolute value in both checks, and assign `vfR = PR*vf`.

## R4 — Every other table-A defect

- **Decision**: the EXPECTED field of the registry entry is the target behaviour; where it
  offers a choice ("an error with a clear message, or an empty result"), the choice that matches
  the function's header and sibling functions is taken, preferring an empty/unchanged result
  for "nothing to do" inputs and a `error()` with an identifier-free clear message for invalid
  input. The implementer re-reads the source (Constitution III-Defects re-check) and confirms no
  input that succeeds today, outside the trigger, changes output; if one does, the defect moves
  to table B (FR-007).

## R5 — Branch and commits

- **Decision**: feature branch `20261102-140321-tier1-safe-defect-fixes` from `upstream/develop`,
  pushed to `origin` with upstream tracking; commits authored with the maintainer's git identity,
  no co-author trailer, only feature paths staged (never the dirty submodule pointers).
- **Rationale**: matches the maintainer's two most recent features; keeps unrelated in-progress
  work out of this branch.
