% The COBRAToolbox: testDynamicModelFieldModification.m
%
% Purpose:
%     - Test functionality in removeFieldEntriesForType, extendModelFields,
%     getModelFieldsForType
%
% Author:
%     - Original file: Thomas Pfau

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testDynamicModelFieldModification.m'));
cd(fileDir);

%Lets create an empty model.
model = createModel();

%Lets add a gene:
model.genes{end+1,1} = 'gene1';

%extend all relevant fields (the original size was 0.
%get all Model fields for genes
fprintf('Testing getModelFieldsForType and extendModelFieldsForType ...\n');
[matchingGeneFields,dimensions] = getModelFieldsForType(model,'genes','fieldSize',0);
assert(dimensions == 2);
assert(isequal(matchingGeneFields,{'rxnGeneMat'}));
model = extendModelFieldsForType(model,'genes');
%This should result in an empty rxnGEneMatrix of size 0x1
assert(all(size(model.rxnGeneMat) == [0,1]));

%Recreate the model.
model = createModel();

%lets add a couple of reactions
reactions = {'R1',{'A','B'},[-1 1],0,1000;...
             'R2',{'B','C'},[-1 2],0,1000;...
             'R3',{'C','D'},[-1 1],0,1000;...
             'R4',{'E','F'},[-1 1],0,1000;...
             'R5',{'F','G'},[-1 1],0,1000;...
             'R6',{'G','E'},[-1 1],0,1000;...
             'R7',{'G','D'},[-1 1],0,1000;...
             'R8',{'H','C'},[-1 1],0,1000};
%Add Reactions
for i = 1:size(reactions,1)
    %All reactions are irreversible
    model = addReaction(model,reactions{i,1},'metaboliteList',reactions{i,2},...
          'stoichCoeffList',reactions{i,3},'lowerBound',reactions{i,4},'upperBound',reactions{i,5},...
          'printLevel',-1);
end
%Now, the size of model.mets is exactly the same as model.rxns (which could
%be a problematic situation).
%so, lets see, which fields we get for mets:
[matchingMetFields,dimensions] = getModelFieldsForType(model,'mets');
%This should be:
assert(isempty(setxor(matchingMetFields,{'mets','b','metNames','csense','S'})) && numel(matchingMetFields) == 5); %No duplicates!
%And S should have dimension 1, and only 1.
assert(all(dimensions(ismember(matchingMetFields,'S')) == 1)); %all to make sure that duplicate appearences are covered. 

%Lets also check this for reactions
[matchingRxnFields,dimensions] = getModelFieldsForType(model,'rxns');
assert(isempty(setxor(matchingRxnFields,{'rxns','lb','ub','c','rxnGeneMat','rules','grRules','S'})) && numel(matchingRxnFields) == 8); %No duplicates!
%And S should have dimension 1, and only 1.
assert(all(dimensions(ismember(matchingRxnFields,'S')) == 2)); %all to make sure that duplicate appearences are covered. 

%Finally for genes:
[matchingGeneFields,dimensions] = getModelFieldsForType(model,'genes');
assert(isempty(setxor(matchingGeneFields,{'genes','rxnGeneMat'})) && numel(matchingGeneFields) == 2); %No duplicates!
%And S should have dimension 1, and only 1.
assert(all(dimensions(ismember(matchingGeneFields,'rxnGeneMat')) == 2)); %all to make sure that duplicate appearences are covered. 


%Now, add a metabolite
model.mets{end+1,1} = 'NewMet';
%and see, which fields we get when asking for all met fields one smaller
%than mets
[matchingMetFields,dimensions] = getModelFieldsForType(model,'mets','fieldSize',length(model.mets)-1);
%This should be all except mets:
assert(isempty(setxor(matchingMetFields,{'b','metNames','csense','S'})) && numel(matchingMetFields) == 4); %No duplicates!
%And S should have dimension 1, and only 1.
assert(all(dimensions(ismember(matchingMetFields,'S')) == 1)); %all to make sure that duplicate appearences are covered. 

%now, lets add an unknown field
model.something = zeros(8,1); %This field will not be returned, as there are other fields (rxns) of the same size, so its unclear, what it belongs to.
[matchingMetFields,dimensions] = getModelFieldsForType(model,'mets','fieldSize',length(model.mets)-1);
assert(~any(ismember(matchingMetFields,'something')));

%If this would be size 9, it should be returned if all equal sized fields
%are requested:
model.something = zeros(1,9); %This field will not be returned, as there are other fields (rxns) of the same size, so its unclear, what it belongs to.
[matchingMetFields,dimensions] = getModelFieldsForType(model,'mets');
assert(any(ismember(matchingMetFields,'something')));
assert(dimensions(ismember(matchingMetFields,'something')) == 2);

% As a size 8 field it woudl be returned as a rxn field:
model.something = zeros(8,1); %This field will not be returned, as there are other fields (rxns) of the same size, so its unclear, what it belongs to.
[matchingRxnFields,dimensions] = getModelFieldsForType(model,'rxns');
assert(any(ismember(matchingRxnFields,'something')));
assert(dimensions(ismember(matchingRxnFields,'something')) == 1);

%So, lets extend the model to update all of those metabolite derived fields
model = extendModelFieldsForType(model,'mets');
[matchingMetFields,dimensions] = getModelFieldsForType(model,'mets');
assert(isempty(setxor(matchingMetFields,{'mets','b','metNames','csense','S'})) && numel(matchingMetFields) == 5);
assert(length(model.something) == 8) %This field was not modified, as it could not be clearly associated with mets.

fprintf('Testing removeFieldEntriesForType ...\n');
%Also, test the removeFieldEntries method now
%To be able to check whether the right fields are removed, we will create a
%random s matrix:
model.S = rand(size(model.S));
removedMets = [3 4 5 6];
model2 = removeFieldEntriesForType(model,removedMets,'mets', length(model.mets));
reducedSMatrix = model.S;
reducedSMatrix(removedMets,:) = [];
assert(isequal(model2.S, reducedSMatrix));
%Assert that the right mets are removed and that the others are retained.
assert(isempty(intersect(model2.mets,model.mets(removedMets))) && isempty(setxor(setdiff(model.mets,model.mets(removedMets)),model2.mets)))

%Now, remove a metabolite
model = removeMetabolites(model,model.mets{end});
% and try this again (same sized rxns and mets)
model2 = removeFieldEntriesForType(model,removedMets,'mets', length(model.mets));
reducedSMatrix = model.S;
reducedSMatrix(removedMets,:) = [];
assert(isequal(model2.S, reducedSMatrix));
%Assert that the right mets are removed and that the others are retained.
assert(isempty(intersect(model2.mets,model.mets(removedMets))) && isempty(setxor(setdiff(model.mets,model.mets(removedMets)),model2.mets)))

%Also give it a try with reactions:
% and try this again (same sized rxns and mets)
removedRxns = [3 4 5];
%Also modify lb, ub and rules for this case
model.lb = rand(size(model.rxns));
model.ub = rand(size(model.rxns));
model = changeGeneAssociation(model,model.rxns{1},'A or B');
model = changeGeneAssociation(model,model.rxns{3},'B and C');
model = changeGeneAssociation(model,model.rxns{6},'D or E');
model2 = removeFieldEntriesForType(model,removedRxns,'rxns', length(model.rxns));
[rxnPres,rxnPos] = ismember(model2.rxns,model.rxns);
assert(isequal(model2.S, model.S(:,rxnPos(rxnPres))));
%Assert that the right mets are removed and that the others are retained.
assert(isempty(intersect(model2.rxns,model.rxns(removedRxns))) && isempty(setxor(setdiff(model.rxns,model.rxns(removedRxns)),model2.rxns)))
assert(all(cellfun(@(x,y) isequal(x,y), model2.rules, model.rules(rxnPos(rxnPres)))));
assert(all(model2.lb == model.lb(rxnPos(rxnPres))));
assert(all(model2.ub == model.ub(rxnPos(rxnPres))));

%And finally give ti a try for genes:
%First create the GR rules.
model = creategrRulesField(model);
removedGenes = [2 3];
model2 = removeFieldEntriesForType(model,removedGenes,'genes', length(model.genes));
assert(isempty(model2.rules{3})); % Both genes got removed.
assert(isequal(model2.grRules{1},'A')); % B got removed, so only A is retained.
assert(isequal(model2.rules{6},'x(2) | x(3)')); % The gene positions got changed.

%And test remobval of gene 4
model2 = removeFieldEntriesForType(model,4,'genes', length(model.genes));
assert(isequal(model2.rules{6},'x(4)')); % 4 got removed, and 5 renamed
[e] = parseBoolean(model2.grRules{6});
[e2] = parseBoolean('E');
assert(isequal(e,e2));
%Compare irrespective of actual format.


%Switch back
cd(currentDir)
