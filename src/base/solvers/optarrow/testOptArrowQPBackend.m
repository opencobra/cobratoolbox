% The COBRAToolbox: testOptArrowQPBackend.m
%
% Purpose:
%     - Tests the OptArrow QP backend via the Arrow IPC Gateway.
%       Solves a 2-variable QP and verifies the optimal primal solution.
%
% Requirements:
%     - MATLAB R2023b or later (native Arrow list-array support).
%     - OptArrow Gateway running (locally or remotely).
%       Start locally: python src/run_server.py  (from optArrow_mat)
%
% Note:
%     - Set COBRA_OPTARROW_ENDPOINT to override the default
%       Gateway URL (http://127.0.0.1:8000/cobra/compute).
%
% Author:
%     - Farid Zare 12/04/2026

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testOptArrowQPBackend'));
cd(fileDir);

fprintf('   Testing OptArrow QP via Arrow IPC...\n');

% Resolve endpoint
endpoint = getenv('COBRA_OPTARROW_ENDPOINT');
if isempty(endpoint)
    endpoint = 'http://127.0.0.1:8000/cobra/compute';
end

% Verify Gateway is reachable
checkOptArrowSetup(endpoint, struct('throwOnError', true));

% Configure OptArrow as the active QP solver
changeCobraOptArrowSolver('HiGHS', 'QP', ...
    'endpoint',  endpoint, ...
    'verbosity', 0);

% min  x^2 + y^2 - 2x - 5y   (F = [2 0; 0 2], c = [-2; -5])
% s.t. x + y = 3,  x,y >= 0
% Optimal: x = 0.75, y = 2.25
QPproblem.F      = sparse([2 0; 0 2]);
QPproblem.c      = [-2; -5];
QPproblem.A      = sparse([1 1]);
QPproblem.b      = 3;
QPproblem.lb     = [0; 0];
QPproblem.ub     = [1000; 1000];
QPproblem.csense = 'E';
QPproblem.osense = 1;

tol = 1e-4;

solution = solveCobraQP(QPproblem);

assert(solution.stat == 1, ...
    'OptArrow QP: expected optimal status (stat=1).');
assert(norm(solution.full - [0.75; 2.25], inf) < tol, ...
    sprintf('OptArrow QP: unexpected primal [%.6f, %.6f].', ...
    solution.full(1), solution.full(2)));

fprintf('   OptArrow QP via Arrow IPC: PASSED (x=[%.4f, %.4f]).\n', ...
    solution.full(1), solution.full(2));

% restore the path
cd(currentDir);
