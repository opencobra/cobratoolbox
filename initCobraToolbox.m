% initCobraToolbox Initialize COnstraint-Based Reconstruction and Analysis Toolbox
%
% Defines default solvers and paths, tests SBML io functionality.
% Function only needs to be called once per installation. Saves paths afer script terminates.
%
% In addition add either of the following into startup.m (generally in MATLAB_DIRECTORY/toolbox/local/startup.m)
%     initCobraToolbox
%           -or-
%     changeCobraSolver('gurobi');
%     changeCobraSolver('gurobi', 'MILP');
%     changeCobraSolver('tomlab_cplex', 'QP');
%     changeCobraSolver('tomlab_cplex', 'MIQP');
%     changeCbMapOutput('svg');
%

% Maintained by Ronan M.T. Fleming

%% Add cobra toolbox paths
global CBTDIR;
global SOLVERS;
global OPTIMIZATIONPROBLEMTYPES;
global GUROBI_PATH;
global CPLEX_PATH;
global TOMLAB_PATH;
global MOSEK_PATH;
global WAITBAR_TYPE;

WAITBAR_TYPE = 1;

fprintf('\n\n      _____   _____   _____   _____     _____     |\n     /  ___| /  _  \\ |  _  \\ |  _  \\   / ___ \\    |   COnstraint-Based Reconstruction and Analysis\n     | |     | | | | | |_| | | |_| |  | |___| |   |   COBRA Toolbox 2.0 - 2017\n     | |     | | | | |  _  { |  _  /  |  ___  |   |\n     | |___  | |_| | | |_| | | | \\ \\  | |   | |   |   Documentation:\n     \\_____| \\_____/ |_____/ |_|  \\_\\ |_|   |_|   |   http://opencobra.github.io/cobratoolbox\n                                                  | \n\n');

fprintf('\n\n > Initializing submodules ... ')
% Throw an error if the user has a bare repository or a copy of The COBRA Toolbox
% that is not a git repository.
currentDir = pwd;
CBTDIR = fileparts(which('initCobraToolbox'));
if ~(exist([CBTDIR filesep '.git'], 'dir') == 7)
    error('This directory is not a git repository.\nSumodules cannot be initialized.');
end
cd(CBTDIR);
[status_submodule, result_submodule] = system(['git submodule update --init']);

if status_submodule == 0
    fprintf('Done.\n');
else
    result_submodule
    error('The submodules could not be initialized.');
end

fprintf(' > Adding all the COBRA Toolbox files ... ')

addpath(genpath(CBTDIR))
rmpath([CBTDIR, filesep, '.git'])
rmpath([CBTDIR, filesep, 'deprecated'])
rmpath([CBTDIR, filesep, 'external/SBMLToolbox'])
fprintf(' Done.\n')

fprintf(' > Fetching model files ... ')
retrieveModels
fprintf(' Done.\n')

fprintf(' > Checking available solvers\n')
GUROBI_PATH = getenv('GUROBI_PATH');
addpath(genpath(GUROBI_PATH));
ILOG_CPLEX_PATH = getenv('ILOG_CPLEX_PATH');
addpath(genpath(ILOG_CPLEX_PATH));
TOMLAB_PATH = getenv('TOMLAB_PATH');
addpath(genpath(TOMLAB_PATH));
TOMLAB_PATH = getenv('MOSEK_PATH');
addpath(genpath(TOMLAB_PATH));

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
    fprintf('    %15s: ', supportedSolversNames{i});
    solverOK = changeCobraSolver(supportedSolversNames{i}, SOLVERS.(supportedSolversNames{i}).type{1}, 0);
    if solverOK
        fprintf(' Installed.\n')
        SOLVERS.(supportedSolversNames{i}).installed = 1;
    else
        fprintf(' Not installed.\n')
    end
end

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

% saves the current paths
try
    savepath;
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

solverSummary = table(solverStatuss(:, 1), solverStatuss(:, 2), solverStatuss(:, 3), solverStatuss(:, 4), solverStatuss(:, 5), 'RowNames', rowNames, 'VariableNames', OPTIMIZATIONPROBLEMTYPES)
fprintf(' + Legend: - = not applicable, 0 = solver not installed, 1 = solver installed.\n\n')

fprintf('\n');

% provide clear instructions and summary
for i = 1:length(OPTIMIZATIONPROBLEMTYPES)
    if sum(solverStatus(:, i) == 1) == 0
        fprintf(' >> You cannot solve %s problems on this system. Consider installing a %s solver.\n', char(OPTIMIZATIONPROBLEMTYPES(i)), char(OPTIMIZATIONPROBLEMTYPES(i)));
    else
        fprintf(' >> You can solve %s problems on this system with: ', char(OPTIMIZATIONPROBLEMTYPES(i)));
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
