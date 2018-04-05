% The COBRAToolbox: testFEA.m
%
% Purpose:
%     - testFEA tests the Flux Enrichemnt Analysis
%     function
%
% Author:
%     - Marouen BEN GUEBILA 09/02/2017

global CBTDIR

%Test requirements
requiredToolboxes = {'bioinformatics_toolbox','statistics_toolbox'};
prepareTest('toolboxes',requiredToolboxes);

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFEA'));
cd(fileDir);    


% load the model and reference data
load('testDataFEA.mat');
model = getDistributedModel('ecoli_core_model.mat');

% run FEA
resultCellFtest = FEA(model, 1:10, 'subSystems');

% assert equality of test results and reference data
assert(isequal(resultCellFtest, resultCellF));

% check when the groups argument is not a string
try
    resultCellFtest = FEA(1:10, model, 0);
catch ME
    assert(length(ME.message) > 0)
end

% check less than 3 input arguments
try
    resultCellFtest = FEA(model, 1:10);
catch ME
    assert(length(ME.message) > 0)
end

% check when the rxnSet is not a vector
try
    resultCellFtest = FEA(model, [1:10; 1:10], 'subSystems');
catch ME
    assert(length(ME.message) > 0)
end

% change the directory
cd(currentDir)
