% The COBRAToolbox: testProductionEnvelope.m
%
% Purpose:
%     - test the productionEnvelope function
%
% Function under test:
%     src/design/productionEnvelope.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - optimisation on ecoli_core_model and on a hand-built toy model.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
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
fileDir = fileparts(which('testProductionEnvelope'));
cd(fileDir);

% require an LP solver; skip gracefully if none is available
prepareTest('needsLP', true);

% test variables
model = readCbModel('ecoli_core_model.mat');
model.lb(36) = 0; % Set anaerobic conditions
biomassRxn = model.rxns{13};
targetRxn = model.rxns{20};
deletions = model.rxns(23);
deletions2 = model.genes(23);

% reference data
refData_biomass = (0:(0.2111/19):0.2111)';
refData_targetValues = zeros(20, 2);
refData_targetValues(14:20, 1) = [0.6599, 1.9014, 3.1430, 4.3845, 5.6260, 6.8675, 8.3187];
refData_targetValues(:,2) = (10:(-1.6813/19):8.3187)';

refData_biomass2 = (0:(0.2117/19):0.2117)';
refData_targetValues2 = zeros(20, 2);
refData_targetValues2(18:20, 1) = [0.6148, 4.5592, 8.5036];
refData_targetValues2(:,2) = (10:(-1.4964/19):8.5036)';

% function outputs
[biomassValues, targetValues, lineHandle] = productionEnvelope(model, deletions, 'k', targetRxn, biomassRxn)
[biomassValues2, targetValues2, lineHandle2] = productionEnvelope(model, deletions2, 'k', targetRxn, biomassRxn, 1)
try
    productionEnvelope(model); % a default call with this model causes an error
catch ME
    assert(length(ME.message) > 0)
end

% tests
assert(isequal((abs(refData_biomass-biomassValues) < 1e-4), true(20, 1)));
assert(isequal((abs(refData_targetValues-targetValues) < 1e-4), true(20, 2)));

assert(isequal((abs(refData_biomass2-biomassValues2) < 1e-4), true(20, 1)));
assert(isequal((abs(refData_targetValues2-targetValues2) < 1e-4), true(20, 2)));

%% Biomass values without a feasible flux distribution give NaN
% Toy model: the uptake EX_a (at most 10) feeds b through CONV, and b leaves through R1, R2 and
% the target T. With the two reactions R1 and R2 as biomass, their sum ranges from 0 to 10, but
% both are fixed to each biomass value, so a value above 5 is infeasible. Up to that value the
% target can take everything that is left, 10 - 2 * biomass, and its minimum is 0.
toyModel = struct();
toyModel.mets = {'a[c]'; 'b[c]'};
toyModel.rxns = {'EX_a'; 'CONV'; 'R1'; 'R2'; 'T'};
toyModel.S = sparse([1 -1 0 0 0; 0 1 -1 -1 -1]);
toyModel.lb = zeros(5, 1);
toyModel.ub = [10; 1000; 1000; 1000; 1000];
toyModel.c = [0; 0; 1; 0; 0];
toyModel.b = zeros(2, 1);
toyModel.csense = 'EE';
toyModel.osenseStr = 'max';
[toyBiomass, toyTarget] = productionEnvelope(toyModel, {}, 'k', 'T', {'R1'; 'R2'}, false, 5);

tolToy = 1e-6; % LP feasibility tolerance
assert(max(abs(toyBiomass - [0; 2.5; 5; 7.5; 10])) < tolToy);
assert(max(max(abs(toyTarget(1:3, :) - [0, 10; 0, 5; 0, 0]))) < tolToy);
assert(all(all(isnan(toyTarget(4:5, :)))));

close all hidden force

% change to old directory
cd(currentDir);
