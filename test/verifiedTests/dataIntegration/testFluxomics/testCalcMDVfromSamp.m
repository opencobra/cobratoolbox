% The COBRAToolbox: testCalcMDVfromSamp.m
%
% Purpose:
%     - calcMDVfromSamp solves the EMU network (slvrEMU_fast) for each sampled flux vector and
%       collects the mass distribution vectors of the measured fragments with their mean and
%       standard deviation. The function is quarantined for the defect below: a substrate
%       label distribution glc that is not empty, a documented input, stops with an error.
%       This file only opens the test; it asserts nothing about the function.
%
% Function under test:
%     src/dataIntegration/fluxomics/calcMDVfromSamp.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver.
%
% Coverage exemptions:
%     every line - calcMDVfromSamp is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A non-empty substrate label distribution glc stops with an error
%       SEVERITY: error
%       TRIGGER: with the fixtures of testFitC13Data, load('point.mat', 'v0');
%         load('expdata.mat', 'expdata'); calcMDVfromSamp(expdata.input, [v0 v0], expdata)
%       OBSERVED: (R2025a, 2026-11-15) "Undefined function 'convert_input' for input arguments
%         of type 'double'." (MATLAB:UndefinedFunction) at line 34; no function convert_input
%         exists in the toolbox, so every call with a non-empty glc fails; an empty experiment
%         needs a non-empty glc, so the branches for an empty experiment cannot run either
%       EXPECTED: glc converted to the fragment label input of slvrEMU_fast (as
%         convertCarbonInput does) and the MDVs of every sample returned
%       LINES: 34, 37-38, 54-57, 68
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCalcMDVfromSamp'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
