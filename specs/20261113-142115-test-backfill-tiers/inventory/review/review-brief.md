# Independent review brief (T021, research R9)

You are an independent reviewer of tests written for the COBRA Toolbox (MATLAB). Work from the
repository root. You get only code and tests: read the test files named in your list and the
source files they test (and any source those call). Do not read the campaign's ledger, results,
waves, confirmations or quarantine lists under `specs/20261113-142115-test-backfill-tiers/inventory/`
(other than this brief and your own list), and do not read `test/known-defects.md`: your view must
not be anchored on the writers' or the lead's conclusions.

Read-only: never edit `src/`, any test, or git state; do not start MATLAB (reading only; several
reviewers run at once on a machine with limited memory). Write only your own output file.

## Severity rule (the campaign's rule; judge entries against it)

- A documented input, option or argument that fails when used: `error` or `unusable-option`.
- Behaviour that contradicts the documented result, or the code's evident intent (stated in a
  comment, or in handling code that is never reached), on a valid input: `wrong-result`.
- Documentation that misdescribes something without changing what a caller gets: `cosmetic`.
- An input the documentation does not allow: `limitation` (or no defect).
- `error`, `unusable-option` and `wrong-result` quarantine the function; `cosmetic` and
  `limitation` do not.

The test-file layout and the header defect entries are described in
`specs/20261113-142115-test-backfill-tiers/contracts/test-file.md`.

## Quarantine lists (`quarantine-N.txt`)

Each line is `test|source`. The test is in quarantine layout: its header records the defects of the
source function, and it asserts nothing. For every defect entry in the header decide, by reading the
source:

- `AGREE`: the code does what the entry says, and the severity follows the rule.
- `SEVERITY:<severity>`: the behaviour is real but the rule gives another severity (say which and why).
- `NOT-A-DEFECT`: the code does not behave as described, or the behaviour is what the documentation
  says, or the trigger is not a valid call.
- `UNCLEAR`: it cannot be decided by reading (say what would decide it).

Also say whether at least one entry that quarantines (error, unusable-option, wrong-result) is
`AGREE`: if none is, the function should not be quarantined.

Output `specs/20261113-142115-test-backfill-tiers/inventory/review/quarantine-N.jsonl`, one JSON line
per test:
`{"file": src path, "test": test path, "entries": [{"title": entry title, "severity": as written,
"verdict": "AGREE" | "SEVERITY:<x>" | "NOT-A-DEFECT" | "UNCLEAR", "why": one or two sentences with
line numbers}], "quarantine_supported": true|false, "notes": ""}`

## Tested sample (`tested-sample.txt`)

Each line is `test|source`; the test asserts the function's behaviour. For each, judge:

- Are the expected values independent of the function under test (worked out by hand, from a
  documented example, or by another method), not copied from its own output?
- Do the assertions check what the header documents, including the edge cases the code handles?
- Is any recorded non-quarantining defect (cosmetic, limitation) in fact a quarantining one by the
  rule above?
- Anything wrong: an assertion that would pass for a broken function, a tolerance too loose to
  mean anything, a fixture that hides the behaviour.

Output `specs/20261113-142115-test-backfill-tiers/inventory/review/tested-sample.jsonl`, one JSON line
per test: `{"file", "test", "verdict": "OK" | "WEAK" | "WRONG", "independent_oracle": true|false,
"missed_quarantine": "" or the entry that should quarantine, "why": "", "suggestion": ""}`

Final message: at most 10 lines: counts by verdict, then every non-AGREE / non-OK item in one line each.
