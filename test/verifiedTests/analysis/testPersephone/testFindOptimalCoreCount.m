% The COBRAToolbox: testFindOptimalCoreCount.m
%
% Purpose:
%     - findOptimalCoreCount times the FBA (optimizeWBModel) of a random subset of the
%       whole-body models of a folder for several numbers of parallel workers: N, the
%       largest power of 2 not above the number of cores, models are drawn, and the worker
%       configurations are 1 followed by the cumulative products of the prime factors of N
%       (1, 2, 4, ..., N). It returns a table of per-model solve times (one column per
%       configuration) and a table of total, load-corrected and relative timings.
%       Quarantined: no behaviour of findOptimalCoreCount is asserted until the defect below
%       is fixed.
%
% Function under test:
%     src/analysis/persephone/additionalFunctions/findOptimalCoreCount.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - LP through optimizeWBModel (solver validated for the PSCM toolbox) on
%     stand-in models written to a temporary folder; Parallel Computing Toolbox.
%
% Coverage exemptions:
%     every line - findOptimalCoreCount is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The first worker configuration is timed on an automatically started pool of
%       the default size
%       SEVERITY: wrong-result
%       TRIGGER: findOptimalCoreCount(modelDir, 'gurobi') with no parallel pool open (the
%         state of a new MATLAB session; Parallel Computing Toolbox with the default
%         AutoCreate preference), modelDir holding N = 4 stand-in whole-body models (three
%         reactions, one coupling constraint), numWorkers = [1 2 4]
%       OBSERVED: (R2025a, gurobi, 2026-11-25) for numWorkers(1) = 1 getParallelPool returns
%         [] (no pool), so lines 88-97 open no pool and the parfor loop starts the default
%         pool of the profile (one worker per core, more than 1); the row Workers = 1 reports FBA
%         times 8.83 s (pool start-up included) against 0.71 s and 0.60 s for 2 and 4 workers,
%         and the relative speed-ups 13.36 and 16.04 follow from it
%       EXPECTED: each configuration timed on a pool of that many workers (a pool of 1 worker
%         opened for the first configuration when none is open), as the help describes
%         (timings for each tested worker configuration)
%       LINES: 87-97
%     - DEFECT: The pool object is printed for each new pool
%       SEVERITY: cosmetic
%       TRIGGER: the same call, for the configurations 2 and 4
%       OBSERVED: (R2025a, gurobi, 2026-11-25) the properties of the new pool ("Connected:
%         true", "NumWorkers: 2", ...) are printed: line 95 has no semicolon
%       EXPECTED: only the progress messages of the function
%       LINES: 95
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindOptimalCoreCount'));
cd(fileDir);

% declare the requirements of this test; nothing that calls findOptimalCoreCount runs while
% it is quarantined, so no solver or toolbox is required yet
prepareTest();

% change the directory
cd(currentDir)
