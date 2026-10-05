# Implementation receipt: 20260921-125236-sparse-bond-matrices

## Prompt

`/speckit-implement` (no additional user input), run inline against
`specs/20260921-125236-sparse-bond-matrices/tasks.md`. One user decision was taken during
the run: at T005, the tyrosine fixture turned out to be inconsistent already in the
original function, and the user chose "Require identical output" for it under SC-003.

## Final response

I've implemented the sparse bond matrices, and every check passes. `M2BiE`, `M2BiW` and `BTi2R` are now built as sparse matrices by default. Setting `options.denseBondMatrices = 1` gives back exactly the original full matrices. Every value, size and diagnostic is unchanged. Nothing is committed.

**What I checked:**
- **New CI test** (`testBuildAtomAndBondTransitionMultigraph.m`): passes, all checks (a)–(f). Run against the unmodified function first, it failed only at (a), the "sparse by default" check, which proves the test detects the change.
- **`testConservedReactingMoieties.m`**: unedited, passes both before and after the change.
- **Snapshot comparison** against the original function: 94 of 94 checks pass across 9 fixtures in both modes. All outputs match the original, with class and sparse/full storage checked for every output.
- **Tyrosine fixture** (197 metabolites, 127 reactions):
  - **Storage:** the three matrices take 421 KB instead of 27.5 MB (1.5%).
  - **Speed:** the fill step's median time fell from 0.0404 s to 0.0010 s, about 39× faster.
- **Scope of the change:** `git diff` shows it's confined to the option default, the header docs and the construction block. No `error`, `warning` or `fprintf` line changed.

**Found during the run:**
- **Tyrosine already fails the bond consistency check in the original function.** The residual is 3, caused by a bond-count mismatch for `tym[c]` and `34hpp[c]` in the RXN corpus. You chose to require identical output for it rather than zero residual, and I amended SC-003 to match. The upside is that its 34-line mismatch report, with non-integer values, is now printed identically in both modes. That tests the report branch at real scale.
- **My first version of check (e) was wrong.** It compared console text from two different call lines, so the warning backtraces differed. I changed it to call both modes from the same line.
- **Two plan details were wrong and are corrected in the artifacts.** With `bondTransitionMultigraph = 0` the function assigns 5 outputs, not 7. The tyrosine sub-model now has 127 reactions, not 139, because `subsystemSubModels.mat` was regenerated on 2026-09-17.

**Not done:**
- The optional full-VMH run (T018); I didn't run it because you didn't ask for it.
- A test where a bond type is 0 or NaN; that case is covered by argument only.
- The reconXmoieties pilot fixtures.
- Nothing is committed. The `binary` submodule change was already there and is untouched.

Everything is recorded in `specs/20260921-125236-sparse-bond-matrices/agent-runs/20260921T135656Z-sparse-bond-matrices/implementation-receipt.md`.

## Diff summary

| File | Change |
|---|---|
| `src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m` | Modified (+23/−13): `options.denseBondMatrices` default (0); header docs for the option and the three outputs; `M2BiE`/`M2BiW` built with one `ismember` and two `sparse` calls, replacing two per-metabolite loops; `full` removed around `BTi2R`; dense-mode `full` conversion before any further use |
| `test/verifiedTests/analysis/testReactingMoieties/testBuildAtomAndBondTransitionMultigraph.m` | New: CI test FR-015 (a)–(f) |
| `specs/20260921-125236-sparse-bond-matrices/reproducibilityCheck.m` | New: non-CI golden-snapshot harness (9 fixtures, both modes) |
| `specs/20260921-125236-sparse-bond-matrices/golden-snapshot.mat` | New: 2,203,764 bytes, captured from the unmodified function |
| `specs/20260921-125236-sparse-bond-matrices/reproducibility-results.md` | New: compare-mode results (94 gates, 0 failed) |
| `specs/20260921-125236-sparse-bond-matrices/spec.md`, `research.md`, `tasks.md` | Amended during the run: SC-003 rule for tyrosine (user decision) and clarification entry; five (not seven) outputs when `bondTransitionMultigraph = 0`; tyrosine now 127 reactions; task checkboxes |

## Tests

| Command (`matlab -batch "initCobraToolbox(false); ..."`) | Source state | Result |
|---|---|---|
| `testConservedReactingMoieties` | unmodified (T001) | PASS |
| `reproducibilityCheck.m` (capture) | unmodified (T005) | Snapshot captured; stopped once for the tyrosine SC-003 decision, then recaptured |
| `testBuildAtomAndBondTransitionMultigraph` | unmodified (T007) | Failed only at (a) `output 9 must be a sparse double matrix by default` (expected) |
| `testConservedReactingMoieties` | modified (T010) | PASS |
| `testBuildAtomAndBondTransitionMultigraph` | modified (T011) | PASS, (a)–(f) |
| `reproducibilityCheck.m` (compare) | modified (T012) | 94 gates, 0 failed |
| `git diff` checks (T013) | modified | only the intended files and hunks; no diagnostic line changed; `testConservedReactingMoieties.m` unchanged |

## Unresolved issues

- **Tyrosine fixture inconsistency** (outside this feature's scope): bond residual 3 from a `tym[c]` (24 vs 22) and `34hpp[c]` (22 vs 20) bond-count mismatch in `/media/JACK/repos/ctf/rxns/old/atomMapped_standardised`. This is a candidate follow-up feature.
- **Test fixture warning**: `rh_14817.rxn`'s internal reaction ID does not match its file name (fixture renamed in `aa55f6c3a`). The warning pre-dates this feature and is harmless.
- **Not verified**:
  - the optional full-VMH demonstration (T018, FR-014/SC-008), not run because the user did not ask for it;
  - `BondType` values of 0 or NaN, which no fixture contains (covered by the argument in research R1);
  - the reconXmoieties pilot fixtures, not covered (research R7).
- **Principle VII-F**: research R9 was consulted and proposes a project `matlab-best-practice` skill, not created here.
- **Style (VII-G)**: `options.denseBondMatrices=0;` has no spaces around `=`, to match the neighbouring option lines.
- **Not committed**: the `binary` submodule and `.specify/feature.json` changes pre-date this run and are untouched.

## Other information

The console capture uses `diary`, not `evalc`, so every warning stays visible
(Principle VII-B). The startup warnings about missing `ReconXKG-cidev/.../reconx`
paths come from the user's MATLAB startup and are unrelated.
