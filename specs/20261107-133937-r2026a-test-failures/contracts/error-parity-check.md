# Contract: error-parity check in `testExtractBondSubgraphs` and `testClassifySubgraphIsomorphism`

The check is a local function in each test. It decides whether an error caught from the function under test is
the failure recorded in the R2024b fixture.

- **Inputs**: the caught `MException`, the recorded identifier and the recorded message.
- **Accept** if (identifier, message) equals the recorded pair, **or** equals an equivalence entry
  (data-model.md) registered for that recorded pair.
- **Reject** every other error. On rejection the test fails with the existing diagnostic: expected identifier and
  message, actual identifier, message, file and line.
- **No error raised**: unchanged; the test fails ("returned normally, but the pre-change function raised ...").
- **Self-check (SC-003)**: for each recorded error case, the test asserts that the check rejects (a) an error with
  a foreign identifier and (b) an error with the recorded identifier and a different message.
- **Fixtures**: read-only; none is re-recorded.
