function solverVersion = getCobraSolverVersion(solverName, printLevel, rootPathSolver)
% detects the version of given COBRA solver
%
% USAGE:
%    solverVersion = getCobraSolverVersion(solverName, printLevel, rootPathSolver)
%
% INPUT:
%    solverName:        Name of the solver
%    printLevel:        verbose level (default: 0)
%    rootPathSolver:    Path to the solver installation
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
        initCobraToolbox(false); %Don't update the toolbox automatically
        ENV_VARS.printLevel = true;
    end

    % define a default printLevel (verbose)
    if nargin < 2
        printLevel = 1;
    end

    % define an empty rootPathSolver when not defined
    if nargin < 3
        rootPathSolver = '';
    end

    % define solver specific patterns
    switch solverName
        case 'ibm_cplex'
            solverPath = ILOG_CPLEX_PATH;
            solverNamePattern = 'CPLEX_Studio';
            solverNameAlias = 'CPLEX';
        case 'gurobi'
            solverPath = GUROBI_PATH;
            solverNamePattern = 'gurobi';
            solverNameAlias = 'GUROBI';
        case 'mosek'
            solverPath = MOSEK_PATH;
            solverNamePattern = 'Mosek';
            solverNameAlias = 'MOSEK';
        case {'tomlab_cplex', 'tomlab_snopt', 'cplex_direct'}
            solverPath = TOMLAB_PATH;
            solverNamePattern = 'tomlab_cplex';
            solverNameAlias = 'TOMLAB';
        otherwise
            solverPath = '';
            solverVersion = '';
            solverNameAlias = upper(solverName);
            %error(['The solver version detection for the solver ' solverName ' is not yet implemented.']);
    end

    if ~isempty(solverPath)
        % retrieve the version number
        if strcmp(solverNamePattern, 'tomlab_cplex')
            % save the original user path
            originalUserPath = path;

            % add the tomlab path
            addpath(genpath(TOMLAB_PATH));
            tmpV = ver('tomlab');
            % Remove it again.
            rmpath(genpath(TOMLAB_PATH))
            
            %And potentially readd it if it was on the path.
            addpath(originalUserPath);

            % replace the version dot
            if ~isempty(tmpV)
                solverVersion = strrep(tmpV.Version, '.', '');
            else
                solverVersion = '';
            end
            rootPathSolver = solverPath;
        else
            try
                [solverVersion, rootPathSolver] = extractVersionNumber(solverPath, solverNamePattern);
            catch
                solverVersion = 'undetermined';
                rootPathSolver = '';
            end
        end

        if printLevel > 0
            if ~strcmpi(solverVersion, 'undetermined')
                fprintf([' > The version of ' solverNameAlias ' is ' solverVersion '.\n']);
            else
                fprintf([' > ' solverNameAlias ' installation path: ', rootPathSolver, '\n']);
                fprintf([' > The ' solverNameAlias ' version is ' solverVersion '\n. Your currently installed version of ' solverNameAlias ' is unsupported or you have multiple versions of ' solverNameAlias ' in the path.\n']);
            end
        end
    else
        solverVersion = '';
        if printLevel > 0
            fprintf([' > The exact version of ' solverNameAlias ' could not be determined\n']);
        end
    end

end

function [solverVersion, rootPathSolver] = extractVersionNumber(globalVar, solverNamePattern)
% extract the version number based on the path of the solver

    index = regexp(lower(globalVar), lower(solverNamePattern));
    rootPathSolver = globalVar(1:index-1);
    beginIndex = index + length(solverNamePattern);

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
