% The COBRAToolbox: testMergeModelFieldPositions
%
% Purpose:
%     - Test merging of model fields with the function
%     mergeModelFieldPositions
%
% Function under test:
%     src/reconstruction/refinement/mergeModelFieldPositions.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; ecoli_core_model loaded through getDistributedModel.
%
% Coverage exemptions:
%     None besides the defective input listed below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A cell field that does not hold text or cell arrays cannot be merged
%       SEVERITY: error
%       TRIGGER: a cell field with one entry per reaction that holds numbers, strings or empty
%         matrices, for example model.rxnValues = num2cell(ones(size(model.rxns))), followed by
%         mergeModelFieldPositions(model, 'rxns', [1, 2])
%       OBSERVED: the call stops in setSlice with Conversion to cell from double is not possible
%         (for string entries: value of type 'string' is not convertible to 'cell'; for empty
%         entries: the size of the right side is 0-by-1)
%       EXPECTED: the entries are merged into one cell entry, as for the other cell fields
%       LINES: 115
%
% Author:
%     - Original file: Thomas Pfau
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMergeModelFieldPositions.m'));
cd(fileDir);

% this test needs no solver, MATLAB toolbox or particular operating system
prepareTest();

% load reference data and model
model = getDistributedModel('ecoli_core_model.mat');

%Initialize the test
fprintf(' -- Running testMergeModelFieldPositions ... ');

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
assert(isequal(strjoin(unique([model.subSystems(rxnspos)]), ';'),modelMerged.subSystems{newreacpos}));

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

%% a logical vector selects the same positions as the equivalent indices

logicalPositions = false(size(model.rxns));
logicalPositions(rxnspos) = true;
assert(isequal(mergeModelFieldPositions(model, 'rxns', logicalPositions), ...
    mergeModelFieldPositions(model, 'rxns', rxnspos)));

%% fewer than two positions leave the model unchanged

assert(isequal(mergeModelFieldPositions(model, 'rxns', 5), model));
assert(isequal(mergeModelFieldPositions(model, 'rxns', false(size(model.rxns))), model));

%% merge functions for both rule fields replace the default rule functions

customFunctions = {'rules', @(x) x(1); 'grRules', @(x) {'customRule'}};
modelCustom = mergeModelFieldPositions(model, 'rxns', [1, 2], customFunctions);
% the merged reaction stays at the first position and takes the output of the given functions
assert(numel(modelCustom.rxns) == numel(model.rxns) - 1);
assert(isequal(modelCustom.rules(1), model.rules(1)));
assert(strcmp(modelCustom.grRules{1}, 'customRule'));

%% a merge function for another field is used along with the default rule functions

modelLowerBound = mergeModelFieldPositions(model, 'rxns', [1, 2], {'lb', @(x) min(x)});
% the lower bounds are not added up, as they are by default
assert(modelLowerBound.lb(1) == min(model.lb(1:2)));
% the rules are still joined by the default function, in the sorted order of setdiff
defaultRule = ['(' strjoin(sort(model.grRules(1:2)), ') and (') ')'];
assert(strcmp(modelLowerBound.grRules{1}, defaultRule));

%% a cell field of cell arrays merges into the unique entries

modelNested = model;
modelNested.subSystems = cellfun(@(x) {x}, model.subSystems, 'UniformOutput', false);
modelMerged = mergeModelFieldPositions(modelNested, 'rxns', [1, 2]);
assert(isequal(modelMerged.subSystems{1}, unique([modelNested.subSystems{1:2}])));
assert(iscell(modelMerged.subSystems{1}));

fprintf('Done...\n');
%Switch back
cd(currentDir)
