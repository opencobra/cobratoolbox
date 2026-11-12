% The COBRAToolbox: testReformulate.m
%
% Purpose:
%     - reformulate replaces the reactions with large stoichiometric coefficients and the badly
%       scaled coupling constraints of an LP by sequences of well scaled rows, adding one dummy
%       variable per step. The test checks the reformulated matrix and that the dummy variables
%       reproduce the original rows.
%
% Function under test:
%     src/base/solvers/rescale/reformulate.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Line 109: unreachable, the branch of an if 0.
%     Line 196: unreachable, the branch of an if 0.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testReformulate'));
cd(fileDir);

% declare the requirements: this test needs no solver, toolbox or operating system
prepareTest();

% exact comparison up to rounding of nthroot and of the divisions by the step
tol = 1e-9;

BIG = 1024;
printLevel = 1;

%% a reaction with a large coefficient in a stoichiometric row
LPproblem.A = [ -1;-10000;1;1];
LPproblem.b = zeros(4,1);
LPproblem.c = 0;
LPproblem.lb = -inf;
LPproblem.ub =  inf;
LPproblem.csense = 'E';

LPproblem_lifted = reformulate(LPproblem, BIG, printLevel);

% the large entry is replaced by the step 100 = sqrt(10000), and a new row defines the dummy
% variable as 100 times the original variable, so that -100 * dummy = -10000 * x
expectedA = [-1, 0; 0, -100; 1, 0; 1, 0; -100, 1];
assert(all(all(abs(full(LPproblem_lifted.A) - expectedA) < tol)));
assert(isequal(LPproblem_lifted.modelID, 'L_aModel'));
assert(isequal(size(LPproblem_lifted.lb), [2, 1]) && isequal(size(LPproblem_lifted.c), [2, 1]));

%% a badly scaled coupling constraint
LPproblem.A = [ 1,  -10000];
LPproblem.b = 0;
LPproblem.c = [0;0];
LPproblem.lb = -inf(2,1);
LPproblem.ub =  inf(2,1);
LPproblem.csense = 'L';

LPproblem_lifted = reformulate(LPproblem, BIG, printLevel);

% one dummy variable of step 100 splits the coefficient -10000 into two rows
expectedA = [1, 0, -100; 0, -100, 1];
assert(all(all(abs(full(LPproblem_lifted.A) - expectedA) < tol)));
assert(numel(LPproblem_lifted.b) == 2 && numel(LPproblem_lifted.csense) == 2);

%% a model identifier given in the problem is kept with the prefix L_
LPproblem.modelID = 'myModel';
LPproblem_lifted = reformulate(LPproblem, BIG, 0);
assert(isequal(LPproblem_lifted.modelID, 'L_myModel'));

% change the directory back
cd(currentDir);
