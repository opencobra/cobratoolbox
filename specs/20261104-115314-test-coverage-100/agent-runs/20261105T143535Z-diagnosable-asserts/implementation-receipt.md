# Implementation receipt: diagnosable failures in testCreateMetIntrcNetwork

## Prompt

> just make the assertions more vocal, that when they through an error we can see what is the
> error it can aslo report the expected output and the real one so that we see why they are not
> the same

> /speckit-implement. and yes push when you're done

## Final response

**The asserts in `testCreateMetIntrcNetwork.m` now report expected and actual values, and the change is pushed to PR #2722, so CI is rerunning it.** If the test fails again, its report should name the failing check instead of saying only `Assertion failed.`. For example, from a copy I broke on purpose:

```
threshold 0: expected 16 edge widths, got 17 (graph plots found: 1)
```

- **All 20 asserts are covered:** a parser confirmed that every condition is unchanged, so this adds information without changing what the test checks.
- **Real errors are shown:** the three expected-error checks now also report the error actually thrown, using a small helper at the end of the test.
- **Checks here:** the real test passes. A copy that forced every assert to fail printed all 20 messages, and a copy with wrong expected values showed the mismatches.

This doesn't fix the CI failure; it should tell us why it happens. The commit also has the spec, plan, tasks and receipt, under your name with no co-author line.

I'm watching PR #2722 and will tell you which check failed as soon as the CI bot posts its result.

## Diff summary

- `test/verifiedTests/visualization/testCreateMetIntrcNetwork/testCreateMetIntrcNetwork.m`: failure
  messages on all 20 assertions; local function `thrownMessage` at the end of the file. Line endings
  stay CRLF.
- `specs/20261104-115314-test-coverage-100/spec.md`: FR-009, SC-005.
- `specs/20261104-115314-test-coverage-100/plan.md`: addendum for FR-009.
- `specs/20261104-115314-test-coverage-100/tasks.md`: Phase 5, T100 to T103.
- This receipt.

No file under `src/` changed, and `test/verifyCobraFunctionError.m` did not change.

## Tests

- Conditions: a parser compared the first argument of every assertion before and after: 20 and 20,
  identical.
- `testCreateMetIntrcNetwork` through `runScriptFile`, invisible figures, `-noFigureWindows`, no
  display, MATLAB R2025a: passed.
- Throwaway copy (not committed) in which every assertion is forced to fail through the real
  `assert`: 20 of 20 messages printed, formatted correctly, none read as an error identifier.
- Throwaway copy (not committed) with wrong expected values: 5 assertions failed. Two showed
  differing values (edge weight, edge width count). Three show matching text, because the copy
  changed only the condition and not the expected text in the message.
- SC-005 is met on these two copies together.

## Unresolved issues

- The CI failure of this test on PR #2722 is not fixed and its cause is unknown. This change only
  makes it diagnosable. The test has not reproduced the failure on the reference machine, alone or
  in a partial CI-order run, which stopped at `testOptForce` for lack of memory and did not reach
  this test.
- Only this test gained messages; the other tests keep their current assertions.
- `CLAUDE.md` and `AGENTS.md` name a different override phrase from the constitution.
