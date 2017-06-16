function cplexVersion = getCPLEXversion(rootPathCPLEX, printLevel)
% detects the CPLEX version
%
% USAGE:
%    cplexVersion = getCPLEXversion(rootPathCPLEX, printLevel)
%
% INPUT:
%    rootPathCPLEX:     Path to the CPLEX installation
%    printLevel:        verbose level (default: 0)
%
% OUTPUT:
%    cplexVersion:      string that contains the CPLEX version number
%
% .. Author: - Laurent Heirendt, June 2017
%

    global ILOG_CPLEX_PATH
    global ENV_VARS
    global SOLVERS

    % save the userpath
    originalUserPath = path;

    if nargin > 1
        restoredefaultpath;
    end

    % run initCobraToolbox when not yet initialised
    if isempty(SOLVERS)
        ENV_VARS.printLevel = false;
        initCobraToolbox;
        ENV_VARS.printLevel = true;
    end

    % Set the CPLEX file path
    index = strfind(ILOG_CPLEX_PATH, 'cplex') + 4;
    rootPathCPLEX = ILOG_CPLEX_PATH(1:index);

    if nargin < 2
        printLevel = 1;
    end

    % try to set the ILOG cplex solver
    %cplexInstalled = changeCobraSolver('ibm_cplex', 'LP', printLevel);
    rootPathCPLEX = strrep(rootPathCPLEX, '~', getenv('HOME'));
    addpath(genpath(rootPathCPLEX));

    if exist(rootPathCPLEX, 'dir') == 7
        cplexInstalled = true;
    else
        cplexInstalled = false;
    end

    if cplexInstalled
        % detect the version of CPLEX
        possibleVersions = {'1262', '1263', '1270', '1271'};

        % check the version based on the presence of a precompiled MEX file
        cplexVersion = 'undetermined';
        for i = 1:length(possibleVersions)
            if isunix == 1 && ismac ~= 1
                versionLink = [rootPathCPLEX filesep 'matlab/x86-64_linux/cplexlink' possibleVersions{i} '.mexa64'];
            elseif ismac == 1
                versionLink = [rootPathCPLEX filesep 'matlab/x86-64_osx/cplexlink' possibleVersions{i} '.mexmaci64'];
            else
                versionLink = [rootPathCPLEX filesep 'matlab\x64_win64\cplexlink' possibleVersions{i} '.mexw64'];
            end

            % if the file exists, set the version
            if exist(versionLink) == 3
                cplexVersion = possibleVersions{i};
            end
        end

        if ~strcmpi(cplexVersion, 'undetermined')
            fprintf([' > The CPLEX version has been determined as ' cplexVersion '.\n']);
        else
            fprintf([' > CPLEX installation path: ', rootPathCPLEX, '\n']);
            fprintf([' > The CPLEX version is ' cplexVersion '\n. Your currently installed version of CPLEX is unsupported or you have multiple versions of CPLEX in the path.']);
        end
    else
        error('CPLEX is not installed. Please follow the installation instructions here:');
    end

    % restore the original path
    path(originalUserPath);
    addpath(originalUserPath);

end
