% The COBRAToolbox: testChangeCobraSolver.m
%
% Purpose:
%     - testChangeCobraSolver tests the changeCobraSolver function
%     - Two collaborators of the function are replaced by stubs from a temporary folder for one
%       section each, because the branches they feed depend on the machine, not on a solver:
%       initCobraToolbox (which would rebuild the whole toolbox path) and configEnvVars (which
%       finds a solver path on any machine that has a solver). No solver is replaced.
%     - The MATLAB path, the solver state, the warning state and the path globals are restored at
%       the end, whatever happens in the sections.
%
% Function under test:
%     src/base/solvers/getSetSolver/changeCobraSolver.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - no model; the solver is validated on the toy problem of the function.
%
% Coverage exemptions:
%     Lines 252-265: defective input skipped, a call without input stops at line 174 (defect below).
%     Lines 389-391: tomlab_cplex branch, solver not available, and TOMLAB's gurobi.m shadows Gurobi's.
%     Line 441: unreachable, the branch of an if 0.
%     Line 453: unreachable, lindo_old and lindo_legacy are not in SOLVERS and are refused at line 311.
%     Lines 471-472: ibm_cplex branch, the Cplex class is not available.
%     Line 480: unreachable, needs a MATLAB older than 8.6 and the baseline is R2024b.
%     Lines 489-492: dqqMinos and quadMinos branch, needs csh, which is not available.
%     Line 517: unreachable, every name in SOLVERS has a case in the switch.
%     Line 525: mosek branch, solver not available.
%     Line 536: mosek branch for CLP problems, solver not available.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A call without input stops instead of listing the defined solvers
%       SEVERITY: error
%       TRIGGER: changeCobraSolver() without input
%       OBSERVED: line 174 reads solverName before any input check, so the call stops with Not
%         enough input arguments and the listing of the defined solvers can never run
%       EXPECTED: the list of the solvers defined in CBT_*_SOLVER
%       LINES: 174, 252-265
%     - DEFECT: A failed validation with printLevel above 0 keeps the failed solver selected
%       SEVERITY: wrong-result
%       TRIGGER: a solver that fails the validation solve, with printLevel above 0, for example
%         changeCobraSolver('pdco', 'MILP')
%       OBSERVED: the error is rethrown before the old solver and the warning state are restored,
%         so the failed solver stays selected and warnings stay off
%       EXPECTED: the selection and the warning state of before the call, as with printLevel 0
%       LINES: 530-531, 553-558
%     - DEFECT: The problem type is matched as a substring
%       SEVERITY: wrong-result
%       TRIGGER: a problem type that contains the name of a type of the solver, for example
%         pdco with MILP
%       OBSERVED: contains accepts MILP for a solver of LP problems, so the solver reaches the
%         validation solve and the call stops there, with a message from the solver interface
%       EXPECTED: the message that the solver cannot solve the problem type, as at line 381
%       LINES: 364, 376
%
% Authors:
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.


% define global paths
global SOLVERS;
global OPT_PROB_TYPES;

% save the current path
currentDir = pwd;

% initialize the test
fprintf(' -- Running testChangeCobraSolver: ... \n');
fileDir = fileparts(which('testChangeCobraSolver'));
cd(fileDir);

% require an LP solver; skip gracefully if none is available
prepareTest('needsLP', true);

% everything the function changes is restored at the end of this test
global ENV_VARS GUROBI_PATH
origState = CobraSolverState.get();
origPath = path;
origWarning = warning;
origSolvers = SOLVERS;
origEnvVars = ENV_VARS;
origGurobiPath = GUROBI_PATH;

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

sectionError = [];
stubDir = tempname;
mkdir(stubDir);
try
    %% validationLevel -1 sets the global of the problem type without any check
    for typeCell = {'LP', 'QP', 'MILP', 'NLP', 'MIQP', 'EP', 'CLP'}
        [ok, installed] = changeCobraSolver('anyName', typeCell{1}, 0, -1);
        assert(isnan(ok) && installed);
        assert(strcmp(CobraSolverState.getSolver(typeCell{1}), 'anyName'));
    end
    CobraSolverState.restore(origState);

    %% validationLevel 0 relies on the table of solvers: selected without a test solve
    [ok, installed] = changeCobraSolver('pdco', 'LP', 0, 0);
    assert(ok && installed);
    assert(strcmp(CobraSolverState.getSolver('LP'), 'pdco'));

    % a solver that the table marks as not installed, or as not working
    SOLVERS.pdco.installed = false;
    [ok, installed] = changeCobraSolver('pdco', 'LP', 0, 0);
    assert(~ok && ~installed);
    printedText = evalc('[ok, installed] = changeCobraSolver(''pdco'', ''LP'', 1, 0);');
    assert(~ok && ~installed && contains(printedText, 'is not installed'));
    SOLVERS.pdco.installed = true;
    SOLVERS.pdco.working = false;
    [ok, installed] = changeCobraSolver('pdco', 'LP', 0, 0);
    assert(~ok && installed);
    printedText = evalc('[ok, installed] = changeCobraSolver(''pdco'', ''LP'', 1, 0);');
    assert(~ok && installed && contains(printedText, 'installed but not working'));
    SOLVERS = origSolvers;

    %% the alias cplex is the solver ibm_cplex
    [ok, installed] = changeCobraSolver('cplex', 'LP', 0, 0);
    assert(ok == (SOLVERS.ibm_cplex.installed && SOLVERS.ibm_cplex.working));
    assert(installed == SOLVERS.ibm_cplex.installed);

    %% a problem type that does not exist
    [ok, installed] = changeCobraSolver('pdco', 'XYZ', 0);
    assert(~ok && installed);
    assert(verifyCobraFunctionError('changeCobraSolver', 'inputs', {'pdco', 'XYZ', 1}, ...
        'testMessage', 'changeCobraSolver: XYZ  problems cannot be solved in The COBRA Toolbox'));

    %% a problem type that the solver cannot solve
    [ok, installed] = changeCobraSolver('glpk', 'QP', 0);
    assert(~ok && installed == SOLVERS.glpk.installed);
    assert(verifyCobraFunctionError('changeCobraSolver', 'inputs', {'glpk', 'QP', 1}, ...
        'testMessage', 'Solver glpk cannot solve QP problems'));

    %% a validation solve that fails: the previous solver stays selected
    % pdco reaches the validation solve for MILP because of the defect above
    changeCobraSolver('glpk', 'MILP', 0, 0);
    [ok, installed] = changeCobraSolver('pdco', 'MILP', 0);
    assert(~ok && installed);
    assert(strcmp(CobraSolverState.getSolver('MILP'), 'glpk'));

    %% validated selection with each available solver
    assert(changeCobraSolver('glpk', 'MILP', 0));
    assert(strcmp(CobraSolverState.getSolver('MILP'), 'glpk'));
    if SOLVERS.gurobi.working
        assert(changeCobraSolver('gurobi', 'LP', 0));
        assert(strcmp(CobraSolverState.getSolver('LP'), 'gurobi'));

        % the names of old gurobi interfaces select gurobi
        changeCobraSolver('pdco', 'LP', 0, 0);
        assert(changeCobraSolver('gurobi6', 'LP', 0));
        assert(strcmp(CobraSolverState.getSolver('LP'), 'gurobi'));
        changeCobraSolver('pdco', 'LP', 0, 0);
        assert(changeCobraSolver('gurobi7', 'LP', 0));
        assert(strcmp(CobraSolverState.getSolver('LP'), 'gurobi'));
    end
    path(origPath);

    %% the solvers that are not usable here report false, like the table of solvers
    for solverCell = {'ibm_cplex', 'cplexlp', 'mosek'}
        solverWorks = SOLVERS.(solverCell{1}).working;
        [ok, installed] = changeCobraSolver(solverCell{1}, 'LP', 0);
        assert(ok == solverWorks && installed == SOLVERS.(solverCell{1}).installed);
        path(origPath);
    end
    if ~SOLVERS.tomlab_snopt.working
        printedText = evalc('ok = changeCobraSolver(''tomlab_snopt'', ''NLP'', 0);');
        assert(~ok && contains(printedText, 'Could not find installation of tomlab_snopt'));
    end

    %% dqqMinos and quadMinos need csh
    [cshStatus, cshPath] = system('which csh');
    if cshStatus ~= 0 || isempty(cshPath)
        for solverCell = {'dqqMinos', 'quadMinos'}
            assert(~changeCobraSolver(solverCell{1}, 'LP', 0));
            assert(verifyCobraFunctionError('changeCobraSolver', 'inputs', {solverCell{1}, 'LP', 1}, ...
                'testMessage', ['changeCobraSolver: You must have `csh` installed in order to use `' solverCell{1} '`.']));
        end
    end

    %% gurobi without its folder on the path: the location is reported
    gurobiFiles = which('gurobi.m', '-all');
    if ~isempty(gurobiFiles)
        cellfun(@(gurobiFile) rmpath(fileparts(gurobiFile)), gurobiFiles);
        GUROBI_PATH = '';
        printedText = evalc('ok = changeCobraSolver(''gurobi'', ''LP'', 0);');
        assert(~ok && contains(printedText, 'Gurobi installed at this location?'));
        assert(contains(printedText, 'Licence file current?'));
        threw = false;
        try
            changeCobraSolver('gurobi', 'LP', 1);
        catch ME
            threw = true;
            assert(contains(ME.message, 'changeCobraSolver: Solver gurobi is not installed.'));
        end
        assert(threw);
        GUROBI_PATH = origGurobiPath;
        path(origPath);
    end

    %% validationLevel 2 shows the progress of the solve and removes temporary files
    % temporary files are looked for in the current folder, hence the empty folder
    validationDir = fullfile(stubDir, 'validation');
    mkdir(validationDir);
    cd(validationDir);
    [ok, installed] = changeCobraSolver('pdco', 'LP', 0, 2);
    cd(fileDir);
    assert(ok && installed);

    %% SOLVERS not yet set: the toolbox is initialised (stubbed, it would rebuild the path)
    global SOLVERS_FOR_INIT_STUB
    SOLVERS_FOR_INIT_STUB = origSolvers;
    writeStub(stubDir, 'initCobraToolbox', ...
        {'function initCobraToolbox(~)', 'global SOLVERS SOLVERS_FOR_INIT_STUB', 'SOLVERS = SOLVERS_FOR_INIT_STUB;', 'end'});
    addpath(stubDir);
    rehash;
    SOLVERS = [];
    [ok, installed] = changeCobraSolver('pdco', 'LP', 0, 0);
    assert(ok && installed && isequal(SOLVERS, origSolvers));
    assert(ENV_VARS.printLevel == true);
    clear global SOLVERS_FOR_INIT_STUB
    delete(fullfile(stubDir, 'initCobraToolbox.m'));

    %% no environment variable found: the path global of the solver is named in the error
    % configEnvVars is stubbed as it would find a path on any machine that has a solver
    global ILOG_CPLEX_PATH TOMLAB_PATH MOSEK_PATH
    savedPaths = {ILOG_CPLEX_PATH, TOMLAB_PATH, MOSEK_PATH};
    writeStub(stubDir, 'configEnvVars', {'function configEnvVars(~)', 'end'});
    rehash;
    ENV_VARS.STATUS = 0;
    GUROBI_PATH = [];
    expectedPathVariable = {'gurobi', 'GUROBI_PATH'; 'ibm_cplex', 'ILOG_CPLEX_PATH'; ...
        'cplexlp', 'ILOG_CPLEX_PATH'; 'tomlab_cplex', 'TOMLAB_PATH'; ...
        'cplex_direct', 'TOMLAB_PATH'; 'mosek', 'MOSEK_PATH'};
    for i = 1:size(expectedPathVariable, 1)
        assert(verifyCobraFunctionError('changeCobraSolver', 'inputs', {expectedPathVariable{i, 1}, 'LP', 1}, ...
            'testMessage', ['changeCobraSolver: The global variable `' expectedPathVariable{i, 2} ...
            '` is not set. Please follow the instructions on https://opencobra.github.io/cobratoolbox/docs/solvers.html in order to set the environment variables properly.']));
    end
    [ILOG_CPLEX_PATH, TOMLAB_PATH, MOSEK_PATH] = deal(savedPaths{:});
catch sectionError
end

% restore the session: nothing above may leak into the tests that follow
cd(fileDir);
SOLVERS = origSolvers;
ENV_VARS = origEnvVars;
GUROBI_PATH = origGurobiPath;
path(origPath);
warning(origWarning);
CobraSolverState.restore(origState);
rmdir(stubDir, 's');
clear initCobraToolbox configEnvVars
rehash;
if ~isempty(sectionError)
    rethrow(sectionError);
end

% output a success message
fprintf('Done.\n');

% change back to the old directory
cd(currentDir);

function writeStub(stubDir, functionName, codeLines)
% Writes a replacement of a toolbox function into the folder stubDir.
    fid = fopen(fullfile(stubDir, [functionName '.m']), 'w');
    fprintf(fid, '%s\n', codeLines{:});
    fclose(fid);
end
