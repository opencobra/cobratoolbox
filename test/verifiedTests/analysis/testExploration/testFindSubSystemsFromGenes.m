% The COBRAToolbox: testFindSubSystemsFromGenes.m
%
% Purpose:
%     - Test the findSubSystemsFromGenes and the wrapper findSubSysGen function
%
% Function under test:
%     src/analysis/exploration/findSubSystemsFromGenes.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; ecoli_core_model loaded through getDistributedModel.
%
% Coverage exemptions:
%     None. Every other executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A model without rxnGeneMat and rules cannot be used
%       SEVERITY: error
%       TRIGGER: a model that has grRules but neither rxnGeneMat nor rules
%       OBSERVED: `regexptranslate y` inside the square brackets calls regexptranslate without
%         arguments, so the call fails with "Not enough input arguments"
%       EXPECTED: the gene associations are read from grRules, as the comment in the code says
%       LINES: 76
%     - DEFECT: Sub-systems stored as character arrays come back as single letters
%       SEVERITY: wrong-result
%       TRIGGER: a model whose subSystems entries are character arrays, the format kept by
%         getDistributedModel for ecoli_core_model, for example
%         findSubSystemsFromGenes(model, 'b1779')
%       OBSERVED: the entries are concatenated into one character array, so unique returns its
%         letters, '/Gcegilnosuy' instead of 'Glycolysis/Gluconeogenesis'
%       EXPECTED: the names of the sub-systems
%       LINES: 87, 92
%
% Authors:
%     - Original file: Thomas Pfau, June 2018
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('findSubSystemsFromGenes'));
cd(fileDir);

% this test needs no solver, toolbox or particular operating system
prepareTest();

% load model
model = getDistributedModel('ecoli_core_model.mat');

% Define some genes in the model and the associated subSystems.
genesOfInterest = {'b1779','Glycolysis/Gluconeogenesis';... %Only associated with the GAPD reaction
                   'b4077','Transport, Extracellular'}; % only associated with the Glucose transport reaction
fprintf('>> Testing SubSystem extraction From Genes\n')               
%Get the SubSystem List for each gene.
SubSysOfFirstReaction = findSubSysGen(model);
%There has to be one for each gene in the model.
assert(length(SubSysOfFirstReaction) == numel(model.genes)); 
%Check if the correct ones got returned.
[gPres,gPos] = ismember(SubSysOfFirstReaction(:,1),genesOfInterest(:,1));
assert(all(isequal(SubSysOfFirstReaction(gPres,2),genesOfInterest(gPos(gPres),2))));

%Now, we will change the subSystems for GAPD.
newSubs = 'Glycolysis';
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
assert(isempty(setxor(geneSubs,originalSub))); %Only the one gets returned. 
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
assert(isempty(setxor(subSystems,{genesOfInterest{:,2}}))); %someOtherGene is empty.
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

%The sections below use sub-systems stored as cell arrays, see the known defects in the header.
modelCells = model;
modelCells.subSystems = cellfun(@cellstr, model.subSystems, 'UniformOutput', false);

%% Without a gene list, all genes of the model are used
fprintf('>> Testing the default gene list\n')
[allSubSystems, allGenes] = findSubSystemsFromGenes(modelCells);
assert(isequal(allGenes(:, 1), modelCells.genes))
[emptyListSubSystems, emptyListGenes] = findSubSystemsFromGenes(modelCells, {});
assert(isequal(emptyListSubSystems, allSubSystems))
assert(isequal(emptyListGenes, allGenes))

%% Without rxnGeneMat the associations come from the rules and the result stays the same
fprintf('>> Testing models without rxnGeneMat\n')
modelRules = rmfield(modelCells, 'rxnGeneMat');
[rulesSubSystems, rulesGenes] = findSubSystemsFromGenes(modelRules, genesOfInterest(:, 1));
[matSubSystems, matGenes] = findSubSystemsFromGenes(modelCells, genesOfInterest(:, 1));
assert(isequal(rulesSubSystems, matSubSystems))
assert(isequal(rulesGenes, matGenes))

%% Without any field that links genes and reactions the function refuses to run
modelNoGpr = rmfield(modelRules, {'rules', 'grRules'});
assert(verifyCobraFunctionError('findSubSystemsFromGenes', 'inputs', {modelNoGpr, 'b1779'}, ...
    'testMessage', ['No fields to determine Gene - Reaction associations (rxnGeneMat, rules, ' ...
    'grRules) found in the model!']));

fprintf('>> Done\n');

% change the directory
cd(currentDir)
