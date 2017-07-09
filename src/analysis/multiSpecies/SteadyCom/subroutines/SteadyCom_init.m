function [modelCom, ibm_cplex, feasTol, solverParams, parameters, ...
    varNameDisp, xName, m, n, nSp, nRxnSp] = SteadyCom_init(modelCom, varargin)
% subroutine for the initialization step for all SteadyCom functions

[m, n] = size(modelCom.S);  % model size
nSp = numel(modelCom.indCom.spBm);  % number of organisms
nRxnSp = sum(modelCom.indCom.rxnSps > 0);  % number of organism-specific rxns

% check required fields for community model
if ~isfield(modelCom,'indCom')
    if ~isfield(modelCom,'infoCom') || ~isstruct(modelCom.infoCom) || ...
            ~all(isfield(modelCom.infoCom,{'spBm','EXcom','EXsp','spAbbr','rxnSps','metSps'}))
        error('*.infoCom or *.indCom must be provided.\n');
    end
    % get useful reaction indices
    modelCom.indCom = infoCom2indCom(modelCom);
end
% check solveCobraLP parameter arguments
isParamStruct = cellfun(@isstruct, varargin);
if numel(varargin) > 1 && any(isParamStruct(2:end-1))
    error('Invalid parameter input (solver-specific parameter structure must be either the 1st or the last arguement among the parameter arguments.');
end
isParamDefault = strcmp(varargin, 'default');
try
    parameters = struct(varargin{~isParamStruct & ~isParamDefault});
catch
    error('Invalid parameter name-value pairs.')
end
% switch to use the Cplex class by IBM ILOG if it is the current solver
global CBT_LP_SOLVER
ibm_cplex = strcmp(CBT_LP_SOLVER, 'ibm_cplex');
% get the solver-specific parameter structure (allow multiple input structures)
solverParams = struct();
for jP = 1:numel(varargin)
    if isParamStruct(jP)
        fields = fieldnames(varargin{jP});
        for jF = 1:numel(fields)
            solverParams.(fields{jF}) = varargin{jP}.(fields{jF});
        end
    end
end
% get feasibility tolerance
feasTol = getCobraSolverParams('LP', {'feasTol'}, parameters);
if ibm_cplex  % specific setting for ibm_cplex
    if isempty(fieldnames(solverParams))
        %default Cplex parameters
        solverParams = getSteadyComParams('CplexParam');
    elseif isfield(solverParams,'simplex') && isfield(solverParams.simplex, 'tolerances') && isfield(solverParams.simplex.tolerances,'feasibility')
        % override the feasTol in CobraSolverParam if given in solverParams
        feasTol = solverParams.simplex.tolerances.feasibility;
    end
    % make sure Cplex use the same feasTol as this script 
    solverParams.simplex.tolerances.feasibility = feasTol;
end
if isfield(modelCom, 'infoCom')
    % reaction/biomass name for display
    varNameDisp = [modelCom.rxns; strcat('X_', modelCom.infoCom.spAbbr(:))];
    % alternative biomass variable name for recovering variable indices
    xName = strcat('X_', strtrim(cellstr(num2str((1:nSp)'))));
else
    % reaction/biomass name for display
    varNameDisp = [modelCom.rxns; strcat('X_', strtrim(cellstr(num2str((1:nSp)'))))];
    xName = {};
end

end