% The COBRAToolbox: testPerformRegressions.m
%
% Purpose:
%     - performRegressions stacks a flux (or relative abundance) table, joins it with the
%       metadata on ID, fits one regression per reaction (or taxon) with cobraFitglm (linear
%       or logistic, Firth-penalised from MATLAB 24.2 on) and returns one results table per
%       predictor with estimates, intervals, p-values, FDR and adjusted R2. The function is
%       QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns): the choice
%       of the Firth regression reads the version of the first listed product instead of
%       MATLAB (defect below), so no assertion about the function is made.
%
% Function under test:
%     src/analysis/persephone/performRegressions.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use hand-built tables of a few samples.
%
% Coverage exemptions:
%     every line - performRegressions is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The MATLAB version check reads the first product listed by ver
%       SEVERITY: wrong-result
%       TRIGGER: any call in a session where ver does not list MATLAB first, e.g. after
%         initCobraToolbox (MATLAB R2025a lists 'M2HTML Toolbox' version 1.5 first)
%       OBSERVED: matlabVersion(1) is 1.5, so firthRegression stays false and the logistic
%         fits are not penalised on R2025a; a perfectly separated reaction is then dropped
%         (warning in cobraFitglm, NaN row) instead of being fitted
%       EXPECTED: the version of MATLAB itself (ver('MATLAB')), so that R2024b and newer use
%         the Firth regression as the code comment states
%       LINES: 137-143
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPerformRegressions'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
