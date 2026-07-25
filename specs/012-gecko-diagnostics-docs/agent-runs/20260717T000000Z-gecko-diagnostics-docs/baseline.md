# Baseline (Phase 1: T001–T003) — read-only, pre-change

## T001 — non-enzyme diagnostic reference (ecoli_core, printLevel=2)
- mosek: stat=1, ||v||=13.434743. Blocks: "Optimality conditions (biochemistry)", "Derived optimality
  conditions (biochemistry)", "Thermo conditions". No enzyme lines (as expected).
- pdco: stat=1, ||v||=13.425614. Blocks: "Optimality conditions (unregularised)/(regularised)", "Thermo
  conditions (unregularised)/(regularised)", "Effects of internal/external bounds".
- These blocks are the FR-004 invariant: unchanged after the enzyme-aware additions (guarded).

## T002 — check_matlab_code baseline
- `entropicFluxBalanceAnalysis.m`: 34 pre-existing flags (unreachable statements, unused vars/functions).
  SC-005 target: no NEW flags beyond these 34. (Post-change: still 34, confirmed.)

## T003 — GECKO enzyme residual + backend sign (pre-fix)
Default `'fluxes'` method uses the pdco block ~L1004–1044 and the mosek block ~L1369–1440 (NOT the
L420–532 / L763 fluxesConcentrations blocks the plan initially guessed).

Enzyme-column stationarity candidate `evarc + E'*y_N + D'*y_C ± z_e`:
- `buildEnzymeToy(3,2)` — NON-binding (enzyme duals ~1e-7 noise) → not discriminating.
- `buildEnzymeToy(1,2)` — BINDING (e=1, v_R2=2=kcat*e):
  - **pdco**: z_e=14.3, y_C=7.149, D'*y_C=-14.3 → `+z_e` resid **1e-8**, `-z_e` resid 28.6 ⇒ **+z_e**.
  - **mosek**: z_e=0, y_C=0 (degenerate dual, weight on y_N) → both signs give 0; the block's own
    external `ce+B'*y_N+z_ve` residual is O(1) on this tiny toy (ill-conditioned).
- Determination: `solution.z_e` is raw `solution.rcost` (010), same as the block's `z_ve`; both blocks
  use `+z_ve` in the working external-reaction line ⇒ enzyme line uses **+z_e for both backends**.
