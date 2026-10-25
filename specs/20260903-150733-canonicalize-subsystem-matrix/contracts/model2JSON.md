# Contract: `model2JSON` multi-subsystem serialization

**Feature**: 20260903-150733-canonicalize-subsystem-matrix
**Public function (unchanged signature)**: `src/base/io/json/model2JSON.m` — `model2JSON(model, fileName)`
**Spec linkage**: US1, FR-001, FR-002, SC-001

## Public call surface

No signature change. `model2JSON(model, fileName)` continues to take the same two required arguments and write the same `.json` file (extension auto-appended if omitted, unchanged).

## Behavioural contract

1. For a reaction whose `model.subSystems{i}` is a cell array naming more than one subsystem, the emitted JSON object for that reaction's `"subsystem"` key MUST represent every name in that cell array — not only the first (research.md R3 confirms today's output silently keeps only `a{1}`).
2. For a reaction whose `model.subSystems{i}` is a plain `char`, or a `1x1` cell (single subsystem, either legacy shape), the emitted JSON for that reaction MUST be byte-for-byte identical to today's output — i.e., the existing `try` branch's single-string behavior for the common case is not touched.
3. Nothing else in `model2JSON`'s output (reaction fields other than `"subsystem"`, metabolite fields, model-level fields) changes.

## Out of scope

- The exact JSON representation for "more than one name" (e.g. a JSON array vs a delimited string) is an implementation decision for `/speckit-tasks`; the contract only requires that no name is dropped and the result is valid JSON parseable back into a list of names for that reaction.
- `model2xls.m`/`xls2model.m` are unaffected (spec: explicitly out of scope) — they already round-trip multi-subsystem reactions via `;`-joined strings.
