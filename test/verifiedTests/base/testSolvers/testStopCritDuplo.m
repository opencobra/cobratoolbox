% The COBRAToolbox: testStopCritDuplo.m
%
% Purpose:
%     - StopCritDuplo decides whether the Duplo kinetic solver should stop and returns a status text, for stopping criteria 1 to 5.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%       Defect(s) fixed by feature 20261102-140321-tier1-safe-defect-fixes: Stopping criterion
%       1 uses an undefined variable; Outputs unassigned for a criterion outside 1 to 5.
%
% Function under test:
%     src/base/solvers/varKin/derFreeMethods/StopCritDuplo.m
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
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.
%     - Updated for feature 20261102-140321-tier1-safe-defect-fixes, 2026-11-02.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testStopCritDuplo'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% inputs: nfxk (residual norm), Niter, Nmap, T (elapsed time), the limits MaxNumIter,
% MaxNumMapEval, TimeLimit, the tolerance epsilon and the stopping criterion number
epsilon = 1e-3;
maxNumIter = 100;
maxNumMapEval = 200;
timeLimit = 60;

%% criterion 1: the residual nfxk compared with epsilon

[stopFlag, status] = StopCritDuplo(1e-3, 10, 10, 1, maxNumIter, maxNumMapEval, timeLimit, epsilon, 1);
assert(stopFlag == 1 && strcmp(status, 'A solution of nonlinear system is found.'));
[stopFlag, status] = StopCritDuplo(2e-3, 10, 10, 1, maxNumIter, maxNumMapEval, timeLimit, epsilon, 1);
assert(stopFlag == 0 && isempty(status));

%% criterion 2: maximum number of iterations

[stopFlag, status] = StopCritDuplo(1, 100, 10, 1, maxNumIter, maxNumMapEval, timeLimit, epsilon, 2);
assert(stopFlag == 1 && strcmp(status, 'Maximum number of iterations is reached.'));
[stopFlag, status] = StopCritDuplo(1, 99, 10, 1, maxNumIter, maxNumMapEval, timeLimit, epsilon, 2);
assert(stopFlag == 0 && isempty(status));

%% criterion 3: maximum number of mapping evaluations

[stopFlag, status] = StopCritDuplo(1, 10, 200, 1, maxNumIter, maxNumMapEval, timeLimit, epsilon, 3);
assert(stopFlag == 1 && strcmp(status, 'Maximum number of mapping evaluations is reached.'));
[stopFlag, status] = StopCritDuplo(1, 10, 199, 1, maxNumIter, maxNumMapEval, timeLimit, epsilon, 3);
assert(stopFlag == 0 && isempty(status));

%% criterion 4: time limit

[stopFlag, status] = StopCritDuplo(1, 10, 10, 60, maxNumIter, maxNumMapEval, timeLimit, epsilon, 4);
assert(stopFlag == 1 && strcmp(status, 'Time limit is reached.'));
[stopFlag, status] = StopCritDuplo(1, 10, 10, 59, maxNumIter, maxNumMapEval, timeLimit, epsilon, 4);
assert(stopFlag == 0 && isempty(status));

%% criterion 5: solution found (residual <= epsilon) or maximum number of iterations

% residual small enough and iterations left -> solution found
[stopFlag, status] = StopCritDuplo(1e-3, 10, 10, 1, maxNumIter, maxNumMapEval, timeLimit, epsilon, 5);
assert(stopFlag == 1 && strcmp(status, 'a solution is found.'));
% iterations used up -> maximum number of iterations
[stopFlag, status] = StopCritDuplo(1, 100, 10, 1, maxNumIter, maxNumMapEval, timeLimit, epsilon, 5);
assert(stopFlag == 1 && strcmp(status, 'Maximum number of iterations is reached.'));
% neither -> continue
[stopFlag, status] = StopCritDuplo(1, 10, 10, 1, maxNumIter, maxNumMapEval, timeLimit, epsilon, 5);
assert(stopFlag == 0 && isempty(status));

%% a criterion outside 1 to 5 raises an error

for badCriterion = [0, 6]
    assert(verifyCobraFunctionError('StopCritDuplo', 'inputs', ...
        {1, 10, 10, 1, maxNumIter, maxNumMapEval, timeLimit, epsilon, badCriterion}, ...
        'testMessage', 'Stopping_Crit must be 1, 2, 3, 4 or 5.'));
end

% change the directory
cd(currentDir)
