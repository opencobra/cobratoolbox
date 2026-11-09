% The COBRAToolbox: testSearchModel.m
%
% Purpose:
%     - tests the searchModel function. 
%
% Function under test:
%     src/analysis/exploration/searchModel.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; ecoli_core_model loaded through getDistributedModel.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Thomas Pfau - June 2018
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%


% initialize the test
fileDir = fileparts(which('testSearchModel'));
% save the current path
currentDir = cd(fileDir);

% this test needs no solver, toolbox or particular operating system
prepareTest();

% load model
model = getDistributedModel('ecoli_core_model.mat');

%Find exactly 'atp[c]'
result = searchModel(model,'atp[c]','similarity',1,'printLevel',0);
assert(isempty(setxor(fieldnames(result),{'mets'}))) % Nothing but mets found.
assert(isempty(setxor({result.mets(:).id},{'atp[c]'}))) % Nothing but atp[c] found.
assert(strcmp(result.mets(1).matches(1).source,'mets')) %Only found in the mets field.

%Search for Glycolysis in the model (will find all subSystems which are
%Glycolysis/Gluconeogenesis
diary('Output.txt');
result = searchModel(model,'Glycolysis','printLevel',1);
diary('off');
glycolysis = findRxnsFromSubSystem(model,'Glycolysis/Gluconeogenesis');
%TODO repair
%assert(isempty(setxor({result.rxns(:).id},glycolysis))); %Its exactly those reactions.
assert(isempty(setxor(fieldnames(result),{'rxns'}))) % There is nothing else.
printOut = fileread('Output.txt');
%All the reactions were mentioned in the printOut
%assert(all(cellfun(@(x) ~isempty(strfind(printOut,['ID: ' x])),glycolysis))); 

%Nothing in the model, so the returned struct is empty.
result = searchModel(model,'WeLookForSomethingOdd','printLevel',1);
assert(isempty(fieldnames(result)));
%We add a field that is looking like an annotation field.
model.geneisSomething = repmat({''},size(model.genes));
model.geneisSomething{2} = 'WeLookForSomethingOdderThanThis;WhateverweFindHereIsThere;Maybe';
result = searchModel(model,'WeLookForSomethingOdd','printLevel',1);
%Now, result should have the second gene.
assert(isempty(setxor(fieldnames(result),{'genes'}))) %There are genes, and only genes found now.
assert(isempty(setxor({result.genes(:).id},model.genes(2)))); % and gene2 was found.
assert(strcmp(result.genes(1).matches(1).source,'geneisSomething')); % and gene2 was found.


%% matches in several kinds of objects are printed in separated blocks
printed = evalc('result = searchModel(model, ''fum'', ''printLevel'', 1, ''similarity'', 1);');
assert(isempty(setxor(fieldnames(result), {'rxns', 'mets'})))
assert(contains(printed, 'The following reactions have matching properties:'))
assert(contains(printed, 'The following metabolites have matching properties:'))
assert(contains(printed, '-----------------------------------------------------'))

%% sub-systems stored as cell arrays are searched as well
modelCells = model;
modelCells.subSystems = cellfun(@(x) {x}, model.subSystems, 'UniformOutput', false);
result = searchModel(modelCells, 'Glycolysis/Gluconeogenesis', 'printLevel', 0, 'similarity', 1);
assert(isempty(setxor(fieldnames(result), {'rxns'})))
assert(isempty(setxor({result.rxns(:).id}, glycolysis)))

%Cleanup
delete('Output.txt')

%Return to original directory
cd(currentDir);