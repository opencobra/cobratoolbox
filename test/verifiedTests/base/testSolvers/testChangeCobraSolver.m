% The COBRAToolbox: testChangeCobraSolver.m
%
% Purpose:
%     - testChangeCobraSolver tests the changeCobraSolver function


% define global paths
global SOLVERS;
global OPT_PROB_TYPES;

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testChangeCobraSolver'));
cd(fileDir);

% Three arguments
ok = changeCobraSolver('pdco', 'MINLP', 0);
assert(~ok);

%This is surely present on all os. 
ok = changeCobraSolver('pdco', 'QP', 0); 
assert(ok);
global CBT_QP_SOLVER
assert(strcmp(CBT_QP_SOLVER, 'pdco'))

global CBT_MINLP_SOLVER
CBT_MINLP_SOLVER = [];
ok = changeCobraSolver('pdco', 'MINLP', 0);
assert(~ok);
assert(isempty(CBT_MINLP_SOLVER))

ok = changeCobraSolver('gurobi_mex', 'MILP', 1);
assert(~ok)

% Two arguments
assert(verifyCobraFunctionError(@() changeCobraSolver('pdco', 'MINLP')));

assert(verifyCobraFunctionError(@() changeCobraSolver('pdco', 'MILP')));

assert(verifyCobraFunctionError(@() changeCobraSolver('mysolver', 'MILP')));

for i = 1:length(OPT_PROB_TYPES)
    varName = horzcat(['CBT_', OPT_PROB_TYPES{i}, '_SOLVER']);
    eval(['global ' varName])
    eval(['clear ' varName]);
end
changeCobraSolver('gurobi', 'all', 0)
for i = 1:length(SOLVERS.pdco.type)
    varName = horzcat(['CBT_', SOLVERS.gurobi.type{i}, '_SOLVER']);
    eval(['global ' varName])
    assert(strcmp(eval(varName), 'gurobi'))
end

% One argument, works with a known solver.
ok = changeCobraSolver('matlab');
assert(ok)

%But not with a Problem Type.
assert(verifyCobraFunctionError(@() changeCobraSolver('LP')))


% legacy MPS support
assert(verifyCobraFunctionError(@() changeCobraSolver('mps')));

% Zero argument
changeCobraSolver();
