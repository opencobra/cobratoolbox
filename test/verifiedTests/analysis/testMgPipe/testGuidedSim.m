% The COBRAToolbox: testGuidedSim.m
%
% Purpose:
%     - guidedSim computes the minimum and maximum flux of a list of reactions at 99.99% of
%       the maximal objective with fastFVA (CPLEX binary; NaN for every reaction when fastFVA
%       reports infeasibilities); if fastFVA fails it warns and uses fluxVariability at
%       99.999%, and if that also fails it warns and minimizes and maximizes each reaction
%       by FBA (optimizeCbModel).
%     - Expected values are derived by hand from the six-reaction toy model below: R1 and
%       R2 are parallel routes of the objective, so each spans [0, 10] near the optimum; T1
%       is a free cycle reaction limited only by its own bounds [-3, 5]. These ranges do not
%       depend on the objective fraction (99.99% or 99.999%), so every branch must return
%       them. On an infeasible model every branch returns NaN.
%
% Function under test:
%     src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/guidedSim.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - LP with every available LP solver among gurobi and glpk on a hand-built toy
%     model. fastFVA needs a CPLEX cplexFVA binary that works on the machine; on the
%     reference machine it runs, so the fastFVA branch (lines 30-35) is reached; where it
%     does not run (no CPLEX, as on CI) fastFVA fails, guidedSim falls back to
%     fluxVariability or FBA, and the same assertions hold. The fallback is forced here by
%     a reaction list that is not in model order, which fastFVA rejects with an error.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The help text gives a wrong usage and an input that does not exist
%       SEVERITY: cosmetic
%       TRIGGER: help guidedSim
%       OBSERVED: USAGE shows guidedSim(model, fvaType, rl) and INPUTS list solver (char with
%         solver name), and the description says the solver is set to 'cplex'; the function
%         is guidedSim(model, rl), has no fvaType or solver input and does not change the
%         solver (fastFVA uses CPLEX, the fallbacks the current COBRA solver)
%       EXPECTED: USAGE guidedSim(model, rl) and the inputs model and rl only
%       LINES: 9, 15
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGuidedSim'));
cd(fileDir);

% note the globals that exist now: the solver interface (parameter globals) and showprogress
% create globals, which are removed at the end
globalsBefore = who('global');

% the fallbacks solve LPs with the current COBRA solver
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi', 'glpk'});
initialSolverState = CobraSolverState.get();
% fastFVA reseeds the random number generator (rng('shuffle')); restore it at the end
initialRng = rng;

% toy model: EX_A supplies at most 10 A, R1 and R2 both turn A into B, BIO (objective) removes
% B; T1 and T2 form a free cycle X <=> Y, with T1 in [-3, 5]
rxnIds = {'EX_A'; 'R1'; 'R2'; 'BIO'; 'T1'; 'T2'};
model = createModel(rxnIds, rxnIds, {' -> A'; 'A -> B'; 'A -> B'; 'B -> '; 'X <=> Y'; 'Y <=> X'}, ...
    'lowerBoundList', [0; 0; 0; 0; -3; -1000], 'upperBoundList', [10; 1000; 1000; 1000; 5; 1000], ...
    'printLevel', 0);
model = changeObjective(model, 'BIO');
% the same model with BIO forced above the supply: no steady state exists
infeasibleModel = changeRxnBounds(model, 'BIO', 20, 'l');

% LP optima are exact to the solver tolerance (about 1e-9); 1e-6 separates rounding from a
% wrong range
tol = 1e-6;

for k = 1:numel(solvers.LP)
    solverOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);
    if solverOK
        fprintf('   Testing guidedSim using %s ... \n', solvers.LP{k});

        %% reactions in model order: fastFVA (or a fallback where fastFVA cannot run)

        [minFlux, maxFlux] = guidedSim(model, {'R1'; 'T1'});
        assert(isequal(size(minFlux), [2, 1]) && isequal(size(maxFlux), [2, 1]));
        assert(max(abs(minFlux - [0; -3])) < tol);
        assert(max(abs(maxFlux - [10; 5])) < tol);
        % guidedSim returns to the folder it was called from
        assert(strcmp(pwd, fileDir));

        %% reactions not in model order: fastFVA fails, fluxVariability is used

        % the results follow the order of the list
        [minFlux, maxFlux] = guidedSim(model, {'T1'; 'R1'});
        assert(max(abs(minFlux - [-3; 0])) < tol);
        assert(max(abs(maxFlux - [5; 10])) < tol);
        assert(strcmp(pwd, fileDir));

        %% infeasible model: NaN from fastFVA, or from FBA after fluxVariability fails

        % in model order fastFVA runs and reports the infeasibility (NaN for every reaction);
        % not in model order fastFVA fails, fluxVariability fails on the infeasible model and
        % the FBA loop returns the objective values of the infeasible problems, NaN
        [minFlux, maxFlux] = guidedSim(infeasibleModel, {'R1'; 'T1'});
        assert(isequal(size(minFlux), [2, 1]) && all(isnan(minFlux)) && all(isnan(maxFlux)));
        [minFlux, maxFlux] = guidedSim(infeasibleModel, {'T1'; 'R1'});
        assert(isequal(size(minFlux), [2, 1]) && all(isnan(minFlux)) && all(isnan(maxFlux)));
        assert(strcmp(pwd, fileDir));
    end
end

% restore the random number generator and the solver state
rng(initialRng);
CobraSolverState.restore(initialSolverState);

% remove the globals created during the test
newGlobals = setdiff(who('global'), globalsBefore);
for k = 1:numel(newGlobals)
    clearvars('-global', newGlobals{k});
end

% change the directory
cd(currentDir)
