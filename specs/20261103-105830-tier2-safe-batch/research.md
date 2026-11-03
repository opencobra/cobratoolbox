# Research: Tier-2 safe batch

## R1 — Selection method
See spec "How the functions were found": transitive name-based call closure over `src/` and
`external/`, local variables excluded, four verified option-gated hubs not traversed, silent
registry defects with a reachable trigger excluded. 30 provisional functions.

## R2 — Run-time guard
- **Decision**: during development each test is run once with throwaway spies shadowing
  `solveCobraLP/QP/MILP/MIQP/NLP/EP` and `optimizeCbModel`; a spy call fails the test.
- **Rationale**: the static graph cannot see `feval` of text or option-dependent calls.

## R3 — Models
- **Decision**: `ecoli_core_model` by default; Recon3DModel_301, iJO1366 or an AGORA model only
  when a branch needs it (stated in the header). Whole-body models are not distributed: a
  function that needs one is dropped unless it also works on a distributed model.

## R4 — Style (from the pilot; maintainer questions unanswered)
Inline structural checks, gene-name GPR check when genes change, global state restored by the
test, only debug leftovers recorded as cosmetic, only documented inputs.
