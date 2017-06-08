function cplexVersion = detectCPLEXversion(CPLEXpath, printLevel)
% detects the CPLEX version
%
% USAGE:
%    cplexVersion = detectCPLEXversion(printLevel)
%
% INPUT:
%    CPLEXpath:     Path to the CPLEX installation
%    printLevel:    verbose level (default: 0)
%
% OUTPUT:
%    cplexVersion:  string that contains the CPLEX version number
%
% .. Author: - Laurent Heirendt, June 2017
%

    if nargin < 1
        global ILOG_CPLEX_PATH
        global ENV_VARS
        global SOLVERS

        % run initCobraToolbox when not yet initialised
        if isempty(SOLVERS)
            ENV_VARS.printLevel = false;
            initCobraToolbox;
            ENV_VARS.printLevel = true;
        end

        % Set the CPLEX file path
        index = strfind(ILOG_CPLEX_PATH, 'cplex') + 4;
        CPLEXpath = ILOG_CPLEX_PATH(1:index);
    end

    if nargin < 2
        printLevel = 1;
    end

    % try to set the ILOG cplex solver
    cplexInstalled = changeCobraSolver('ibm_cplex');

    if cplexInstalled
        % detect the version of CPLEX
        possibleVersions = {'1262', '1263', '127', '1271'};

        % check the version based on the presence of a precompiled MEX file
        cplexVersion = 'undetermined';
        for i = 1:length(possibleVersions)
            if isunix == 1 && ismac ~= 1
                versionLink = [CPLEXpath '/matlab/x86-64_linux/cplexlink' possibleVersions{i} '.mexa64'];
            elseif ismac == 1
                versionLink = [CPLEXpath '/matlab/x86-64_osx/cplexlink' possibleVersions{i} '.mexmaci64'];
            else
                versionLink = [CPLEXpath '\matlab\x64_win64\cplexlink' possibleVersions{i} '.mexw64'];
            end

            % if the file exists, set the version
            if exist(versionLink) == 3
                cplexVersion = possibleVersions{i};
            end
        end

        if ~strcmpi(cplexVersion, 'undetermined')
            fprintf([' > The CPLEX version has been determined as ' cplexVersion '.\n']);
        else
            fprintf([' > CPLEX installation path: ', ILOG_CPLEX_PATH, '\n']);
            fprintf([' > The CPLEX version is ' cplexVersion '\n. Your currently installed version of CPLEX is unsupported.']);
        end
    else
        error('CPLEX is not installed. Please follow the installation instructions here:');
    end
end
