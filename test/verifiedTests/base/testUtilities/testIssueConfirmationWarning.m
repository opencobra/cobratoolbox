% The COBRAToolbox: testIssueConfirmationWarning.m
%
% Purpose:
%     - issueConfirmationWarning issues the given message as a warning, with all warnings
%       switched on for the call and the warning state restored afterwards, and, according to
%       its help text, blocks execution until the user confirms. The function is QUARANTINED
%       (Constitution III-Defects, quarantine in back-fill campaigns): the confirmation is asked
%       only on a machine whose HOME contains 'jenkins' (the CI machine), the opposite of the
%       help text and of the comment in the code, so no assertion about the function is made.
%
% Function under test:
%     src/base/utilities/issueConfirmationWarning.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model and no solver; a test would call the function with a message string.
%
% Coverage exemptions:
%     every line - issueConfirmationWarning is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The confirmation is asked only on a jenkins home, the opposite of the documentation
%       SEVERITY: wrong-result
%       TRIGGER: any call, for example issueConfirmationWarning('probe message') on a machine
%         whose HOME does not contain 'jenkins'
%       OBSERVED: the warning is issued and the function returns at once without asking for
%         a confirmation; with HOME set to '/var/lib/jenkins' (setenv) it calls input and, in a
%         -batch session, stops with "Support for user input is required, which is not
%         available on this platform." (MATLAB:services:MissingRequiredCapability, line 22;
%         R2025a, 2026-11-15)
%       EXPECTED: as the help text ("blocks execution until confirmation by the user") and the
%         comment of line 21 ("stall only if we are NOT on jenkins! I.e. not on the CI") say,
%         ask for a confirmation outside jenkins and continue without asking on jenkins
%       LINES: 20-26
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testIssueConfirmationWarning'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
