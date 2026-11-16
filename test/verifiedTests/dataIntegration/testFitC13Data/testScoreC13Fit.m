% The COBRAToolbox: testScoreC13Fit.m
%
% Purpose:
%     - scoreC13Fit computes the theoretical mass distribution vectors of a flux vector (or of
%       null-space coordinates mapped to fluxes) with the cumomer or the EMU solver and returns
%       the sum of squared differences to the experimental data divided by std2^2. The function
%       is quarantined for the defect below: the documented input method is always
%       overwritten, so the cumomer method cannot be selected. This file only opens the test;
%       it asserts nothing about the function.
%
% Function under test:
%     src/dataIntegration/fluxomics/c13solver/scoreC13Fit.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - the documented inputs include a model structure (the isotopomer model of this
%     folder); no solver.
%
% Coverage exemptions:
%     every line - scoreC13Fit is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The input method is ignored, method 1 (cumomer) cannot be selected
%       SEVERITY: unusable-option
%       TRIGGER: with the fixtures of this folder, load('point.mat', 'v0'); load('model.mat',
%         'model'); load('expdata.mat', 'expdata'); expdata.inputfrag =
%         convertCarbonInput(expdata.input); scoreC13Fit(v0, expdata, model, [], 1)
%       OBSERVED: (R2025a, 2026-11-16) the test "if nargin < 6" is always true for a function
%         of five inputs, so method is set to 2 (EMU) on every call; the output for method = 1
%         is identical (isequal) to the output for the default, error 386.121954048192 in both
%         cases. The cumomer branch runs only as the fallback when the EMU result has NaN
%       EXPECTED: method = 1 uses slvrCumomer_fast with expdata.input (documented "method 1 =
%         cumomer, method 2 = CMU"); the default 2 applies only when method is not given
%       LINES: 50-52
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testScoreC13Fit'));
cd(fileDir);

% declare the requirements of this test. This test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
