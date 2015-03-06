function initCobraToolbox(CobraLPSolver)
%initCobraToolbox Initialize COnstraint-Based Reconstruction and Analysis Toolbox
%
% Define default solvers and paths
% Function only needs to be called once. Save paths afer script terminates.
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
% Markus Herrgard 8/30/06
%
% Rewritten to utilize addpath_recurse. Richard Que (11/19/09)

%% add cobra toolbox paths
pth=which('initCobraToolbox.m');
global CBTDIR
CBTDIR = pth(1:end-(length('initCobraToolbox.m')+1));
path(path,[CBTDIR, filesep, 'external']);
addpath_recurse(CBTDIR,{'.git','obsolete','m2html','docs','src','stow'});

%% Define Solvers
% Define the default linear programming solver to be used by the toolbox
% Available solver options:
% 'lindo_new','lindo_old','glpk','lp_solve','mosek','tomlab_cplex',
% 'cplex_direct','gurobi'
% Note that you must install the solver separately and make sure Matlab can
% access the solver
if ~exist('CobraLPSolver','var')
    CobraLPSolver = 'tomlab_cplex';
    % CobraLPSolver = 'glpk';
    %CobraLPSolver = 'mosek';
    % CobraLPSolver = 'cplx';
end
if isunix
  addpath('/usr/local/lib/');
end
CobraLPSolvers = { 'gurobi5', 'gurobi', 'tomlab_cplex', 'glpk', 'mosek', 'cplx' };
for CobraLPSolver = CobraLPSolvers
    LPsolverOK = changeCobraSolver(char(CobraLPSolver));
    if LPsolverOK
        fprintf('LP solver set to %s successful\n',char(CobraLPSolver));
    	break;
    end
end
if ~LPsolverOK
    fprintf('LP solver set failed\n');
end
% Define default MILP solver
%CobraMILPSolver = 'tomlab_cplex';
%CobraMILPSolver = 'glpk';
for CobraMILPSolver = { 'gurobi5', 'gurobi', 'tomlab_cplex', 'glpk' }
    MILPsolverOK = changeCobraSolver(char(CobraMILPSolver),'MILP');
    if MILPsolverOK
        fprintf('MILP solver set to %s successful\n',char(CobraMILPSolver));
        break;
   end 
end
if ~MILPsolverOK
    fprintf('MILP solver set failed\n');
end
% Define default QP solver
%CobraQPSolver = 'tomlab_cplex';
for CobraQPSolver = {'gurobi5', 'gurobi', 'tomlab_cplex', 'qpng' }
    QPsolverOK = changeCobraSolver(char(CobraQPSolver),'QP');
    if QPsolverOK
        fprintf('QP solver set to %s successful\n',char(CobraQPSolver));
        break;
    end
end
if ~QPsolverOK
    fprintf('QP solver set failed\n');
end
% Define default MIQP solver
for CobraMIQPSolver = {'gurobi5', 'gurobi' 'tomlab_cplex'}
    MIQPsolverOK = changeCobraSolver(char(CobraMIQPSolver),'MIQP');
    if MIQPsolverOK
        fprintf('MIQP solver set to %s successful\n',char(CobraMIQPSolver));
        break;
    end
end
if ~MIQPsolverOK
    fprintf('MIQP solver set failed\n');
end


% Define default CB map output
% CbMapOutput = 'matlab';
CbMapOutput = 'svg';
CbMapOutputOK = changeCbMapOutput(CbMapOutput);
if CbMapOutputOK
    fprintf('CB map output set to %s successful\n',CbMapOutput);
else
    fprintf('Cb map output set failed\n');
end

% Set global LP solution accuracy tolerance
changeOK = changeCobraSolverParams('LP','objTol',1e-6);

if exist([CBTDIR, filesep, 'external' filesep 'SBMLToolbox-4.1.0'],'dir')==7 && exist([CBTDIR, filesep, 'external' filesep 'sbml' filesep 'libsbml-5.10.2'],'dir')==7
    path(path,[CBTDIR, filesep, 'external' filesep 'SBMLToolbox-4.1.0' filesep 'toolbox']);
    %cobratoolbox/external/sbml/libsbml-5.10.2/src/bindings/matlab
    sbmlBindingsPath=[CBTDIR, filesep, 'external' filesep 'sbml' filesep 'libsbml-5.10.2' filesep 'src' filesep 'bindings' filesep 'matlab'];
    path(path,sbmlBindingsPath);
    setenv('LD_LIBRARY_PATH',[getenv('LD_LIBRARY_PATH') ';' sbmlBindingsPath])
    getenv('LD_LIBRARY_PATH')
    %now attempt to install
    %UBUNTU 14.04 LTS
    if isunix
        fprintf('make sure that xml2 is installed')
        fprintf('sudo apt-get install xml2')
        %TODO - windows bindings, only ubuntu bindings available at the moment
    installSBMLToolbox
    %http://sbml.org/Software/SBMLToolbox/SBMLToolbox_4.0_API_Manual
end
% Check that SBML toolbox is installed and accessible
if (~exist('TranslateSBML','file'))
    warning('SBML Toolbox not in Matlab path: COBRA Toolbox will be unable to read SBML files');
end


