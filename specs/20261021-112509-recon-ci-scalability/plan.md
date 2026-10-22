# Implementation Plan: CI scalability of COBRA functions

**Branch**: `20261021-112509-recon-ci-scalability` | **Date**: 2026-10-22 | **Spec**: [spec.md](spec.md)

## Summary

Measure, pin, then optimise. For each COBRA function that the baseline ([research.md](research.md))
shows to be a material share of runtime or memory and that the solver path does not dominate:
write `test<FunctionName>.m` against the UNMODIFIED function (100 % line coverage or documented
exemptions), then enhance the function for memory and runtime without changing its results, then
re-run the same test file unedited and compare before/after on real models.

## Selection rule (FR-009)

A function is changed only if, in the baseline on the 30 665 x 38 841 model, it either (a) fails or
exceeds 4 GB peak memory, or (b) spends at least 5 % of its stage time outside the solver
(`gurobi`) and the cause is a data-structure or repeated-work pattern. Others are recorded as
"measured, not worth changing".

Decision so far: `checkDuplicateRxn` (rule a). `findMassLeaksAndSiphons` is out (346 of 357 s in
`gurobi`). `findSExRxnInd`, `removeRxns`, `removeMetabolites`, `findFluxConsistentSubset`,
`findStoichConsistentSubset`, `maxCardinalityConservationVector`: decided in task T020 from the
profiles; each added function gets its own test-first task group.

## Technical Context

**Language**: MATLAB R2025a. **Solver**: Gurobi via `changeCobraSolver('gurobi','all',0)`.
**Testing**: `test<Function>.m` under `test/verifiedTests/reconstruction/`, run with
`runScriptFile`/`testAll`, coverage via the repository plugin.
**Constraints**: no signature/default/diagnostic change; same output order and sparsity;
no dense nRxn x nRxn or nMet x nMet allocation; no solver substitution.

## Constitution Check

- I/II: results and interfaces identical; verified by unedited tests and real-model diffs.
- III: III-Naming, III-Coverage (tier, prepareTest, smallest model), III-Defects respected.
- IV: no solver-facing change; warnings and diagnostics kept; sparse and vectorised only.
- V/VI: gate satisfied by this spec/plan/tasks and the explicit instruction to run the
  implementation phase (maintainer, 2026-10-21/22); receipt required.
- IX: tests under `test/verifiedTests/`; nothing in `external/`, `deprecated/`, `binary/`.

## Design for checkDuplicateRxn (first target)

- 'FR': scale columns with a sparse diagonal (`spdiags`) or column-wise `A .* sparse(1./sumA1)` so
  element values are the same IEEE products as `A * diag(...)`; keep `A` sparse; `unique(...,'rows')`
  on the transposed sparse matrix as today.
- Group handling ('S' and 'FR'): replace the per-reaction scan `ic == n` by one stable grouping of
  `ic`, visiting groups in the same order (increasing group id) and taking `ind(1)`/`ind(end)` as
  today; the warning for groups with more than two members is raised in the same order.
- 'FR' direction check `norm(S(:,i1)+S(:,i2)) == 0 || norm(S(:,i1)-S(:,i2)) == 0` is kept
  exactly (only evaluated for groups with more than one member, as today).
- Preallocation of `removedRxnInd`/`keptRxnInd` instead of growth; output shape (column vectors)
  unchanged.

## Verification

1. Test passes on the baseline function (hash of the test file recorded).
2. Same file passes after the change (hash equal).
3. Real-model equality: `removedRxnInd`, `keptRxnInd`, `modelOut` identical (`isequal`) on the
   stored Source, VMH and MNX models for methods 'S' and 'FR' where the baseline can run
   (smaller models; the large model baseline fails by design for 'FR').
4. Large-model run of the benchmark under the 24 GB cap; record in research.md.

## Project Structure

```text
specs/20261021-112509-recon-ci-scalability/{spec,plan,tasks,research}.md
test/verifiedTests/reconstruction/testCheckDuplicateRxn/testCheckDuplicateRxn.m
src/reconstruction/modelGeneration/checkDuplicateRxn.m          (edited after its test exists)
```
