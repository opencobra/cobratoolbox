# Review resolution brief (T021: "fixes re-run")

You resolve findings of the independent review for a list of functions. Read
`specs/20261113-142115-test-backfill-tiers/inventory/agent-brief.md` first and follow its rules
(MATLAB only through the tools it names, one session of your own at a time, test-file contract,
quarantine layout, severity rule of research R5, privacy check). The finding for each function is in
`specs/20261113-142115-test-backfill-tiers/inventory/review/tested-sample.jsonl` (match on "file")
or in the lead's note in your prompt.

For each function on your list:

1. Reproduce the finding in MATLAB (a stand-in function or program in the test's own temporary
   folder is acceptable where a missing external program or another platform is the only obstacle).
   A finding you cannot reproduce is not a defect: say so in the record's notes.
2. Classify every confirmed behaviour by the severity rule. Add it to the test header as a defect
   entry (TRIGGER, OBSERVED with release and date, EXPECTED, LINES).
3. If a confirmed entry is `error`, `unusable-option` or `wrong-result`, the function is quarantined:
   convert its test to the quarantine layout (header entries, no assertions, every line exempt), and
   say in the notes which call forms reach the defect (an input form or call form recognisable in
   calling code) and which src/ callers use that form, so the lead can set the reach.
4. Otherwise keep the test TESTED and fix what the reviewer showed to be weak (an assertion copied
   from the function's own output, a fixture that hides the behaviour, a wrong expected value).
5. Run the test once with coverage as the agent brief says; it must pass and leave nothing behind.
6. Write one full result record per function (the format of contracts/agent-result.md, the same
   fields as a wave record) to the output file named in your prompt. Start "notes" with
   "independent review T021:".

Never edit src/, the ledger, other agents' files or git state. Final message: at most 12 lines,
one line per function (name: STATUS - short note), then the decisions the lead must take.
