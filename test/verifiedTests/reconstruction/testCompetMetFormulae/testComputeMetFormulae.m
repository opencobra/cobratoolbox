% The COBRAToolbox: testCompetMetFormulae.m
%
% Purpose:
%     - testCompetMetFormulae tests the computeMetFormulae function and its different methods
%
% Author:
%     - Siu Hung Joshua Chan, 2017 Nov

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testComputeMetFormulae'));
cd(fileDir);

% save original solve
global CBT_LP_SOLVER;
orig_solver = CBT_LP_SOLVER;

changeCobraSolver('gurobi', 'LP');
% check the added functionality in computeElementalMatrix
% test parsing generic formulae
modelTest = struct();
[modelTest.mets, modelTest.metFormulas] = deal({'A'; 'B'; 'C'}, {'C6H11O9PCharge-1', '[H2O]5CuSO4', 'Random_element-0.5(Abc(O2)1.5)2'});
[metEleTest, eleTest] = computeElementalMatrix(modelTest, [], false, true);
eleTest0 = {'C'; 'O'; 'H'; 'P'; 'Charge'; 'Cu'; 'S'; 'Abc'; 'Random_element'};
metEleTest0 = [6, 9, 11, 1, -1, 0, 0, 0,    0;...
               0, 9, 10, 0,  0, 1, 1, 0,    0;...
               0, 6,  0, 0,  0, 0, 0, 2, -0.5];
[yn, id] = ismember(eleTest, eleTest0);
assert(all(yn))
assert(isequal(metEleTest, metEleTest0(:, id)))
% test error message
modelTest.metFormulas{2} = '(H2O(2HO)2)2';
try
    [metEleTest, eleTest] = computeElementalMatrix(modelTest, [], false, true);
    error('Should not finish!')
catch ME
end
assert(~isempty(strfind(ME.message, '#1: Invalid chemical formula. Only ''HO'' can be recognized from ''(2HO)'' in the input formula ''(H2O(2HO)2)2''.')))
assert(~isempty(strfind(ME.message, 'Each element should start with a capital letter followed by lower case letters or ''_'' with indefinite length and followed by a number.')))

% test eleMatrixToFormulae
formulae = eleMatrixToFormulae(eleTest, metEleTest);
assert(all(strcmp(formulae, {'C6H11O9PCharge-1'; 'H10O9SCu'; 'O6Abc2Random_element-0.5'})))

% ensure the original functionality is unchanged
[metEleTest, eleTest] = computeElementalMatrix(modelTest, 'A');
assert(isequal(eleTest, {'C', 'N', 'O', 'H', 'P', 'Other'}))
assert(isequal(metEleTest, [6 0 9 11 1 0]))
elementMwStruct = struct('H', 1, 'C', 12, 'N', 14, 'O', 16, 'Na', 23, 'Mg', 24, 'P', 31, ...
    'S', 32, 'Cl', 35, 'K', 39, 'Ca', 40, 'Mn', 55, 'Fe', 56, 'Ni', 58, 'Co', 59, ...
    'Cu', 63, 'Zn', 65, 'As', 75, 'Se', 80, 'Ag', 107, 'Cd', 114, 'W', 184, 'Hg', 202);
modelTest.metFormulas{1} = strjoin(fieldnames(elementMwStruct), '');
[metEleTest, eleTest] = computeElementalMatrix(modelTest, 'A');
assert(isequal(metEleTest, [1 1 1 1 1 18]));

% load a model for testing
model = readCbModel('Abiotrophia_defectiva_ATCC_49176.mat');

% check the function findElementaryMoietyVectors
EMV = findElementaryMoietyVectors(model);
% random combination to form non-elementary moiety vectors
L = EMV * (randi(11, size(EMV, 2), 10) - 1);
D = decomposeMoietyVectors(L, model.S(:, sum(model.S ~= 0, 1) > 1));
assert(size(D, 2) <= size(EMV, 2))
assert(all(ismember(D' ~= 0, EMV' ~= 0, 'rows')))

% get the elemental compoisiton matrix for all metabolites
[metEle, ele] = computeElementalMatrix(model, [], false, true);
% find the molecular weight of each element
modelEle = struct();
[modelEle.mets, modelEle.metFormulas] = deal(ele);
MWele = computeMW(modelEle, [], false, true);
% generic elements will have weight = 0
metKnown = model.mets(~any(metEle(:, MWele == 0), 2) & ~cellfun(@isempty, model.metFormulas));
% PGPm1[c] is involved in the biomass reaction and is an exchange 
% metabolite (with a sink reaction) without known chemical formula. 
% Fix it and treat it as known. Or the max possible biomass MW may be unbounded.
model.metFormulas{findMetIDs(model, 'PGPm1[c]')} = 'Pg_subunit';
% the following pseudo metabolites are also exchangable (with demand
% reactions). They acutaully contribute nothing to the biomass reaction.
pseudoMet = {'dnarep[c]'; 'rnatrans[c]'; 'proteinsynth[c]'};
% 'Mass0' is a special chemical formula retained for 'massless' metabolites
% such as electron, photon, or other pseudo metabolites.
model.metFormulas(findMetIDs(model, pseudoMet)) = {'Mass0'};
% Include them as metabolites with known formulae to properly bound the model
metKnown = [metKnown; {'PGPm1[c]'}; pseudoMet];

% infer chemical formulae under minimum inconsistency
[model1, metFormulae, ele, metEle, rxnBalance, S_fill, solInfo, LP] = computeMetFormulae(model, metKnown, 'printLevel', 0);
assert(max(max(abs(metEle' * model.S - rxnBalance))) < 1e-6)
% check the biomass MW
biomassMw = computeMW(model1, 'biomass[c]', 0, 1);
assert(abs(biomassMw - 918.8727) < 1e-2)
% find the range for the biomass molecular weight under minimum inconsitency
[biomassMwRange, biomassFormula] = computeMetFormulae(model, 'knownMets', metKnown, 'metMwRange', 'biomass[c]');
% check the range (should be a unique value)
assert(max(abs(biomassMwRange - 918.8727)) < 1e-3)

% test other parameters

% print messages
computeMetFormulae(model, metKnown, 'printLevel', 1);
% solver-specific parameter structure (time limit = 0, no solution)
diary('testBiomassMW_diary.txt')
[model2, metFormulae2, ele2, metEle2, rxnBalance2, S_fill2, solInfo2] = computeMetFormulae(model, metKnown, struct('TimeLimit', 0), 'printLevel', 1);
diary off
assert(all(cellfun(@isempty, {metFormulae2; ele2; metEle2; rxnBalance2; S_fill2})))
f = fopen('testBiomassMW_diary.txt', 'r');
text = '';
l = fgets(f);
while ~isequal(l, -1)
    text = [text ' ' l];
    l = fgets(f);
end
assert(~isempty(strfind(text, 'Critical failure: no feasible solution is found.')))
delete('testBiomassMW_diary.txt')

% partial matching and find conserved moieties using the left null space
[~, ~, ~, ~, ~, ~, solInfo2] = computeMetFormulae(model, 'k', metKnown, ...
    'balanced', model.rxns(sum(model.S ~= 0, 1) > 1), 'calcCMs', 'null');
% columns with all entries non-negative are subset of elementary moiety vectors
posCol = all(solInfo2.N >= 0, 1);
assert(size(solInfo.N, 2) >= sum(posCol))
assert(all(ismember(solInfo2.N(:, posCol)' ~= 0, solInfo.N' ~= 0, 'rows')))
% more than one metabolites for filling inconsistency. And supply elementary moiety vectors
[model2, metFormulae2, ele2, metEle2, rxnBalance2, S_fill, solInfo, LP] = ...
    computeMetFormulae(model, metKnown, [], {'HCharge1', 'H2O'}, [], 'calcCMs', solInfo.N);
% results should be very close (can differ by the representation of
% conserved moieties
[yn, id] = ismember(ele2, ele);
assert(all(yn))
assert(sum(any(abs(metEle2 - metEle(:, id)) > 1e-5, 2)) < 5)

% no metabolite for filling inconsistency
[model2, metFormulae2, ele2, metEle2, rxnBalance2, S_fill, solInfo, LP] = ...
    computeMetFormulae(model, metKnown, [], 'none', [], 'calcCMs', false);
% results should be very close (can differ by the representation of
% conserved moieties
[yn, id] = ismember(ele2, ele);
assert(all(yn))
assert(sum(any(abs(metEle2 - metEle(:, id)) > 1e-5, 2)) < 5)

% test another solver
changeCobraSolver('ibm_cplex', 'LP');
[model2, metFormulae2, ele2, metEle2, rxnBalance2, S_fill, solInfo, LP] = ...
    computeMetFormulae(model, metKnown, [], 'none', [], 'calcCMs', false);
% results should be very close (can differ by the representation of
% conserved moieties
[yn, id] = ismember(ele2, ele);
assert(all(yn))
assert(sum(any(abs(metEle2 - metEle(:, id)) > 1e-5, 2)) < 5)

% change back to the original solver
changeCobraSolver(orig_solver, 'MILP', 0);

% change the directory
cd(currentDir)