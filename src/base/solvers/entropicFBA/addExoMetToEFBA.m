function modelOut = addExoMetToEFBA(model,exoMet,param)
% generates H and h to add a min (alpha/2)(v-h)'*H*(v-h) term to an EFBA problem
%
% USAGE:
%   modelOut = addExoMetToEFBA(model,exoMet,param)
%
% INPUTS:
%  model.S:  
%  model.rxns:    
%
%  exoMet.rxns:   
%  exoMet.mean:   
%  exoMet.SD:      
%
% OPTIONAL INPUT
%  param.printLevel:
%  param.alpha:              alpha in (alpha/2)(v-h)'*H*(v-h), default = 10000;
%  param.metabolomicWeights: String indicating the type of weights to be applied to penalise the difference
%                            between of predicted and experimentally measured fluxes by, where 
%                            'SD'   weights = 1/(1+exoMet.SD^2)
%                            'mean' weights = 1/(1+exoMet.mean^2)  (Default)
%                            'RSD'  weights = 1/((exoMet.SD./exoMet.mean)^2)
%  param.relaxBounds: True to relax bounds on reaction whose fluxes are to be fitted to exometabolomic data  
%
% OUTPUTS:
%  modelOut:         
%
% EXAMPLE:
%
% NOTE:
%
% Author(s):

if ~exist('param','var')
    param=struct;
end
if ~isfield(param,'printLevel')
    param.printLevel=0;
end
if ~isfield(param,'alpha')
    param.alpha=10000;
end
if ~isfield(param,'relaxBounds')
    param.relaxBounds=1;
end
if ~isfield(param,'metabolomicWeights')
    param.metabolomicWeights = 'mean';
end

[bool, locb] = ismember(exoMet.rxns, model.rxns);
if any(locb == 0)
    if printLevel > 0
        fprintf('%s\n','The following exometabolomic exchange reactions were not found in the model:')
        disp(exoMet.rxns(locb == 0))
    end
end

if length(unique(exoMet.rxns)) ~= length(exoMet.rxns) && printLevel > 0
    disp('There are duplicate rxnID entries in the metabolomic data! Only using data corresponding to first occurance')
end

% Assume mean model flux is equal to the mean experimental reaction flux.
[~,nRxn] = size(model.S);
vExp = NaN * ones(nRxn,1);
vExp(locb(bool)) = exoMet.mean(bool);

vSD = NaN * ones(nRxn,1);
vSD(locb(bool)) = exoMet.SD(bool);

% Set the weight on the Euclidean distance of the predicted steady state
% flux from the experimental steady state flux. Uniform at first.
weightExp = ones(nRxn,1);
% The weight penalty on relaxation from the experimental flux vector should be greater than that
% on the lower and upper bounds, if the experimental data is considered more reliable
% than the lower and upper bounds of the model.
% Assumes the lower and upper bound of standard deviation of
% experimental reaction flux are separated by two standard
% deviations.

% Penalise the relaxation from the experimental flux value by 1/(1+weights^2)
switch param.metabolomicWeights
    case 'SD'
        weightExp(locb(bool)) = 1 ./ (1 +  (vSD(locb(bool))).^2);
    case 'mean'
        weightExp(locb(bool)) = 1 ./ (1 + (vExp(locb(bool))).^2);
    case 'RSD'
        weightExp(locb(bool)) = 1 ./ ((vSD(locb(bool))./vExp(locb(bool))).^2);
    otherwise
        weightExp(locb(bool)) = 2;
end
% Weights are ignored on the reactions without experimental data, i.e. vExp(n) == NaN.
weightExp(~isfinite(vExp)) = 0;

%add 
model.H=diag(sparse(weightExp*param.alpha));
model.h=vExp;
if param.printLevel>1
    figure;
    histogram(weightExp)
    xlabel('weights on the diagonal of model.H')
    ylabel('#reactions')
end

if param.relaxBounds
    bool=ismember(model.rxns,exoMet.rxns);
    model.lb(bool) = model.lb_preconstrainRxns(bool);
    model.ub(bool) = model.ub_preconstrainRxns(bool);
end

modelOut = model;
end

