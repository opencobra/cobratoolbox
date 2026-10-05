# Quickstart: validating label-only isomorphism classification

**Prerequisites**:
- MATLAB R2024b and `initCobraToolbox(false)`.
- The local 1,960-reaction captures:
  - `…/extractBondSubgraphsPeeling/n1960-inputs.mat`;
  - `…/extractBondSubgraphsPeeling/n1960-endToEnd-golden.mat`;
  - `…/conservedMoietyHotspots/n1960-identifyInputs.mat`.

Run scripts with absolute paths: `matlab -batch "initCobraToolbox(false); run('<absolute path>')"`. `FEATURE` below stands for `specs/20260930-102230-isomorphism-label-only-copies`.

## Step 1: Capture on the unchanged helper

Run `FEATURE/captureClassifyReference.m`.

**Expected**:
- It refuses to run if `classifySubgraphIsomorphism.m` differs from `f4a62639e`.
- It writes `test/.../data/classifySubgraphIsomorphismReference.mat`: random cases in three modes, error cases and call counts.
- It creates `FEATURE/baseline/classifySubgraphIsomorphism.m` as a verbatim copy.

## Step 2: Test on the unchanged helper

Run `runtests('testClassifySubgraphIsomorphism')`.

**Expected**: PASS.

## Step 3: Check-script self-check on the unchanged helper

Run `FEATURE/isomorphismLabelOnlyCheck.m` with `CBT_ILO_NO_TIMING=1`.

**Expected**:
- The component classification on the 1,960-reaction model is identical to the baseline helper, with 39,204 `isisomorphic` calls.
- The end-to-end 1,960-reaction outputs are identical to the golden.

## Step 4: After the edit

1. Repeat steps 2 and 3, and run `runtests('testConservedReactingMoieties')`.
   **Expected**: identical outputs and call count, with the classification ratio reported (research: 0.111).
2. Run the check with timing on.
   **Expected**: SC-003 median ratio ≤ 0.60 over 5 alternating runs; research projects 0.40–0.47.
3. Run `reactingOptimisationReproducibilityCheck.m` with `CBT_RMO_NO_TIMING_GATE=1`.
   **Expected**: 16/16 EQUAL.
4. Run all `testReactingMoieties` tests.
   **Expected**: PASS.

## Step 5: Static review

Run `git diff f4a62639e -- src/`.

**Expected**:
- Changes only in `classifySubgraphIsomorphism.m`: the invariant loop, the `isisomorphic` call, the local `labelOnlyCopy` and `NOTE`.
- No message changes.
