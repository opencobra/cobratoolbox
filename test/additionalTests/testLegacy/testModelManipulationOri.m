% The COBRAToolbox: testModelManipulationOri.m
% Requires fork-cobratoolbox/external/base/utilities/cellstructeq
%
% Purpose:
%     - testModelManipulationOri tests backward compatibility of the new
%     versions with the old versions of each of these files

% addDemandReactionOri.m
% addReactionOri.m
% computeMin2Norm_HH.m
% fastLeakTestOri.m
% printRxnFormulaOri.m
% addExchangeRxnOri.m
% changeGeneAssociationOri.m
% computeMin2Norm_HH_ori.m
% fluxVariabilityOri.m
% removeRxnsOri.m

%       first creates a simple toy network with basic S, lb, ub, rxns, mets
%       tests addReaction, removeReaction, removeMetabolite
%       then creates an empty matrix and does the previous procedures.
%       Then tests convertToReversible, and convertToIrreversible using the
%       iJR904 model. Prints whether each test was successful or not.
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testModelManipulationOri'));
cd(fileDir);

% Test with non-empty model
fprintf('>> Starting testModelManipulationOri :\n');

if 1
    % load the ecoli_core_model
    model = getDistributedModel('ecoli_core_model.mat');
else
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
    model.genes = {'testGene'};
    sc =  [-1, 0, 0, 0, 2, 0, 0, 0, 3, 0, 0, 0];
    mets_length = length(model.mets);
    rxns_length = length(model.rxns);
end



% [modelClosed, rxnIDexists] = addReactionOri(modelClosed,'DM_atp_c_',  'h2o[c] + atp[c]  -> adp[c] + h[c] + pi[c] ');
% edit addReaction
% [modelClosed2, rxnIDexists] = addReaction(model, 'DM_atp_c_', 'reactionFormula', 'h2o[c] + atp[c]  -> adp[c] + h[c] + pi[c] ');
% isequal(modelClosed,modelClosed2)
% isequaln(modelClosed,modelClosed2)
% edit /home/rfleming/work/sbgCloud/code/fork-cobratoolbox/external/base/utilities/cellstructeq
% cd /home/rfleming/work/sbgCloud/code/fork-cobratoolbox/external/base/utilities/cellstructeq

%save the original model
modelDefault = model;

% adding a reaction to the model
model = addReaction(modelDefault, 'DM_atp_c_', 'reactionFormula', 'h2o[c] + atp[c]  -> adp[c] + h[c] + pi[c] ');
modelOri = addReactionOri(modelDefault, 'DM_atp_c_', 'h2o[c] + atp[c]  -> adp[c] + h[c] + pi[c] ');
modelOri = rmfield(modelOri,'rev'); %depreciated
%modelOri = rmfield(modelOri,'rxnGeneMat');%incorrectly not updated
modelOri.rxnGeneMat(end+1,:)=model.rxnGeneMat(end,:);
% model.subSystems{96}
%   1×1 cell array
%     {0×0 char}
%
% modelOri.subSystems{96}
%   0×0 empty char array
modelOri.subSystems{end}=model.subSystems{end};

%check that the models are the same
[result, why] = structeq(model, modelOri);
if ~result
    model
    modelOri
    why
end
assert(result);

%[model, rxnIDexists] = addReaction(model, rxnID, varargin)
%                         * reactionName - a Descriptive name of the reaction
%                           (default ID)
%                         * metaboliteList - Cell array of metabolite names. Either this
%                           parameter or reactionFormula are required.
%                         * stoichCoeffList - List of stoichiometric coefficients (reactants -ve,
%                           products +ve), if not provided, all stoichiometries
%                           are assumed to be -1 (Exchange, or consumption).
%                         * reactionFormula - A Reaction formula in string format ('A + B -> C').
%                           If this parameter is provided metaboliteList MUST
%                           be empty, and vice versa.
%                         * reversible - Reversibility flag (Default = true)
%                         * lowerBound - Lower bound (Default = 0 or -vMax`)
%                         * upperBound - Upper bound (Default = `vMax`)
%                         * objectiveCoef - Objective coefficient (Default = 0)
%                         * subSystem - Subsystem (Default = {''})
%                         * geneRule - Gene-reaction rule in boolean format (and/or allowed)
%                           (Default = '');
%                         * geneNameList - List of gene names (used only for translation from
%                           common gene names to systematic gene names) (Default empty)
%                         * systNameList - List of systematic names (Default empty)
%                         * checkDuplicate - Check `S` matrix too see if a duplicate reaction is
%                           already in the model (Deafult false)
%                         * printLevel - default = 0
model = addReaction(modelDefault,'Ex_RxnsAll[c]','metaboliteList',{'atp[c]','adp[c]'},'stoichCoeffList',[-1,1],...
    'lowerBound',0,'upperBound',1000,'objectiveCoef',0,'subSystem',{'Transport'},'geneRule','','geneNameList',[],'systNameList',[],'checkDuplicate',0,'printLevel',0);

% metaboliteList = [metaboliteList metaboliteListA];
% stoichCoeffList = [-1 1];
% if LB < 0
%     revFlag = 1;
% else
%     revFlag = 0;
% end
% RxnName = strcat(model.rxnNames{b},' (from ',strcat('[',OldComp,']'),' to ',NewCompName,')');
% modelComp = addReactionOri(modelComp,{strcat(Ex_RxnsAll{i},'_[',NewComp,']'),RxnName},metaboliteList,stoichCoeffList,...
%     revFlag,LB,UB,0,strcat('Transport'),'',[],[],0,0);

%[model,rxnIDexists] = addReactionOri(model,rxnName,metaboliteList,stoichCoeffList,revFlag,lowerBound,upperBound,objCoeff,subSystem,grRule,geneNameList,systNameList,checkDuplicate, addRxnGeneMat)
modelOri = addReactionOri(modelDefault,'Ex_RxnsAll[c]',{'atp[c]','adp[c]'},[-1,1],0,0,1000,0,strcat('Transport'),'',[],[],0,0);

modelOri = rmfield(modelOri,'rev'); %depreciated
modelOri.rxnGeneMat(end+1,:)=model.rxnGeneMat(end,:);
modelOri.subSystems{end}=model.subSystems{end};
%modelOri.rxnNames{end+1}=model.rxnNames{end};

%check that the models are the same
[result, why] = structeq(model, modelOri);
if ~result
    model
    modelOri
    why
end
assert(result);

%add a coupling constraint to make it a bit more realistic
modelDefault = addCouplingConstraint(modelDefault, {'FRD7','SUCDi'}, [1,1], 1, 'G');

model = addDemandReaction(modelDefault, 'glc-D[e]');
modelOri = addDemandReactionOri(modelDefault, 'glc-D[e]');
modelOri.C = model.C;
modelOri = rmfield(modelOri,'rev');

%check that the models are the same
[result, why] = structeq(model, modelOri);
if ~result
    model
    modelOri
    why
end
assert(result);

model = addDemandReaction(modelDefault, 'pi[c]');
modelOri = addDemandReactionOri(modelDefault, 'pi[c]');
modelOri = rmfield(modelOri,'rev');
modelOri.C = model.C;

%check that the models are the same
[result, why] = structeq(model, modelOri);
if ~result
    model
    modelOri
    why
end
assert(result);

model = addExchangeRxn(modelDefault,{'q8h2[c]'},-1000,1000);
modelOri = addExchangeRxnOri(modelDefault,{'q8h2[c]'},-1000,1000);
modelOri = rmfield(modelOri,'rev');
modelOri.rxnGeneMat = model.rxnGeneMat;
modelOri.subSystems{end} = model.subSystems{end};
modelOri.C = model.C;

%check that the models are the same
[result, why] = structeq(model, modelOri);
if ~result
    model
    modelOri
    why
end
assert(result);


model = changeGeneAssociation(modelDefault,modelDefault.rxns{1},'(b1812 or b0485 or b1524)');
modelOri = changeGeneAssociationOri(modelDefault,modelDefault.rxns{1},'(b1812 or b0485 or b1524)');
% model.rules{1}    '( x(53) | x(10) | x(41) )'
% modelOri.rules{1} '(x(53) | x(10) | x(41))'    %only slight difference in formatting
modelOri.rules{1}=model.rules{1};
% modelOri.grRules{1} '(b1812 or b0485 or b1524)'
% model.grRules{1}    '( b1812 or b0485 or b1524 )' %only slight difference in formatting
modelOri.grRules{1}=model.grRules{1};
%check that the models are the same
[result, why] = structeq(model, modelOri);
if ~result
    model
    modelOri
    why
end
assert(result);

% %TODO replace with changeGeneAssociation
% modelAllComp = changeGeneAssociationOri(modelAllComp,modelAllComp.rxns{j},char(modelAllCompgrRule{j}));
                
% function formulas = printRxnFormula(model, varargin)
% %                       * rxnAbbrList:       Cell array of rxnIDs to be printed (Default = print all reactions)
% %                       * printFlag:         Print formulas or just return them (Default = true)
% %                       * lineChangeFlag:    Append a line change at the end of each line
% %                                            (Default = true)
% %                       * metNameFlag:       Print full met names instead of abbreviations
% %                                            (Default = false)
% %                       * fid:               Optional file identifier for printing in files
% %                                            (default 1, i.e. stdout)
% %                       * directionFlag:     Checks directionality of reaction. See Note.
% %                                            (Default = false)
% %                       * gprFlag:           Print gene protein reaction association
% %                                            (Default = false)
% %                       * proteinFlag:       Print the protein names associated with the genes in the 
% %                                            GPRs associated with the reactions. (Default = false)
% %                       * printBounds:       Print the upper and lower Bounds of the reaction (Default = false)
a = printRxnFormula(modelDefault,'rxnAbbrList',modelDefault.rxns(1),'printFlag',0,'lineChangeFlag',0,'metNameFlag',0,'fid',0,'directionFlag',0);

%formulas = printRxnFormulaOri(model,rxnAbbrList,           printFlag,lineChangeFlag,metNameFlag,fid,directionFlag)
aOri = printRxnFormulaOri(modelDefault,modelDefault.rxns{1},0        ,0             ,0          ,'' ,0);
if ~isequal(a,aOri)
    a
    aOri
end
assert(isequal(a,aOri));

modelTmp = findSExRxnInd(modelDefault);
rxnAbbrList = modelDefault.rxns(~modelTmp.SIntRxnBool);

a = printRxnFormula(modelDefault,'rxnAbbrList',rxnAbbrList,'printFlag',0,'lineChangeFlag',0,'metNameFlag',0,'fid',0,'directionFlag',0);

%formulas = printRxnFormulaOri(model,rxnAbbrList,           printFlag,lineChangeFlag,metNameFlag,fid,directionFlag)
aOri = printRxnFormulaOri(modelDefault, rxnAbbrList,               [],            [],         [], [],        false);
if ~isequal(a,aOri)
    a
    aOri
end
assert(isequal(a,aOri));

a = printRxnFormula(modelDefault,'rxnAbbrList',rxnAbbrList,'printFlag',0,'lineChangeFlag',1,'metNameFlag',0,'fid',1,'directionFlag',0);
aOri = printRxnFormulaOri(modelTmp,rxnAbbrList,0,1,0,1,0);
if ~isequal(a,aOri)
    a
    aOri
end
assert(isequal(a,aOri));

%printRxnFormula(modelDefault,'rxnAbbrList','Biomass_Ecoli_core_w_GAM');
%printRxnFormulaOri(modelDefault,'Biomass_Ecoli_core_w_GAM');


%
% % adding a reaction to the model (test only)
% model = addReaction(model, 'ABC_def', sort(model.mets), 2 * sc, 0, -5, 10);
% assert(any(ismember(model.rxns,'ABC_def')));
%
% reactionPos = ismember(model.rxns,'ABC_def');
% [~,metPos] = ismember(sort(model.mets),model.mets);
% assert(all(model.S(metPos,reactionPos) == 2*sc')); %Correct stoichiometry
% assert(model.lb(reactionPos) == -5);
% assert(model.ub(reactionPos) == 10);
%
%
%
% %Now, add some fields by an extensive addReaction call
% modelWithFields = addReaction(model,'TestReaction','reactionFormula','A + B -> C','subSystem','Some Sub','geneRule','GeneA or GeneB');
% assert(verifyModel(modelWithFields,'simpleCheck',true,'requiredFields',{}))
%
% %Also add a Constraint to the model
% model = addCOBRAConstraints(model,{'GLCt1'; 'HEX1'; 'PGI'},[1000,50],'c',[1,1,0;0,0,1],'dsense','LL');
%
% %And test this also with a different input of subSystems:
% modelWithFields = addReaction(model,'TestReaction','reactionFormula','A + B -> C','subSystem',{'Some Sub', 'And another sub'},'geneRule','GeneA or GeneB');
% assert(verifyModel(modelWithFields,'simpleCheck',true,'requiredFields',{}))
% assert(size(modelWithFields.C,2) == size(modelWithFields.S,2));
%
% %Trying to add a reaction without stoichiometry will fail.
% errorCall = @() addReaction(model,'NoStoich');
% assert(verifyCobraFunctionError('addReaction', 'inputs',{model,'NoStoich'}));
%
% %Try adding a new reaction with two different stoichiometries
%
% assert(verifyCobraFunctionError('addReaction', 'inputs', {model, 'reactionFormula', 'A + B -> C','stoichCoeffList',[ -1 2], 'metaboliteList',{'A','C'}}));
%
% %Try having a metabolite twice in the metabolite list or reaction formula
% modelWAddedMet = addReaction(model, 'reactionFormula', 'Alpha + Beta -> Gamma + 2 Beta');
% assert(modelWAddedMet.S(ismember(modelWAddedMet.mets,'Beta'),end) == 1);
%
% %Try to change metabolites of a specific reaction
% exchangedMets = {'atp','adp','pi'};
% [A,B] = ismember(exchangedMets,modelWAddedMet.mets);
% exMetPos = B(A);
% newMets = {'Alpha','Beta','Gamma'};
% [A,B] = ismember(newMets,modelWAddedMet.mets);
% newMetPos = B(A);
% HEXPos = ismember(modelWAddedMet.rxns,'HEX1');
% FBPPos = ismember(modelWAddedMet.rxns,'FBP');
% oldvaluesHEX = modelWAddedMet.S(exMetPos,HEXPos);
% oldvaluesFBP = modelWAddedMet.S(exMetPos,FBPPos);
% [modelWAddedMetEx,changedRxns] = changeRxnMets(modelWAddedMet,exchangedMets,newMets,{'HEX1','FBP'});
% %The new metabolites have the right values
% assert(all(modelWAddedMetEx.S(newMetPos,HEXPos)==oldvaluesHEX));
% assert(all(modelWAddedMetEx.S(newMetPos,FBPPos)==oldvaluesFBP));
% assert(all(modelWAddedMetEx.S(exMetPos,HEXPos) == 0));
% assert(all(modelWAddedMetEx.S(exMetPos,FBPPos) == 0));
%
% %Also give new Stoichiometry
% newStoich = [ 1 4; 2 5; 3 6];
% [modelWAddedMetEx,changedRxns] = changeRxnMets(modelWAddedMet,exchangedMets,newMets,{'HEX1','FBP'},newStoich);
% %The new metabolites have the right values
% assert(all(modelWAddedMetEx.S(newMetPos,HEXPos)==newStoich(:,1)));
% assert(all(modelWAddedMetEx.S(newMetPos,FBPPos)==newStoich(:,2)));
% assert(all(modelWAddedMetEx.S(exMetPos,HEXPos) == 0));
% assert(all(modelWAddedMetEx.S(exMetPos,FBPPos) == 0));
%
% %And try random ones.
% %Also give new Stoichiometry
% newStoich = [ 1 2 3; 4 5 6];
% [modelWAddedMetEx,changedRxns] = changeRxnMets(modelWAddedMet,exchangedMets,newMets,2);
% OldPos1 = ismember(modelWAddedMet.rxns,changedRxns{1});
% OldPos2 = ismember(modelWAddedMet.rxns,changedRxns{2});
% oldvalues1 = modelWAddedMet.S(exMetPos,OldPos1);
% oldvalues2 = modelWAddedMet.S(exMetPos,OldPos2);
% %The new metabolites have the right values
% assert(all(modelWAddedMetEx.S(newMetPos,OldPos1)==oldvalues1));
% assert(all(modelWAddedMetEx.S(newMetPos,OldPos2)==oldvalues2));
% assert(all(modelWAddedMetEx.S(exMetPos,OldPos1) == 0));
% assert(all(modelWAddedMetEx.S(exMetPos,OldPos2) == 0));
%
%
% % check if the number of reactions was incremented by 1
% assert(length(model.rxns) == rxns_length + 2);
%
% % adding a reaction to the model (test only)
% model = addReaction(model, 'ABC_def', model.mets, 3 * sc);
%
% % remove the reaction from the model
% model = removeRxns(model, {'EX_glc'});
%
% % remove the reaction from the model
% model = removeRxns(model, {'ABC_def'});
%
% % add exchange reaction
% modelWEx = addExchangeRxn(model, {'glc-D[e]'; 'glc-D'});
% %We added two reactions, check that.
% assert(numel(modelWEx.rxns) == numel(model.rxns)+2);
%
% %Now try again, this time, we should get the same model
% modelWEx2 = addExchangeRxn(modelWEx, {'glc-D[e]'; 'glc-D'});
% assert(isSameCobraModel(modelWEx,modelWEx2));
%
% %check if rxns length was decremented by 1
% assert(length(model.rxns) == rxns_length);
%
% % add a new reaction to the model
% model = addReaction(model,'newRxn1','A -> B + 2 C');
%
% % check if the number of reactions was incremented by 1
% assert(length(model.rxns) == rxns_length + 1);
%
% % check if the number of metabolites was incremented by 3
% assert(length(model.mets) == mets_length + 3);
%
% % change the reaction bounds
% model = changeRxnBounds(model, model.rxns, 2, 'u');
% assert(model.ub(1) == 2);
%
% % remove the reaction
% model = removeRxns(model, {'newRxn1'});
% assert(length(model.rxns) == rxns_length);
%
% % remove some metabolites
% model = removeMetabolites(model, {'A', 'B', 'C'});
% assert(length(model.mets) == mets_length);
%
% % Tests with empty model
% fprintf('>> Starting empty model tests:\n');
%
% model.S = [];
% model.rxns = {};
% model.mets = {};
% model.lb = [];
% model.ub = [];
%
% rxns_length = 0;
% mets_length = 0;
%
% % add a reaction
% model = addReaction(model,'newRxn1','A -> B + 2 C');
%
% % check if the number of reactions was incremented by 1
% assert(length(model.rxns) == rxns_length + 1);
%
% % check if the number of metabolites was incremented by 3
% assert(length(model.mets) == mets_length + 3);
%
% % change the reaction bounds
% model = changeRxnBounds(model, model.rxns, 2, 'u');
% assert(model.ub(1) == 2);
%
% % remove the reaction
% model = removeRxns(model, {'newRxn1'});
% assert(length(model.rxns) == rxns_length);
%
% % remove some metabolites
% model = removeMetabolites(model, {'A', 'B', 'C'});
% assert(length(model.mets) == mets_length);
%
% % Convert to irreversible
% fprintf('>> Testing convertToIrreversible (1)\n');
% model = readCbModel('testModelManipulation.mat','modelName', 'model');
% assert(verifyModel(model, 'simpleCheck', 1));
% modelIrrev = readCbModel('testModelManipulation.mat','modelName', 'modelIrrev');
% assert(verifyModel(modelIrrev, 'simpleCheck', 1));
% [testModelIrrev, matchRev, rev2irrev, irrev2rev] = convertToIrreversible(model);
% testModelIrrev.modelID = 'modelIrrev'; % newer COBRA models have modelID
%
% % test if both models are the same
% assert(isSameCobraModel(modelIrrev, testModelIrrev));
%
% % Convert to reversible
% fprintf('>> Testing convertToReversible\n');
% testModelRev = convertToReversible(testModelIrrev);
% testModelRev = rmfield(testModelRev,'reversibleModel'); % this should now be the original model!
%
% % test if both models are the same
% testModelRev.modelID = 'model'; % newer COBRA models have modelID
% assert(isSameCobraModel(model,testModelRev));
%
% % test irreversibility of model
% fprintf('>> Testing convertToIrreversible (2)\n');
% model = readCbModel('testModelManipulation.mat','modelName', 'model');
% assert(verifyModel(model, 'simpleCheck', 1));
% modelIrrev = readCbModel('testModelManipulation.mat','modelName', 'modelIrrev');
% assert(verifyModel(modelIrrev, 'simpleCheck', 1));
%
% % set a lower bound to positive (faulty model)
% modelRev.lb(1) = 10;
% [testModelIrrev, matchRev, rev2irrev, irrev2rev] = convertToIrreversible(model);
% testModelIrrev.modelID = 'modelIrrev'; % newer COBRA models have modelID
%
% % test if both models are the same
% assert(isSameCobraModel(modelIrrev, testModelIrrev));
%
%
% %test Conversion with special ordering
% fprintf('>> Testing convertToIrreversible (3)\n');
% model = readCbModel('testModelManipulation.mat','modelName', 'model');
% assert(verifyModel(model, 'simpleCheck', 1));
% modelIrrevOrdered = readCbModel('testModelManipulation.mat','modelName', 'modelIrrevOrdered');
% assert(verifyModel(modelIrrevOrdered, 'simpleCheck', 1));
%
% [testModelIrrev, matchRev, rev2irrev, irrev2rev] = convertToIrreversible(model, 'orderReactions', true);
% testModelIrrev.modelID = 'modelIrrevOrdered'; % newer COBRA models have modelID
%
% % test if both models are the same
% assert(isSameCobraModel(modelIrrevOrdered, testModelIrrev));
%
%
% %Test moveRxn
% model2 = moveRxn(model,10,20);
% fields = getModelFieldsForType(model,'rxns');
% rxnSize = numel(model.rxns);
% for i = 1:numel(fields)
%     if size(model.(fields{i}),1) == rxnSize
%         val1 = model.(fields{i})(10,:);
%         val2 = model2.(fields{i})(20,:);
%     elseif size(model.(fields{i}),2) == rxnSize
%         val1 = model.(fields{i})(:,10);
%         val2 = model2.(fields{i})(:,20);
%     end
%     assert(isequal(val1,val2));
% end
%
% % Test addReaction with name-value argument input
% fprintf('>> Testing addReaction with name-value argument input\n');
% % options available in the input:
% name = {'reactionName', 'reversible', ...
%     'lowerBound', 'upperBound', 'objectiveCoef', 'subSystem', 'geneRule', ...
%     'geneNameList', 'systNameList', 'checkDuplicate'};
% value = {'TEST', true, ...
%     -1000, 1000, 0, '', '', ...
%     {}, {}, true};
% arg = [name; value];
% model2 = addReaction(model, 'TEST', 'reactionFormula', [model.mets{1} ' <=>'], arg{:});
% assert(verifyModel(model2, 'simpleCheck', 1));
% for k = 1:numel(name)
%     % test differet optional name-value argument as the first argument after rxnID
%     model2b = addReaction(model, 'TEST', name{k}, value{k}, 'printLevel', 0, 'reactionFormula', [model.mets{1} ' <=>']);
%     assert(verifyModel(model2b, 'simpleCheck', 1));
%     assert(isequal(model2, model2b))
%
%     model2b = addReaction(model, 'TEST', name{k}, value{k}, 'printLevel', 0, 'metaboliteList', model.mets(1), 'stoichCoeffList', -1);
%     assert(verifyModel(model2b, 'simpleCheck', 1));
%     assert(isequal(model2, model2b))
%
%     % test differet optional name-value argument as argument after reactionFormula or stoichCoeffList
%     model2b = addReaction(model, 'TEST', 'printLevel', 0, 'reactionFormula', [model.mets{1} ' <=>'], name{k}, value{k});
%     assert(verifyModel(model2b, 'simpleCheck', 1));
%     assert(isequal(model2, model2b))
%
%     model2b = addReaction(model, 'TEST', 'printLevel', 0, 'metaboliteList', model.mets(1), 'stoichCoeffList', -1, name{k}, value{k});
%     assert(verifyModel(model2b, 'simpleCheck', 1));
%     assert(isequal(model2, model2b))
% end
%
% % Test addReaction backward compatibility
% % backward signature: model = addReaction(model,rxnName,metaboliteList,stoichCoeffList,revFlag,lowerBound,upperBound,objCoeff,subSystem,grRule,geneNameList,systNameList,checkDuplicate)
% % reactionName
% fprintf('>> Done \n\n >> Testing reactionFormula\n');
% model2 = addReaction(model, 'TEST', 'reactionFormula', [model.mets{1} ' <=>'], 'printLevel', 0, 'reactionName', 'TestReaction');
% assert(verifyModel(model2, 'simpleCheck', 1));
% model2b = addReaction(model, {'TEST', 'TestReaction'}, [model.mets{1} ' <=>']);
% assert(verifyModel(model2b, 'simpleCheck', 1));
% assert(isequal(model2, model2b))
% % metaboliteList & stoichCoeffList
% fprintf('>> Done \n\n >> Testing metaboliteList & stoichCoeffList\n');
% model2 = addReaction(model, 'TEST', 'metaboliteList', model.mets(1), 'printLevel', 0, 'stoichCoeffList', -1);
% assert(verifyModel(model2, 'simpleCheck', 1));
% model2b = addReaction(model, 'TEST', model.mets(1), -1);
% assert(verifyModel(model2b, 'simpleCheck', 1));
% assert(isequal(model2, model2b))
% % revFlag
% fprintf('>> Done \n\n >> Testing reversible\n');
% model2 = addReaction(model, 'TEST', 'metaboliteList', model.mets(1), 'printLevel', 0, 'stoichCoeffList', -1, 'reversible', 0);
% assert(verifyModel(model2, 'simpleCheck', 1));
% model2b = addReaction(model, 'TEST', model.mets(1), -1, 0);
% assert(verifyModel(model2b, 'simpleCheck', 1));
% assert(isequal(model2, model2b))
% % irreversible revFlag overridden by reversible reaction formula
% model2 = addReaction(model, 'TEST', 'reactionFormula', [model.mets{1} ' <=>'], 'printLevel', 0, 'stoichCoeffList', -1, 'reversible', 0);
% assert(verifyModel(model2, 'simpleCheck', 1));
% model2b = addReaction(model, 'TEST', [model.mets{1} ' <=>'], [], 0);
% assert(verifyModel(model2b, 'simpleCheck', 1));
% assert(isequal(model2, model2b))
% % lowerBound
% fprintf('>> Done \n\n >> Testing lowerBound\n');
% model2 = addReaction(model, 'TEST', 'reactionFormula', [model.mets{1} ' <=>'], 'printLevel', 0, 'lowerBound', -10);
% assert(verifyModel(model2, 'simpleCheck', 1));
% model2b = addReaction(model, 'TEST', [model.mets{1} ' <=>'], [], [], -10);
% assert(verifyModel(model2b, 'simpleCheck', 1));
% assert(isequal(model2, model2b))
% % upperBound
% fprintf('>> Done \n\n >> Testing upperBound\n');
% model2 = addReaction(model, 'TEST', 'reactionFormula', [model.mets{1} ' <=>'], 'printLevel', 0, 'upperBound', 10);
% assert(verifyModel(model2, 'simpleCheck', 1));
% model2b = addReaction(model, 'TEST', [model.mets{1} ' <=>'], [], [], [], 10);
% assert(verifyModel(model2b, 'simpleCheck', 1));
% assert(isequal(model2, model2b))
% % objCoeff
% fprintf('>> Done \n\n >> Testing objectiveCoef\n');
% model2 = addReaction(model, 'TEST', 'reactionFormula', [model.mets{1} ' <=>'], 'printLevel', 0, 'objectiveCoef', 3);
% assert(verifyModel(model2, 'simpleCheck', 1));
% model2b = addReaction(model, 'TEST', [model.mets{1} ' <=>'], [], [], [], [], 3);
% assert(verifyModel(model2b, 'simpleCheck', 1));
% assert(isequal(model2, model2b))
% % subSystem
% fprintf('>> Done \n\n >> Testing subSystem\n');
% model2 = addReaction(model, 'TEST', 'reactionFormula', [model.mets{1} ' <=>'], 'printLevel', 0, 'subSystem', 'testSubSystem');
% assert(verifyModel(model2, 'simpleCheck', 1));
% model2b = addReaction(model, 'TEST', [model.mets{1} ' <=>'], [], [], [], [], [], 'testSubSystem');
% assert(verifyModel(model2b, 'simpleCheck', 1));
% assert(isequal(model2, model2b))
% % grRule
% fprintf('>> Done \n\n >> Testing geneRule\n');
% model2 = addReaction(model, 'TEST', 'reactionFormula', [model.mets{1} ' <=>'], 'printLevel', 0, 'geneRule', 'test1 & test2');
% assert(verifyModel(model2, 'simpleCheck', 1));
% model2b = addReaction(model, 'TEST', [model.mets{1} ' <=>'], [], [], [], [], [], [], 'test1 & test2');
% assert(verifyModel(model2b, 'simpleCheck', 1));
% nGene = numel(model2.genes);
% assert(isequal(model2, model2b) ...
%     & isequal(model2.genes(end-1:end), {'test1'; 'test2'}) & strcmp(model2.grRules{end}, 'test1 and test2') ...
%     & strcmp(model2.rules{end}, ['x(' num2str(nGene-1) ') & x(' num2str(nGene) ')']))
% % geneNameList & systNameList
% fprintf('>> Done \n\n >> Testing geneRule with geneNameList and systNameList\n');
% model2 = addReaction(model, 'TEST', 'reactionFormula', [model.mets{1} ' <=>'], ...
%     'geneRule', 'testGeneName1 & testGeneName2', 'geneNameList', {'testGeneName1'; 'testGeneName2'}, ...
%     'systNameList', {'testSystName1'; 'testSystName2'}, 'printLevel', 0);
% assert(verifyModel(model2, 'simpleCheck', 1));
% model2b = addReaction(model, 'TEST', [model.mets{1} ' <=>'], [], [], [], [], [], [], ...
%     'testGeneName1 & testGeneName2', {'testGeneName1'; 'testGeneName2'}, {'testSystName1'; 'testSystName2'});
% assert(verifyModel(model2b, 'simpleCheck', 1));
% nGene = numel(model2.genes);
% assert(isequal(model2, model2b) ...
%     & isequal(model2.genes(end-1:end), {'testSystName1'; 'testSystName2'}) & strcmp(model2.grRules{end}, 'testSystName1 and testSystName2') ...
%     & strcmp(model2.rules{end}, ['x(' num2str(nGene-1) ') & x(' num2str(nGene) ')']))
% % checkDuplicate
% fprintf('>> Done \n\n >> Testing checkDuplicate\n');
% formula = printRxnFormula(model,'rxnAbbrList', model.rxns(1), 'printFlag', false);
% model2 = addReaction(model, 'TEST', 'reactionFormula', formula{1}, 'printLevel', 0, 'checkDuplicate', true, 'printLevel', 0);
% assert(verifyModel(model2, 'simpleCheck', 1));
% model2b = addReaction(model, 'TEST', formula{1}, [], [], [], [], [], [], [], [], [], true);
% assert(verifyModel(model2b, 'simpleCheck', 1));
% assert(isequal(model2, model) & isequal(model2b, model2))
% model2 = addReaction(model, 'TEST', 'reactionFormula', formula{1}, 'printLevel', 0, 'checkDuplicate', false, 'printLevel', 0);
% assert(verifyModel(model2, 'simpleCheck', 1));
% model2b = addReaction(model, 'TEST', formula{1}, [], [], [], [], [], [], [], [], [], false);
% assert(verifyModel(model2b, 'simpleCheck', 1));
% assert(isequal(model2, model2b) & numel(model2.rxns) == numel(model.rxns) + 1)
% %Test changeGeneAssociation
% newRule = 'Gene1 or b0002 and(b0008 or Gene5)';
% model2 = changeGeneAssociation(model, model.rxns(20),newRule);
% adaptedNewRule = 'Gene1 or b0002 and ( b0008 or Gene5 )';
% assert(isequal(model2.grRules{20},adaptedNewRule));
% assert(numel(model.genes) == numel(model2.genes) -2);
% assert(all(ismember(model2.genes(end-1:end),{'Gene5','Gene1'})));
% fp = FormulaParser();
% newRuleBool = ['x(', num2str(find(ismember(model2.genes,'Gene1'))), ') | x(',...
%                num2str(find(ismember(model2.genes,'b0002'))), ') & ( x(',...
%                num2str(find(ismember(model2.genes,'b0008'))), ') | x(',...
%                num2str(find(ismember(model2.genes,'Gene5'))), ') )'];
% head = fp.parseFormula(newRuleBool);
% head2 = fp.parseFormula(model2.rules{20});
% assert(head.isequal(head2)); % We can't make a string comparison so we parse the two formulas and see if they are equal.
%
%
% fprintf('>> Testing Gene Batch Addition...\n');
%
% genes = {'G1','Gene2','InterestingGene'}';
% proteinNames = {'Protein1','Protein B','Protein Alpha'}';
% modelWGenes = addGenes(model,genes,...
%                             'proteins',proteinNames, 'geneField2',{'D','E','F'});
% assert(isequal(lastwarn, 'Field geneField2 is excluded.'));
% %three new genes.
% assert(size(modelWGenes.rxnGeneMat,2) == size(model.rxnGeneMat,2) + 3);
% assert(isfield(modelWGenes,'proteins'));
% [~,genepos] = ismember(genes,modelWGenes.genes);
% assert(isequal(modelWGenes.proteins(genepos),proteinNames));
% assert(~isfield(model,'geneField2'));
%
% %Init geneField 2
% gField2 = {'D';'E';'F'};
% model.geneField2 = cell(size(model.genes));
% model.geneField2(:) = {''};
% modelWGenes = addGenes(model,genes,...
%                             'proteins',proteinNames, 'geneField2',gField2);
% [~,genepos] = ismember(genes,modelWGenes.genes);
% assert(isequal(modelWGenes.geneField2(genepos), gField2));
% assert(all(cellfun(@(x) isequal(x,''),modelWGenes.geneField2(~ismember(modelWGenes.genes,genes)))));
% gprRule = '(G1 or InterestingGene) and Gene2 or (Gene2 and G1)';
% ruleWithoutG1 = 'InterestingGene and Gene2';
% ruleWithoutG2 = 'InterestingGene and Gene2 or Gene2';
%
%
%
% %And finally test duplication errors.
% assert(verifyCobraFunctionError('addGenes', 'inputs', {model,{'b0008','G1'}}));
% assert(verifyCobraFunctionError('addGenes', 'inputs', {model,{'G2','G1','G2'}}));
%
% modelMod = changeGeneAssociation(model,model.rxns{1},gprRule);
% modelMod = changeGeneAssociation(modelMod,modelMod.rxns{2},ruleWithoutG1);
% modelMod = changeGeneAssociation(modelMod,modelMod.rxns{3},ruleWithoutG2);
%
% fprintf('>> Done \n\n >> Testing Gene removal...\n');
%
% %Test removal of a gene
% modelMod1 = removeGenesFromModel(modelMod,'G1');
% % now, rules{1} and rules{3} should be equal;
% fp = FormulaParser();
% rule = fp.parseFormula(modelMod1.rules{1});
% rule2 = fp.parseFormula(modelMod1.rules{3});
% assert(rule2.isequal(rule));
% % and now without keeping the clauses
% modelMod2 = removeGenesFromModel(modelMod,'G1','keepClauses',false);
% fp = FormulaParser();
% rule = fp.parseFormula(modelMod2.rules{1});
% rule2 = fp.parseFormula(modelMod2.rules{2});
% assert(rule2.isequal(rule));
%
% % Test the warning for an invalid gene
% modelMod1 = removeGenesFromModel(modelMod,'G231');
% assert(isequal(sprintf('The following genes were not part of the model:\nG231'),lastwarn));
% modelMod1 = removeGenesFromModel(modelMod,{'G231','G27'});
% assert(isequal(sprintf('The following genes were not part of the model:\nG231, G27'),lastwarn));


fprintf('>> Done\n');

% change the directory
cd(currentDir)
