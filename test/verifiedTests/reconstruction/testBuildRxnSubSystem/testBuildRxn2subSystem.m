% The COBRAToolbox: <testBuildRxn2subSystem>.m
%
% Purpose:
%     - This test checks the correct functionality of buildRxn2subSystem
%
% Function under test:
%     src/reconstruction/refinement/buildRxn2subSystem.m
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
%     - Farid Zare 2024/08/12
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%

% save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));

% this test needs no solver, MATLAB toolbox or particular operating system
prepareTest();

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

%% the output model holds the new fields and, by default, loses the subSystems field

assert(~isfield(modelOut, 'subSystems'));
assert(isequal(modelOut.rxn2subSystem, rxnSubSystemMatref));
assert(isequal(modelOut.subSystemNames, subSystemNamesref));

%% removeSubSystems false (or 0) keeps the subSystems field

modelKept = buildRxn2subSystem(model, false);
assert(isequal(modelKept.subSystems, subSystemsCell));
modelKept = buildRxn2subSystem(model, 0);
assert(isequal(modelKept.subSystems, subSystemsCell));

%% any other value of removeSubSystems is rejected

assert(verifyCobraFunctionError('buildRxn2subSystem', 'inputs', {model, 2}, ...
    'testMessage', 'removeSubSystem input should be logical variable true/false or 1/0'));

%% existing output fields are reported with a warning and replaced

modelExisting = model;
modelExisting.rxn2subSystem = [];
lastwarn('');
modelReplaced = buildRxn2subSystem(modelExisting);
assert(strcmp(lastwarn, 'rxn2subSystem matrix already exists in the model'));
assert(isequal(modelReplaced.rxn2subSystem, rxnSubSystemMatref));

modelExisting = model;
modelExisting.subSystemNames = {};
lastwarn('');
modelReplaced = buildRxn2subSystem(modelExisting);
assert(strcmp(lastwarn, 'subSystemNames field already exists in the model'));
assert(isequal(modelReplaced.subSystemNames, subSystemNamesref));

%% the subSystems and rxns fields are required

assert(verifyCobraFunctionError('buildRxn2subSystem', 'inputs', {rmfield(model, 'subSystems')}, ...
    'testMessage', 'subSystems field should exist in the model'));
assert(verifyCobraFunctionError('buildRxn2subSystem', 'inputs', {rmfield(model, 'rxns')}, ...
    'testMessage', 'rxns field should exist in the model'));

% output a success message
fprintf('Done.\n');

% change the directory
cd(currentDir)
