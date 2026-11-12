# Benchmark and differential harness

Used to produce the numbers in ../research.md. The scripts find the toolbox clone and `ref/` from
their own location, and model files are passed as arguments. The `feasibility` stage also needs
`checkFeasibilityConditions` from the ReconXKG repository: set `COBRA_BENCH_EXTRA_CODE` to the folder
that holds it. Other stages do not need it.

- `stageRun.m`, `runChain.sh`: one extraction stage per MATLAB process under a 24 GB cap
  (`systemd-run --user --scope -p MemoryMax=24G`), peak memory from `VmHWM`.
- `profRun.m`: MATLAB profiler around one stage.
- `diffDup.m`, `diffRFE.m`: old and new implementation side by side (`ref/` holds the unmodified
  functions renamed `...Ref`) on randomised models and on stored models; all outputs compared
  with `isequaln`.
- `runTest.m`, `covReport.py`: run a test script and list the source lines it did not execute.
