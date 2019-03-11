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

fprintf('\n -- Running QFCA w/o reduction and using the default linprog solver...\n\n');
[~, fctableD, blockedD] = QFCA(model, false);
assert(all(blockedD == blocked));
assert(all(fctableD == fctable, 'all'));
fprintf('\n -- Running QFCA w/ reduction and using the default linprog solver...\n\n');
[~, fctableR, blockedR] = QFCA(model, true);
assert(all(blockedR == blocked));
assert(all(fctableR == fctable, 'all'));
fprintf('\n -- Running QFCA w/o reduction and using the %s solver...\n\n', solvers.LP{1});
[~, fctableG, blockedG] = QFCA(model, false, solvers.LP{1});
assert(all(blockedG == blocked));
assert(all(fctableG == fctable, 'all'));
fprintf('\n -- Running QFCA w/ reduction and using the %s solver...\n\n', solvers.LP{1});
[~, fctableRG, blockedRG] = QFCA(model, true, solvers.LP{1});
assert(all(blockedRG == blocked));
assert(all(fctableRG == fctable, 'all'));

% output a success message
fprintf('\nDone.\n');

% change the directory
cd(currentDir)