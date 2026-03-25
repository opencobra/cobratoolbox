% The COBRAToolbox: testQuadLP
%
% Purpose:
%     - Testing all available quad precision solvers
%
% Authors:
%     - Ronan Fleming 2026
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testQuadLP'));
cd(fileDir);

global CBTDIR

%Test the requirements
%useSolversIfAvailable = {'gurobi','quadMinos', 'dqqMinos',};
%useSolversIfAvailable = {'gurobi','quadMinos'};

requiredSolvers = {'quadMinos','dqqMinos'};
useSolversIfAvailable = {'mosek'};
excludeSolvers = {'pdco'};
requiredSoftwares = {'csh'};
       
solvers = prepareTest('needsLP',true,'requiredSolvers',requiredSolvers, 'useSolversIfAvailable',useSolversIfAvailable,'excludeSolvers',excludeSolvers, 'requiredSoftwares', requiredSoftwares);

fprintf('   Testing testQuadLP ... ')

solverOK = changeCobraSolver('quadMinos', 'LP');

% test solver packages
solverPkgs = solvers.LP;

if 1
    % load the ecoli_core_model
    model = getDistributedModel('ecoli_core_model.mat');
else
    % load the ecoli_core_model
    model = getDistributedModel('ME_matrix_GlcAer_WT.mat');
end

% set the tolerance
params.feasTol = getCobraSolverParams('LP','feasTol');

% run LP with various solvers
[~, all_obj] = runLPvariousSolvers(model, solverPkgs, params);



% set up QP problem
QPproblem.F = [8, 1; 1, 8];  % Matrix F in 1/2 * x' * F * x + c' * x
QPproblem.c = [3, -4]';  % Vector c in 1/2 * x' * F * x + c' * x
QPproblem.A = [1, 1; 1, -1];  % Constraint matrix
QPproblem.b = [5, 0]';
QPproblem.lb = [0, 0]';
QPproblem.ub = [inf, inf]';
QPproblem.x0 = [0, 1]';  % starting point
QPproblem.osense = 1;
QPproblem.csense = ['L'; 'E'];

 solverOK = changeCobraSolver('dqqMinos', 'QP');

 assert(solverOK==1)

 sol = solveCobraQP(QPproblem);


% output a success message
fprintf('Done.\n');

% change the directory
cd(currentDir)