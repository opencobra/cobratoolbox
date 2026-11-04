% The COBRAToolbox: testMergeTwoModels.m
%
% Purpose:
%     - testMergeTwoModels tests the mergeTwoModels function for
%     applicability to multiple different scenarios.
%
% Function under test:
%     src/reconstruction/refinement/mergeTwoModels.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Lines 261-262: the local function updateRule, nothing in the file calls it.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A field that cannot be concatenated is dropped with a debug message
%       SEVERITY: wrong-result
%       TRIGGER: a reaction field present in both models whose sizes do not fit, for example
%         model1.rxnMat = zeros(2, 2) and model2.rxnMat = zeros(3, 3) for models with 2 and 3
%         reactions
%       OBSERVED: the error is caught, the text test is printed and the merged model has no
%         rxnMat field, without any warning
%       EXPECTED: an error, or a warning that names the field that is lost
%       LINES: 236-237
%
% Authors:
%     - Thomas Pfau 2018
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.

% save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));

% this test needs no solver, MATLAB toolbox or particular operating system
prepareTest();

% determine the test path for references
testPath = pwd;

% Initiate the test
fprintf(' -- Running testMergeTwoModels ... ');

% We will create 2 toy models
% model1
model1 = createModel();
model1 = addMultipleMetabolites(model1,{'A[c]','B[c]','C[c]','D[c]','E[c]'},'metKEGGID',{'C1','C2','C3','C4','C5'});
model1 = addGenes(model1,{'G1','G2','G3'},'geneNames',{'Gene1','Gene2','Gene3'});
model1 = addMultipleReactions(model1,{'R1','R2','R3'},model1.mets,rand(5,3),'grRules',{'G1','G2 and G3',''});

% Model2
model2 = createModel();
model2 = addMultipleMetabolites(model2,{'A2[c]','B2[c]','C2[c]','D2[c]','E2[c]'},'metKEGGID',{'C1','C2','C3','C4','C5'});
model2 = addGenes(model2,{'G21','G22','G23'},'geneNames',{'Gene1a','Gene2a','Gene3a'});
model2 = addMultipleReactions(model2,{'R21','R22','R23'},model2.mets,rand(5,3),'grRules',{'G21','G22 and G23',''});

%join the models (first, with genes)
modelJoint = mergeTwoModels(model1,model2);
%New S is of size 10 x 6
assert(size(modelJoint.S,1) == 10) 
assert(size(modelJoint.S,2) == 6)
%Test, that the reactions are the same.
model2rxn = printRxnFormula(model2,'rxnAbbrList',model2.rxns(1),'printFlag',false);
modelJointRxn = printRxnFormula(modelJoint,'rxnAbbrList',model2.rxns(1),'printFlag',false);
assert(strcmp(model2rxn{1},modelJointRxn{1}));
model1rxn = printRxnFormula(model1,'rxnAbbrList',model1.rxns(2),'printFlag',false);
modelJointRxn = printRxnFormula(modelJoint,'rxnAbbrList',model1.rxns(2),'printFlag',false);
assert(strcmp(model1rxn{1},modelJointRxn{1}));

%Check, that the rules are correctly updated.
ruleR22 = modelJoint.rules{ismember(modelJoint.rxns,'R22')};
genePos = find(ismember(modelJoint.genes,{'G22','G23'}));
rule = strjoin(cellfun(@(x) ['x(' num2str(x) ')'], num2cell(genePos),'Uniform',0),' & '); 
fp = FormulaParser();
modelRule = fp.parseFormula(ruleR22);
shouldBeRule = fp.parseFormula(rule);
assert(modelRule.isequal(shouldBeRule))

%Now, lets change G22 in model2 to G2 and introduce a common reaction
model2 = changeGeneAssociation(model2,'R22','G1 and G2');
model2 = addReaction(model2,'Rcommon','A[c] + B[c] -> C[c]');
model1 = addReaction(model1,'Rcommon','A[c] + B[c] -> C[c]');
model2.geneNames(end-1) = {'GeneFromModel2'};

%Assert that Model2 overrides model 1
modelJoint = mergeTwoModels(model1,model2);
assert(size(modelJoint.S,1) == 10) 
assert(size(modelJoint.S,2) == 7)
geneWithName = model2.genes(end-1);
m2pos = ismember(model2.genes,geneWithName);
m1pos = ismember(model1.genes,geneWithName);
mjointPos = ismember(modelJoint.genes,geneWithName);
assert(strcmp(modelJoint.geneNames{mjointPos}, model1.geneNames{m1pos}))
model1rxn = printRxnFormula(model1,'rxnAbbrList','Rcommon','printFlag',false);
modelJointRxn = printRxnFormula(modelJoint,'rxnAbbrList','Rcommon','printFlag',false);
assert(strcmp(model1rxn{1},modelJointRxn{1}));

%Now also check that the objective is set correctly
model2.c(1) = 1;
model1.c(1) = 1;
modelJoint = mergeTwoModels(model1,model2,2);
assert(strcmp(modelJoint.rxns{find(modelJoint.c)},model2.rxns{1}));
modelJoint = mergeTwoModels(model1,model2,1);
assert(strcmp(modelJoint.rxns{find(modelJoint.c)},model1.rxns{1}));

%Finally, check that the merger is ok without merging genes
modelJoint = mergeTwoModels(model1,model2,2,false);
assert(~isfield(modelJoint,'geneNames'));
assert(isempty(modelJoint.genes));

%Test appropriate error if there are duplicate ids with distinct
%stoichiometries:
model2 = addReaction(model2,'Rcommon','A[c] -> C[c]');

mergeTwoModels(model1, model2);

assert(strcmp(lastwarn, 'The following reactions were present in both models but had distinct stoichiometries:\nRcommon'))

%% two small models that share metabolite B[c], for the fields that may be missing

smallModel1 = createModel();
smallModel1 = addMultipleMetabolites(smallModel1, {'A[c]', 'B[c]'});
smallModel1 = addMultipleReactions(smallModel1, {'R1'}, smallModel1.mets, [-1; 1]);
smallModel2 = createModel();
smallModel2 = addMultipleMetabolites(smallModel2, {'B[c]', 'C[c]'});
smallModel2 = addMultipleReactions(smallModel2, {'R2'}, smallModel2.mets, [-1; 1]);
geneFields = {'genes', 'rules', 'rxnGeneMat'};

%% a model without genes takes over the genes of the other model

% model1 without genes
modelJoint = mergeTwoModels(rmfield(smallModel1, geneFields), ...
    addGenes(smallModel2, {'G1'}, 'geneNames', {'gene one'}));
assert(isequal(modelJoint.genes, {'G1'}));
assert(isequal(modelJoint.geneNames, {'gene one'}));
assert(isequal(size(modelJoint.S), [3, 2]));

% model2 without genes
modelJoint = mergeTwoModels(addGenes(smallModel1, {'G1'}, 'geneNames', {'gene one'}), ...
    rmfield(smallModel2, geneFields));
assert(isequal(modelJoint.genes, {'G1'}));
assert(isequal(modelJoint.geneNames, {'gene one'}));
assert(isequal(size(modelJoint.S), [3, 2]));

%% a gene field present only in model2 is kept

modelJoint = mergeTwoModels(addGenes(smallModel1, {'G1'}), ...
    addGenes(smallModel2, {'G2'}, 'geneNames', {'gene two'}));
assert(isequal(modelJoint.genes, {'G1'; 'G2'}));
assert(strcmp(modelJoint.geneNames{strcmp(modelJoint.genes, 'G2')}, 'gene two'));

%% compartments are merged, once each, and model1 wins for a common compartment

compModel1 = smallModel1;
compModel1.comps = {'c'};
compModel1.compNames = {'cytosol of model1'};
compModel2 = smallModel2;
compModel2.comps = {'c'; 'e'};
compModel2.compNames = {'cytosol of model2'; 'extracellular'};

modelJoint = mergeTwoModels(compModel1, compModel2);
assert(isequal(modelJoint.comps, {'c'; 'e'}));
assert(isequal(modelJoint.compNames, {'cytosol of model1'; 'extracellular'}));

% model2 without compartments
modelJoint = mergeTwoModels(compModel1, smallModel2);
assert(isequal(modelJoint.comps, {'c'}));

% model1 without compartments
modelJoint = mergeTwoModels(smallModel1, compModel2);
assert(isequal(modelJoint.comps, {'c'; 'e'}));
assert(isequal(modelJoint.compNames, {'cytosol of model2'; 'extracellular'}));

%% a reaction field present in one model only is filled with defaults for the other model

notesModel1 = smallModel1;
notesModel1.rxnNotes = {'note of R1'};
modelJoint = mergeTwoModels(notesModel1, smallModel2);
assert(isequal(modelJoint.rxns, {'R1'; 'R2'}));
assert(strcmp(modelJoint.rxnNotes{1}, 'note of R1'));
assert(isempty(modelJoint.rxnNotes{2}));

notesModel2 = smallModel2;
notesModel2.rxnNotes = {'note of R2'};
modelJoint = mergeTwoModels(smallModel1, notesModel2);
assert(isempty(modelJoint.rxnNotes{1}));
assert(strcmp(modelJoint.rxnNotes{2}, 'note of R2'));

fprintf('\nDone.\n');
fprintf('testMergeTwoModels passed successfully.\n');

% change the directory
cd(currentDir);
