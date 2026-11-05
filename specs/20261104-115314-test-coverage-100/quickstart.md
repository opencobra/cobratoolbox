# Quickstart
1. `cd test; matlab -batch "initCobraToolbox(false); changeCobraSolver('gurobi','all',0); addpath('<feature>/tools'); measureCoverage('<list>.txt','<out>.jsonl')"` with list lines `<test>|<source>`.
2. `python3 <feature>/tools/build_inventory.py` regenerates `coverage-inventory.md` from `coverage-runs/*.jsonl`.
3. For a changed test: re-measure it; status must be COMPLETE and the test must pass.
