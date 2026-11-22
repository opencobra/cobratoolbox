# Quickstart: validating the back-fill

Prerequisites: MATLAB R2025a with the COBRA Toolbox initialised, Gurobi, Python 3; MATLAB is
started only through the memory-capped wrapper used on the reference machine. Run from the
repository root; `F=specs/20261113-142115-test-backfill-tiers`.

1. **Inventory is reproducible**

   ```
   matlab -batch "addpath('$F/tools'); dumpCallGraph(pwd, '$F/inventory/callgraph-raw.tsv')"
   python3 $F/tools/build_inventory.py . $F
   ```

   Expected: "untested: 1085" on 5200aad48 and a ledger with one row per untested file
   (on a later base the numbers drop by the files tested in this feature).

2. **Every row is final** (SC-001)

   ```
   cut -f4 $F/inventory/ledger.tsv | sort | uniq -c
   ```

   Expected: no `PENDING`.

3. **New tests pass with complete coverage** (SC-002): run the TESTED and QUARANTINED rows' tests
   with `tools/measureCoverage.m` (list file `<test>|<source>` per line). Expected: every record
   `passed`, and every uncovered line listed under "Coverage exemptions" of its test.

4. **Quarantine is consistent** (SC-003): `python3 $F/tools/update_ledger.py --check` reports, for
   every BLOCKED row, a QUARANTINED function it reaches, and for every QUARANTINED row a defect entry;
   `python3 .github/scripts/known_defects.py` regenerates `test/known-defects.md` with no diff.

5. **No source change** (SC-004): `git diff --name-only upstream/develop... -- src` is empty.

6. **Full suite** (SC-005): run the whole suite once (runTestSuite); failures are compared with the
   base commit's.

7. **Summary** (SC-006): `$F/inventory/summary.md` lists counts by status and tier, the quarantine
   ranking, exclusions by reason, and coverage before and after.
