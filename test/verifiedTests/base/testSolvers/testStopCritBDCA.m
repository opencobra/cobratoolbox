% The COBRAToolbox: testStopCritBDCA.m
%
% Purpose:
%     - StopCritBDCA decides whether the BDCA kinetic solver should stop and returns a status text, for stopping criteria 2 to 5.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/solvers/varKin/BDCAmethods/StopCritBDCA.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Lines 34-36, 38 and 39 of StopCritBDCA.m (inside "case 1" of the switch) are uncovered because of the defect below; the line that evaluates the undefined variable is reached only by an erroring call, which is not tested.
%
% Known defects documented (NOT tested, NOT fixed here):
%     Stopping criterion 1 refers to the undefined variable nhxk (it should probably be nfxk), so calling the function with criterion 1 errors (MATLAB:UndefinedFunction). That criterion is skipped here (documented, not tested, not fixed). A criterion outside 1..5 leaves the outputs unassigned; also not tested.
%
% Authors:
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testStopCritBDCA'));
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

%% criterion 2: maximum number of iterations

[stopFlag, status] = StopCritBDCA(1, 100, 10, 1, maxNumIter, maxNumMapEval, timeLimit, epsilon, 2);
assert(stopFlag == 1 && strcmp(status, 'Maximum number of iterations is reached.'));
[stopFlag, status] = StopCritBDCA(1, 99, 10, 1, maxNumIter, maxNumMapEval, timeLimit, epsilon, 2);
assert(stopFlag == 0 && isempty(status));

%% criterion 3: maximum number of mapping evaluations

[stopFlag, status] = StopCritBDCA(1, 10, 200, 1, maxNumIter, maxNumMapEval, timeLimit, epsilon, 3);
assert(stopFlag == 1 && strcmp(status, 'Maximum number of mapping evaluations is reached.'));
[stopFlag, status] = StopCritBDCA(1, 10, 199, 1, maxNumIter, maxNumMapEval, timeLimit, epsilon, 3);
assert(stopFlag == 0 && isempty(status));

%% criterion 4: time limit

[stopFlag, status] = StopCritBDCA(1, 10, 10, 60, maxNumIter, maxNumMapEval, timeLimit, epsilon, 4);
assert(stopFlag == 1 && strcmp(status, 'Time limit is reached.'));
[stopFlag, status] = StopCritBDCA(1, 10, 10, 59, maxNumIter, maxNumMapEval, timeLimit, epsilon, 4);
assert(stopFlag == 0 && isempty(status));

%% criterion 5: solution found (residual <= epsilon) or maximum number of iterations

% residual small enough and iterations left -> solution found
[stopFlag, status] = StopCritBDCA(1e-3, 10, 10, 1, maxNumIter, maxNumMapEval, timeLimit, epsilon, 5);
assert(stopFlag == 1 && strcmp(status, 'a solution is found'));
% iterations used up -> maximum number of iterations
[stopFlag, status] = StopCritBDCA(1, 100, 10, 1, maxNumIter, maxNumMapEval, timeLimit, epsilon, 5);
assert(stopFlag == 1 && strcmp(status, 'Maximum number of iterations is reached.'));
% neither -> continue
[stopFlag, status] = StopCritBDCA(1, 10, 10, 1, maxNumIter, maxNumMapEval, timeLimit, epsilon, 5);
assert(stopFlag == 0 && isempty(status));

% change the directory
cd(currentDir)
