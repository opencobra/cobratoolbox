# Benchmark and differential harness

Used to produce the numbers in ../research.md. Paths inside the scripts point at the maintainer's
machine (models of the ReconXKG repository, the toolbox clone); change them to reproduce.

- `stageRun.m`, `runChain.sh`: one extraction stage per MATLAB process under a 24 GB cap
  (`systemd-run --user --scope -p MemoryMax=24G`), peak memory from `VmHWM`.
- `profRun.m`: MATLAB profiler around one stage.
- `diffDup.m`, `diffRFE.m`: old and new implementation side by side (`ref/` holds the unmodified
  functions renamed `...Ref`) on randomised models and on stored models; all outputs compared
  with `isequaln`.
- `runTest.m`, `covReport.py`: run a test script and list the source lines it did not execute.
