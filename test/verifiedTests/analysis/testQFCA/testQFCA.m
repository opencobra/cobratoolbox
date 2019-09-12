% The COBRAToolbox: testQFCA.m
%
% Purpose:
%     - tests the basic functionality of QFCA algorithm
%
% Authors:
%     - Original file: Mojtaba Tefagh, March 2019
%

global CBTDIR

% require the specified toolboxes and solvers
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi'});

% save the current path
currentDir = pwd;

% initialize the test
testPass = fileparts(which('testQFCA.m'));
cd(testPass);
load('fctable.mat');
load('blocked.mat');

% load the model
model = getDistributedModel('ecoli_core_model.mat');
model.rev = model.lb < 0;

% set the cobra solver
solverLPOK = changeCobraSolver(solvers.LP{1}, 'LP', 0);

fprintf('\n -- Running QFCA w/o reduction and using the %s solver...\n\n', solvers.LP{1});
[~, fctableD, blockedD] = QFCA(model, false, solvers.LP{1});
assert(all(blockedD == blocked));
assert(all(fctableD(:) == fctable(:)));
fprintf('\n -- Running QFCA w/ reduction and using the %s solver...\n\n', solvers.LP{1});
[~, fctableR, blockedR] = QFCA(model, true, solvers.LP{1});
assert(all(blockedR == blocked));
assert(all(fctableR(:) == fctable(:)));

% output a success message
fprintf('\nDone.\n');

% change the directory
cd(currentDir)