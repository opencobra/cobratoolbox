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
fprintf(' -- Running testChangeCobraSolver: ... \n');
fileDir = fileparts(which('testChangeCobraSolver'));
cd(fileDir);

% Three arguments
if any(ismember('MINLP',OPT_PROB_TYPES))
    ok = changeCobraSolver('pdco', 'MINLP', 0);
    assert(ok == false);
else
    fprintf('There is no MINLP in opt problem types')
end

ok = changeCobraSolver('pdco', 'LP', 0);
assert(ok == true);
global CBT_LP_SOLVER
assert(strcmp(CBT_LP_SOLVER, 'pdco'))

if any(ismember('MINLP',OPT_PROB_TYPES))
    global CBT_MINLP_SOLVER
    CBT_MINLP_SOLVER = [];
    ok = changeCobraSolver('pdco', 'MINLP', 0);
    assert(ok == false);
    assert(isempty(CBT_MINLP_SOLVER))
end

try
    ok = changeCobraSolver('gurobi_mex', 'MILP', 1);
catch ME
    assert(length(ME.message) > 0)
end

% Two arguments
try
    ok = changeCobraSolver('pdco', 'MINLP');
catch ME
    assert(length(ME.message) > 0)
end

try
    ok = changeCobraSolver('pdco', 'MILP');
catch ME
    assert(length(ME.message) > 0)
end

try
    ok = changeCobraSolver('mysolver', 'MILP');
catch ME
    assert(length(ME.message) > 0)
end

for i = 1:length(OPT_PROB_TYPES)
    varName = horzcat(['CBT_', OPT_PROB_TYPES{i}, '_SOLVER']);
    eval(['global ' varName])
    eval(['clear ' varName]);
end
changeCobraSolver('pdco', 'all')
for i = 1:length(SOLVERS.pdco.type)
    varName = horzcat(['CBT_', SOLVERS.pdco.type{i}, '_SOLVER']);
    eval(['global ' varName])
    assert(strcmp(eval(varName), 'pdco'))
end

% One argument
try
    ok = changeCobraSolver('matlab');
catch ME
    assert(length(ME.message) > 0)
end

% legacy MPS support
try
    ok = changeCobraSolver('mps');
catch ME
    assert(length(ME.message) > 0)
end

% output a success message
fprintf('Done.\n');
