% The COBRAToolbox: <testBuildRxn2subSystem>.m
%
% Purpose:
%     - This test checks the correct functionality of buildRxn2subSystem
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
rxnSubSystemMatref = [0 0 0; 1 0 0; 1 1 0; 0 0 1; 1 0 1; 0 0 0];
subSystemNamesref = {'S1'; 'S2'; 'S3'};
nestedCellsref = true;

fprintf(' -- Running testBuildRxnSubSystemMat ... ');

[modelOut, rxnSubSystemMat, subSystemNames, nestedCells] = buildRxn2subSystem(model);

assert(isequal(subSystemNames, subSystemNamesref))
assert(isequal(rxnSubSystemMat, rxnSubSystemMatref))
assert(nestedCells, nestedCellsref)

% output a success message
fprintf('Done.\n');

% change the directory
cd(currentDir)
