% The COBRAToolbox: testSingleProductionEnvelope.m
%
% Purpose:
%     - test the singleProductionEnvelope function
%
% Function under test:
%     src/design/singleProductionEnvelope.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - optimisation on ecoli_core_model, loaded through getDistributedModel.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Jacek Wachowiak
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
global CBTDIR
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSingleProductionEnvelope'));
cd(fileDir);

% require an LP solver; skip gracefully if none is available
prepareTest('needsLP', true);

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
% the plots go to a new folder next to tutorial_optKnock, which also tests its creation
outputFolder = 'testSingleProductionEnvelopeResults';
outputPath = [fileparts(which('tutorial_optKnock')) filesep outputFolder];
[x, y1, y2] = singleProductionEnvelope(model, deletions, product, biomassRxn, 'savePlot', 1, 'outputFolder', outputFolder);
singleProductionEnvelope(model, deletions2, product, biomassRxn, 'geneDelFlag', 1);

% tests
assert(isequal(refData_y1, y1));
assert(isequal(((refData_y2 - (2 * x') - y2) < 1e-4), ones(20, 1)));

% the plots exist in the new folder, under the default file name (the product)
assert(isfile([outputPath filesep product '.png']));
assert(isfile([outputPath filesep product '.pdf']));

% remove the created plots and the folder
rmdir(outputPath, 's');
close all hidden force

% change to old directory
cd(currentDir);
