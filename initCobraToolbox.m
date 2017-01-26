%initCobraToolbox Initialize COnstraint-Based Reconstruction and Analysis Toolbox
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
global CBTDIR
global MINOSPATH
global DQQMINOSPATH
global WAITBAR_TYPE
global WAITBAR_HANDLE

WAITBAR_TYPE = 1;

fprintf('\n\n      _____   _____   _____   _____     _____     |\n     /  ___| /  _  \\ |  _  \\ |  _  \\   / ___ \\    |   COnstraint-Based Reconstruction and Analysis\n     | |     | | | | | |_| | | |_| |  | |___| |   |   COBRA Toolbox 2.0 - 2017\n     | |     | | | | |  _  { |  _  /  |  ___  |   |\n     | |___  | |_| | | |_| | | | \\ \\  | |   | |   |   Documentation:\n     \\_____| \\_____/ |_____/ |_|  \\_\\ |_|   |_|   |   http://opencobra.github.io/cobratoolbox\n                                                  | \n\n');

fprintf('\n\n > Adding all the COBRA Toolbox files ... ')

pth = which('initCobraToolbox.m');
CBTDIR = pth(1:end-(length('initCobraToolbox.m')+1));
%path(path,[CBTDIR, filesep, 'external']);

addpath(genpath(CBTDIR))
rmpath([CBTDIR, filesep, '.git'])
rmpath([CBTDIR, filesep, '/deprecated'])
rmpath([CBTDIR, filesep, '/external/SBMLToolbox'])
fprintf(' Done.\n')

% add SMBL lib path
% temporary comment
%fprintf(' > Adding all the SBML Toolbox library files ... ')

%if isunix && exist('usr/local/lib/', 'dir')
%  addpath('/usr/local/lib/');
%end
%fprintf(' Done.\n')

%% Define Solvers
% Define the default linear programming solver to be used by the toolbox
% Available solver options are given in allSolverNames.
% Note that you must install the solver separately and make sure Matlab can
% access the solver

% create a summary table
allSolverNames  = {'lindo_old';'lindo_new';'glpk';...
                   'mosek';'tomlab_cplex';'cplex_direct';'ibm_cplex';...
                   'lp_solve';'pdco';'gurobi';'gurobi5';'gurobi6';...
                   'mps';'quadMinos';'dqqMinos';'opti'; 'matlab'; 'tomlab_snopt'};

% define categories of solvers: LP, MILP, QP, MIQP
solverTypes     = {'LP', 'MILP', 'QP', 'MIQP', 'NLP'};
solverStatus    = - ones(length(allSolverNames),length(solverTypes));

% define individual solver categories
catSolverNames    = {};
catSolverNames{1} = {'gurobi6','gurobi5', 'gurobi', 'tomlab_cplex', 'glpk', 'mosek', 'cplex_direct', 'ibm_cplex'}; % LP
catSolverNames{2} = {'gurobi6','gurobi5', 'gurobi', 'tomlab_cplex', 'glpk', 'cplex_direct', 'ibm_cplex'}; % MILP
catSolverNames{3} = {'gurobi6','gurobi5', 'gurobi', 'tomlab_cplex', 'qpng' }; % QP
catSolverNames{4} = {'gurobi6','gurobi5', 'tomlab_cplex'}; % MIQP
catSolverNames{5} = {'matlab', 'tomlab_snopt'}; % NLP

% check the installation of the solver
for i = 1:length(solverTypes)
    fprintf('\n-- Checking the installation of %s solvers --\n\n', char(solverTypes(i)));
    for CobraLPSolver = catSolverNames{i}
        fprintf(' > Testing %s ... ', char(CobraLPSolver))
        solverOK = changeCobraSolver(char(CobraLPSolver), char(solverTypes(i)));
        if solverOK
            fprintf(' Passed.\n')
            solverStatus( find(strcmp(allSolverNames, char(CobraLPSolver))), i) = 1;
        else
            fprintf(' Failed.\n')
            solverStatus( find(strcmp(allSolverNames, char(CobraLPSolver))), i) = 0;
        end
    end
end

% Define default CB map output
fprintf('Define CB map output...\n');
for CbMapOutput = {'svg', 'matlab'}
    CbMapOutputOK = changeCbMapOutput(char(CbMapOutput));
    if CbMapOutputOK; break; end
end
if CbMapOutputOK
    fprintf('CB map output: %s\n\n',char(CbMapOutput));
else
    fprintf('Cb map output: FAILED\n\n');
end

% Set global LP solution accuracy tolerance
changeCobraSolverParams('LP', 'optTol', 1e-6);

%attempt to provide support for sbml
if exist([CBTDIR, filesep, 'external' filesep 'SBMLToolbox-4.1.0'],'dir')==7 && exist([CBTDIR, filesep, 'external' filesep 'libsbml-5.11.0'],'dir')==7
    SBMLToolboxPath=[CBTDIR, filesep, 'external' filesep 'SBMLToolbox-4.1.0' filesep 'toolbox'];
    path(path,SBMLToolboxPath);
    %CBTDIR/cobratoolbox/external/libsbml-5.11.0/compiled/lib
    %sbmlBindingsPath=[CBTDIR, filesep, 'external' filesep 'libsbml-5.11.0'
    %filesep 'compiled' filesep 'lib']; -old
    sbmlBindingsPath=[CBTDIR, filesep, 'external' filesep 'libSBML-5.11.4-matlab'];
    path(path,sbmlBindingsPath);
    setenv('LD_LIBRARY_PATH',[getenv('LD_LIBRARY_PATH') ':' sbmlBindingsPath])
    getenv('LD_LIBRARY_PATH');

    if 1
        currentPath=pwd;
        cd(SBMLToolboxPath)
        run('installSBMLToolbox')
        cd(currentPath)
    end
end
% Check that SBML toolbox is installed and accessible
if ~exist('TranslateSBML','file')
    warning('SBML Toolbox not in Matlab path: COBRA Toolbox will be unable to read SBML files');
end

%Test the installation with:
xmlTestFile = strcat([CBTDIR, filesep, 'testing', filesep, 'testSBML', filesep, 'Ecoli_core_ECOSAL.xml']);

fPath = {'Ecoli_core_ECOSAL.xml'; 'testSBML'; 'testing'};

if ~isequal(exist(fPath{1},'file'),2)
    fprintf('the testing XML file - ''%s'' is missing from the COBRA folder.\n',fPath{1});
    if ~isequal(exist(fPath{2},'dir'),7)
        fprintf('the testing folder ''%s'' is missing from the COBRA folder.\n',fPath{2});
        if ~isequal(exist(fPath{3},'dir'),7)
            fprintf('the testing folder ''%s'' is missing from the COBRA folder.\n',fPath{3});
        end
    end
else
    try
        TranslateSBML(xmlTestFile);
        fprintf('%s\n', 'TranslateSBML worked with the test .xml file: Ecoli_core_ECOSAL.xml')
    catch
        warning('TranslateSBML did not work with the test .xml file: Ecoli_core_ECOSAL.xml')
    end

end

%quadMinos and dqqMinos support
[status,cmdout]=system('which minos');
if ~isempty(cmdout)
    MINOSPATH=cmdout(1:end-length('/bin/minos')-1);
end
[status,cmdout]=system('which run1DQQ');
if ~isempty(cmdout)
    str=strrep(cmdout,'//run1DQQ','/run1DQQ');
    DQQMINOSPATH=str(1:end-length('/run1DQQ')-1);
end

%saves the current paths
savepath

% print out a summary table
solverSummary = table(solverStatus(:,1),solverStatus(:,2),solverStatus(:,3),solverStatus(:,4),solverStatus(:,5),'RowNames',allSolverNames, 'VariableNames', solverTypes)
fprintf(' + Legend: -1 = not applicable, 0 = solver not installed, 1 = solver installed.\n\n')

for i = 1:length(solverTypes)
    fprintf(' + %s solvers: %i not applicable, %i failed, %i passed\n', char(solverTypes(i)), sum(solverStatus(:,i)==-1),sum(solverStatus(:,i)==0),sum(solverStatus(:,i)==1));
end

fprintf('\n');

% provide clear instructions and summary
for i = 1:length(solverTypes)
    if sum(solverStatus(:,i)==1) == 0
        fprintf(' >> You cannot solve %s problems on this system. Consider installing a %s solver.\n', char(solverTypes(i)), char(solverTypes(i)));
    else
        if sum(solverStatus(:,i)==-1) > 0
            fprintf(' >> You can solve %s problems on this system, but some solvers may not be usable (see above summary).\n', char(solverTypes(i)));
        else
            fprintf(' >> You can solve %s problems. All solvers have been tested, but some failed (see above summary).\n', char(solverTypes(i)));
        end
    end
end

fprintf('\n')
