% The COBRAToolbox: testOptArrowEcoliCoreHttpFBA.m
%
% Purpose:
%     - End-to-end FBA test on ecoli_core via a remote OptArrow Gateway.
%       Identical to testOptArrowEcoliCoreFBA but explicitly uses a
%       remote endpoint to verify multi-machine deployment.
%
% Requirements:
%     - MATLAB R2023b or later.
%     - OptArrow Gateway running (locally or on a remote host).
%
% Note:
%     - Set COBRA_OPTARROW_ENDPOINT to specify the Gateway URL.
%       If not set, defaults to http://127.0.0.1:8000/cobra/compute.
%
% Author:
%     - Farid Zare 12/04/2026

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testOptArrowEcoliCoreHttpFBA'));
cd(fileDir);

% Resolve endpoint
endpoint = getenv('COBRA_OPTARROW_ENDPOINT');
if isempty(endpoint)
    endpoint = 'http://127.0.0.1:8000/cobra/compute';
end

fprintf('   Testing OptArrow FBA on ecoli_core (endpoint: %s)...\n', endpoint);

% Verify Gateway is reachable
checkOptArrowSetup(endpoint, struct('throwOnError', true));

% Configure OptArrow as the active LP solver
changeCobraOptArrowSolver('HiGHS', 'LP', ...
    'endpoint',    endpoint, ...
    'timeoutSec',  120, ...
    'verbosity',   0);

model    = getDistributedModel('ecoli_core_model.mat');
solution = optimizeCbModel(model, 'max', 0, true);

tol = 1e-6;

assert(solution.stat == 1, ...
    'OptArrow FBA: expected optimal solution (stat=1).');
assert(abs(solution.f - 0.873921506968427) < tol, ...
    sprintf('OptArrow FBA: unexpected biomass flux %.10f.', solution.f));
assert(norm(model.S * solution.v - model.b, inf) < 1e-7, ...
    'OptArrow FBA: flux vector violates steady-state constraints.');

fprintf('   OptArrow FBA on ecoli_core: PASSED (f=%.8f).\n', solution.f);

% restore the path
cd(currentDir);
