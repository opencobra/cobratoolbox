%test quad precision solver

global CBTDIR

%Test the requirements
%useSolversIfAvailable = {'gurobi','quadMinos', 'dqqMinos',};
%useSolversIfAvailable = {'gurobi','quadMinos'};
useSolversIfAvailable = {'mosek','quadMinos','dqqMinos'};
%useSolversIfAvailable = {'quadMinos'};
excludeSolvers={'pdco'};
       
solvers = prepareTest('needsLP',true,'useSolversIfAvailable',useSolversIfAvailable,'excludeSolvers',excludeSolvers);


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

 sol = solveCobraQP(QPproblem)

