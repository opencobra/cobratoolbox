% The COBRAToolbox: testChangeObjective.m
%
% Purpose:
%     - Tests the changeObjective function
% Author:
%     - Original file: Stefania Magnusdottir

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testChangeObjective'));
cd(fileDir);

% define the test model
toyModel = struct;
toyModel.rxns = {'Rxn1'; 'Rxn2'; 'Rxn3'};
toyModel.c = [0 ; 0 ; 0];

% test default coefficient (1)
modelNew = changeObjective(toyModel, 'Rxn1');
assert(modelNew.c(1) == 1 && modelNew.c(2) == 0 && modelNew.c(3) == 0)

% test that error is thrown if objective Rxn4 not in model
try
    modelNew = changeObjective(toyModel, 'Rxn4');
catch ME
    assert(length(ME.message) > 0)
end

% test multiple rxns and 1 rxn not in model, default coefficient (1)
modelNew = changeObjective(toyModel,{'Rxn1'; 'Rxn2'; 'Rxn4'});
assert(modelNew.c(1) == 1 && modelNew.c(2) == 1 && modelNew.c(3) == 0)

% test multiple rxns, different coefficients
modelNew = changeObjective(toyModel,{'Rxn1'; 'Rxn2'},[0.3 ; 0.7]);
assert(modelNew.c(1) == 0.3 && modelNew.c(2) == 0.7 && modelNew.c(3) == 0)

% change the directory
cd(currentDir)
