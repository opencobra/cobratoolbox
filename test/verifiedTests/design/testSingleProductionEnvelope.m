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
model = getDistributedModel('ecoli_core_model.mat');
deletions = model.rxns(21); % 'EX_acald(e)'
deletions2 = model.genes(21);
product = char(model.rxns(20)); % 'EX_ac(e)' - the created and deleted plot has the name of the reaction
biomassRxn = char(model.rxns(22));
refData_y1 = zeros(20,1);
refData_y2 = 20 * ones(20, 1);

% function outputs
% requires Global Optimization Toolbox
% this function's output is a curve, in tested case one of them y=0, the other y=20-2x
[x, y1, y2] = singleProductionEnvelope(model, deletions, product, biomassRxn, 'savePlot', 1);
singleProductionEnvelope(model, deletions2, product, biomassRxn, 'geneDelFlag', 1);

% tests
assert(isequal(refData_y1, y1));
assert(isequal(((refData_y2 - (2 * x') - y2) < 1e-4), ones(20, 1)));

% remove the created plots and the folder - .gitignore for windows because apparently 'rmdir' fails sometimes
if isunix
try
  rmdir([CBTDIR filesep 'tutorials' filesep 'additionalTutorials' filesep 'optKnock' filesep 'Results'], 's');
end
end

% change to old directory
cd(currentDir);
