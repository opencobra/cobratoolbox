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
%
%     fully supported solvers:
%
%     cplex_direct    CPLEX accessed directly through Tomlab cplex.m. This gives
%                     the user more control of solver parameters. e.g.
%                     minimising the Euclidean norm of the internal flux to
%                     get rid of net flux around loops
%     dqqMinos        DQQ solver
%     glpk            GLPK solver with Matlab mex interface (glpkmex)
%     gurobi          Gurobi solver
%     ibm_cplex       The IBM API for CPLEX using the CPLEX class
%     mosek           Mosek LP solver with Matlab API (using linprog.m from Mosek)
%     pdco            PDCO solver
%     quadMinos       quad LP solver
%     tomlab_cplex    CPLEX accessed through Tomlab environment (default)
%
%     experimental support:
%
%     opti            CLP(recommended), CSDP, DSDP, OOQP and SCIP(recommended)
%                     solver installed and called with OPTI TB wrapper
%                     Lower level calls with installed mex files are possible
%                     but best avoided for all solvers
%
%     legacy solvers:
%
%     lindo_new       Lindo API >v2.0
%     lindo_legacy    Lindo API <v2.0
%     lp_solve        lp_solve with Matlab API
%     gurobi_mex      Gurobi accessed through Matlab mex interface (Gurobi mex)
%
% Currently allowed MILP solvers:
%
%     fully supported solvers:
%
%     cplex_direct    CPLEX accessed directly through Tomlab cplex.m. This gives
%                     the user more control of solver parameters. e.g.
%                     minimising the Euclidean norm of the internal flux to
%                     get rid of net flux around loops
%     glpk            glpk MILP solver with Matlab mex interface (glpkmex)
%     gurobi          Gurobi solver
%     ibm_cplex       The IBM API for CPLEX using the CPLEX class
%     mosek           Mosek LP solver with Matlab API (using linprog.m from Mosek)
%     pdco            PDCO solver
%     tomlab_cplex    CPLEX MILP solver accessed through Tomlab environment
%
%     experimental support:
%
%     opti            CLP(recommended), CSDP, DSDP, OOQP and SCIP(recommended)
%                     solver installed and called with OPTI TB wrapper
%                     Lower level calls with installed mex files are possible
%                     but best avoided for all solvers
%
%     legacy solvers:
%
%     gurobi_mex      Gurobi accessed through Matlab mex interface (Gurobi mex)
%
% Currently allowed QP solvers:
%
%     fully supported solvers:
%
%     cplex_direct    CPLEX accessed directly through Tomlab cplex.m. This gives
%                     the user more control of solver parameters. e.g.
%                     minimising the Euclidean norm of the internal flux to
%                     get rid of net flux around loops
%     gurobi          Gurobi solver
%     ibm_cplex       The IBM API for CPLEX using the CPLEX class
%     mosek           Mosek LP solver with Matlab API (using linprog.m from Mosek)
%     pdco            PDCO solver
%     tomlab_cplex    CPLEX QP solver accessed through Tomlab environment
%
%     experimental support:
%
%     opti            CLP(recommended), CSDP, DSDP, OOQP and SCIP(recommended)
%                     solver installed and called with OPTI TB wrapper
%                     Lower level calls with installed mex files are possible
%                     but best avoided for all solvers
%     qpng            qpng QP solver with Matlab mex interface (in glpkmex
%                     package, only limited support for small problems)
%
%     legacy solvers:
%
%     gurobi_mex      Gurobi accessed through Matlab mex interface (Gurobi mex)
%
% Currently allowed MIQP solvers:
%
%     fully supported solvers:
%
%     cplex_direct    CPLEX accessed directly through Tomlab cplex.m. This gives
%                     the user more control of solver parameters. e.g.
%                     minimising the Euclidean norm of the internal flux to
%                     get rid of net flux around loops
%     gurobi          Gurobi solver
%     ibm_cplex       The IBM API for CPLEX using the CPLEX class
%     tomlab_cplex    CPLEX MIQP solver accessed through Tomlab environment
%
%     legacy solvers:
%
%     gurobi_mex      Gurobi accessed through Matlab mex interface (Gurobi mex)
%
% Currently allowed NLP solvers:
%
%     fully supported solvers:
%
%     matlab          MATLAB's fmincon.m
%
%     experimental support:
%
%     tomlab_snopt    SNOPT solver accessed through Tomlab environment
%
% It is a good idea to put this function call into your startup.m file
% (usually matlabinstall/toolboxes/local/startup.m)
%
% Original file: Markus Herrgard 1/19/07

global SOLVERS;
global OPT_PROB_TYPES;
global CBT_LP_SOLVER;
global CBT_MILP_SOLVER;
global CBT_QP_SOLVER;
global CBT_MIQP_SOLVER;
global CBT_NLP_SOLVER;
global ENV_VARS;
global TOMLAB_PATH;

if isempty(SOLVERS) || isempty(OPT_PROB_TYPES)
    ENV_VARS.printLevel = false;
    initCobraToolbox;
end

% configure the environment variables
configEnvVars();

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

% legacy support for other versions of gurobi
if strcmpi(solverName, 'gurobi') || strcmpi(solverName, 'gurobi6') ||  strcmpi(solverName, 'gurobi7')
    solverName = 'gurobi';
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
if strcmpi(solverType, 'all')
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

% if gurobi is selected, unload tomlab if tomlab is on the path
tomlabOnPath = ~isempty(strfind(lower(path), 'tomlab'));
if (~isempty(strfind(solverName, 'gurobi')) ||  ~isempty(strfind(solverName, 'ibm_cplex')) ||  ~isempty(strfind(solverName, 'matlab'))) && tomlabOnPath
    rmpath(genpath(TOMLAB_PATH));
    if printLevel > 0
        fprintf('\n > Tomlab interface removed from MATLAB path.\n');
    end
end
if ~tomlabOnPath && (~isempty(strfind(solverName, 'tomlab')) || ~isempty(strfind(solverName, 'cplex_direct')))
    addpath(genpath(TOMLAB_PATH));
    if printLevel > 0
        fprintf('\n > Tomlab interface added to MATLAB path.\n');
    end
end

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
        if ~verLessThan('matlab', '8.4')
            if printLevel > 0
                fprintf(' > The cplex_direct is incompatible with this version of MATLAB, please downgrade or change solver.\n');
            end
        else
            solverOK = checkSolverInstallationFile(solverName, 'tomRun', printLevel);
        end
    case 'ibm_cplex'
        if ~verLessThan('matlab', '9')  % 2016b
            if printLevel > 0
                fprintf(' > ibm_cplex (IBM ILOG CPLEX) is incompatible with this version of MATLAB, please downgrade or change solver.\n');
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
    case 'gurobi'
        tmpGurobi = 'gurobi.sh';
        if ispc, tmpGurobi = 'gurobi.bat'; end
        solverOK = checkGurobiInstallation(solverName, tmpGurobi, printLevel);
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
    if strcmpi(solverType, 'all')
        fprintf([' > ', varName, ' has been set to ', solverName, '.\n']);
    end
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
    if exist(fileName, 'file') == 2 || exist(fileName, 'file') == 3
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
    if ~isunix && printLevel > 0
        error('%s interface not implemented for non unix OS', solverName);
    end

    if isunix
        [status, cmdout] = system(['which ' executableName]);
        if isempty(cmdout) && printLevel > 0
            error('Solver %s is not installed. %s could not be found in your path. Check your PATH environement variable.', solverName, executableName);
        else
            solverOk = true;
        end
    end
end
