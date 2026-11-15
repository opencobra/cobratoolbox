% The COBRAToolbox: testCOBRArrowSolver.m
%
% Purpose:
%     - COBRArrowSolver holds the name of a solver and a key-value map of its parameters for the
%       COBRArrow client. The test checks the constructor, setName, setParameter (add and
%       update), removeParameter, clearParameters and the text that showParameters prints
%       (captured with diary into a tempname folder).
%
% Function under test:
%     src/base/cobrarrow/COBRArrowSolver.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver (only the configuration object), hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Copies of a solver object share one parameter map
%       SEVERITY: limitation
%       TRIGGER: o1 = COBRArrowSolver('GLPK'); o2 = o1; o2 = o2.setParameter('k', 1); o1.parameters.keys
%       OBSERVED: (R2025a, 2026-11-15) {'k'}: COBRArrowSolver is a value class, but its parameters
%         property is a containers.Map, which is a handle, so setParameter and removeParameter on
%         a copy change the original too (clearParameters gives the copy a new map)
%       EXPECTED: o1 keeps no parameters, as for a value object whose methods return the updated
%         instance
%       LINES: 36, 60, 72
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCOBRArrowSolver'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% constructor: the name as given and an empty parameter map

solver = COBRArrowSolver('GLPK');
assert(isa(solver, 'COBRArrowSolver'));
assert(strcmp(solver.name, 'GLPK'));
assert(isa(solver.parameters, 'containers.Map') && solver.parameters.Count == 0);

%% setName replaces the name

solver = solver.setName('gurobi');
assert(strcmp(solver.name, 'gurobi'));

%% setParameter adds a key and updates an existing key

solver = solver.setParameter('maxIterations', 1000);
solver = solver.setParameter('method', 'dual');
assert(solver.parameters.Count == 2);
assert(isequal(solver.parameters('maxIterations'), 1000));
solver = solver.setParameter('maxIterations', 500);
assert(solver.parameters.Count == 2 && isequal(solver.parameters('maxIterations'), 500));
assert(strcmp(solver.parameters('method'), 'dual'));

%% showParameters prints the name and one line per parameter (keys in sorted order)

tempFolder = tempname;
mkdir(tempFolder);
diaryFile = fullfile(tempFolder, 'showParameters.txt');
diary(diaryFile);
solver.showParameters();
diary('off');
printedLines = strtrim(splitlines(strtrim(fileread(diaryFile))));
assert(isequal(printedLines, {'Parameters for solver: gurobi'; 'maxIterations: 500'; 'method: dual'}));
rmdir(tempFolder, 's');

%% removeParameter removes one key, clearParameters all of them

solver = solver.removeParameter('method');
assert(isequal(solver.parameters.keys, {'maxIterations'}));
solver = solver.clearParameters();
assert(isa(solver.parameters, 'containers.Map') && solver.parameters.Count == 0);
assert(strcmp(solver.name, 'gurobi'));

% change the directory
cd(currentDir)
