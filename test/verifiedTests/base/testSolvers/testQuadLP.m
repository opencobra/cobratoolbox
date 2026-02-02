%test quad precision solver

global CBTDIR

%Test the requirements
%useSolversIfAvailable = {'gurobi','quadMinos', 'dqqMinos',};
%useSolversIfAvailable = {'gurobi','quadMinos'};
useSolversIfAvailable = {'mosek','quadMinos'};
useSolversIfAvailable = {'quadMinos'};
excludeSolvers={'pdco'};
       
solvers = prepareTest('needsLP',true,'useSolversIfAvailable',useSolversIfAvailable,'excludeSolvers',excludeSolvers);


solverOK = changeCobraSolver('quadMinos', 'LP')

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