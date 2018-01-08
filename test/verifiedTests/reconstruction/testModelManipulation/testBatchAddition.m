% The COBRAToolbox: testBatchAddition.m
%
% Purpose:
%     - testBatchAddition tests addReactionBatch, addMEtaboliteBatch and
%       addGeneBatch based on E.coli Core. 
%
% Authors:
%     - Thomas Pfau Dec 2017



% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testBatchAddition.m'));
cd(fileDir);

% Test with non-empty model
fprintf('>> Starting Batch Addition Test:\n');

%Load a test model.
model = getDistributedModel('ecoli_core_model.mat');

%Test batch addition
%For Mets
fprintf('>> Testing Metabolite Batch Addition...\n');
metNames = {'A','b','c'};
metFormulas = {'C','CO2','H2OKOPF'};
modelBatch = addMetaboliteBatch(model,metNames,'metCharges', [ -1 1 0],...
    'metFormulas', metFormulas, 'metKEGGID',{'C000012','C000023','C000055'});
assert(all(ismember(metNames,modelBatch.mets)));
[pres,pos] = ismember(metNames,modelBatch.mets);
assert(isequal(modelBatch.metFormulas(pos(pres)),columnVector(metFormulas)));
assert(isequal(modelBatch.metCharges(pos(pres)),[-1; 1;0]));
assert(verifyModel(modelBatch,'simpleCheck',true));


%For Reactions:
fprintf('>> Testing Reaction Batch Addition...\n');
rxnIDs = {'ExA','ATob','BToC'};
modelBatch2 = addReactionBatch(modelBatch,rxnIDs,{'A','b','ac[c]'},[1 -1 0; 0,-2,-1;0,0,1],...
                                   'lb',[-50,30,1],'ub',[0,60,15]);
%Check that the reactions are in.                               
assert(all(ismember(rxnIDs,modelBatch2.rxns)));
%Check that lbs/ubs are properly updated.
assert(modelBatch2.lb(ismember(modelBatch2.rxns,{'ExA'})) == -50);
assert(modelBatch2.lb(ismember(modelBatch2.rxns,{'BToC'})) == 1);
assert(modelBatch2.ub(ismember(modelBatch2.rxns,{'ATob'})) == 60);
assert(modelBatch2.ub(ismember(modelBatch2.rxns,{'BToC'})) == 15);
%Check that the metabolites were correctly assigned.
assert(modelBatch2.mets{find(modelBatch2.S(:,ismember(modelBatch2.rxns,'ExA')))} == 'A');
assert(isempty(setxor(modelBatch2.mets(find(modelBatch2.S(:,ismember(modelBatch2.rxns,'BToC')))),{'b','ac[c]'})));
%Check the stoichiometry is correct
assert(modelBatch2.S(ismember(modelBatch2.mets,'A'),ismember(modelBatch2.rxns,'ExA')) == 1);
assert(modelBatch2.S(ismember(modelBatch2.mets,'b'),ismember(modelBatch2.rxns,'ATob')) == -2);


%Now check proper addition of grRules (and updated fields).
modelBatch3 = addReactionBatch(modelBatch,{'ExA','ATob','BToC'},{'A','b','c'},[1 -1 0; 0,1,-1;0,0,1],...
                                   'grRules',{'G1 or b0721', 'b0008 and G4',''});
assert(numel(modelBatch3.genes) == numel(model.genes)+2); %Only two genes were added, the others already existed.
%Since the model has a rules field, we will test the equality of the rules.
fp = FormulaParser();
%Assert all correct genes are there.
assert(all(ismember(union(model.genes,{'G1','G4'}),modelBatch3.genes)));
%we will use ExA to test.
ExAPos = ismember(modelBatch3.rxns,'ExA');
G1pos = find(ismember(modelBatch3.genes,'G1'));
b0721pos = find(ismember(modelBatch3.genes,'b0721'));
Formula = ['x(' num2str(G1pos) ,') | x(' num2str(b0721pos) ')'];
head1 = fp.parseFormula(Formula);
head2 = fp.parseFormula(modelBatch3.rules{ExAPos});
assert(head1.isequal(head2));

%Also check logical format addition:              
modelBatch3 = addReactionBatch(model,{'ExA','ATob','BToC'},{'A','b','c'},[1 -1 0; 0,1,-1;0,0,1],...
                                   'rules',{'x(3) | x(2)', 'x(4) & x(1)',''}, 'genes', {'G4';'b0002';'G1';'b0008'})
%The same addition as above but a different
%format, so test the same things.
assert(numel(modelBatch3.genes) == numel(model.genes)+2); %Only two genes were added, the others already existed.
%Since the model has a rules field, we will test the equality of the rules.
fp = FormulaParser();
%Assert all correct genes are there.
assert(all(ismember(union(model.genes,{'G1','G4'}),modelBatch3.genes)));
%we will use ExA to test.
ExAPos = ismember(modelBatch3.rxns,'ExA');
G1pos = find(ismember(modelBatch3.genes,'G1'));
b0002pos = find(ismember(modelBatch3.genes,'G1'));
head1 = fp.parseFormula(Formula);
head2 = fp.parseFormula(model.rules{ExAPos});
assert(head1.isequal(head2));

%Now, test duplicate ID fails (duplicate in the reaction list
verifyCobraFunctionError(@() addReactionBatch(model,{'ExA','ATob','ExA'},{'A','b','c'},[1 -1 0; 0,1,-1;0,0,1]));
verifyCobraFunctionError(@() addReactionBatch(model,{'ExA','ATob','CS'},{'A','b','c'},[1 -1 0; 0,1,-1;0,0,1]));

%Also assert, that all metabolites are part of the Model (this is necessary
%for quick addition).
verifyCobraFunctionError(@() addReactionBatch(model,{'ExA','ATob','BToC'},{'A','b','ac[c]'},[1 -1 0; 0,1,-1;0,0,1]))



                               
                               
                               
% change the directory
cd(currentDir)