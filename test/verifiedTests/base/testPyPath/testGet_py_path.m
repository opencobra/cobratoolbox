% The COBRAToolbox: testGet_py_path.m
%
% Purpose:
%     - get_py_path() returns Python's module search path (sys.path) of the interpreter that
%       MATLAB controls, as a column cell array of char. This test compares the result with
%       sys.path read independently (its length and its entries joined by Python itself), checks
%       that a folder inserted at the front of sys.path appears first, and restores sys.path
%       afterwards (and stops the out-of-process interpreter if the test started it).
%
% Function under test:
%     src/base/io/python/pyPath/get_py_path.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; needs MATLAB's Python interface with a Python 3 interpreter
%     (declared as the required software python3).
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGet_py_path'));
cd(fileDir);

% declare the requirements of this test: a Python 3 interpreter for MATLAB's Python interface
prepareTest('requiredSoftwares', {'python3'});

% remember whether Python was already running, and its search path, to restore both at the end
pythonEnvironment = pyenv;
pythonWasLoaded = string(pythonEnvironment.Status) == "Loaded";
sysPathBefore = cellfun(@char, cell(py.sys.path), 'UniformOutput', false);

%% the result is sys.path as a column cell array of char

pyPath = get_py_path();
assert(iscell(pyPath) && iscolumn(pyPath) && all(cellfun(@ischar, pyPath)));
% same number of entries as Python reports
assert(numel(pyPath) == double(py.len(py.sys.path)));
% same entries, in order: Python joins them with a separator that occurs in none of them
separator = char(10);
joined = char(py.str(separator).join(py.sys.path));
assert(isequal(pyPath(:)', strsplit(joined, separator, 'CollapseDelimiters', false)));

%% a folder inserted at the front of sys.path is the first entry

testFolder = tempname;
sysPath = py.sys.path;
sysPath.insert(int64(0), testFolder);
pyPath = get_py_path();
assert(strcmp(pyPath{1}, testFolder));
assert(numel(pyPath) == numel(sysPathBefore) + 1);

% restore sys.path (same list object, emptied and refilled), Python's state, and the directory
sysPath.clear();
for i = 1:numel(sysPathBefore)
    sysPath.append(sysPathBefore{i});
end
assert(isequal(get_py_path(), sysPathBefore(:)));
clear sysPath
if ~pythonWasLoaded && string(pythonEnvironment.ExecutionMode) == "OutOfProcess"
    terminate(pyenv);
end
cd(currentDir)
