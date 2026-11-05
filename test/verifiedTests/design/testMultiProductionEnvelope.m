% The COBRAToolbox: testmultiProductionEnvelope.m
%
% Purpose:
%     - test the multiProductionEnvelope function
%
% Function under test:
%     src/design/multiProductionEnvelope.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - optimisation on ecoli_core_model and on hand-built toy models.
%
% Coverage exemptions:
%     Line 141: GUI, the plot tools open interactive windows.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The wrong reaction is removed when a later substrate is next to the end of the list
%       SEVERITY: wrong-result
%       TRIGGER: a second or later substrate at position n - 1 of the n carbon exchange
%         reactions, for example ecoli_core_model with EX_pyr(e) lower bound -1
%       OBSERVED: the test j == length(CExcRxns) compares the original position with the length
%         of the list that already lost a substrate, so the last entry is removed: EX_pyr(e)
%         stays in the list and EX_succ(e) is dropped
%       EXPECTED: EX_pyr(e) is removed and EX_succ(e) stays
%       LINES: 77-78
%     - DEFECT: An unbounded minimum is stored in the upper bounds
%       SEVERITY: error
%       TRIGGER: a target whose minimum is unbounded, which needs a carbon uptake with an infinite
%         lower bound left in the list by the defect above
%       OBSERVED: targetUpperBounds is set to Inf and targetLowerBounds gets no value, so the two
%         differ in size and plot stops with 'Specify the coordinates as vectors or matrices'
%       EXPECTED: targetLowerBounds is set to -Inf
%       LINES: 119-120
%
% Authors:
%     - Jacek Wachowiak
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
global CBTDIR
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMultiProductionEnvelope'));
cd(fileDir);

% require an LP solver; skip gracefully if none is available
solvers = prepareTest('needsLP', true);

% test variables
model = getDistributedModel('ecoli_core_model.mat');
model.lb(36) = 0; % setting the model to anaerobic conditions
model.ub(36) = 0; % setting the model to anaerobic conditions
biomassRxn = model.rxns(13);
target = model.rxns(13); % objective = biomass reaction
deletions = model.rxns(21);
deletions2 = model.genes(21);
targetreactionsBasic = {'EX_ac(e)','EX_for(e)','EX_ethoh(e)'};

%reference data
refData_x=(0:(0.2117/19):0.2117)';
refData_lowerbound = zeros(20, 1); % EX_ac(e)
refData_lowerbound(18) = 0.0736;
refData_lowerbound(19) = 3.9862;
refData_lowerbound(20) = 8.5036;
 refData_upperBound = (10:(-1.4964/19):8.5036)';

% function outputs
% each column of targetValues corresponds to one reaction results, while biomassValues is the x axis
% for this test: 1	EX_ac(e), 2	EX_acald(e), 3	EX_akg(e), 4	EX_etoh(e), 5	EX_for(e), after that the results do not correspond to the graph,
% additionally there are always 2 curves, the data corresponds to the lower one
[biomassValues, targetLowerBounds, targetUpperBounds, targetReactions] = multiProductionEnvelope(model);
[biomassValues2, targetLowerBounds2, targetUpperBounds2, targetReactions2] = multiProductionEnvelope(model, deletions, biomassRxn);
%gene not reaction removal
[biomassValues3, targetLowerBounds3, targetUpperBounds3,  targetReactions3] = multiProductionEnvelope(model, deletions2, biomassRxn, 1, 20);

% tests - not all results are possible to be tested, the suitable were chosen
% x axis comparison
assert(isequal((abs(refData_x-biomassValues) < 1e-4), true(20, 1)));
assert(isequal((abs(refData_lowerbound-targetLowerBounds(:,ismember(targetReactions,'EX_ac(e)'))) < 1e-4), true(20, 1)));
assert(isequal((abs(refData_upperBound-targetUpperBounds(:, ismember(targetReactions,'EX_ac(e)'))) < 1e-4), true(20, 1)));

%% Toy models for the exchange list and for the status of the LPs
% The substrate of the toy model is the first (a) or the last (z) carbon exchange, sorted by
% name, and leaves the list. Its uptake (at most 10) goes to the biomass reactions R1 and R2 and
% to the product p. With both R1 and R2 as biomass, each fixed to the biomass value, a value
% above 5 is infeasible; up to that value p takes 10 - 2 * biomass and its minimum is 0.
changeCobraSolver(solvers.LP{1}, 'LP', 0);
tolToy = 1e-6; % LP feasibility tolerance
toyModel = struct();
toyModel.mets = {'a[c]'; 'd[c]'; 'p[c]'};
toyModel.metFormulas = {'C6H12O6'; 'H2O'; 'C2H4O2'};
toyModel.rxns = {'EX_a'; 'R1'; 'R2'; 'CONV'; 'EX_d'; 'EX_p'};
toyModel.S = sparse([-1 -1 -1 -1 0 0; 0 1 1 0 -1 0; 0 0 0 1 0 -1]);
toyModel.lb = [-10; 0; 0; 0; 0; 0];
toyModel.ub = [0; 1000; 1000; 1000; 1000; 1000];
toyModel.c = [0; 1; 0; 0; 0; 0];
toyModel.b = zeros(3, 1);
toyModel.csense = 'EEE';
toyModel.osenseStr = 'max';

[toyBiomass, toyLower, toyUpper, toyReactions] = multiProductionEnvelope(toyModel, {}, {'R1'; 'R2'}, false, 5, true);
assert(isequal(toyReactions, {'EX_p'}));
assert(max(abs(toyBiomass - [0; 2.5; 5; 7.5; 10])) < tolToy);
assert(max(abs(toyUpper(1:3) - [10; 5; 0])) < tolToy);
assert(max(abs(toyLower(1:3))) < tolToy);
assert(all(isnan(toyUpper(4:5))) && all(isnan(toyLower(4:5))));

% the only substrate at the end of the sorted list
toyModelLast = toyModel;
toyModelLast.rxns{1} = 'EX_z';
[~, ~, ~, toyReactionsLast] = multiProductionEnvelope(toyModelLast, {}, 'R1', false, 3, true);
assert(isequal(toyReactionsLast, {'EX_p'}));

%% A product without an upper limit gives an infinite upper bound
% The uptake of n, without carbon and unlimited, makes p without limit next to the biomass.
toyUnbounded = struct();
toyUnbounded.mets = {'a[c]'; 'n[c]'; 'p[c]'};
toyUnbounded.metFormulas = {'C6H12O6'; 'H2O'; 'C2H4O2'};
toyUnbounded.rxns = {'EX_a'; 'EX_n'; 'CONV'; 'BIO'; 'EX_p'};
toyUnbounded.S = sparse([-1 0 0 -1 0; 0 -1 -1 -1 0; 0 0 1 0 -1]);
toyUnbounded.lb = [-10; -Inf; 0; 0; 0];
toyUnbounded.ub = [0; 0; Inf; 1000; Inf];
toyUnbounded.c = [0; 0; 0; 1; 0];
toyUnbounded.b = zeros(3, 1);
toyUnbounded.csense = 'EEE';
toyUnbounded.osenseStr = 'max';
[~, unboundedLower, unboundedUpper, unboundedReactions] = multiProductionEnvelope(toyUnbounded, {}, 'BIO', false, 3, true);
assert(isequal(unboundedReactions, {'EX_p'}));
assert(all(isinf(unboundedUpper) & unboundedUpper > 0));
assert(max(abs(unboundedLower)) < tolToy);

close all hidden force

% change to old directory
cd(currentDir);
fprintf('\nDone\n');
