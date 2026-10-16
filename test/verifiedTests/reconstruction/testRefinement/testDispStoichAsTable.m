% The COBRAToolbox: testDispStoichAsTable.m
%
% Purpose:
%     - dispStoichAsTable returns the stoichiometric matrix as a table with reactions as columns and
%     metabolites as rows, and displays it unless the print level is zero.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/refinement/dispStoichAsTable.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testDispStoichAsTable'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

model.S = [-1 0; 1 -1];
model.rxns = {'r1'; 'r2'};
model.mets = {'a'; 'b'};

%% table contents and names

text = evalc('T = dispStoichAsTable(model);');
assert(istable(T));
assert(isequal(T.Properties.VariableNames, {'r1', 'r2'}));
assert(isequal(T.Properties.RowNames, {'a'; 'b'}));
assert(isequal(table2array(T), model.S));
% displayed by default
assert(contains(text, 'r1') && contains(text, 'r2'));

%% no display at print level zero

text = evalc('T = dispStoichAsTable(model, 0);');
assert(isempty(text) && istable(T));

% change the directory
cd(currentDir)
