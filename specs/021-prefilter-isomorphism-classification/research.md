# Research: Prefilter subgraph isomorphism classification

**Feature**: `021-prefilter-isomorphism-classification` | **Date**: 2026-09-02

## R1: Can one shared grouping algorithm serve all three call sites given they currently use two different loop skeletons?

**Decision**: Yes. Implement a single canonical algorithm (the "exclusion/visited" forward-scan already used by `identifyIsomorphicClasses.m` and `identifyConservedReactingMoieties.m:606-673`) inside the new shared helper, and prove it is behaviorally equivalent to `findAndExtractMolecularGraphs.m`'s symmetric-matrix-then-group-find skeleton.

**Rationale**: `isisomorphic` is an equivalence relation (reflexive, symmetric, transitive) over the fixed set of subgraphs being classified. Both existing skeletons compute the same underlying partition of that set:

* `findAndExtractMolecularGraphs.m` (lines 27-56) builds a full symmetric `isomorphicMatrix` by comparing every `i<j` pair once, then for each unvisited `i` (ascending), forms `isomorphicGroup = [i, find(isomorphicMatrix(i,:))]` and marks the group visited.
* `identifyIsomorphicClasses.m` / `identifyConservedReactingMoieties.m` scan `i` ascending, skip already-excluded `i`, and for each unvisited `i` scan `j` ascending appending `j` to `currentClass` when `isisomorphic(i,j)` and `j` not yet excluded.

Because isomorphism is transitive, if `j < i` were isomorphic to `i`, `j` would already have been the class leader when the outer loop reached `j` (since `j` is processed first) and `i` would already be marked visited/excluded by the time the loop reaches it — so in both skeletons, only the *minimum-index* member of each class ever executes the "form a new class" branch, and the members collected are exactly the ascending-order list of every other index in that equivalence class. The two skeletons therefore produce **identical** `(leader, ascending-members)` groups, in the same class-formation order (ascending leader index), for the same underlying pairwise `isisomorphic` truth table.

**Alternatives considered**:
* *Two helpers (one per skeleton).* Rejected — reintroduces the drift risk FR-001/US2 exist to remove, for no correctness benefit once the equivalence proof above holds.
* *Bucket-by-invariant-hash grouping (map/containers.Map keyed by invariant) for asymptotic improvement beyond the pre-filter.* Rejected for this feature: changes iteration order and risks non-ascending member ordering, which downstream code in `findAndExtractMolecularGraphs.m` uses to build `conservedEdges`/`reactingEdges` row order (see R3). The spec's described approach (skip `isisomorphic`, keep the loop) is lower-risk and suffices to satisfy SC-002 (any nonzero reduction).

## R2: Is substituting a hardcoded "false" for a skipped `isisomorphic` call behaviorally identical to calling it?

**Decision**: Yes, provided the invariant is a strictly necessary (not sufficient) condition for isomorphism (FR-003), which node count + edge count + sorted label multiset already are: two isomorphic graphs necessarily have equal node count, edge count, and (under a label-preserving isomorphism) equal multisets of the label values on the matched dimension.

**Rationale**: When invariants differ, the true `isisomorphic` result is provably `false`; substituting `false` without the call has zero behavioral difference. When invariants match, the pre-filter falls through to the real `isisomorphic` call, so the result is unchanged. This makes the change a pure performance optimization with no output-changing side effect (SC-004), and confirms SC-002's chosen gate (any nonzero reduction, no fixed percentage) is the correct shape of success criterion — the magnitude of the reduction depends entirely on how well node/edge-count/label-multiset separates the actual subgraph population, which is only known empirically (Assumptions section).

**Alternatives considered**: A stricter invariant (e.g. degree sequence, colour-refinement signature as already used in `identifyAtomEquivalenceClasses.m`) would prune more but adds implementation/verification cost; FR-002's "at minimum" wording permits adding it later without a spec change, so it is deferred rather than adopted now (YAGNI — the node/edge-count + label-multiset invariant is enough to demonstrate a measurable reduction per SC-002).

## R3: Does replacing each site's inline loop with the shared helper change any observable output ordering?

**Decision**: No, if each site reconstructs its site-specific bookkeeping (I2C, `atrans2component`, `conservedEdges`/`reactingEdges` concatenation order, etc.) from the helper's returned `isomorphismClasses` cell array by iterating class-by-class, then member-by-member in the array's existing ascending order — i.e. do not re-sort or re-bucket the returned indices.

**Rationale**: `findAndExtractMolecularGraphs.m` concatenates `bondSubgraphs{idx,1}.Edges` for `idx` in `conservedGroup`/`reactingGroups` order directly into `CMTG`/`RMTG` (no dedup on edges, only `unique(...,'rows')` on nodes, which is order-independent because `unique` returns sorted output by default). R1 established the helper's returned member order for a given class is identical (ascending, leader first) to what `[i, find(isomorphicMatrix(i,:))]` already produces today, so `conservedGroup`/`reactingGroups` — and therefore `CMTG`/`RMTG`'s edge row order — is unchanged by routing through the shared helper.

`identifyConservedReactingMoieties.m`'s sanity check (`atoms2component(subgraphs{idx,1}.Nodes.AtomIndex) ~= idx`, FR-007) is per-`idx` and order-independent; moving it from inline-during-comparison to a post-grouping pass over the returned classes changes only the error's *timing* (it now fires after full classification of all subgraphs rather than mid-scan) but not *whether* it fires for a given `idx` under the same input — satisfying "continue to fire under the same conditions" (FR-007) without requiring identical fire-order, which no acceptance scenario tests.

**Alternatives considered**: Keeping sanity-check side effects inside the shared helper via a callback/function-handle parameter. Rejected — couples a generic, reusable classification helper to two structurally different per-site checks (`Nodes.AtomIndex ~= j` in `identifyIsomorphicClasses.m` vs `atoms2component(...) ~= idx` in `identifyConservedReactingMoieties.m`), adding needless helper surface area for no behavioral necessity (R2/R3 already prove post-hoc iteration is equivalent).

## R4: Where does `findAndExtractMolecularGraphs.m`'s plain (no `NodeVariables`/`EdgeVariables`) `isisomorphic` call fit the helper's "comparison mode" parameterization from FR-001?

**Decision**: The helper accepts a generic `varargin` forwarded verbatim to each `isisomorphic(subgraphs{i}, subgraphs{j}, varargin{:})` call. When `varargin` is empty (as at `findAndExtractMolecularGraphs.m`'s call site), the invariant is node-count + edge-count only (no label multiset — there is no label being matched, so no additional invariant component is available or needed). When `varargin` is `{'NodeVariables','mets'}` or `{'EdgeVariables','mets'}`, the invariant additionally includes the sorted multiset of `Nodes.mets`/`Edges.mets` respectively, keeping the invariant consistent with what that mode actually compares (per the spec's Edge Cases section).

**Rationale**: A `varargin`-forwarding signature keeps the helper's public contract at exactly "comparison mode + variable name," matching FR-001, while still covering the third (mode-less) call site without inventing a fourth enum value the spec doesn't describe.

**Alternatives considered**: An explicit `mode` enum parameter (`'plain' | 'NodeVariables' | 'EdgeVariables'`) plus a separate `varName` argument. Rejected as a needless indirection — `varargin` forwarding is simpler, is already the shape `isisomorphic` itself uses, and requires no translation layer between the helper's parameters and the underlying call.

## R5: Where does identifyIsomorphicClasses.m's existing public signature constraint (FR-006 — signatures MUST NOT change) leave the "host the helper" option from the spec's Assumptions section?

**Decision**: `identifyIsomorphicClasses.m` cannot itself become the fully generic shared helper (FR-001 requires parameterization by comparison mode + variable name; `identifyIsomorphicClasses.m`'s signature `(CBSubgraphs, sanityChecks)` is frozen by FR-006 and currently hardcodes `'EdgeVariables','mets'`). Instead: create a new file, `classifySubgraphIsomorphism.m`, as the shared helper (matching the spec's own fallback: "the new shared helper, if implemented as its own file"). `identifyIsomorphicClasses.m` becomes a thin wrapper: it calls `classifySubgraphIsomorphism(CBSubgraphs, 'EdgeVariables', 'mets')` and re-attaches its own `sanityChecks`-gated side effects (R3).

**Rationale**: Satisfies FR-001 (one generic helper), FR-004 (all three sites route through it — `identifyIsomorphicClasses.m` routes through it internally), FR-006 (no public signature changes to any of the three named functions), and SC-006 (exactly one pairwise `isisomorphic(` loop remains in the directory — inside `classifySubgraphIsomorphism.m` — once the other two sites' inline loops are removed).

**Alternatives considered**: Extending `identifyIsomorphicClasses.m`'s signature with optional trailing arguments (e.g. `identifyIsomorphicClasses(CBSubgraphs, sanityChecks, mode, varName)`) defaulting to today's `'EdgeVariables','mets'` behavior, and having it double as the shared helper. Rejected — FR-006 says the signature's "documented meaning" MUST NOT change either, and overloading the maintainer-facing, sanity-check-carrying function as the generic reusable primitive re-couples the two concerns R3 just separated.

## R6: FR-009 reproducibility check — placement and mechanics

**Decision**: A new, non-CI script `specs/021-prefilter-isomorphism-classification/tyrosineReproducibilityCheck.m` (Spec Kit feature artifact, Principle IX) that:
1. Loads the Tyrosine metabolism subsystem model/RXN files from the paths in the spec's Assumptions section (adjusted at run time if unavailable, per that same section).
2. Runs the pipeline, capturing `moietyFormulas`, `moietyGraphs`, `moietyVectors`, the total `isisomorphic` call count (via a counting wrapper or `dbstop`-free instrumentation — see below), and wall-clock time for the classification step.
3. BEFORE this feature's code change: saves that capture as a golden snapshot file, `specs/021-prefilter-isomorphism-classification/tyrosine-golden-snapshot.mat`.
4. AFTER the change: re-runs and asserts structural equality against the snapshot (`isequal`/`isequaln` on the three outputs, tolerant of any solver-order nondeterminism already tolerated by `testConservedReactingMoieties.m`), and prints/records the before/after `isisomorphic` call counts and wall-clock time to `specs/021-prefilter-isomorphism-classification/tyrosine-reproducibility-results.md`.

**Call-count instrumentation**: MATLAB has no built-in per-call counter for a base function. Use a `persistent`-counter wrapper only inside `classifySubgraphIsomorphism.m` itself (increment immediately before each real `isisomorphic(...)` invocation, i.e. only for pairs that pass the invariant pre-filter) exposed via a `nargout`-gated 4th output or a `clear`-resettable `persistent` accessor (e.g. `classifySubgraphIsomorphism('resetCallCount')` / a sibling tiny accessor). This keeps the counting mechanism inside the one file that owns the only remaining `isisomorphic(` loop (SC-006), rather than instrumenting three call sites.

**Rationale**: Matches FR-009's three sub-requirements exactly; keeps the golden snapshot and results as versioned, human-readable feature artifacts (Principle IX: "Spec Kit artifact → specs/<feature>/"), not a `results/`-style regenerable/gitignored output, since the whole point is a persistent before/after comparison. Not placed under `test/` because it depends on external, non-repo model/RXN-file paths and has a multi-minute runtime (explicitly excluded from CI by Principle III's own reproducibility-check fallback clause).

**Alternatives considered**: Wrapping `isisomorphic` itself at the MATLAB path level (a shadowing function). Rejected — shadowing a Statistics/Graph-and-Network Toolbox built-in is fragile, would affect *every* caller in the session (including `identifyAtomEquivalenceClasses.m` and the unrelated `line 1020` single-pair check), and Principle VII-B/warning-visibility norms discourage silently intercepting built-ins.
