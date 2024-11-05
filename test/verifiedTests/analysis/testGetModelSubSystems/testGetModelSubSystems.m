% The COBRAToolbox: testGetModelSubSystems.m
%
% Purpose:
%     - This test function checks the functionality of getModelSubSystems
% function
%
% Authors:
%     - Farid Zare 2024/08/12
%


% save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));

% determine the test path for references
testPath = pwd;

% Expected answer for subSystems:
refsubSystems = {'Anaplerotic reactions'; 'Citric Acid Cycle'; 'Exchange'; ...
    'Glutamate Metabolism'; 'Glycolysis/Gluconeogenesis'; ...
    'Inorganic Ion Transport and Metabolism'; 'Oxidative Phosphorylation';...
    'Pentose Phosphate Pathway'; 'Pyruvate Metabolism'; 'Transport, Extracellular'};

% load the model
model = getDistributedModel('ecoli_core_model.mat'); %For all models in the test/models folder and subfolders

fprintf(' -- Running testGetModelSubSystems ... ');

% test with character elements as sub-system names
[subSystems]  = getModelSubSystems(model);
assert(isequal(subSystems, refsubSystems));

% test with cell elements as sub-system names
modelNew = model;
% Convert char elements to cell elements
for i = 1:numel(modelNew.subSystems)
    modelNew.subSystems{i} = modelNew.subSystems(i);
end
[subSystems]  = getModelSubSystems(modelNew);
assert(isequal(subSystems, refsubSystems));

% test with nested cell arrays
modelNew = model;
% Convert char elements to nested cell arrays
for i = 1:numel(modelNew.subSystems)
    modelNew.subSystems{i} = [model.subSystems(i); model.subSystems(i)];
end
[subSystems]  = getModelSubSystems(modelNew);
assert(isequal(subSystems, refsubSystems));

% test a model with no subSystem field
modelNew = rmfield(modelNew, 'subSystems');

% Expected output is an empty cell
[subSystems]  = getModelSubSystems(modelNew);
assert(isempty(subSystems));

% output a success message
fprintf('Done.\n');

% change the directory
cd(currentDir)
