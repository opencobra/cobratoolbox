# Quickstart: validating the safe Tier-1 defect fixes

Prerequisites: MATLAB R2025a, `initCobraToolbox(false)`, repository root.

1. Run one changed test through the harness runner, from `test/`:
   `res = runScriptFile('<test path>'); disp(res.status)` (expect `passed`).
2. Measure line coverage of its function with a throwaway runner (not committed) that runs the
   test with the code-coverage plugin and Cobertura output and reads `<line hits=".." number="..">`;
   report covered/total and the missed lines; it must be no lower than before the fix.
3. Check that the formerly skipped TRIGGER input is asserted and the fixed entry is gone from
   the header.
4. Regenerate the registry: `python3 .github/scripts/known_defects.py`; the count line must read
   28 known defects in 24 functions.
5. Scope check: `git diff --name-only upstream/develop -- src` lists only the 52 table-A files
   and none of the 24 table-B files.
6. Read `attention-defects.md`: one entry per table-B row and per new problem.
