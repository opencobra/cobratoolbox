% The COBRAToolbox: testSetResultPath.m
%
% Purpose:
%     - setResultPath returns (and creates if missing) the folder Results_<name> next to
%       the flux solution folder <parent>/<name>. The function is QUARANTINED (Constitution
%       III-Defects, quarantine in back-fill campaigns): on Linux and macOS the folder is
%       placed at the file-system root (defect below), so no assertion about the function is
%       made.
%
% Function under test:
%     src/analysis/persephone/additionalFunctions/setResultPath.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use a temporary folder.
%
% Coverage exemptions:
%     every line - setResultPath is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: On Linux and macOS the results folder is placed at the file-system root
%       SEVERITY: error
%       TRIGGER: on Linux: setResultPath(fullfile(tempname, 'sol'))
%       OBSERVED: prints 'Create new folder:/Results_sol' and stops with 'Permission denied'
%         (setResultPath:27); the non-Windows branch (line 19) looks for the text before the
%         last backslash, which a path with '/' separators does not have, so the parent
%         folder is empty
%       EXPECTED: the folder <tempname>/Results_sol is created and returned
%       LINES: 19
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSetResultPath'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
