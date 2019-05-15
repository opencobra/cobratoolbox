% The COBRAToolbox: testCompetMetFormulae.m
%
% Purpose:
%     - testCompetMetFormulae tests the computeMetFormulae function and its different methods
%
% Author:
%     - Siu Hung Joshua Chan, 2017 Nov

% save the current path
currentDir = pwd;

%This tests requires gurobi and cplex. 
prepareTest('requiredSolver',{'gurobi','ibm_cplex'});

% initialize the test
fileDir = fileparts(which('testComputeMetFormulae'));
cd(fileDir);

% save original solve
global CBT_LP_SOLVER
orig_lp_solver = CBT_LP_SOLVER;

global CBT_MILP_SOLVER
orig_milp_solver = CBT_MILP_SOLVER;

changeCobraSolver('gurobi', 'LP');
changeCobraSolver('gurobi', 'MILP');
% check the added functionality in computeElementalMatrix
% test parsing generic formulae
modelTest = struct();
[modelTest.mets, modelTest.metFormulas] = deal({'A'; 'B'; 'C'}, {'C6H11O9P', '[H2O]5CuSO4', 'Random_element0.5(Abc(O2)1.5)2'});
[metEleTest, eleTest] = computeElementalMatrix(modelTest, [], false, true);
eleTest0 = {'C'; 'O'; 'H'; 'P'; 'Cu'; 'S'; 'Abc'; 'Random_element'}';
metEleTest0 = [6, 9, 11, 1, 0, 0, 0,   0;...
               0, 9, 10, 0, 1, 1, 0,   0;...
               0, 6,  0, 0, 0, 0, 2, 0.5];
[yn, id] = ismember(eleTest, eleTest0);
assert(all(yn))
assert(isequal(metEleTest, metEleTest0(:, id)))
% test error message
modelTest.metFormulas{1} = 'H-1CO2(H2O(HO)2)-2';
modelTest.metFormulas{2} = '(H2O((2OH)O-5)2)2';
try
    [metEleTest, eleTest] = computeElementalMatrix(modelTest, [], false, true);
    error('Should not finish!')
catch ME
end
errMsg = load('testComputeMetFormulae_errorMessages.mat');
assert(isequal(ME.message, errMsg.errMsg1))

% test getElementalComposition (called by coputeElementalMatrix when genericFormula = true)
[modelTest.mets, modelTest.metFormulas] = deal({'A'; 'B'; 'C'}, {'C6H11O9P', '[H2O]5CuSO4', 'Random_element0.5(Abc(O2)1.5)2'});
% formulae as input
[metEleTest2, eleTest2] = getElementalComposition(modelTest.metFormulas);
% COBRA model as input
[metEleTest3, eleTest3] = getElementalComposition(modelTest);
[yn, id] = ismember(eleTest2, eleTest);
assert(all(yn) & numel(eleTest2) == numel(eleTest))
assert(isequal(eleTest2, eleTest3))
assert(isequal(metEleTest(:, id), metEleTest2) & isequal(metEleTest(:, id), metEleTest3))

% error with 'Charge' in formula
try
    [Ematrix, element] = getElementalComposition('C6H11O9PCharge-1');
    error('Should not finish!')
catch ME
end
assert(isequal(ME.message, errMsg.errMsg2))
% ok with 'Charge' in formula if chargeInFormula = true
[Ematrix, elements] = getElementalComposition('C6H11O9PCharge-1', [], true);
[yn, id] = ismember(elements, {'C', 'H', 'O', 'P', 'Charge'});
Ematrix0 = [6 11 9 1 -1];
assert(all(yn))
assert(isequal(Ematrix, Ematrix0(:, id)))
[Ematrix, elements] = getElementalComposition('C6H11O9PCharge-1', {'Charge', 'P'}, true);
% preserve the order of elements
assert(isequal(elements(1:2), {'Charge', 'P'}))

% test elementalMatrixToFormulae
formulae = elementalMatrixToFormulae(metEleTest, eleTest);
assert(all(strcmp(formulae, {'C6H11O9P'; 'H10O9SCu'; 'O6Abc2Random_element0.5'})))
% return 'Mass0' for metabolites with all zeros the the elemental compoisiton matrix
assert(isequal(elementalMatrixToFormulae([0, 0, 0, 0], {'C', 'H', 'O', 'R'}), {'Mass0'}))
% duplicate elements
assert(isequal(elementalMatrixToFormulae([1, 1, 1], {'H', 'O', 'H'}), {'H2O'}))

% ensure the original functionality is unchanged
modelTest.mets = {'A'};
modelTest.metFormulas = {'C6H11O9PRandom_element0.5'};
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
MWele = getMolecularMass(ele, 0, 1);
% generic elements will have weight = NaN
metKnown = model.mets(~any(metEle(:, isnan(MWele)), 2) & ~cellfun(@isempty, model.metFormulas));
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
[biomassMw, biomassEleComp, biomassEle, knownMw, unknownEle] = computeMW(model1, 'biomass[c]', 0, 1);
% sum of the stoich for all metabolites containing Pg_subunit is not
% exactly zero (-2e-7), causing the slight difference accounted by the biomass
assert(isequal(unknownEle, {'Pg_subunit'}))
assert(biomassEleComp(strcmp(biomassEle, 'Pg_subunit')) == 2e-7)
% MW = NaN since it contains an unknown group
assert(isnan(biomassMw))  
% the MW for the known part
assert(abs(knownMw - 919.7837) < 1)  % allow 1 g/mmol descrepancy

% find the range for the biomass molecular weight under minimum inconsitency
[biomassMwRange, biomassFormula] = computeMetFormulae(model, 'knownMets', metKnown, 'metMwRange', 'biomass[c]');
% check the range (should be a unique value)
assert(max(abs(biomassMwRange - 919.7837)) < 1)

% find the range for an already knwon metabolites
[atpMwRange, atpFormula] = computeMetFormulae(model, 'metMwRange', 'atp[c]', 'knownMets', metKnown);
assert(atpMwRange(1) == atpMwRange(2) & abs(atpMwRange(1) - 503.1493) < 1)
assert(strcmp(atpFormula{1}, atpFormula{2}) &  strcmp(atpFormula{1}, model.metFormulas{findMetIDs(model, 'atp[c]')}))

% call without charge balancing
modelWoCharge = model;
modelWoCharge.metCharges(:) = NaN;
[modelWoCharge, metFormulae] = computeMetFormulae(modelWoCharge, metKnown);
[biomassMw, biomassEleComp, biomassEle, knownMw, unknownEle] = computeMW(modelWoCharge, 'biomass[c]', [], 1);
% should be the same as above
assert(isequal(unknownEle, {'Pg_subunit'}))
assert(biomassEleComp(strcmp(biomassEle, 'Pg_subunit')) == 2e-7)
assert(isnan(biomassMw))  
assert(abs(knownMw - 919.7837) < 1)

% test other parameters

% print EFM calculations
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
fclose(f);
assert(~isempty(strfind(text, 'Critical failure: no feasible solution is found.')))
delete('testBiomassMW_diary.txt')

% partial matching and find conserved moieties using the left null space
[~, ~, ~, ~, ~, ~, solInfo2] = computeMetFormulae(model, 'k', metKnown, ...
    'balanced', model.rxns(sum(model.S ~= 0, 1) > 1), 'calcCMs', 'null');
% columns with all entries non-negative are subset of elementary moiety vectors
posCol = all(solInfo2.N >= 0, 1);
assert(size(solInfo.N, 2) >= sum(posCol))
assert(all(ismember(solInfo2.N(:, posCol)' ~= 0, solInfo.N' ~= 0, 'rows')))

% calculate left null space matrix only for metabolites not in dead end
% call findElementaryMoietyVectors directly (called by computeMetFormulae)
NwoDeadend = findElementaryMoietyVectors(model, 'method', 'null', 'deadCMs', false);
assert(size(NwoDeadend, 2) == 6)
assert(all(ismember(NwoDeadend(:, all(NwoDeadend >= 0, 1))' ~= 0, solInfo.N' ~= 0, 'rows')))

% more than one metabolites for filling inconsistency. And supply elementary moiety vectors
[model2, metFormulae2, ele2, metEle2, rxnBalance2, S_fill, solInfo, LP] = ...
    computeMetFormulae(model, metKnown, [], {'HCharge1', 'H2O'}, [], 'calcCMs', solInfo.N);
% results should be very close (can differ by the representation of
% conserved moieties
[yn, id] = ismember(ele2, ele);
assert(all(yn))
assert(sum(any(abs(metEle2 - metEle(:, id)) > 1e-5, 2)) < 5)

% supplying the elementary moiety vectors and the corresponding formulae
cmNames = repmat({''}, 1, size(solInfo.N, 2));
% H1R, H2R, ..., HnR for the first, second, ..., n-th moieties
numCellStr = cellfun(@num2str, num2cell((1:sum(solInfo.cmUnknown))'), 'UniformOutput', false);
cmNames(solInfo.cmUnknown) = strcat('H', numCellStr, 'R');
[model3, metFormulae3, ele3, metEle3, rxnBalance3, S_fill3, solInfo3] = ...
    computeMetFormulae(model, metKnown, 'calcCMs', solInfo.N, 'nameCMs', cmNames);
% check that the results are the same as the previous if we directly
% replace the generic elements in the previous solution with the supplied formulae
ct = 0;
for j = 1:numel(solInfo.cmFormulae)
    if solInfo.cmUnknown(j)
        ct = ct + 1;
        model2.metFormulas = strrep(model2.metFormulas, solInfo.cmFormulae{j}, ['H' num2str(ct) 'R']);
    end
end
% get elemental matrix
[metEle2, ele2] = getElementalComposition(model2.metFormulas);
[yn, id] = ismember(ele2, ele3);
% ele3 from the algorithm contains 'Charge' as an element. ele2 does not.
assert(all(yn) && numel(ele2) == numel(ele3) - 1)
% check that the inferred formulae are the same
assert(max(max(abs(metEle2 - metEle3(:, id)))) < 1e-5)

% check that the identified moieties involving dead end metabolites are correct 
[~, removedMets] = removeDeadEnds(model);
metDeadId = findMetIDs(model, removedMets);
% all identified moieties involve dead end mets
assert(all(any(solInfo.N(metDeadId, solInfo.cmDeadend), 1)))
% other moieties do not invovle dead end mets
assert(~any(any(solInfo.N(metDeadId, ~solInfo.cmDeadend), 1)))

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

% change the directory
cd(currentDir)