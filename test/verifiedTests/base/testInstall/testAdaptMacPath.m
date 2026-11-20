% The COBRAToolbox: testAdaptMacPath.m
%
% Purpose:
%     - adaptMacPath() reads the macOS version from the output of `sw_vers` and puts
%       CBTDIR/binary/maci64/bin/preSierra on the MATLAB path for a Mac older than Sierra
%       (10.12), or when the version cannot be read, and postSierra otherwise, removing the
%       other folder. The function is QUARANTINED (Constitution III-Defects, quarantine in
%       back-fill campaigns): the version is converted with str2double and compared as a
%       decimal number, so the version strings of most pre-Sierra Macs select postSierra; no
%       assertion about the function is made.
%
% Function under test:
%     src/base/install/adaptMacPath.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would point CBTDIR to a temporary folder and put a
%     fake `sw_vers` first on the system PATH (needs a Unix shell).
%
% Coverage exemptions:
%     every line - adaptMacPath is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: pre-Sierra macOS versions with a patch number or a one-digit minor select postSierra
%       SEVERITY: wrong-result
%       TRIGGER: CBTDIR set to a temporary folder holding binary/maci64/bin/preSierra and
%         postSierra (both on the MATLAB path), a fake sw_vers first on PATH that prints
%         "ProductName:\tMac OS X\nProductVersion:\t10.11.6\nBuildVersion:\t15G31\n", then
%         adaptMacPath()
%       OBSERVED: (R2025a, 2026-11-15) postSierra on the path and preSierra removed for
%         ProductVersion 10.11.6, 10.9.5 and 10.9; preSierra only for 10.11. Line 20 gives
%         str2double('10.11.6') = NaN, and NaN < 10.12 is false; '10.9' becomes 10.9, which
%         is larger than 10.12 as a decimal number
%       EXPECTED: preSierra for every macOS version below 10.12 (the help text: "Sierra/High
%         Sierra or higher and Anything below"), e.g. 10.11.6 (the last El Capitan release)
%         and 10.9.5; the version should be compared component by component
%       LINES: 20-21
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAdaptMacPath'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
