function varargout = getSteadyComParams(param2get, options, modelCom)
% get the required default parameters
%
% USAGE:
%    [param_1, ..., param_N] = getCobraComParams({'param_1',...,'param_N'}, options, modelCom)
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
paramNeedTransform = {'GRfx', 'BMlb', 'BMub', 'BMfx'};
    
varargout = cell(numel(param2get), 1);
for j = 1:numel(param2get)
    if any(strcmp(param2get{j}, paramNeedTransform))
        %if need transformation
        varargout{j} = transformOptionInput(options, param2get{j}, numel(modelCom.infoCom.spAbbr));
    elseif isfield(options, param2get{j})
        %if provided in the call
        varargout{j} = options.(param2get{j});
    else
        %use default if default exist and not provided
        %return empty if no default
        varargout{j} = paramDefault(param2get{j}, modelCom);
    end
    %if calling for a directory, make sure to return a new directory
    if strcmp(param2get{j}, 'directory')
        k = 0;
        while exist(varargout{j}, 'file')
            k = k + 1;
            varargout{j} = [paramDefault.directory num2str(k)];
        end
    end
end


end

function param = paramDefault(paramName,modelCom)
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
        
    % parameters for createCommModel
    case 'metExId',     param = '[e]';
        
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
    case 'rxnNameList', if isfield(modelCom.infoCom,'spBm'), param = modelCom.rxns(findRxnIDs(modelCom,modelCom.infoCom.spBm));else param = modelCom.rxns;end
    case 'rxnFluxList', if isfield(modelCom.infoCom,'spBm'), param = modelCom.rxns(findRxnIDs(modelCom,modelCom.infoCom.spBm));else param = modelCom.rxns;end
    case 'BMmaxLB',     param = 1;   % maximum biomass when it is unknown
    case 'BMmaxUB',     param = 1;   % maximum biomass when it is unknown
    case 'optGRpercent',param = 99.99;
    case 'saveFVA',     param = '';
    case 'saveFre',     param = 0.1;  % save frequency. Save every #rxns x saveFraction
    
    % parameters for SteadyComPOA
    case 'Nstep',       param = 10;
    case 'NstepScale',  param = 'lin';
    case 'symmetric',   param = true;   % treat it as symmetric, optimize for only j > k
    case 'savePOA',     param = 'POAtmp/POA';
   
    otherwise,          param = [];
end
end

function x = transformOptionInput(options, field, nSp)
% transform input parameters
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
