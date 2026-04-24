function testOptArrowBackend()
% testOptArrowBackend Minimal MATLAB smoke test for the COBRA OptArrow LP backend.
%
% USAGE:
%
%    testOptArrowBackend()

repoRoot = fileparts(fileparts(fileparts(fileparts(fileparts(mfilename('fullpath'))))));
addpath(genpath(repoRoot));

pythonExe = fullfile(repoRoot, '.venv_optarrow_poc', 'bin', 'python');
if ~exist(pythonExe, 'file')
    error('Expected proof virtualenv Python at %s', pythonExe);
end

LPproblem = struct();
LPproblem.A = sparse([2 1; 1 2]);
LPproblem.b = [8; 8];
LPproblem.c = [3; 4];
LPproblem.lb = [0; 0];
LPproblem.ub = [1000; 1000];
LPproblem.csense = ['L'; 'L'];
LPproblem.osense = -1;

solution = solveCobraLP(LPproblem, ...
    'solver', 'optarrow', ...
    'pythonExecutable', pythonExe);

disp('Objective:')
disp(solution.obj)
disp('Primal:')
disp(solution.full')
disp('Dual:')
disp(solution.dual')
disp('Reduced costs:')
disp(solution.rcost')

assert(solution.stat == 1, 'Expected optimal status.')
assert(abs(solution.obj - 56 / 3) < 1e-8, 'Unexpected objective value.')
end
