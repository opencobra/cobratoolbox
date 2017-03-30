%      _____   _____   _____   _____     _____     |
%     /  ___| /  _  \ |  _  \ |  _  \   / ___ \    |   COnstraint-Based Reconstruction and Analysis
%     | |     | | | | | |_| | | |_| |  | |___| |   |   The COBRA Toolbox - 2017
%     | |     | | | | |  _  { |  _  /  |  ___  |   |
%     | |___  | |_| | | |_| | | | \ \  | |   | |   |   Documentation:
%     \_____| \_____/ |_____/ |_|  \_\ |_|   |_|   |   http://opencobra.github.io/cobratoolbox
%                                                  |
%
%     initCobraToolbox Initialize COnstraint-Based Reconstruction and Analysis Toolbox
%
%     Defines default solvers and paths, tests SBML io functionality.
%     Function only needs to be called once per installation. Saves paths afer script terminates.
%
%     In addition add either of the following into startup.m (generally in MATLAB_DIRECTORY/toolbox/local/startup.m)
%     initCobraToolbox
%           -or-
%     changeCobraSolver('gurobi');
%     changeCobraSolver('gurobi', 'MILP');
%     changeCobraSolver('tomlab_cplex', 'QP');
%     changeCobraSolver('tomlab_cplex', 'MIQP');
%     changeCbMapOutput('svg');
%
% Maintained by Ronan M.T. Fleming, Sylvain Arreckx, Laurent Heirendt

%- check if the folder is already with addpath, then unload the path if uing tomlab

% define GLOBAL variables
global CBTDIR;
global SOLVERS;
global OPT_PROB_TYPES;
global GUROBI_PATH;
global ILOG_CPLEX_PATH;
global TOMLAB_PATH;
global MOSEK_PATH;
global WAITBAR_TYPE;
global ENV_VARS;

SOLVERS = {};
ENV_VARS.STATUS = 0;
WAITBAR_TYPE = 1;

% initialize the paths
GUROBI_PATH = '';
ILOG_CPLEX_PATH = '';
TOMLAB_PATH = '';
MOSEK_PATH = '';

if ~isfield(ENV_VARS, 'printLevel') || ENV_VARS.printLevel
    fprintf('\n\n      _____   _____   _____   _____     _____     |\n     /  ___| /  _  \\ |  _  \\ |  _  \\   / ___ \\    |   COnstraint-Based Reconstruction and Analysis\n     | |     | | | | | |_| | | |_| |  | |___| |   |   The COBRA Toolbox - 2017\n     | |     | | | | |  _  { |  _  /  |  ___  |   |\n     | |___  | |_| | | |_| | | | \\ \\  | |   | |   |   Documentation:\n     \\_____| \\_____/ |_____/ |_|  \\_\\ |_|   |_|   |   http://opencobra.github.io/cobratoolbox\n                                                  | \n\n');
    ENV_VARS.printLevel = true;
end

% retrieve the current directory
currentDir = pwd;

% define the root path of The COBRA Toolbox
CBTDIR = fileparts(which('initCobraToolbox'));

% check if git is installed
checkGit();

% change to the root of The COBRA Tooolbox
cd(CBTDIR);

% configure a remote tracking repository
if isempty(strfind(getenv('HOME'), 'jenkins'))
    if ENV_VARS.printLevel
        fprintf(' > Checking if the repository is tracked ... ');
    end

    % check if the directory is a git-tracked folder
    if exist('.git', 'dir') ~= 7
        % initialize the directory
        [status_gitInit, result_gitInit] = system('git init');

        if status_gitInit ~= 0
            fprintf(result_gitInit);
            error(' > This directory is not a git repository.\n');
        end

        % set the remote origin
        [status_setOrigin, result_setOrigin] = system('git remote add origin https://github.com/opencobra/cobratoolbox.git');

        if status_setOrigin ~= 0
            fprintf(result_setOrigin);
            error(' > The remote tracking origin could not be set.');
        end

        % check curl
        status_curl = checkCurlAndRemote();

        if status_curl == 0
            % set the remote origin
            [status_fetch, result_fetch] = system('git fetch origin master --depth=1');
            if status_fetch ~= 0
                fprintf(result_fetch);
                error(' > The files could not be fetched.');
            end

            [status_resetMixed, result_resetMixed] = system('git reset --mixed origin/master');

            if status_resetMixed ~= 0
                fprintf(result_resetMixed);
                error(' > The remote tracking origin could not be set.');
            end
        end
    end

    if ENV_VARS.printLevel
        fprintf(' Done.\n');
    end

    % check curl
    status_curl = checkCurlAndRemote(false);

    % check if the URL exists
    if exist([CBTDIR filesep 'binary' filesep 'README.md'], 'file') && status_curl ~= 0
        fprintf(' > Submodules exist but cannot be updated (remote cannot be reached).\n');
    elseif status_curl == 0
        % initialize and update the submodules
        if ENV_VARS.printLevel
            fprintf(' > Initializing and updating submodules ...');
        end

        % initialize and update the submodules
        [status_submodule, result_submodule] = system('git submodule update --init');

        if status_submodule ~= 0
            fprintf(result_submodule);
            error('The submodules could not be initialized.');
        end

        if ENV_VARS.printLevel
            fprintf('   Done.\n');
        end
    end
end

% add the folders of The COBRA Toolbox
onPath = ~isempty(strfind(lower(path), lower(CBTDIR)));

folders = {'external', 'tutorials', 'papers', 'binary', 'deprecated', 'src', 'test'};

if ~onPath
    if ENV_VARS.printLevel
        fprintf(' > Adding all the files of The COBRA Toolbox ... ')
    end

    % add the root folder
    addpath(CBTDIR);

    % add specific subfolders
    for k = 1:length(folders)
        addpath(genpath([CBTDIR, filesep, folders{k}]));
    end

    % remove the SBML Toolbox
    rmpath(genpath([CBTDIR, filesep, 'external', filesep, 'SBMLToolbox']));

    % print a success message
    if ENV_VARS.printLevel
        fprintf(' Done.\n');
    end
end

% Define default CB map output
if ENV_VARS.printLevel
    fprintf(' > Define CB map output...');
end
for CbMapOutput = {'svg', 'matlab'}
    CbMapOutputOK = changeCbMapOutput(char(CbMapOutput));
    if CbMapOutputOK
        break
    end
end
if CbMapOutputOK
    if ENV_VARS.printLevel
        fprintf(' set to %s.\n', char(CbMapOutput));
    end
else
    if ENV_VARS.printLevel
        fprintf('FAILED.\n');
    end
end

% retrieve the models
xmlTestFile = strcat([CBTDIR, filesep, 'test', filesep, 'models', filesep, 'Ec_iAF1260_flux1.xml']);
if ENV_VARS.printLevel
    fprintf(' > Retrieving models ...');
end
if ~exist(xmlTestFile, 'file')
    retrieveModels(1);
end
if ENV_VARS.printLevel
    fprintf('   Done.\n');
end

% Set global LP solution accuracy tolerance
changeCobraSolverParams('LP', 'optTol', 1e-6);

% Check that SBML toolbox is installed and accessible
if ~exist('TranslateSBML', 'file')
    if ENV_VARS.printLevel
        warning('SBML Toolbox not in Matlab path: COBRA Toolbox will be unable to read SBML files');
    end
else
    % Test the installation with:
    try
        TranslateSBML(xmlTestFile);
        if ENV_VARS.printLevel
            fprintf(' > TranslateSBML is installed and working properly.\n');
        end
    catch
        if ENV_VARS.printLevel
            warning('TranslateSBML did not work with Ec_iAF1260_flux1.xml')
        end
    end
end

if ENV_VARS.printLevel
    fprintf(' > Configuring solver environment variables ...\n');
    configEnvVars(1);
    fprintf('   Done.\n');
    fprintf(' > Checking available solvers and solver interfaces ...');
end

% define categories of solvers: LP, MILP, QP, MIQP, NLP
OPT_PROB_TYPES = {'LP', 'MILP', 'QP', 'MIQP', 'NLP'};

% supported solvers
SOLVERS.cplex_direct.type = {'LP', 'MILP', 'QP', 'MIQP'};
SOLVERS.dqqMinos.type = {'LP'};
SOLVERS.glpk.type = {'LP', 'MILP'};
SOLVERS.gurobi6.type = {'LP', 'MILP', 'QP', 'MIQP'};
SOLVERS.gurobi7.type = {'LP', 'MILP', 'QP', 'MIQP'};
SOLVERS.ibm_cplex.type = {'LP', 'MILP', 'QP', 'MIQP'};
SOLVERS.matlab.type = {'NLP'};
SOLVERS.mosek.type = {'LP', 'QP', 'MILP'};
SOLVERS.pdco.type = {'LP', 'QP', 'NLP'};
SOLVERS.quadMinos.type = {'LP', 'NLP'};
SOLVERS.tomlab_cplex.type = {'LP', 'MILP', 'QP', 'MIQP'};

% experimental solver interfaces
SOLVERS.opti.type = {'LP', 'MILP', 'QP', 'MIQP', 'NLP'};
SOLVERS.qpng.type = {'QP'};
SOLVERS.tomlab_snopt.type = {'NLP'};

% legacy solvers
SOLVERS.gurobi5.type = {'LP', 'MILP', 'QP', 'MIQP'};
SOLVERS.gurobi_mex.type = {'LP', 'MILP', 'QP', 'MIQP'};
SOLVERS.lindo_old.type = {'LP'};
SOLVERS.lindo_legacy.type = {'LP'};
SOLVERS.lp_solve.type = {'LP'};

% definition of category
SOLVERS.cplex_direct.categ = 'full';
SOLVERS.dqqMinos.categ = 'full';
SOLVERS.glpk.categ = 'full';
SOLVERS.gurobi6.categ = 'full';
SOLVERS.gurobi7.categ = 'full';
SOLVERS.ibm_cplex.categ = 'full';
SOLVERS.matlab.categ = 'full';
SOLVERS.mosek.categ = 'full';
SOLVERS.pdco.categ = 'full';
SOLVERS.quadMinos.categ = 'full';
SOLVERS.tomlab_cplex.categ = 'full';

SOLVERS.opti.categ = 'experimental';
SOLVERS.qpng.categ = 'experimental';
SOLVERS.tomlab_snopt.categ = 'experimental';

SOLVERS.gurobi5.categ = 'legacy';
SOLVERS.gurobi_mex.categ = 'legacy';
SOLVERS.lindo_old.categ = 'legacy';
SOLVERS.lindo_legacy.categ = 'legacy';
SOLVERS.lp_solve.categ = 'legacy';

supportedSolversNames = fieldnames(SOLVERS);
catSolverNames.LP = {}; catSolverNames.MILP = {}; catSolverNames.QP = {}; catSolverNames.MIQP = {}; catSolverNames.NLP = {};
for i = 1:length(supportedSolversNames)
    SOLVERS.(supportedSolversNames{i}).installed = 0;
    types = SOLVERS.(supportedSolversNames{i}).type;
    for j = 1:length(types)
        catSolverNames.(types{j}){end + 1} = supportedSolversNames{i};
    end
end

% check the installation of the solver
for i = 1:length(supportedSolversNames)
    solverOK = changeCobraSolver(supportedSolversNames{i}, SOLVERS.(supportedSolversNames{i}).type{1}, 0);
    if solverOK
        SOLVERS.(supportedSolversNames{i}).installed = 1;
    end
end

if ENV_VARS.printLevel
    fprintf(' Done.\n');
end

% saves the current paths
try
    if ENV_VARS.printLevel
        fprintf(' > Saving the MATLAB path ...');
    end
    if ispc || ismac
        savepath;
        if ENV_VARS.printLevel
            fprintf(' Done.\n');
            fprintf('   - The MATLAB path was saved in the default location.\n');
        end
    else
        savepath('~/pathdef.m');
        if ENV_VARS.printLevel
            fprintf(' Done.\n');
            fprintf('   - The MATLAB path was saved as ~/pathdef.m.\n');
        end
    end
catch
    if ENV_VARS.printLevel
        fprintf(' > The MATLAB path could not be saved.\n');
    end
end

% print out a summary table
solverTypeInstalled = zeros(length(OPT_PROB_TYPES), 1);
solverStatuss = '-' * ones(length(supportedSolversNames), length(OPT_PROB_TYPES) + 1);
solverStatus = -1 * ones(length(supportedSolversNames), length(OPT_PROB_TYPES) + 1);
catList = cell(length(supportedSolversNames), 1);
for i = 1:length(supportedSolversNames)
    types = SOLVERS.(supportedSolversNames{i}).type;
    catList{i} = SOLVERS.(supportedSolversNames{i}).categ;
    for j = 1:length(types)
        k = find(ismember(OPT_PROB_TYPES, types{j}));
        if SOLVERS.(supportedSolversNames{i}).installed
            solverStatus(i, k + 1) = 1;
            solverStatuss(i, k + 1) = '1';
            solverTypeInstalled(k) = solverTypeInstalled(k) + 1;
        else
            solverStatus(i, k + 1) = 0;
            solverStatuss(i, k + 1) = '0';
        end
    end
end
catList{end + 1} = '----------';
catList{end + 1} = '-';

solverStatuss(end + 1, :) = ' ' * ones(1, length(OPT_PROB_TYPES) + 1);
solverStatuss(end + 1, 2:end) = num2str(solverTypeInstalled)';
solverStatuss = char(solverStatuss);
rowNames = [supportedSolversNames; '----------'; 'Total'];

solverSummary = table(categorical(catList), solverStatuss(:, 2), solverStatuss(:, 3), solverStatuss(:, 4), solverStatuss(:, 5), solverStatuss(:, 6), 'RowNames', rowNames, 'VariableNames', ['Support', OPT_PROB_TYPES]);

if ENV_VARS.printLevel
    fprintf('\n > Summary of available solvers and solver interfaces\n\n');
    disp(solverSummary);
    fprintf(' + Legend: - = not applicable, 0 = solver not compatible or not installed, 1 = solver installed.\n\n')
end

% provide clear instructions and summary
for i = 1:length(OPT_PROB_TYPES)
    if sum(solverStatus(:, i + 1) == 1) == 0
        if ENV_VARS.printLevel
            fprintf(' > You cannot solve %s problems. Consider installing an %s solver.\n', char(OPT_PROB_TYPES(i)), char(OPT_PROB_TYPES(i)));
        end
    else
        if ENV_VARS.printLevel
            fprintf(' > You can solve %s problems using: ', char(OPT_PROB_TYPES(i)));
        end
        k = 1;
        for j = 1:length(catSolverNames.(OPT_PROB_TYPES{i}))
            if SOLVERS.(catSolverNames.(OPT_PROB_TYPES{i}){j}).installed
                if k == 1
                    msg = '''%s'' ';
                else
                    msg = '- ''%s'' ';
                end
                if ENV_VARS.printLevel
                    fprintf(msg, catSolverNames.(OPT_PROB_TYPES{i}){j});
                end
                k = k + 1;
            end
        end
        if ENV_VARS.printLevel
            fprintf('\n');
        end
    end
end

if ENV_VARS.printLevel
    fprintf('\n')
end

% change back to the current directory
cd(currentDir);

% clear all temporary variables
% Note: global variables are kept in memory - DO NOT clear all the variables!
clearvars

function checkGit()
% Checks if git is installed on the system and throws an error if not
%
% USAGE:
%     checkGit();
%

      global ENV_VARS

    if ENV_VARS.printLevel
        fprintf(' > Checking if git is installed ... ')
    end

    % check if git is properly installed
    [status_gitVersion, result_gitVersion] = system('git --version');

    if status_gitVersion == 0 && ~isempty(strfind(result_gitVersion, 'git version'))
        if ENV_VARS.printLevel
            fprintf(' Done.\n');
        end
    else
        fprintf(result_gitVersion);
        error(' > git is not installed. Please follow the guidelines to learn more on how to install git.');
    end
end

function status_curl = checkCurlAndRemote(throwError)
% Checks if curl is installed on the system, can connect to the opencobra URL, and throws an error if not
%
% USAGE:
%     status_curl = checkCurlAndRemote(throwError)
%
% INPUT:
%     throwError:   boolean variable that specifies if an error is thrown or a message is displayed
%

    global ENV_VARS

    if nargin < 1
        throwError = true;
    end

    if ENV_VARS.printLevel
        fprintf('\n > Checking if curl is installed ... ')
    end

    % check if curl is properly installed
    [status_curl, result_curl] = system('curl --version');

    if status_curl == 0 && ~isempty(strfind(result_curl, 'curl')) && ~isempty(strfind(result_curl, 'http'))
        if ENV_VARS.printLevel
            fprintf(' Done.\n');
        end
    else
        if throwError
            fprintf(result_curl);
            error(' > curl is not installed. Please follow the guidelines on how to install curl.');
        else
            if ENV_VARS.printLevel
                fprintf(' (not installed).\n');
            end
        end
    end

    if ENV_VARS.printLevel
        fprintf(' > Checking if remote can be reached ... ')
    end

    % check if the remote repository can be reached
    [status_curl, result_curl] = system('curl -s -k --head https://github.com/opencobra/cobratoolbox');

    % check if the URL exists
    if status_curl == 0 && ~isempty(strfind(result_curl, '200 OK'))
        if ENV_VARS.printLevel
            fprintf(' Done.\n');
        end
    else
        if throwError
            fprintf(result_curl);
            error('The remote repository cannot be reached. Please check your internet connection.');
        else
            if ENV_VARS.printLevel
                fprintf(' (unsuccessful - no internet connection).\n');
            end
        end
    end
end
