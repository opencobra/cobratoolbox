% The COBRAToolbox: testPrepareTest.m
%
% Purpose:
%     - prepareTest(varargin) checks the requirements a test declares (operating system,
%       toolboxes, solvers, installed programs, web access) and returns the solvers to use per
%       problem type, or raises COBRA:RequirementsNotMet. Quarantined: no behaviour of
%       prepareTest is asserted until the defect below is fixed. The opening below still calls
%       prepareTest() because it is the standard opening of every COBRA test.
%
% Function under test:
%     src/base/install/prepareTest.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would set the global solver state and the
%     CI_RUNTYPE / test-mode environment to hand-built values and restore them afterwards.
%
% Coverage exemptions:
%     every line - prepareTest is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: needsLinux makes every test skip on Linux
%       SEVERITY: unusable-option
%       TRIGGER: prepareTest('needsLinux', true) on a 64-bit Linux machine
%       OBSERVED: error COBRA:RequirementsNotMet "This test only works on Linux Systems"
%         although isunix is 1; computer('arch') returns 'glnxa64' (probe output: "isunix=1
%         arch=glnxa64"), and line 177 compares it with 'glnx64', so the check always fails
%       EXPECTED: no requirement error on Linux, as the help text says ("needsLinux: Whether
%         the test only works on a Linux system")
%       LINES: 177-179
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPrepareTest'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
