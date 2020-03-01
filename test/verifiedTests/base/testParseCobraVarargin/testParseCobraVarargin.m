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
[paramNames, paramValues, paramCurrent] = deal(struct());
for str = {'LP', 'MILP', 'QP', 'MIQP', 'NLP'}
    paramNames.(str{1}) = getCobraSolverParamsOptionsForType(str{1});
    % exclude 'solver', which is not identified by getCobraSolverParams
    paramNames.(str{1})(strcmp(paramNames.(str{1}), 'solver')) = [];
    paramValues.(str{1}) = cell(1, numel(paramNames.(str{1})));
    [paramValues.(str{1}){:}] = getCobraSolverParams(str{1}, paramNames.(str{1}));
end

optArgin = {'aIn', 'aIn2', 'bIn'};
defaultValues = {[], 'test', 2};
validator = {@(x) true, @ischar, @(x) isscalar(x) & isnumeric(x)};

% test getting default values
[funParams, cobraParams, solverVarargin] = parseCobraVarargin({}, optArgin, defaultValues, validator, {'LP', 'MILP', 'QP', 'MIQP', 'NLP'});
[aIn, aIn2, bIn] = deal(funParams{:});
assert(isequal(aIn, []) & isequal(aIn2, 'test') & isequal(bIn, 2))
for str = {'LP', 'MILP', 'QP', 'MIQP', 'NLP'}
    cobraParamsCorrect = [paramNames.(str{1})', paramValues.(str{1})'];
    cobraParamsCorrect =cobraParamsCorrect';
    cobraParamsCorrectStruct = struct(cobraParamsCorrect{:});
    % all fields the same except 'solver'
    assert(isequal(rmfield(cobraParams.(str{1}), 'solver'), cobraParamsCorrectStruct))
    % first argument in solverVarargin being empty structure
    assert(isequal(solverVarargin.(str{1}){1}, struct()))
    % all other fields the same except 'solver'
    assert(isequal(rmfield(struct(solverVarargin.(str{1}){2:end}), 'solver'), struct(cobraParamsCorrect{:})))
end

feasTolCur = cobraParams.LP.feasTol;
intTolCur = cobraParams.MILP.intTol;
problemTypes = {'LP', 'MILP'};


% test all direct inputs
[funParams, cobraParams, solverVarargin] = parseCobraVarargin({{'cobraIsFun'}, 'testDirectInputs', 999}, optArgin, defaultValues, validator, problemTypes);
[aIn, aIn2, bIn] = deal(funParams{:});
assert(isequal(aIn, {'cobraIsFun'}) & isequal(aIn2, 'testDirectInputs') & isequal(bIn, 999))
for str = problemTypes
    cobraParamsCorrect = [paramNames.(str{1}); paramValues.(str{1})];
    cobraParamsCorrectStruct = struct(cobraParamsCorrect{:});
    % all fields the same except 'solver'
    assert(isequal(rmfield(cobraParams.(str{1}), 'solver'), cobraParamsCorrectStruct))
    % first argument in solverVarargin being empty structure
    assert(isequal(solverVarargin.(str{1}){1}, struct()))
    % all other fields the same except 'solver'
    assert(isequal(rmfield(struct(solverVarargin.(str{1}){2:end}), 'solver'), struct(cobraParamsCorrect{:})))
end

% test all parameter-value inputs
[funParams, cobraParams, solverVarargin] = parseCobraVarargin({'bIn', 101, 'aIn2', 'testParamValueInputs', 'aIn', struct('testStruct', 123)}, optArgin, defaultValues, validator, problemTypes);
[aIn, aIn2, bIn] = deal(funParams{:});
assert(isequal(aIn, struct('testStruct', 123)) & isequal(aIn2, 'testParamValueInputs') & isequal(bIn, 101))
for str = problemTypes
    cobraParamsCorrect = [paramNames.(str{1}); paramValues.(str{1})];
    cobraParamsCorrectStruct = struct(cobraParamsCorrect{:});
    % all fields the same except 'solver'
    assert(isequal(rmfield(cobraParams.(str{1}), 'solver'), cobraParamsCorrectStruct))
    % first argument in solverVarargin being empty structure
    assert(isequal(solverVarargin.(str{1}){1}, struct()))
    % all other fields the same except 'solver'
    assert(isequal(rmfield(struct(solverVarargin.(str{1}){2:end}), 'solver'), struct(cobraParamsCorrect{:})))
end

% test mixed inputs
[funParams, cobraParams, solverVarargin] = parseCobraVarargin({'whatever', 'bIn', 1e-8}, optArgin, defaultValues, validator, problemTypes);
[aIn, aIn2, bIn] = deal(funParams{:});
assert(isequal(aIn, 'whatever') & isequal(aIn2, 'test') & isequal(bIn, 1e-8))
for str = problemTypes
    cobraParamsCorrect = [paramNames.(str{1}); paramValues.(str{1})];
    cobraParamsCorrectStruct = struct(cobraParamsCorrect{:});
    % all fields the same except 'solver'
    assert(isequal(rmfield(cobraParams.(str{1}), 'solver'), cobraParamsCorrectStruct))
    % first argument in solverVarargin being empty structure
    assert(isequal(solverVarargin.(str{1}){1}, struct()))
    % all other fields the same except 'solver'
    assert(isequal(rmfield(struct(solverVarargin.(str{1}){2:end}), 'solver'), struct(cobraParamsCorrect{:})))
end

% test mixed inputs with cobra params
[funParams, cobraParams, solverVarargin] = parseCobraVarargin({'whatever', 'bIn', 1e-8, 'feasTol', feasTolCur * 2}, optArgin, defaultValues, validator, problemTypes);
[aIn, aIn2, bIn] = deal(funParams{:});
assert(isequal(aIn, 'whatever') & isequal(aIn2, 'test') & isequal(bIn, 1e-8))
for str = problemTypes
    cobraParamsCorrect = [paramNames.(str{1}); paramValues.(str{1})];
    cobraParamsCorrectStruct = struct(cobraParamsCorrect{:});
    cobraParamsCorrectStruct.feasTol = feasTolCur * 2;
    % all fields the same except 'solver'
    assert(isequal(rmfield(cobraParams.(str{1}), 'solver'), cobraParamsCorrectStruct))
    % first argument in solverVarargin being empty structure
    assert(isequal(solverVarargin.(str{1}){1}, struct()))
    % all other fields the same except 'solver'
    solverVararginCur = rmfield(struct(solverVarargin.(str{1}){2:end}), 'solver');
    solverVararginCur.feasTol = feasTolCur * 2;
    assert(isequal(solverVararginCur, cobraParamsCorrectStruct))
end

[funParams, cobraParams, solverVarargin] = parseCobraVarargin({'whatever', 'bIn', 1e-8, 'feasTol', feasTolCur * 2, 'intTol', intTolCur * 2}, optArgin, defaultValues, validator, problemTypes);
[aIn, aIn2, bIn] = deal(funParams{:});
assert(isequal(aIn, 'whatever') & isequal(aIn2, 'test') & isequal(bIn, 1e-8))
for str = problemTypes
    cobraParamsCorrect = [paramNames.(str{1}); paramValues.(str{1})];
    cobraParamsCorrectStruct = struct(cobraParamsCorrect{:});
    cobraParamsCorrectStruct.feasTol = feasTolCur * 2;
    if strcmp(str{1}, 'MILP')
        cobraParamsCorrectStruct.intTol = intTolCur * 2;
    end
    % all fields the same except 'solver'
    assert(isequal(rmfield(cobraParams.(str{1}), 'solver'), cobraParamsCorrectStruct))
    % first argument in solverVarargin being empty structure
    assert(isequal(solverVarargin.(str{1}){1}, struct()))
    % all other fields the same except 'solver'
    solverVararginCur = rmfield(struct(solverVarargin.(str{1}){2:end}), 'solver');
    solverVararginCur.feasTol = feasTolCur * 2;
    if strcmp(str{1}, 'MILP')
        solverVararginCur.intTol = intTolCur * 2;
    end
    assert(isequal(solverVararginCur, cobraParamsCorrectStruct))
end

% test mixed inputs with cobra and solver params
% solver params at last
[funParams, cobraParams, solverVarargin] = parseCobraVarargin({'whatever', 'bIn', 1e-8, 'feasTol', feasTolCur * 2, 'intTol', intTolCur * 2, struct('Presolve', 0)}, optArgin, defaultValues, validator, problemTypes);
[aIn, aIn2, bIn] = deal(funParams{:});
assert(isequal(aIn, 'whatever') & isequal(aIn2, 'test') & isequal(bIn, 1e-8))
for str = problemTypes
    cobraParamsCorrect = [paramNames.(str{1}); paramValues.(str{1})];
    cobraParamsCorrectStruct = struct(cobraParamsCorrect{:});
    cobraParamsCorrectStruct.feasTol = feasTolCur * 2;
    if strcmp(str{1}, 'MILP')
        cobraParamsCorrectStruct.intTol = intTolCur * 2;
    end
    % all fields the same except 'solver'
    assert(isequal(rmfield(cobraParams.(str{1}), 'solver'), cobraParamsCorrectStruct))
    % first argument in solverVarargin being empty structure
    assert(isequal(solverVarargin.(str{1}){1}, struct('Presolve', 0)))
    % all other fields the same except 'solver'
    solverVararginCur = rmfield(struct(solverVarargin.(str{1}){2:end}), 'solver');
    solverVararginCur.feasTol = feasTolCur * 2;
    if strcmp(str{1}, 'MILP')
        solverVararginCur.intTol = intTolCur * 2;
    end
    assert(isequal(solverVararginCur, cobraParamsCorrectStruct))
end

% solver params before cobra params
[funParams, cobraParams, solverVarargin] = parseCobraVarargin({'whatever', 'bIn', 1e-8, struct('Presolve', 0), 'feasTol', feasTolCur * 2, 'intTol', intTolCur * 2}, optArgin, defaultValues, validator, problemTypes);
[aIn, aIn2, bIn] = deal(funParams{:});
assert(isequal(aIn, 'whatever') & isequal(aIn2, 'test') & isequal(bIn, 1e-8))
for str = problemTypes
    cobraParamsCorrect = [paramNames.(str{1}); paramValues.(str{1})];
    cobraParamsCorrectStruct = struct(cobraParamsCorrect{:});
    cobraParamsCorrectStruct.feasTol = feasTolCur * 2;
    if strcmp(str{1}, 'MILP')
        cobraParamsCorrectStruct.intTol = intTolCur * 2;
    end
    % all fields the same except 'solver'
    assert(isequal(rmfield(cobraParams.(str{1}), 'solver'), cobraParamsCorrectStruct))
    % first argument in solverVarargin being empty structure
    assert(isequal(solverVarargin.(str{1}){1}, struct('Presolve', 0)))
    % all other fields the same except 'solver'
    solverVararginCur = rmfield(struct(solverVarargin.(str{1}){2:end}), 'solver');
    solverVararginCur.feasTol = feasTolCur * 2;
    if strcmp(str{1}, 'MILP')
        solverVararginCur.intTol = intTolCur * 2;
    end
    assert(isequal(solverVararginCur, cobraParamsCorrectStruct))
end

% solver params in between cobra params
[funParams, cobraParams, solverVarargin] = parseCobraVarargin({'whatever', 'bIn', 1e-8, 'feasTol', feasTolCur * 2, struct('Presolve', 0), 'intTol', intTolCur * 2}, optArgin, defaultValues, validator, problemTypes);
[aIn, aIn2, bIn] = deal(funParams{:});
assert(isequal(aIn, 'whatever') & isequal(aIn2, 'test') & isequal(bIn, 1e-8))
for str = problemTypes
    cobraParamsCorrect = [paramNames.(str{1}); paramValues.(str{1})];
    cobraParamsCorrectStruct = struct(cobraParamsCorrect{:});
    cobraParamsCorrectStruct.feasTol = feasTolCur * 2;
    if strcmp(str{1}, 'MILP')
        cobraParamsCorrectStruct.intTol = intTolCur * 2;
    end
    % all fields the same except 'solver'
    assert(isequal(rmfield(cobraParams.(str{1}), 'solver'), cobraParamsCorrectStruct))
    % first argument in solverVarargin being empty structure
    assert(isequal(solverVarargin.(str{1}){1}, struct('Presolve', 0)))
    % all other fields the same except 'solver'
    solverVararginCur = rmfield(struct(solverVarargin.(str{1}){2:end}), 'solver');
    solverVararginCur.feasTol = feasTolCur * 2;
    if strcmp(str{1}, 'MILP')
        solverVararginCur.intTol = intTolCur * 2;
    end
    assert(isequal(solverVararginCur, cobraParamsCorrectStruct))
end

% function params, cobra params and solver params in mixed order (except direct input)
[funParams, cobraParams, solverVarargin] = parseCobraVarargin({'whatever', 'feasTol', feasTolCur * 2, 'bIn', 1e-8, struct('Presolve', 0), 'intTol', intTolCur * 2}, optArgin, defaultValues, validator, problemTypes);
[aIn, aIn2, bIn] = deal(funParams{:});
assert(isequal(aIn, 'whatever') & isequal(aIn2, 'test') & isequal(bIn, 1e-8))
for str = problemTypes
    cobraParamsCorrect = [paramNames.(str{1}); paramValues.(str{1})];
    cobraParamsCorrectStruct = struct(cobraParamsCorrect{:});
    cobraParamsCorrectStruct.feasTol = feasTolCur * 2;
    if strcmp(str{1}, 'MILP')
        cobraParamsCorrectStruct.intTol = intTolCur * 2;
    end
    % all fields the same except 'solver'
    assert(isequal(rmfield(cobraParams.(str{1}), 'solver'), cobraParamsCorrectStruct))
    % first argument in solverVarargin being empty structure
    assert(isequal(solverVarargin.(str{1}){1}, struct('Presolve', 0)))
    % all other fields the same except 'solver'
    solverVararginCur = rmfield(struct(solverVarargin.(str{1}){2:end}), 'solver');
    solverVararginCur.feasTol = feasTolCur * 2;
    if strcmp(str{1}, 'MILP')
        solverVararginCur.intTol = intTolCur * 2;
    end
    assert(isequal(solverVararginCur, cobraParamsCorrectStruct))
end

% cobra + solver params in one structure
[funParams, cobraParams, solverVarargin] = parseCobraVarargin({'whatever', 'bIn', 1e-8, struct('Presolve', 0, 'feasTol', feasTolCur * 2, 'intTol', intTolCur * 2)}, optArgin, defaultValues, validator, problemTypes);
[aIn, aIn2, bIn] = deal(funParams{:});
assert(isequal(aIn, 'whatever') & isequal(aIn2, 'test') & isequal(bIn, 1e-8))
for str = problemTypes
    cobraParamsCorrect = [paramNames.(str{1}); paramValues.(str{1})];
    cobraParamsCorrectStruct = struct(cobraParamsCorrect{:});
    cobraParamsCorrectStruct.feasTol = feasTolCur * 2;
    if strcmp(str{1}, 'MILP')
        cobraParamsCorrectStruct.intTol = intTolCur * 2;
    end
    % all fields the same except 'solver'
    assert(isequal(rmfield(cobraParams.(str{1}), 'solver'), cobraParamsCorrectStruct))
    % first argument in solverVarargin being empty structure
    assert(isequal(solverVarargin.(str{1}){1}, struct('Presolve', 0)))
    % all other fields the same except 'solver'
    solverVararginCur = rmfield(struct(solverVarargin.(str{1}){2:end}), 'solver');
    solverVararginCur.feasTol = feasTolCur * 2;
    if strcmp(str{1}, 'MILP')
        solverVararginCur.intTol = intTolCur * 2;
    end
    assert(isequal(solverVararginCur, cobraParamsCorrectStruct))
end

% all params in one structure (except direct input)
[funParams, cobraParams, solverVarargin] = parseCobraVarargin({'whatever', struct('Presolve', 0, 'feasTol', feasTolCur * 2, 'intTol', intTolCur * 2, 'bIn', 1e-8)}, optArgin, defaultValues, validator, problemTypes);
[aIn, aIn2, bIn] = deal(funParams{:});
assert(isequal(aIn, 'whatever') & isequal(aIn2, 'test') & isequal(bIn, 1e-8))
for str = problemTypes
    cobraParamsCorrect = [paramNames.(str{1}); paramValues.(str{1})];
    cobraParamsCorrectStruct = struct(cobraParamsCorrect{:});
    cobraParamsCorrectStruct.feasTol = feasTolCur * 2;
    if strcmp(str{1}, 'MILP')
        cobraParamsCorrectStruct.intTol = intTolCur * 2;
    end
    % all fields the same except 'solver'
    assert(isequal(rmfield(cobraParams.(str{1}), 'solver'), cobraParamsCorrectStruct))
    % first argument in solverVarargin being empty structure
    assert(isequal(solverVarargin.(str{1}){1}, struct('Presolve', 0)))
    % all other fields the same except 'solver'
    solverVararginCur = rmfield(struct(solverVarargin.(str{1}){2:end}), 'solver');
    solverVararginCur.feasTol = feasTolCur * 2;
    if strcmp(str{1}, 'MILP')
        solverVararginCur.intTol = intTolCur * 2;
    end
    assert(isequal(solverVararginCur, cobraParamsCorrectStruct))
end

% aIn is an explicit solver param input
[funParams, cobraParams, solverVarargin] = parseCobraVarargin({struct('Presolve', 0), 'aIn2correct', 'feasTol', feasTolCur * 2, 'intTol', intTolCur * 2, 'bIn', 1e-8, 'IterationLimit', 1000}, optArgin, defaultValues, validator, problemTypes, 'aIn');
assert(numel(funParams) == 2)
[aIn2, bIn] = deal(funParams{:});
assert(isequal(aIn2, 'aIn2correct') & isequal(bIn, 1e-8))
for str = problemTypes
    cobraParamsCorrect = [paramNames.(str{1}); paramValues.(str{1})];
    cobraParamsCorrectStruct = struct(cobraParamsCorrect{:});
    cobraParamsCorrectStruct.feasTol = feasTolCur * 2;
    if strcmp(str{1}, 'MILP')
        cobraParamsCorrectStruct.intTol = intTolCur * 2;
    end
    % all fields the same except 'solver'
    assert(isequal(rmfield(cobraParams.(str{1}), 'solver'), cobraParamsCorrectStruct))
    % first argument in solverVarargin being empty structure
    assert(isequal(solverVarargin.(str{1}){1}, struct('Presolve', 0, 'IterationLimit', 1000)))
    % all other fields the same except 'solver'
    solverVararginCur = rmfield(struct(solverVarargin.(str{1}){2:end}), 'solver');
    solverVararginCur.feasTol = feasTolCur * 2;
    if strcmp(str{1}, 'MILP')
        solverVararginCur.intTol = intTolCur * 2;
    end
    assert(isequal(solverVararginCur, cobraParamsCorrectStruct))
end

% aIn is an explicit solver param input and is inputted as parameter-value argument
[funParams, cobraParams, solverVarargin] = parseCobraVarargin({'aIn2', 'aIn2correct', 'feasTol', feasTolCur * 2, 'aIn', struct('Presolve', 0, 'IterationLimit', 1000), 'intTol', intTolCur * 2, 'bIn', 1e-8}, optArgin, defaultValues, validator, problemTypes, 'aIn');
assert(numel(funParams) == 2)
[aIn2, bIn] = deal(funParams{:});
assert(isequal(aIn2, 'aIn2correct') & isequal(bIn, 1e-8))
for str = problemTypes
    cobraParamsCorrect = [paramNames.(str{1}); paramValues.(str{1})];
    cobraParamsCorrectStruct = struct(cobraParamsCorrect{:});
    cobraParamsCorrectStruct.feasTol = feasTolCur * 2;
    if strcmp(str{1}, 'MILP')
        cobraParamsCorrectStruct.intTol = intTolCur * 2;
    end
    % all fields the same except 'solver'
    assert(isequal(rmfield(cobraParams.(str{1}), 'solver'), cobraParamsCorrectStruct))
    % first argument in solverVarargin being empty structure
    assert(isequal(solverVarargin.(str{1}){1}, struct('Presolve', 0, 'IterationLimit', 1000)))
    % all other fields the same except 'solver'
    solverVararginCur = rmfield(struct(solverVarargin.(str{1}){2:end}), 'solver');
    solverVararginCur.feasTol = feasTolCur * 2;
    if strcmp(str{1}, 'MILP')
        solverVararginCur.intTol = intTolCur * 2;
    end
    assert(isequal(solverVararginCur, cobraParamsCorrectStruct))
end

assert(verifyCobraFunctionError('parseCobraVarargin', 'outputArgCount', 3, ...
    'input', {{}, optArgin, defaultValues, validator, 'ABC'}, ...
    'testMessage', 'Input ABC for `ProblemTypes` not supported. Only ''LP'', ''MILP'', ''QP'' and ''MIQP'' are supported'))

% test support for interpreting empty positional inputs as default values
funParams = parseCobraVarargin({'input1value', [], 123}, optArgin, defaultValues, validator,  [], [], true);
% error if emptyForDefault flag not true
assert(isequal(funParams, {'input1value', 'test', 123}))
assert(verifyCobraFunctionError('parseCobraVarargin', 'outputArgCount', 3, ...
    'input', {{'input1value', [], 123}, optArgin, defaultValues, validator}, ...
    'testMessage', 'The value of ''aIn2'' is invalid. It must satisfy the function: ischar.'))

           
% change the directory
cd(currentDir)