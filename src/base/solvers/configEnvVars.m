function configEnvVars(printLevel)
% Configures the global variables based on the system's configuration
%
% USAGE:
%
%    configEnvVars(printLevel)
%
% INPUT:
%    printLevel:    default = 0, verbose level

    global GUROBI_PATH;
    global ILOG_CPLEX_PATH;
    global TOMLAB_PATH;
    global MOSEK_PATH;
    global ENV_VARS;

    if nargin < 1
        printLevel = 0;
    end

    if exist('ENV_VARS.STATUS', 'var') == 1 || ENV_VARS.STATUS == 0
        solverPaths = {};
        solverPaths{1, 1} = {'ILOG_CPLEX_PATH'};
        solverPaths{1, 2} = {'/Applications/IBM/ILOG/CPLEX_Studio1271', ...
                             '/Applications/IBM/ILOG/CPLEX_Studio127', ...
                             '/Applications/IBM/ILOG/CPLEX_Studio1263', ...
                             '/Applications/IBM/ILOG/CPLEX_Studio1262', ...
                             '~/Applications/IBM/ILOG/CPLEX_Studio1271', ...
                             '~/Applications/IBM/ILOG/CPLEX_Studio127', ...
                             '~/Applications/IBM/ILOG/CPLEX_Studio1263', ...
                             '~/Applications/IBM/ILOG/CPLEX_Studio1262', ...
                             '/opt/ibm/ILOG/CPLEX_Studio1271' ...
                             '/opt/ibm/ILOG/CPLEX_Studio127', ...
                             '/opt/ibm/ILOG/CPLEX_Studio1263', ...
                             '/opt/ibm/ILOG/CPLEX_Studio1262', ...
                             'C:\Program Files\IBM\ILOG\CPLEX_Studio1271', ...
                             'C:\Program Files\IBM\ILOG\CPLEX_Studio127', ...
                             'C:\Program Files\IBM\ILOG\CPLEX_Studio1263', ...
                             'C:\Program Files\IBM\ILOG\CPLEX_Studio1262'};
        solverPaths{1, 3} = 'CPLEX_Studio'; % alias
        solverPaths{2, 1} = {'GUROBI_PATH', 'GUROBI_HOME'};
        solverPaths{2, 2} = {'/Library/gurobi702', ...
                             '/Library/gurobi701', ...
                             '/Library/gurobi700', ...
                             '/Library/gurobi70', ...
                             '/Library/gurobi650', ...
                             '/Library/gurobi600', ...
                             '~/Library/gurobi702', ...
                             '~/Library/gurobi701', ...
                             '~/Library/gurobi700', ...
                             '~/Library/gurobi70', ...
                             '~/Library/gurobi650', ...
                             '~/Library/gurobi600', ...
                             '/opt/gurobi702', ...
                             '/opt/gurobi701', ...
                             '/opt/gurobi700', ...
                             '/opt/gurobi70', ...
                             '/opt/gurobi650', ...
                             '/opt/gurobi600', ...
                             'C:\gurobi702', ...
                             'C:\gurobi701', ...
                             'C:\gurobi700', ...
                             'C:\gurobi70', ...
                             'C:\gurobi650', ...
                             'C:\gurobi600'};
        solverPaths{2, 3} = 'gurobi'; % alias
        solverPaths{3, 1} = {'TOMLAB_PATH'};
        solverPaths{3, 2} = {'/opt/tomlab', 'C:\tomlab', 'C:\Program Files\tomlab', 'C:\Program Files (x86)\tomlab', '/Applications/tomlab'};
        solverPaths{3, 3} = 'tomlab'; % alias
        solverPaths{4, 1} = {'MOSEK_PATH'};
        solverPaths{4, 2} = {'/opt/mosek/8', '/opt/mosek/7', '/Applications/mosek/8', '/Applications/mosek/7', 'C:\Program Files\Mosek\8', 'C:\Program Files\Mosek\7'};
        solverPaths{4, 3} = 'mosek'; % alias

        isOnPath = false;

        for k = 1:length(solverPaths)

            method = '----';

            for j = 1:length(solverPaths{k, 1})
                % temporary variable for aliases of solver defined environment variables
                tmpEnvVar = solverPaths{k, 1}(j);
                tmpEnvVar = tmpEnvVar{1};

                % global variable
                globEnvVar = solverPaths{k, 1}(1);
                globEnvVar = globEnvVar{1};

                % try retrieving the solver path from the environment variables
                eval([globEnvVar, ' = getenv(''', tmpEnvVar, ''');'])
                if ~isempty(eval(globEnvVar))
                    method = '*---';
                    subDir = filesep;
                    if k == 1 || k == 2
                        subDir = generateSolverSubDirectory(solverPaths{k, 3});
                    end
                    eval([globEnvVar, ' = [', globEnvVar, ', ''', subDir, '''];']);
                end

                % loop through the list of possible directories
                possibleDir = '';
                tmpSolverPath = solverPaths{k, 2};
                for i = 1:length(solverPaths{k, 2})
                    if exist(tmpSolverPath{i}, 'dir') == 7
                        subDir = filesep;
                        if k == 1 || k == 2
                            subDir = generateSolverSubDirectory(solverPaths{k, 3});
                        end
                        possibleDir = [tmpSolverPath{i}, subDir];
                        break;
                    end;
                end

                if isempty(eval(globEnvVar))
                    % check if the solver is already on the MATLAB path
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

                    % solver is on the path and at a standard location
                    if isOnPath
                        eval([globEnvVar, ' = ''', possibleDir, ''';']);
                        method = '-*--';

                    % solver is on path but at a non-standard location and may not be compatible
                    elseif higherLevelIndex > 0 && higherLevelIndex < length(idCell)
                        eval([globEnvVar, ' = ''', tmpS{higherLevelIndex}, ''';']);
                        method = '--*-';
                    end
                end

                % solver is not already on the path and the environment variable is not set, but the directory exists
                if isempty(eval(globEnvVar))
                    if ~isempty(possibleDir)
                        eval([globEnvVar, ' = ''', possibleDir, ''';']);
                        method = '---*';
                    end
                end

                if j == 1 % only print out for global variable name
                    % if the solver variable is still empty, then give instructions on how to proceed
                    if isempty(eval(globEnvVar))
                        if printLevel > 0
                            solversLink = 'https://opencobra.github.io/cobratoolbox/docs/solvers.html';
                            if usejava('desktop')
                                solversLink = ['<a href=\"', solversLink, '\">instructions</a>'];
                            end
                            fprintf(['   - [', method, '] ', globEnvVar, ' :  --> set this path manually after installing the solver ( see ', solversLink, ' )\n' ]);
                        end
                    else
                        if printLevel > 0
                            fprintf(['   - [', method, '] ', globEnvVar, ': ', strrep(eval(globEnvVar), '\', '\\'), '\n' ]);
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

        % check for 32-bit
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

        % check for 32-bit
        if ~isempty(strfind(computer('arch'), '64'))
            subDir = [filesep, 'cplex', filesep, 'matlab', filesep, osPath];
        end
    end
end
