# Quickstart: validating the Tier-2 safe batch

1. From `test/`: `runScriptFile('<test path>')` → `passed`.
2. Line coverage with the throwaway runner → 100% or every missed line in the header.
3. Spy run: `addpath('<scratch>/solverSpies','-begin')` after `initCobraToolbox(false)`, run the
   test → passes (no solver reached); `rmpath` afterwards.
4. `python3 .github/scripts/known_defects.py` exits 0; `git diff --name-only <base> -- src` empty.
