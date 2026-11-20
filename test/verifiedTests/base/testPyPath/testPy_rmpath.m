% The COBRAToolbox: testPy_rmpath.m
%
% Purpose:
%     - py_rmpath(directory, MATLAB_too) removes a folder from the module search path
%       (sys.path) of the Python interpreter that MATLAB controls (and, optionally, from the
%       MATLAB path) and returns the updated sys.path. Quarantined: no behaviour of py_rmpath
%       is asserted until the defect below is fixed.
%
% Function under test:
%     src/base/io/python/pyPath/py_rmpath.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would need MATLAB's Python interface (python3) and
%     would restore sys.path and the MATLAB path afterwards.
%
% Coverage exemptions:
%     every line - py_rmpath is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: MATLAB_too = true always raises an error
%       SEVERITY: error
%       TRIGGER: d = tempname; mkdir(d); sp = py.sys.path; sp.insert(int64(0), d);
%         py_rmpath(d, true)
%       OBSERVED: error "Undefined function 'rnpath' for input arguments of type 'char'." on
%         line 48 (rnpath is a misspelling of rmpath); the folder has already been removed from
%         sys.path, the MATLAB path is not changed and no output is returned
%       EXPECTED: the folder removed from sys.path and from the MATLAB path, as the help text
%         says ("If true (or 1), directory will also be removed from the MATLAB path")
%       LINES: 47-48
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPy_rmpath'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
