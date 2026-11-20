% The COBRAToolbox: testCheckGAMSSolvers.m
%
% Purpose:
%     - checkGAMSSolvers returns the GAMS solvers that the licence of the local GAMS installation
%       allows for a problem type, from the table of getAvailableGAMSSolvers. The function is
%       QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns): a problem
%       type that GAMS does not list stops with an index error instead of returning an empty
%       cell, so no assertion about the function is made.
%
% Function under test:
%     src/base/solvers/gams/checkGAMSSolvers.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; GAMS is not installed on the reference machine, so a test
%     would replace gams and getAvailableGAMSSolvers by stubs on a temporary path.
%
% Coverage exemptions:
%     every line - checkGAMSSolvers is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A problem type that GAMS does not list stops with an index error
%       SEVERITY: error
%       TRIGGER: checkGAMSSolvers('MINLP') when getAvailableGAMSSolvers returns problem types
%         {'LP', 'MIP', 'NLP'} (stubs of gams and getAvailableGAMSSolvers on a temporary path)
%       OBSERVED: Index in position 2 is invalid. Array indices must be positive integers or
%         logical values. (MATLAB:badsubscript, line 50; R2025a, 2026-11-15): ismember returns
%         position 0, never an empty position, so line 49 is always true
%       EXPECTED: an empty cell array, the else branch of line 52
%       LINES: 48-52
%     - DEFECT: The existence of licememo.gms is never checked
%       SEVERITY: cosmetic
%       TRIGGER: any call with GAMS on the MATLAB path
%       OBSERVED: line 41 tests whether the concatenated path string is empty, which it never
%         is, so the error of line 42 cannot be raised
%       EXPECTED: the error licememo.gms in not in MATLAB path. when the file is missing
%       LINES: 41-42
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCheckGAMSSolvers'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
