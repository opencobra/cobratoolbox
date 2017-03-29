function solverOK = changeCobraSolver(solverName, solverType, printLevel)
% changeCobraSolver Changes the Cobra Toolbox optimization solver(s)
%
% USAGE:
%     solverOK = changeCobraSolver(solverName,solverType)
%
% INPUTS:
%     solverName    Solver name
%     solverType    Solver type, 'LP', 'MILP', 'QP', 'MIQP' (opt, default
%                   'LP', 'all').  'all' attempts to change all applicable
%                   solvers to solverName.  This is purely a shorthand
%                   convenience.
%     printLevel    if 0, warnings and errors are silenced and if > 0, they are
%                   thrown. (default: 1)
%
% OUTPUT:
%     solverOK      true if solver can be accessed, false if not
%
% Currently allowed LP solvers:
%     lindo_new       Lindo API >v2.0
%     lindo_legacy       Lindo API <v2.0
%     glpk            GLPK solver with Matlab mex interface (glpkmex)
%     lp_solve        lp_solve with Matlab API
%     tomlab_cplex    CPLEX accessed through Tomlab environment (default)
%     cplex_direct    CPLEX accessed direct to Tomlab cplex.m. This gives
%                     the user more control of solver parameters. e.g.
%                     minimising the Euclidean norm of the internal flux to
%                     get rid of net flux around loops
%     mosek           Mosek LP solver with Matlab API (using linprog.m included in Mosek
%                     package)
%     gurobi_mex          Gurobi accessed through Matlab mex interface (Gurobi mex)
%     gurobi5         Gurobi 5.0 accessed through built-in Matlab mex interface
%     gurobi6         Gurobi 6.*  accessed through built-in Matlab mex interface
%     gurobi7         Gurobi 7.*  accessed through built-in Matlab mex interface
%     ibm_cplex       The IBM API for CPLEX using the CPLEX class
%     opti            CLP(recommended), CSDP, DSDP, OOQP and SCIP(recommended)
%                     solver installed and called with OPTI TB wrapper
%                     Lower level calls with installed mex files are possible
%                     but best avoided for all solvers
%
% Currently allowed MILP solvers:
%     tomlab_cplex    CPLEX MILP solver accessed through Tomlab environment
%     glpk            glpk MILP solver with Matlab mex interface (glpkmex)
%     gurobi          Gurobi accessed through Matlab mex interface (Gurobi mex)
%     gurobi5         Gurobi 5.0 accessed through built-in Matlab mex interface
%     gurobi6         Gurobi 6.* accessed through built-in Matlab mex interface
%     gurobi7         Gurobi 7.* accessed through built-in Matlab mex interface
%     ibm_cplex       The IBM API for CPLEX using the CPLEX class
%
% Currently allowed QP solvers:
%     tomlab_cplex    CPLEX QP solver accessed through Tomlab environment
%     qpng            qpng QP solver with Matlab mex interface (in glpkmex
%                     package, only limited support for small problems)
%     gurobi5         Gurobi 5.0 accessed through built-in Matlab mex interface
%     gurobi6         Gurobi 6.* accessed through built-in Matlab mex interface
%     gurobi7         Gurobi 7.* accessed through built-in Matlab mex interface
%
% Currently allowed MIQP solvers:
%     tomlab_cplex    CPLEX MIQP solver accessed through Tomlab environment
%     gurobi5         Gurobi 5.0 accessed through built-in Matlab mex interface
%     gurobi6         Gurobi 6.* accessed through built-in Matlab mex interface
%     gurobi7         Gurobi 7.* accessed through built-in Matlab mex interface
%
% Currently allowed NLP solvers
%     matlab          MATLAB's fmincon.m
%     tomlab_snopt    SNOPT solver accessed through Tomlab environment
%
% It is a good idea to put this function call into your startup.m file
% (usually matlabinstall/toolboxes/local/startup.m)
% Markus Herrgard 1/19/07

global SOLVERS;
global OPT_PROB_TYPES;
global CBT_LP_SOLVER;
global CBT_MILP_SOLVER;
global CBT_QP_SOLVER;
global CBT_MIQP_SOLVER;
global CBT_NLP_SOLVER;

if isempty(SOLVERS) || isempty(OPT_PROB_TYPES)
    initCobraToolbox;
end

% configure the environment variables
configEnvVars()

% Print out all solvers defined in global variables CBT_*_SOLVER
if nargin < 1
    definedSolvers = [CBT_LP_SOLVER, CBT_MILP_SOLVER, CBT_QP_SOLVER, CBT_MIQP_SOLVER, CBT_NLP_SOLVER];
    if isempty(definedSolvers)
        fprintf('No solvers are defined!\n');
    else
        fprintf('Defined solvers are:\n');
        for i = 1:length(OPT_PROB_TYPES)
            varName = horzcat(['CBT_', OPT_PROB_TYPES{i}, '_SOLVER']);
            if ~isempty(eval(varName))
                fprintf('    %s: %s\n', varName, eval(varName));
            end
        end
    end
    return;
end


if nargin < 2
    solverType = 'LP';
else
    solverType = upper(solverType);
end

if nargin < 3
    printLevel = 1;
end

% Attempt to set the user provided solver for all optimization problem types
if (strcmp(solverType, 'ALL'))
    for i = 1:length(OPT_PROB_TYPES)
        changeCobraSolver(solverName, OPT_PROB_TYPES{i}, 0);
    end
    return
end

% check if the given solver is able to solve the given problem type.
solverOK = false;
if isempty(strmatch(solverType, OPT_PROB_TYPES))
    if printLevel > 0
        error('%s problems cannot be solved in The COBRA Toolbox', solverType);
    else
        return
    end
end

% check if the given solver is able to solve the given problem type.
if isempty(strmatch(solverType, SOLVERS.(solverName).type))
    if printLevel > 0
        error('Solver %s cannot solve %s problems', solverName, solverType);
    else
        return
    end
end

solverOK = false;

switch solverName
    case {'lindo_old', 'lindo_legacy'}
        solverOK = checkSolverInstallationFile(solverName, 'mxlindo', printLevel);
    case 'glpk'
        solverOK = checkSolverInstallationFile(solverName, 'glpkmex', printLevel);
    case 'mosek'
        solverOK = checkSolverInstallationFile(solverName, 'mosekopt', printLevel);
    case {'tomlab_cplex', 'tomlab_snopt'}
        solverOK = checkSolverInstallationFile(solverName, 'tomRun', printLevel);
    case 'cplex_direct'
        solverOK = checkSolverInstallationFile(solverName, 'tomRun', printLevel);
    case 'ibm_cplex'
        if ~verLessThan('matlab', '9')  % 2016b
            if printLevel > 0
                fprintf('IBM ILOG CPLEX is incompatible with this version of MATLAB, please downgrade or change solver\n');
            end
        else
            try
                ILOGcplex = Cplex('fba');  % Initialize the CPLEX object
                solverOK = true;
            catch ME
                solverOK = false;
            end
        end
        if verLessThan('matlab', '9') && ~verLessThan('matlab', '8.6')  % >2015b
            warning('off', 'MATLAB:lang:badlyScopedReturnValue');  % take out warning message
        end
    case 'lp_solve'
        solverOK = checkSolverInstallationFile(solverName, 'lp_solve', printLevel);
    case 'qpng'
        solverOK = checkSolverInstallationFile(solverName, 'qpng', printLevel);
    case 'pdco'
        solverOK = checkSolverInstallationFile(solverName, 'pdco', printLevel);
    case 'gurobi_mex'
        solverOK = checkSolverInstallationFile(solverName, 'gurobi_mex', printLevel);
    case {'gurobi5', 'gurobi6', 'gurobi7'}
        solverOK = checkGurobiInstallation(solverName, 'gurobi.m', printLevel);
    case 'mps'
        solverOK = checkSolverInstallationFile(solverName, 'BuildMPS', printLevel);
    case 'quadMinos'
        solverOK = checkSolverInstallationExecutable(solverName, 'minos', true, printLevel);
    case 'dqqMinos'
        solverOK = checkSolverInstallationExecutable(solverName, 'run1DQQ', true, printLevel);
    case 'opti'
        optiSolvers = {'CLP', 'CSDP', 'DSDP', 'OOQP', 'SCIP'};
        if ~isempty(which('checkSolver'))
            availableSolvers = cellfun(@(x)checkSolver(lower(x)), optiSolvers);
            fprintf('OPTI solvers installed currently: ');
            fprintf(char(allLPsolvers(logical(availableSolvers))));
            if ~any(logical(availableSolvers))
                return;
            end
        end
    case 'matlab'
        solverOK = true;
    otherwise
        error(['Solver ' solverName ' not supported by COBRA Toolbox']);
end

% set solver related global variables
if solverOK
    varName = horzcat(['CBT_', solverType, '_SOLVER']);
    eval([varName ' =  solverName;']);
end

end


function solverOK = checkGurobiInstallation(solverName, fileName, printLevel)
% Check Gurobi installation.
%
% Usage:
%     solverOK = checkGurobiInstallation(solverName, fileName)
%
% Inputs:
%     solverName: string with the name of the solver
%     fileName:   string with the name of the file to look for
%
% Output:
%     solverOK: true if filename exists, false otherwise.
%

    global GUROBI_PATH
    solverOK = false;
    if ~isempty(findstr(GUROBI_PATH, solverName))
        if exist(fileName) == 2
            solverOK = true;
        elseif printLevel > 0
            error('Solver %s is not installed!', solverName)
        end
    elseif printLevel > 0
        error('Solver %s is not installed!', solverName)
    end
end


function solverOK = checkSolverInstallationFile(solverName, fileName, printLevel)
% Check solver installation by existence of a file in the Matlab path.
%
% Usage:
%     solverOK = checkSolverInstallation(solverName, fileName)
%
% Inputs:
%     solverName: string with the name of the solver
%     fileName:   string with the name of the file to look for
%
% Output:
%     solverOK: true if filename exists, false otherwise.
%
    solverOK = false;
    if exist(fileName, 'file') == 2
        solverOK = true;
    elseif printLevel > 0
        error('Solver %s is not installed!', solverName)
    end
end


function solverOK = checkSolverInstallationExecutable(solverName, executableName, unix, printLevel)
% Check Gurobi installation.
%
% Usage:
%     solverOK = checkGurobiInstallation(solverName, fileName)
%
% Inputs:
%     solverName: string with the name of the solver
%     executableName:   string with the name of the executable to look for
%     unix:
%
% Output:
%     solverOK: true if executableName exists, false otherwise.
%
    solverOK = false;
    if unix
        if ~isunix && printLevel > 0
            error('%s interface not implemented for non unix OS', solverName);
        end
    end
    [status, cmdout] = system(['which ' executableName]);
    if isempty(cmdout) && printLevel > 0
        error('Solver %s is not installed. %s could not be found in your path. Check your PATH environement variable.', solverName, executableName);
    else
        solverOk = true;
    end
end
