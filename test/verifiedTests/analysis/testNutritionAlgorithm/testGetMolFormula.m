% The COBRAToolbox: testGetMolFormula.m
%
% Purpose:
%     - getMolFormula returns the molecular formula of a metabolite of a model and a table with the
%     number of atoms of each element.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/nutritionAlgorithm/getMolFormula.m
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
fileDir = fileparts(which('testGetMolFormula'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

model.mets = {'glc'; 'fe'};
model.metFormulas = {'C6H12O6'; 'Fe'};

%% formula with several elements

[molStr, molTable] = getMolFormula(model, 'glc');
assert(strcmp(molStr, 'C6H12O6'));
% one row per element: symbol and number of atoms
assert(isequal(molTable, {'C', 6; 'H', 12; 'O', 6}));

%% element with a two-letter symbol and no count

% a missing count means one atom
[molStr, molTable] = getMolFormula(model, 'fe');
assert(strcmp(molStr, 'Fe'));
assert(isequal(molTable, {'Fe', 1}));

%% an unknown metabolite is an error

verifyCobraFunctionError('getMolFormula', 'inputs', {model, 'notAMet'}, ...
    'testMessage', 'Invalid input metabolite!');

%% a model without formulas is an error

verifyCobraFunctionError('getMolFormula', 'inputs', {struct('mets', {{'a'}}), 'a'}, ...
    'testMessage', 'A "metFormulas" field is necessary');

% change the directory
cd(currentDir)
