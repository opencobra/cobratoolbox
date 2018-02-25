function [] = configEnvVars(printLevel)
% Configures the global variables based on the system's configuration
% First, all environment variables for each solver are defined together
% with all eventual solver paths.
% Then, there will be 4 methods marked that can be used to define the global
% variables:
%
%   - 1: solver is on the path and at a standard location (`*---`)
%   - 2: solver is on path but at a non-standard location (`-*--`)
%   - 3: solver path is defined through environment variables (`--*-`)
%   - 4: solver is not already on the path and the environment variable is not set, but the standard directory exists (`---*`)
%
% If none of these 4 methods applies, the global solver path variable is not set and an appropriate message is returned
%
% USAGE:
%
%    configEnvVars(printLevel)
%
% INPUT:
%    printLevel:    default = 0, verbose level
%

    global ENV_VARS
    global GUROBI_PATH
    global ILOG_CPLEX_PATH
    global TOMLAB_PATH
    global MOSEK_PATH

    if nargin < 1
        printLevel = 0;
    end

    if exist('ENV_VARS.STATUS', 'var') == 1 || ENV_VARS.STATUS == 0

        % initialize global variables
        GUROBI_PATH = []; ILOG_CPLEX_PATH = []; TOMLAB_PATH = []; MOSEK_PATH = [];

        % define default locations of the root installation folder
        defaultLocationsUNIX = {'/Applications/', ...
                                '~/Applications/', ...
                                '/opt/', ...
                                '~/', ...
                                '/private/var/root/', ...
                                '/Library/', ...
                                '~/Library/'
                               };
        defaultLocationsPC = {'C:\', ...
                              'D:\', ...
                              'E:\', ...
                              'Z:\', ...
                              'C:\Program Files\', ...
                              'C:\Program Files (x86)\', ...
                              'C:\solvers\', ...
                              'D:\solvers\'
                             };

        % define default locations based on operating system
        if ispc
            defaultLocations = defaultLocationsPC;
        else
            defaultLocations = defaultLocationsUNIX;
        end

        % structure for storing solver information
        % {*, 1}: environment variable of solver installation folder location
        % {*, 2}: array of possible arrays based on alias and version number
        % {*, 3}: alias or pattern
        % {*, 4}: locations of the root installation folder
        solverPaths = {};

        % IBM ILOG CPLEX (k = 1)
        solverPaths{1, 1} = {'ILOG_CPLEX_PATH'};
        solverPaths{1, 2} = {};
        solverPaths{1, 3} = 'CPLEX_Studio'; % alias
        solverPaths{1, 4} = defaultLocations;

        % GUROBI (k = 2)
        solverPaths{2, 1} = {'GUROBI_PATH', 'GUROBI_HOME'};
        solverPaths{2, 2} = {};
        solverPaths{2, 3} = 'gurobi'; % alias
        solverPaths{2, 4} = defaultLocations;

        % TOMLAB (k = 3)
        solverPaths{3, 1} = {'TOMLAB_PATH'};
        solverPaths{3, 2} = {};
        solverPaths{3, 3} = 'tomlab'; % alias
        solverPaths{3, 4} = defaultLocations;

        % MOSEK (k = 4)
        solverPaths{4, 1} = {'MOSEK_PATH'};
        solverPaths{4, 2} = {};
        solverPaths{4, 3} = 'mosek'; % alias
        solverPaths{4, 4} = defaultLocations;

        % loop through the solvers
        for k = 1:length(solverPaths)

            % define the method identification label
            method = '----';

            for j = 1:length(solverPaths{k, 1})
                % temporary variable for aliases of solver defined environment variables
                tmpEnvVar = solverPaths{k, 1}(j);
                tmpEnvVar = tmpEnvVar{1};

                % global variable (1st name defined)
                globEnvVar = solverPaths{k, 1}(1);
                globEnvVar = globEnvVar{1};

                % loop through the list of possible directories
                possibleDir = '';

                % list here the contents of the possible directory and find a regular expression
                folderPattern = solverPaths{k, 3};
                folderNameVect = solverPaths{k, 4};

                % define additional subfolders for IBM ILOG CPLEX and MOSEK
                if k == 1 || k == 4

                    % initialize and empty cell for storing folder names
                    tmpFolderNameVect = {};

                    % retrieve the length of the current cell of folders
                    len = length(folderNameVect);

                    % define additional subfolders
                    if k == 1 % IBM ILOG CPLEX
                        tmpFolderNameVect(end+1:end+len) = strcat(folderNameVect, ['IBM' filesep 'ilog' filesep]);
                        tmpFolderNameVect(end+1:end+len) = strcat(folderNameVect, ['IBM' filesep 'ILOG' filesep]);
                        tmpFolderNameVect(end+1:end+len) = strcat(folderNameVect, ['ibm' filesep 'ilog' filesep]);
                        tmpFolderNameVect(end+1:end+len) = strcat(folderNameVect, ['ibm' filesep 'ILOG' filesep]);
                        tmpFolderNameVect(end+1:end+len) = strcat(folderNameVect);
                    end
                    if k == 4 % MOSEK
                        tmpFolderNameVect(end+1:end+len) = strcat(folderNameVect, ['mosek' filesep]);
                        tmpFolderNameVect(end+1:end+len) = strcat(folderNameVect, ['Mosek' filesep]);
                        folderPattern = '';
                    end

                    % set the new folderNameVect
                    folderNameVect = tmpFolderNameVect;
                end

                % loop through all possible locations
                for jj = 1:length(folderNameVect)
                    folderName = folderNameVect(jj);
                    folderName = folderName{1};

                    % read the directory at the specified default location
                    tempD = dir(folderName);
                    tmpFileNameVect = {tempD.name};

                    % loop through all the folders
                    for ii = 1:length(tmpFileNameVect)
                        % save a temporary directory name
                        tmpFileName = tmpFileNameVect(ii);

                        % define all folders that match folderPattern1234
                        if k == 3
                            extraRE = '';
                        else
                            extraRE = '[0-9]+';
                        end
                        idCell = regexp(tmpFileName, ['(', folderPattern, ')', extraRE]);

                        for kk = 1:length(idCell)
                            if ~isempty(idCell{kk})
                                tmpFolderName = [folderName, tmpFileName{1}];
                                solverPaths{k, 2} = [solverPaths{k, 2}; tmpFolderName];
                            end
                        end
                    end
                end

                % store the array of possible solver paths
                tmpSolverPath = solverPaths{k, 2};

                % loop through the possible directories of installed solvers
                % start from the last one with the highest version number (most recent version)
                for i = length(solverPaths{k, 2}):-1:1
                    if exist(tmpSolverPath{i}, 'dir') == 7
                        subDir = filesep;

                        % generate solver sub-directories for IBM ILOG CPLEX and gurobi
                        if k == 1 || k == 2
                            subDir = generateSolverSubDirectory(solverPaths{k, 3});
                        end
                        possibleDir = [tmpSolverPath{i}, subDir];
                        break;
                    end
                end

                % Method 1: check if the solver is already on the MATLAB path
                isOnPath = ~isempty(strfind(lower(path), lower(possibleDir)));

                % find the index of the most recently added solver path
                tmp = path;
                if isunix
                    tmpS = strsplit(tmp, ':');
                else
                    tmpS = strsplit(tmp, ';');
                end

                % build reqular expression to check for the solver
                extraRE = '';
                if k == 2  % gurobi
                    extraRE = '\w'; % any word, alphanumeric and underscore
                end

                idCell = regexp(tmpS, ['/(', solverPaths{k, 3}, ')', extraRE, '+']);
                higherLevelIndex = 0;
                for i = 1:length(idCell)
                    if ~isempty(idCell{i})
                        higherLevelIndex = i;
                        break;
                    end
                end

                % Method 2: solver is on the path and at a standard location
                if isOnPath
                    eval([globEnvVar, ' = ''', possibleDir, ''';']);
                    method = '*---';

                % Method 3: solver is on path but at a non-standard location and may not be compatible
                elseif higherLevelIndex > 0 && higherLevelIndex < length(idCell)
                    eval([globEnvVar, ' = ''', tmpS{higherLevelIndex}, ''';']);
                    method = '-*--';
                end

                % Method 4: solver path is defined through environment variables
                if isempty(eval(globEnvVar))
                    eval([globEnvVar, ' = getenv(''', tmpEnvVar, ''');'])
                    if ~isempty(eval(globEnvVar))
                        method = '--*-';
                        subDir = filesep;
                        if k == 1 || k == 2
                            subDir = generateSolverSubDirectory(solverPaths{k, 3});
                        end
                        eval([globEnvVar, ' = [', globEnvVar, ', ''', subDir, '''];']);
                    end
                end

                % solver is not already on the path and the environment variable is not set, but the standard directory exists
                if isempty(eval(globEnvVar)) && ~isempty(possibleDir)
                    eval([globEnvVar, ' = ''', possibleDir, ''';']);
                    method = '---*';
                end

                if j == 1 % only print out for global variable name
                    % if the solver variable is still empty, then give instructions on how to proceed
                    if isempty(eval(globEnvVar))
                        if printLevel > 0
                            solversLink = hyperlink('https://opencobra.github.io/cobratoolbox/docs/solvers.html', 'instructions');
                            fprintf(['   - [', method, '] ', globEnvVar, ': --> set this path manually after installing the solver ( see ', solversLink, ' )\n']);
                        end
                    else
                        if printLevel > 0
                            fprintf(['   - [', method, '] ', globEnvVar, ': ', strrep(eval(globEnvVar), '\', '\\'), '\n']);
                        end
                        ENV_VARS.STATUS = 1;
                    end
                end
            end
        end
    end
end

function subDir = generateSolverSubDirectory(solverName)
% Define the subdirectory path of the solver to be included
%
% USAGE:
%     subDir = generateSolverSubDirectory(solverName)
%
% INPUT:
%     solverName:     string with the name of the solver (or alias)
%
% OUTPUT:
%     subDir:         path to the subdirectory of the solver
%

    subDir = '';

    % GUROBI path
    if ~isempty(strfind(solverName, 'gurobi'))
        if ispc
            osPath = 'win64';
        elseif ismac
            osPath = 'mac64';
        else
            osPath = 'linux64';
        end

        % check for 64-bit
        if ~isempty(strfind(computer('arch'), '64'))
            subDir = [filesep, osPath, filesep, 'matlab'];
        end
    end

    % ILOG CPLEX path
    if ~isempty(strfind(solverName, 'ibm_cplex')) || ~isempty(strfind(solverName, 'CPLEX_Studio'))
        if ispc
            osPath = 'x64_win64';
        elseif ismac
            osPath = 'x86-64_osx';
        else
            osPath = 'x86-64_linux';
        end

        % check for 64-bit
        if ~isempty(strfind(computer('arch'), '64'))
            subDir = [filesep, 'cplex', filesep, 'matlab', filesep, osPath];
        end
    end
end
