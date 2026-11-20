% The COBRAToolbox: testCleanFilesFastFVA.m
%
% Purpose:
%     - cleanFilesFastFVA(userInteraction) removes the log files (*.log) that fastFVA writes to
%       [CBTDIR]/src/analysis/FVA/fastFVA/logFiles, after asking the user (userInteraction =
%       true, the default) or without asking (userInteraction = false). The function is
%       quarantined (feature 20261113-142115-test-backfill-tiers): this file asserts nothing
%       about it until the defect below is fixed.
%
% Function under test:
%     src/analysis/FVA/fastFVA/cleanFilesFastFVA.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver (a temporary folder stands for CBTDIR when tested).
%
% Coverage exemptions:
%     every line — cleanFilesFastFVA is quarantined for the defect below (feature 20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: cleanFilesFastFVA(false) fails when there are log files to remove
%       SEVERITY: error
%       TRIGGER: cleanFilesFastFVA(false) with at least one *.log file in
%                [CBTDIR]/src/analysis/FVA/fastFVA/logFiles
%       OBSERVED: MATLAB 2026-11-13: after printing " Number of files in logFiles/: 1" the call
%                 stops with "Unrecognized function or variable 'm'." (MATLAB:UndefinedFunction)
%                 at line 39; the log file is not removed. m is assigned only by the input()
%                 prompt of line 36, which runs only when userInteraction is true, and line 39
%                 evaluates strcmpi(m, 'y') before ~userInteraction.
%       EXPECTED: all *.log files removed without a prompt and " >> All log files in logFiles/
%                 removed." printed (the documented meaning of userInteraction = false)
%       LINES: 35-43
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCleanFilesFastFVA'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
