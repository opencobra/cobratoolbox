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

%Init the empty model.
model = struct();

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
sc =  [-1, 0, 0, 0, 2, 0, 0, 0, 3, 0, 0, 0];
mets_length = length(model.mets);
rxns_length = length(model.rxns);

% adding a reaction to the model
model = addReaction(model, 'EX_glc', model.mets, sc, 0, 0, 20);
assert(any(ismember(model.rxns,'EX_glc')));

% adding a reaction to the model (test only)
model = addReaction(model, 'ABC_def', sort(model.mets), 2 * sc, 0, -5, 10);
assert(any(ismember(model.rxns,'ABC_def')));

reactionPos = ismember(model.rxns,'ABC_def');
[~,metPos] = ismember(sort(model.mets),model.mets);
assert(all(model.S(metPos,reactionPos) == 2*sc')); %Correct stoichiometry
assert(model.lb(reactionPos) == -5);
assert(model.ub(reactionPos) == 10);



%Now, add some fields by an extensive addReaction call
modelWithFields = addReaction(model,'TestReaction','reactionFormula','A + B -> C','subSystem','Some Sub','geneRule','GeneA or GeneB');
assert(verifyModel(modelWithFields,'simpleCheck',true,'requiredFields',{}))

%Also add a Constraint to the model
model = addCOBRAConstraints(model,{'GLCt1'; 'HEX1'; 'PGI'},[1000,50],'c',[1,1,0;0,0,1],'dsense','LL');

%And test this also with a different input of subSystems:
modelWithFields = addReaction(model,'TestReaction','reactionFormula','A + B -> C','subSystem',{'Some Sub', 'And another sub'},'geneRule','GeneA or GeneB');
assert(verifyModel(modelWithFields,'simpleCheck',true,'requiredFields',{}))
assert(size(modelWithFields.C,2) == size(modelWithFields.S,2));

%Trying to add a reaction without stoichiometry will fail.
errorCall = @() addReaction(model,'NoStoich');
assert(verifyCobraFunctionError('addReaction', 'inputs',{model,'NoStoich'}));

%Try adding a new reaction with two different stoichiometries

assert(verifyCobraFunctionError('addReaction', 'inputs', {model, 'reactionFormula', 'A + B -> C','stoichCoeffList',[ -1 2], 'metaboliteList',{'A','C'}}));

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
    'geneNameList', 'systNameList', 'checkDuplicate'};
value = {'TEST', true, ...
    -1000, 1000, 0, '', '', ...
    {}, {}, true};
arg = [name; value];
model2 = addReaction(model, 'TEST', 'reactionFormula', [model.mets{1} ' <=>'], arg{:});
assert(verifyModel(model2, 'simpleCheck', 1));
for k = 1:numel(name)
    % test differet optional name-value argument as the first argument after rxnID
    model2b = addReaction(model, 'TEST', name{k}, value{k}, 'printLevel', 0, 'reactionFormula', [model.mets{1} ' <=>']);
    assert(verifyModel(model2b, 'simpleCheck', 1));
    assert(isequal(model2, model2b))  
    
    model2b = addReaction(model, 'TEST', name{k}, value{k}, 'printLevel', 0, 'metaboliteList', model.mets(1), 'stoichCoeffList', -1);
    assert(verifyModel(model2b, 'simpleCheck', 1));
    assert(isequal(model2, model2b))  
    
    % test differet optional name-value argument as argument after reactionFormula or stoichCoeffList
    model2b = addReaction(model, 'TEST', 'printLevel', 0, 'reactionFormula', [model.mets{1} ' <=>'], name{k}, value{k});
    assert(verifyModel(model2b, 'simpleCheck', 1));
    assert(isequal(model2, model2b))  
    
    model2b = addReaction(model, 'TEST', 'printLevel', 0, 'metaboliteList', model.mets(1), 'stoichCoeffList', -1, name{k}, value{k});
    assert(verifyModel(model2b, 'simpleCheck', 1));
    assert(isequal(model2, model2b))  
end

% Test addReaction backward compatibility
% backward signature: model = addReaction(model,rxnName,metaboliteList,stoichCoeffList,revFlag,lowerBound,upperBound,objCoeff,subSystem,grRule,geneNameList,systNameList,checkDuplicate)
% reactionName
fprintf('>> Done \n\n >> Testing reactionFormula\n');
model2 = addReaction(model, 'TEST', 'reactionFormula', [model.mets{1} ' <=>'], 'printLevel', 0, 'reactionName', 'TestReaction');
assert(verifyModel(model2, 'simpleCheck', 1));
model2b = addReaction(model, {'TEST', 'TestReaction'}, [model.mets{1} ' <=>']);
assert(verifyModel(model2b, 'simpleCheck', 1));
assert(isequal(model2, model2b))
% metaboliteList & stoichCoeffList
fprintf('>> Done \n\n >> Testing metaboliteList & stoichCoeffList\n');
model2 = addReaction(model, 'TEST', 'metaboliteList', model.mets(1), 'printLevel', 0, 'stoichCoeffList', -1);
assert(verifyModel(model2, 'simpleCheck', 1));
model2b = addReaction(model, 'TEST', model.mets(1), -1);
assert(verifyModel(model2b, 'simpleCheck', 1));
assert(isequal(model2, model2b))
% revFlag
fprintf('>> Done \n\n >> Testing reversible\n');
model2 = addReaction(model, 'TEST', 'metaboliteList', model.mets(1), 'printLevel', 0, 'stoichCoeffList', -1, 'reversible', 0);
assert(verifyModel(model2, 'simpleCheck', 1));
model2b = addReaction(model, 'TEST', model.mets(1), -1, 0);
assert(verifyModel(model2b, 'simpleCheck', 1));
assert(isequal(model2, model2b))
% irreversible revFlag overridden by reversible reaction formula
model2 = addReaction(model, 'TEST', 'reactionFormula', [model.mets{1} ' <=>'], 'printLevel', 0, 'stoichCoeffList', -1, 'reversible', 0);
assert(verifyModel(model2, 'simpleCheck', 1));
model2b = addReaction(model, 'TEST', [model.mets{1} ' <=>'], [], 0);
assert(verifyModel(model2b, 'simpleCheck', 1));
assert(isequal(model2, model2b))
% lowerBound
fprintf('>> Done \n\n >> Testing lowerBound\n');
model2 = addReaction(model, 'TEST', 'reactionFormula', [model.mets{1} ' <=>'], 'printLevel', 0, 'lowerBound', -10);
assert(verifyModel(model2, 'simpleCheck', 1));
model2b = addReaction(model, 'TEST', [model.mets{1} ' <=>'], [], [], -10);
assert(verifyModel(model2b, 'simpleCheck', 1));
assert(isequal(model2, model2b))
% upperBound
fprintf('>> Done \n\n >> Testing upperBound\n');
model2 = addReaction(model, 'TEST', 'reactionFormula', [model.mets{1} ' <=>'], 'printLevel', 0, 'upperBound', 10);
assert(verifyModel(model2, 'simpleCheck', 1));
model2b = addReaction(model, 'TEST', [model.mets{1} ' <=>'], [], [], [], 10);
assert(verifyModel(model2b, 'simpleCheck', 1));
assert(isequal(model2, model2b))
% objCoeff
fprintf('>> Done \n\n >> Testing objectiveCoef\n');
model2 = addReaction(model, 'TEST', 'reactionFormula', [model.mets{1} ' <=>'], 'printLevel', 0, 'objectiveCoef', 3);
assert(verifyModel(model2, 'simpleCheck', 1));
model2b = addReaction(model, 'TEST', [model.mets{1} ' <=>'], [], [], [], [], 3);
assert(verifyModel(model2b, 'simpleCheck', 1));
assert(isequal(model2, model2b))
% subSystem
fprintf('>> Done \n\n >> Testing subSystem\n');
model2 = addReaction(model, 'TEST', 'reactionFormula', [model.mets{1} ' <=>'], 'printLevel', 0, 'subSystem', 'testSubSystem');
assert(verifyModel(model2, 'simpleCheck', 1));
model2b = addReaction(model, 'TEST', [model.mets{1} ' <=>'], [], [], [], [], [], 'testSubSystem');
assert(verifyModel(model2b, 'simpleCheck', 1));
assert(isequal(model2, model2b))
% grRule
fprintf('>> Done \n\n >> Testing geneRule\n');
model2 = addReaction(model, 'TEST', 'reactionFormula', [model.mets{1} ' <=>'], 'printLevel', 0, 'geneRule', 'test1 & test2');
assert(verifyModel(model2, 'simpleCheck', 1));
model2b = addReaction(model, 'TEST', [model.mets{1} ' <=>'], [], [], [], [], [], [], 'test1 & test2');
assert(verifyModel(model2b, 'simpleCheck', 1));
nGene = numel(model2.genes);
assert(isequal(model2, model2b) ...
    & isequal(model2.genes(end-1:end), {'test1'; 'test2'}) & strcmp(model2.grRules{end}, 'test1 and test2') ...
    & strcmp(model2.rules{end}, ['x(' num2str(nGene-1) ') & x(' num2str(nGene) ')']))
% geneNameList & systNameList
fprintf('>> Done \n\n >> Testing geneRule with geneNameList and systNameList\n');
model2 = addReaction(model, 'TEST', 'reactionFormula', [model.mets{1} ' <=>'], ...
    'geneRule', 'testGeneName1 & testGeneName2', 'geneNameList', {'testGeneName1'; 'testGeneName2'}, ...
    'systNameList', {'testSystName1'; 'testSystName2'}, 'printLevel', 0);
assert(verifyModel(model2, 'simpleCheck', 1));
model2b = addReaction(model, 'TEST', [model.mets{1} ' <=>'], [], [], [], [], [], [], ...
    'testGeneName1 & testGeneName2', {'testGeneName1'; 'testGeneName2'}, {'testSystName1'; 'testSystName2'});
assert(verifyModel(model2b, 'simpleCheck', 1));
nGene = numel(model2.genes);
assert(isequal(model2, model2b) ...
    & isequal(model2.genes(end-1:end), {'testSystName1'; 'testSystName2'}) & strcmp(model2.grRules{end}, 'testSystName1 and testSystName2') ...
    & strcmp(model2.rules{end}, ['x(' num2str(nGene-1) ') & x(' num2str(nGene) ')']))
% checkDuplicate
fprintf('>> Done \n\n >> Testing checkDuplicate\n');
formula = printRxnFormula(model,'rxnAbbrList', model.rxns(1), 'printFlag', false);
model2 = addReaction(model, 'TEST', 'reactionFormula', formula{1}, 'printLevel', 0, 'checkDuplicate', true, 'printLevel', 0);
assert(verifyModel(model2, 'simpleCheck', 1));
model2b = addReaction(model, 'TEST', formula{1}, [], [], [], [], [], [], [], [], [], true);
assert(verifyModel(model2b, 'simpleCheck', 1));
assert(isequal(model2, model) & isequal(model2b, model2))
model2 = addReaction(model, 'TEST', 'reactionFormula', formula{1}, 'printLevel', 0, 'checkDuplicate', false, 'printLevel', 0);
assert(verifyModel(model2, 'simpleCheck', 1));
model2b = addReaction(model, 'TEST', formula{1}, [], [], [], [], [], [], [], [], [], false);
assert(verifyModel(model2b, 'simpleCheck', 1));
assert(isequal(model2, model2b) & numel(model2.rxns) == numel(model.rxns) + 1)
%Test changeGeneAssociation
newRule = 'Gene1 or b0002 and(b0008 or Gene5)';
model2 = changeGeneAssociation(model, model.rxns(20),newRule);
adaptedNewRule = 'Gene1 or b0002 and ( b0008 or Gene5 )';
assert(isequal(model2.grRules{20},adaptedNewRule));
assert(numel(model.genes) == numel(model2.genes) -2);
assert(all(ismember(model2.genes(end-1:end),{'Gene5','Gene1'})));
fp = FormulaParser();
newRuleBool = ['x(', num2str(find(ismember(model2.genes,'Gene1'))), ') | x(',...
               num2str(find(ismember(model2.genes,'b0002'))), ') & ( x(',...
               num2str(find(ismember(model2.genes,'b0008'))), ') | x(',...
               num2str(find(ismember(model2.genes,'Gene5'))), ') )'];
head = fp.parseFormula(newRuleBool);
head2 = fp.parseFormula(model2.rules{20});
assert(head.isequal(head2)); % We can't make a string comparison so we parse the two formulas and see if they are equal.


fprintf('>> Testing Gene Batch Addition...\n');

genes = {'G1','Gene2','InterestingGene'}';
proteinNames = {'Protein1','Protein B','Protein Alpha'}';
modelWGenes = addGenes(model,genes,...
                            'proteins',proteinNames, 'geneField2',{'D','E','F'});
assert(isequal(lastwarn, 'Field geneField2 is excluded.'));                       
%three new genes.
assert(size(modelWGenes.rxnGeneMat,2) == size(model.rxnGeneMat,2) + 3);
assert(isfield(modelWGenes,'proteins'));
[~,genepos] = ismember(genes,modelWGenes.genes);
assert(isequal(modelWGenes.proteins(genepos),proteinNames));
assert(~isfield(model,'geneField2'));

%Init geneField 2
gField2 = {'D';'E';'F'};
model.geneField2 = cell(size(model.genes));
model.geneField2(:) = {''};
modelWGenes = addGenes(model,genes,...
                            'proteins',proteinNames, 'geneField2',gField2);
[~,genepos] = ismember(genes,modelWGenes.genes);
assert(isequal(modelWGenes.geneField2(genepos), gField2));
assert(all(cellfun(@(x) isequal(x,''),modelWGenes.geneField2(~ismember(modelWGenes.genes,genes)))));
gprRule = '(G1 or InterestingGene) and Gene2 or (Gene2 and G1)';
ruleWithoutG1 = 'InterestingGene and Gene2';
ruleWithoutG2 = 'InterestingGene and Gene2 or Gene2';



%And finally test duplication errors.
assert(verifyCobraFunctionError('addGenes', 'inputs', {model,{'b0008','G1'}}));
assert(verifyCobraFunctionError('addGenes', 'inputs', {model,{'G2','G1','G2'}}));

modelMod = changeGeneAssociation(model,model.rxns{1},gprRule);
modelMod = changeGeneAssociation(modelMod,modelMod.rxns{2},ruleWithoutG1);
modelMod = changeGeneAssociation(modelMod,modelMod.rxns{3},ruleWithoutG2);

fprintf('>> Done \n\n >> Testing Gene removal...\n');

%Test removal of a gene
modelMod1 = removeGenesFromModel(modelMod,'G1');
% now, rules{1} and rules{3} should be equal;
fp = FormulaParser();
rule = fp.parseFormula(modelMod1.rules{1});
rule2 = fp.parseFormula(modelMod1.rules{3});
assert(rule2.isequal(rule));
% and now without keeping the clauses
modelMod2 = removeGenesFromModel(modelMod,'G1','keepClauses',false);
fp = FormulaParser();
rule = fp.parseFormula(modelMod2.rules{1});
rule2 = fp.parseFormula(modelMod2.rules{2});
assert(rule2.isequal(rule));

fprintf('>> Done\n');

% change the directory
cd(currentDir)
