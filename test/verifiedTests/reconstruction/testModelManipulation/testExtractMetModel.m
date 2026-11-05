% The COBRAToolbox: testUpdateGenes.m
%
% Purpose:
%     - testExtractMetModel tests extractMetModel
%
% Function under test:
%     src/reconstruction/refinement/extractMetModel.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; Recon2.v05 loaded through getDistributedModel, as the
%     stored reference subnetworks come from it.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Uri David Akavia August 2017
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.

global CBTDIR

% save the current path
currentDir = pwd;

fileDir = fileparts(which('testUpdateGenes'));
cd(fileDir);

% this test needs no solver, MATLAB toolbox or particular operating system
prepareTest();

if 1
    model = getDistributedModel('Recon2.v05.mat');
else
    if 0
        model = getDistributedModel('Recon2.v04.mat');
    else
        load('Recon2.v04.mat');
        model = modelR204;
        %delete gpr for ATPS4m
        model.grRules(strcmp(model.rxns,'ATPS4m')) = {''};
        model.rules(strcmp(model.rxns,'ATPS4m')) = {''};
        model = convertOldStyleModel(model, 0);
        res = verifyModel(model, 'silentCheck', true);
    end
end
                
%compare against explicitly loaded models to conserve the ids.
load('testExtractMetModel.mat', 'emptyModel', 'atpModel', 'pppg9Level0', 'pppg9Level1');

% Test getting level 0 (just reactions that involve a metabolite)
model2 = extractMetModel(model, 'pppg9', 0, 1);

printLevel=1;
pppg9Level0.modelID=model.modelID;
[isSame, nDiff, commonFields] = isSameCobraModel(model2, pppg9Level0, printLevel);
assert(isSame);

% Test getting level 1 (include one reaction away from reactions that involve a metaoblite)
model2 = extractMetModel(model, 'pppg9', 1, 1);
pppg9Level1.modelID=model.modelID;
assert(isSameCobraModel(model2, pppg9Level1));

% Test asking for a very common metabolite, empty model should be returned
model2 = extractMetModel(model, 'atp', 0, 1);
emptyModel.modelID=model.modelID;
[isSame, nDiff, commonFields] = isSameCobraModel(model2, emptyModel, printLevel);
assert(isSame);

% Test asking for a very common metabolite, with high limit on connectivity
model2 = extractMetModel(model, 'atp', 0, 1, 99999);
atpModel.modelID=model.modelID;
atpModel.grRules=model2.grRules;
atpModel.rules=model2.rules;
[isSame, nDiff, commonFields] = isSameCobraModel(model2, atpModel, printLevel);
assert(isSame);

%% one metabolite in one compartment gives exactly the reactions of that metabolite

% with allCompFlag false the name is taken with its compartment, so one metabolite is selected
oneMetabolite = model.mets{find(strncmp(model.mets, 'pppg9[', 6), 1)};
model2 = extractMetModel(model, oneMetabolite, 0, 0);
metRow = strcmp(model.mets, oneMetabolite);
assert(isequal(sort(model2.rxns), sort(model.rxns(model.S(metRow, :) ~= 0 & model.c' ~= 1))));
assert(any(strcmp(model2.mets, oneMetabolite)));

%return to original directory
cd(currentDir)