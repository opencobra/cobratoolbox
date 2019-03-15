% The COBRAToolbox: testROOM.m
%
% Purpose:
%     - Check the function ROOM
%
% Authors:
%     - Luis V. Valcarcel 2018-12-17
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
