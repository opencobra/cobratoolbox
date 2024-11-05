% The COBRAToolbox: <testFindRxnsFromSubSystem>.m
%
% Purpose:
%     - This test checks the correct functionality of findRxnsFromSubSystem
%
% Authors:
%     - Farid Zare 2024/08/12
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

% Load reference data
rxnPosref = [3; 4; 5];
reactionNamesref = {'R3'; 'R4'; 'R5'};
nestedCellsref = true;

fprintf(' -- Running testFindRxnsFromSubSystem ...\n ');
subSystem = {'S2', 'S3'};
[reactionNames,rxnPos] = findRxnsFromSubSystem(model,subSystem);

assert(isequal(reactionNames, reactionNamesref))
assert(isequal(rxnPos, rxnPosref))

% Check to see if the code supports a COBRA model V4
model = buildRxn2subSystem(model);
[reactionNames,rxnPos] = findRxnsFromSubSystem(model,subSystem);

assert(isequal(reactionNames, reactionNamesref))
assert(isequal(rxnPos, rxnPosref))

% output a success message
fprintf('Done.\n');

% change the directory
cd(currentDir)
