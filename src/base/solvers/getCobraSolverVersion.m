function solverVersion = getCobraSolverVersion(solverName, rootPathSolver, printLevel)
% detects the version of given COBRA solver
%
% USAGE:
%    solverVersion = getCobraSolverVersion(solverName, rootPathSolver, printLevel)
%
% INPUT:
%    solverName:        Name of the solver
%    rootPathSolver:    Path to the CPLEX installation
%    printLevel:        verbose level (default: 0)
%
% OUTPUT:
%    solverVersion:     string that contains the version number
%
% .. Author: - Laurent Heirendt, June 2017
%

    global ILOG_CPLEX_PATH
    global GUROBI_PATH
    global MOSEK_PATH
    global TOMLAB_PATH
    global ENV_VARS
    global SOLVERS

    % run initCobraToolbox when not yet initialised
    if isempty(SOLVERS)
        ENV_VARS.printLevel = false;
        initCobraToolbox;
        ENV_VARS.printLevel = true;
    end

    if nargin < 2
        rootPathSolver = '';
    end

    if nargin < 3
        printLevel = 1;
    end

    solverStatus = eval(['SOLVERS.' solverName '.installed;']);

    % define solver specific patterns
    switch solverName
        case 'ibm_cplex'
            solverPath = ILOG_CPLEX_PATH;
            pattern = 'CPLEX_Studio';
            aliasName = 'CPLEX';
        case 'gurobi'
            solverPath = GUROBI_PATH;
            pattern = 'gurobi';
            aliasName = 'GUROBI';
        case 'mosek'
            solverPath = MOSEK_PATH;
            pattern = 'Mosek';
            aliasName = 'MOSEK';
        case 'tomlab_cplex'
            solverPath = TOMLAB_PATH;
            pattern = 'tomlab_cplex';
            aliasName = 'TOMLAB';
        otherwise
    end

    if solverStatus
        % retrieve the version number
        if strcmp(pattern, 'tomlab_cplex')
            % save the original user path
            originalUserPath = path;

            % add the tomlab path
            addpath(genpath(TOMLAB_PATH));
            tmpV = ver('tomlab');

            % reset the path
            restoredefaultpath;
            addpath(originalUserPath);

            % replace the version dot
            solverVersion = strrep(tmpV.Version, '.', '');
            rootPathSolver = solverPath;
        else
            try
                [solverVersion, rootPathSolver] = extractVersionNumber(solverPath, pattern);
            catch
                solverVersion = 'undetermined';
                rootPathSolver = '';
            end
        end

        if printLevel > 0
            if ~strcmpi(solverVersion, 'undetermined')
                fprintf([' > The ' aliasName ' version has been determined as ' solverVersion '.\n']);
            else
                fprintf([' > ' aliasName ' installation path: ', rootPathSolver, '\n']);
                fprintf([' > The ' aliasName ' version is ' solverVersion '\n. Your currently installed version of ' aliasName ' is unsupported or you have multiple versions of ' aliasName ' in the path.']);
            end
        end
    else
        error([aliasName ' is not installed. Please follow the installation instructions here: https://opencobra.github.io/cobratoolbox/docs/solvers.html']);
    end

end

function [solverVersion, rootPathSolver] = extractVersionNumber(globalVar, pattern)
% extract the version number based on the path of the solver
    index = regexp(lower(globalVar), lower(pattern));
    rootPathSolver = globalVar(1:index-1);
    beginIndex = index + length(pattern);

    tmpPath = globalVar(beginIndex:end);

    % determine position of filesep
    endIndex = strfind(tmpPath, filesep);

    % determine solver version
    solverVersion = tmpPath(1:endIndex(1)-1);

    % if the solver version is still empty, try the second index
    if isempty(solverVersion)
        solverVersion = tmpPath(2:endIndex(2)-1);
    end
end