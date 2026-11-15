% The COBRAToolbox: testInitPythonEnvironment.m
%
% Purpose:
%     - initPythonEnvironment(environmentName, reset) cleans the PATH and LD_LIBRARY_PATH
%       variables of Anaconda environment entries, finds the Python executable of the
%       requested environment (CPython3 by default, CPython2 or an Anaconda environment),
%       checks its version and loads it with pyenv (OutOfProcess). The function is
%       QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns): the
%       version check of the default environment CPython3 accepts only Python 3.6, 3.7 and
%       3.8, so the default option fails with every Python that current MATLAB releases
%       support (defect below); no assertion about the function is made.
%
% Function under test:
%     src/base/io/python/initPythonEnvironment.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would need python3 and would load it with pyenv
%     (which cannot be undone in a MATLAB session once Python is loaded).
%
% Coverage exemptions:
%     every line - initPythonEnvironment is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The default environment CPython3 rejects every Python newer than 3.8
%       SEVERITY: unusable-option
%       TRIGGER: initPythonEnvironment() with python3 3.12.3 on the system path (MATLAB R2025a)
%       OBSERVED: error "MATLAB >=R2020b is only stated to be compatible with Python
%         3.6,3.7,3.8" at line 123; in the same session pyenv('Version', <which python3>,
%         'ExecutionMode', 'OutOfProcess') loads that Python 3.12 and py.sys.version
%         returns "3.12.3 ...". The test of line 120 is contains(response, '3.6') ||
%         '3.7' || '3.8' on the output of python3 --version
%       EXPECTED: the Python versions supported by the running MATLAB are accepted (R2025a
%         supports 3.9 to 3.12, R2023b and later no longer support 3.8), so the default
%         option can load Python
%       LINES: 119-124
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testInitPythonEnvironment'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
