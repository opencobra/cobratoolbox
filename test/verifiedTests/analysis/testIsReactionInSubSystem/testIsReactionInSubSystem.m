% The COBRAToolbox: <testIsReactionInSubSystem>.m
%
% Purpose:
%     - This test checks the correct functionality of isReactionInSubSystem
%
% Authors:
%     - Farid Zare 2024/08/14
%

% save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));

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

% output a success message
fprintf('... testIsReactionInSubSystem passed...\n')
fprintf('Done.\n');
% change the directory
cd(currentDir)
