function testOptArrowQPBackend()
% testOptArrowQPBackend Minimal MATLAB smoke test for the COBRA OptArrow QP backend.
%
% USAGE:
%
%    testOptArrowQPBackend()

repoRoot = fileparts(fileparts(fileparts(fileparts(fileparts(mfilename('fullpath'))))));
addpath(genpath(repoRoot));
pythonExe = fullfile(repoRoot, '.venv_optarrow_poc', 'bin', 'python');

if ~exist(pythonExe, 'file')
    error('Expected proof Python executable not found: %s', pythonExe);
end

QPproblem = struct();
QPproblem.F = sparse([2 0; 0 2]);
QPproblem.c = [-2; -5];
QPproblem.A = sparse([1 1]);
QPproblem.b = 3;
QPproblem.lb = [0; 0];
QPproblem.ub = [1000; 1000];
QPproblem.csense = 'E';
QPproblem.osense = 1;

solution = solveCobraQP(QPproblem, ...
    'solver', 'optarrow', ...
    'pythonExecutable', pythonExe);

disp(solution);

assert(solution.stat == 1, 'Expected an optimal QP solve.');
assert(norm(solution.full - [0.75; 2.25], inf) < 1e-5, ...
    'Unexpected primal solution from OptArrow QP backend.');
end
