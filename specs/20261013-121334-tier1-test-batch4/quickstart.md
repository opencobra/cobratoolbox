# Quickstart: validating batch 4

Prerequisites: MATLAB R2025a, `initCobraToolbox(false)`, repository root.

1. Run one test through the harness runner, from `test/`:
   `res = runScriptFile('<test path>'); disp(res.status)` (expect `passed`).
2. Measure line coverage of its function (throwaway runner, not committed) with the
   code-coverage plugin and read `<line hits=".." number="..">` entries.
3. Run the independent-section check: run the same file with `TestSuite.fromFile` and confirm
   no section fails.
4. Regenerate and check the defect registry: `python3 .github/scripts/known_defects.py`.
5. `git diff --stat -- src` prints nothing.
