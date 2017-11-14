% The COBRAToolbox: testSubSystemModification.m
%
% Purpose:
%     - test Manipulation of subSystems and retrieval by subSystems in
%     addSubSystemsToReactions, setRxnSubSystem, removeSubSystemFromReaction,
%     findRxnsFromSubSystem, getModelSubSystems, isReactionInSubSystem
%
% Authors:
%     Thomas Pfau - Nov 2017


% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSubSystemModification.m'));
cd(fileDir);

model = getDistributedModel('ecoli_core_model.mat');
%This is a correct model. Now lets do some subSystem Manipulation
originalSubSystems = {'Exchange','Anaplerotic reactions','Citric Acid Cycle','Glutamate Metabolism','Glycolysis/Gluconeogenesis','Inorganic Ion Transport and Metabolism','Oxidative Phosphorylation','Pentose Phosphate Pathway','Pyruvate Metabolism','Transport, Extracellular'};
subSysToManipulate = 'Citric Acid Cycle';
originalPositions = [4;5;8;15;46;59;64;90];

%First get all reactions with 'Citric Acid Cycle' subSystem annotation
[reactionNames,reactionPos] = findRxnsFromSubSystem(model,subSysToManipulate);
assert(isempty(setxor(reactionPos,[4;5;8;15;46;59;64;90]))); %These and only these
assert(isequal(reactionNames,model.rxns(reactionPos))); %Same order

%Now, get all subSystems in the model
subsInModel = getModelSubSystems(model);
assert(isempty(setxor(subsInModel,originalSubSystems)));

%Now, add Citric Acid Cycle to the first three reactions
originalSubsystems = model.subSystems;
modelNew = addSubSystemsToReactions(model,model.rxns(1:3),subSysToManipulate);
[reactionNames,reactionPos] = findRxnsFromSubSystem(modelNew,subSysToManipulate);
assert(isempty(setxor(union(originalPositions,[1:3]),reactionPos))); %Added only to those and not changed elsewhere.
assert(all(~cellfun(@(x) isequal(x,{''}),originalSubsystems(1:3)))); %The first three subSystems are non Empty, i.e. this empty is not removed
assert(all(cellfun(@(x,y) all(ismember(y,x)),modelNew.subSystems,originalSubsystems))); %Old subSystems are retained.

%Add it to an empty reactions
modelWithEmptyReplaced = addSubSystemsToReactions(model,13,subSysToManipulate); %Biomass gets assigned to Citric Acid Cycle
assert(isequal(modelWithEmptyReplaced.subSystems{13},{subSysToManipulate})); %Assert that the '' was removed and only the Citric Acid cycle is there.

%Remove the Citric Acid Cycle from all reactions
rxnToDo = true(numel(model.rxns),1);
modelWOTCA = removeSubSystemsFromRxns(modelNew,rxnToDo,subSysToManipulate); %Remove it from model with the added SubSystems.
assert(all(cellfun(@(x) isequal(x,{''}),modelWOTCA.subSystems(originalPositions)))); %The former TCA reactions should have no subSystem left.
rxnToDo(originalPositions) = false; %Ignore them
assert(all(cellfun(@(x,y) isempty(setxor(x,y)),modelWOTCA.subSystems(rxnToDo),model.subSystems(rxnToDo)))); %All others should have their original

%Now, set the TCA as subSystem for a batch of reactions:
reactionsToSet = [3 4 7 8 13];
modelWithSet = setRxnSubSystems(model,reactionsToSet,subSysToManipulate);
assert(all(cellfun(@(x) isequal(x,{subSysToManipulate}),modelWithSet.subSystems(reactionsToSet))));
notChanged = setdiff(1:numel(model.rxns),reactionsToSet);
assert(all(cellfun(@(x,y) isequal(x,y), modelWithSet.subSystems(notChanged),model.subSystems(notChanged))));

%Test for multiple values
SomeSubSys = 'testtSubSys';
modelTest = addSubSystemsToReactions(model,1:4,SomeSubSys);
newSubs = getModelSubSystems(modelTest);
assert(isempty(setxor(newSubs,union(originalSubSystems,SomeSubSys))));

%finally test isReactionInSubSystem
assert(~isReactionInSubSystem(model,model.rxns{9},'Citric Acid Cycle'))
assert(all(isReactionInSubSystem(model,model.rxns(4:5),'Citric Acid Cycle')));
assert(isequal(isReactionInSubSystem(model,21:-1:18,'Exchange'),[true; true; false; false]));

%Return to old path
cd(currentDir)