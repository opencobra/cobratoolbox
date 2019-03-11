% The COBRAToolbox: testPartition.m
%
% Purpose:
%     - tests the basic functionality of swiftcc++ algorithm
%
% Authors:
%     - Original file: Mojtaba Tefagh, March 2019
%

global CBTDIR

% require the specified toolboxes and solvers
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi'}, ...
    'requiredToolboxes', {'bioinformatics_toolbox'});

% save the current path
currentDir = pwd;

% initialize the test
testPass = fileparts(which('testPartition.m'));
cd(testPass);

% load the model
model = getDistributedModel('ecoli_core_model.mat');
model.rev = double(model.lb < 0);
A = fastcc(model, 1e-4, 0);

% set the cobra solver
solverLPOK = changeCobraSolver(solvers.LP{1}, 'LP', 0);

fprintf('\n -- Running swiftcc++ using the %s solver...\n\n', solvers.LP{1});
component = partition(model, solvers.LP{1}, 'swift');
assert(all(component(A)));
assert(length(A) == sum(component));

% output a success message
fprintf('\nDone.\n');

% change the directory
cd(currentDir)