% The COBRAToolbox: testBatchAddition.m
%
% Purpose:
%     - testBatchAddition tests addMultipleReactions, addMultipleMetabolites and
%       addGenes based on E.coli Core. 
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
% For Mets
fprintf('>> Testing Metabolite Batch Addition...\n');
metNames = {'A','b','c'};
metFormulas = {'C','CO2','H2OKOPF'};

%Also, implicitly test whether tables are handled correctly
model.tableField = table(model.mets,model.mets);
modelBatch = addMultipleMetabolites(model,metNames,'metCharges', [ -1 1 0],...
    'metFormulas', metFormulas, 'metKEGGID',{'C000012','C000023','C000055'});
assert(all(ismember(metNames,modelBatch.mets)));
[pres,pos] = ismember(metNames,modelBatch.mets);
assert(isequal(modelBatch.metFormulas(pos(pres)),columnVector(metFormulas)));
assert(isequal(modelBatch.metCharges(pos(pres)),[-1; 1;0]));
assert(verifyModel(modelBatch,'simpleCheck',true));
assert(isfield(modelBatch,'metKEGGID'));
assert(isequal(size(modelBatch.tableField,1),size(modelBatch.mets,1)));
assert(isequal(size(modelBatch.tableField,2),size(model.tableField,2)));

%Assert duplication check
assert(verifyCobraFunctionError('addMultipleMetabolites', 'inputs',{model,model.mets(1:3)}))
assert(verifyCobraFunctionError('addMultipleMetabolites', 'inputs',{model,{'A','b','A'}}))

% For Reactions:
fprintf('>> Testing Reaction Batch Addition...\n');
rxnIDs = {'ExA','ATob','BToC'};
modelBatch2 = addMultipleReactions(modelBatch,rxnIDs,{'A','b','ac[c]'},[1 -1 0; 0,-2,-1;0,0,1],...
                                   'lb',[-50,30,1],'ub',[0,60,15],'rxnKEGGID',{'R01','R02','R03'});                              
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
assert(verifyModel(modelBatch2,'simpleCheck',true));
assert(isfield(modelBatch2,'rxnKEGGID'));
%Now check proper addition of grRules (and updated fields).
modelBatch3 = addMultipleReactions(modelBatch,{'ExA','ATob','BToC'},{'A','b','c'},[1 -1 0; 0,1,-1;0,0,1],...
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
modelBatch3 = addMultipleReactions(modelBatch,{'ExA','ATob','BToC'},{'A','b','c'},[1 -1 0; 0,1,-1;0,0,1],...
                                   'rules',{'x(3) | x(2)', 'x(4) & x(1)',''}, 'genes', {'G4';'b0727';'G1';'b0008'});

%The same addition as above but a different
%format, so test the same things.
assert(numel(modelBatch3.genes) == numel(model.genes)+2); %Only two genes were added, the others already existed.
assert(verifyModel(modelBatch3,'simpleCheck',true))
%Since the model has a rules field, we will test the equality of the rules.
fp = FormulaParser();
%Assert all correct genes are there.
assert(all(ismember(union(model.genes,{'G1','G4'}),modelBatch3.genes)));
%we will use ExA to test.
ExAPos = ismember(modelBatch3.rxns,'ExA');
G1pos = find(ismember(modelBatch3.genes,'G1'));
b0727pos = find(ismember(modelBatch3.genes,'b0727'));
Formula = ['x(' num2str(G1pos) ,') | x(' num2str(b0727pos) ')'];
head1 = fp.parseFormula(Formula);
head2 = fp.parseFormula(modelBatch3.rules{ExAPos});
assert(head1.isequal(head2));

%Now also check the printLevel argument at different positions.
diary('reacAdd1.txt');
modelBatch4 = addMultipleReactions(modelBatch,{'ExA','ATob','BToC'},{'A','b','c'},[1 -1 0; 0,1,-1;0,0,1],'printLevel',1,...
                                   'rules',{'x(3) | x(2)', 'x(4) & x(1)',''}, 'genes', {'G4';'b0727';'G1';'b0008'});
diary off
diary('comparison.txt')
fprintf('Adding the following reactions to the model:\n');
printRxnFormula(modelBatch4,{'ExA','ATob','BToC'});
diary off
assert(all(fileread('reacAdd1.txt')==fileread('comparison.txt')));
diary('reacAdd2.txt');
modelBatch4 = addMultipleReactions(modelBatch,{'ExA','ATob','BToC'},{'A','b','c'},[1 -1 0; 0,1,-1;0,0,1],...
                                   'rules',{'x(3) | x(2)', 'x(4) & x(1)',''},'printLevel',1, 'genes', {'G4';'b0727';'G1';'b0008'});
diary off
assert(all(fileread('reacAdd2.txt')==fileread('comparison.txt')));
%clean diaries
delete('reacAdd1.txt');
delete('reacAdd2.txt');
delete('comparison.txt');


%Now, test duplicate ID fails (duplicate in the reaction list
assert(verifyCobraFunctionError('addMultipleReactions', 'inputs',{model,{'ExA','ATob','ExA'},{'A','b','c'},[1 -1 0; 0,1,-1;0,0,1]}));
assert(verifyCobraFunctionError('addMultipleReactions', 'inputs',{model,{'ExA','ATob','CS'},{'A','b','c'},[1 -1 0; 0,1,-1;0,0,1]}));

%Also assert, that all metabolites are part of the Model (this is necessary
%for quick addition).
assert(verifyCobraFunctionError('addMultipleReactions', 'inputs',{model,{'ExA','ATob','BToC'},{'A','b','ac[c]'},[1 -1 0; 0,1,-1;0,0,1]}));

% For Genes
fprintf('>> Testing Gene Batch Addition...\n');

genes = {'G1','Gene2','InterestingGene'}';
proteinNames = {'Protein1','Protein B','Protein Alpha'}';
modelWGenes = addGenes(model,genes,...
                            'proteins',proteinNames, 'geneField2',{'D','E','F'});
assert(isequal(lastwarn, 'Field geneField2 is excluded.'));                       
%three new genes.
assert(size(modelWGenes.rxnGeneMat,2) == size(model.rxnGeneMat,2) + 3);
assert(isfield(modelWGenes,'proteins'));
[~,genepos] = ismember(genes,modelWGenes.genes);
assert(isequal(modelWGenes.proteins(genepos),proteinNames));
assert(~isfield(model,'geneField2'));

%Init geneField 2
gField2 = {'D';'E';'F'};
model.geneField2 = cell(size(model.genes));
model.geneField2(:) = {''};
modelWGenes = addGenes(model,genes,...
                            'proteins',proteinNames, 'geneField2',gField2);
[~,genepos] = ismember(genes,modelWGenes.genes);
assert(isequal(modelWGenes.geneField2(genepos), gField2));
assert(all(cellfun(@(x) isequal(x,''),modelWGenes.geneField2(~ismember(modelWGenes.genes,genes)))));

%And finally test duplication errors.
assert(verifyCobraFunctionError('addGenes', 'inputs',{model,{'b0008','G1'}}));
assert(verifyCobraFunctionError('addGenes', 'inputs',{model,{'G2','G1','G2'}}));
              
%Test the functions on an empty model
fprintf('>> Testing Addition to an empty model\n');
model = createModel();
modelBatch = addMultipleMetabolites(model,metNames,'metNames',metNames,'metCharges', [ -1 1 0],...
    'metFormulas', metFormulas, 'metKEGGID',{'C000012','C000023','C000055'});
modelBatch2 = addMultipleReactions(modelBatch,rxnIDs,{'A','b','c'},[1 -1 0; 0,-2,-1;0,0,1],...
                                   'lb',[-50,30,1],'ub',[0,60,15],'rxnKEGGID',{'R01','R02','R03'});                              

% change the directory
cd(currentDir)