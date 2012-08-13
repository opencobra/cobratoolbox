function solverOK = changeCobraSolver(solverName,solverType)
%changeCobraSolver Changes the Cobra Toolbox optimization solver(s)
%
% solverOK = changeCobraSolver(solverName,solverType)
%
%INPUTS
% solverName    Solver name
% solverType    Solver type, 'LP', 'MILP', 'QP', 'MIQP' (opt, default
%               'LP', 'all').  'all' attempts to change all applicable
%               solvers to solverName.  This is purely a shorthand
%               convenience.
%
%OUTPUT
% solverOK      true if solver can be accessed, false if not
%
% Currently allowed LP solvers:
%   lindo_new       Lindo API >v2.0
%   lindo_old       Lindo API <v2.0
%   glpk            GLPK solver with Matlab mex interface (glpkmex)
%   lp_solve        lp_solve with Matlab API
%   tomlab_cplex    CPLEX accessed through Tomlab environment (default)
%   cplex_direct    CPLEX accessed direct to Tomlab cplex.m. This gives
%                   the user more control of solver parameters. e.g.
%                   minimising the Euclidean norm of the internal flux to
%                   get rid of net flux around loops
%   mosek           Mosek LP solver with Matlab API (using linprog.m included in Mosek
%                   package)
%   gurobi          Gurobi accessed through Matlab mex interface (Gurobi mex)
%   gurobi5         Gurobi 5.0 accessed through built-in Matlab mex interface
%   matlab          Matlab's own linprog.m (currently unsupported, may not
%                   work on COBRA-type LP problems)
%   mps             Outputs a MPS matrix string. Does not solve LP problem
%
% Currently allowed MILP solvers:
%   tomlab_cplex    CPLEX MILP solver accessed through Tomlab environment
%   glpk            glpk MILP solver with Matlab mex interface (glpkmex)
%   gurobi          Gurobi accessed through Matlab mex interface (Gurobi mex)
%   gurobi5         Gurobi 5.0 accessed through built-in Matlab mex interface
%   mps             Outputs a MPS matrix string. Does not solve MILP
%                   problem
%
% Currently allowed QP solvers:
%   tomlab_cplex    CPLEX QP solver accessed through Tomlab environment
%   qpng            qpng QP solver with Matlab mex interface (in glpkmex
%                   package, only limited support for small problems)
%   gurobi5         Gurobi 5.0 accessed through built-in Matlab mex interface
%
% Currently allowed MIQP solvers:
%   tomlab_cplex    CPLEX MIQP solver accessed through Tomlab environment
%   gurobi5         Gurobi 5.0 accessed through built-in Matlab mex interface
%
% Currently allowed NLP solvers
%   matlab          MATLAB's fmincon.m
%   tomlab_snopt    SNOPT solver accessed through Tomlab environment
%
% it is a good idea to put this function call into your startup.m file
% (usually matlabinstall/toolboxes/local/startup.m)
% Markus Herrgard 1/19/07
global CBTLPSOLVER;
global CBT_MILP_SOLVER;
global CBT_QP_SOLVER;
global CBT_MIQP_SOLVER;
global CBT_NLP_SOLVER;

if (nargin < 1)
    display('The solvers defined are: ');
    display(CBTLPSOLVER);
    if ~isempty(CBT_MILP_SOLVER), display(CBT_MILP_SOLVER); end
    if ~isempty(CBT_QP_SOLVER), display(CBT_QP_SOLVER); end
    if ~isempty(CBT_MIQP_SOLVER), display(CBT_MIQP_SOLVER); end
    if ~isempty(CBT_NLP_SOLVER), display(CBT_NLP_SOLVER); end
    solverOK = false;
    return;
end

if (nargin < 2)
    solverType = 'LP';
end

solverOK = false;
solverType = upper(solverType);

if (strcmp(solverType, 'ALL'))
    changeCobraSolver(solverName,'LP');
    changeCobraSolver(solverName,'MILP');
    changeCobraSolver(solverName,'QP');
    changeCobraSolver(solverName,'MIQP');
end

% Only LP is currently included
if (strcmp(solverType,'LP'))
    %% LP solver
    solverOK = true;
    % Check that the LP solver is installed and accessible
    switch solverName
        case {'lindo_old','lindo_new'}
            if (~exist('mxlindo'))
                warning('LP solver Lindo not usable: mxlindo.dll not in Matlab path');
                solverOK = false;
            end
        case 'glpk'
            if (~exist('glpkmex'))
                warning('LP solver glpk not usable: glpkmex not in Matlab path');
                solverOK = false;
            end
        case 'mosek'
            if (~exist('mosekopt'))
                warning('LP solver Mosek not usable: mosekopt.m not in Matlab path');
                solverOK = false;
            end
        case 'tomlab_cplex'
            if (~exist('tomRun'))
                warning('LP solver CPLEX through Tomlab not usable: tomRun.m not in Matlab path');
                solverOK = false;
            end
        case 'cplex_direct'
            if (~exist('solveCobraLPCPLEX'))
                warning('LP solver CPLEX through Tomlab not usable: tomRun.m not in Matlab path');
                solverOK = false;
            end
        case 'lp_solve'
            if (~exist('lp_solve'))
                warning('LP solver lp_solve not usable: lp_solve.m not in Matlab path');
                solverOK = false;
            end
        case 'pdco'
            if (~exist('pdco'))
                warning('LP solver pdco not usable: pdco.m not in Matlab path');
                solverOK = false;
            end
        case 'gurobi'
            if (~exist('gurobi_mex'))
                warning('LP solver Gurobi not useable: gurobi_mex not in Matlab path');
                solverOK=false;
            end
        case 'gurobi5'
            if (~exist('gurobi'))
                warning('LP solver Gurobi not useable: gurobi.m not in Matlab path');
                solverOK=false;
            end
        case 'mps'
            if (~exist('BuildMPS'))
                warning('MPS not usable: BuildMPS.m not in Matlab path');
                solverOK = false;
            end
        otherwise
            warning(['LP solver ' solverName ' not supported by COBRA Toolbox']);
            solverOK = false;
    end
    if solverOK
        CBTLPSOLVER = solverName;
    end
elseif (strcmp(solverType,'MILP'))
    %% MILP solver
    solverOK = true;  
    % Check that the LP solver is installed and accessible
    switch solverName
        case 'tomlab_cplex'
            if (~exist('tomRun'))
                warning('MILP solver CPLEX through Tomlab not usable: tomRun.m not in Matlab path');
                solverOK = false;
            end
        case 'glpk'
            if (~exist('glpkmex'))
                warning('MILP solver glpk not usable: glpkmex not in Matlab path');
                solverOK = false;
            end
        case 'gurobi'
            if (~exist('gurobi_mex'))
                warning('MILP solver Gurobi not useable: gurobi_mex not in Matlab path');
                solverOK=false;
            end
        case 'gurobi5'
            if (~exist('gurobi'))
                warning('MILP solver Gurobi not useable: gurobi.m not in Matlab path');
                solverOK=false;
            end
        case 'mps'
            if (~exist('BuildMPS'))
                warning('MPS not usable: BuildMPS.m not in Matlab path');
                solverOK = false;
            end
        otherwise
            warning(['MILP solver ' solverName ' not supported by COBRA Toolbox']);
            solverOK = false;
    end
    if solverOK
        CBT_MILP_SOLVER = solverName;
    end
elseif (strcmp(solverType,'QP'))
    %% QP solver
    switch solverName
        case 'tomlab_cplex'
            if (~exist('tomRun'))
                warning('QP solver CPLEX through Tomlab not usable: tomRun.m not in Matlab path');
                solverOK = false;
            else
                solverOK = true;
            end
        case 'qpng'
            if (~exist('qpng'))
                warning('QP solver qpng not usable: qpng.m not in Matlab path');
                solverOK = false;
            else
                warning('qpng solver has not been fully tested - results may not be correct');
                solverOK = true;
            end
        case 'mosek'
            if (~exist('mskqpopt'))
                warning('QP solver mskqpopt not usable: mskqpopt.m not in Matlab path');
                solverOK = false;
            else
                solverOK = true;
            end
        case 'pdco'
            if (~exist('pdco'))
                warning('QP solver pdco not usable: pdco.m not in Matlab path');
                solverOK = false;
            else
                solverOK = true;
            end
        case 'gurobi'
            if (~exist('gurobi_mex'))
                warning('QP solver Gurobi not useable: gurobi_mex not in Matlab path');
                solverOK=false;
            else
                solverOK=true;
            end
        case 'gurobi5'
            if (~exist('gurobi'))
                warning('QP solver Gurobi not useable: gurobi.m not in Matlab path');
                solverOK=false;
            else
                solverOK=true;
            end
        otherwise
            warning(['QP solver ' solverName ' not supported by COBRA Toolbox']);
            solverOK = false;
    end
    if solverOK
        CBT_QP_SOLVER = solverName;
    end
elseif (strcmp(solverType, 'MIQP'))
    %MIQP solver
    switch solverName
        case 'tomlab_cplex'
            if(~exist('tomRun'))
                warning('MIQP solver CPLEX through Tomlab not usable: tomRun.m not in Matlab path');
                solverOK = false;
            else
                solverOK = true;
            end
        case 'gurobi'
            if(~exist('gurobi_mex'))
                warning('MIQP solver gurobi not usable: gurobi_mex not in Matlab path');
                solverOK = false;
            else
                solverOK = true;
            end
        case 'gurobi5'
            if(~exist('gurobi'))
                warning('MIQP solver gurobi not usable: gurobi.m not in Matlab path');
                solverOK = false;
            else
                solverOK = true;
            end
        otherwise
            warning(['MIQP solver ' solverName ' not supported by COBRA Toolbox']);
            solverOK = false;
    end
    if solverOK
        CBT_MIQP_SOLVER = solverName;
    end
elseif (strcmp(solverType, 'NLP'))
    %NLP solver
    switch solverName
        case 'matlab'
            solverOK = true;
        case 'tomlab_snopt'
            if(~exist('tomRun'))
                warning('MIQP solver CPLEX through Tomlab not usable: tomRun.m not in Matlab path');
                solverOK = false;
            else
                solverOK = true;
            end
        otherwise
            warning(['NLP solver ' solverName ' not supported by COBRA Toolbox']);
            solverOK = false;
    end
    if solverOK
        CBT_NLP_SOLVER = solverName;
    end
end