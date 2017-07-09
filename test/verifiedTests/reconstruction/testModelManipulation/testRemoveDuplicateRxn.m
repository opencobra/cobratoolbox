% The COBRAToolbox: testRemoveDuplicateRxn.m
%
% Purpose:
%     - testRemoveDuplicateRxn tests removeDuplicateRxn
%
% Authors:
%     - CI integration: Laurent Heirendt January 2017

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRemoveDuplicateRxn'));
cd(fileDir);

% test detection and removal of duplicate reactions
model.S = [-1, 0, 0 ,0 , 0, 0, 0;
            1, -1, 0, 0, 0, 0, 0;
            0, -1, 0,-1, 0, 0, 0;
            0, 1, 0, 1, 0, 0, 0;
            0, 1, 0, 1, 0, 0, 0;
            0, 1,-1, 0, 0, 0, 0;
            0, 0, 1,-1, 1, 0, 0;
            0, 0, 0, 1,-1,-1, 0;
            0, 0, 0, 0, 1, 0, 0;
            0, 0, 0, 0,-1, 0, 0;
            0, 0, 0, 0, 0, 1, 1;
            0, 0, 0, 0, 0, 1, -1];
model.lb = [0, 0, 0, 0, 0, 0, 0];
model.ub = [20, 20, 20, 20, 20, 20, 20];
model.rxns = {'GLCt1'; 'HEX1'; 'PGI'; 'PFK'; 'FBP'; 'FBA'; 'TPI'};
model.mets = {'glc-D[e]'; 'glc-D'; 'atp'; 'H'; 'adp'; 'g6p';'f6p'; 'fdp'; 'pi'; 'h2o'; 'g3p'; 'dhap'};
mets_length = length(model.mets);
rxns_length = length(model.rxns);

sc =  [1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

% adding a reaction to the model
%[model,rxnIDexists] = addReaction(model,rxnName,metaboliteList,stoichCoeffList,revFlag,lowerBound,upperBound,objCoeff,subSystem,grRule,geneNameList,systNameList,checkDuplicate,printLevel)
model = addReaction(model, 'GLCt1_duplicate_reverse', model.mets, sc, 0, 0, 20,0,'temp', [], [], [], 1, 0);

method = 'FR'; %will be removed as detects reverse reaction
printLevel = 1;
removeFlag = 1;
[model, removedRxn, rxnRelationship] = checkDuplicateRxn(model, method, removeFlag, printLevel);

assert(rxns_length == length(model.rxns));

% adding a reaction to the model
model = addReaction(model, 'GLCt1_duplicate_reverse', model.mets, sc, 0, 0, 20,0,'temp', [], [], [], 1, 0);

method = 'S';%will not be removed as does not detect reverse reaction
printLevel = 1;
removeFlag = 1;
[model, removedRxn, rxnRelationship] = checkDuplicateRxn(model, method, removeFlag, printLevel);

assert(rxns_length + 1 == length(model.rxns));

%return to original directory
cd(currentDir)
