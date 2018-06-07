% The COBRAToolbox: testFindSubSystemsFromGenes.m
%
% Purpose:
%     - Test the findSubSystemsFromGenes and the wrapper findSubSysGen function
%
% Authors:
%     - Original file: Thomas Pfau, June 2018
%

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('findSubSystemsFromGenes'));
cd(fileDir);

% load model
model = getDistributedModel('ecoli_core_model.mat');

% Define some genes in the model and the associated subSystems.
genesOfInterest = {'b1779',{'Glycolysis/Gluconeogenesis'};... %Only associated with the GAPD reaction
                   'b4077',{'Transport, Extracellular'}}; % only associated with the Glucose transport reaction
fprintf('>> Testing SubSystem extraction From Genes\n')               
%Get the SubSystem List for each gene.
SubSysOfFirstReaction = findSubSysGen(model);
%There has to be one for each gene in the model.
assert(length(SubSysOfFirstReaction) == numel(model.genes)); 
%Check if the correct ones got returned.
[gPres,gPos] = ismember(SubSysOfFirstReaction(:,1),genesOfInterest(:,1));
assert(all(isequal(SubSysOfFirstReaction(gPres,2),genesOfInterest(gPos(gPres),2))));

%Now, we will change the subSystems for GAPD.
newSubs = {'Glycolysis','Gluconeogenesis'};
model = setRxnSubSystems(model,'GAPD',newSubs);

%This should return the new subSystems for 
SubSysOfFirstReaction = findSubSysGen(model);
%Get the position and check that it is the new subsystems.
b1779Pos = find(ismember(model.genes,'b1779'));
assert(isempty(setxor(SubSysOfFirstReaction{b1779Pos,2},newSubs)));

%Now, findSubSysGen defines that it will only return the Subsystem of the
%first found reaction. Check this on a reaction, associated with only
%'Transport, Extracellular' subSystems.
geneWithMultipleReactions = 'b3528'; 
originalSub = 'Transport, Extracellular';
b3528pos = find(ismember(model.genes,geneWithMultipleReactions));
geneSubs = findSubSystemsFromGenes(model,geneWithMultipleReactions);
assert(isempty(setxor(geneSubs,{originalSub}))); %Only the one gets returned. 
%Also check this for findSubSysGen
SubSysOfFirstReaction = findSubSysGen(model);
assert(isempty(setxor(SubSysOfFirstReaction{b3528pos,2},originalSub))); %this is the expected one.

%Change One of the reaction Subsystems, which is the first
%reaction associated with this gene.
model = setRxnSubSystems(model,'FUMt2_2','TestSub'); 
SubSysOfFirstReaction = findSubSysGen(model);
%Now test, if only the first is returned.
assert(isempty(setxor(SubSysOfFirstReaction{b3528pos,2},{'TestSub'})));
geneSubs = findSubSystemsFromGenes(model,geneWithMultipleReactions);
%Check that actually all subSystems are found by findSubSystemsFromGenes.
assert(isempty(setxor(geneSubs,{'TestSub',originalSub})));

%Now test the ordering of the outputs..
fprintf('>> Testing Ordering\n')
genesOfInterest{1,2} = newSubs;
%Outputs should have the same order as inputs.
[subSystems,indList] = findSubSystemsFromGenes(model,['someOtherGene',genesOfInterest(:,1)']);
%assert the correct order , i.e. order as in the input:
assert(isequal(indList(:,1),['someOtherGene';genesOfInterest(:,1)]))
%Nothing associated with someOtherGene
assert(isequal(indList(1,2),{[]})) 
%outputs should be consistent
assert(isempty(setxor(subSystems,union(genesOfInterest{:,2})))); %someOtherGene is empty.
%Assert that all other outputs are correct.
assert(all(cellfun(@(x,y) isempty(setxor(x,y)),indList(2:3,2),genesOfInterest(:,2)))); %All sets match

%Finally, test the struct flag
fprintf('>> Testing Struct Output\n')
checkedGenes = ['2some+OtherGene',genesOfInterest(:,1)'];
[subSystems,indList] = findSubSystemsFromGenes(model,checkedGenes,'structResult',true);
geneFields = fieldnames(indList);
%Assert that the gene was translated correctly.
assert(isempty(setxor(strcat('gene_',regexprep(checkedGenes,'[^a-zA-Z0-9]','_')),geneFields)));
assert(isempty(indList.gene_2some_OtherGene)); %it still has no associated subSystems
%All other genes have the correct subSystems
assert(all(cellfun(@(x,y) isempty(setxor(indList.(['gene_',x]),y)),genesOfInterest(:,1),genesOfInterest(:,2)))); %All sets match

fprintf('>> Done\n');

% change the directory
cd(currentDir)
