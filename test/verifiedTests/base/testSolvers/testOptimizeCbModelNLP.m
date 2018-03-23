% The COBRAToolbox: testOptimizeCbModelNLP.m
%
% Purpose:
%     - tests the optimizeCbModelNLP function, and some of its parameters.
%
% Authors:
%     - Thomas Pfau, March 2017
%

global CBTDIR

%Test Requirements
requiredSolvers = {'matlab','glpk'};
testRequirementsAndGetSolvers('ReqSolvers',requiredSolvers);


% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testOptimizeCbModelNLP'));
cd(fileDir);

% set the LP cobra solver - used in optimizeCbModelNLP that calls optimizeCbModel
changeCobraSolver('glpk', 'LP');

% set the NLP cobra the solver
solverOk = changeCobraSolver('matlab', 'NLP');

% set the tolerance
tol = 1e-6;

% load the model
model = getDistributedModel('ecoli_core_model.mat');

toymodel = createToyModel(0, 0, 0); % create a toy model
toymodel.ub(1) = -1; % force uptake, otherwise the default Objective will try to minimize all fluxes...

% optimize
sol = optimizeCbModelNLP(toymodel, 'nOpt', 10);

% the optimal sol has the minimal uptake and a maximal flux distribution.
optsol = [-1; 0.5; 0.5; 0.5; 0.5; 0.5];

assert(abs(sum(sol.x - optsol)) < tol)

% test a different objective function
model.ub(28) = 0;

% maximize the glucose flux...
objArg = {ismember(model.rxns,model.rxns(28))};
model.c(:) = 0;
sol2 = optimizeCbModelNLP(model, 'objFunction', 'SimpleQPObjective', 'objArgs', objArg, 'nOpt', 5);

assert(abs(sol2.f-100) < tol);

% change the directory
cd(currentDir)
