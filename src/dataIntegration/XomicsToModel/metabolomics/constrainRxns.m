function [newModel, rxnsConstrained, rxnBoundsCorrected, newSpecificData] = ...
constrainRxns(model, specificData, param, mode, printLevel, ...
weightLower_flx_default, weightUpper_flx_default, weightLower_e_default, weightUpper_e_default, weightExpFct)
% Function used to apply constraints in the XomicsToModel function
%
% USAGE:
%
%    [newModel, rxnsConstrained, rxnBoundsCorrected, newOptions] = constrainRxns(model, specificData, param, mode, metabolomicWeights, printLevel)
%
% INPUTS:
%  model.S:                      m x n stoichiometric matrix
%  model.rxns:                   n x 1 cell array of reaction identifiers
%  model.rxnNames:               n x 1 cell array of reaction names
%  model.lb:                     n x 1 vector with lower bounds
%  model.ub:                     n x 1 vector with upper bounds
%  model.constraintDescription:
%  model.SIntRxnBool:
%  model.SinkRxnBool:
%  model.DMRxnBool:
%
%  specificData.rxns2constrain:
%  specificData.mediaData:
%  specificData.exoMet.rxns   k x 1 cell array of reaction identifiers
%  specificData.exoMet.mean    k x 1 numeric array of mean measured reaction flux
%  specificData.exoMet.SD      k x 1 numeric array of standard deviation in measured reaction flux
%  specificData.essentialAA:
%  specificData.exoMet.varID
%
%  param.TolMinBoundary:
%
%  param.TolMaxBoundary:
%
%  param.boundPrecisionLimit:
%
%  param.metabolomicWeights: String indicating the type of weights to be applied to penalise the difference
%                            between of predicted and experimentally measured fluxes by, where 
%                            'SD'   weights = 1/(1+exoMet.SD^2)
%                            'mean' weights = 1/(1+exoMet.mean^2)
%                            'RSD'  weights = 1/((exoMet.SD./exoMet.mean)^2)
%
%  param.eta:               lower bound on significant bound costraint perturbation
%                           Default: feasTol*10;
%
%  param.printLevel:
%
%  mode:                    String indicating the type of constraints to be applied
%                           'customConstraints'  uses specificData.rxns2constrain
%                           'mediaDataConstraints' uses specificData.mediaData
%                           'exometabolomicConstraints' uses specificData.exoMet
%  printLevel:        
%
% OPTIONAL INPUTS:
%  weightLower_flx_default:  User defined penalty applied to lower bounds of all fluxes.
%                            It overwrites the default penalty.
%                            It is overwritten for measured fluxes only by specificData.exoMet.penaltyLowerBoundPerturbation
%                            when available
%  weightUpper_flx_default:  User defined penalty applied to upper bounds of all fluxes.
%                            It overwrites the default penalty.
%                            It is overwritten for measured fluxes only by specificData.exoMet.penaltyUpperBoundPerturbation
%                            when available
%  weightLower_e_default:    User defined penalty applied to lower bounds of extra variables.
%                            It overwrites the default penalty.
%                            It is overwritten for measured extra variables only by specificData.exoMet.penaltyLowerBoundPerturbation
%                            when available
%  weightUpper_e_default:    User defined penalty applied to upper bounds of extra variables.
%                            It overwrites the default penalty.
%                            It is overwritten for measured extra variables only by specificData.exoMet.penaltyUpperBoundPerturbation
%                            when available
%  weightExpFct:             Factor by which to multiply experimental weights (weightExp_flx ,weightExp_e) in mode 'allConstraints'
%
% OUTPUTS:
%  newModel:
%
%  rxnsConstrained:
%
%  rxnBoundsCorrected:
%
%  newSpecificData:
%
% OUTPUTS:
%   newModel:           A cobra model with constraints applied
%
%   rxnsConstrained:    List of the reactions constrained
%
%   rxnBoundsCorrected: list of reactions whose restrictions should have
%                       been modified to comply with TolMinBoundary,
%                       TolMaxBoundary and boundPrecisionLimit.
%   newSpecificData:    A new structure containing arguments for the
%                       XomicsToModel function
%

if ~exist('printLevel','var')
    printLevel=0;
end

if ~exist('param','var')
    param=struct();
end
if ~isfield(param, 'TolMinBoundary')
    param.TolMinBoundary = -1e3;
end
if ~isfield(param, 'TolMaxBoundary')
    param.TolMaxBoundary = 1e3;
end
feasTol = getCobraSolverParams('LP', 'feasTol');
if ~isfield(param, 'boundPrecisionLimit')
    param.boundPrecisionLimit = feasTol*10;
end
if ~isfield(param,'eta')
    % eta is the lower bound on significant bound costraint perturbation
    %eta should be slightly larger than feasTol to omit tiny bound perturbations
    param.eta = feasTol*10;
end
if ~isfield(param, 'metabolomicWeights')
    param.metabolomicWeights = 'SD';
end

switch mode
    case 'customConstraints'
        
        % Data check
        if ~isfield(specificData,'rxns2constrain')
            error('Expecting specificData.rxns2constrain but it is absent')
        end
        if ~ismember('rxns', specificData.rxns2constrain.Properties.VariableNames)
            error('Expecting specificData.rxns2constrain.rxns but it is absent')
        end
        if ~ismember('lb', specificData.rxns2constrain.Properties.VariableNames)
            error('Expecting specificData.rxns2constrain.lb but it is absent')
        end
        if iscell(specificData.rxns2constrain.lb)
            specificData.rxns2constrain.lb = [specificData.rxns2constrain.lb{:}]';
        end
        if ~ismember('ub', specificData.rxns2constrain.Properties.VariableNames)
            error('Expecting specificData.rxns2constrain.ub but it is absent')
        end
        if iscell(specificData.rxns2constrain.ub)
            specificData.rxns2constrain.ub = [specificData.rxns2constrain.ub{:}]';
        end
        if ismember('constraintDescription', specificData.rxns2constrain.Properties.VariableNames)
            specificData.rxns2constrain.constraintDescription(cellfun('isempty', specificData.rxns2constrain.constraintDescription)) = {'Custom constraint'};
        else
            specificData.rxns2constrain.constraintDescription = repelem({'Custom constraint'}, numel(specificData.rxns2constrain.rxns), 1);
        end
        if ~isfield(model, 'constraintDescription')
            model.constraintDescription(1:length(model.rxns), 1) = {''};
        end
        
        % Collect custom constraints information
        rxnList = specificData.rxns2constrain.rxns;
        rxn_lb = specificData.rxns2constrain.lb;
        rxn_ub = specificData.rxns2constrain.ub;
        constraintDescription = specificData.rxns2constrain.constraintDescription;
        constraint = 1;
        if any(model.lb > model.ub)
            error('lower bounds greater than upper bounds')
        end
    case 'mediaDataConstraints'
        
        % Data check
        if ~isfield(specificData,'mediaData')
            error('Expecting specificData.mediaData but it is absent')
        end
        if ~ismember('rxns', specificData.mediaData.Properties.VariableNames)
            error('Expecting specificData.mediaData.rxns but it is absent')
        end
        if ~ismember('mediumMaxUptake', specificData.mediaData.Properties.VariableNames)
            if ismember('maxMediumUptake', specificData.mediaData.Properties.VariableNames)
                specificData.mediaData.mediumMaxUptake = specificData.mediaData.maxMediumUptake;
            else
                error('Expecting specificData.mediaData.mediumMaxUptake but it is absent')
            end
        end
        
        if ismember('constraintDescription', specificData.mediaData.Properties.VariableNames)
            specificData.mediaData.constraintDescription(cellfun('isempty', specificData.mediaData.constraintDescription)) = {'Growth media constraint'};
        else
            specificData.mediaData.constraintDescription = repelem({'Growth media constraint'}, numel(specificData.mediaData.rxns), 1);
        end
        
        if ~isfield(model, 'constraintDescription')
            model.constraintDescription(1:length(model.rxns), 1) = {''};
        end
        
        % Collect growth media constraints information
        rxnList = specificData.mediaData.rxns;
        rxn_lb = specificData.mediaData.mediumMaxUptake;
        rxn_ub = NaN(size(rxn_lb, 1), 1);
        constraintDescription = specificData.mediaData.constraintDescription;
        constraint = 1;
        if any(model.lb > model.ub)
            error('lower bounds greater than upper bounds')
        end
    case 'exometabolomicConstraints'
        
        % Data check
        if ~ismember('rxns', specificData.exoMet.Properties.VariableNames)
            error('Expecting specificData.exoMet.rxns but it is absent')
        end
        if ~ismember('mean', specificData.exoMet.Properties.VariableNames)
            error('Expecting specificData.exoMet.mean but it is absent')
        end
        if ~ismember('SD', specificData.exoMet.Properties.VariableNames)
            error('Expecting specificData.exoMet.SD but it is absent')
        end
        
        constraint = 0;
        
        [bool, locb] = ismember(specificData.exoMet.rxns, model.rxns);
        if any(locb == 0)
            if printLevel > 0
                fprintf('%s\n','The following exometabolomic exchange reactions were not found in the model:')
                disp(specificData.exoMet.rxns(locb == 0))
            end
        end
        
        % Save a list of the reactions constrained
        rxnsConstrained = specificData.exoMet.rxns(bool);
        
        if length(unique(specificData.exoMet.rxns)) ~= length(specificData.exoMet.rxns) && printLevel > 0
            display('There are duplicate rxns entries in the metabolomic data! Only using data corresponding to first occurance')
        end
        
        if ismember('exoMet_mean', specificData.exoMet.Properties.VariableNames) && ismember('exoMet_SD', specificData.exoMet.Properties.VariableNames)
            specificData.exoMet.mean = specificData.exoMet.exoMet_mean;
            specificData.exoMet.SD = specificData.exoMet.exoMet_SD;
            specificData.exoMet = removevars(specificData.exoMet, 'exoMet_mean');
            specificData.exoMet = removevars(specificData.exoMet, 'exoMet_SD');
        end
        
        [~,nRxn] = size(model.S);
        
        % Assume mean model flux is equal to the mean experimental reaction
        % flux.
        vExp = NaN * ones(nRxn,1);
        vExp(locb(bool)) = specificData.exoMet.mean(bool);
        
        vSD = NaN * ones(nRxn,1);
        vSD(locb(bool)) = specificData.exoMet.SD(bool);
        
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
        
        % Weights are ignored on the reactions without experimental data,
        % i.e. vExp(n) == NaN.
        weightExp(~isfinite(vExp)) = NaN;
        
        % Set the weight on the Euclidean norm of the relaxation to the lower bounds
        % on the predicted steady state flux vector. Only for allow relaxation for external
        % reactions. The weight penalty on relaxation of the lower bound should be greater
        % than that on the experimental flux, and upper bound, if the model lower bound
        % is considered more reliable than the experimental data and the upper bound.
        weightLower = ones(nRxn,1);
        
        % Do not allow external reaction lower bounds to be changed if it is
        % not measured in the media
        weightLower(~model.SIntRxnBool & isnan(weightExp)) = inf;
        
        % Do not allow internal reaction lower bounds to be changed
        weightLower(model.SIntRxnBool) = inf;
        
        % Penalise change to sink/demand reactions lower bounds
        weightLower(model.SinkRxnBool | model.DMRxnBool) = inf;
        
        % Do not allow lower bound to be relaxed if a metabolite is secreted
        %weightLower(~model.SIntRxnBool &  vExp > 0) = inf;
        weightLower(~model.SIntRxnBool &  (vExp-vSD) > 0) = inf;
        
        if 0
            %if any external reactions are at default bounds, allow those to be changed more readily
            weightLower(model.lb==param.TolMinBoundary & ~model.SIntRxnBool) = eta;
        end
        
        if ismember('penaltyLowerBoundPerturbation', specificData.exoMet.Properties.VariableNames)
            weightLower(locb(bool)) = specificData.exoMet.penaltyLowerBoundPerturbation(locb(bool));
        end
        
        %%
        % Set the weight on the Euclidean norm of the relaxation to the upper bounds
        % on the predicted steady state flux vector. Only for allow relaxation for external
        % reactions. The weight penalty on relaxation of the upper bound should be greater
        % than that on the experimental flux, and lower bound, if the model upper bound
        % is considered more reliable than the experimental data and the lower bound.
        
        weightUpper=ones(nRxn,1);
        
        % Do not allow internal reaction bounds to be changed
        weightUpper(model.SIntRxnBool) = inf;
        
        % Penalise change to sink/demand reactions lower bounds
        weightUpper(model.SinkRxnBool | model.DMRxnBool) = inf;
        
        if 0
            % If any external reactions are at default bounds, allow those to be changed more readily
            weightUpper(model.ub==param.TolMaxBoundary & ~model.SIntRxnBool) = eta;
        end
        
        % Do not allow upper bound to be relaxed if a metabolite is uptaken
        %weightUpper(~model.SIntRxnBool &  vExp < 0) = inf;
        weightUpper(~model.SIntRxnBool &  (vExp+vSD) < 0) = inf;
        
        if ismember('penaltyUpperBoundPerturbation', specificData.exoMet.Properties.VariableNames)
            weightUpper(locb(bool)) = specificData.exoMet.penaltyUpperBoundPerturbation(locb(bool));
        end
        
        % Compute the steady state flux vector that minimises the weighted Euclidean
        % norm between experimental and predicted steady state flux vector, plus the weighted
        % Euclidean norm relaxation of the model lower bounds, plus the  weighted Euclidean
        % norm relaxation of the model upper bounds. Also save the relaxed model that
        % admits such a steady state flux.
                
        if ~all(isinf(weightLower(model.SIntRxnBool)))
            warning('Some internal reaction lower bounds may be relaxed')
        end
        if ~all(isinf(weightUpper(model.SIntRxnBool)))
            warning('Some internal reaction upper bounds may be relaxed')
        end
        
        %select method(s) of fitting to try
        if 1
            %two norm fitting only
             methods={'two'};
        else
            %try a set of methods to fit fluxes
             methods = {'zero','zeroOne','oneTwo','two'};
        end
        
        %try to fit the bounds to the metabolomic data
        for i=1:length(methods)
            fitParam.method = methods{i};
            fitParam.printLevel = printLevel;
            if printLevel > 0
                fprintf('%s\n',['Fit experimental flux method: ' methods{i} ' norm.'])
            end
            [v, p, q, dv, obj] = fitExperimentalFlux(model, vExp, weightLower, weightUpper, weightExp, fitParam);
            
            %  v:          * `n x 1` steady state flux vector
            %  p:          * `n x 1` relaxation of lower bounds
            %  q:          * `n x 1` relaxation of upper bounds
            % dv:          * `n x 1` difference between experimental and predicted steady state flux
            
            %save perturbations, before any zeroing out of small variables
            pOrig = p;
            qOrig = q;
             
            if 1
                %zero out small changes to bounds of reactions not experimentally measured
                finiteExpBool =~ isnan(vExp);
                p(p<param.eta & ~finiteExpBool)=0;
                q(q<param.eta & ~finiteExpBool)=0;
            else
                %zero out small changes to bounds of all reactions
                p(p < param.eta) = 0;
                q(q < param.eta) = 0;
            end
            
            %create the fitted model
            modelFitted = model;
            
            sol = optimizeCbModel(modelFitted);
            
            if sol.stat == 1
                fprintf('%\n','Fitted model is feasible.')
            else
                %try with the original bound relaxations
                modelFitted.lb = model.lb - pOrig;
                modelFitted.ub = model.ub + qOrig;
                
                %test that the model is feasible.
                FBAsolution = optimizeCbModel(modelFitted);
                if FBAsolution.stat == 1
                    warning('Fitted model is feasible, but only after including small changes to bounds of reactions not experimentally measured.')
                    p = pOrig;
                    q = qOrig;
                else
                    sol
                    warning('Fitted model is not feasible for FBA yet. Check numerical issues within fitExperimentalFlux.')
                end
            end

            boolExpRxn = false(nRxn,1);
            boolExpRxn(locb(bool))=1;
            if printLevel > 0
                fprintf('\n')
                fprintf('%s\n',[int2str(nnz(boolExpRxn)) ' measured exchange reaction rates.'])
                fprintf('%s\n',[int2str(nnz(dv==0 & boolExpRxn)) ' perfectly fit measured exchange reaction rates.'])
                fprintf('%s\n',[int2str(nnz(dv~=0 & boolExpRxn)) ' imperfectly fit measured exchange reaction rates.'])
                T = table(model.rxns(dv~=0 & boolExpRxn),model.rxnNames(dv~=0 & boolExpRxn),dv(dv~=0 & boolExpRxn),'VariableNames',{'rxns','rxnNames','deviation from measured mean exchange'});
                disp(T)
                fprintf('%s\n',[int2str(nnz(p)) ' lower bounds relaxed.'])
                fprintf('%s\n',[int2str(nnz(p & ~model.SIntRxnBool)) ' external lower bounds relaxed.'])
                fprintf('%s\n',[int2str(nnz(p~=0 & boolExpRxn~=0 & ~model.SIntRxnBool)) ' measured external metabolite lower bounds relaxed.'])
                fprintf('%s\n',[int2str(nnz(p~=0 & boolExpRxn==0 & ~model.SIntRxnBool)) ' unmeasured external metabolite lower bounds relaxed.'])
                
                fprintf('%s\n',[int2str(nnz(q)) ' upper bounds relaxed.'])
                fprintf('%s\n',[int2str(nnz(q & ~model.SIntRxnBool)) ' external upper bounds relaxed.'])
                fprintf('%s\n',[int2str(nnz(q~=0 & boolExpRxn~=0 & ~model.SIntRxnBool)) ' measured external metabolite upper bounds relaxed.'])
                fprintf('%s\n',[int2str(nnz(q~=0 & boolExpRxn==0 & ~model.SIntRxnBool)) ' unmeasured external metabolite upper bounds relaxed.'])
                fprintf('\n')
            end
        end
        
        % Identify the reactions where the bounds are relaxed
        modelFitted.exometRelaxation.lowerBoundBool = p >= param.eta;
        modelFitted.exometRelaxation.upperBoundBool = q >= param.eta;

        
        %% Adjust the bounds based on the standard deviation of the experimental data
        if 1
            % set bounds to +/- one standard deviation, except where bounds were relaxed, or
            % where it would change direction of reaction
            
            % Reversible reactions
            reversibleRxnBool = model.lb < 0 & model.ub > 0;
            modelFitted.lb(finiteExpBool & ~modelFitted.exometRelaxation.lowerBoundBool & reversibleRxnBool)=...
                v(finiteExpBool & ~modelFitted.exometRelaxation.lowerBoundBool & reversibleRxnBool) -  vSD(finiteExpBool & ~modelFitted.exometRelaxation.lowerBoundBool & reversibleRxnBool);
            
            modelFitted.ub(finiteExpBool & ~modelFitted.exometRelaxation.upperBoundBool & reversibleRxnBool)=...
                v(finiteExpBool & ~modelFitted.exometRelaxation.upperBoundBool & reversibleRxnBool) + vSD(finiteExpBool & ~modelFitted.exometRelaxation.upperBoundBool & reversibleRxnBool);
            
            %forward reactions
            fwdRxnBool = model.lb >= 0 & model.ub ~=0 ;
            modelFitted.lb(finiteExpBool & ~modelFitted.exometRelaxation.lowerBoundBool & fwdRxnBool)=...
                max(0, v(finiteExpBool & ~modelFitted.exometRelaxation.lowerBoundBool & fwdRxnBool) -  vSD(finiteExpBool & ~modelFitted.exometRelaxation.lowerBoundBool & fwdRxnBool));
            
            modelFitted.ub(finiteExpBool & ~modelFitted.exometRelaxation.upperBoundBool & fwdRxnBool)=...
                v(finiteExpBool & ~modelFitted.exometRelaxation.upperBoundBool & fwdRxnBool) + vSD(finiteExpBool & ~modelFitted.exometRelaxation.upperBoundBool & fwdRxnBool);
            
            %reverse reactions
            revRxnBool = model.ub<=0 & model.lb~=0;
            modelFitted.lb(finiteExpBool & ~modelFitted.exometRelaxation.lowerBoundBool & revRxnBool)=...
                v(finiteExpBool & ~modelFitted.exometRelaxation.lowerBoundBool & revRxnBool) -  vSD(finiteExpBool & ~modelFitted.exometRelaxation.lowerBoundBool & revRxnBool);
            
            modelFitted.ub(finiteExpBool & ~modelFitted.exometRelaxation.upperBoundBool & revRxnBool)=...
                min(0, v(finiteExpBool & ~modelFitted.exometRelaxation.upperBoundBool & revRxnBool) + vSD(finiteExpBool & ~modelFitted.exometRelaxation.upperBoundBool & revRxnBool));
            
        else
            %set lower bound to match upper bound when upper bound relaxed
            modelFitted.lb(modelFitted.exometRelaxation.upperBoundBool) = modelFitted.ub(modelFitted.exometRelaxation.upperBoundBool);
            %set upper bound to match lower bound when lower bound relaxed
            modelFitted.ub(modelFitted.exometRelaxation.lowerBoundBool) = modelFitted.lb(modelFitted.exometRelaxation.lowerBoundBool);
            
            %also set the bounds specified by the experimental data, except where
            %bounds were relaxed
            modelFitted.lb(finiteExpBool & ~modelFitted.exometRelaxation.lowerBoundBool)=v(finiteExpBool & ~modelFitted.exometRelaxation.lowerBoundBool);
            modelFitted.ub(finiteExpBool & ~modelFitted.exometRelaxation.upperBoundBool)=v(finiteExpBool & ~modelFitted.exometRelaxation.upperBoundBool);
        end
        
        %save the revised bounds in the exoMet structure
        specificData.exoMet.name(bool) = model.rxnNames(locb(bool));
        specificData.exoMet.lb(bool) = modelFitted.lb(locb(bool));
        specificData.exoMet.wl(bool) = weightLower(locb(bool));
        specificData.exoMet.p(bool) = p(locb(bool));
        specificData.exoMet.lb_old(bool)=  model.lb(locb(bool));
        specificData.exoMet.v(bool) = v(locb(bool));
        
        %compute the sign of the model flux
        specificData.exoMet.sign_v = sign(specificData.exoMet.v);
        specificData.exoMet.sign_v(abs(specificData.exoMet.v)<param.boundPrecisionLimit)=0;
        
        %compute the sign of the experimental flux
        specificData.exoMet.sign_vExp = sign(specificData.exoMet.mean);
        
        %interval formed by mean +/- SD contains zero
        specificData.exoMet.sign_vExpSD = sign(specificData.exoMet.mean);
        specificData.exoMet.sign_vExpSD((specificData.exoMet.mean - specificData.exoMet.SD)<0 & (specificData.exoMet.mean + specificData.exoMet.SD)>0)=0;
        
        specificData.exoMet.signMatch = double(specificData.exoMet.sign_v == specificData.exoMet.sign_vExp);
        specificData.exoMet.dv(bool) = dv(locb(bool));
        specificData.exoMet.wexp(bool) = weightExp(locb(bool));
        specificData.exoMet.ub_old(bool)=  model.ub(locb(bool));
        specificData.exoMet.q(bool)=  q(locb(bool));
        specificData.exoMet.wu(bool) = weightUpper(locb(bool));
        specificData.exoMet.ub(bool)=  modelFitted.ub(locb(bool));
        specificData.exoMet.vdv = specificData.exoMet.dv./specificData.exoMet.v;
        
        specificData.exoMet.lb(~bool) = NaN;
        specificData.exoMet.wl(~bool) = NaN;
        specificData.exoMet.p(~bool) = NaN;
        specificData.exoMet.lb_old(~bool) = NaN;
        specificData.exoMet.v(~bool) = NaN;
        specificData.exoMet.wexp(~bool) = NaN;
        specificData.exoMet.ub_old(~bool) = NaN;
        specificData.exoMet.q(~bool) = NaN;
        specificData.exoMet.wu(~bool) = NaN;
        specificData.exoMet.ub(~bool) = NaN;
        specificData.exoMet.signMatch(~bool) = NaN;
        
        specificData.exoMet = sortrows(specificData.exoMet, 'mean', 'ascend');
        
        modelFitted.exometRelaxationObj = obj;
        modelFitted.exometRelaxation.v = v;
        modelFitted.exometRelaxation.p = p;
        modelFitted.exometRelaxation.q = q;
        modelFitted.exometRelaxation.dv = dv;
        modelFitted.exometRelaxation.eta = param.eta;
        modelFitted.exometRelaxation.weightLower = weightLower;
        modelFitted.exometRelaxation.weightUpper = weightUpper;
        modelFitted.exometRelaxation.weightExp = weightExp;
        modelFitted.constraintDescription(ismember(modelFitted.rxns, specificData.exoMet.rxns)) = {'Metabolomics constraints'};
        
        % Except in the case where bounds were relaxed,
        if printLevel > 0
            if any(finiteExpBool)
                fprintf('%s\n','Fit reactions:')
                k = 1;
                for n = 1:nRxn
                    if k == 100 %only show 100 reactions maximum
                        break;
                    end
                    if n == 1
                        fprintf('%-20s%12s%12s%12s%12s%12s%12s%12s%12s%12s%12s%12s\t%-60s\n',...
                            'rxns{n}', 'lb', 'wl', '-p', 'lb_old', 'v', 'vexp', 'wexp', 'ub_old', ...
                            'q', 'wu', 'ub', 'reaction name');
                    end
                    if finiteExpBool(n)
                        k = k + 1;
                        fprintf('%-20s%12.4g%12.4g%12.4g%12.4g%12.4g%12.4g%12.4g%12.4g%12.4g%12.4g%12.4g\t%-60s\n',...
                            model.rxns{n}, modelFitted.lb(n), weightLower(n), -p(n), ...
                            model.lb(n), v(n), vExp(n), weightExp(n), model.ub(n), q(n), ...
                            weightUpper(n), modelFitted.ub(n), model.rxnNames{n});
                    end
                end
            else
                fprintf('%s\n','No finite data to fit reaction bounds.')
            end
        end
        
        if printLevel > 0
            if any(modelFitted.exometRelaxation.lowerBoundBool)
                fprintf('\n%s\n', 'Relaxation of lower bounds:')
                k = 1;
                for n = 1:nRxn
                    if k == 100 %only show 100 reactions maximum
                        break;
                    end
                    if n == 1
                        fprintf('%-20s%12s%12s%12s%12s%12s%12s%12s%12s%12s%12s%12s\t%-60s\n',...
                            'rxns{n}', 'lb', 'wl', '-p', 'lb_old', 'v', 'vexp', 'wexp', ...
                            'ub_old', 'q', 'wu', 'ub', 'reaction name');
                    end
                    if modelFitted.exometRelaxation.lowerBoundBool(n)
                        k = k + 1;
                        fprintf('%-20s%12.4g%12.4g%12.4g%12.4g%12.4g%12.4g%12.4g%12.4g%12.4g%12.4g%12.4g\t%-60s\n',...
                            model.rxns{n}, modelFitted.lb(n), weightLower(n), -p(n), model.lb(n),...
                            v(n), vExp(n), weightExp(n), model.ub(n), q(n), weightUpper(n), ...
                            modelFitted.ub(n), model.rxnNames{n});
                    end
                end
            else
                fprintf('%s\n','No relaxation of lower bounds.')
            end
        end
        %%
        % Display the predicted fluxes in relation to the original model bounds and
        % the relaxation of the upper model bounds
        
        if printLevel > 0
            if any(modelFitted.exometRelaxation.upperBoundBool)
                fprintf('\n%s\n', 'Relaxation of upper bounds:')
                k = 1;
                for n = 1:nRxn
                    if k == 100 %only show 100 reactions maximum
                        break;
                    end
                    if n == 1
                        fprintf('%-20s%12s%12s%12s%12s%12s%12s%12s%12s%12s%12s%12s\t%-60s\n',...
                            'rxns{n}', 'lb', 'wl', '-p', 'lb_old', 'v', 'vexp', 'wexp', 'ub_old', ...
                            'q', 'wu', 'ub', 'reaction name');
                    end
                    if modelFitted.exometRelaxation.upperBoundBool(n)
                        k=k+1;
                        fprintf('%-20s%12.4g%12.4g%12.4g%12.4g%12.4g%12.4g%12.4g%12.4g%12.4g%12.4g%12.4g\t%-60s\n',...
                            model.rxns{n}, modelFitted.lb(n), weightLower(n) ,-p(n), model.lb(n), v(n), vExp(n), ...
                            weightExp(n), model.ub(n), q(n), weightUpper(n), modelFitted.ub(n), model.rxnNames{n});
                    end
                end
            else
                fprintf('%s\n','No relaxation of upper bounds.')
            end
        end
        if printLevel > 0
            fprintf('%s\n\n', '...done.')
        end
        
        %save the new model
        model = modelFitted;
        if any(model.lb > model.ub)
            error('lower bounds greater than upper bounds')
        end
    case 'allConstraints'
        % apply quadratic relaxation to constraints using flux
        % variables and/or extra variables (e.g. enzyme-usage variables in
        % GECKO model)
        
        % do not use generic hard constraints
        constraint = 0;

        % check data
        exo = specificData.exoMet;
        necessaryCols = {'varID', 'mean', 'SD'};
        for i=necessaryCols
            if ~ismember(i{1}, exo.Properties.VariableNames)
                error('Expecting specificData.exoMet.%s but it is absent', i{1})
            end
        end

        [flxBool, flxIdx] = ismember(exo.varID, model.rxns);

        if isfield(model, 'evars') && ~isempty(model.evars)
            [eBool, eIdx] = ismember(exo.varID, model.evars);
        else
            eBool = false(numel(exo.varID));
            eIdx = zeros(numel(exo.varID));
        end

        if any(~flxBool & ~eBool)
            notThere = exo.varID(~flxBool & ~eBool);
            nt = sprintf('%s\n', notThere);
            warning('These exoMet.varID entries neither match model.rxns nor model.evars, and will be ignored: %s', nt)
        end
        
        rxnsConstrained = exo.varID(flxBool);
        extraConstrained = exo.varID(eBool);
        
        if length(unique(rxnsConstrained)) ~= length(rxnsConstrained) && printLevel > 0
            display('There are duplicate rxns entries in the data!')
        end
        
        if length(unique(extraConstrained)) ~= length(extraConstrained) && printLevel > 0
            display('There are duplicate extra variables entries in the data!')
        end

        nRxn = numel(model.rxns);
        nExt = numel(model.evars);
        
        % experimenal values for flux
        vExp_flx = NaN * ones(nRxn,1);
        vExp_flx(flxIdx(flxBool)) = exo.mean(flxBool); % vector with experimental mean flux (rxns ordered as in the model)
        
        vSD_flx = NaN * ones(nRxn,1);
        vSD_flx(flxIdx(flxBool)) = exo.SD(flxBool); % vector with experimental std (rxns ordered as in the model)
        
        % experimental values for extra variables
        vExp_e = NaN * ones(nExt ,1);
        vExp_e(eIdx(eBool)) = exo.mean(eBool);

        vSD_e = NaN * ones(nExt, 1);
        vSD_e(eIdx(eBool)) = exo.SD(eBool);
        
        % Set the weight on the Euclidean distance of the predicted steady state
        % value from the experimental steady state value.
        weightExp_flx = NaN * ones(nRxn,1); % weights are ignored on the reactions without experimental data
        weightExp_e = NaN * ones(nExt,1);
        % Penalise the relaxation from the experimental value
        switch param.metabolomicWeights
            case 'SD'
                % weightExp_flx(flxIdx(flxBool)) = 1 ./ (1 +  (vSD_flx(flxIdx(flxBool)).^2));
                % weightExp_e(eIdx(eBool)) = 1 ./ (1 +  (vSD_e(eIdx(eBool)).^2));
                % TO REMOVE?
                % % alternatively we could give less weight to allow more relaxation:
                if exist('weightExpFct', 'var') || ~isempty(weightExpFct)
                    weightExp_flx(flxIdx(flxBool)) = (1 ./ (1 +  (vSD_flx(flxIdx(flxBool)).^2)))*weightExpFct;
                    weightExp_e(eIdx(eBool)) = (1 ./ (1 +  (vSD_e(eIdx(eBool)).^2)))*weightExpFct;
                else
                    weightExp_flx(flxIdx(flxBool)) = 1 ./ (1 +  (vSD_flx(flxIdx(flxBool)).^2));
                    weightExp_e(eIdx(eBool)) = 1 ./ (1 +  (vSD_e(eIdx(eBool)).^2));
                end
            case 'mean'
                if exist('weightExpFct', 'var') || ~isempty(weightExpFct)
                    weightExp_flx(flxIdx(flxBool)) = (1 ./ (1 + (vExp_flx(flxIdx(flxBool)).^2)))*weightExpFct;
                    weightExp_e(eIdx(eBool)) = (1 ./ (1 + (vExp_e(eIdx(eBool)).^2)))*weightExpFct;
                else
                    weightExp_flx(flxIdx(flxBool)) = 1 ./ (1 + (vExp_flx(flxIdx(flxBool)).^2));
                    weightExp_e(eIdx(eBool)) = 1 ./ (1 + (vExp_e(eIdx(eBool)).^2));
                end
            case 'RSD'
                if exist('weightExpFct', 'var') || ~isempty(weightExpFct)
                    weightExp_flx(flxIdx(flxBool)) = 1 ./ ((vSD_flx(flxIdx(flxBool))./vExp_flx(flxIdx(flxBool))).^2);
                    weightExp_e(eIdx(eBool)) = 1 ./ ((vSD_e(eIdx(eBool))./vExp_e(eIdx(eBool))).^2);
                else
                    weightExp_flx(flxIdx(flxBool)) = 1 ./ ((vSD_flx(flxIdx(flxBool))./vExp_flx(flxIdx(flxBool))).^2)*weightExpFct;
                    weightExp_e(eIdx(eBool)) = 1 ./ ((vSD_e(eIdx(eBool))./vExp_e(eIdx(eBool))).^2)*weightExpFct;
                end
            otherwise
                if exist('weightExpFct', 'var') || ~isempty(weightExpFct)
                    weightExp_flx(flxIdx(flxBool)) = 2*weightExpFct;
                    weightExp_e(eIdx(eBool)) = 2*weightExpFct;
                else
                    weightExp_flx(flxIdx(flxBool)) = 2;
                    weightExp_e(eIdx(eBool)) = 2;
                end
            end
        
        % default for flux bound relaxation if no
        % weightLower/Upper_flx_default is provided
        weightLower_flx = ones(nRxn, 1);
        weightUpper_flx = ones(nRxn, 1);
                
        % does model has fields necessary for relaxation default logic
        hasDefaultFields = isfield(model,'SIntRxnBool') && isfield(model,'SinkRxnBool') && isfield(model,'DMRxnBool');
                
        if hasDefaultFields
            % Default bound relaxation logic

            % Set the weight on the Euclidean norm of the relaxation to the lower bounds
            % on the predicted steady state flux vector. Only for allow relaxation for external
            % reactions. The weight penalty on relaxation of the lower bound should be greater
            % than that on the experimental flux, and upper bound, if the model lower bound
            % is considered more reliable than the experimental data and the upper bound.
            
            % Do not allow external reaction lower bounds to be changed if it is
            % not measured in the media
            weightLower_flx(~model.SIntRxnBool & isnan(weightExp_flx)) = inf;
            
            % Do not allow internal reaction lower bounds to be changed
            weightLower_flx(model.SIntRxnBool) = inf;
            
            % Penalise change to sink/demand reactions lower bounds
            weightLower_flx(model.SinkRxnBool | model.DMRxnBool) = inf;

            % Do not allow lower bound to be relaxed if a metabolite is secreted
            %weightLower(~model.SIntRxnBool &  vExp > 0) = inf;
            weightLower_flx(~model.SIntRxnBool &  (vExp_flx-vSD_flx) > 0) = inf;
            
            if 0
                %if any external reactions are at default bounds, allow those to be changed more readily
                weightLower_flx(model.lb==param.TolMinBoundary & ~model.SIntRxnBool) = eta;
            end

            % Set the weight on the Euclidean norm of the relaxation to the upper bounds
            % on the predicted steady state flux vector. Only for allow relaxation for external
            % reactions. The weight penalty on relaxation of the upper bound should be greater
            % than that on the experimental flux, and lower bound, if the model upper bound
            % is considered more reliable than the experimental data and the lower bound.
            
            % Do not allow internal reaction bounds to be changed
            weightUpper_flx(model.SIntRxnBool) = inf;
            
            % Penalise change to sink/demand reactions lower bounds
            weightUpper_flx(model.SinkRxnBool | model.DMRxnBool) = inf;
                        
            % Do not allow upper bound to be relaxed if a metabolite is uptaken
            %weightUpper(~model.SIntRxnBool &  vExp < 0) = inf;
            weightUpper_flx(~model.SIntRxnBool &  (vExp_flx+vSD_flx) < 0) = inf;
            
            if 0
                % If any external reactions are at default bounds, allow those to be changed more readily
                weightUpper_flx(model.ub==param.TolMaxBoundary & ~model.SIntRxnBool) = eta;
            end
        else
            % if model does not have fields necessary for default bound
            % relaxation logic, weightLower/Upper_flx = 1
            if (~exist('weightLower_flx_default', 'var') || isempty(weightLower_flx_default)) ...
                && (~exist('weightUpper_flx_default', 'var') || isempty(weightUpper_flx_default))
                warning(['using mode allConstraints, ' ...
                    'and the model lacks SIntRxnBool/SinkRxnBool/DMRxnBool, ' ...
                    'and no weightLower_flx_default/Upper_flx_default are provided.'...
                    'default bound relaxation weights are therefore 1, ' ...
                    'except where penalty*BoundPerturbation overwrites. ', ...
                    'to change default use weightLower_flx_default/weightUpper_flx_default']);  
            end
        end
        
        % overwrite default flux bound relaxation if
        % weightLower/Upper_flx_default is provided by user
        if exist('weightLower_flx_default', 'var') && ~isempty(weightLower_flx_default)
            if isscalar(weightLower_flx_default)
                weightLower_flx = repmat(weightLower_flx_default, nRxn, 1);
            else
                weightLower_flx = weightLower_e_default;
            end
        end

        if exist('weightUpper_flx_default', 'var') && ~isempty(weightUpper_flx_default)
            if isscalar(weightLower_flx_default)
                weightUpper_flx = repmat(weightUpper_flx_default, nRxn, 1);
            else
                weightUpper_flx = weightUpper_e_default;
            end
        end
        
        % overwrite bound relaxation for fluxes with user defined penalties
        if ismember('penaltyLowerBoundPerturbation', specificData.exoMet.Properties.VariableNames)
            weightLower_flx(flxIdx(flxBool)) = specificData.exoMet.penaltyLowerBoundPerturbation(flxIdx(flxBool));
        end
        if ismember('penaltyUpperBoundPerturbation', specificData.exoMet.Properties.VariableNames)
            weightUpper_flx(flxIdx(flxBool)) = specificData.exoMet.penaltyUpperBoundPerturbation(flxIdx(flxBool));
        end
        
        % default for extra variables bound relaxation, if no
        % weightLower/Upper_e_default is provided, is to not relax
        weightLower_e = inf * ones(nExt,1);
        weightUpper_e = inf * ones(nExt,1);

        % overwrite default extra variable bound relaxation if
        % weightLower/Upper_e_default is provided by user
        if exist('weightLower_e_default', 'var') && ~isempty(weightLower_e_default)
            if isscalar(weightLower_e)
                weightLower_e = repmat(weightLower_e_default, nExt, 1);
            else
                weightLower_e = weightLower_e_default;
            end
        end
        if exist('weightUpper_e_default', 'var') && ~isempty(weightUpper_e_default)
            if isscalar(weightUpper_e)
                weightUpper_e = repmat(weightUpper_e_default, nExt, 1);
            else
                weightUpper_e = weightUpper_e_default;
            end
        end
        % overwrite bound relaxation for extra variables with user defined penalties
        if ismember('penaltyLowerBoundPerturbation', specificData.exoMet.Properties.VariableNames)
            weightLower_e(eIdx(eBool)) = specificData.exoMet.penaltyLowerBoundPerturbation(eIdx(eBool));
        end
        if ismember('penaltyUpperBoundPerturbation', specificData.exoMet.Properties.VariableNames)
            weightUpper_e(eIdx(eBool)) = specificData.exoMet.penaltyUpperBoundPerturbation(eIdx(eBool));
        end

        % warn when extra variables exist, but no lower bound default is
        % given
        if nExt > 0 ...
            && ((~exist('weightLower_e_default', 'var')) || isempty(weightLower_e_default)) ...
            && ((~exist('weightUpper_e_default', 'var')) || isempty(weightUpper_e_default))
            warning(['extra variables exist but no weightLower_e_default/weightUpper_e_default was given. ', ...
                'extra variable bounds will not be relaxed (weight is Inf), ', ...
                'except where penalty*BoundPerturbation overwrites'])
        end
        
        % Compute the steady state flux vector that minimises the weighted Euclidean
        % norm between experimental and predicted steady state flux vector, plus the weighted
        % Euclidean norm relaxation of the model lower bounds, plus the  weighted Euclidean
        % norm relaxation of the model upper bounds. Also save the relaxed model that
        % admits such a steady state flux.
        
        if isfield(model, 'SIntRxnBool') && ~isempty(model.SIntRxnBool)
            if ~all(isinf(weightLower_flx(model.SIntRxnBool)))
                warning('Some internal reaction lower bounds may be relaxed')
            end
            if ~all(isinf(weightUpper_flx(model.SIntRxnBool)))
                warning('Some internal reaction upper bounds may be relaxed')
            end
        end
        
        %select method(s) of fitting to try
        if 1
            %two norm fitting only
             methods={'two'};
        else
            %try a set of methods to fit fluxes
             methods = {'zero','zeroOne','oneTwo','two'};
        end
        
        %try to fit the bounds to the data
        for i=1:length(methods)
            fitParam.method = methods{i};
            fitParam.printLevel = printLevel;
            if printLevel > 0
                fprintf('%s\n',['Fit experimental method: ' methods{i} ' norm.'])
            end
            if nExt == 0
                [v, p, q, dv, obj] = fitExperimentalFlux(model, vExp_flx, weightLower_flx, weightUpper_flx, weightExp_flx, fitParam);
            elseif nExt > 0
                modelExtend = model;
                vExp = [vExp_flx; vExp_e];
                weightLower = [weightLower_flx; weightLower_e];
                weightUpper = [weightUpper_flx; weightUpper_e];
                weightExp = [weightExp_flx; weightExp_e];
                modelExtend.S = [model.S, model.E];
                modelExtend.C = [model.C, model.D];
                modelExtend.c = [model.c; model.evarc];
                modelExtend.lb = [model.lb; model.evarlb];
                modelExtend.ub = [model.ub; model.evarub];
                [v, p, q, dv, obj] = fitExperimentalFlux(modelExtend, vExp, weightLower, weightUpper, weightExp, fitParam);
            end
            %  v:          * `n x 1` steady state extended variable vector
            %  p:          * `n x 1` relaxation of lower bounds
            %  q:          * `n x 1` relaxation of upper bounds
            % dv:          * `n x 1` difference between experimental and predicted steady state
            
            % split v, p, q, dv back
            v_flx = v(1:nRxn);
            p_flx = p(1:nRxn);
            q_flx = q(1:nRxn);
            dv_flx = dv(1:nRxn);
            v_e = v(nRxn+1:end);
            p_e = p(nRxn+1:end);
            q_e = q(nRxn+1:end);
            dv_e = dv(nRxn+1:end);

            %save perturbations, before any zeroing out of small variables
            p_flxOrig = p_flx;
            q_flxOrig = q_flx;
            p_eOrig = p_e;
            q_eOrig = q_e;

            if 1
                %zero out small changes to bounds not experimentally measured
                finiteExpBool_flx =~ isnan(vExp_flx); % has experimental
                finiteExpBool_e =~ isnan(vExp_e);
                p_flx(p_flx<param.eta & ~finiteExpBool_flx)=0;
                q_flx(q_flx<param.eta & ~finiteExpBool_flx)=0;
                p_e(p_e<param.eta & ~finiteExpBool_e)=0;
                q_e(q_e<param.eta & ~finiteExpBool_e)=0;
            else
                %zero out small changes to bounds of all variables
                p_flx(p_flx < param.eta) = 0;
                q_flx(q_flx < param.eta) = 0;
                p_e(p_e < param.eta) = 0;
                q_e(q_e < param.eta) = 0;
            end
            
            %create the fitted model
            modelFitted = model;
            modelFitted.lb = model.lb - p_flx;
            modelFitted.ub = model.ub + q_flx;
            modelFitted.evarlb = model.evarlb - p_e;
            modelFitted.evarub = model.evarub + q_e;

            % buildOptProblemFromModel takes fields D and E in
            % consideration
            LP = buildOptProblemFromModel(modelFitted, 'true', struct());
            sol = solveCobraLP(LP);
            
            if sol.stat == 1
                fprintf('%\n','Fitted model is feasible.')
            else
                %try with the original bound relaxations
                modelFitted.lb = model.lb - p_flxOrig;
                modelFitted.ub = model.ub + q_flxOrig;
                modelFitted.evarlb = model.evarlb - p_eOrig;
                modelFitted.evarub = model.evarub + q_eOrig;
                
                LP = buildOptProblemFromModel(modelFitted, 'true', struct());
                FBAsolution = solveCobraLP(LP); % buildOptProblemFromModel takes fields D and E in
                % consideration
                
                if FBAsolution.stat == 1
                    warning('Fitted model is feasible, but only after including small changes to bounds of variables not experimentally measured.')
                    p_flx = p_flxOrig;
                    q_flx = q_flxOrig;
                    p_e = p_eOrig;
                    q_e = q_eOrig;
                else
                    sol
                    warning('Fitted model is not feasible for FBA yet. Check numerical issues within fitExperimentalFlux.')
                end
            end
            
            boolExpRxn = false(nRxn,1);
            boolExpExt = false(nExt,1);
            boolExpRxn(flxIdx(flxBool))=1;
            boolExpExt(eIdx(eBool))=1;
            if printLevel > 0
                fprintf('\n')
                fprintf('%s\n',[int2str(nnz(boolExpRxn)) ' measured reaction rates.'])
                fprintf('%s\n',[int2str(nnz(dv_flx==0 & boolExpRxn)) ' perfectly fit measured reaction rates.'])
                fprintf('%s\n',[int2str(nnz(dv_flx~=0 & boolExpRxn)) ' imperfectly fit measured reaction rates.'])
                fprintf('%s\n',[int2str(nnz(boolExpExt)) ' measured extra variables.'])
                fprintf('%s\n',[int2str(nnz(dv_e==0 & boolExpExt)) ' perfectly fit measured extra variables.'])
                fprintf('%s\n',[int2str(nnz(dv_e~=0 & boolExpExt)) ' imperfectly fit measured extra variables.'])
                Tr = table(model.rxns(dv_flx~=0 & boolExpRxn), model.rxnNames(dv_flx~=0 & boolExpRxn),dv_flx(dv_flx~=0 & boolExpRxn),'VariableNames',{'variables','variableNames','deviation from measured mean'});
                Te = table(model.evars(dv_e~=0 & boolExpExt), model.evarNames(dv_e~=0 & boolExpExt),dv_e(dv_e~=0 & boolExpExt),'VariableNames',{'variables','variableNames','deviation from measured mean'});
                T = vertcat(Tr, Te);
                disp(T)
                fprintf('%s\n',[int2str(nnz(p_flx)) ' reaction lower bounds relaxed.'])
                if isfield(model, 'SIntRxnBool') && ~isempty(model.SIntRxnBool)
                    fprintf('%s\n',[int2str(nnz(p_flx & ~model.SIntRxnBool)) ' external reaction lower bounds relaxed.'])
                    fprintf('%s\n',[int2str(nnz(p_flx~=0 & boolExpRxn~=0 & ~model.SIntRxnBool)) ' measured external metabolite lower bounds relaxed.'])
                    fprintf('%s\n',[int2str(nnz(p_flx~=0 & boolExpRxn==0 & ~model.SIntRxnBool)) ' unmeasured external metabolite lower bounds relaxed.'])
                end               
                fprintf('%s\n',[int2str(nnz(q_flx)) ' reaction upper bounds relaxed.'])
                if isfield(model, 'SIntRxnBool') && ~isempty(model.SIntRxnBool)
                    fprintf('%s\n',[int2str(nnz(q_flx & ~model.SIntRxnBool)) ' external reaction upper bounds relaxed.'])
                    fprintf('%s\n',[int2str(nnz(q_flx~=0 & boolExpRxn~=0 & ~model.SIntRxnBool)) ' measured external metabolite upper bounds relaxed.'])
                    fprintf('%s\n',[int2str(nnz(q_flx~=0 & boolExpRxn==0 & ~model.SIntRxnBool)) ' unmeasured external metabolite upper bounds relaxed.'])
                end
                fprintf('\n')
            end
        end
        
        % Identify the variables where the bounds are relaxed
        modelFitted.exometRelaxation.lowerBoundBool = p_flx >= param.eta;
        modelFitted.exometRelaxation.upperBoundBool = q_flx >= param.eta;
        modelFitted.exometRelaxation.evarlowerBoundBool = p_e >= param.eta;
        modelFitted.exometRelaxation.evarupperBoundBool = q_e >= param.eta;

        
        %% Adjust the bounds based on the standard deviation of the experimental data
        if 1
            % set bounds to +/- one standard deviation, except where bounds were relaxed, or
            % where it would change direction of reaction
            
            % Reversible reactions
            reversibleRxnBool = model.lb < 0 & model.ub > 0;
            reversibleEvarBool = model.evarlb < 0 & model.evarub > 0;
            modelFitted.lb(finiteExpBool_flx & ~modelFitted.exometRelaxation.lowerBoundBool & reversibleRxnBool)=...
                v_flx(finiteExpBool_flx & ~modelFitted.exometRelaxation.lowerBoundBool & reversibleRxnBool) -  vSD_flx(finiteExpBool_flx & ~modelFitted.exometRelaxation.lowerBoundBool & reversibleRxnBool);
            modelFitted.evarlb(finiteExpBool_e & ~modelFitted.exometRelaxation.evarlowerBoundBool & reversibleEvarBool)=...
                v_e(finiteExpBool_e & ~modelFitted.exometRelaxation.evarlowerBoundBool & reversibleEvarBool) -  vSD_e(finiteExpBool_e & ~modelFitted.exometRelaxation.evarlowerBoundBool & reversibleEvarBool);

            modelFitted.ub(finiteExpBool_flx & ~modelFitted.exometRelaxation.upperBoundBool & reversibleRxnBool)=...
                v_flx(finiteExpBool_flx & ~modelFitted.exometRelaxation.upperBoundBool & reversibleRxnBool) + vSD_flx(finiteExpBool_flx & ~modelFitted.exometRelaxation.upperBoundBool & reversibleRxnBool);
            modelFitted.evarub(finiteExpBool_e & ~modelFitted.exometRelaxation.evarupperBoundBool & reversibleEvarBool)=...
                v_e(finiteExpBool_e & ~modelFitted.exometRelaxation.evarupperBoundBool & reversibleEvarBool) + vSD_e(finiteExpBool_e & ~modelFitted.exometRelaxation.evarupperBoundBool & reversibleEvarBool);
            
            %forward reactions
            fwdRxnBool = model.lb >= 0 & model.ub ~=0;
            fwdEvarBool = model.evarlb >= 0 & model.evarub ~=0;
            modelFitted.lb(finiteExpBool_flx & ~modelFitted.exometRelaxation.lowerBoundBool & fwdRxnBool)=...
                max(0, v_flx(finiteExpBool_flx & ~modelFitted.exometRelaxation.lowerBoundBool & fwdRxnBool) -  vSD_flx(finiteExpBool_flx & ~modelFitted.exometRelaxation.lowerBoundBool & fwdRxnBool));
            modelFitted.evarlb(finiteExpBool_e & ~modelFitted.exometRelaxation.evarlowerBoundBool & fwdEvarBool)=...
                max(0, v_e(finiteExpBool_e & ~modelFitted.exometRelaxation.evarlowerBoundBool & fwdEvarBool) -  vSD_e(finiteExpBool_e & ~modelFitted.exometRelaxation.evarlowerBoundBool & fwdEvarBool));

            modelFitted.ub(finiteExpBool_flx & ~modelFitted.exometRelaxation.upperBoundBool & fwdRxnBool)=...
                v_flx(finiteExpBool_flx & ~modelFitted.exometRelaxation.upperBoundBool & fwdRxnBool) + vSD_flx(finiteExpBool_flx & ~modelFitted.exometRelaxation.upperBoundBool & fwdRxnBool);
            modelFitted.evarub(finiteExpBool_e & ~modelFitted.exometRelaxation.evarupperBoundBool & fwdEvarBool)=...
                v_e(finiteExpBool_e & ~modelFitted.exometRelaxation.evarupperBoundBool & fwdEvarBool) + vSD_e(finiteExpBool_e & ~modelFitted.exometRelaxation.evarupperBoundBool & fwdEvarBool);
            
            %reverse reactions
            revRxnBool = model.ub<=0 & model.lb~=0;
            revEvarBool = model.evarub<=0 & model.evarlb~=0;
            modelFitted.lb(finiteExpBool_flx & ~modelFitted.exometRelaxation.lowerBoundBool & revRxnBool)=...
                v_flx(finiteExpBool_flx & ~modelFitted.exometRelaxation.lowerBoundBool & revRxnBool) -  vSD_flx(finiteExpBool_flx & ~modelFitted.exometRelaxation.lowerBoundBool & revRxnBool);
            modelFitted.evarlb(finiteExpBool_e & ~modelFitted.exometRelaxation.evarlowerBoundBool & revEvarBool)=...
                v_e(finiteExpBool_e & ~modelFitted.exometRelaxation.evarlowerBoundBool & revEvarBool) -  vSD_e(finiteExpBool_e & ~modelFitted.exometRelaxation.evarlowerBoundBool & revEvarBool);

            modelFitted.ub(finiteExpBool_flx & ~modelFitted.exometRelaxation.upperBoundBool & revRxnBool)=...
                min(0, v_flx(finiteExpBool_flx & ~modelFitted.exometRelaxation.upperBoundBool & revRxnBool) + vSD_flx(finiteExpBool_flx & ~modelFitted.exometRelaxation.upperBoundBool & revRxnBool));
            modelFitted.evarub(finiteExpBool_e & ~modelFitted.exometRelaxation.evarupperBoundBool & revEvarBool)=...
                min(0, v_e(finiteExpBool_e & ~modelFitted.exometRelaxation.evarupperBoundBool & revEvarBool) + vSD_e(finiteExpBool_e & ~modelFitted.exometRelaxation.evarupperBoundBool & revEvarBool));

        else
            %set lower bound to match upper bound when upper bound relaxed
            modelFitted.lb(modelFitted.exometRelaxation.upperBoundBool) = modelFitted.ub(modelFitted.exometRelaxation.upperBoundBool);
            modelFitted.evarlb(modelFitted.exometRelaxation.evarupperBoundBool) = modelFitted.evarub(modelFitted.exometRelaxation.evarupperBoundBool);

            %set upper bound to match lower bound when lower bound relaxed
            modelFitted.ub(modelFitted.exometRelaxation.lowerBoundBool) = modelFitted.lb(modelFitted.exometRelaxation.lowerBoundBool);
            modelFitted.evarub(modelFitted.exometRelaxation.evarlowerBoundBool) = modelFitted.evarlb(modelFitted.exometRelaxation.evarlowerBoundBool);

            %also set the bounds specified by the experimental data, except where
            %bounds were relaxed
            modelFitted.lb(finiteExpBool_flx & ~modelFitted.exometRelaxation.lowerBoundBool)=v_flx(finiteExpBool_flx & ~modelFitted.exometRelaxation.lowerBoundBool);
            modelFitted.evarlb(finiteExpBool_e & ~modelFitted.exometRelaxation.evarlowerBoundBool)=v_e(finiteExpBool_e & ~modelFitted.exometRelaxation.evarlowerBoundBool);

            modelFitted.ub(finiteExpBool_flx & ~modelFitted.exometRelaxation.upperBoundBool)=v_flx(finiteExpBool_flx & ~modelFitted.exometRelaxation.upperBoundBool);
            modelFitted.evarub(finiteExpBool_e & ~modelFitted.exometRelaxation.evarupperBoundBool)=v_e(finiteExpBool_e & ~modelFitted.exometRelaxation.evarupperBoundBool);
        end
        
        %save the revised bounds in the exoMet structure
        specificData.exoMet.name(flxBool) = model.rxnNames(flxIdx(flxBool));
        specificData.exoMet.name(eBool) = model.evarNames(eIdx(eBool));
        specificData.exoMet.lb(flxBool) = modelFitted.lb(flxIdx(flxBool));
        specificData.exoMet.lb(eBool) = modelFitted.evarlb(eIdx(eBool));
        specificData.exoMet.wl(flxBool) = weightLower_flx(flxIdx(flxBool));
        specificData.exoMet.wl(eBool) = weightLower_e(eIdx(eBool));
        specificData.exoMet.p(flxBool) = p_flx(flxIdx(flxBool));
        specificData.exoMet.p(eBool) = p_e(eIdx(eBool));
        specificData.exoMet.lb_old(flxBool)=  model.lb(flxIdx(flxBool));
        specificData.exoMet.lb_old(eBool)=  model.evarlb(eIdx(eBool));
        specificData.exoMet.v(flxBool) = v_flx(flxIdx(flxBool));
        specificData.exoMet.v(eBool) = v_e(eIdx(eBool));
        
        %compute the sign of the model flux
        specificData.exoMet.sign_v = sign(specificData.exoMet.v);
        specificData.exoMet.sign_v(abs(specificData.exoMet.v)<param.boundPrecisionLimit)=0;
        
        %compute the sign of the experimental flux
        specificData.exoMet.sign_vExp = sign(specificData.exoMet.mean);
        
        %interval formed by mean +/- SD contains zero
        specificData.exoMet.sign_vExpSD = sign(specificData.exoMet.mean);
        specificData.exoMet.sign_vExpSD((specificData.exoMet.mean - specificData.exoMet.SD)<0 & (specificData.exoMet.mean + specificData.exoMet.SD)>0)=0;
        
        specificData.exoMet.signMatch = double(specificData.exoMet.sign_v == specificData.exoMet.sign_vExp);
        specificData.exoMet.dv(flxBool) = dv_flx(flxIdx(flxBool));
        specificData.exoMet.dv(eBool) = dv_e(eIdx(eBool));
        specificData.exoMet.wexp(flxBool) = weightExp_flx(flxIdx(flxBool));
        specificData.exoMet.wexp(eBool) = weightExp_e(eIdx(eBool));
        specificData.exoMet.ub_old(flxBool)=  model.ub(flxIdx(flxBool));
        specificData.exoMet.ub_old(eBool)=  model.evarub(eIdx(eBool));
        specificData.exoMet.q(flxBool)=  q_flx(flxIdx(flxBool));
        specificData.exoMet.q(eBool)=  q_e(eIdx(eBool));
        specificData.exoMet.wu(flxBool) = weightUpper_flx(flxIdx(flxBool));
        specificData.exoMet.wu(eBool) = weightUpper_e(eIdx(eBool));
        specificData.exoMet.ub(flxBool)=  modelFitted.ub(flxIdx(flxBool));
        specificData.exoMet.ub(eBool)=  modelFitted.evarub(eIdx(eBool));
        specificData.exoMet.vdv = specificData.exoMet.dv./specificData.exoMet.v;
        
        specificData.exoMet.lb(~(flxBool|eBool)) = NaN;
        specificData.exoMet.wl(~(flxBool|eBool)) = NaN;
        specificData.exoMet.p(~(flxBool|eBool)) = NaN;
        specificData.exoMet.lb_old(~(flxBool|eBool)) = NaN;
        specificData.exoMet.v(~(flxBool|eBool)) = NaN;
        specificData.exoMet.wexp(~(flxBool|eBool)) = NaN;
        specificData.exoMet.ub_old(~(flxBool|eBool)) = NaN;
        specificData.exoMet.q(~(flxBool|eBool)) = NaN;
        specificData.exoMet.wu(~(flxBool|eBool)) = NaN;
        specificData.exoMet.ub(~(flxBool|eBool)) = NaN;
        specificData.exoMet.signMatch(~(flxBool|eBool)) = NaN;
        
        specificData.exoMet = sortrows(specificData.exoMet, 'mean', 'ascend');
        
        modelFitted.exometRelaxationObj = obj;
        modelFitted.exometRelaxation.v = v_flx;
        modelFitted.exometRelaxation.v_extraVariables = v_e;
        modelFitted.exometRelaxation.p = p_flx;
        modelFitted.exometRelaxation.p_extraVariables = p_e;
        modelFitted.exometRelaxation.q = q_flx;
        modelFitted.exometRelaxation.q_extraVariables = q_e;
        modelFitted.exometRelaxation.dv = dv_flx;
        modelFitted.exometRelaxation.dv_extraVariables = dv_e;
        modelFitted.exometRelaxation.eta = param.eta;
        modelFitted.exometRelaxation.weightLower = weightLower_flx;
        modelFitted.exometRelaxation.weightLower_extraVariables = weightLower_e;
        modelFitted.exometRelaxation.weightUpper = weightUpper_flx;
        modelFitted.exometRelaxation.weightUpper_extraVariables = weightUpper_e;
        modelFitted.exometRelaxation.weightExp = weightExp_flx;
        modelFitted.exometRelaxation.weightExp_extraVariables = weightExp_e;
                
        %save the new model
        model = modelFitted;
        if any(model.lb > model.ub)
            error('lower bounds greater than upper bounds')
        end

    otherwise
        error('unrecognised mode')
end

if constraint
    
    % Map reactions in the model
    rxnsInModel = intersect(model.rxns, rxnList);
    rxnsNotInModel = setdiff(rxnList, rxnsInModel);
    
    % rxns not in the model
    if ~isempty(rxnsNotInModel)
        idNot = find(ismember(rxnList, rxnsNotInModel));
        if printLevel && ~isempty(idNot)
            disp('The following reactions could not be constrained since they are not present in the model:');
            disp(rxnsNotInModel)
        end
        rxnList(idNot) = [];
        rxn_lb(idNot) = [];
        rxn_ub(idNot) = [];
        constraintDescription(idNot) = [];
    end
    
    % Set constraints for reactions in the model
    if printLevel > 0
        disp(['Adding constraints on ' num2str(numel(rxnsInModel)) ' reactions']);
    end
    
    % Control check
    rxns2constrain = rxnList(ismember(rxnList ,rxnsInModel));
    if numel(rxns2constrain) ~= numel(unique(rxns2constrain))
        c = 0;
        repatedRxnsIdx = [];
        for i = 1:length(rxns2constrain)
            idR = find(ismember(rxnList, rxns2constrain(i)));
            if numel(idR) > 1 && ~any(ismember(repatedRxnsIdx, idR))
                warning(['Reaction ' rxnList{idR(end)} ' is repeated.'])
                c = c + 1;
                idx2delete(c) = idR(1:end - 1);
                repatedRxnsIdx = [repatedRxnsIdx; idR];
            end
        end
    end
    if exist('idx2delete', 'var')
        rxnList(idx2delete) = [];
        rxn_lb(idx2delete) = [];
        rxn_ub(idx2delete) = [];
        constraintDescription(idx2delete) = [];
    end
    
    rxnsConstrained = rxnList;
    % Change bounds
    for i = 1:length(rxnList)
        idR = find(ismember(rxnList, rxnList(i)));
        
        %lower bound
        if ~isnan(rxn_lb(idR))
            model = changeRxnBounds(model, rxnList(idR), rxn_lb(idR), 'l');
        end
        
        %upper bound
        if ~isnan(rxn_ub(idR))
            model = changeRxnBounds(model, rxnList(idR), rxn_ub(idR), 'u');
        elseif isnan(rxn_ub(idR)) && ismember(rxnList(i), table2array(specificData.essentialAA))
            %set upper bound of essential amino acids to zero, so no secretion possible.
            model = changeRxnBounds(model, rxnList(idR), 0, 'u');
        end
        model.constraintDescription(findRxnIDs(model, rxnList(idR))) = constraintDescription(idR);
    end
    
end

% Correct bounds if  bounds outside min, max or boundPrecisionLimit
generous_Minlb = find(model.lb < param.TolMinBoundary);
generous_Minub = find(model.ub < param.TolMinBoundary);
generous_Maxub = find(model.ub > param.TolMaxBoundary);
generous_Maxlb = find(model.lb > param.TolMaxBoundary);
generous_b = unique([generous_Minlb; generous_Minub; generous_Maxub; generous_Maxlb]);

format long g
modelBefore = model;
if ~isempty(generous_b)
    rxnsWithProblems = model.rxns(generous_b);
    if printLevel > 0
        disp(['These reactions have bounds larger than the recommended value = abs(', num2str(param.TolMaxBoundary) ')']);
        disp('The bounds for the following reactions have been adjusted:');
    end
    
    %min
    generous_MinlbRx = model.rxns(generous_Minlb);
    % adapt these bounds to the minimum allowed
    if ~isempty(generous_MinlbRx)
        for h = 1:length(generous_MinlbRx)
            model    = changeRxnBounds(model, generous_MinlbRx(h), param.TolMinBoundary, 'l');
        end
    end
    generous_MinubRx = model.rxns(generous_Minub);
    % adapt these bounds to the minimum allowed
    if ~isempty(generous_MinubRx)
        for h = 1:length(generous_MinubRx)
            model = changeRxnBounds(model, generous_MinubRx(h), param.TolMinBoundary, 'u');
        end
    end
    
    % max
    generous_MaxlbRx = model.rxns(generous_Maxlb);
    % adapt these bounds to the maximum allowed
    if ~isempty(generous_MaxlbRx)
        for u = 1:length(generous_MaxlbRx)
            model = changeRxnBounds(model, generous_MaxlbRx(u), param.TolMaxBoundary, 'l');
        end
    end
    generous_MaxubRx = model.rxns(generous_Maxub);
    % adapt these bounds to the maximum allowed
    if ~isempty(generous_MaxubRx)
        for u = 1:length(generous_MaxubRx)
            model = changeRxnBounds(model, generous_MaxubRx(u), param.TolMaxBoundary, 'u');
        end
    end
    
    if printLevel > 0
        disp('Number of corrected bounds (to min/max boundary):');
        disp(numel(generous_b));
    end
    if printLevel > 0
        printConstraints(modelBefore, -inf, inf, ismember(model.rxns, rxnsWithProblems), model, 0)
    end
    rxnBoundsCorrected = rxnsWithProblems;
    
    if any(model.lb > model.ub)
        error('lower bounds greater than upper bounds')
    end
else
    rxnBoundsCorrected = [];
end

if nExt > 0
    % Correct bounds of extra variables if outside min and max
    generous_Minlb_e = find(model.evarlb < param.TolMinBoundary);
    generous_Minub_e = find(model.evarub < param.TolMinBoundary);
    generous_Maxlb_e = find(model.evarlb > param.TolMaxBoundary);
    generous_Maxub_e = find(model.evarub > param.TolMaxBoundary);
    
    if ~isempty(generous_Minlb_e)
        model.evarlb(generous_Minlb_e) = param.TolMinBoundary;
    end
    if ~isempty(generous_Minub_e)
        model.evarub(generous_Minub_e) = param.TolMinBoundary;
    end
    if ~isempty(generous_Maxlb_e)
        model.evarlb(generous_Maxlb_e) = param.TolMaxBoundary;
    end
    if ~isempty(generous_Maxub_e)
        model.evarub(generous_Maxub_e) = param.TolMaxBoundary;
    end
end

% Identify reactions where the absolute value of the flux is less than the
% boundPrecisionLimit
meagre_lb = find(abs(model.lb) < param.boundPrecisionLimit & abs(model.lb) ~= 0);
meagre_ub = find(abs(model.ub) < param.boundPrecisionLimit & abs(model.ub) ~= 0);
belowLimit = unique([meagre_lb; meagre_ub]);

% Fix meagre bounds
modelBefore = model;
if ~isempty(belowLimit)
    rxnsWithProblems = model.rxns(belowLimit);
    if printLevel > 0
        disp(['These reactions have bounds smaller than the reccommended value = abs(', num2str(param.boundPrecisionLimit) ')']);
        disp('The bounds for the following reactions will be adjusted:');
    end
    
    %lb
    meagre_lbRx = model.rxns(meagre_lb);
    % adapt these bounds to the minimum allowed
    if ~isempty(meagre_lbRx)
        model = changeRxnBounds(model, meagre_lbRx, -param.boundPrecisionLimit, 'l');
    end
    
    %ub
    meagre_ubRx = model.rxns(meagre_ub);
    % adapt these bounds to the minimum allowed
    if ~isempty(meagre_ubRx)
        model = changeRxnBounds(model, meagre_ubRx, param.boundPrecisionLimit, 'u');
    end
    
    if printLevel > 0
        printConstraints(modelBefore, -inf, inf, ismember(model.rxns, rxnsWithProblems), model, 0)
    end
    rxnBoundsCorrected = [rxnBoundsCorrected; rxnsWithProblems];    
end

if nExt > 0
    % Identify extra variables where the absolute value < boundPrecisionLimit
    meagre_lb_eIdx = find(abs(model.evarlb) < param.boundPrecisionLimit & abs(model.evarlb) ~= 0);
    if ~isempty(meagre_lb_eIdx)
        negIdx = meagre_lb_eIdx(model.evarlb(meagre_lb_eIdx) < 0);
        posIdx = meagre_lb_eIdx(model.evarlb(meagre_lb_eIdx) > 0);
        model.evarlb(negIdx)= -param.boundPrecisionLimit;
        model.evarlb(posIdx) = param.boundPrecisionLimit;
    end
    meagre_ub_eIdx = find(abs(model.evarub) < param.boundPrecisionLimit & abs(model.evarub) ~= 0);
    if ~isempty(meagre_ub_eIdx)
        negIdx = meagre_ub_eIdx(model.evarub(meagre_ub_eIdx) < 0);
        posIdx = meagre_ub_eIdx(model.evarub(meagre_ub_eIdx) > 0);
        model.evarub(negIdx)= -param.boundPrecisionLimit;
        model.evarub(posIdx) = param.boundPrecisionLimit;
    end
end

if any(isnan([model.lb; model.ub]))
    error('at least one NaN bound')
end

newModel = model;
newSpecificData = specificData;

end