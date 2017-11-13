% The COBRAToolbox: testMergeModelFieldPositions
%
% Purpose:
%     - Test merging of model fields with the function
%     mergeModelFieldPositions
%
% Author:
%     - Original file: Thomas Pfau

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMergeModelFieldPositions.m'));
cd(fileDir);

% load reference data and model
model = getDistributedModel('ecoli_core_model.mat');

%Merge two reactions first two reactions which have a non empty rules
%field. 

rxnspos = [3,4,8];
modelMerged = mergeModelFieldPositions(model,'rxns',rxnspos);
%The new reaction is the merged reaction names, and the old ones get
%removed.
assert(~any(ismember(model.rxns(rxnspos),modelMerged.rxns)));
%get the position of the merged rxn
newreacpos = ismember(modelMerged.rxns,strjoin(model.rxns(rxnspos),';'));
assert(any(newreacpos));

%check that the new reac pos grRules and rules field is a merge of the two
%old ones. (this should be the old ones concatenated with parenthesis and and or &)
%The order could be any, so we need to check all and if any fits, we are fine.
rulesperms = perms(rxnspos);
newRules = cell(size(rulesperms,1),1);
newgrRules = cell(size(rulesperms,1),1);
for i = 1:size(rulesperms,1)
    newRules{i} = ['(' strjoin(model.rules(rulesperms(i,:)), ') & (') , ')'];
    newgrRules{i} = ['(' strjoin(model.grRules(rulesperms(i,:)), ') and (') , ')'];
end
assert(any(ismember(newRules,modelMerged.rules{newreacpos})));
assert(any(ismember(newgrRules,modelMerged.grRules{newreacpos})));

%The S matrix is added up.
assert(isequal(modelMerged.S(:,newreacpos), sum(model.S(:,rxnspos),2)));

%Also check that the subSystems were merged properly
assert(isequal(unique([model.subSystems{rxnspos}]),modelMerged.subSystems{newreacpos}));

%Now, lets change the model a bit, and duplicate the name of a gene
%(replacing it in all grRules).
geneReplaced = model.genes(end);
modelWithReplacedGene = model;
modelWithReplacedGene.genes(end) = modelWithReplacedGene.genes(1);
modelWithReplacedGene.grRules = strrep(modelWithReplacedGene.grRules,geneReplaced,modelWithReplacedGene.genes(end));

modelMerged = mergeModelFieldPositions(modelWithReplacedGene,'genes',[1,numel(modelWithReplacedGene.genes)]);
%Assert, that the gene is still present.
assert(sum(ismember(modelMerged.genes,modelWithReplacedGene.genes(1)))==1)

%Assert, that all grRules are equal(the gene names were just merged and no
%new gene name was introduced.
assert(isequal(modelWithReplacedGene.grRules,modelMerged.grRules))

%Check, that the rules positions are now merged.
involvedInEnd = find(modelWithReplacedGene.rxnGeneMat(:,end));

%Check that the rules have been updated
assert(~isequal(modelMerged.rules(involvedInEnd),modelWithReplacedGene.rules(involvedInEnd)));
%Also check, that they have been updated correctly
assert(isequal(modelMerged.rules(involvedInEnd),strrep(modelWithReplacedGene.rules(involvedInEnd),['x(' num2str(numel(modelWithReplacedGene.genes)) ')'], 'x(1)')));

%Finally, we will merge 2 no equal genes.
modelMerged = mergeModelFieldPositions(model,'genes',[1,numel(model.genes)]);

%Check that the rules have been updated (this is the same as above as the
%genes are the same.
assert(~isequal(modelMerged.rules(involvedInEnd),model.rules(involvedInEnd)));
%Also check, that they have been updated correctly
assert(isequal(modelMerged.rules(involvedInEnd),strrep(model.rules(involvedInEnd),['x(' num2str(numel(model.genes)) ')'], 'x(1)')));

%Also check, that the grRules have been updated:
assert(~isequal(model.grRules,modelMerged.grRules))
%And correctly updated
assert(isequal(modelMerged.grRules,regexprep(model.grRules,['(' model.genes{1} ')|(' model.genes{end} ')'],strjoin(model.genes([1,end]),';'))));

fprintf('Done...\n');
%Switch back
cd(currentDir)
