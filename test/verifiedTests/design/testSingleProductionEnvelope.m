% The COBRAToolbox: testSingleProductionEnvelope.m
%
% Purpose:
%     - test the singleProductionEnvelope function
%
% Authors:
%     - Jacek Wachowiak
global CBTDIR
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSingleProductionEnvelope'));
cd(fileDir);

% test variables
model = readCbModel([CBTDIR filesep 'test' filesep 'models' filesep 'ecoli_core_model.mat']);
deletions = model.rxns(2);
deletions2 = model.genes(2);
product = char(model.rxns(3));
biomassRxn = char(model.rxns(1));

% function outputs
% requires Global Optimization Toolbox
% this function's output is a plot therefore it can be tested only by checking if the plots were created and then deleted successfully
singleProductionEnvelope(model, deletions, product, biomassRxn, 'savePlot', 1);
singleProductionEnvelope(model, deletions2, product, biomassRxn, 'geneDelFlag', 1);

% remove the created plots and the folder - .gitignore for windows because apparently 'rmdir' fails sometimes
if isunix
try
  rmdir([CBTDIR filesep 'tutorials' filesep 'additionalTutorials' filesep 'optKnock' filesep 'Results'], 's');
end
end

% change to old directory
cd(currentDir);
