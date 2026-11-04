% The COBRAToolbox: testROOM.m
%
% Purpose:
%     - Check the function ROOM
%
% Function under test:
%     src/analysis/ROOM/ROOM.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - optimisation (MILP) on a toy model.
%
% Coverage exemptions:
%     Line 78: unreachable, the statement `global CBT_LP_PARAMS` above it always creates the variable, so the exist check is always true.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Luis V. Valcarcel 2018-12-17
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%

global CBTDIR

solversToUse = prepareTest('needsMILP', true, 'useSolversIfAvailable', {'tomlab_cplex', 'ibm_cplex', 'gurobi', 'glpk','cplex_direct'}, 'excludeSolvers', {'qpng'});
% Note: the solver QPNG cannot be used with this test

% save the current path
currentDir = pwd;

% initialize the test
testDir = fileparts(which('testROOM'));
cd(testDir);

% Create Toy example model
ReactionFormulas = {'A -> B', '2 B -> C + byp', '2 B + cof -> D + byp',...
'D -> E + cof', 'C + cof -> D', 'C -> E', ' -> A', 'E -> ', 'byp -> '};
ReactionNames = {'v1', 'v2', 'v3', 'v4', 'v5', 'v6', 'b1', 'b2', 'b3'};
lowerbounds = [0 0 0 0 0 0 0 0 0];
upperbounds = [20, 20, 20, 20, 20, 20, 20, 20, 20];
model = createModel(ReactionNames, ReactionNames, ReactionFormulas,...
'lowerBoundList', lowerbounds, 'upperBoundList', upperbounds);

% Generate reference flux 
WT_flux = [10, 5, 0, 0, 0, 5, 10, 5, 5];

% Check errors when missing argument
assert(verifyCobraFunctionError('ROOM', 'inputs', {model}))
assert(verifyCobraFunctionError('ROOM', 'inputs', {model, WT_flux}))
assert(verifyCobraFunctionError('ROOM', 'inputs', {model, WT_flux, 'a'}))

% define the solver packages to be used to run this test
solverPkgs = solversToUse.MILP;

predictedROOMsol = [10 5 0 5 5 0 10 5 5]';

% Test solving for different solvers
for k = 1:length(solverPkgs)
    fprintf(' -- Running testROOM using the solver interface: %s ... ', solverPkgs{k});
    
    solverOK = changeCobraSolver(solverPkgs{k}, 'all', 0);

    if solverOK
        % Calculate ROOM and check solutions
        fluxROOM = ROOM(model, WT_flux, {'v6'},'delta', 1e-5, 'epsilon', 1e-5);
        assert(norm(fluxROOM-predictedROOMsol)<1e-2)
        
        [fluxROOM, solutionROOM, totalFluxDiff] = ROOM(model, WT_flux, {'v6'},'delta',1e-6,'epsilon',1e-6);
        assert(norm(fluxROOM-predictedROOMsol)<1e-2)
        assert(abs(totalFluxDiff^2-75)<1e-2)
        
        [fluxROOM2, solutionROOM2, totalFluxDiff2] = linearROOM(model, WT_flux, {'v6'},'delta',1e-6,'epsilon',1e-6);
        assert(norm(fluxROOM-predictedROOMsol)<1e-2)
        assert(abs(totalFluxDiff^2-75)<1e-2)

        % a knock-out without a feasible flux: the uptake is fixed at 5 and its only outlet is removed
        modelInfeasible = changeRxnBounds(model, 'b1', 5, 'l');
        [fluxInfeasible, solutionInfeasible, diffInfeasible] = ROOM(modelInfeasible, WT_flux, {'v1'}, 'printLevel', 0);
        assert(solutionInfeasible.stat ~= 1);
        assert(numel(fluxInfeasible) == numel(model.rxns) && all(isnan(fluxInfeasible)));
        assert(isnan(diffInfeasible));

        % the objective tolerance of the LP parameters decides how far the reference flux may be
        % from steady state (10 * tol): a residual of 1e-4 is refused at the default 1e-6, ...
        perturbedFlux = WT_flux;
        perturbedFlux(end) = perturbedFlux(end) + 1e-4;
        assert(verifyCobraFunctionError('ROOM', 'inputs', {model, perturbedFlux, {'v6'}}, ...
                                        'testMessage', 'This flux distribution cannot exist in this model'));

        % ... and accepted with CBT_LP_PARAMS.objTol = 1e-3
        global CBT_LP_PARAMS
        savedLPParams = CBT_LP_PARAMS;
        CBT_LP_PARAMS.objTol = 1e-3;
        fluxROOM = ROOM(model, perturbedFlux, {'v6'}, 'delta', 1e-5, 'epsilon', 1e-3, 'printLevel', 0);
        CBT_LP_PARAMS = savedLPParams;
        assert(norm(fluxROOM - predictedROOMsol) < 1e-2);

    else
        warning('The test testROOM cannot run using the solver interface: %s. The solver interface is not installed or not configured properly.\n', solverPkgs{k});
    end

    % output a success message
    fprintf('Done.\n');
end

% remove the file created during the test
if exist('CobraLPSolver.log','file')
    delete('CobraLPSolver.log');
end

% Set seed to default value
rng('default')
% change the directory
cd(currentDir)
