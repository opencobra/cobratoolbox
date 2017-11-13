% The COBRAToolbox: testModelManipulation.m
%
% Purpose:
%     - testModelManipulation tests addReaction, removeReaction, removeMetabolite
%       first creates a simple toy network with basic S, lb, ub, rxns, mets
%       tests addReaction, removeReaction, removeMetabolite
%       then creates an empty matrix and does the previous procedures.
%       Then tests convertToReversible, and convertToIrreversible using the
%       iJR904 model. Prints whether each test was successful or not.
%
% Authors:
%     - Joseph Kang 04/16/09
%     - Richard Que (12/16/09) Added testing of convertToIrrevsible/Reversible
%     - CI integration: Laurent Heirendt January 2017

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testModelManipulation'));
cd(fileDir);

% Test with non-empty model
fprintf('>> Starting non-empty model tests:\n');

% addReaction, removeReaction, removeMetabolite
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
model.lb = [0, 0, 0, 0, 0, 0, 0]';
model.ub = [20, 20, 20, 20, 20, 20, 20]';
model.rxns = {'GLCt1'; 'HEX1'; 'PGI'; 'PFK'; 'FBP'; 'FBA'; 'TPI'};
model.mets = {'glc-D[e]'; 'glc-D'; 'atp'; 'H'; 'adp'; 'g6p';'f6p'; 'fdp'; 'pi'; 'h2o'; 'g3p'; 'dhap'};
sc =  [-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
mets_length = length(model.mets);
rxns_length = length(model.rxns);

% adding a reaction to the model
model = addReaction(model, 'EX_glc', model.mets, sc, 0, 0, 20);

% adding a reaction to the model (test only)
model = addReaction(model, 'ABC_def', model.mets, 2 * sc, 0, -5, 10);

%Now, add some fields by an extensive addReaction call
modelWithFields = addReaction(model,'TestReaction','reactionFormula','A + B -> C','subSystem','Some Sub','geneRule','GeneA or GeneB');
assert(verifyModel(modelWithFields,'simpleCheck',true,'requiredFields',{}))

%And test this also with a different input of subSystems:
modelWithFields = addReaction(model,'TestReaction','reactionFormula','A + B -> C','subSystem',{'Some Sub', 'And another sub'},'geneRule','GeneA or GeneB');
assert(verifyModel(modelWithFields,'simpleCheck',true,'requiredFields',{}))


%Trying to add a reaction without stoichiometry will fail.
errorCall = @() addReaction(model,'NoStoich');
assert(verifyCobraFunctionError(errorCall));

%Try adding a new reaction with two different stoichiometries
errorCall = @() addReaction(model, 'reactionFormula', 'A + B -> C','stoichCoeffList',[ -1 2], 'metaboliteList',{'A','C'});
assert(verifyCobraFunctionError(errorCall));

%Try having a metabolite twice in the metabolite list or reaction formula
modelWAddedMet = addReaction(model, 'reactionFormula', 'Alpha + Beta -> Gamma + 2 Beta');
assert(modelWAddedMet.S(ismember(modelWAddedMet.mets,'Beta'),end) == 1);

%Try to change metabolites of a specific reaction
exchangedMets = {'atp','adp','pi'};
[A,B] = ismember(exchangedMets,modelWAddedMet.mets);
exMetPos = B(A);
newMets = {'Alpha','Beta','Gamma'};
[A,B] = ismember(newMets,modelWAddedMet.mets);
newMetPos = B(A);
HEXPos = ismember(modelWAddedMet.rxns,'HEX1');
FBPPos = ismember(modelWAddedMet.rxns,'FBP');
oldvaluesHEX = modelWAddedMet.S(exMetPos,HEXPos);
oldvaluesFBP = modelWAddedMet.S(exMetPos,FBPPos);
[modelWAddedMetEx,changedRxns] = changeRxnMets(modelWAddedMet,exchangedMets,newMets,{'HEX1','FBP'});
%The new metabolites have the right values
assert(all(modelWAddedMetEx.S(newMetPos,HEXPos)==oldvaluesHEX));
assert(all(modelWAddedMetEx.S(newMetPos,FBPPos)==oldvaluesFBP));
assert(all(modelWAddedMetEx.S(exMetPos,HEXPos) == 0));
assert(all(modelWAddedMetEx.S(exMetPos,FBPPos) == 0));

%Also give new Stoichiometry
newStoich = [ 1 4; 2 5; 3 6];
[modelWAddedMetEx,changedRxns] = changeRxnMets(modelWAddedMet,exchangedMets,newMets,{'HEX1','FBP'},newStoich);
%The new metabolites have the right values
assert(all(modelWAddedMetEx.S(newMetPos,HEXPos)==newStoich(:,1)));
assert(all(modelWAddedMetEx.S(newMetPos,FBPPos)==newStoich(:,2)));
assert(all(modelWAddedMetEx.S(exMetPos,HEXPos) == 0));
assert(all(modelWAddedMetEx.S(exMetPos,FBPPos) == 0));

%And try random ones.
%Also give new Stoichiometry
newStoich = [ 1 2 3; 4 5 6];
[modelWAddedMetEx,changedRxns] = changeRxnMets(modelWAddedMet,exchangedMets,newMets,2);
OldPos1 = ismember(modelWAddedMet.rxns,changedRxns{1});
OldPos2 = ismember(modelWAddedMet.rxns,changedRxns{2});
oldvalues1 = modelWAddedMet.S(exMetPos,OldPos1);
oldvalues2 = modelWAddedMet.S(exMetPos,OldPos2);
%The new metabolites have the right values
assert(all(modelWAddedMetEx.S(newMetPos,OldPos1)==oldvalues1));
assert(all(modelWAddedMetEx.S(newMetPos,OldPos2)==oldvalues2));
assert(all(modelWAddedMetEx.S(exMetPos,OldPos1) == 0));
assert(all(modelWAddedMetEx.S(exMetPos,OldPos2) == 0));


% check if the number of reactions was incremented by 1
assert(length(model.rxns) == rxns_length + 2);

% adding a reaction to the model (test only)
model = addReaction(model, 'ABC_def', model.mets, 3 * sc);

% remove the reaction from the model
model = removeRxns(model, {'EX_glc'});

% remove the reaction from the model
model = removeRxns(model, {'ABC_def'});

% add exchange reaction
modelWEx = addExchangeRxn(model, {'glc-D[e]'; 'glc-D'});
%We added two reactions, check that.
assert(numel(modelWEx.rxns) == numel(model.rxns)+2);

%Now try again, this time, we should get the same model
modelWEx2 = addExchangeRxn(modelWEx, {'glc-D[e]'; 'glc-D'});
assert(isSameCobraModel(modelWEx,modelWEx2));

%check if rxns length was decremented by 1
assert(length(model.rxns) == rxns_length);

% add a new reaction to the model
model = addReaction(model,'newRxn1','A -> B + 2 C');

% check if the number of reactions was incremented by 1
assert(length(model.rxns) == rxns_length + 1);

% check if the number of metabolites was incremented by 3
assert(length(model.mets) == mets_length + 3);

% change the reaction bounds
model = changeRxnBounds(model, model.rxns, 2, 'u');
assert(model.ub(1) == 2);

% remove the reaction
model = removeRxns(model, {'newRxn1'});
assert(length(model.rxns) == rxns_length);

% remove some metabolites
model = removeMetabolites(model, {'A', 'B', 'C'});
assert(length(model.mets) == mets_length);

% Tests with empty model
fprintf('>> Starting empty model tests:\n');

model.S = [];
model.rxns = {};
model.mets = {};
model.lb = [];
model.ub = [];

rxns_length = 0;
mets_length = 0;

% add a reaction
model = addReaction(model,'newRxn1','A -> B + 2 C');

% check if the number of reactions was incremented by 1
assert(length(model.rxns) == rxns_length + 1);

% check if the number of metabolites was incremented by 3
assert(length(model.mets) == mets_length + 3);

% change the reaction bounds
model = changeRxnBounds(model, model.rxns, 2, 'u');
assert(model.ub(1) == 2);

% remove the reaction
model = removeRxns(model, {'newRxn1'});
assert(length(model.rxns) == rxns_length);

% remove some metabolites
model = removeMetabolites(model, {'A', 'B', 'C'});
assert(length(model.mets) == mets_length);

% Convert to irreversible
fprintf('>> Testing convertToIrreversible (1)\n');
model = readCbModel('testModelManipulation.mat','modelName', 'model');
assert(verifyModel(model, 'simpleCheck', 1));
modelIrrev = readCbModel('testModelManipulation.mat','modelName', 'modelIrrev');
assert(verifyModel(modelIrrev, 'simpleCheck', 1));
[testModelIrrev, matchRev, rev2irrev, irrev2rev] = convertToIrreversible(model);
testModelIrrev.modelID = 'modelIrrev'; % newer COBRA models have modelID

% test if both models are the same
assert(isSameCobraModel(modelIrrev, testModelIrrev));

% Convert to reversible
fprintf('>> Testing convertToReversible\n');
testModelRev = convertToReversible(testModelIrrev);
testModelRev = rmfield(testModelRev,'reversibleModel'); % this should now be the original model!

% test if both models are the same
testModelRev.modelID = 'model'; % newer COBRA models have modelID
assert(isSameCobraModel(model,testModelRev));

% test irreversibility of model
fprintf('>> Testing convertToIrreversible (2)\n');
model = readCbModel('testModelManipulation.mat','modelName', 'model');
assert(verifyModel(model, 'simpleCheck', 1));
modelIrrev = readCbModel('testModelManipulation.mat','modelName', 'modelIrrev');
assert(verifyModel(modelIrrev, 'simpleCheck', 1));

% set a lower bound to positive (faulty model)
modelRev.lb(1) = 10;
[testModelIrrev, matchRev, rev2irrev, irrev2rev] = convertToIrreversible(model);
testModelIrrev.modelID = 'modelIrrev'; % newer COBRA models have modelID

% test if both models are the same
assert(isSameCobraModel(modelIrrev, testModelIrrev));


%test Conversion with special ordering
fprintf('>> Testing convertToIrreversible (3)\n');
model = readCbModel('testModelManipulation.mat','modelName', 'model');
assert(verifyModel(model, 'simpleCheck', 1));
modelIrrevOrdered = readCbModel('testModelManipulation.mat','modelName', 'modelIrrevOrdered');
assert(verifyModel(modelIrrevOrdered, 'simpleCheck', 1));

[testModelIrrev, matchRev, rev2irrev, irrev2rev] = convertToIrreversible(model, 'orderReactions', true);
testModelIrrev.modelID = 'modelIrrevOrdered'; % newer COBRA models have modelID

% test if both models are the same
assert(isSameCobraModel(modelIrrevOrdered, testModelIrrev));


%Test moveRxn
model2 = moveRxn(model,10,20);
fields = getModelFieldsForType(model,'rxns');
rxnSize = numel(model.rxns);
for i = 1:numel(fields)
    if size(model.(fields{i}),1) == rxnSize
        val1 = model.(fields{i})(10,:);    
        val2 = model2.(fields{i})(20,:);    
    elseif size(model.(fields{i}),2) == rxnSize
        val1 = model.(fields{i})(:,10);    
        val2 = model2.(fields{i})(:,20);    
    end
    assert(isequal(val1,val2));
end

% Test addReaction with name-value argument input
fprintf('>> Testing addReaction with name-value argument input\n');
% options available in the input:
name = {'reactionName', 'reversible', ...
    'lowerBound', 'upperBound', 'objectiveCoef', 'subSystem', 'geneRule', ...
    'geneNameList', 'systNameList', 'checkDuplicate', 'printLevel'};
value = {'TEST', true, ...
    -1000, 1000, 0, '', '', ...
    {}, {}, true, 1};
arg = [name; value];
model2 = addReaction(model, 'TEST', 'reactionFormula', [model.mets{1} ' <=>'], arg{:});
assert(verifyModel(model2, 'simpleCheck', 1));
for k = 1:numel(name)
    % test differet optional name-value argument as the first argument after rxnID
    model2b = addReaction(model, 'TEST', name{k}, value{k}, 'reactionFormula', [model.mets{1} ' <=>']);
    assert(verifyModel(model2b, 'simpleCheck', 1));
    assert(isequal(model2, model2b))  
    
    model2b = addReaction(model, 'TEST', name{k}, value{k}, 'metaboliteList', model.mets(1), 'stoichCoeffList', -1);
    assert(verifyModel(model2b, 'simpleCheck', 1));
    assert(isequal(model2, model2b))  
    
    % test differet optional name-value argument as argument after reactionFormula or stoichCoeffList
    model2b = addReaction(model, 'TEST', 'reactionFormula', [model.mets{1} ' <=>'], name{k}, value{k});
    assert(verifyModel(model2b, 'simpleCheck', 1));
    assert(isequal(model2, model2b))  
    
    model2b = addReaction(model, 'TEST', 'metaboliteList', model.mets(1), 'stoichCoeffList', -1, name{k}, value{k});
    assert(verifyModel(model2b, 'simpleCheck', 1));
    assert(isequal(model2, model2b))  
end

% Test addReaction backward compatibility
fprintf('>> Testing addReaction backward compatibility\n');
% backward signature: model = addReaction(model,rxnName,metaboliteList,stoichCoeffList,revFlag,lowerBound,upperBound,objCoeff,subSystem,grRule,geneNameList,systNameList,checkDuplicate)
% reactionName
fprintf('reactionFormula\n');
model2 = addReaction(model, 'TEST', 'reactionFormula', [model.mets{1} ' <=>'], 'reactionName', 'TestReaction');
assert(verifyModel(model2, 'simpleCheck', 1));
model2b = addReaction(model, {'TEST', 'TestReaction'}, [model.mets{1} ' <=>']);
assert(verifyModel(model2b, 'simpleCheck', 1));
assert(isequal(model2, model2b))
% metaboliteList & stoichCoeffList
fprintf('metaboliteList & stoichCoeffList\n');
model2 = addReaction(model, 'TEST', 'metaboliteList', model.mets(1), 'stoichCoeffList', -1);
assert(verifyModel(model2, 'simpleCheck', 1));
model2b = addReaction(model, 'TEST', model.mets(1), -1);
assert(verifyModel(model2b, 'simpleCheck', 1));
assert(isequal(model2, model2b))
% revFlag
fprintf('reversible\n');
model2 = addReaction(model, 'TEST', 'metaboliteList', model.mets(1), 'stoichCoeffList', -1, 'reversible', 0);
assert(verifyModel(model2, 'simpleCheck', 1));
model2b = addReaction(model, 'TEST', model.mets(1), -1, 0);
assert(verifyModel(model2b, 'simpleCheck', 1));
assert(isequal(model2, model2b))
% irreversible revFlag overridden by reversible reaction formula
model2 = addReaction(model, 'TEST', 'reactionFormula', [model.mets{1} ' <=>'], 'stoichCoeffList', -1, 'reversible', 0);
assert(verifyModel(model2, 'simpleCheck', 1));
model2b = addReaction(model, 'TEST', [model.mets{1} ' <=>'], [], 0);
assert(verifyModel(model2b, 'simpleCheck', 1));
assert(isequal(model2, model2b))
% lowerBound
fprintf('lowerBound\n');
model2 = addReaction(model, 'TEST', 'reactionFormula', [model.mets{1} ' <=>'], 'lowerBound', -10);
assert(verifyModel(model2, 'simpleCheck', 1));
model2b = addReaction(model, 'TEST', [model.mets{1} ' <=>'], [], [], -10);
assert(verifyModel(model2b, 'simpleCheck', 1));
assert(isequal(model2, model2b))
% upperBound
fprintf('upperBound\n');
model2 = addReaction(model, 'TEST', 'reactionFormula', [model.mets{1} ' <=>'], 'upperBound', 10);
assert(verifyModel(model2, 'simpleCheck', 1));
model2b = addReaction(model, 'TEST', [model.mets{1} ' <=>'], [], [], [], 10);
assert(verifyModel(model2b, 'simpleCheck', 1));
assert(isequal(model2, model2b))
% objCoeff
fprintf('objectiveCoef\n');
model2 = addReaction(model, 'TEST', 'reactionFormula', [model.mets{1} ' <=>'], 'objectiveCoef', 3);
assert(verifyModel(model2, 'simpleCheck', 1));
model2b = addReaction(model, 'TEST', [model.mets{1} ' <=>'], [], [], [], [], 3);
assert(verifyModel(model2b, 'simpleCheck', 1));
assert(isequal(model2, model2b))
% subSystem
fprintf('subSystem\n');
model2 = addReaction(model, 'TEST', 'reactionFormula', [model.mets{1} ' <=>'], 'subSystem', 'testSubSystem');
assert(verifyModel(model2, 'simpleCheck', 1));
model2b = addReaction(model, 'TEST', [model.mets{1} ' <=>'], [], [], [], [], [], 'testSubSystem');
assert(verifyModel(model2b, 'simpleCheck', 1));
assert(isequal(model2, model2b))
% grRule
fprintf('geneRule\n');
model2 = addReaction(model, 'TEST', 'reactionFormula', [model.mets{1} ' <=>'], 'geneRule', 'test1 & test2');
assert(verifyModel(model2, 'simpleCheck', 1));
model2b = addReaction(model, 'TEST', [model.mets{1} ' <=>'], [], [], [], [], [], [], 'test1 & test2');
assert(verifyModel(model2b, 'simpleCheck', 1));
nGene = numel(model2.genes);
assert(isequal(model2, model2b) ...
    & isequal(model2.genes(end-1:end), {'test1'; 'test2'}) & strcmp(model2.grRules{end}, 'test1 & test2') ...
    & strcmp(model2.rules{end}, ['x(' num2str(nGene-1) ') & x(' num2str(nGene) ')']))
% geneNameList & systNameList
fprintf('geneRule with geneNameList and systNameList\n');
model2 = addReaction(model, 'TEST', 'reactionFormula', [model.mets{1} ' <=>'], ...
    'geneRule', 'testGeneName1 & testGeneName2', 'geneNameList', {'testGeneName1'; 'testGeneName2'}, ...
    'systNameList', {'testSystName1'; 'testSystName2'});
assert(verifyModel(model2, 'simpleCheck', 1));
model2b = addReaction(model, 'TEST', [model.mets{1} ' <=>'], [], [], [], [], [], [], ...
    'testGeneName1 & testGeneName2', {'testGeneName1'; 'testGeneName2'}, {'testSystName1'; 'testSystName2'});
assert(verifyModel(model2b, 'simpleCheck', 1));
nGene = numel(model2.genes);
assert(isequal(model2, model2b) ...
    & isequal(model2.genes(end-1:end), {'testSystName1'; 'testSystName2'}) & strcmp(model2.grRules{end}, 'testSystName1 & testSystName2') ...
    & strcmp(model2.rules{end}, ['x(' num2str(nGene-1) ') & x(' num2str(nGene) ')']))
% checkDuplicate
fprintf('checkDuplicate\n');
formula = printRxnFormula(model,'rxnAbbrList', model.rxns(1), 'printFlag', false);
model2 = addReaction(model, 'TEST', 'reactionFormula', formula{1}, 'checkDuplicate', true);
assert(verifyModel(model2, 'simpleCheck', 1));
model2b = addReaction(model, 'TEST', formula{1}, [], [], [], [], [], [], [], [], [], true);
assert(verifyModel(model2b, 'simpleCheck', 1));
assert(isequal(model2, model) & isequal(model2b, model2))
model2 = addReaction(model, 'TEST', 'reactionFormula', formula{1}, 'checkDuplicate', false);
assert(verifyModel(model2, 'simpleCheck', 1));
model2b = addReaction(model, 'TEST', formula{1}, [], [], [], [], [], [], [], [], [], false);
assert(verifyModel(model2b, 'simpleCheck', 1));
assert(isequal(model2, model2b) & numel(model2.rxns) == numel(model.rxns) + 1)


% change the directory
cd(currentDir)
