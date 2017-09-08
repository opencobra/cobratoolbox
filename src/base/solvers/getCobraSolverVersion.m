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
    global ENV_VARS
    global SOLVERS

    % save the userpath
    originalUserPath = path;

    if nargin > 2
        restoredefaultpath;
    end

    % run initCobraToolbox when not yet initialised
    if isempty(SOLVERS)
        ENV_VARS.printLevel = false;
        initCobraToolbox;
        ENV_VARS.printLevel = true;
    end

    if nargin < 3
        printLevel = 1;
    end

    if strcmp(solverName, 'ibm_cplex')
        % Set the CPLEX file path
        index = strfind(ILOG_CPLEX_PATH, 'cplex') + 4;
        rootPathSolver = ILOG_CPLEX_PATH(1:index);

        % try to set the ILOG cplex solver
        %cplexInstalled = changeCobraSolver('ibm_cplex', 'LP', printLevel);
        rootPathSolver = strrep(rootPathSolver, '~', getenv('HOME'));
        addpath(genpath(rootPathSolver));

        if exist(rootPathSolver, 'dir') == 7
            cplexInstalled = true;
        else
            cplexInstalled = false;
        end

        if cplexInstalled
            % detect the version of CPLEX
            possibleVersions = {'1262', '1263', '1270', '1271'};

            % check the version based on the presence of a precompiled MEX file
            solverVersion = 'undetermined';
            for i = 1:length(possibleVersions)
                if isunix == 1 && ismac ~= 1
                    versionLink = [rootPathSolver filesep 'matlab/x86-64_linux/cplexlink' possibleVersions{i} '.mexa64'];
                elseif ismac == 1
                    versionLink = [rootPathSolver filesep 'matlab/x86-64_osx/cplexlink' possibleVersions{i} '.mexmaci64'];
                else
                    versionLink = [rootPathSolver filesep 'matlab\x64_win64\cplexlink' possibleVersions{i} '.mexw64'];
                end

                % if the file exists, set the version
                if exist(versionLink) == 3
                    solverVersion = possibleVersions{i};
                end
            end

            if ~strcmpi(solverVersion, 'undetermined')
                fprintf([' > The CPLEX version has been determined as ' solverVersion '.\n']);
            else
                fprintf([' > CPLEX installation path: ', rootPathSolver, '\n']);
                fprintf([' > The CPLEX version is ' solverVersion '\n. Your currently installed version of CPLEX is unsupported or you have multiple versions of CPLEX in the path.']);
            end
        else
            error(['CPLEX is not installed. Please follow the installation instructions here: ', ...
                'https://opencobra.github.io/cobratoolbox/docs/solvers.html']);
        end

    elseif strcmp(solverName, 'gurobi')
        solverVersion = 'undetermined';

        index = regexp(GUROBI_PATH, solverName);
        rootPathSolver = GUROBI_PATH(1:index-1);
        beginIndex = index + length(solverName);

        tmpPath = GUROBI_PATH(beginIndex:end);
        % determine position of filesep
        endIndex = strfind(tmpPath, filesep);

        % determine solver version
        solverVersion = tmpPath(1:endIndex(1)-1);
        if ~strcmpi(solverVersion, 'undetermined')
            fprintf([' > The GUROBI version has been determined as ' solverVersion '.\n']);
        else
            fprintf([' > GUROBI installation path: ', rootPathSolver, '\n']);
            fprintf([' > The GUROBI version is ' solverVersion '\n. Your currently installed version of GUROBI is unsupported or you have multiple versions of GUROBI in the path.']);
        end

    end

    % restore the original path
    path(originalUserPath);
    addpath(originalUserPath);

end
