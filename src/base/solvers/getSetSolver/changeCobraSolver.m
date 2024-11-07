function [solverOK, solverInstalled] = changeCobraSolver(solverName, problemType, printLevel, validationLevel)
% Changes the Cobra Toolbox optimization solver(s)
%
% USAGE:
%
%    [solverOK, solverInstalled] = changeCobraSolver(solverName, problemType, printLevel, validationLevel)
%
% INPUTS:
%    solverName:           Solver name
%    problemType:          Problem type ('LP' by default)
%                          (a) One of the following: `LP` `MILP`, `QP`, `MIQP` 'EP', 'CLP'
%                          (b) 'all' attempts to change all applicable solvers to solverName.  This is purely a shorthand convenience.
%                          (c) Cell array of problemTypes, e.g. {'LP','QP'}   
%    printLevel:           verbose level
%
%                           *   if `0`, warnings and errors are silenced
%                           *   if `> 0`, warnings and errors are thrown. (default: 1)
%
% OPTIONAL INPUT:
%    validationLevel:      how much validation to use
%
%                           *   `-1`: assign only the global variable. Do not assign any path.
%                           *   `0`: adjust solver paths but don't validate the solver
%                           *   `1`: validate but remove outputs, silent  (default)
%                           *   `2`: validate and keep any outputs
%
% OUTPUT:
%     solverOK:             `true` if solver can be accessed, `false` if not
%     solverInstalled:      `true` if the solver is installed (not
%                           necessarily working)
%
% USAGE:
%    The following is an example of how to change gurobi to be the LP solver
%    [solverOK, solverInstalled] = changeCobraSolver('gurobi','LP')
%
%    If there are problems changing to a solver, use the following call to debug 
%    [solverOK, solverInstalled] = changeCobraSolver('gurobi','LP',1,1)
%
% Currently allowed LP solvers:
%
%   - fully supported solvers
%
%     ============    ============================================================
%     cplex_direct    CPLEX accessed directly through Tomlab `cplex.m`. This gives
%                     the user more control of solver parameters. e.g.
%                     minimising the Euclidean norm of the internal flux to
%                     get rid of net flux around loops
%     dqqMinos        Double Quad Quad precision solver for ill scaled prob
%     pronnb
%     glpk            GLPK solver with Matlab mex interface (glpkmex)
%     gurobi          Gurobi solver
%     ibm_cplex       The IBM API for CPLEX using the CPLEX class
%     matlab          MATLAB's linprog function
%     mosek           Mosek LP solver with Matlab API (using linprog.m from Mosek)
%     pdco            PDCO solver
%     quadMinos       quad solver
%     tomlab_cplex    CPLEX accessed through Tomlab environment (default)
%     cplexlp         CPLEX accessed through IBM matlab functions
%     ============    ============================================================
%
%   * legacy solvers:
%
%     ============    ============================================================
%     lindo_new       Lindo API > v2.0
%     lindo_legacy    Lindo API < v2.0
%     lp_solve        lp_solve with Matlab API
%     gurobi_mex      Gurobi accessed through Matlab mex interface (Gurobi mex)
%     opti            CLP(recommended), CSDP, DSDP, OOQP and SCIP(recommended)
%                     solver installed and called with OPTI TB wrapper
%                     Lower level calls with installed mex files are possible
%                     but best avoided for all solvers
%     ============    ============================================================
%
% Currently allowed MILP solvers:
%
%   * fully supported solvers:
%
%     ============    ============================================================
%     cplex_direct    CPLEX accessed directly through Tomlab cplex.m. This gives
%                     the user more control of solver parameters. e.g.
%                     minimising the Euclidean norm of the internal flux to
%                     get rid of net flux around loops
%     glpk            glpk MILP solver with Matlab mex interface (glpkmex)
%     gurobi          Gurobi solver
%     ibm_cplex       The IBM API for CPLEX using the CPLEX class
%     mosek           Mosek LP solver with Matlab API (using linprog.m from Mosek)
%     tomlab_cplex    CPLEX MILP solver accessed through Tomlab environment
%     ============    ============================================================
%
%   * legacy solvers:
%
%     ============    ============================================================
%     gurobi_mex      Gurobi accessed through Matlab mex interface (Gurobi mex)
%     opti            CLP(recommended), CSDP, DSDP, OOQP and SCIP(recommended)
%                     solver installed and called with OPTI TB wrapper
%                     Lower level calls with installed mex files are possible
%                     but best avoided for all solvers
%     ============    ============================================================
%
% Currently allowed QP solvers:
%
%   * fully supported solvers:
%
%     ============    ============================================================
%     cplex_direct    CPLEX accessed directly through Tomlab cplex.m. This gives
%                     the user more control of solver parameters. e.g.
%                     minimising the Euclidean norm of the internal flux to
%                     get rid of net flux around loops
%     gurobi          Gurobi solver
%     ibm_cplex       The IBM API for CPLEX using the CPLEX class
%     mosek           Mosek QP solver with Matlab API
%     pdco            PDCO solver
%     tomlab_cplex    CPLEX QP solver accessed through Tomlab environment
%     dqqMinos        Double Quad Quad precision solver for ill scaled prob
%     ============    ============================================================
%
%   * experimental support:
%
%     ============    ============================================================
%     qpng            qpng QP solver with Matlab mex interface (in glpkmex
%                     package, only limited support for small problems)
%     ============    ============================================================
%
%   * legacy solvers:
%
%     ============    ============================================================
%     gurobi_mex      Gurobi accessed through Matlab mex interface (Gurobi mex)
%     opti            CLP(recommended), CSDP, DSDP, OOQP and SCIP(recommended)
%                     solver installed and called with OPTI TB wrapper.
%                     Lower level calls with installed mex files are possible
%     ============    ============================================================
%
% Currently allowed MIQP solvers:
%
%   * fully supported solvers:
%
%     ============    ============================================================
%     cplex_direct    CPLEX accessed directly through Tomlab cplex.m. This gives
%                     the user more control of solver parameters. e.g.
%                     minimising the Euclidean norm of the internal flux to
%                     get rid of net flux around loops
%     gurobi          Gurobi solver
%     ibm_cplex       The IBM API for CPLEX using the CPLEX class
%     tomlab_cplex    CPLEX MIQP solver accessed through Tomlab environment
%     ============    ============================================================
%
%   * legacy solvers:
%
%     ============    ============================================================
%     gurobi_mex      Gurobi accessed through Matlab mex interface (Gurobi mex)
%     ============    ============================================================
%
% Currently allowed NLP solvers:
%
%   * fully supported solvers:
%
%     ============    ============================================================
%     matlab          MATLAB's fmincon.m
%     quadMinos       quad solver
%     ============    ============================================================
%
%   * experimental support:
%
%     ============    ============================================================
%     tomlab_snopt    SNOPT solver accessed through Tomlab environment
%     ============    ============================================================
%
% NOTE:
%
%    It is a good idea to put this function call into your `startup.m` file
%    (usually matlabinstall/toolboxes/local/startup.m)
%

if strcmp(solverName,'cplex')
    solverName='ibm_cplex';
end
global SOLVERS;
global CBTDIR;
global OPT_PROB_TYPES;
global CBT_LP_SOLVER;
global CBT_MILP_SOLVER;
global CBT_QP_SOLVER;
global CBT_EP_SOLVER;
global CBT_CLP_SOLVER;
global CBT_MIQP_SOLVER;
global CBT_NLP_SOLVER;
global ENV_VARS;
global TOMLAB_PATH;
global MOSEK_PATH;
global GUROBI_PATH;
global MINOS_PATH;
global ILOG_CPLEX_PATH;


if nargin < 3
    printLevel = 1;
end

if ~exist('unchecked' , 'var')
    unchecked = false;
end

if ~exist('validationLevel' , 'var')
    validationLevel = 1;
end

solverInstalled = true;

if validationLevel == -1
    switch problemType
        case 'LP'
            CBT_LP_SOLVER = solverName;
        case 'QP'
            CBT_QP_SOLVER = solverName;
        case 'MILP'
            CBT_MILP_SOLVER = solverName;
        case 'NLP'
            CBT_NLP_SOLVER = solverName;
        case 'MIQP'
            CBT_MIQP_SOLVER = solverName;
        case 'EP'
            CBT_EP_SOLVER = solverName;
        case 'CLP'
            CBT_CLP_SOLVER = solverName;
    end
    solverOK = NaN;
    return
end

%Now we actually change the solver, so we will set the solverInstalled to
%false (and reset it later)
solverInstalled = false;

if isempty(SOLVERS) || isempty(OPT_PROB_TYPES)
    ENV_VARS.printLevel = false;
    initCobraToolbox(false); %Don't update the toolbox automatically
    ENV_VARS.printLevel = true;
end

%Clean up, after changing the solver, this happens only if CBTDIR is
%actually set i.e. initCobraToolbox is called before. This is only
%necessary, if the solver is being validated.
if validationLevel == 2 %TODO sometimes this takes far too long, why?
    origFiles = getFilesInDir('type','ignoredByCOBRA','checkSubFolders',false); 
    finish = onCleanup(@() removeTempFiles(pwd, origFiles,'checkSubFolders',false));
end
% configure the environment variables
configEnvVars();

% Print out all solvers defined in global variables CBT_*_SOLVER
if nargin < 1
    definedSolvers = [CBT_LP_SOLVER, CBT_MILP_SOLVER, CBT_QP_SOLVER, CBT_MIQP_SOLVER, CBT_NLP_SOLVER, CBT_CLP_SOLVER, CBT_EP_SOLVER];
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
if strcmpi(solverName, 'gurobi6') || strcmpi(solverName, 'gurobi7')
    solverName = 'gurobi';
end

% check if the global environment variable is properly set
if ~ENV_VARS.STATUS

    if isempty(GUROBI_PATH) || isempty(ILOG_CPLEX_PATH) || isempty(TOMLAB_PATH) || isempty(MOSEK_PATH)
        switch solverName
            case 'gurobi'
                tmpVar = 'GUROBI_PATH';
            case {'ibm_cplex','cplexlp'}
                tmpVar = 'ILOG_CPLEX_PATH';
            case {'tomlab_cplex', 'cplex_direct'}
                tmpVar = 'TOMLAB_PATH';
            case 'mosek'
                tmpVar = 'MOSEK_PATH';
        end
        if printLevel > 0 && (strcmpi(solverName, 'gurobi') || strcmpi(solverName, 'ibm_cplex') || strcmpi(solverName, 'cplexlp') || strcmpi(solverName, 'tomlab_cplex') || strcmpi(solverName, 'cplex_direct') || strcmpi(solverName, 'mosek'))
            error(['changeCobraSolver: The global variable `', tmpVar, '` is not set. Please follow the instructions on https://opencobra.github.io/cobratoolbox/docs/solvers.html in order to set the environment variables properly.']);
        end
    end
end

% set path to MINOS and DQQ
MINOS_PATH = [CBTDIR filesep 'binary' filesep computer('arch') filesep 'bin' filesep 'minos'];

% legacy support for MPS (will be removed in future release)
if nargin > 0 && strcmpi(solverName, 'mps')
    fprintf(' > changeCobraSolver: The interface to ''mps'' from ''changeCobraSolver()'' is no longer supported.\n');
    error(' -> Use >> writeCbModel(model, \''mps\''); instead.)');
end

if nargin < 2
    problemType = 'LP';
else
    problemType = upper(problemType);
end

% print an error message if the solver is not supported
supportedSolversNames = fieldnames(SOLVERS);
if ~any(strcmp(supportedSolversNames, solverName))
    error('changeCobraSolver: The solver %s is not available to the COBRA Toolbox on your machine. Please run >> initCobraToolbox to obtain a table with available solvers.', solverName);
else
    %If we don't validate the solver, at which point it could be, that it is not yet set up,
    % we can actually just check whether it
    %is installed according to the solver field, and if not return false.
    if validationLevel == 0
        if ~SOLVERS.(solverName).installed
            if printLevel > 0
                fprintf([' > changeCobraSolver: Solver ', solverName, ' is not installed.\n']);
            end
            solverInstalled = SOLVERS.(solverName).installed;
            solverOK = false;
            return
        end
        if ~SOLVERS.(solverName).working
            if printLevel > 0
                fprintf([' > changeCobraSolver: Solver ', solverName, ' is installed but not working properly.\n']);
            end
            solverInstalled = SOLVERS.(solverName).installed;
            solverOK = false;
            return
        end
    end
end

% Attempt to set the user provided solver for all optimization problem types
if strcmpi(problemType, 'all')
    solvedProblems = SOLVERS.(solverName).type;
    for i = 1:length(solvedProblems)
        %this looks to be self referential (calling changeCobraSolver in
        %changeCobraSolver)
        [solverOK,solverInstalled] = changeCobraSolver(solverName, solvedProblems{i}, printLevel,validationLevel);
        if printLevel > 0
            fprintf([' > changeCobraSolver: Solver for ', solvedProblems{i}, ' problems has been set to ', solverName, '.\n']);
        end
    end
    notsupportedProblems = setdiff(OPT_PROB_TYPES,solvedProblems);
    for i = 1:length(notsupportedProblems)
        solverUsed = eval(['CBT_' notsupportedProblems{i} '_SOLVER']);
        if isempty(solverUsed)
            infoString = 'No solver set for this problemtype';
        else
            infoString = sprintf('Currently used: %s',solverUsed);
        end
        if printLevel > 0
            fprintf(' > changeCobraSolver: Solver %s not supported for problems of type %s. %s \n', solverName, notsupportedProblems{i},infoString);
        end
    end
    return
end

% check if the given solver is able to solve the given problem type.
solverOK = false;
if ~contains(problemType, OPT_PROB_TYPES)
    %This is not done during init, so at this point, the solver is already
    %checked for installation
    solverInstalled = SOLVERS.(solverName).installed;
    if printLevel > 0
        error('changeCobraSolver: %s  problems cannot be solved in The COBRA Toolbox', problemType);
    else
        return
    end
end

% check if the given solver is able to solve the given problem type.
if ~contains(problemType, SOLVERS.(solverName).type)
    %This is not done during init, so at this point, the solver is already
    %checked for installation
    solverInstalled = SOLVERS.(solverName).installed;
    if printLevel > 0
        error('Solver %s cannot solve %s problems', solverName, problemType);
    else
        return
    end
end

% add the solver path for GUROBI, MOSEK or CPLEX
if contains(solverName, 'tomlab_cplex') || contains(solverName, 'cplex_direct') && ~isempty(TOMLAB_PATH)
    TOMLAB_PATH = strrep(TOMLAB_PATH, '~', getenv('HOME'));
    installDir = strrep(TOMLAB_PATH, '\\', '\');
    addSolverDir(installDir, printLevel, 'Tomlab', 'TOMLAB_PATH', TOMLAB_PATH, true);
end

% add the matlab path (in case someone had the great idea to overwrite the MATLAB path).
if contains(solverName, 'matlab')
    FMINCON_PATH = [matlabroot filesep 'toolbox' filesep 'shared' filesep 'optimlib'];
    addSolverDir(FMINCON_PATH, printLevel, 'matlab', 'FMINCON_PATH', FMINCON_PATH, true);
    LINPROG_PATH = [matlabroot filesep 'toolbox' filesep 'optim' ];
    addSolverDir(LINPROG_PATH, printLevel, 'matlab', 'LINPROG_PATH', LINPROG_PATH, true);
end

% add the pdco submodule path (especially important if TOMLAB_PATH is set)
if contains(solverName, 'pdco')
    PDCO_PATH = [CBTDIR filesep 'external' filesep 'base' filesep 'solvers' filesep 'pdco'];
    addSolverDir(PDCO_PATH, printLevel, 'pdco', 'PDCO_PATH', PDCO_PATH, true);
end

if  contains(solverName, 'gurobi') && ~isempty(GUROBI_PATH)
    % add the solver path
    GUROBI_PATH = strrep(GUROBI_PATH, '~', getenv('HOME'));
    installDir = strrep(GUROBI_PATH, '\\', '\');
    addSolverDir(installDir, printLevel, 'Gurobi', 'GUROBI_PATH', GUROBI_PATH, false);
end

if  contains(solverName, 'ibm_cplex') && ~isempty(ILOG_CPLEX_PATH)
    % add the solver path
    ILOG_CPLEX_PATH = strrep(ILOG_CPLEX_PATH, '~', getenv('HOME'));
    installDir = strrep(ILOG_CPLEX_PATH, '\\', '\');
   %addSolverDir(installDir, printLevel, capsName, varName, globaVarPath, subFolders)
    addSolverDir(installDir, printLevel, 'IBM ILOG CPLEX', 'ILOG_CPLEX_PATH', ILOG_CPLEX_PATH, false);
end

if  strcmp(solverName, 'cplexlp') && ~isempty(ILOG_CPLEX_PATH)
    % add the solver path
    ILOG_CPLEX_PATH = strrep(ILOG_CPLEX_PATH, '~', getenv('HOME'));
    installDir = strrep(ILOG_CPLEX_PATH, '\\', '\');
    addSolverDir(installDir, printLevel, 'IBM ILOG CPLEX', 'ILOG_CPLEX_PATH', ILOG_CPLEX_PATH, false);
end

if  contains(solverName, 'mosek') && ~isempty(MOSEK_PATH)
    MOSEK_PATH = strrep(MOSEK_PATH, '~', getenv('HOME'));
    installDir = strrep(MOSEK_PATH, '\\', '\');
    addSolverDir(installDir, printLevel, 'MOSEK', 'MOSEK_PATH', MOSEK_PATH, true);
end

solverOK = false;

if 0
    % TODO: UPDATE docs/source/installation/compatMatrix.rst
    % compatibleStatus determine the compatibility status
    compatibleStatus = isCompatible(solverName, printLevel);
else
    %skip this as it is a pain to maintain compatibility matrix.
    compatibleStatus = 2;

end
% * 0: not compatible with the COBRA Toolbox (tested)
% * 1: compatible with the COBRA Toolbox (tested)
% * 2: unverified compatibility with the COBRA Toolbox (not tested)
if compatibleStatus == 1 || compatibleStatus == 2
    switch solverName
        case {'lindo_old', 'lindo_legacy'}
            solverOK = checkSolverInstallationFile(solverName, 'mxlindo', printLevel);
        case 'glpk'
            solverOK = checkSolverInstallationFile(solverName, 'glpkmex', printLevel);
        case 'mosek'
            solverOK = checkSolverInstallationFile(solverName, 'mosekopt', printLevel);
        case {'tomlab_cplex', 'tomlab_snopt', 'cplex_direct'}
            solverOK = checkSolverInstallationFile(solverName, 'tomRun', printLevel);
        case {'ibm_cplex','cplexlp'}
            if isempty(which('Cplex'))
                warning('Cplex is not on the MATLAB path. Complete the installation as specified here: https://opencobra.github.io/cobratoolbox/stable/installation.html#ibm-ilog-cplex')
                solverOK = false;
            end
            try
                prob.f = 1;
                prob.Aineq = 1;
                prob.bineq = 10;
                prob.ub    = 5;
                cplex = Cplex(prob);
                ILOGcplex = Cplex('fba');  % Initialize the CPLEX object
                solverOK = true;
            catch ME
                fprintf('%s\n',['changeCobraSolver: problem initialising CPLEX object: ' ME.message ])
                solverOK = false;
            end
            matver=split(version,'.');
            matver=str2double(strcat(char(matver(1)),'.',char(matver(2))));
            if matver < 8.6
                warning('off', 'MATLAB:lang:badlyScopedReturnValue');  % take out warning message
            end
        case {'lp_solve', 'qpng', 'pdco', 'gurobi_mex'}
            solverOK = checkSolverInstallationFile(solverName, solverName, printLevel);
        case 'gurobi'
            solverOK = checkSolverInstallationFile(solverName, 'gurobi.m', printLevel);
        case {'quadMinos', 'dqqMinos'}
            [stat, res] = system('which csh');
            if ~isempty(res) && stat == 0
                if strcmp(solverName, 'dqqMinos')
                    solverOK = checkSolverInstallationFile(solverName, 'run1DQQ', printLevel);
                elseif strcmp(solverName, 'quadMinos')
                    solverOK = checkSolverInstallationFile(solverName, 'minos', printLevel);
                end
            else
                solverOK = false;
                if printLevel > 0
                    error(['changeCobraSolver: You must have `csh` installed in order to use `', solverName, '`.']);
                end
            end
        %{
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
        %}
        case 'matlab'
            v = ver;
            %Both linprog and fmincon are part of the optimization toolbox.
            solverOK = any(strcmp('Optimization Toolbox', {v.Name})) && license('test','Optimization_Toolbox');
        otherwise
            error(['changeCobraSolver: Solver ' solverName ' not supported by The COBRA Toolbox.']);
    end
end

% set solver related global variables (only for actively maintained solver interfaces)
if solverOK
    if 1 %set to 1 to debug a new solver
        if strcmp(solverName,'mosek')
            pause(0.1);
        end
    end
    solverInstalled = true;
    if validationLevel > 0
        cwarn = warning;
        warning('off');
        eval(['oldval = CBT_', problemType, '_SOLVER;']);
        eval(['CBT_', problemType, '_SOLVER = solverName;']);
        % validate with a simple problem.
        if strcmp(solverName,'mosek') && strcmp(problemType,'CLP') || strcmp(problemType,'all')
            problem = struct('A',[0 1],'b',0,'c',[1;1],'osense',-1,'lb',[0;0],'ub',[0;0],'csense','E','vartype',['C';'I'],'x0',[0;0],'names',[]);  
        else
            problem = struct('A',[0 1],'b',0,'c',[1;1],'osense',-1,'F',speye(2),'lb',[0;0],'ub',[0;0],'csense','E','vartype',['C';'I'],'x0',[0;0],'names',[]);
        end
        try
            % Skip the CLP solver until further developments
            if ~strcmp(problemType, 'CLP')
                %This is the code that actually tests if a solver is working
                if validationLevel>1
                    %display progress
                    eval(['solveCobra' problemType '(problem,''printLevel'',3);']);
                else
                    eval(['solveCobra' problemType '(problem,''printLevel'',0);']);
                end
            end
        catch ME
            %This is the code that describes what went wrong if a call to a solver does not work           
            if printLevel > 0
                fprintf(2,'The identifier was:\n%s',ME.identifier);
                fprintf(2,'There was an error! The message was:\n%s',ME.message);
                disp(ME.message);
                rethrow(ME)
            end
            solverOK = false;
            eval(['CBT_', problemType, '_SOLVER = oldval;']);
        end
        warning(cwarn)
    else
        % if unvalidated, simply set the solver without testing.
        eval(['CBT_', problemType, '_SOLVER = solverName;']);
    end
else
    switch solverName
        case 'gurobi'
            fprintf('%s\n',['Gurobi installed at this location? ' getenv('GUROBI_HOME')])
            fprintf('%s\n',['Licence file current? ' getenv('GRB_LICENSE_FILE')])
        otherwise
            fprintf('%s\n',['Could not find installation of ' solverName ', so it cannot be tested'])
    end
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
    if exist(fileName, 'file') >= 2
        solverOK = true;
    elseif printLevel > 0
        error(['changeCobraSolver: Solver ', solverName, ' is not installed. Please follow ', hyperlink('https://opencobra.github.io/cobratoolbox/docs/solvers.html', 'these instructions', 'the instructions on '), ' in order to install the solver properly.'])
    end
end

function addSolverDir(installDir, printLevel, capsName, varName, globaVarPath, subFolders)
% Adds the solver installation path to the MATLAB path:
% Usage:
%     addSolverDir(installDir, printLevel, capsName, varName, globaVarPath, subFolders)
%
% Inputs:
%     installDir:     Solver installation directory
%     printLevel:     Verbose level
%     capsName:       Name of solver in capital letters
%     varName:        Name of global variable associated with the solver path
%     globaVarPath:   Name of the path variable associated with the solver path
%     subFolders:     Boolean to add the subfolders
%

    if exist(installDir, 'dir')
        % add the solver installation folder
        if subFolders
            addpath(genpath(installDir));
        else
            addpath(installDir);
        end

        % print out a status message
        if printLevel > 0
            fprintf(['\n > changeCobraSolver: ', capsName, ' interface added to MATLAB path.\n']);
        end
    else
        % print out a warning message
        if printLevel > 0
            warning([' > changeCobraSolver: The directory defined in ', varName, ' (', globaVarPath, ') does not exist.']);
        end
    end
end
