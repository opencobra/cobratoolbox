% The COBRAToolbox: testComparePaths.m
%
% Purpose:
%     - comparePaths(NAME, printLevel) splits an environment variable as the system shell sees
%       it (echo $NAME) and as MATLAB sees it (getenv), or, for NAME = 'PYTHON', the module
%       search path of the system python and of MATLAB's Python interface, and returns the
%       entries common to both and the entries found only on one side. This test uses
%       environment variables it sets itself (restored at the end): equal entries, an entry
%       with two blanks (the shell collapses them, so the two sides differ), an unset variable,
%       all print levels, and the PYTHON comparison checked against sys.path read independently
%       from the system python and from MATLAB.
%
% Function under test:
%     src/base/paths/comparePaths.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; needs the system program python and MATLAB's Python
%     interface (python3), declared as required software.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Python path entries with blanks are reported as differences
%       SEVERITY: limitation
%       TRIGGER: setenv('PYTHONPATH', fullfile(d, 'a b')) before MATLAB's Python starts, then
%         comparePaths('PYTHON')
%       OBSERVED: system_not_matlab = {'<d>/ab'} and matlab_not_system = {'<d>/a b', ...}; line
%         39 deletes every blank of the system entries (meant for the blanks after the commas
%         of the printed list), and lines 32-40 also split entries that contain a comma or quote
%       EXPECTED: the entry '<d>/a b' common to both sides
%       LINES: 32-40
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testComparePaths'));
cd(fileDir);

% declare the requirements of this test: the system program python (called by comparePaths)
% and a Python 3 interpreter for MATLAB's Python interface
prepareTest('requiredSoftwares', {'python', 'python3'});

% names of the environment variables used by the test (not set before it)
testVariable = 'COBRA_TEST_COMPAREPATHS';
unsetVariable = 'COBRA_TEST_COMPAREPATHS_UNSET';
assert(isempty(getenv(testVariable)) && isempty(getenv(unsetVariable)));

%% the same entries on both sides are common; blanks around entries are removed

setenv(testVariable, '/opt/a: /opt/b :/opt/c');
[common, systemNotMatlab, matlabNotSystem] = comparePaths(testVariable);
% intersect returns the entries sorted, as a column
assert(isequal(common, {'/opt/a'; '/opt/b'; '/opt/c'}));
assert(isempty(systemNotMatlab) && isempty(matlabNotSystem));
% printLevel 1 prints that there are no differences (both "No ..." messages)
[common, systemNotMatlab, matlabNotSystem] = comparePaths(testVariable, 1);
assert(numel(common) == 3 && isempty(systemNotMatlab) && isempty(matlabNotSystem));

%% an entry with two blanks: the shell collapses them, so the two sides differ

% the unquoted echo $NAME splits '/opt/b  c' into two words and prints them with one blank
setenv(testVariable, '/opt/a:/opt/b  c');
[common, systemNotMatlab, matlabNotSystem] = comparePaths(testVariable, 2);
assert(isequal(common, {'/opt/a'}));
assert(isequal(systemNotMatlab, {'/opt/b c'}));
assert(isequal(matlabNotSystem, {'/opt/b  c'}));
% printLevel 1 lists the differences
[~, systemNotMatlab, matlabNotSystem] = comparePaths(testVariable, 1);
assert(numel(systemNotMatlab) == 1 && numel(matlabNotSystem) == 1);
% remove the variable again
unsetenv(testVariable);

%% an unset variable: one empty entry on each side, common to both

[common, systemNotMatlab, matlabNotSystem] = comparePaths(unsetVariable);
assert(numel(common) == 1 && isempty(common{1}));
assert(isempty(systemNotMatlab) && isempty(matlabNotSystem));

%% PYTHON: the module search paths of the system python and of MATLAB's Python

% remember whether MATLAB's Python was already running, to stop it again at the end
pythonEnvironment = pyenv;
pythonWasLoaded = string(pythonEnvironment.Status) == "Loaded";
sysPathBefore = cellfun(@char, cell(py.sys.path), 'UniformOutput', false);

[common, systemNotMatlab, matlabNotSystem] = comparePaths('PYTHON', 2);
% the system python's sys.path, one entry per line (the first entry of python -c is '')
[status, systemOutput] = system('python -c "import sys; print(chr(10).join(sys.path))"');
assert(status == 0);
systemPath = strsplit(regexprep(systemOutput, '\n$', ''), newline, 'CollapseDelimiters', false);
matlabPath = cellfun(@char, cell(py.sys.path), 'UniformOutput', false);
% entries without blanks, commas or quotes are compared exactly (see the known defect)
assert(~any(contains([systemPath, matlabPath], {' ', ',', ''''})));
assert(isequal(sort(common(:)), sort(intersect(systemPath, matlabPath)')));
assert(isequal(sort(systemNotMatlab(:)), sort(setdiff(systemPath, matlabPath)')));
assert(isequal(sort(matlabNotSystem(:)), sort(setdiff(matlabPath, systemPath)')));
% the comparison does not change MATLAB's Python path
assert(isequal(matlabPath, sysPathBefore));
if ~pythonWasLoaded && string(pythonEnvironment.ExecutionMode) == "OutOfProcess"
    terminate(pyenv);
end

% change the directory
cd(currentDir)
