# Quickstart: validating the Tier-2 pilot

Prerequisites: MATLAB R2025a, `initCobraToolbox(false)`, repository root.

1. From `test/`: `res = runScriptFile('<test path>'); disp(res.status)` → `passed`.
2. Line coverage with a throwaway runner (code-coverage plugin, Cobertura) → 100% or every missed
   line listed in the header.
3. `python3 .github/scripts/known_defects.py` exits 0.
4. `git diff --name-only <base> -- src` prints nothing.
