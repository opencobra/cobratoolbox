% The COBRAToolbox: testMultiProductionEnvelopeInorg.m
%
% Purpose:
%     - test the multiProductionEnvelopeInorg function
%
% Function under test:
%     src/design/multiProductionEnvelopeInorg.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - optimisation on ecoli_core_model and on a hand-built toy model.
%
% Coverage exemptions:
%     Line 121: GUI, the plot tools open interactive windows.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Jacek Wachowiak
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
global CBTDIR
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMultiProductionEnvelopeInorg'));
cd(fileDir);

% require an LP solver; skip gracefully if none is available
solvers = prepareTest('needsLP', true);

% test variables
model = getDistributedModel('ecoli_core_model.mat');
model.ub(36) = 0; % anaerobic conditions
model.lb(36) = 0;
deletions = model.genes(20);
biomassRxn = model.rxns(model.c==1); % biomass
geneDelFlag = true;
nPts = 100;
plotAllFlag = true;

% reference data
refData_x=(0:(0.2117/19):0.2117)';
refData_1stcolumn = zeros(20, 1); % EX_ac(e)
refData_1stcolumn(18) = 0.0736;
refData_1stcolumn(19) = 3.9862;
refData_1stcolumn(20) = 8.5036;
refData_2ndcolumn = zeros(20, 1);
refData_6thcolumn = (10:(-1.4964/19):8.5036)';

% function calls
[biomassValues, targetValues] = multiProductionEnvelopeInorg(model);
% Feature 002: the following two calls exercise the single-reaction and
% gene-deletion/plotting paths but their outputs are never asserted; skip them
% in fast mode. Full mode runs the complete set.
if ~getCobraTestMode('isFast')
    [biomassValues1, targetValues1] = multiProductionEnvelopeInorg(model, model.rxns(20));
    [biomassValues2, targetValues2] = multiProductionEnvelopeInorg(model, deletions, biomassRxn, geneDelFlag, nPts, plotAllFlag);
end

% tests
% x axis comparison
assert(isequal((abs(refData_x-biomassValues) < 1e-4), ones(20, 1)));
% tests for 1st (rising in the end), 2nd (zeros) and 6th column (decreasing from 10 to 8.5)
assert(isequal((abs(refData_1stcolumn-targetValues(:, 1)) < 1e-4), ones(20, 1)));
assert(isequal(refData_2ndcolumn, targetValues(:, 2)));
assert(isequal((abs(refData_6thcolumn-targetValues(:, 6)) < 1e-4), ones(20, 1)));

%% Reaction and gene deletions, in a short run that fast mode also makes
% The last biomass value is the maximal growth of the deletion strain. Tolerance: LP feasibility.
tolLP = 1e-6;
solRxnDeletion = optimizeCbModel(changeRxnBounds(model, model.rxns(20), 0, 'b'));
biomassRxnDeletion = multiProductionEnvelopeInorg(model, model.rxns(20), biomassRxn, false, 3);
assert(abs(biomassRxnDeletion(end) - solRxnDeletion.f) < tolLP);

solGeneDeletion = optimizeCbModel(deleteModelGenes(model, deletions));
biomassGeneDeletion = multiProductionEnvelopeInorg(model, deletions, biomassRxn, true, 3, false);
assert(abs(biomassGeneDeletion(end) - solGeneDeletion.f) < tolLP);

%% Biomass values without a feasible flux distribution give NaN
% Toy model: the uptake of a (at most 10) goes to the biomass reactions R1 and R2 and to the
% product p. With both R1 and R2 as biomass, each fixed to the biomass value, a value above 5
% is infeasible; up to that value p takes 10 - 2 * biomass and its minimum is 0. The exchange
% reactions that do not take up are EX_d and EX_p, in this order, so EX_p is the second column
% of the lower bounds and of the upper bounds.
changeCobraSolver(solvers.LP{1}, 'LP', 0);
toyModel = struct();
toyModel.mets = {'a[c]'; 'd[c]'; 'p[c]'};
toyModel.rxns = {'EX_a'; 'R1'; 'R2'; 'CONV'; 'EX_d'; 'EX_p'};
toyModel.S = sparse([-1 -1 -1 -1 0 0; 0 1 1 0 -1 0; 0 0 0 1 0 -1]);
toyModel.lb = [-10; 0; 0; 0; 0; 0];
toyModel.ub = [0; 1000; 1000; 1000; 1000; 1000];
toyModel.c = [0; 1; 0; 0; 0; 0];
toyModel.b = zeros(3, 1);
toyModel.csense = 'EEE';
toyModel.osenseStr = 'max';
[toyBiomass, toyValues] = multiProductionEnvelopeInorg(toyModel, {}, {'R1'; 'R2'}, false, 5, true);
toyLower = toyValues(:, 1:end/2);
toyUpper = toyValues(:, end/2+1:end);
assert(max(abs(toyBiomass - [0; 2.5; 5; 7.5; 10])) < tolLP);
assert(max(abs(toyUpper(1:3, end) - [10; 5; 0])) < tolLP);
assert(max(abs(toyLower(1:3, end))) < tolLP);
assert(all(all(isnan(toyValues(4:5, end/2:end)))));

close all hidden force

% change to old directory
cd(currentDir);
