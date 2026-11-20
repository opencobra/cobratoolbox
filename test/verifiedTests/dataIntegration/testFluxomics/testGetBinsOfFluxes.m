% The COBRAToolbox: testGetBinsOfFluxes.m
%
% Purpose:
%     - getBinsOfFluxes splits the columns of samp.points (flux samples) into bins of
%       numfluxes samples or into numbins bins and returns them in output.samps. The function
%       is quarantined for the defect below: every call with at least 200 samples, the only
%       input it processes, stops with an error before returning. This file only opens the
%       test; it asserts nothing about the function.
%
% Function under test:
%     src/dataIntegration/fluxomics/getBinsOfFluxes.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver.
%
% Coverage exemptions:
%     every line - getBinsOfFluxes is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Every call with at least 200 samples stops with an error instead of returning
%         the bins
%       SEVERITY: error
%       TRIGGER: samp.points = reshape(1:1200, 3, 400); getBinsOfFluxes(samp, 100, 2) (also
%         getBinsOfFluxes(samp, [], 3))
%       OBSERVED: (R2025a, 2026-11-15) after printing the bins, "Unable to perform assignment
%         because dot indexing is not supported for variables of this type."
%         (MATLAB:structAssToNonStruct) at line 142: output is initialised as the number 0 at
%         line 21 and line 142 assigns the field samps to it
%       EXPECTED: output.samps, a struct array with one element per bin holding the points of
%         that bin
%       LINES: 21, 142
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetBinsOfFluxes'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
