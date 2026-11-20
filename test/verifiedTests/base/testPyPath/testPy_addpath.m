% The COBRAToolbox: testPy_addpath.m
%
% Purpose:
%     - py_addpath(directory, MATLAB_too) adds a folder to the module search path (sys.path) of
%       the Python interpreter that MATLAB controls (and, optionally, to the MATLAB path) and
%       returns the updated sys.path. Quarantined: no behaviour of py_addpath is asserted until
%       the defects below are fixed.
%
% Function under test:
%     src/base/io/python/pyPath/py_addpath.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would need MATLAB's Python interface (python3) and
%     would restore sys.path and the MATLAB path afterwards.
%
% Coverage exemptions:
%     every line - py_addpath is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The empty input adds the current folder to the Python path
%       SEVERITY: wrong-result
%       TRIGGER: d = tempname; mkdir(d); cd(d); p = py_addpath('')
%       OBSERVED: sys.path gains d as its second entry (probe output: "after py_addpath(''):
%         added = <d>"); exist('', 'dir') is 0, so line 63 replaces '' with
%         py.os.path.abspath(''), the current folder, which lines 67-69 insert
%       EXPECTED: the help text: "to get this output without updating the Python path, use an
%         empty string as the input: py_path = py_addpath('')" - sys.path unchanged
%       LINES: 62-63, 67-69
%     - DEFECT: A relative folder is added as given, not converted to an absolute path
%       SEVERITY: wrong-result
%       TRIGGER: d = tempname; mkdir(fullfile(d, 'sub')); cd(d); p = py_addpath('sub')
%       OBSERVED: the entry 'sub' is added ("after py_addpath('sub'): added = sub"); Python
%         resolves it against its working folder, which follows MATLAB's cd, so the folder is
%         lost after a change of directory. exist('sub', 'dir') is 7, so the conversion on line
%         63 is skipped for every existing folder
%       EXPECTED: the absolute path fullfile(d, 'sub'), as the comment on line 61 ("Convert
%         relative path to absolute path") states
%       LINES: 62-63
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPy_addpath'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
