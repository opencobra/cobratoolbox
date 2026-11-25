% The COBRAToolbox: testQuantitativeFluxCoupling.m
%
% Purpose:
%     - quantitativeFluxCoupling selects, for each requested coordinate [x, y] of the
%       abundance-growth grid (y outer loop, x inner loop), the closest feasible grid point,
%       constrains the community model to it (constrainEcosystemPoint), fixes the first
%       reaction of a pair to nSteps values spanning its flux range and computes the minimum
%       and maximum flux of the second reaction (fluxVariability, optPercentage 0). Fluxes of
%       member reactions are divided by the member fraction; community reactions are not.
%       The result is a table (rxn1, rxn2, FVA, point) with the pair and the point indices in
%       its UserData.
%     - Expected values are derived by hand from the six-reaction two-member community below
%       (yield 1 for both members, so every flux range is a short linear calculation, written
%       next to each assertion).
%
% Function under test:
%     src/analysis/ecosystem/quantitativeFluxCoupling.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - flux variability analysis (LP) with every available LP solver among gurobi
%     and glpk, on a hand-built community model; the ecosystem structure is hand-built with
%     the fields the function and constrainEcosystemPoint read (model, objectives,
%     memberRxns, points, feasiblePoints).
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testQuantitativeFluxCoupling'));
cd(fileDir);

% note the globals that exist now: the solver interface (parameter globals) and showprogress
% create globals, which are removed at the end
globalsBefore = who('global');

% flux variability analysis needs an LP solver
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi', 'glpk'});
initialSolverState = CobraSolverState.get();

% community: the pool supplies at most 10 A_e (EX_A_e); member 1 takes up A_e (org1_EX_A) or
% makes its A from an internal source of at most 2 (org1_SRC) and turns A into biomass with
% yield 1; member 2 grows only on A_e, also with yield 1
rxnIds = {'EX_A_e'; 'org1_EX_A'; 'org1_SRC'; 'org1_biomass'; 'org2_EX_A'; 'org2_biomass'};
model = createModel(rxnIds, rxnIds, {' -> A_e'; 'A_e -> org1_A'; ' -> org1_A'; 'org1_A -> '; ...
    'A_e -> org2_A'; 'org2_A -> '}, 'upperBoundList', [10; 1000; 2; 1000; 1000; 1000], 'printLevel', 0);
eco = struct();
eco.model = model;
eco.objectives = {'org1_biomass', 'org2_biomass'};
eco.memberRxns = {{'org1_EX_A'; 'org1_SRC'; 'org1_biomass'}, {'org2_EX_A'; 'org2_biomass'}};
% three grid points [f, mu]; the second is marked infeasible (member 2 would need 15 > 10)
eco.points = [0.5, 6; 0.5, 30; 0.25, 4];
eco.feasiblePoints = [true; false; true];

% LP solutions are exact to the solver tolerance (about 1e-9); dividing by a member fraction
% of 0.25 multiplies the error by 4, so 1e-6 separates rounding from a wrong value
tol = 1e-6;

%% wrong inputs

% the feasibility of the grid must have been computed
ecoNoFeasibility = eco;
ecoNoFeasibility.feasiblePoints = [];
assert(verifyCobraFunctionError('quantitativeFluxCoupling', 'inputs', ...
    {ecoNoFeasibility, 0.5, 6, {'org1_EX_A', 'EX_A_e'}}, ...
    'testMessage', 'Feasible points have not been computed. Run checkEcosystemGridFeasibility first.'));
% both reactions must be in the community model; the missing one is named
assert(verifyCobraFunctionError('quantitativeFluxCoupling', 'inputs', ...
    {eco, 0.5, 6, {'org1_EX_A', 'missing'}}, ...
    'testMessage', 'Reactions not found in the community model: missing'));

for k = 1:numel(solvers.LP)
    solverOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);
    if solverOK
        fprintf('   Testing quantitativeFluxCoupling using %s ... \n', solvers.LP{k});

        %% closest feasible points, member normalization and the coupling of two reactions

        % y is the outer loop: [0.5, 30] is closest to the feasible point 1 ([0.5, 6], distance
        % 24; the infeasible point 2 is skipped), then [0.5, 4] is closest to point 3
        % ([0.25, 4], distance 0.25, against 2 for point 1); printLevel 1 (default) prints them
        [qfca, selectedPoints] = quantitativeFluxCoupling(eco, 0.5, [30, 4], {'org1_EX_A', 'EX_A_e'}, 'nSteps', 3);
        assert(isequal(selectedPoints, [1; 3]));
        assert(isequal(qfca.Properties.UserData.rxnPair, {'org1_EX_A', 'EX_A_e'}));
        assert(isequal(qfca.Properties.UserData.pointIndex, [1; 3]));
        assert(isequal(qfca.Properties.VariableNames, {'rxn1', 'rxn2', 'FVA', 'point'}));
        assert(height(qfca) == 2 * 3 * 2);
        assert(isequal(qfca.FVA, repmat({'minimum'; 'maximum'}, 6, 1)));
        assert(isequal(qfca.point, [repmat({'[0.5, 6]'}, 6, 1); repmat({'[0.25, 4]'}, 6, 1)]));
        % point 1 (f = 0.5, bounds of the members scaled by [0.5, 0.5]): member 1 grows 3 from
        % org1_SRC (at most 2 * 0.5 = 1) and org1_EX_A, so org1_EX_A spans [2, 3]; member 2
        % takes up 3; EX_A_e = org1_EX_A + 3 is fixed by each value (min = max). org1_EX_A is a
        % member 1 reaction, divided by 0.5; EX_A_e belongs to no member and is not divided.
        % point 3 (f = 0.25): member 1 grows 1, org1_SRC is at most 0.5, so org1_EX_A spans
        % [0.5, 1] (divided by 0.25: [2, 4]) and EX_A_e = org1_EX_A + 3
        expectedRxn1 = [4; 4; 5; 5; 6; 6; 2; 2; 3; 3; 4; 4];
        expectedRxn2 = [5; 5; 5.5; 5.5; 6; 6; 3.5; 3.5; 3.75; 3.75; 4; 4];
        assert(max(abs(qfca.rxn1 - expectedRxn1)) < tol);
        assert(max(abs(qfca.rxn2 - expectedRxn2)) < tol);

        %% bounds not scaled, and a second reaction that belongs to member 2

        % updateBounds false keeps org1_SRC at [0, 2]: at point 3 member 1 grows 1, so org1_SRC
        % spans [0, 1] (divided by 0.25: [0, 4]); org2_EX_A is fixed to the growth 3 of member
        % 2 and is divided by its fraction 0.75 (= 4); printLevel 0 prints nothing
        qfcaFixed = quantitativeFluxCoupling(eco, 0.25, 4, {'org1_SRC'; 'org2_EX_A'}, 'nSteps', 2, ...
            'updateBounds', false, 'printLevel', 0);
        assert(height(qfcaFixed) == 4);
        assert(isequal(qfcaFixed.point, repmat({'[0.25, 4]'}, 4, 1)));
        assert(max(abs(qfcaFixed.rxn1 - [0; 0; 4; 4])) < tol);
        assert(max(abs(qfcaFixed.rxn2 - [4; 4; 4; 4])) < tol);

        %% a value of the first reaction for which the analysis fails gives NaN

        if strcmp(solvers.LP{k}, 'gurobi')
            % a free cycle (CYC1, CYC2: X <=> Y with infinite bounds) has the flux range
            % [-Inf, Inf] with gurobi (glpk reports the unbounded problem as an error of
            % fluxVariability before the loop, so this section runs with gurobi only); the
            % values are then [-Inf, 0, Inf], and fixing CYC1 to -Inf or Inf makes the
            % analysis of EX_A_e fail, which is recorded as NaN. At CYC1 = 0, EX_A_e spans
            % [5, 6] at point 1 (org1_EX_A in [2, 3] plus 3)
            cycleIds = [rxnIds; {'CYC1'; 'CYC2'}];
            ecoCycle = eco;
            ecoCycle.model = createModel(cycleIds, cycleIds, {' -> A_e'; 'A_e -> org1_A'; ' -> org1_A'; ...
                'org1_A -> '; 'A_e -> org2_A'; 'org2_A -> '; 'X <=> Y'; 'Y <=> X'}, ...
                'lowerBoundList', [0; 0; 0; 0; 0; 0; -Inf; -Inf], ...
                'upperBoundList', [10; 1000; 2; 1000; 1000; 1000; Inf; Inf], 'printLevel', 0);
            qfcaCycle = quantitativeFluxCoupling(ecoCycle, 0.5, 6, {'CYC1', 'EX_A_e'}, 'nSteps', 3, 'printLevel', 0);
            assert(isequal(qfcaCycle.rxn1, [-Inf; -Inf; 0; 0; Inf; Inf]));
            assert(all(isnan(qfcaCycle.rxn2([1, 2, 5, 6]))));
            assert(max(abs(qfcaCycle.rxn2([3, 4]) - [5; 6])) < tol);
        end
    end
end

% restore the solver state
CobraSolverState.restore(initialSolverState);

% remove the globals created during the test
newGlobals = setdiff(who('global'), globalsBefore);
for k = 1:numel(newGlobals)
    clearvars('-global', newGlobals{k});
end

% change the directory
cd(currentDir)
