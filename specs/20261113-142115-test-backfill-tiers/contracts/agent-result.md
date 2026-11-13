# Contract: result record of a helper agent

Each helper agent receives a slice of ≤ 10 ledger rows of one wave and returns one JSON line per
row in `inventory/results/wave<NN>-<slice>.jsonl`:

```json
{"file": "src/<path>/<name>.m",
 "status": "TESTED | QUARANTINED | EXCLUDED",
 "tier": 1,
 "test": "test/verifiedTests/<...>/test<Name>.m",
 "lines": 54, "missed": [207, 208], "exempt": [207, 208],
 "passed": true,
 "defects": [{"title": "...", "severity": "wrong-result", "trigger": "...",
              "observed": "...", "expected": "...", "lines": "12-14", "quarantine": true}],
 "reason": "for EXCLUDED: why",
 "extra_edges": ["src/<path>/<callee>.m"],
 "notes": "anything the lead must know"}
```

Rules:

- `TESTED` requires `passed: true` and `missed == exempt` (every uncovered line documented).
- `QUARANTINED` requires at least one defect with `quarantine: true` and a test file in the
  quarantine layout (`contracts/test-file.md`).
- A defect with severity `cosmetic` or `limitation` has `quarantine: false` and leaves the row
  `TESTED`.
- `extra_edges` lists `src/` functions the agent found the function calls at run time that the
  ledger's callees do not list (R3).
- The agent does not change any `src/` file, any other test, the ledger, or git state.
