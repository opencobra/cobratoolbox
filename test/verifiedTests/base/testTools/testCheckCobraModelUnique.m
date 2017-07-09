% The COBRAToolbox: testCheckCobraModelUnique.m
%
% Purpose:
%     - Tests the checkCobraModelUnique function
% Author:
%     - Original file: Stefania Magnusdottir

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCheckCobraModelUnique'));
cd(fileDir);

% define the test model
toyModel = struct;
toyModel.rxns = {'Rxn1'; 'Rxn2'; 'Rxn2'};
toyModel.mets = {'Met1'; 'Met2'; 'Met2'};

% define output mets when replacing duplicate met names
metsReplaced = {'Met1'; 'Met2_1'; 'Met2_2'};

% define output mets when replacing duplicate met names
rxnsReplaced = {'Rxn1'; 'Rxn2_1'; 'Rxn2_2'};

% run function without replacing rxn/met names
modelTest = checkCobraModelUnique(toyModel);

% check if met and rxn outputs are identical
assert(isequal(toyModel.mets, modelTest.mets));
assert(isequal(toyModel.rxns, modelTest.rxns));

% run function and replace duplicate rxn/met names
modelTest=checkCobraModelUnique(toyModel, 1);

% check if duplicate met and rxn names have been changed correctly
assert(isequal(metsReplaced, modelTest.mets));
assert(isequal(rxnsReplaced, modelTest.rxns));

% change the directory
cd(currentDir)
