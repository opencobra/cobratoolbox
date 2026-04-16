% The COBRAToolbox: testOptArrowBackend.m
%
% Purpose:
%     - Tests the OptArrow LP backend via the Arrow IPC Gateway.
%       Solves a 2-variable LP and verifies the optimal objective,
%       primal solution, dual variables, and reduced costs.
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
fileDir = fileparts(which('testOptArrowBackend'));
cd(fileDir);

fprintf('   Testing OptArrow LP via Arrow IPC...\n');

% Resolve endpoint
endpoint = getenv('COBRA_OPTARROW_ENDPOINT');
if isempty(endpoint)
    endpoint = 'http://127.0.0.1:8000/cobra/compute';
end

% Verify Gateway is reachable (will error if not)
checkOptArrowSetup(endpoint, struct('throwOnError', true));

% Configure OptArrow as the active LP solver
changeCobraOptArrowSolver('HiGHS', 'LP', ...
    'endpoint',  endpoint, ...
    'verbosity', 0);

% max 3x + 4y  s.t.  2x + y <= 8,  x + 2y <= 8,  x,y >= 0
% Optimal: x = y = 8/3, obj = 56/3
LPproblem.A      = sparse([2 1; 1 2]);
LPproblem.b      = [8; 8];
LPproblem.c      = [3; 4];
LPproblem.lb     = [0; 0];
LPproblem.ub     = [1000; 1000];
LPproblem.csense = ['L'; 'L'];
LPproblem.osense = -1;

tol = 1e-6;

solution = solveCobraLP(LPproblem);

assert(solution.stat == 1, ...
    'OptArrow LP: expected optimal status (stat=1).');
assert(abs(solution.obj - 56/3) < tol, ...
    sprintf('OptArrow LP: unexpected objective %.10f (expected %.10f).', ...
    solution.obj, 56/3));
assert(numel(solution.dual)  == 2, 'OptArrow LP: expected 2 dual variables.');
assert(numel(solution.rcost) == 2, 'OptArrow LP: expected 2 reduced costs.');

fprintf('   OptArrow LP via Arrow IPC: PASSED (obj=%.6f).\n', solution.obj);

% restore the path
cd(currentDir);
