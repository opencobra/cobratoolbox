function testOptArrowEcoliCoreHttpFBA(endpoint)
% testOptArrowEcoliCoreHttpFBA End-to-end COBRA FBA test on ecoli_core via OptArrow HTTP.
%
% USAGE:
%
%    testOptArrowEcoliCoreHttpFBA()
%    testOptArrowEcoliCoreHttpFBA(endpoint)

if nargin < 1 || isempty(endpoint)
    endpoint = 'http://127.0.0.1:8000/compute';
end

repoRoot = fileparts(fileparts(fileparts(fileparts(fileparts(mfilename('fullpath'))))));
addpath(genpath(repoRoot));

pythonExe = fullfile(repoRoot, '.venv_optarrow_poc', 'bin', 'python');
if ~exist(pythonExe, 'file')
    error('Expected OptArrow HTTP Python executable not found: %s', pythonExe);
end

model = getDistributedModel('ecoli_core_model.mat');

solverOK = changeCobraSolver('optarrow', 'LP', 0, -1);
assert(isnan(solverOK), 'Expected changeCobraSolver(..., -1) to skip validation for optarrow.');

param = struct();
param.endpoint = endpoint;
param.timeoutSec = 120;
param.pythonExecutable = pythonExe;
param.optArrowMatlabRoot = fullfile(fileparts(repoRoot), 'optArrow_mat', 'src', 'matlab');
param.printLevel = 1;

solution = optimizeCbModel(model, 'max', 0, true, param);

disp('OptArrow ecoli_core HTTP FBA result:')
disp(struct( ...
    'solver', solution.solver, ...
    'stat', solution.stat, ...
    'origStat', solution.origStat, ...
    'f', solution.f, ...
    'biomassFlux', solution.v(find(model.c, 1, 'first'))))

assert(solution.stat == 1, 'Expected an optimal FBA solution.');
assert(abs(solution.f - 0.873921506968427) < 1e-6, ...
    'Unexpected ecoli_core biomass objective from OptArrow HTTP backend.');
assert(norm(model.S * solution.v - model.b, inf) < 1e-7, ...
    'Returned flux vector violates steady-state constraints.');
end
