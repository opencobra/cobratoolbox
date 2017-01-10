function initCobraToolbox()
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

pth=which('initCobraToolbox.m');
CBTDIR = pth(1:end-(length('initCobraToolbox.m')+1));
path(path,[CBTDIR, filesep, 'external']);

%add all paths below cobra directory, but not certain folders
addpath_recurse(CBTDIR,{'.git','obsolete','m2html','docs','src','stow','libsbml-5.11.0','SBMLToolbox-4.1.0'});

% add SMBL lib path?
if isunix && exist('usr/local/lib/', 'dir')
  addpath('/usr/local/lib/');
end

%% Define Solvers
% Define the default linear programming solver to be used by the toolbox
% Available solver options:
% 'lindo_new','lindo_old','glpk','lp_solve','mosek','tomlab_cplex',
% 'cplex_direct','gurobi'
% Note that you must install the solver separately and make sure Matlab can
% access the solver

% Define LP solver
fprintf('Define LP solver...\n');
for CobraLPSolver = {'gurobi6','gurobi5', 'gurobi', 'tomlab_cplex', 'glpk', 'mosek', 'cplx'}
    LPsolverOK = changeCobraSolver(char(CobraLPSolver));
    if LPsolverOK; break; end
end
if LPsolverOK
    fprintf('LP solver: %s \n\n',char(CobraLPSolver));
else
    fprintf('LP solver: FAILED\n\n');
end

% Define default MILP solver
fprintf('Define MILP solver...\n');
for CobraMILPSolver = {'gurobi6','gurobi5', 'gurobi', 'tomlab_cplex', 'glpk' }
    MILPsolverOK = changeCobraSolver(char(CobraMILPSolver),'MILP');
    if MILPsolverOK; break; end 
end
if MILPsolverOK
    fprintf('MILP solver: %s\n\n',char(CobraMILPSolver));
else
    fprintf('MILP solver: FAILED\n\n');
end

% Define default QP solver
fprintf('Define QP solver...\n');
for CobraQPSolver = {'gurobi6','gurobi5', 'gurobi', 'tomlab_cplex', 'qpng' }
    QPsolverOK = changeCobraSolver(char(CobraQPSolver),'QP');
    if QPsolverOK; break; end
end
if QPsolverOK
    fprintf('QP solver: %s\n\n', char(CobraQPSolver));
else
    fprintf('QP solver: FAILED\n\n');
end

% Define default MIQP solver
fprintf('Define MIQP solver...\n');
for CobraMIQPSolver = {'gurobi6','gurobi5', 'gurobi' 'tomlab_cplex'}
    MIQPsolverOK = changeCobraSolver(char(CobraMIQPSolver),'MIQP');
    if MIQPsolverOK; break; end
end
if MIQPsolverOK
    fprintf('MIQP solver: %s\n\n',char(CobraMIQPSolver));
else
    fprintf('MIQP solver: FAILED\n\n');
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
changeCobraSolverParams('LP','optTol',1e-6);

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
if (~exist('TranslateSBML','file'))
    warning('SBML Toolbox not in Matlab path: COBRA Toolbox will be unable to read SBML files');
end

%Test the installation with:
xmlTestFile=strcat([CBTDIR,filesep,'testing',filesep,'testSBML',filesep','Ecoli_core_ECOSAL.xml']);

fPath={'Ecoli_core_ECOSAL.xml';
    'testSBML';
    'testing'};

if ~isequal(exist(fPath{1},'file'),2)
    fprintf('the testing XML file - ''%s'' is missing from the COBRA folder! \n',fPath{1});
    if ~isequal(exist(fPath{2},'dir'),7)
        fprintf('the testing folder ''%s'' is missing from the COBRA folder!!\n',fPath{2});
        if ~isequal(exist(fPath{3},'dir'),7)
            fprintf('the testing folder ''%s'' is missing from the COBRA folder!!\n',fPath{3});
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