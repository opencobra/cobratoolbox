%      _____   _____   _____   _____     _____     |
%     /  ___| /  _  \ |  _  \ |  _  \   / ___ \    |   COnstraint-Based Reconstruction and Analysis
%     | |     | | | | | |_| | | |_| |  | |___| |   |   COBRA Toolbox 2.0 - 2017
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

% Add cobra toolbox paths
global CBTDIR;
global SOLVERS;
global OPTIMIZATIONPROBLEMTYPES;
global GUROBI_PATH;
global ILOG_CPLEX_PATH;
global TOMLAB_PATH;
global MOSEK_PATH;
global WAITBAR_TYPE;

WAITBAR_TYPE = 1;

fprintf('\n\n      _____   _____   _____   _____     _____     |\n     /  ___| /  _  \\ |  _  \\ |  _  \\   / ___ \\    |   COnstraint-Based Reconstruction and Analysis\n     | |     | | | | | |_| | | |_| |  | |___| |   |   COBRA Toolbox 2.0 - 2017\n     | |     | | | | |  _  { |  _  /  |  ___  |   |\n     | |___  | |_| | | |_| | | | \\ \\  | |   | |   |   Documentation:\n     \\_____| \\_____/ |_____/ |_|  \\_\\ |_|   |_|   |   http://opencobra.github.io/cobratoolbox\n                                                  | \n\n');

% Throw an error if the user has a bare repository or a copy of The COBRA Toolbox
% that is not a git repository.
currentDir = pwd;
CBTDIR = fileparts(which('initCobraToolbox'));

% check if git is properly installed
[status_gitVersion, result_gitVersion] = system('git --version');

fprintf('\n\n > Checking if git is installed ... ')

if status_gitVersion == 0 && ~isempty(strfind(result_gitVersion, 'git version'))
    fprintf(' Done.\n');
else
    fprintf(result_gitVersion);
    error(' > git is not installed. Please follow the guidelines to learn more on how to install git.');
end

% change to the directory of The COBRA Tooolbox
cd(CBTDIR);

% configure a remote tracking repository
fprintf(' > Checking if the repository is git-tracked ... ')
% check if the directory is a git-tracked folder
if exist('.git', 'dir') ~= 7
    % initialize the directory
    [status_gitInit, result_gitInit] = system(['git init']);

    if status_gitInit ~= 0
        fprintf(result_gitInit);
        error(' > This directory is not a git repository.\n');
    end

    % set the remote origin
    [status_setOrigin, result_setOrigin] = system(['git remote add origin https://github.com/opencobra/cobratoolbox.git']);

    if status_setOrigin ~= 0
        fprintf(result_setOrigin);
        error(' > The remote tracking origin could not be set.');
    end

    % set the remote origin
    [status_fetch, result_fetch] = system('git fetch origin master --depth=1');
    if status_fetch ~= 0
        fprintf(result_fetch);
        error(' > The files could not be fetched.');
    end

    [status_resetHard, result_resetHard] = system('git reset --mixed origin/master');

    if status_resetHard ~= 0
        fprintf(result_resetHard);
        error(' > The remote tracking origin could not be set.');
    end
end
fprintf(' Done.\n');

% initialize and update the submodules
fprintf(' > Initializing and updating submodules ... ');
[status_submodule, result_submodule] = system('git submodule update --init --jobs=5');

if status_submodule ~= 0
    result_submodule
    error('The submodules could not be initialized.');
end

% add the folders of The COBRA Toolbox
if ispc  % Windows is not case-sensitive
    onPath = ~isempty(strfind(lower(path), lower(CBTDIR)));
else
    onPath = ~isempty(strfind(path, CBTDIR));
end

folders = {'external', 'src', 'test', 'tutorials', 'papers', 'binary', 'deprecated'};

if ~onPath
    fprintf(' > Adding all the files of The COBRA Toolbox ... ')

    % add the root folder
    addpath(CBTDIR);

    % add specific subfolders
    for k = 1:length(folders)
        addpath(genpath([CBTDIR, filesep, folders{k}]));
    end

    % remove the SBML Toolbox
    rmpath(genpath([CBTDIR, filesep, 'external', filesep, 'SBMLToolbox']));

    % print a success message
    fprintf(' Done.\n');
end
clear folders;

% Define default CB map output
fprintf(' > Define CB map output...');
for CbMapOutput = {'svg', 'matlab'}
    CbMapOutputOK = changeCbMapOutput(char(CbMapOutput));
    if CbMapOutputOK
      break
    end
end
if CbMapOutputOK
    fprintf(' set to %s.\n', char(CbMapOutput));
else
    fprintf('FAILED.\n');
end

% Set global LP solution accuracy tolerance
changeCobraSolverParams('LP', 'optTol', 1e-6);

% Check that SBML toolbox is installed and accessible
if ~exist('TranslateSBML', 'file')
    warning('SBML Toolbox not in Matlab path: COBRA Toolbox will be unable to read SBML files');
else
    % Test the installation with:
    xmlTestFile = strcat([CBTDIR, filesep, 'test', filesep, 'verifiedTests', filesep, 'testSBML', filesep, 'Ecoli_core_ECOSAL.xml']);
    try
        TranslateSBML(xmlTestFile);
        fprintf(' > TranslateSBML is installed and working.\n')
    catch
        warning('TranslateSBML did not work with the file: Ecoli_core_ECOSAL.xml')
    end
end

fprintf(' > Configuring solver environment variables ...\n')

solverPaths = {};
solverPaths{1,1} = 'ILOG_CPLEX_PATH';
solverPaths{1,2} = {'/Applications/IBM/ILOG/CPLEX_Studio1262', '/Applications/IBM/ILOG/CPLEX_Studio1263', '/Applications/IBM/ILOG/CPLEX_Studio127', ...
                    '/opt/ibm/ILOG/CPLEX_Studio1262', '/opt/ibm/ILOG/CPLEX_Studio1263', '/opt/ibm/ILOG/CPLEX_Studio127'};
solverPaths{2,1} = 'GUROBI_PATH';
solverPaths{2,2} = {'/Library/gurobi600', '/Library/gurobi650', '/Library/gurobi702', '/opt/gurobi650', '/opt/gurobi70'};
solverPaths{3,1} = 'TOMLAB_PATH';
solverPaths{3,2} = {'/opt/tomlab'};
solverPaths{4,1} = 'MOSEK_PATH';
solverPaths{4,2} = {};

for k = 1:length(solverPaths)
    eval([solverPaths{k, 1}, ' = getenv(''', solverPaths{k, 1} ,''');'])
    possibleDir = '';
    if isempty(eval(solverPaths{k, 1})) && isunix
        tmpSolverPath = solverPaths{k, 2};
        for i = 1:length(solverPaths{k, 2})
            if exist(tmpSolverPath{i}, 'dir') == 7
                possibleDir = tmpSolverPath{i};
            end;
        end
        if ~isempty(possibleDir)
            reply = input(['The environment variable ', solverPaths{k, 1}, ' is not set, but the solver seems to be installed in ', possibleDir, '. Do you want to set this path temporarily? Y/N [N]: '], 's');
            if ~isempty(reply) && (strcmpi(reply, 'yes') || strcmpi(reply, 'y'))
                setenv(solverPaths{k, 1}, possibleDir);
                eval([solverPaths{k, 1}, ' = getenv(''', solverPaths{k, 1} ,''');']);
            end
        end
    end

    % add the solver path
    if ~isempty(eval(solverPaths{k, 1}))
        addpath(genpath(eval(solverPaths{k, 1})));
        fprintf(['   - ', solverPaths{k, 1}, ': ', eval(solverPaths{k, 1}), '\n']);
    end
end
% print a success message
fprintf('   Done.\n');

fprintf(' > Checking available solvers ...')
% define categories of solvers: LP, MILP, QP, MIQP, NLP
OPTIMIZATIONPROBLEMTYPES = {'LP', 'MILP', 'QP', 'MIQP', 'NLP'};
SOLVERS = {};
SOLVERS.gurobi7.type = {'LP', 'MILP', 'QP', 'MIQP'};
SOLVERS.gurobi6.type = {'LP', 'MILP', 'QP', 'MIQP'};
SOLVERS.gurobi5.type = {'LP', 'MILP', 'QP', 'MIQP'};
SOLVERS.gurobi_mex.type = {'LP', 'MILP', 'QP', 'MIQP'};
SOLVERS.tomlab_cplex.type = {'LP', 'MILP', 'QP', 'MIQP'};
SOLVERS.tomlab_snopt.type = {'NLP'};
SOLVERS.ibm_cplex.type = {'LP', 'MILP', 'QP', 'MIQP'};
SOLVERS.cplex_direct.type = {'LP', 'MILP', 'QP', 'MIQP'};
SOLVERS.glpk.type = {'LP', 'MILP'};
SOLVERS.qpng.type = {'QP'};
SOLVERS.lindo_old.type = {'LP'};
SOLVERS.lindo_legacy.type = {'LP'};
SOLVERS.lp_solve.type = {'LP'};
SOLVERS.pdco.type = {'LP', 'NLP'};
SOLVERS.mosek.type = {'LP', 'QP', 'MILP'};
SOLVERS.opti.type = {'LP', 'MILP', 'QP', 'MIQP', 'NLP'};
SOLVERS.quadMinos.type = {'LP', 'NLP'};
SOLVERS.dqqMinos.type = {'LP'};
SOLVERS.matlab.type = {'NLP'};

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

% print a success message
fprintf(' Done.\n');

% saves the current paths
try
    fprintf(' > Saving the MATLAB path ...');
    savepath;
    fprintf(' Done.\n');
catch
    fprintf(' > The MATLAB path could not be saved.\n');
end

% print out a summary table
solverTypeInstalled = zeros(length(OPTIMIZATIONPROBLEMTYPES), 1);
solverStatuss = '-' * ones(length(supportedSolversNames), length(OPTIMIZATIONPROBLEMTYPES));
solverStatus = -1 * ones(length(supportedSolversNames), length(OPTIMIZATIONPROBLEMTYPES));
for i = 1:length(supportedSolversNames)
    types = SOLVERS.(supportedSolversNames{i}).type;
    for j = 1:length(types)
        k = find(ismember(OPTIMIZATIONPROBLEMTYPES, types{j}));
        if SOLVERS.(supportedSolversNames{i}).installed
            solverStatus(i, k) = 1;
            solverStatuss(i, k) = '1';
            solverTypeInstalled(k) = solverTypeInstalled(k) + 1;
        else
            solverStatus(i, k) = 0;
            solverStatuss(i, k) = '0';
        end
    end
end
solverStatuss(end+1, :) = ' '* ones(1, length(OPTIMIZATIONPROBLEMTYPES));
solverStatuss(end+1, :) =  num2str(solverTypeInstalled)';
solverStatuss = char(solverStatuss);
rowNames = [supportedSolversNames; '----------'; 'Total'];

solverSummary = table(solverStatuss(:, 1), solverStatuss(:, 2), solverStatuss(:, 3), solverStatuss(:, 4), solverStatuss(:, 5), 'RowNames', rowNames, 'VariableNames', OPTIMIZATIONPROBLEMTYPES);

fprintf('\n > Summary of available solvers\n\n')
disp(solverSummary);

fprintf(' + Legend: - = not applicable, 0 = solver not compatible or not installed, 1 = solver installed.\n\n')

fprintf('\n');

% provide clear instructions and summary
for i = 1:length(OPTIMIZATIONPROBLEMTYPES)
    if sum(solverStatus(:, i) == 1) == 0
        fprintf(' > You cannot solve %s problems on this system. Consider installing a %s solver.\n', char(OPTIMIZATIONPROBLEMTYPES(i)), char(OPTIMIZATIONPROBLEMTYPES(i)));
    else
        fprintf(' > You can solve %s problems on this system with: ', char(OPTIMIZATIONPROBLEMTYPES(i)));
        k = 1;
        for j = 1:length(catSolverNames.(OPTIMIZATIONPROBLEMTYPES{i}))
            if SOLVERS.(catSolverNames.(OPTIMIZATIONPROBLEMTYPES{i}){j}).installed
                if k == 1 msg = '''%s'' '; else msg = '- ''%s'' '; end
                fprintf(msg, catSolverNames.(OPTIMIZATIONPROBLEMTYPES{i}){j});
                k = k + 1;
            end
        end
        fprintf('\n');
    end
end

clear solverStatus solverSummary solverStatuss
fprintf('\n')
cd(currentDir);
