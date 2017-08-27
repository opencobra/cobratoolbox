function varargout = SteadyComSubroutines(purpose, varargin)
% Calls different subroutines for `SteadyCom` functions
%
% USAGE:
%
%    varargout = SteadyComSubroutines(purpose, varargin)
%
% INPUT:
%    purpose:     'initialize' / 'infoCom2indCom' / 'rxnList2objMatrix' / 'updateLPcom' / 'getParams'
%                 See the respective local functions for their documentations
%    varargin:    various input for different subroutines

switch purpose
    case 'initialize'
        [varargout{1}, varargout{2}, varargout{3}, varargout{4}, varargout{5}, varargout{6}, ...
            varargout{7}, varargout{8}, varargout{9}, varargout{10}, varargout{11}] = initialize(varargin{:});
    case 'solveCobraLP_arg'
        [varargout{1}, varargout{2}] = solveCobraLP_arg(varargin{:});
    case 'infoCom2indCom'
        varargout{1} = infoCom2indCom(varargin{:});
    case 'rxnList2objMatrix'
        varargout{1} = rxnList2objMatrix(varargin{:});
    case 'updateLPcom'
        varargout{1} = updateLPcom(varargin{:});
    case 'getParams'
        varargout = getParams(varargin{:});
    otherwise
        varargout = {[]};
end
end

function [modelCom, ibm_cplex, feasTol, solverParams, parameters, varNameDisp, xName, m, n, nSp, nRxnSp] = initialize(modelCom, varargin)
% initialization step for all SteadyCom functions
%
% USAGE:
%    [modelCom, ibm_cplex, feasTol, solverParams, parameters, varNameDisp, xName, m, n, nSp, nRxnSp]
%        = initialize(modelCom, parameter, 'param1', value1, 'param2', value2, ...)
%
% INPUT:
%    modelCom:      A community COBRA model structure with the following fields (created using createMultipleSpeciesModel):
%    (the following fields are required)
%      S              stoichiometric matrix
%      b              right hand side
%      c              objective coefficients
%      lb             lower bounds
%      ub             upper bounds
%    (at least one of the below two is needed. Can be obtained using getMultiSpecisModelId)
%      infoCom        structure containing community reaction info
%      indCom         the index structure corresponding to infoCom
%
% OPTIONAL INPUTS:
%    parameter:              structure for solver-specific parameters.
%    'param1', value1, ...:  name-value pairs for solveCobraLP parameters. See solveCobraLP for details
%
% OUTPUTS:
%    modelCom:      modelCom with .indCom embedded
%    ibm_cplex:     true if the solver 'ibm_cplex' is used for Cobra Toolbox
%    feasTol:       feasibility tolerance
%    solverParams:  solver-specific parameters
%    parameters:    name-value paired parameters in a structure format
%    varNameDisp    cell array of rxn IDs + biomass variable IDs
%    xName          alternative biomass variable IDs if organism abbreviations (modelCom.infoCom.spAbbr) are given
%    m:             number of metabolites
%    n:             number of reactions
%    nSp:           number of organisms
%    nRxnSp:        number of organism-specific reactions

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
        solverParams = getParams('CplexParam');
        solverParams = solverParams{1};
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

function [options, arg] = solveCobraLP_arg(options, parameters, arg)
% handle solveCobraLP name-value arguments that are specially treated in SteadyCom functions
%
% USAGE:
%    [options, arg] = solveCobraLP_arg(options, parameters, arg)
%
% INPUTS:
%    options:       option structure
%    parameters:    name-value parameter structure
%    arg:           varargin for SteadyCom functions
%
% OUTPUTS:
%    options:       updated option structure
%    arg:           updated varargin

if isfield(parameters, 'printLevel')
    options.verbFlag = parameters.printLevel;
end
if isfield(parameters, 'minNorm')
    options.minNorm = ~isequal(parameters.minNorm, 0);
    f = find(cellfun(@(x) isequal(x, 'minNorm'), arg));
    arg{f + 1} = 0;
end
if isfield(parameters, 'saveInput')
    options.saveModel = parameters.saveInput;
    f = find(cellfun(@(x) isequal(x, 'saveInput'), arg));
    arg(f : (f + 1)) = [];
    options.saveFVA = [parameters.saveInput, '_fva'];
    options.savePOA = [parameters.saveInput, '_poa'];
end
end

function indCom = infoCom2indCom(modelCom, infoCom, revFlag, spAbbr, spName)
% Interconvert between community reaction/metabolite IDs (indCom) and names (infoCom).
% Both infoCom and indCom can be obtained using with getMultiSpeciesModelId.m
% This function helps to quickly convert between the two if one is missing.
%
% USAGE:
%    [1] indCom = infoCom2indCom(modelCom, infoCom)
%      OR
%    [2] infoCom = infoCom2indCom(modelCom, indCom, true, spAbbr, spName)
%
% INPUTS:
%    modelCom:      community COBRA model.
%  (for converting infoCom to indCom, usage [1])
%    infoCom:       structure containing community reaction/metabolite names
%                     If modelCom.infoCom exists, can omit this argument.
%  (for converting indCom to infoCom, usage [2])
%    indCom:        structure containing community reaction/metabolite IDs
%    spAbbr:        organisms' abbreviations
%    spName:        organisms' names (optional, default = spAbbr)
if nargin < 2
    if ~isfield(modelCom, 'infoCom')
        error('infoCom must be provided.\n');
    end
    infoCom = modelCom.infoCom;
end
if nargin < 3
    revFlag = false;
end
indCom = struct();
if ~revFlag
    %from infoCom to indCom
    if isfield(infoCom, 'spBm')
        indCom.spBm = findRxnIDs(modelCom, infoCom.spBm);
    end
    if isfield(infoCom, 'spATPM')
        indCom.spATPM = findRxnIDs(modelCom, infoCom.spATPM);
    end
    if isfield(infoCom, 'rxnSD')
        indCom.rxnSD = findRxnIDs(modelCom, infoCom.rxnSD);
    end
    indCom.EXcom = findRxnIDs(modelCom, infoCom.EXcom);
    indCom.EXsp = zeros(size(infoCom.EXsp));
    SpCom = ~cellfun(@isempty, infoCom.EXsp);
    indCom.EXsp(SpCom) = findRxnIDs(modelCom, infoCom.EXsp(SpCom));
    if isfield(infoCom, 'EXhost')
        if ~isempty(infoCom.EXhost)
            indCom.EXhost = findRxnIDs(modelCom, infoCom.EXhost);
        else
            indCom.EXhost = zeros(0, 1);
        end
    end
    indCom.Mcom = findMetIDs(modelCom, infoCom.Mcom);
    indCom.Msp = zeros(size(infoCom.Msp));
    if isfield(infoCom, 'Mhost')
        if ~isempty(infoCom.Mhost)
            indCom.Mhost = findMetIDs(modelCom, infoCom.Mhost);
        else
            indCom.Mhost = zeros(0, 1);
        end
    end
    SpCom = ~cellfun(@isempty, infoCom.Msp);
    indCom.Msp(SpCom) = findMetIDs(modelCom, infoCom.Msp(SpCom));
    [~, indCom.rxnSps] = ismember(infoCom.rxnSps, infoCom.spAbbr);
    [~, indCom.metSps] = ismember(infoCom.metSps, infoCom.spAbbr);
else
    %from indCom to infoCom
    if nargin < 4
        error('spAbbr must be provided to get the organisms'' abbreviations');
    end
    if nargin < 5
        spName = spAbbr;
    end
    if isfield(infoCom, 'spBm')
        indCom.spBm = modelCom.rxns(infoCom.spBm);
    end
    if isfield(infoCom,'spATPM')
        indCom.spATPM = modelCom.rxns(infoCom.spATPM);
    end
    if isfield(infoCom,'rxnSD')
        indCom.rxnSD = modelCom.rxns(infoCom.rxnSD);
    end
    indCom.EXcom = repmat({''}, size(infoCom.EXcom, 1), size(infoCom.EXcom, 2));
    indCom.EXcom(infoCom.EXcom ~= 0) = modelCom.rxns(infoCom.EXcom(infoCom.EXcom ~= 0));
    indCom.EXsp = repmat({''}, size(infoCom.EXsp, 1), size(infoCom.EXsp, 2));
    SpCom = infoCom.EXsp ~= 0;
    indCom.EXsp(SpCom) = modelCom.rxns(infoCom.EXsp(SpCom));
    if isfield(infoCom, 'EXhost')
        if ~isempty(infoCom.EXhost)
            indCom.EXhost = modelCom.rxns(infoCom.EXhost);
        else
            indCom.EXhost = cell(0, 1);
        end
    end
    indCom.Mcom = modelCom.mets(infoCom.Mcom);
    indCom.Msp = repmat({''},size(infoCom.Msp,1), size(infoCom.Msp,2));
    SpCom = infoCom.Msp ~= 0;
    indCom.Msp(SpCom) = modelCom.mets(infoCom.Msp(SpCom));
    if isfield(infoCom, 'Mhost')
        if ~isempty(infoCom.Mhost)
            indCom.Mhost = modelCom.mets(infoCom.Mhost);
        else
            indCom.Mhost = cell(0, 1);
        end
    end
    indCom.spAbbr = spAbbr;
    indCom.spName = spName;
    indCom.rxnSps = repmat({'com'}, numel(modelCom.rxns), 1);
    indCom.rxnSps(infoCom.rxnSps > 0) = spAbbr(infoCom.rxnSps(infoCom.rxnSps > 0));
    indCom.metSps = repmat({'com'}, numel(modelCom.mets), 1);
    indCom.metSps(infoCom.metSps > 0) = spAbbr(infoCom.metSps(infoCom.metSps > 0));
end
end

function objMatrix = rxnList2objMatrix(rxnList, varNameDisp, xName, n, nVar, callName)
% transform a list of K reactions or K linear combinations of reactions into a (#rxns + #organisms)-by-K matrix
% as the objective vectors to be optimized in SteadyComFVA and SteadyComPOA
%
% USAGE:
%    objMatrix = rxnList2objMatrix(rxnList, varNameDisp, xName, n, nVar, callName)
%
% INPUTS:
%    rxnNameList     list of K reactions or K linear combinations of reactions, in the format of either:
%                      - cell array, each cell being a reaction ID or a cell array of reaction IDs. For the latter,
%                        it is transformed as a column with 1 for each reaction (uniform sum)
%                        E.g., {'rxn1'; 'X_1'; {'rxn2'; 'X_2'}} becomes
%                              [1 0 0; (rxn1)
%                               0 0 1; (rxn2)
%                               0 1 0; (X_1)
%                               0 0 1] (X_2)
%                               for a model with 2 reactions and 2 organisms
%                      - a row vector of reaction index (#rxns + k for the biomass of the k-th organism)
%                        E.g., [3, 4] becomes [0 0; 0 0; 1 0; 0 1].
%                      - a direct (N_rxns + N_organism) x K matrix.
%    varNameDisp     cell array of rxn IDs + biomass variable IDs
%    xName          alternative biomass variable IDs if organism abbreviations (modelCom.infoCom.spAbbr) are given
%    n               number of reactions
%    nVar            number of variables in the LP problem
%    callName        name of the matrix to be transformed, for error message

if ischar(rxnList)
    % if input is a string, make it a cell
    rxnList = {rxnList};
end
if isnumeric(rxnList)  % if the input is numeric
    if size(rxnList,1) >= n && size(rxnList,1) <= nVar
        % it is a matrix of objective vectors
        objMatrix = [sparse(rxnList); sparse(nVar - size(rxnList,1), size(rxnList,2))];
    elseif size(rxnList, 1) == 1 || size(rxnList, 2) == 1
        % reaction index (better in row to distinguish from matrix input)
        objMatrix = sparse(rxnList, 1:numel(rxnList), ones(numel(rxnList),1),...
            nVar, max(size(rxnList)));
    else
        error(['Invalid numerical input of %s.\n', ...
            'Either a (#rxns + #organisms)-by-K matrix for K targets to be analyzed,\n'...
            'or an index row vector v (but not column vector)'], callName);
    end
elseif iscell(rxnList)  % if the input is a cell array
    [row, col] = deal([]);
    for jRxnName = 1:numel(rxnList)
        % Each rxnNameList{jRxnName} can be a cell array of reactions.
        % In this case, treat as the unweighted sum of the reactions
        [~, rJ] = ismember(rxnList{jRxnName}, varNameDisp);
        % check if names for biomass variables exist
        if ~all(rJ)
            invalidName = false;
            if ~isempty(xName)
                if iscell(rxnList{jRxnName})  % the cell contains a cell array of strings
                    [~, id] = ismember(rxnList{jRxnName}(rJ == 0), xName);
                    id(id ~= 0) = n + id(id ~= 0);  % biomass variable index = n + #organism
                    rJ(rJ == 0) = id;
                    if ~all(rJ)
                        invalidName = true;
                    end
                else  % if the cell contains a string not found in .rxns
                    id = strcmp(xName, rxnList{jRxnName});
                    if any(id)
                        rJ = find(id) + n;  % biomass variable index = n + #organism
                    else
                        invalidName = true;
                    end
                end
            else
                invalidName = true;
            end
            if invalidName
                if iscell(rxnList{jRxnName})
                    toPrint = strjoin(rxnList{jRxnName}(rJ == 0), ', ');
                else
                    toPrint = rxnList{jRxnName};
                end
                error('Invalid names in options.%s: #%d %s', callName, jRxnName, toPrint);
            end
        end
        [row, col] = deal([row; rJ(:)], [col; jRxnName * ones(numel(rJ), 1)]);
    end
    objMatrix = sparse(row, col, 1, nVar, numel(rxnList));
else
    error('Invalid input of %s. Either cell array or numeric input.', callName);
end
end

function LPproblem = updateLPcom(modelCom, grCur, GRfx, BMcon, LPproblem, BMgdw)
% Create the LP problem [LP(grCur)] given growth rate grCur and other
% constraints if LPproblem in the input does not contain the field 'A',
% or is empty or is not given.
% Otherwise, update LPproblem with the growth rate grCur. Only the
% arguments 'modelCom', 'grCur', 'GRfx' and 'LPproblem' are used in this case.
%
% Usage:
%   LPproblem = updateLPcom(modelCom, grCur, GRfx, BMcon, LPproblem, BMgdw)
%
% Input:
%   modelCom:   community model
%   grCur:      the current growth rate for the LP to be updated to
%   GRfx:       fixed growth rates for certain organisms
%   BMcon:      constraint matrix for organism biomass
%   LPproblem:  LP problem structure with field 'A' or the problem matrix
%               directly
%   BMgdw:      the gram dry weight per mmol of the biomass reaction of
%               each organism (nSp x 1 vector, default all 1)
%
% Return a structure with the field 'A' updated if the input 'LPproblem' is
% a structure or return a matrix if 'LPproblem' is the problem matrix
m = size(modelCom.S, 1);
n = size(modelCom.S, 2);
nRxnSp = sum(modelCom.indCom.rxnSps > 0);
nSp = numel(modelCom.infoCom.spAbbr);
if ~exist('grCur', 'var')
    grCur = 0;
elseif isempty(grCur)
    grCur = 0;
end
if ~exist('GRfx', 'var') || isempty(GRfx)
    GRfx  = getParams({'GRfx'}, struct(), modelCom);
    GRfx = GRfx{1};
end
if ~exist('LPproblem', 'var')
    LPproblem = struct();
end

construct = false;
if ~isstruct(LPproblem)
    if isempty(LPproblem)
        construct = true;
    end
elseif ~isfield(LPproblem, 'A')
    construct = true;
end
if construct
    if ~exist('BMgdw', 'var')
        BMgdw = ones(nSp,1);
    end
    %upper bound matrix
    S_ub = sparse([1:nRxnSp 1:nRxnSp]', [(1:nRxnSp)'; n + modelCom.indCom.rxnSps(1:nRxnSp)],...
          [ones(nRxnSp,1); -modelCom.ub(1:nRxnSp)], nRxnSp, n + nSp);
    %lower bound matrix
    S_lb = sparse([1:nRxnSp 1:nRxnSp]', [(1:nRxnSp)'; n + modelCom.indCom.rxnSps(1:nRxnSp)],...
          [-ones(nRxnSp,1); modelCom.lb(1:nRxnSp)], nRxnSp, n + nSp);
    %growth rate and biomass link matrix
    grSp = zeros(nSp, 1);
    grSp(isnan(GRfx)) = grCur;
    %given fixed growth rate
    grSp(~isnan(GRfx)) = GRfx(~isnan(GRfx));
    S_gr = sparse([1:nSp 1:nSp]', [modelCom.indCom.spBm(:) (n + 1:n + nSp)'],...
                  [BMgdw(:); -grSp], nSp, n + nSp);
    if isempty(BMcon)
        A = [modelCom.S sparse([],[],[], m, nSp); S_ub; S_lb; S_gr];
    else
        A = [modelCom.S sparse([],[],[], m, nSp); S_ub; S_lb; S_gr;...
                   sparse([],[],[],size(BMcon, 1), n) BMcon];
    end
    if isstruct(LPproblem)
        LPproblem.A = A;
    else
        LPproblem = A;
    end
else
    for j = 1:nSp
        if isstruct(LPproblem)
            if isnan(GRfx(j))
                LPproblem.A(m + 2*nRxnSp + j, n + j) = -grCur;
            else
                LPproblem.A(m + 2*nRxnSp + j, n + j) = -GRfx(j);
            end
        else
            if isnan(GRfx(j))
                LPproblem(m + 2*nRxnSp + j, n + j) = -grCur;
            else
                LPproblem(m + 2*nRxnSp + j, n + j) = -GRfx(j);
            end
        end
    end
end
end

function paramCell = getParams(param2get, options, modelCom)
% get the required default parameters for SteadyCom functions
%
% USAGE:
%    [param_1, ..., param_N] = getParams({'param_1',...,'param_N'}, options, modelCom)
%
% INPUTS:
%    'param_1',...,'param_N': parameter names
%    options:   option structure. If the required parameter is a field in options,
%               take from options. Otherwise, return the default value.
%    modelCom:  the community model for which parameters are constructed.
if nargin < 3
    modelCom = struct('rxns',[]);
    modelCom.infoCom.spAbbr = {};
    modelCom.infoCom.rxnSps = {};
end
if nargin < 2 || isempty(options)
    options = struct();
end
if ischar(param2get)
    param2get = {param2get};
end
paramNeedTransform = {'GRfx'};

paramCell = cell(numel(param2get), 1);
for j = 1:numel(param2get)
    if any(strcmp(param2get{j}, paramNeedTransform))
        %  if need transformation
        paramCell{j} = transformOptionInput(options, param2get{j}, numel(modelCom.infoCom.spAbbr));
    elseif isfield(options, param2get{j})
        % if provided in the call
        paramCell{j} = options.(param2get{j});
    else
        % use default if default exist and not provided
        % return empty if no default
        paramCell{j} = paramDefault(param2get{j});
    end
end


    function param = paramDefault(paramName)
        % get the default parameters. Called by getParams

        % Default parameters
        switch paramName
            % general parameters
            case 'threads',     param = 1;  % threads for general computation, 0 or -1 to turn on maximum no. of threads
            case 'verbFlag',	param = 3;  % verbal dispaly
            case 'loadModel',   param = '';
            case 'CplexParam',  % default Cplex parameter structure
                [param.simplex.display, param.tune.display, param.barrier.display,...
                    param.sifting.display, param.conflict.display] = deal(0);
                [param.simplex.tolerances.optimality, param.simplex.tolerances.feasibility] = deal(1e-9,1e-8);
                param.read.scale = -1;

                % parameters for SteadyCom
            case 'GRguess',     param = 0.2;  % initial guess for growth rate
            case 'BMtol',       param = 0.8;  % tolerance for relative biomass amount (used only for feasCrit=3)
            case 'BMtolAbs',    param = 1e-5;  % tolerance for absolute biomass amount
            case 'GR0',         param = 0.001;  % small growth rate to test growth
            case 'GRtol',       param = 1e-5;  % gap for growth rate convergence
            case 'GRdev',       param = 1e-5;  % percentage deviation from the community steady state allowed
            case 'maxIter',     param = 1e3;  % maximum no. of iterations
            case 'feasCrit',    param = 1;   % feasibility critierion
            case 'algorithm',   param = 1;  % 1:invoke Fzero after getting bounds; 2:simple guessing algorithm
            case 'BMgdw',       param = ones(numel(modelCom.infoCom.spAbbr), 1);  % relative molecular weight of biomass. For scaling the relative abundance
            case 'saveModel',   param = '';
            case 'BMobj',       param = ones(numel(modelCom.infoCom.spBm),1);   % objective coefficient for each species
            case 'BMweight',    param = 1;   % sum of biomass for feasibility criterion 1
            case 'LPonly',      param = false;  % true to return LP only but not calculate anything
            case 'solveGR0',    param = false;  % true to solve the model at very low growth rate (GR0)
            case 'resultTmp',   param = struct('GRmax',[],'vBM',[],'BM',[],'Ut',[],...
                    'Ex',[],'flux',[],'iter0',[],'iter',[],'stat','');  % result template

                % parameters for SteadyComFVA
            case 'optBMpercent',param = 99.99;
            case 'rxnNameList',  % targets for analysis
                if isfield(modelCom, 'indCom') || isfield(modelCom, 'infoCom')
                    if isfield(modelCom, 'indCom')
                        nSp = max(modelCom.indCom.rxnSps);
                    elseif isfield(modelCom.infoCom, 'spAbbr')
                        nSp = numel(modelCom.infoCom.spAbbr);
                    else
                        nSp = numel(unique(modelCom.infoCom.rxnSps)) - 1;
                    end
                    param = strcat('X_', strtrim(cellstr(num2str((1:nSp)'))));
                else
                    param = modelCom.rxns;
                end
            case 'rxnFluxList'
                if isfield(modelCom, 'infoCom') && isfield(modelCom.infoCom, 'spBm')
                    param = modelCom.infoCom.spBm;
                elseif isfield(modelCom, 'indCom') && isfield(modelCom.indCom, 'spBm')
                    param = modelCom.rxns(modelCom.indCom.spBm);
                else
                    param = modelCom.rxns;
                end
            case 'BMmaxLB',     param = 1;   % maximum biomass when it is unknown
            case 'BMmaxUB',     param = 1;   % maximum biomass when it is unknown
            case 'optGRpercent',param = 99.99;
            case 'saveFVA',     param = '';
            case 'saveFre',     param = 0.1;  % save frequency. Save every #rxns x saveFraction

                % parameters for SteadyComPOA
            case 'Nstep',       param = 10;
            case 'NstepScale',  param = 'lin';
            case 'symmetric',   param = true;   % treat it as symmetric, optimize for only j > k
            case 'savePOA',     param = ['POAtmp' filesep 'POA'];

            otherwise,          param = [];
        end
    end

    function x = transformOptionInput(options, field, nSp)
        % transform input parameters. Called by getParams

        if isfield(options, field)
            if size(options.(field), 2) == 2
                x = NaN(nSp, 1);
                x(options.(field)(:,1)) = options.(field)(:,2);
            else
                x = options.(field);
            end
        else
            x = NaN(nSp, 1);
        end

    end
end
