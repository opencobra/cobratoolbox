% The COBRAToolbox: testGetCobraSolverParams.m
%
% Purpose:
%     - getCobraSolverParams(problemType, paramNames, paramStructure) returns the values of
%       the solver parameters named in paramNames, taken with the documented priority
%       "paramStructure > solver type paramStructure (the global solver settings made with
%       changeCobraSolverParams, held by CobraSolverState) > default values set within this
%       script", and, when paramStructure is given, a final structure output in which the
%       fields named in paramNames are set to the returned values. paramStructure 'default'
%       asks for the values set within the script only. The test sets the global settings by
%       hand, checks every calling form against the values written in the source (built-in
%       defaults) or set by the test, and restores the solver state at the end.
%
% Function under test:
%     src/base/solvers/param/getCobraSolverParams.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; the global solver settings are set by hand
%     (changeCobraSolverParams / CobraSolverState) and restored.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found. (The three defects recorded on 2026-11-13, the global settings ignored by
%     the two-input form, 'default' returning the global settings, and the help describing the
%     structure output the wrong way round, were fixed by feature
%     20261120-161825-core-blocker-fixes and are tested below.)
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-13.
%     - Full test after the fix (feature 20261120-161825-core-blocker-fixes), 2026-11-20.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetCobraSolverParams'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the global solver settings are changed below: save the whole solver state and the global
% variables that exist now, to restore them at the end
globalsBefore = who('global');
solverStateBefore = CobraSolverState.get();

% built-in defaults written in the source (valDef): feasTol 1e-6, printLevel 0, intTol 1e-12
builtInFeasTol = 1e-6;

%% two inputs, no global setting: the built-in default; no structure output

feasTol = getCobraSolverParams('LP', 'feasTol');
assert(isequal(feasTol, builtInFeasTol));
% the number of outputs is the number of names: asking for a structure as well is an error
assert(verifyCobraFunctionError('getCobraSolverParams', 'inputs', {'LP', 'feasTol'}, 'outputArgCount', 2));

%% two inputs with a global setting: the global setting wins over the built-in default

changeCobraSolverParams('LP', 'feasTol', 1e-9);
assert(isequal(getCobraSolverParams('LP', 'feasTol'), 1e-9));
% a name given as a cell, several names, and a name without a global setting (printLevel)
[feasTol, printLevel] = getCobraSolverParams('LP', {'feasTol', 'printLevel'});
assert(isequal(feasTol, 1e-9) && isequal(printLevel, 0));
% a setting of another problem type does not apply
assert(isequal(getCobraSolverParams('MILP', 'feasTol'), builtInFeasTol));

%% paramStructure 'default': the built-in defaults, ignoring the global setting, and a structure

[feasTol, paramStructureOut] = getCobraSolverParams('LP', 'feasTol', 'default');
assert(isequal(feasTol, builtInFeasTol));
assert(isequal(paramStructureOut, struct('feasTol', builtInFeasTol)));
% with no names, the structure holds the built-in value of every LP parameter that has one
defaultStructure = getCobraSolverParams('LP', [], 'default');
assert(isstruct(defaultStructure) && isequal(defaultStructure.feasTol, builtInFeasTol) ...
    && isequal(defaultStructure.printLevel, 0));

%% a parameter structure: structure > global setting > built-in default

paramStructure = struct('optTol', 1e-3, 'other', 5);
[feasTol, optTol, printLevel, paramStructureOut] = getCobraSolverParams('LP', ...
    {'feasTol', 'optTol', 'printLevel'}, paramStructure);
% feasTol from the global setting, optTol from the structure, printLevel built in
assert(isequal([feasTol, optTol, printLevel], [1e-9, 1e-3, 0]));
% the structure output is the given structure with the named fields set to the returned values
assert(isequal(paramStructureOut, struct('optTol', 1e-3, 'other', 5, 'feasTol', 1e-9, 'printLevel', 0)));
% a value in the structure wins over the global setting
assert(isequal(getCobraSolverParams('LP', 'feasTol', struct('feasTol', 1e-4)), 1e-4));
% a name the function does not know is empty, unless the structure gives it
[unknownValue, paramStructureOut] = getCobraSolverParams('LP', 'unknownName', struct());
assert(isempty(unknownValue) && isequal(paramStructureOut, struct()));
assert(isequal(getCobraSolverParams('LP', 'unknownName', struct('unknownName', 7)), 7));

%% a text other than 'default' as paramStructure: the global settings, and a structure

[feasTol, paramStructureOut] = getCobraSolverParams('LP', 'feasTol', 'other');
assert(isequal(feasTol, 1e-9) && isequal(paramStructureOut, struct('feasTol', 1e-9)));

%% every problem type has its built-in defaults

problemTypes = {'LP', 'QP', 'MILP', 'EP', 'CLP', 'MIQP', 'NLP'};
for k = 1:numel(problemTypes)
    [feasTol, intTol, problemType] = getCobraSolverParams(problemTypes{k}, ...
        {'feasTol', 'intTol', 'problemType'}, 'default');
    assert(isequal(feasTol, builtInFeasTol) && isequal(intTol, 1e-12) ...
        && strcmp(problemType, problemTypes{k}));
end
% the exponential-cone and conic types name mosek as their solver
assert(strcmp(getCobraSolverParams('EP', 'solver', 'default'), 'mosek'));
assert(strcmp(getCobraSolverParams('CLP', 'solver', 'default'), 'mosek'));

%% an unrecognised problem type prints a message and returns no value

% the message ("Unrecognized solver type") is printed; asking for a value is an error
getCobraSolverParams('XY', 'feasTol');
assert(verifyCobraFunctionError('getCobraSolverParams', 'inputs', {'XY', 'feasTol'}, 'outputArgCount', 1));

%% restore the solver state and remove the global variables created here

CobraSolverState.restore(solverStateBefore);
newGlobals = setdiff(who('global'), globalsBefore);
for k = 1:numel(newGlobals)
    clearvars('-global', newGlobals{k});
end

% change the directory
cd(currentDir)
