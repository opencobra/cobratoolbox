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

% get reactions for gene list, include gene not in model and nested cell
genesOfInterest = {'b1779',{'Glycolysis/Gluconeogenesis'};... %GAPD
                   'b4077',{'Transport, Extracellular'}}; %Glucose Transport
fprintf('>> Testing SubSystem extraction From Genes\n')               
SubSysOfFirstReaction = findSubSysGen(model);
assert(length(SubSysOfFirstReaction) == 137); %One for each gene.
[gPres,gPos] = ismember(SubSysOfFirstReaction(:,1),genesOfInterest(:,1));
%The subSystems match the expected ones.
assert(all(isequal(SubSysOfFirstReaction(gPres,2),genesOfInterest(gPos(gPres),2))));
%Now, we will change the subSystems for GAPD.
newSubs = {'Glycolysis','Gluconeogenesis'};
model = setRxnSubSystems(model,'GAPD',newSubs);
SubSysOfFirstReaction = findSubSysGen(model);
b1779Pos = find(ismember(model.genes,'b1779'));
assert(isempty(setxor(SubSysOfFirstReaction{b1779Pos,2},newSubs)));
geneWithMultipleReactions = 'b3528'; %Normally only 'Transport, Extracellular'
originalSub = 'Transport, Extracellular';
%Change One of the reaction Subsystems
model = setRxnSubSystems(model,'FUMt2_2','TestSub'); %This should be the first reaction.
SubSysOfFirstReaction = findSubSysGen(model);
b3528pos = find(ismember(model.genes,geneWithMultipleReactions));
assert(isempty(setxor(SubSysOfFirstReaction{b3528pos,2},{'TestSub'}))); %Only TestSub
geneSubs = findSubSystemsFromGenes(model,geneWithMultipleReactions);
assert(isempty(setxor(geneSubs,{'TestSub',originalSub})));

%Now test the ordering of things.
fprintf('>> Testing Ordering\n')
genesOfInterest{1,2} = newSubs;
[subSystems,indList] = findSubSystemsFromGenes(model,['someOtherGene',genesOfInterest(:,1)']);
assert(isempty(setxor(subSystems,union(genesOfInterest{:,2})))); %someOtherGene is empty.
assert(isequal(indList(:,1),['someOtherGene';genesOfInterest(:,1)]))
assert(isequal(indList(1,2),{[]}))
assert(all(cellfun(@(x,y) isempty(setxor(x,y)),indList(2:3,2),genesOfInterest(:,2)))); %All sets match

%Finally, test the struct flag
fprintf('>> Testing Struct Output\n')
checkedGenes = ['2some+OtherGene',genesOfInterest(:,1)'];
[subSystems,indList] = findSubSystemsFromGenes(model,checkGenes,'structResult',true);
geneFields = fieldnames(indList);
assert(isempty(setxor(strcat('gene_',regexprep(checkedGenes,'[^a-zA-Z0-9]','_')),geneFields)));
assert(isempty(indList.gene_2some_OtherGene)); %Empty field.
assert(all(cellfun(@(x,y) isempty(setxor(indList.(['gene_',x]),y)),genesOfInterest(:,1),genesOfInterest(:,2)))); %All sets match

fprintf('>> Done\n');

% change the directory
cd(currentDir)
