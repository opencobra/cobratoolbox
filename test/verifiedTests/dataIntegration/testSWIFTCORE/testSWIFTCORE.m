% The COBRAToolbox: testSWIFTCORE.m
%
% Purpose:
%     - tests the basic functionality of swiftcore algorithm
%
% Authors:
%     - Original file: Mojtaba Tefagh, March 2019
%

global CBTDIR

% require the specified toolboxes and solvers
solvers = prepareTest('needsLP', true, 'requireOneSolverOf', {'gurobi','ibm_cplex'},'excludeSolvers', {'matlab', 'lp_solve','pdco'});


% save the current path
currentDir = pwd;

% initialize the test
testPass = fileparts(which('testSWIFTCORE.m'));
cd(testPass);

% load the model
model = getDistributedModel('ecoli_core_model.mat');
model.rev = double(model.lb < 0);
A = swiftcc(model.S, model.rev);
model.S = model.S(:, A);
model.rev = model.rev(A);
model.ub = model.ub(A);
model.lb = model.lb(A);
model.rxns = model.rxns(A);
n = length(model.rev);
core = randsample(n, round(n/2));

% set the cobra solver
solverLPOK = changeCobraSolver(solvers.LP{1}, 'LP', 0);

fprintf(' -- Running swiftcore w/o reduction and using the %s solver...\n', solvers.LP{1});
[~, coreInd, ~] = swiftcore(model, core, ones(n, 1), 1e-10, false, solvers.LP{1});
assert(all(coreInd(core)));
A = swiftcc(model.S(:, coreInd), model.rev(coreInd));
assert(all(A.' == 1:length(A)));
fprintf(' -- Running swiftcore w/ reduction and using the %s solver...\n', solvers.LP{1});
[~, coreInd, ~] = swiftcore(model, core, ones(n, 1), 1e-10, true, solvers.LP{1});
assert(all(coreInd(core)));
A = swiftcc(model.S(:, coreInd), model.rev(coreInd));
assert(all(A.' == 1:length(A)));

% output a success message
fprintf('\nDone.\n');

% load the model
model = getDistributedModel('ecoli_core_model.mat');
model.rev = double(model.lb < 0);
A = fastcc(model, 1e-4, 0);

fprintf('\n -- Running swiftcc using the %s solver...\n', solvers.LP{1});
consistent = swiftcc(model.S, model.rev, solvers.LP{1});
assert(all(A == consistent));

[solverName, solverOK] = getCobraSolver('LP');
fprintf('\n -- Running swiftcc using the default linprog, which is %s,....\n', solverName);
consistent = swiftcc(model.S, model.rev);
assert(all(A == consistent));

% output a success message
fprintf('\nDone.\n');

% change the directory
cd(currentDir)