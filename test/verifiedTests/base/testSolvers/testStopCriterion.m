% The COBRAToolbox: testStopCriterion.m
%
% Purpose:
%     - StopCriterion decides whether the kinetic-modelling solver should stop for one of nine
%     stopping criteria (gradient, residual, iteration, evaluation and time limits, and relative
%     versions) and returns a status text.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/solvers/varKin/levMarMethods/StopCriterion.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testStopCriterion'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% base values that satisfy none of the criteria
grad = [1; 0];            % norm 1
nhxk = 1;                 % residual norm
MaxNumIter = 10; MaxNumMapEval = 10; MaxNumGmapEval = 10; TimeLimit = 100;
epsilon = 1e-3; nhx0 = 100; ngradx0 = 100;

%% criterion 1: gradient norm below the accuracy

[flag, status] = StopCriterion(1e-4 * [1; 0], nhxk, 0, 0, 0, MaxNumIter, MaxNumMapEval, MaxNumGmapEval, 0, TimeLimit, epsilon, nhx0, ngradx0, 1);
assert(flag == 1 && strcmp(status, 'Local (global) solution of merit function is found.'));
[flag, status] = StopCriterion(grad, nhxk, 0, 0, 0, MaxNumIter, MaxNumMapEval, MaxNumGmapEval, 0, TimeLimit, epsilon, nhx0, ngradx0, 1);
assert(flag == 0 && isempty(status));

%% criterion 2: residual norm below the accuracy

[flag, status] = StopCriterion(grad, 1e-4, 0, 0, 0, MaxNumIter, MaxNumMapEval, MaxNumGmapEval, 0, TimeLimit, epsilon, nhx0, ngradx0, 2);
assert(flag == 1 && strcmp(status, 'A solution of nonlinear system is found.'));
[flag, status] = StopCriterion(grad, nhxk, 0, 0, 0, MaxNumIter, MaxNumMapEval, MaxNumGmapEval, 0, TimeLimit, epsilon, nhx0, ngradx0, 2);
assert(flag == 0 && isempty(status));

%% criterion 3: maximum number of iterations

[flag, status] = StopCriterion(grad, nhxk, 10, 0, 0, MaxNumIter, MaxNumMapEval, MaxNumGmapEval, 0, TimeLimit, epsilon, nhx0, ngradx0, 3);
assert(flag == 1 && strcmp(status, 'Maximum number of iterations is reached.'));
[flag, ~] = StopCriterion(grad, nhxk, 9, 0, 0, MaxNumIter, MaxNumMapEval, MaxNumGmapEval, 0, TimeLimit, epsilon, nhx0, ngradx0, 3);
assert(flag == 0);

%% criterion 4: maximum number of mapping evaluations

[flag, status] = StopCriterion(grad, nhxk, 0, 10, 0, MaxNumIter, MaxNumMapEval, MaxNumGmapEval, 0, TimeLimit, epsilon, nhx0, ngradx0, 4);
assert(flag == 1 && strcmp(status, 'Maximum number of mapping evaluations is reached.'));
[flag, ~] = StopCriterion(grad, nhxk, 0, 9, 0, MaxNumIter, MaxNumMapEval, MaxNumGmapEval, 0, TimeLimit, epsilon, nhx0, ngradx0, 4);
assert(flag == 0);

%% criterion 5: maximum number of gradient evaluations

[flag, status] = StopCriterion(grad, nhxk, 0, 0, 10, MaxNumIter, MaxNumMapEval, MaxNumGmapEval, 0, TimeLimit, epsilon, nhx0, ngradx0, 5);
assert(flag == 1 && strcmp(status, 'Maximum number of gradient evaluations is reached.'));
[flag, ~] = StopCriterion(grad, nhxk, 0, 0, 9, MaxNumIter, MaxNumMapEval, MaxNumGmapEval, 0, TimeLimit, epsilon, nhx0, ngradx0, 5);
assert(flag == 0);

%% criterion 6: time limit

[flag, status] = StopCriterion(grad, nhxk, 0, 0, 0, MaxNumIter, MaxNumMapEval, MaxNumGmapEval, 100, TimeLimit, epsilon, nhx0, ngradx0, 6);
assert(flag == 1 && strcmp(status, 'Time limit is reached.'));
[flag, ~] = StopCriterion(grad, nhxk, 0, 0, 0, MaxNumIter, MaxNumMapEval, MaxNumGmapEval, 99, TimeLimit, epsilon, nhx0, ngradx0, 6);
assert(flag == 0);

%% criterion 7: gradient norm below the relative accuracy

% epsilon^2 * ngradx0 = 1e-4, so the threshold is max(1e-3, 1e-4) = 1e-3
[flag, status] = StopCriterion(1e-4 * [1; 0], nhxk, 0, 0, 0, MaxNumIter, MaxNumMapEval, MaxNumGmapEval, 0, TimeLimit, epsilon, nhx0, ngradx0, 7);
assert(flag == 1 && strcmp(status, 'A possible stationary point is found.'));
[flag, ~] = StopCriterion(grad, nhxk, 0, 0, 0, MaxNumIter, MaxNumMapEval, MaxNumGmapEval, 0, TimeLimit, epsilon, nhx0, ngradx0, 7);
assert(flag == 0);

%% criterion 8: residual norm below the relative accuracy

[flag, status] = StopCriterion(grad, 1e-4, 0, 0, 0, MaxNumIter, MaxNumMapEval, MaxNumGmapEval, 0, TimeLimit, epsilon, nhx0, ngradx0, 8);
assert(flag == 1 && strcmp(status, 'A possible solution is found.'));
[flag, ~] = StopCriterion(grad, nhxk, 0, 0, 0, MaxNumIter, MaxNumMapEval, MaxNumGmapEval, 0, TimeLimit, epsilon, nhx0, ngradx0, 8);
assert(flag == 0);

%% criterion 9: solution found or maximum number of iterations

[flag, status] = StopCriterion(grad, 1e-4, 0, 0, 0, MaxNumIter, MaxNumMapEval, MaxNumGmapEval, 0, TimeLimit, epsilon, nhx0, ngradx0, 9);
assert(flag == 1 && strcmp(status, 'a solution is found.'));
[flag, status] = StopCriterion(grad, nhxk, 10, 0, 0, MaxNumIter, MaxNumMapEval, MaxNumGmapEval, 0, TimeLimit, epsilon, nhx0, ngradx0, 9);
assert(flag == 1 && strcmp(status, 'Maximum number of iterations is reached.'));
[flag, status] = StopCriterion(grad, nhxk, 0, 0, 0, MaxNumIter, MaxNumMapEval, MaxNumGmapEval, 0, TimeLimit, epsilon, nhx0, ngradx0, 9);
assert(flag == 0 && isempty(status));

% change the directory
cd(currentDir)
