function initCobraToolbox(updateToolbox)
%      _____   _____   _____   _____     _____     |
%     /  ___| /  _  \ |  _  \ |  _  \   / ___ \    |   COnstraint-Based Reconstruction and Analysis
%     | |     | | | | | |_| | | |_| |  | |___| |   |   The COBRA Toolbox verson 3.1
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
%
%     initCobraToolbox
%           -or-
%     changeCobraSolver('gurobi');
%     changeCobraSolver('gurobi', 'MILP');
%     changeCobraSolver('tomlab_cplex', 'QP');
%     changeCobraSolver('tomlab_cplex', 'MIQP');
%     changeCbMapOutput('svg');
%
%     Maintained by Ronan M.T. Fleming

% define GLOBAL variables
global CBTDIR;
global SOLVERS;
global OPT_PROB_TYPES;
global CBT_LP_SOLVER;
global CBT_QP_SOLVER;
global CBT_EP_SOLVER;
global CBT_MILP_SOLVER;
global CBT_MIQP_SOLVER;
global CBT_NLP_SOLVER;
global GUROBI_PATH;
global ILOG_CPLEX_PATH;
global TOMLAB_PATH;
global MOSEK_PATH;
global WAITBAR_TYPE;
global ENV_VARS;
global gitBashVersion;
global CBT_MISSING_REQUIREMENTS_ERROR_ID;

if ~exist('updateToolbox','var')
    updateToolbox = true;
end
% define a base version of gitBash that is tested
gitBashVersion = '2.13.3';

% Set the Requirements Error Message ID:
CBT_MISSING_REQUIREMENTS_ERROR_ID = 'COBRA:RequirementsNotMet';

% default waitbar is of type text
if isempty(WAITBAR_TYPE)
    WAITBAR_TYPE = 1;
end

% Linux only - default save path location
defaultSavePathLocation = '~/pathdef.m';

% initialize the cell of solvers
SOLVERS = {};

% declare that the environment variables have not yet been configured
ENV_VARS.STATUS = 0;

% initialize the paths
if exist('GUROBI_PATH', 'var') ~= 1
    GUROBI_PATH = '';
end
if exist('ILOG_CPLEX_PATH', 'var') ~= 1
    ILOG_CPLEX_PATH = '';
end
if exist('TOMLAB_PATH', 'var') ~= 1
    TOMLAB_PATH = '';
end
if exist('MOSEK_PATH', 'var') ~= 1
    MOSEK_PATH = '';
end

% print header
if ~isfield(ENV_VARS, 'printLevel') || ENV_VARS.printLevel
    docLink = 'http://opencobra.github.io/cobratoolbox';
    if usejava('desktop')
        docLink = ['<a href=\"', docLink, '\">', docLink, '</a>'];
    end

    c = clock;
    fprintf('\n\n      _____   _____   _____   _____     _____     |\n');
    fprintf('     /  ___| /  _  \\ |  _  \\ |  _  \\   / ___ \\    |   COnstraint-Based Reconstruction and Analysis\n');
    fprintf(['     | |     | | | | | |_| | | |_| |  | |___| |   |   The COBRA Toolbox - ' num2str(c(1)) '\n']);
    fprintf('     | |     | | | | |  _  { |  _  /  |  ___  |   |\n');
    fprintf('     | |___  | |_| | | |_| | | | \\ \\  | |   | |   |   Documentation:\n');
    fprintf(['     \\_____| \\_____/ |_____/ |_|  \\_\\ |_|   |_|   |   ', docLink, '\n']);
    fprintf('                                                  | \n\n');
    ENV_VARS.printLevel = true;
end

% retrieve the current directory
currentDir = fileparts(which(mfilename));

% define the root path of The COBRA Toolbox and change to it.
CBTDIR = fileparts(which('initCobraToolbox'));
cd(CBTDIR);

if 0
    % add the external install folder
    addpath(genpath([CBTDIR filesep 'external' filesep 'base' filesep 'install']));

    %And the rdir directory
    addpath(genpath([CBTDIR filesep 'external' filesep 'base' filesep 'utilities' filesep 'rdir']));
else
    %add the entire external folder
    addpath(genpath([CBTDIR filesep 'external']))
end
% add the install folder
addpath(genpath([CBTDIR filesep 'src' filesep 'base' filesep 'install']));

% check if git is installed
[installedGit, versionGit] = checkGit();

% set the depth flag if the version of git is higher than 2.10.0
depthFlag = '';
if installedGit && versionGit > 2100
    depthFlag = '--depth=1';
end

% change to the root of The COBRA Tooolbox
cd(CBTDIR);

% configure a remote tracking repository
if ENV_VARS.printLevel
    fprintf(' > Checking if the repository is tracked using git ... ');
end

% check if the directory is a git-tracked folder
if installedGit && exist([CBTDIR filesep '.git'], 'dir') ~= 7
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
    [status_curl, result_curl] = checkCurlAndRemote();

    if status_curl == 0
        % set the remote origin
        [status_fetch, result_fetch] = system(['git fetch origin master ' depthFlag]);
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

if installedGit
    % temporary disable ssl verification
    [status_setSSLVerify, result_setSSLVerify] = system('git config --global http.sslVerify false');

    if status_setSSLVerify ~= 0
        fprintf(strrep(result_setSSLVerify, '\', '\\'));
        warning('Your global git configuration could not be changed.');
    end
end

% check curl
[status_curl, result_curl] = checkCurlAndRemote(false);

submoduleWarning=0;
if installedGit
    % check if the URL exists
    if exist([CBTDIR filesep 'binary' filesep 'README.md'], 'file') && status_curl ~= 0
        fprintf(' > Submodules exist but cannot be updated (remote cannot be reached).\n');
    elseif status_curl == 0
        if ENV_VARS.printLevel
            fprintf(' > Initializing and updating submodules (this may take a while)...');
        end

        % Clean the test/models folder
        [status, result] = system('git submodule status models');
        if status == 0 && strcmp(result(1), '-')
            [status, message, messageid] = rmdir([CBTDIR filesep 'test' filesep 'models'], 's');
        end

        %Check for changes to submodules
        [status_gitSubmodule, result_gitSubmodule] = system('git submodule foreach git status');
        if status_gitSubmodule==0
            if contains(result_gitSubmodule,'modified') || contains(result_gitSubmodule,'Untracked files')
                submoduleWarning = 1;
                [status_gitSubmodule, result_gitSubmodule] = system('git submodule foreach git stash push -u');
                if status_gitSubmodule==0
                    fprintf('\n%s\n','***Local changes to submodules have been stashed. See https://git-scm.com/docs/git-stash.')
                    disp(result_gitSubmodule)
                end
            end
        end

        % Update/initialize submodules
        %By default your submodules repository is in a state called 'detached HEAD'.
        %This means that the checked-out commit -- which is the one that the super-project (core) needs -- is not associated with a local branch name.
        %[status_gitSubmodule, result_gitSubmodule] = system(['git submodule update --init --remote --no-fetch ' depthFlag]);%old
        %[status_gitSubmodule, result_gitSubmodule] = system(['git submodule foreach git submodule update --init --recursive']);% 23/9/21 RF submodules point to master
        [status_gitSubmoduleInit, result_gitSubmoduleInit] = system('git submodule update --init --recursive --depth 1');% 23/9/21 RF submodules point to master, don't pull in remote changes
        %[status_gitSubmodule, result_gitSubmodule] = system('git submodule foreach git checkout master');
        % [status_gitSubmodule, result_gitSubmodule] = system('git submodule foreach git checkout master');% 30/9/21 RF submodules point to master, don't pull in remote changes
        %
        if status_gitSubmoduleInit ~= 0
            fprintf(strrep(result_gitSubmoduleInit, '\', '\\'));
            error('The submodules could not be initialized.');
        end

        % 19/01/2024 FZ Get all submodule path
        submoduleInfo = evalc('system(''git submodule foreach echo $path'')');

        % Extract submodule paths using regular expressions
        pattern = 'Entering ''(.+?)''';
        matches = regexp(submoduleInfo, pattern, 'tokens');

        % Extract submodule paths from the matches
        submodulePaths = cellfun(@(x) x{1}, matches, 'UniformOutput', false);

        if isempty(submodulePaths)
            error('Failed to retrieve submodules paths.');
        end

        for i = 1:length(submodulePaths)
            % Run Git commands using the full path
            submodulePath = fullfile(currentDir, submodulePaths{i});

            % submodules point to master, don't pull in remote changes
            [status_gitSubmodule, result_gitSubmodule] = system(['git -C "', submodulePath, '" checkout master']);

            % In the cases where the default branch name is main, submodule
            % points to main
            if status_gitSubmodule
                [status_gitSubmodule, result_gitSubmodule] = system(['git -C "', submodulePath, '" checkout main']);
            end

            if status_gitSubmodule
                error('Failed to checkout submodule: %s to its default branch.', submodulePath);
            end
        end

        % reset each submodule
        %https://github.com/bazelbuild/continuous-integration/issues/727
        %[status_gitReset, result_gitReset] = system('git submodule foreach --recursive git reset --hard');
        %[status_gitReset, result_gitReset] = system('git submodule foreach --recursive "git reset --hard"'); % [opencobra/cobratoolbox] Matlab installation error (#1490)
        %[status_gitReset, result_gitReset] = system('git submodule foreach --recursive --git reset --hard');%old

        %     if status_gitReset ~= 0
        %         fprintf(strrep(result_gitReset, '\', '\\'));
        %         warning('The submodules could not be reset.');
        %     end

        if ENV_VARS.printLevel
            fprintf(' Done.\n');
        end
    end
    % List all files in the supplied (git tracked) Directory with their absolute path name
    % based on the git ls-file command. If the directory is not git controlled, the
    % type is assumed to be 'all' and all files (except for .git files
    % will be returned).
    %get the current content of the init Folder
    dirContent = getFilesInDir('type','all');
else
    %warning('Git is not installed so the submodules could not be populated.%s\n','Some of the dependencies of the cobra toolbox are not satisfied.%s\n','Trying to proceed without submodules!%s\n')
    fprintf('%s\n','Git not installed, proceeding without initialising submodules.')
end



% add the folders of The COBRA Toolbox
folders = {'tutorials', 'papers', 'binary', 'deprecated', 'src', 'test', '.tmp'};

if ENV_VARS.printLevel
    fprintf(' > Adding all the files of The COBRA Toolbox ... ')
end

% add the root folder
addpath(CBTDIR);

% add the external folder
addpath(genpath([CBTDIR filesep 'external']));

% add specific subfolders
for k = 1:length(folders)
    tmpDir = [CBTDIR, filesep, folders{k}];
    if exist(tmpDir, 'dir') == 7
        addpath(genpath(tmpDir));
    end
end

%Adapt the mac path depending on the mac version.
if ismac
    adaptMacPath()
end

% add the docs/source/notes folder
addpath(genpath([CBTDIR filesep 'docs' filesep 'source' filesep 'notes']));

% print a success message
if ENV_VARS.printLevel
    fprintf(' Done.\n');
end

% Define default CB map output
if ENV_VARS.printLevel
    fprintf(' > Define CB map output...');
end
for CbMapOutput = {'svg', 'matlab'}
    CbMapOutputOK = changeCbMapOutput(char(CbMapOutput));
    if CbMapOutputOK
        break;
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

%refresh field properties in memory in case they have been updated
clear getDefinedFieldProperties
fields = getDefinedFieldProperties();

% define xml test file
xmlTestModel = 'ecoli_core_model.xml';
xmlTestFile = [getDistributedModelFolder(xmlTestModel) filesep xmlTestModel];

% save the userpath
originalUserPath = path;

%These default tolerances are based on the default values for the Gurobi LP
%solver. Do not change them without first consulting with other developers.
%https://www.gurobi.com/documentation/9.0/refman/parameters.html
% (primal) feasibility tolerance
changeCobraSolverParams('LP', 'feasTol', 1e-6);
% (dual) optimality tolerance
changeCobraSolverParams('LP', 'optTol', 1e-6);

% (primal) feasibility tolerance
changeCobraSolverParams('EP', 'feasTol', 1e-8);
% (dual) optimality tolerance
changeCobraSolverParams('EP', 'optTol', 1e-12);

% Check that SBML toolbox is installed and accessible
if ~exist('TranslateSBML', 'file')
    if ENV_VARS.printLevel
        warning('libsbml binaries not on Matlab path: COBRA Toolbox will be unable to read/write SBML files');
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
            warning(' > TranslateSBML is installed but is not working properly.');
            fprintf([' > Try running\n   >> TranslateSBML(\''', strrep(xmlTestFile, '\', '\\'), '\'');\n   in order to debug.\n']);
        end
    end
end

%configuration of solver environment variables
if ENV_VARS.printLevel
    fprintf(' > Configuring solver environment variables ...\n');
    configEnvVars(1);
    fprintf('   Done.\n');
    fprintf(' > Checking available solvers and solver interfaces ...');
end

% define categories of solvers: LP, MILP, QP, MIQP, NLP
OPT_PROB_TYPES = {'LP', 'MILP', 'QP', 'MIQP', 'NLP','EP'};

%Define a set of "use first" solvers, other supported solvers will also be added to the struct.
%This allows to assign them in any order but keep the most commonly used ones on top of the struct.
SOLVERS = struct('gurobi',struct(),...
    'ibm_cplex',struct(),...
    'tomlab_cplex',struct(),...
    'glpk',struct(),...
    'mosek',struct(),...
    'matlab',struct());

% active support - supported solvers
SOLVERS.gurobi.type = {'LP', 'MILP', 'QP', 'MIQP'};
SOLVERS.mosek.type = {'LP', 'QP','EP'};
SOLVERS.glpk.type = {'LP', 'MILP'};
SOLVERS.pdco.type = {'LP', 'QP','EP'};
SOLVERS.quadMinos.type = {'LP'};
SOLVERS.dqqMinos.type = {'LP','QP'};
SOLVERS.matlab.type = {'LP', 'NLP'};
% active support of cplex interfaces - supported solvers
SOLVERS.cplex_direct.type = {'LP', 'MILP', 'QP'};
SOLVERS.ibm_cplex.type = {'LP', 'MILP', 'QP', 'MIQP'};
SOLVERS.cplexlp.type = {'LP'};
SOLVERS.tomlab_cplex.type = {'LP', 'MILP', 'QP', 'MIQP'};

% passive support - solver interfaces
SOLVERS.qpng.type = {'QP'};
SOLVERS.tomlab_snopt.type = {'NLP'};

% legacy solvers
%SOLVERS.gurobi_mex.type = {'LP', 'MILP', 'QP', 'MIQP'};
%SOLVERS.lindo_old.type = {'LP'};
%SOLVERS.lindo_legacy.type = {'LP'};
SOLVERS.lp_solve.type = {'LP'};
%SOLVERS.opti.type = {'LP', 'MILP', 'QP', 'MIQP', 'NLP'};

% definition of category of solvers with active support

SOLVERS.dqqMinos.categ = 'active';
SOLVERS.glpk.categ = 'active';
SOLVERS.gurobi.categ = 'active';
SOLVERS.matlab.categ = 'active';
SOLVERS.mosek.categ = 'active';
SOLVERS.pdco.categ = 'active';
SOLVERS.quadMinos.categ = 'active';

SOLVERS.cplex_direct.categ = 'active';
SOLVERS.ibm_cplex.categ = 'active';
SOLVERS.cplexlp.categ = 'active';
SOLVERS.tomlab_cplex.categ = 'active';

% definition of category of solvers with passive support
SOLVERS.qpng.categ = 'passive';
SOLVERS.tomlab_snopt.categ = 'passive';

% definition of category of solvers with legacy support
%SOLVERS.gurobi_mex.categ = 'legacy';
%SOLVERS.lindo_old.categ = 'legacy';
%SOLVERS.lindo_legacy.categ = 'legacy';
SOLVERS.lp_solve.categ = 'legacy';
%SOLVERS.opti.categ = 'legacy';

% definition of categories of solvers
supportedSolversNames = fieldnames(SOLVERS);
catSolverNames.LP = {};
catSolverNames.MILP = {};
catSolverNames.QP = {};
catSolverNames.MIQP = {};
catSolverNames.NLP = {};
catSolverNames.EP = {};
for i = 1:length(supportedSolversNames)
    SOLVERS.(supportedSolversNames{i}).installed = false;
    SOLVERS.(supportedSolversNames{i}).working = false;
    types = SOLVERS.(supportedSolversNames{i}).type;
    for j = 1:length(types)
        catSolverNames.(types{j}){end + 1} = supportedSolversNames{i};
    end
end

% check the installation of the solver
for i = 1:length(supportedSolversNames)
    if 0 %set to 1 to debug a new solver
        disp(supportedSolversNames{i})
        if strcmp(supportedSolversNames{i},'quadMinos')
            pause(0.1)
        end
    end
    %We will validate all solvers in init. After this, all solvers are
    %checked, whether they actually work and the SOLVERS field is set.
    [solverOK,solverInstalled] = changeCobraSolver(supportedSolversNames{i},SOLVERS.(supportedSolversNames{i}).type{1},0, 2);
    if strcmp(supportedSolversNames{i},'gurobi') && 0%use fordebugging
        disp(supportedSolversNames{i});
    end
    if solverOK
        SOLVERS.(supportedSolversNames{i}).working = true;
    end
    SOLVERS.(supportedSolversNames{i}).installed = solverInstalled;
end

if ENV_VARS.printLevel
    fprintf(' Done.\n');
end

% set the default solver and print out the default variables
if ENV_VARS.printLevel
    fprintf(' > Setting default solvers ...');
    changeCobraSolver('glpk', 'LP', 0);
    changeCobraSolver('glpk', 'MILP', 0);
    changeCobraSolver('glpk', 'LP', 0);
    changeCobraSolver('pdco', 'QP', 0);
    changeCobraSolver('mosek', 'EP', 0);
    changeCobraSolver('matlab', 'NLP', 0);
    for k = 1:length(OPT_PROB_TYPES)
        varName = horzcat(['CBT_', OPT_PROB_TYPES{k}, '_SOLVER']);
    end
    fprintf(' Done.\n');
end

% fill the summary table
solverTypeInstalled = zeros(length(OPT_PROB_TYPES), 1);
solverStatus = -1 * ones(length(supportedSolversNames), length(OPT_PROB_TYPES) + 1);
catList = cell(length(supportedSolversNames), 1);
for i = 1:length(supportedSolversNames)
    types = SOLVERS.(supportedSolversNames{i}).type;
    catList{i} = SOLVERS.(supportedSolversNames{i}).categ;
    for j = 1:length(types)
        if 0 %set to 1 to debug a new solver
            if strcmp(supportedSolversNames{i},'mosek') && strcmp(types{j},'EP')
                pause(0.1)
            end
        end
        k = find(ismember(OPT_PROB_TYPES, types{j}));
        if SOLVERS.(supportedSolversNames{i}).installed
            solverStatus(i, k + 1) = 1;
            solverTypeInstalled(k) = solverTypeInstalled(k) + 1;

            % set the default MIQP solver based on the solvers that are installed
            if strcmp(supportedSolversNames{i},'gurobi') && strcmp(types{j},'LP')
                changeCobraSolver('gurobi', 'LP', 0);
                changeCobraSolver('gurobi', 'MILP', 0);
                changeCobraSolver('gurobi', 'LP', 0);
                changeCobraSolver('gurobi', 'QP', 0);
            end
            if strcmp(supportedSolversNames{i},'mosek') && strcmp(types{j},'EP')
                changeCobraSolver(supportedSolversNames{i}, types{j}, 0);
            end
        else
            solverStatus(i, k + 1) = 0;
        end
    end
end

catList{end + 1} = '----------';
catList{end + 1} = '-';

rowNames = [supportedSolversNames; '----------'; 'Total'];

solverStatus(end + 1, :) = ones(1, length(OPT_PROB_TYPES) + 1);
solverStatus(end + 1, 2:end) = solverTypeInstalled';

statusTable = {};
for k = 1:length(OPT_PROB_TYPES)
    statusTable{k} = cellstr(num2str(solverStatus(:, k+1)));
    for p = 1:length(solverStatus(:, k+1))
        if strcmp(statusTable{k}(p), '-1')
            statusTable{k}(p) = {'-'};
        end
    end
end

% restore the original path
path(originalUserPath);
addpath(originalUserPath);

% saves the current path
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
        [~, values] = fileattrib(which('pathdef.m'));
        if values.UserWrite
            savepath
        else
            savepath(defaultSavePathLocation);
        end
        if ENV_VARS.printLevel
            fprintf(' Done.\n');
            fprintf(['   - The MATLAB path was saved as ', defaultSavePathLocation, '.\n']);
        end
    end
catch
    if ENV_VARS.printLevel
        fprintf(' > The MATLAB path could not be saved.');
    end
end

% print out a summary table
if ENV_VARS.printLevel
    colFormat = '\t%-12s \t%-13s \t%5s \t%5s \t%5s \t%5s \t%5s \t%5s\n';
    sep = '\t------------------------------------------------------------------------------\n';
    fprintf('\n > Summary of available solvers and solver interfaces\n\n');
    if ispc
        topLineFormat = '\t\t\t\t\tSupport        %5s \t%5s \t%5s \t%5s \t%5s \t%5s\n';
    else
        topLineFormat = '\t\t\tSupport \t%5s \t%5s \t%5s \t%5s \t%5s \t%5s\n';
    end
    fprintf(topLineFormat, OPT_PROB_TYPES{1}, OPT_PROB_TYPES{2}, OPT_PROB_TYPES{3}, OPT_PROB_TYPES{4}, OPT_PROB_TYPES{5}, OPT_PROB_TYPES{6})
    fprintf(sep);
    for i = 1:length(catList)-2
        fprintf(colFormat, rowNames{i}, catList{i}, statusTable{1}{i}, statusTable{2}{i}, statusTable{3}{i}, statusTable{4}{i}, statusTable{5}{i}, statusTable{6}{i})
    end
    fprintf(sep);
    fprintf(colFormat, rowNames{end}, catList{end}, statusTable{1}{end}, statusTable{2}{end}, statusTable{3}{end}, statusTable{4}{end}, statusTable{5}{end}, statusTable{6}{end})
    fprintf('\n + Legend: - = not applicable, 0 = solver not compatible or not installed, 1 = solver installed.\n\n\n')
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
            if SOLVERS.(catSolverNames.(OPT_PROB_TYPES{i}){j}).working
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
    fprintf('\n');
end

% use Gurobi (if installed) as the default solver for LP, QP and MILP problems
changeCobraSolver('gurobi', 'ALL', 0);
%changeCobraSolver('ibm_cplex', 'QP', 0); %until problem with gurobi QP sorted

% check if a new update exists
if installedGit && ENV_VARS.printLevel && status_curl == 0 && contains(result_curl, ' 200') && updateToolbox
    updateCobraToolbox(true); % only check
else
    if ~updateToolbox && ENV_VARS.printLevel
        fprintf('> Checking for available updates ... skipped\n')
    end
end

if installedGit
    % restore global configuration by unsetting http.sslVerify
    [status_setSSLVerify, result_setSSLVerify] = system('git config --global --unset http.sslVerify');

    if status_setSSLVerify ~= 0
        fprintf(strrep(result_setSSLVerify, '\', '\\'));
        warning('Your global git configuration could not be restored.');
    end
end

% set up the COBRA System path
addCOBRABinaryPathToSystemPath();

%remove /new thermo folders from path
%TODO resolve issues with new file versions
aPath = which('initVonBertalanffy');
basePath = strrep(aPath,['vonBertalanffy' filesep 'initVonBertalanffy.m'],'');
addpath(genpath(basePath))
folderPattern=[filesep 'new'];
method = 'remove';
editCobraToolboxPath(basePath,folderPattern,method)

if exist([CBTDIR filesep 'binary' filesep 'glnxa64' filesep 'lib_old'],'dir')
    rmpath([CBTDIR filesep 'binary' filesep 'glnxa64' filesep 'lib_old']);
end

% change back to the current directory
cd(currentDir);

if installedGit
    % cleanup at the end of the successful run
    removeTempFiles(CBTDIR, dirContent);
end

if submoduleWarning
    warning('Local changes have been made to submodules\n%s\n%s\n%s','Local changes have been stashed. See ***Local changes ... above for details.','Such changes should ideally be made to separate forks.', 'See, e.g., https://github.com/opencobra/COBRA.tutorials#contribute-a-new-tutorial-or-modify-an-existing-tutorial')
end

% clear all temporary variables
% Note: global variables are kept in memory - DO NOT clear all the variables!
if ENV_VARS.printLevel
    clearvars
end
end

function [installed, versionGit] = checkGit()
% Checks if git is installed on the system and throws an error if not
%
% USAGE:
%     versionGit = checkGit();
%
% OUTPUT:
%     installed:      boolean to determine whether git is installed or not
%     versionGit:     version of git installed
%

if 0 %try to proceed as if there is no git
    installed = false;
    versionGit = [];
    return
end

global ENV_VARS

% set the boolean as false (not installed)
installed = false;

if ENV_VARS.printLevel
    fprintf(' > Checking if git is installed ... ')
end

% check if git is properly installed
[status_gitVersion, result_gitVersion] = system('git --version');

% get index of the version string
searchStr = 'git version';
index = strfind(result_gitVersion, searchStr);

if status_gitVersion == 0 && ~isempty(index)

    % determine the version of git
    versionGitStr = result_gitVersion(length(searchStr)+1:end);

    % replace line breaks and white spaces
    versionGitStr = regexprep(versionGitStr(1:7),'\s+','');

    % replace the dots in the version number
    tmp = strrep(versionGitStr, '.', '');

    % convert the string of the version number to a number
    versionGit = str2num(tmp);

    % set the boolean to true
    installed = true;

    if ENV_VARS.printLevel
        fprintf([' Done (version: ' versionGitStr ').\n']);
    end
else
    if ispc
        fprintf('(git is not installed, attempting to install GitBash).\n');
        installGitBash();
    else
        fprintf(result_gitVersion);
        warning(' > git is not installed.');
        fprintf(' > Please follow the guidelines on how to install git: https://opencobra.github.io/cobratoolbox/docs/requirements.html.\n');

    end
    % set the boolean as false (not installed)
    installed = false;
end
end

function [status_curl, result_curl] = checkCurlAndRemote(throwError)
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
    fprintf(' > Checking if curl is installed ... ')
end

origLD = getenv('LD_LIBRARY_PATH');
newLD = regexprep(getenv('LD_LIBRARY_PATH'), [matlabroot '/bin/' computer('arch') ':'], '');

% check if curl is properly installed
[status_curl, result_curl] = system('curl --version');

if status_curl == 0 && ~isempty(strfind(result_curl, 'curl')) && ~isempty(strfind(result_curl, 'http'))
    if ENV_VARS.printLevel
        fprintf(' Done.\n');
    end
elseif ((status_curl == 127 || status_curl == 48) && isunix)
    % status_curl of 48 is "An unknown option was passed in to libcurl"
    % status_curl of 127 is a bash/shell error for "command not found"
    % You can get either if there is mismatch between the library
    % libcurl and the curl program, which happens with matlab's
    % distributed libcurl. In order to avoid library mismatch we
    % temporarily fchange LD_LIBRARY_PATH
    setenv('LD_LIBRARY_PATH', newLD);
    [status_curl, result_curl] = system('curl --version');
    setenv('LD_LIBRARY_PATH', origLD);
    if status_curl == 0 && ~isempty(strfind(result_curl, 'curl')) && ~isempty(strfind(result_curl, 'http'))
        if ENV_VARS.printLevel
            fprintf(' Done.\n');
        end
    else
        if throwError
            fprintf(result_curl);
            fprintf(' > Please follow the guidelines on how to install curl: https://opencobra.github.io/cobratoolbox/docs/requirements.html.\n');
            error(' > curl is not installed.');
        else
            if ENV_VARS.printLevel
                fprintf(' (not installed).\n');
            end
        end
    end
else
    if throwError
        if ispc
            fprintf('(not installed).\n');
            installGitBash();
        else
            fprintf(result_curl);
            fprintf(' > Please follow the guidelines on how to install curl: https://opencobra.github.io/cobratoolbox/docs/requirements.html.\n');
            error(' > curl is not installed.');
        end
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
if status_curl == 0 && ~isempty(strfind(result_curl, ' 200'))
    if ENV_VARS.printLevel
        fprintf(' Done.\n');
    end
elseif ((status_curl == 127 || status_curl == 48) && isunix)
    setenv('LD_LIBRARY_PATH', newLD);
    [status_curl, result_curl] = system('curl -s -k --head https://github.com/opencobra/cobratoolbox');
    setenv('LD_LIBRARY_PATH', origLD);
    if status_curl == 0 && ~isempty(strfind(result_curl, ' 200'))
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
