function varargout = getCobraSolverParams(problemType, paramNames, paramStructure)
% This function gets the specified paramStructure in `paramNames` from
% paramStructure, the global cobra parameters variable or default values set within
% this script. 
%
% It will use values with the following priority
% paramStructure > solver type paramStructure > default paramStructure
%
% The specified paramStructure will be delt to the specified output arguements.
% See examples below.
%
% USAGE:
%
%    varargout = getCobraSolverParams(problemType, paramNames, paramStructure)
%
% INPUTS:
%    problemType:   Type of problem solved: 'LP', 'MILP', 'QP', 'MIQP', 'EP', 'CLP'
%    paramNames:    Cell array of strings containing parameter names OR one
%                   parameter name as string
%
% OPTIONAL INPUTS:
%    paramStructure:    Structure with fields pertaining to parameter values that
%                   should be used in place of global or default paramStructure.
%                   paramStructure can be set to 'default' to use the default
%                   values set within this script.
%
% OUTPUTS:
%    varargout:     Variables which each value corresponding to paramNames
%                   is output to.
%                   In addition, if paramStructure is passed as an input, then
%                   the final output argument is paramStructureOut, with fields
%                   removed corresponding to paramNames
%
% EXAMPLE:
%    paramStructure.saveInput = 'LPproblem.mat';
%    paramStructure.printLevel = 1;
%    [printLevel, saveInput] = getCobraSolverParams('LP', {'printLevel', 'saveInput'}, paramStructure);
%
%    %Example using default values
%    [printLevel, saveInput] = getCobraSolverParams('LP', {'printLevel','saveInput'}, 'default');
%
% .. Authors:
%       - Richard Que (12/01/2009)
%       - Ronan (16/07/2013) default MPS paramStructure are no longer global variables

if ~exist('paramNames','var') || isempty(paramNames)
    %get the names of all the parameters
    defaultParamNames = getCobraSolverParamsOptionsForType(problemType);
else
    if ~iscell(paramNames)
        paramNames = {paramNames};
    end
end
if exist('paramStructure','var')
    overRideDefaults = 1;
    %overide defaults unless hack is asking for defaults
    if isstruct(paramStructure)
        paramStructureOut = paramStructure;
    else
        if ischar(paramStructure) && strcmp(paramStructure,'default')
           overRideDefaults=1;
        end
    end
else
    %the last argument will be the structure with defaults
    overRideDefaults=0;
    paramStructure=[];
end

% Persistence will make names specific to one type of solver.
% Default Values
% For descriptions of the different settings please have a look at 
% getCobraSolverParamsOptionsForType

% %These default tolerances are based on the default values for the Gurobi LP
% %solver. Do not change them without first consulting with other developers.
% %https://www.gurobi.com/documentation/9.0/refman/parameters.html
% % (primal) feasibility tolerance
% changeCobraSolverParams('LP', 'feasTol', 1e-6);
% % (dual) optimality tolerance
% changeCobraSolverParams('LP', 'optTol', 1e-6);
% 
% % (primal) feasibility tolerance
% changeCobraSolverParams('EP', 'feasTol', 1e-8);
% % (dual) optimality tolerance
% changeCobraSolverParams('EP', 'optTol', 1e-12);

%These default tolerances are based on the default values for the Gurobi LP solver
%https://www.gurobi.com/documentation/9.0/refman/paramStructure.html
valDef.feasTol = 1e-6; % (primal) feasibility tolerance
valDef.optTol = 1e-6;  % (dual) optimality tolerance

valDef.objTol = 1e-6; % this should be used only when comparing the values of two objective functions

valDef.minNorm = [];

valDef.printLevel = 0;
valDef.verify = 0;

valDef.primalOnly = 0;

valDef.timeLimit = 1e36; 
valDef.iterationLimit = 1000;

valDef.logFile = []; %log file should be empty to avoid creating it by default
valDef.saveInput = [];
valDef.problemType = problemType;
valDef.debug = 0;
valDef.lifting = 0;
valDef.multiscale=0;  % true if problem is multiscale

% tolerances
valDef.intTol = 1e-12;
valDef.relMipGapTol = 1e-12;
valDef.absMipGapTol = 1e-12;
valDef.NUMERICALEMPHASIS = 1;    

switch problemType
    case 'LP'
        global CBT_LP_PARAMS
        parametersGlobal = CBT_LP_PARAMS;
    case 'QP'
        global CBT_QP_PARAMS
        parametersGlobal = CBT_QP_PARAMS;
    case 'MILP'
        global CBT_MILP_PARAMS
        parametersGlobal = CBT_MILP_PARAMS;
    case 'EP'
        global CBT_EP_PARAMS
        parametersGlobal = CBT_EP_PARAMS;
        valDef.feasTol = 1e-6; % (primal) feasibility tolerance
        valDef.optTol = 1e-6;  % (dual) optimality tolerance
        valDef.solver='mosek';
        
    case 'CLP'
        % This is never used elsewhere except for parameter setting loop
        % for backward compatibility
        global CBT_CLP_PARAMS
        parametersGlobal = CBT_CLP_PARAMS;

        valDef.feasTol = 1e-6; % (primal) feasibility tolerance
        valDef.optTol = 1e-6;  % (dual) optimality tolerance
        valDef.solver='mosek';
    case 'MIQP'
        global CBT_MIQP_PARAMS
        parametersGlobal = CBT_MIQP_PARAMS;
    case 'NLP'
        global CBT_NLP_PARAMS
        parametersGlobal = CBT_NLP_PARAMS;
    otherwise
        display('Unrecognized solver type')
        return;
end

if exist('defaultParamNames','var')
    % set parameter structure values to default, unless they are overridden by paramStructure
    for i=1:length(defaultParamNames)
        if isfield(valDef,defaultParamNames{i})
            %structure of default parameter values
            paramStructureOut.(defaultParamNames{i})=valDef.(defaultParamNames{i});
        end
    end
end

varargout = cell(1, numel(paramNames));
paramNames = columnVector(paramNames);
for i=1:length(paramNames)
    % first set each value to default
    if isfield(valDef,paramNames{i})
        %list of default parameter values 
        varargout{i} = valDef.(paramNames{i});
        %structure of default parameter values
        paramStructureOut.(paramNames{i})= valDef.(paramNames{i});
    end

    if overRideDefaults
        % second set values to global values
        if isfield(parametersGlobal,paramNames{i})
            %list of default parameter values 
            varargout{i} = parametersGlobal.(paramNames{i});
            %structure of default parameter values
            paramStructureOut.(paramNames{i})=parametersGlobal.(paramNames{i});
        end
        % third set values to specified values in paramStructure
        if isfield(paramStructure,paramNames{i})
            varargout{i} = paramStructure.(paramNames{i});
            %structure of default parameter values
            paramStructureOut.(paramNames{i})=paramStructure.(paramNames{i});
        end
    end
end
if overRideDefaults
    varargout{length(paramNames)+1}=paramStructureOut;
end

