% The COBRAToolbox: <testIsReactionInSubSystem>.m
%
% Purpose:
%     - This test checks the correct functionality of isReactionInSubSystem
%
% Function under test:
%     src/analysis/exploration/isReactionInSubSystem.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; the toy model comes from createToyModel.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Reactions listed by name out of model order get each other's answers
%       SEVERITY: wrong-result
%       TRIGGER: a cell array of reactions in another order than model.rxns, for example
%         isReactionInSubSystem(model, {'R5', 'Ex_A'}, 'S3') with only R5 in S3
%       OBSERVED: [0; 1], because the reactions are looked up in model order while the answers
%         are stored in the order of the request
%       EXPECTED: [1; 0], one answer per requested reaction in the order of the request
%       LINES: 40, 63
%
% Authors:
%     - Farid Zare 2024/08/14
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%

% save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));

% this test needs no solver, toolbox or particular operating system
prepareTest();

% determine the test path for references
testPath = pwd;

% Create a Toy model
model = createToyModel(0, 0, 0);

% Add subSystems field
subSystemsCell = {''; 'S1'; {'S1'; 'S2'}; 'S3'; {'S3'; 'S1'}; ''};
model.subSystems = subSystemsCell;

% Initiate the test
fprintf(' -- Running testIsReactionInSubSystem ... \n');

[present] = isReactionInSubSystem(model, {'Ex_A', 'R4', 'R5'}, {'S3'});
% set expected output
presentref = [0; 1; 1];
assert(isequal(present, presentref))

% Test vertical input
[present] = isReactionInSubSystem(model, {'Ex_A'; 'R4'; 'R5'}, {'S2', 'S3'});
% set expected output
presentref = [0; 1; 1];
assert(isequal(present, presentref))

% Test subSystem as a string input
[present] = isReactionInSubSystem(model, {'Ex_A'; 'R4'; 'R5'}, 'S3');
% set expected output
presentref = [0; 1; 1];
assert(isequal(present, presentref))

% Test COBRA V4 model
model = buildRxn2subSystem(model);
[present] = isReactionInSubSystem(model, {'Ex_A'; 'R4'; 'R5'}, 'S3');
% set expected output
presentref = [0; 1; 1];
assert(isequal(present, presentref))

%% one reaction given as a string
assert(isequal(isReactionInSubSystem(model, 'R4', 'S3'), true))
assert(isequal(isReactionInSubSystem(model, 'Ex_A', 'S3'), false))

%% reactions given by their position, in any order
[~, positions] = ismember({'R5'; 'Ex_A'; 'R4'}, model.rxns);
[present] = isReactionInSubSystem(model, positions, 'S3');
assert(isequal(present, [true; false; true]))

%% a position outside the model is refused
assert(verifyCobraFunctionError('isReactionInSubSystem', 'inputs', {model, numel(model.rxns) + 1, 'S3'}, ...
    'testMessage', 'Index of reactions exceeds number of reactions in the model'))

% output a success message
fprintf('... testIsReactionInSubSystem passed...\n')
fprintf('Done.\n');
% change the directory
cd(currentDir)
