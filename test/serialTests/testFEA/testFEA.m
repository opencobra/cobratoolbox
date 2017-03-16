% The COBRAToolbox: testFEA.m
%
% Purpose:
%     - testFEA tests the Flux Enrichemnt Analysis
%     function
%
% Author:
%     - Marouen BEN GUEBILA 09/02/2017

% define the path to The COBRAToolbox
pth = which('initCobraToolbox.m');
CBTDIR = pth(1:end - (length('initCobraToolbox.m') + 1));

cd([CBTDIR, filesep, 'test', filesep, 'serialTests', filesep, 'testFEA']);

% load the model and reference data
load testDataFEA;
load('ecoli_core_model', 'model');

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
cd(CBTDIR)
