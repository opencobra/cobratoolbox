# iDopaNeuroC Reproducibility Check — Expected Output

**Task**: T043 | **Discharges**: SC-005 | **Recorded**: 2026-09-15
**Script**: [iDopaNeuroCReproducibilityCheck.m](./iDopaNeuroCReproducibilityCheck.m)

## Why this is not a CI test

The model lives at `papers/2023_iDopaNeuro/models/iDopaNeuroC.mat`, and `papers` is a
**git submodule** whose initialisation is gated during toolbox initialisation, so it
cannot be relied upon to be present in CI. SC-011 forbids the CI-resident test from
depending on submodule content. Constitution Principle III sanctions a documented
reproducibility check where full automation is not practical and requires the reason for
deferral to be stated; the reason is stated here and in the script's own header.

## How to run it

```matlab
git submodule update --init papers        % shell, once
initCobraToolbox(false)
addpath('specs/20260914-204640-greedy-left-nullspace-conditioning')
results = iDopaNeuroCReproducibilityCheck();
```

## Expected output, as measured

```text
iDopaNeuroC reproducibility check (SC-005)
  solver gurobi, seed 20260914, 1 replicate
  operative matrix        1244 x 1710
  outcome / regime        incomplete / wellScaled (timeBudget)
  sigmaMinPlus / boundary 2.8382e-02 / 5.2837e-06
  accuracy target         1.1928e-12
  residual abs / scaled   1.1852e-16 / 1.7068e-19
  rays found / expected   101 / 105
  zero rows returned      0
  row count == raysFound  1
  non-negative            1
  runtime                 180.0 s
  VERDICT: PASS (basis meets the derived accuracy target)
```

## Reading it

**SC-005 is discharged.** The requirement was that iDopaNeuroC either yield a basis
giving the augmented matrix an unambiguous rank, or return the bad-scaling diagnosis —
and that silently returning a basis with the pre-change accuracy is not acceptable. It
takes the first branch: the returned basis clears the derived accuracy target by roughly
four orders of magnitude (1.185e-16 against 1.193e-12).

What is and is not promised by this record:

- **`wellScaled` is a measurement, not a prediction.** sigmaMinPlus sits 5372x above the
  boundary. The seed's own evidence did not settle which regime this model was in, and
  this is the answer, not an assumption that preceded the work.
- **`incomplete` at 101 of 105 is expected and honest.** The basis is trimmed to the 101
  rays actually accepted, with zero all-zero padding rows, so the row count cannot be
  mistaken for a complete basis. Before this feature the same run returned 105 rows of
  which 4 were padding.
- **The 101 is not a defect of this check.** Restarting from fresh randomness nine times
  reaches the same 101 (see `measurements/results.md` section 6), so the shortfall is
  structural rather than a stochastic dead end. Whether `raysExpected = 105` was ever
  reachable by NON-NEGATIVE rays is an open question, recorded as the next thing to
  measure. `status.raysExpectedIsEstimate` is always true for exactly this reason.
- **Runtime is reported, not promised.** 180.0 s is the total budget the check sets, not
  a performance claim; the run uses all of it because it is still searching when the
  budget expires.
- **Solver dependence matters here.** This record is gurobi. Under mosek the assembled
  residual was measured at 9.342e-09, which does NOT meet the 1.193e-12 target, so mosek
  would report accuracy rejections instead. That is the headline finding of the feature
  and is not a fault in this check.

A `FAIL` verdict would mean a basis was returned that misses the derived accuracy
target — the precise defect this feature exists to make impossible.
