% The COBRAToolbox: testSimpleOptKnock.m
%
% Purpose:
%     - test the simpleOptKnock function
%
% Function under test:
%     src/design/simpleOptKnock.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - optimisation on ecoli_core_model, loaded through getDistributedModel.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The wild-type minimum production is the maximum
%       SEVERITY: wrong-result
%       TRIGGER: any call (output wtRes.minProd)
%       OBSERVED: solMin is computed with the default maximisation, so wtRes.minProd equals
%         wtRes.maxProd
%       EXPECTED: the minimum production at the wild-type growth rate ('min' sense, as used for
%         the deletion strains)
%       LINES: 66
%     - DEFECT: Single-deletion growth is stored in the first column in double-deletion mode
%       SEVERITY: limitation
%       TRIGGER: doubleDelFlag true
%       OBSERVED: delRes.growth(i, 1) holds the growth of the single deletion i, whereas
%         delRes.maxProd and delRes.minProd hold the single deletion on the diagonal (i, i)
%       EXPECTED: the same layout for the three outputs
%       LINES: 104
%
% Authors:
%     - Jacek Wachowiak
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
global CBTDIR
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSimpleOptKnock'));
cd(fileDir);

% require an LP solver; skip gracefully if none is available
prepareTest('needsLP', true);

% test variables
model = getDistributedModel('ecoli_core_model.mat');
targetRxn = model.rxns(20); % 'EX_ac(e)'

% function outputs
[wtRes, delRes] = simpleOptKnock(model, targetRxn);
[wtRes2, delRes2] = simpleOptKnock(model, targetRxn, model.genes(1), 1, 0.5, 1);

% tests
assert(abs(12.1585 - delRes.maxProd(23)) < 1e-4); % 'EX_co2(e)'
assert(abs(14.3123 - delRes.maxProd(12)) < 1e-4);% 'ATPS4r'
assert(abs(12.1584 - delRes.minProd(14)) < 1e-4);% 'CO2t'
assert(abs(8.5036 - delRes.minProd(16)) < 1e-4);% 'CYTBD'
assert(abs(0.8739 - wtRes.growth) < 1e-4);% always the same
%for gene deletions
assert(abs(0.8739 - wtRes2.growth) < 1e-4);% always the same
assert(abs(3e-07 - delRes2.maxProd) < 1e-4);
assert(abs(delRes2.minProd) < 1e-4);

%% The missing rxnGeneMat field is built
% The field is only needed for gene deletions, so reaction deletions give the same result.
[~, delResWithMat] = simpleOptKnock(model, targetRxn, model.rxns(1:2));
[~, delResNoMat] = simpleOptKnock(rmfield(model, 'rxnGeneMat'), targetRxn, model.rxns(1:2));
assert(max(abs(delResWithMat.growth - delResNoMat.growth)) < 1e-6);

%% Double reaction deletions
% CYTBD and LDH_D can be deleted together and CYTBD forces acetate secretion; ENO is lethal. The
% repeated ENO makes the list 50 entries long, the length at which progress is printed, while
% only the two viable first deletions go through the second loop. Tolerance 1e-6: LP values.
tolLP = 1e-6;
doubleDeletions = [{'CYTBD'; 'LDH_D'}; repmat({'ENO'}, 48, 1)];
[~, delResDouble] = simpleOptKnock(model, targetRxn, doubleDeletions, false, 0.05, true);
assert(isequal(size(delResDouble.growth), [50, 50]));

% independent evaluation of the viable pair, with the same growth rounding as the function
modelPair = changeRxnBounds(model, {'CYTBD', 'LDH_D'}, 0, 'b');
solPair = optimizeCbModel(modelPair);
modelPair = changeRxnBounds(modelPair, model.rxns(model.c == 1), floor(solPair.f / 1e-7) * 1e-7, 'l');
modelPair = changeObjective(modelPair, targetRxn, 1);
solPairMax = optimizeCbModel(modelPair, 'max');
solPairMin = optimizeCbModel(modelPair, 'min');
assert(abs(delResDouble.growth(1, 2) - solPair.f) < tolLP);
assert(abs(delResDouble.maxProd(1, 2) - solPairMax.f) < tolLP);
assert(abs(delResDouble.minProd(1, 2) - solPairMin.f) < tolLP);
assert(delResDouble.minProd(1, 2) > 1);

% the single deletion stays on the diagonal and agrees with the single-deletion scan
assert(abs(delResDouble.minProd(1, 1) - delRes.minProd(strcmp(model.rxns, 'CYTBD'))) < tolLP);

% a pair with the lethal ENO does not grow, so no production is reported
assert(~(delResDouble.growth(1, 3) >= 0.05)); % NaN when the pair is infeasible
assert(delResDouble.maxProd(1, 3) == 0 && delResDouble.minProd(1, 3) == 0);

%% Double gene deletions
genePair = model.genes(1:2);
[~, delResGenes] = simpleOptKnock(model, targetRxn, genePair, true, 0.05, true);
solGenes = optimizeCbModel(deleteModelGenes(model, genePair));
assert(abs(delResGenes.growth(1, 2) - solGenes.f) < tolLP);

% change to old directory
cd(currentDir);
