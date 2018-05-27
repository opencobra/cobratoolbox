% The COBRAToolbox: testMergeTwoModels.m
%
% Purpose:
%     - testMergeTwoModels tests the mergeTwoModels function for
%     applicability to multiple different scenarios.
%
% Authors:
%     - Thomas Pfau 2018

% We will create 2 toy models
%model1
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
assert(verifyCobraFunctionError('mergeTwoModels','outputArgCount',1,'inputs',{model1,model2},...
                         'testMessage','The following reactions were present in both models but had distinct stoichiometries:\nRcommon'));

