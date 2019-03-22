% The COBRAToolbox: testParseCobraVarargin.m
%
% Purpose:
%     - testParseCobraVarargin tests the ability of parseCobraVarargin to
%     return the correct function, cobra and solver parameters given
%     different supported input formats
%
% Authors:
%     - Original file: Joshua Chan 03/22/19
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFVA'));
cd(fileDir);

% set all cobra parameters to default values
[paramNames, paramDefault] = deal(struct());
for str = {'LP', 'MILP'}
    paramNames.(str{1}) = getCobraSolverParamsOptionsForType(str{1});
    paramDefault.(str{1}) = cell(numel(paramNames.(str{1})), 1);
    [paramDefault.(str{1}){:}] = getCobraSolverParams(str{1}, paramNames.(str{1}), 'default');
    for j = 1:numel(paramNames.(str{1}))
        changeCobraSolverParams(str{1}, paramNames.(str{1}){j}, paramDefault.(str{1}){j});
    end
end

optArgin = {'aIn', 'aIn2', 'bIn'};
defaultValues = {[], 'test', 2};
validator = {@(x) true, @ischar, @(x) isscalar(x) & isnumeric(x)};
problemTypes = {'LP', 'MILP'};

% test getting default values
[funParams, cobraParams, solverVarargin] = parseCobraVarargin({}, optArgin, defaultValues, validator, problemTypes);
[aIn, aIn2, bIn] = deal(funParams{:});
assert(isequal(aIn, []) & isequal(aIn2, 'test') & isequal(bIn, 2))
assert(isequal(cobraParams.LP, struct('minNorm',0,'printLevel',0,'primalOnly',0,'saveInput',[],'feasTol',1.00000000000000e-09,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0,'logFile','CobraLPSolver.log','lifting',0)))
assert(isequal(cobraParams.MILP, struct('intTol',1.00000000000000e-12,'relMipGapTol',1.00000000000000e-12,'absMipGapTol',1.00000000000000e-12,'timeLimit',1.00000000000000e+36,'logFile','CobraMILPSolver.log','printLevel',0,'saveInput',[],'feasTol',1.00000000000000e-09,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0)))
assert(isequal(solverVarargin.LP, {struct(),'minNorm',0,'printLevel',0,'primalOnly',0,'saveInput',[],'feasTol',1.00000000000000e-09,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0,'logFile','CobraLPSolver.log','lifting',0}))
assert(isequal(solverVarargin.MILP, {struct(),'intTol',1.00000000000000e-12,'relMipGapTol',1.00000000000000e-12,'absMipGapTol',1.00000000000000e-12,'timeLimit',1.00000000000000e+36,'logFile','CobraMILPSolver.log','printLevel',0,'saveInput',[],'feasTol',1.00000000000000e-09,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0}))

% test all direct inputs
[funParams, cobraParams, solverVarargin] = parseCobraVarargin({{'cobraIsFun'}, 'testDirectInputs', 999}, optArgin, defaultValues, validator, problemTypes);
[aIn, aIn2, bIn] = deal(funParams{:});
assert(isequal(aIn, {'cobraIsFun'}) & isequal(aIn2, 'testDirectInputs') & isequal(bIn, 999))
assert(isequal(cobraParams.LP, struct('minNorm',0,'printLevel',0,'primalOnly',0,'saveInput',[],'feasTol',1.00000000000000e-09,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0,'logFile','CobraLPSolver.log','lifting',0)))
assert(isequal(cobraParams.MILP, struct('intTol',1.00000000000000e-12,'relMipGapTol',1.00000000000000e-12,'absMipGapTol',1.00000000000000e-12,'timeLimit',1.00000000000000e+36,'logFile','CobraMILPSolver.log','printLevel',0,'saveInput',[],'feasTol',1.00000000000000e-09,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0)))
assert(isequal(solverVarargin.LP, {struct(),'minNorm',0,'printLevel',0,'primalOnly',0,'saveInput',[],'feasTol',1.00000000000000e-09,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0,'logFile','CobraLPSolver.log','lifting',0}))
assert(isequal(solverVarargin.MILP, {struct(),'intTol',1.00000000000000e-12,'relMipGapTol',1.00000000000000e-12,'absMipGapTol',1.00000000000000e-12,'timeLimit',1.00000000000000e+36,'logFile','CobraMILPSolver.log','printLevel',0,'saveInput',[],'feasTol',1.00000000000000e-09,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0}))

% test all parameter-value inputs
[funParams, cobraParams, solverVarargin] = parseCobraVarargin({'bIn', 101, 'aIn2', 'testParamValueInputs', 'aIn', struct('testStruct', 123)}, optArgin, defaultValues, validator, problemTypes);
[aIn, aIn2, bIn] = deal(funParams{:});
assert(isequal(aIn, struct('testStruct', 123)) & isequal(aIn2, 'testParamValueInputs') & isequal(bIn, 101))
assert(isequal(cobraParams.LP, struct('minNorm',0,'printLevel',0,'primalOnly',0,'saveInput',[],'feasTol',1.00000000000000e-09,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0,'logFile','CobraLPSolver.log','lifting',0)))
assert(isequal(cobraParams.MILP, struct('intTol',1.00000000000000e-12,'relMipGapTol',1.00000000000000e-12,'absMipGapTol',1.00000000000000e-12,'timeLimit',1.00000000000000e+36,'logFile','CobraMILPSolver.log','printLevel',0,'saveInput',[],'feasTol',1.00000000000000e-09,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0)))
assert(isequal(solverVarargin.LP, {struct(),'minNorm',0,'printLevel',0,'primalOnly',0,'saveInput',[],'feasTol',1.00000000000000e-09,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0,'logFile','CobraLPSolver.log','lifting',0}))
assert(isequal(solverVarargin.MILP, {struct(),'intTol',1.00000000000000e-12,'relMipGapTol',1.00000000000000e-12,'absMipGapTol',1.00000000000000e-12,'timeLimit',1.00000000000000e+36,'logFile','CobraMILPSolver.log','printLevel',0,'saveInput',[],'feasTol',1.00000000000000e-09,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0}))

% test mixed inputs
[funParams, cobraParams, solverVarargin] = parseCobraVarargin({'whatever', 'bIn', 1e-8}, optArgin, defaultValues, validator, problemTypes);
[aIn, aIn2, bIn] = deal(funParams{:});
assert(isequal(aIn, 'whatever') & isequal(aIn2, 'test') & isequal(bIn, 1e-8))
assert(isequal(cobraParams.LP, struct('minNorm',0,'printLevel',0,'primalOnly',0,'saveInput',[],'feasTol',1.00000000000000e-09,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0,'logFile','CobraLPSolver.log','lifting',0)))
assert(isequal(cobraParams.MILP, struct('intTol',1.00000000000000e-12,'relMipGapTol',1.00000000000000e-12,'absMipGapTol',1.00000000000000e-12,'timeLimit',1.00000000000000e+36,'logFile','CobraMILPSolver.log','printLevel',0,'saveInput',[],'feasTol',1.00000000000000e-09,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0)))
assert(isequal(solverVarargin.LP, {struct(),'minNorm',0,'printLevel',0,'primalOnly',0,'saveInput',[],'feasTol',1.00000000000000e-09,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0,'logFile','CobraLPSolver.log','lifting',0}))
assert(isequal(solverVarargin.MILP, {struct(),'intTol',1.00000000000000e-12,'relMipGapTol',1.00000000000000e-12,'absMipGapTol',1.00000000000000e-12,'timeLimit',1.00000000000000e+36,'logFile','CobraMILPSolver.log','printLevel',0,'saveInput',[],'feasTol',1.00000000000000e-09,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0}))

% test mixed inputs with cobra params
[funParams, cobraParams, solverVarargin] = parseCobraVarargin({'whatever', 'bIn', 1e-8, 'feasTol', 1e-8}, optArgin, defaultValues, validator, problemTypes);
[aIn, aIn2, bIn] = deal(funParams{:});
assert(isequal(aIn, 'whatever') & isequal(aIn2, 'test') & isequal(bIn, 1e-8))
assert(isequal(cobraParams.LP, struct('minNorm',0,'printLevel',0,'primalOnly',0,'saveInput',[],'feasTol',1.00000000000000e-08,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0,'logFile','CobraLPSolver.log','lifting',0)))
assert(isequal(cobraParams.MILP, struct('intTol',1.00000000000000e-12,'relMipGapTol',1.00000000000000e-12,'absMipGapTol',1.00000000000000e-12,'timeLimit',1.00000000000000e+36,'logFile','CobraMILPSolver.log','printLevel',0,'saveInput',[],'feasTol',1.00000000000000e-08,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0)))
assert(isequal(solverVarargin.LP, {struct(),'minNorm',0,'printLevel',0,'primalOnly',0,'saveInput',[],'feasTol',1.00000000000000e-08,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0,'logFile','CobraLPSolver.log','lifting',0}))
assert(isequal(solverVarargin.MILP, {struct(),'intTol',1.00000000000000e-12,'relMipGapTol',1.00000000000000e-12,'absMipGapTol',1.00000000000000e-12,'timeLimit',1.00000000000000e+36,'logFile','CobraMILPSolver.log','printLevel',0,'saveInput',[],'feasTol',1.00000000000000e-08,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0}))

[funParams, cobraParams, solverVarargin] = parseCobraVarargin({'whatever', 'bIn', 1e-8, 'feasTol', 1e-8, 'intTol', 1e-9}, optArgin, defaultValues, validator, problemTypes);
[aIn, aIn2, bIn] = deal(funParams{:});
assert(isequal(aIn, 'whatever') & isequal(aIn2, 'test') & isequal(bIn, 1e-8))
assert(isequal(cobraParams.LP, struct('minNorm',0,'printLevel',0,'primalOnly',0,'saveInput',[],'feasTol',1.00000000000000e-08,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0,'logFile','CobraLPSolver.log','lifting',0)))
assert(isequal(cobraParams.MILP, struct('intTol',1.00000000000000e-9,'relMipGapTol',1.00000000000000e-12,'absMipGapTol',1.00000000000000e-12,'timeLimit',1.00000000000000e+36,'logFile','CobraMILPSolver.log','printLevel',0,'saveInput',[],'feasTol',1.00000000000000e-08,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0)))
assert(isequal(solverVarargin.LP, {struct(),'minNorm',0,'printLevel',0,'primalOnly',0,'saveInput',[],'feasTol',1.00000000000000e-08,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0,'logFile','CobraLPSolver.log','lifting',0}))
assert(isequal(solverVarargin.MILP, {struct(),'intTol',1.00000000000000e-9,'relMipGapTol',1.00000000000000e-12,'absMipGapTol',1.00000000000000e-12,'timeLimit',1.00000000000000e+36,'logFile','CobraMILPSolver.log','printLevel',0,'saveInput',[],'feasTol',1.00000000000000e-08,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0}))

% test mixed inputs with cobra and solver params
% solver params at last
[funParams, cobraParams, solverVarargin] = parseCobraVarargin({'whatever', 'bIn', 1e-8, 'feasTol', 1e-8, 'intTol', 1e-9, struct('Presolve', 0)}, optArgin, defaultValues, validator, problemTypes);
[aIn, aIn2, bIn] = deal(funParams{:});
assert(isequal(aIn, 'whatever') & isequal(aIn2, 'test') & isequal(bIn, 1e-8))
assert(isequal(cobraParams.LP, struct('minNorm',0,'printLevel',0,'primalOnly',0,'saveInput',[],'feasTol',1.00000000000000e-08,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0,'logFile','CobraLPSolver.log','lifting',0)))
assert(isequal(cobraParams.MILP, struct('intTol',1.00000000000000e-9,'relMipGapTol',1.00000000000000e-12,'absMipGapTol',1.00000000000000e-12,'timeLimit',1.00000000000000e+36,'logFile','CobraMILPSolver.log','printLevel',0,'saveInput',[],'feasTol',1.00000000000000e-08,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0)))
assert(isequal(solverVarargin.LP, {struct('Presolve', 0),'minNorm',0,'printLevel',0,'primalOnly',0,'saveInput',[],'feasTol',1.00000000000000e-08,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0,'logFile','CobraLPSolver.log','lifting',0}))
assert(isequal(solverVarargin.MILP, {struct('Presolve', 0),'intTol',1.00000000000000e-9,'relMipGapTol',1.00000000000000e-12,'absMipGapTol',1.00000000000000e-12,'timeLimit',1.00000000000000e+36,'logFile','CobraMILPSolver.log','printLevel',0,'saveInput',[],'feasTol',1.00000000000000e-08,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0}))

% solver params before cobra params
[funParams, cobraParams, solverVarargin] = parseCobraVarargin({'whatever', 'bIn', 1e-8, struct('Presolve', 0), 'feasTol', 1e-8, 'intTol', 1e-9}, optArgin, defaultValues, validator, problemTypes);
[aIn, aIn2, bIn] = deal(funParams{:});
assert(isequal(aIn, 'whatever') & isequal(aIn2, 'test') & isequal(bIn, 1e-8))
assert(isequal(cobraParams.LP, struct('minNorm',0,'printLevel',0,'primalOnly',0,'saveInput',[],'feasTol',1.00000000000000e-08,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0,'logFile','CobraLPSolver.log','lifting',0)))
assert(isequal(cobraParams.MILP, struct('intTol',1.00000000000000e-9,'relMipGapTol',1.00000000000000e-12,'absMipGapTol',1.00000000000000e-12,'timeLimit',1.00000000000000e+36,'logFile','CobraMILPSolver.log','printLevel',0,'saveInput',[],'feasTol',1.00000000000000e-08,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0)))
assert(isequal(solverVarargin.LP, {struct('Presolve', 0),'minNorm',0,'printLevel',0,'primalOnly',0,'saveInput',[],'feasTol',1.00000000000000e-08,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0,'logFile','CobraLPSolver.log','lifting',0}))
assert(isequal(solverVarargin.MILP, {struct('Presolve', 0),'intTol',1.00000000000000e-9,'relMipGapTol',1.00000000000000e-12,'absMipGapTol',1.00000000000000e-12,'timeLimit',1.00000000000000e+36,'logFile','CobraMILPSolver.log','printLevel',0,'saveInput',[],'feasTol',1.00000000000000e-08,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0}))

% solver params in between cobra params
[funParams, cobraParams, solverVarargin] = parseCobraVarargin({'whatever', 'bIn', 1e-8, 'feasTol', 1e-8, struct('Presolve', 0), 'intTol', 1e-9}, optArgin, defaultValues, validator, problemTypes);
[aIn, aIn2, bIn] = deal(funParams{:});
assert(isequal(aIn, 'whatever') & isequal(aIn2, 'test') & isequal(bIn, 1e-8))
assert(isequal(cobraParams.LP, struct('minNorm',0,'printLevel',0,'primalOnly',0,'saveInput',[],'feasTol',1.00000000000000e-08,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0,'logFile','CobraLPSolver.log','lifting',0)))
assert(isequal(cobraParams.MILP, struct('intTol',1.00000000000000e-9,'relMipGapTol',1.00000000000000e-12,'absMipGapTol',1.00000000000000e-12,'timeLimit',1.00000000000000e+36,'logFile','CobraMILPSolver.log','printLevel',0,'saveInput',[],'feasTol',1.00000000000000e-08,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0)))
assert(isequal(solverVarargin.LP, {struct('Presolve', 0),'minNorm',0,'printLevel',0,'primalOnly',0,'saveInput',[],'feasTol',1.00000000000000e-08,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0,'logFile','CobraLPSolver.log','lifting',0}))
assert(isequal(solverVarargin.MILP, {struct('Presolve', 0),'intTol',1.00000000000000e-9,'relMipGapTol',1.00000000000000e-12,'absMipGapTol',1.00000000000000e-12,'timeLimit',1.00000000000000e+36,'logFile','CobraMILPSolver.log','printLevel',0,'saveInput',[],'feasTol',1.00000000000000e-08,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0}))

% function params, cobra params and solver params mixed (except direct input)
[funParams, cobraParams, solverVarargin] = parseCobraVarargin({'whatever', 'feasTol', 1e-8, 'bIn', 1e-8, struct('Presolve', 0), 'intTol', 1e-9}, optArgin, defaultValues, validator, problemTypes);
[aIn, aIn2, bIn] = deal(funParams{:});
assert(isequal(aIn, 'whatever') & isequal(aIn2, 'test') & isequal(bIn, 1e-8))
assert(isequal(cobraParams.LP, struct('minNorm',0,'printLevel',0,'primalOnly',0,'saveInput',[],'feasTol',1.00000000000000e-08,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0,'logFile','CobraLPSolver.log','lifting',0)))
assert(isequal(cobraParams.MILP, struct('intTol',1.00000000000000e-9,'relMipGapTol',1.00000000000000e-12,'absMipGapTol',1.00000000000000e-12,'timeLimit',1.00000000000000e+36,'logFile','CobraMILPSolver.log','printLevel',0,'saveInput',[],'feasTol',1.00000000000000e-08,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0)))
assert(isequal(solverVarargin.LP, {struct('Presolve', 0),'minNorm',0,'printLevel',0,'primalOnly',0,'saveInput',[],'feasTol',1.00000000000000e-08,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0,'logFile','CobraLPSolver.log','lifting',0}))
assert(isequal(solverVarargin.MILP, {struct('Presolve', 0),'intTol',1.00000000000000e-9,'relMipGapTol',1.00000000000000e-12,'absMipGapTol',1.00000000000000e-12,'timeLimit',1.00000000000000e+36,'logFile','CobraMILPSolver.log','printLevel',0,'saveInput',[],'feasTol',1.00000000000000e-08,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0}))

% cobra + solver params in one structure
[funParams, cobraParams, solverVarargin] = parseCobraVarargin({'whatever', 'bIn', 1e-8, struct('Presolve', 0, 'feasTol', 1e-8, 'intTol', 1e-9)}, optArgin, defaultValues, validator, problemTypes);
[aIn, aIn2, bIn] = deal(funParams{:});
assert(isequal(aIn, 'whatever') & isequal(aIn2, 'test') & isequal(bIn, 1e-8))
assert(isequal(cobraParams.LP, struct('minNorm',0,'printLevel',0,'primalOnly',0,'saveInput',[],'feasTol',1.00000000000000e-08,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0,'logFile','CobraLPSolver.log','lifting',0)))
assert(isequal(cobraParams.MILP, struct('intTol',1.00000000000000e-9,'relMipGapTol',1.00000000000000e-12,'absMipGapTol',1.00000000000000e-12,'timeLimit',1.00000000000000e+36,'logFile','CobraMILPSolver.log','printLevel',0,'saveInput',[],'feasTol',1.00000000000000e-08,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0)))
assert(isequal(solverVarargin.LP, {struct('Presolve', 0),'minNorm',0,'printLevel',0,'primalOnly',0,'saveInput',[],'feasTol',1.00000000000000e-08,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0,'logFile','CobraLPSolver.log','lifting',0}))
assert(isequal(solverVarargin.MILP, {struct('Presolve', 0),'intTol',1.00000000000000e-9,'relMipGapTol',1.00000000000000e-12,'absMipGapTol',1.00000000000000e-12,'timeLimit',1.00000000000000e+36,'logFile','CobraMILPSolver.log','printLevel',0,'saveInput',[],'feasTol',1.00000000000000e-08,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0}))

% all params in one structure (except direct input)
[funParams, cobraParams, solverVarargin] = parseCobraVarargin({'whatever', struct('Presolve', 0, 'feasTol', 1e-8, 'intTol', 1e-9, 'bIn', 1e-8)}, optArgin, defaultValues, validator, problemTypes);
[aIn, aIn2, bIn] = deal(funParams{:});
assert(isequal(aIn, 'whatever') & isequal(aIn2, 'test') & isequal(bIn, 1e-8))
assert(isequal(cobraParams.LP, struct('minNorm',0,'printLevel',0,'primalOnly',0,'saveInput',[],'feasTol',1.00000000000000e-08,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0,'logFile','CobraLPSolver.log','lifting',0)))
assert(isequal(cobraParams.MILP, struct('intTol',1.00000000000000e-9,'relMipGapTol',1.00000000000000e-12,'absMipGapTol',1.00000000000000e-12,'timeLimit',1.00000000000000e+36,'logFile','CobraMILPSolver.log','printLevel',0,'saveInput',[],'feasTol',1.00000000000000e-08,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0)))
assert(isequal(solverVarargin.LP, {struct('Presolve', 0),'minNorm',0,'printLevel',0,'primalOnly',0,'saveInput',[],'feasTol',1.00000000000000e-08,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0,'logFile','CobraLPSolver.log','lifting',0}))
assert(isequal(solverVarargin.MILP, {struct('Presolve', 0),'intTol',1.00000000000000e-9,'relMipGapTol',1.00000000000000e-12,'absMipGapTol',1.00000000000000e-12,'timeLimit',1.00000000000000e+36,'logFile','CobraMILPSolver.log','printLevel',0,'saveInput',[],'feasTol',1.00000000000000e-08,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0}))

% aIn is an explicit solver param input
[funParams, cobraParams, solverVarargin] = parseCobraVarargin({struct('Presolve', 0), struct('feasTol', 1e-8, 'intTol', 1e-9, 'bIn', 1e-8)}, optArgin, defaultValues, validator, problemTypes, 'aIn');
assert(numel(funParams) == 2)
[aIn2, bIn] = deal(funParams{:});
assert(isequal(aIn, 'whatever') & isequal(aIn2, 'test') & isequal(bIn, 1e-8))
assert(isequal(cobraParams.LP, struct('minNorm',0,'printLevel',0,'primalOnly',0,'saveInput',[],'feasTol',1.00000000000000e-08,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0,'logFile','CobraLPSolver.log','lifting',0)))
assert(isequal(cobraParams.MILP, struct('intTol',1.00000000000000e-9,'relMipGapTol',1.00000000000000e-12,'absMipGapTol',1.00000000000000e-12,'timeLimit',1.00000000000000e+36,'logFile','CobraMILPSolver.log','printLevel',0,'saveInput',[],'feasTol',1.00000000000000e-08,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0)))
assert(isequal(solverVarargin.LP, {struct('Presolve', 0),'minNorm',0,'printLevel',0,'primalOnly',0,'saveInput',[],'feasTol',1.00000000000000e-08,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0,'logFile','CobraLPSolver.log','lifting',0}))
assert(isequal(solverVarargin.MILP, {struct('Presolve', 0),'intTol',1.00000000000000e-9,'relMipGapTol',1.00000000000000e-12,'absMipGapTol',1.00000000000000e-12,'timeLimit',1.00000000000000e+36,'logFile','CobraMILPSolver.log','printLevel',0,'saveInput',[],'feasTol',1.00000000000000e-08,'optTol',1.00000000000000e-09,'solver','gurobi','debug',0}))


assert(verifyCobraFunctionError('parseCobraVarargin', 'outputArgCount', 3, ...
                    'input', {{}, optArgin, defaultValues, validator, 'ABC'}, ...
                    'testMessage', 'Input ABC for `ProblemTypes` not supported. Only ''LP'', ''MILP'', ''QP'' and ''MIQP'' are supported'))

% change the directory
cd(currentDir)