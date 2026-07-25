function [V, compareFluxes] = exoMetLOOCV(model, measuredFluxes, param)
% Leave-one-out cross-validation of exometabolomic flux fitting
%
% USAGE:
%
%    [V, compareFluxes] = exoMetLOOCV(model, measuredFluxes, param)
%
% INPUTS:
%    model:    COBRA model with fields:
%
%                * .S - `m x n` stoichiometric matrix
%                * .rxns - `n x 1` cell array of reaction identifiers
%                * .osenseStr - objective sense passed to entropic FBA ('min' or 'max')
%                * .cf - forward reaction linear weight for entropic FBA
%                * .cr - reverse reaction linear weight for entropic FBA
%                * .g - flux entropy weight for entropic FBA
%                * .u0 - reference chemical potential for entropic FBA
%                * .f - concentration entropy weight for entropic FBA
%
%    measuredFluxes:    table with the fluxes obtained from exometabolomics experiments, with variables:
%
%                         * .rxns - `k x 1` cell array of reaction identifiers
%                         * .mean - `k x 1` double of measured mean flux
%                         * .SD - `k x 1` double standard deviation of the measured flux
%
% OPTIONAL INPUT:
%    param:    a structure containing the parameters for the function:
%
%                * .alpha - alpha in (alpha/2)(v-h)'*H*(v-h) (Default: 10000)
%                * .approach - flux-fitting approach passed to the solver (Default: 'QEFBA')
%                * .relaxBounds - True to relax bounds on reactions whose fluxes are fitted to exometabolomic data
%                * .metabolomicWeights - String indicating the type of weights to be applied to
%                  penalise the difference between predicted and experimentally measured fluxes,
%                  where 'SD' weights = 1/(1+exoMet.SD^2), 'mean' weights = 1/(1+exoMet.mean^2),
%                  'RSD' weights = 1/((exoMet.SD./exoMet.mean)^2)
%
% OUTPUTS:
%    V:    table with the fluxes predicted by leave one out cross validation, with variables:
%
%            * .rxns - `n x 1` cell array of reaction identifiers, one for each in input model
%            * .v - `n x 1` double of predicted mean flux
%            * .lb - `n x 1` double lower bound on reaction flux
%            * .ub - `n x 1` double upper bound on reaction flux
%
%    compareFluxes:    table mapping the predicted fluxes V onto the measured fluxes for comparison
%
% .. Author(s):
if ~exist('param','var')
    param = struct;
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
if ~isfield(param,'relaxBounds')
    param.relaxBounds=1;
end
if ~isfield(param,'approach')
    param.approach='QEFBA';
end
            
[~,nRxns] = size(model.S);
            
if param.relaxBounds
    bool=ismember(model.rxns,measuredFluxes.rxns);
    model.lb(bool) = model.lb_preconstrainRxns(bool);
    model.ub(bool) = model.ub_preconstrainRxns(bool);
end

modelOrig = model;

if 1
    [measuredFluxes,LIBkey,LOCAkey] = mapAontoB(measuredFluxes.rxns,model.rxns,measuredFluxes);
    
    %preallocate and add data from measurments
    V = zeros(nRxns,nnz(LIBkey)+4);
    varNames = cell(nnz(LIBkey)+4,1);
    V(:,1) = measuredFluxes.mean;
    varNames{1} = 'mean';
    V(:,2) = measuredFluxes.SD;
    varNames{2} = 'SD';
    
    %reduce to the measured fluxes part of the model
    measuredFluxes = measuredFluxes(LIBkey,:);
else
    nMeasuredRxns = size(measuredFluxes,1);
    
    %preallocate and add data from measurments
    V = zeros(nRxns,nMeasuredRxns+4);
    varNames = cell(nMeasuredRxns+4,1);
    [V(:,1),LIBkey] = mapAontoB(measuredFluxes.rxns,model.rxns,measuredFluxes.mean);
    varNames{1} = 'mean';
    V(:,2) = mapAontoB(measuredFluxes.rxns,model.rxns,measuredFluxes.SD);
    varNames{2} = 'SD';
end

nMeasuredRxns = size(measuredFluxes,1);
bool = true(nMeasuredRxns,1);

%loop through the measured fluxes, leaving one of them out each time
for i=1:nMeasuredRxns
    bool(i)=0;
    switch param.approach
        case 'QEFBA'
            if i==1
                %compare without leaving any measured flux out
                model = addExoMetToEFBA(modelOrig,measuredFluxes,param);
                efbaParam.method = 'fluxes';
                efbaParam.printLevel = 0;
                model.osenseStr = 'min';
                model.cf = 0;
                model.cr = 0;
                model.g = 2;
                model.u0 = 0;
                model.f = 1;
                [QEFBAsolution, ~] = entropicFluxBalanceAnalysis(model,efbaParam);
                V(:,3) = QEFBAsolution.v;
                varNames{3}='QEFBA';
            end
            
            model = changeRxnBounds(modelOrig, measuredFluxes.rxns(~bool), min(modelOrig.lb), 'l');
            model = changeRxnBounds(model, measuredFluxes.rxns(~bool), max(modelOrig.ub), 'u');
            model = addExoMetToEFBA(model,measuredFluxes(bool,:),param);
            efbaParam.method = 'fluxes';
            efbaParam.printLevel = 0;
            model.osenseStr = 'min';
            model.cf = 0;
            model.cr = 0;
            model.g = 2;
            model.u0 = 0;
            model.f = 1;
            [solution, modelOut] = entropicFluxBalanceAnalysis(model,efbaParam);
            V(:,i+4) = solution.v;
            varNames{i+4}=measuredFluxes.rxns{~bool};
            
            %generate a flux vector amalgamated from all of the leave one out predictions
            boolRxn = ismember(model.rxns,measuredFluxes.rxns(~bool));
            V(boolRxn,4) = solution.v(boolRxn);
            if i==1
                varNames{4}='LOOCV';
            end
    end
    bool(i)=1;
end

V = array2table(V,'VariableNames',varNames);
V = addvars(V,model.rxns,modelOrig.lb,modelOrig.ub,'NewVariableNames',{'rxns','lb','ub'},'Before','mean');
% V = V(LIBkey,:);

compareFluxes = mapAontoB('rxns','rxns',V,measuredFluxes);
