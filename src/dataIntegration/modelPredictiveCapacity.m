function [comparisonData, summary] = modelPredictiveCapacity(model, param)
% Test the model's predictive capacity in terms of its ability to predict uptake
% and secretions, as well as the consistency of flux in reactions and metabolites.
%
% USAGE:
%
%    [accuracySummary, fullReport, comparisonStats] = modelPredictiveCapacity(model, param)
%
% INPUT:
%    model:	A Cobra model to be tested
%
%    	* .S - Stoichiometric matrix
%    	* .mets - Metabolite ID vector
%    	* .rxns - Reaction ID vector
%    	* .lb - Lower bound vector
%    	* .ub - Upper bound vector
%
%   param:	Parameters used to test the model
%
%       * .tests - Array with the tests run on the model (Default: 'flux').
%       	'fluxConsistent': Flux consistency
%           'thermoConsistentFlux': Thermodynamic flux consistency
%           'flux': Objective function comparison based on a training set
%           'all': Do all tests
%       * .activeInactiveRxn - nx1 with entries {1,-1,0} depending on whether a
%           reaction must be active, inactive, or unspecified respectively
%           (Required for tests 'fluxConsistent' and 'thermoFluxConsistent').
%       * .presentAbsentMet - nx1 with entries {1,-1,0} depending on whether a
%           metabolite must be present, absent, or unspecified respectively
%           (Required for tests 'fluxConsistent' and 'thermoFluxConsistent').
%       * .trainingSet - Table with the training set. It includes the reaction
%           identifier, the reaction name, the measured mean flux, standard
%           deviation of the flux, the flux units, and the platform used to
%           measure it (Required for test 'flux').
%       * .objectives - List of objective functions to be tested (Required for
%           test 'flux'; Default: 'all'); supported objectives:
%          - 'unWeighted0norm' min 0-norm unweighted.
%          - 'Weighted0normGE' min 0-norm weighted by the gene expression.
%          - 'unWeighted1norm' min 1-norm unweighted
%          - 'Weighted1normGE' min 1-norm weighted by the gene expression
%          - 'unWeighted2norm' min 2-norm unweighted
%          - 'Weighted2normGE' min 2-norm weighted by the gene expression
%          - {'unWeightedTCBMflux'} unweighted thermodynamic constraint
%            based modelling for fluxes
%       * .printLevel - Greater than zero to receive more output printed.
%
% OUTPUT:
%    comparisonData: A struct array with two tables in it.
%       * .fullReport - A table comparing each tested reactions with columns:
%           - .fullReport.model - the name of the model
%           - .fullReport.objective - objective function
%           - .fullReport.rxns - reaction identifier
%           - .fullReport.mean - experimental mean flux
%           - .fullReport.SD - experimental standard deviation in flux
%           - .fullReport.target - sign of the exchange flux
%           - .fullReport.v - predicted exchange flux
%           - .fullReport.predict - sign of the predicted flux
%           - .fullReport.agree - true if sign of measured and predicted flux agree
%           - .fullReport.dv - difference between measured and estimated fluxes
%           - .fullReport.messages - error message in the case that there was a problem
%       * .comparisonStats: - A table containing predictive capacity statistics for each 
%         objective function tested.
%           - .comparisonStats.objective - objective function
%           - .comparisonStats.model - model compared (both, modelUpt or modelSec)
%           - .comparisonStats.qualAccuracy - qualitative predictive capacity
%           - .comparisonStats.Spearman - Spearman rank
%           - .comparisonStats.SpearmanPval - P value
%           - .comparisonStats.wEuclidNorm - Euclidean norm
%
%    summary: The average of the objective function accuracies and the average 
%    of the euclidean distances.


if nargin < 2 || isempty(param)
    param = struct;
end

% Add default parameters
if ~isfield(param, 'tests')
    param.tests = 'flux';
end
if ~isfield(param, 'activeInactiveRxn')
    param.activeInactiveRxn = ones(size(model.rxns));
end
if ~isfield(param, 'presentAbsentMet')
    param.presentAbsentMet = ones(size(model.mets));
end
if ~isfield(param, 'objectives')
    param.objectives =  {'unWeighted0norm'; 'Weighted0normGE'; 'unWeighted1norm'; 'Weighted1normGE';...
        'unWeighted2norm'; 'Weighted2normGE'; 'unWeightedTCBMflux'};
end
if ~isfield(param, 'printLevel')
    param.printLevel = 1;
end
if ~isfield(param, 'cobraSolver')
    param.cobraSolver = 'gurobi';
end
if ~isfield(param, 'approach')
    param.approach = 'UptSec';
end

% List tests and objectives
if ismember('all', param.tests)
    param.tests = {'fluxConsistent'; 'thermoConsistentFlux'; 'flux'};
end
if ismember('all', param.objectives)
    param.objectives = {'unWeighted0norm'; 'Weighted0normGE'; 'Weighted0normBBF'; ...
        'unWeighted1norm'; 'Weighted1normGE';  'Weighted1normBBF';...
        'unWeighted2norm'; 'Weighted2normGE'; 'Weighted2normBBF'; ...
        'unWeightedTCBMfluxConc';'unWeightedTCBMfluxConcNorm';'weightedTCBM';'weightedTCBMt'};
end

% Bound precision limit
feasTol = getCobraSolverParams('LP', 'feasTol');
boundPrecisionLimit = feasTol * 10; % this assumes uMol experimental data

% cleanup
if isfield(model,'g0')
    model = rmfield(model, 'g0');
end
if isfield(model,'g1')
    model = rmfield(model, 'g1');
end

if 0
    xOmicsModel = model;
    inputFolder = ['~' filesep 'work' filesep 'sbgCloud' filesep 'programExperimental' filesep 'projects' filesep 'xomics' filesep 'data' filesep 'Recon3D_301'];
    genericModelName = 'Recon3DModel_301_xomics_input';
    load([inputFolder filesep genericModelName],'model')
    %replace xOmicsModel.DfG0 with model.DfG0
    [LIA,LOCB] = ismember(model.mets,xOmicsModel.mets);
    xOmicsModel.DfG0(LOCB(LIA)) = model.DfG0(LIA);
    xOmicsModel.DfGt0(LOCB(LIA)) = model.DfGt0(LIA);
    
    %     %check replacement of xOmicsModel.field with corresponding model.field
    %     [LIA,LOCB] = ismember(model.mets,xOmicsModel.mets);
    %     xOmicsModel.mets2 = xOmicsModel.mets;
    %     xOmicsModel.mets2(LOCB(LIA)) = model.mets(LIA);
    %     M = [xOmicsModel.mets,xOmicsModel.mets2];
    
    model = xOmicsModel;
    clear xOmicsModel;
end

%% fluxConsistency

% if any(ismember(param.tests, {'fluxConsistent'; 'thermoConsistentFlux'}))
%     consistencyParam.tests = param.tests(ismember(param.tests, {'fluxConsistent'; 'thermoConsistentFlux'}));
%     consistencyParam.presentAbsentMet = param.presentAbsentMet;
%     consistencyParam.activeInactiveRxn = param.activeInactiveRxn;
%     consistencyParam.printLevel = param.printLevel;
%     [modelConsistencyInfo] = modelConsistency(model, consistencyParam);
% end

%% Flux prediction

if ismember({'flux'}, param.tests)
    
    % Data test
    if ~isfield(param, 'trainingSet')
        if isfield(model.XomicsToModelSpecificData, 'exoMet')
            param.trainingSet = model.XomicsToModelSpecificData.exoMet;
        else
            error('The trainingSet could not be found to compare model predictions.')
        end
    end
    
    if 0
        %TODO replace also with qualQuantAcc
        exoMet=param.trainingSet;
        [modelUpt,modelSec] = generateModelUptSec(model,exoMet,param);
        
        
        rxnTargetSecList = modelUpt.rxnTargetSec.rxns;
        rxnTargetSec_mean = modelUpt.rxnTargetSec.mean;
        rxnTargetSec_SD = modelUpt.rxnTargetSec.SD;
        
        rxnTargetUptList = modelSec.rxnTargetUpt.rxns;
        rxnTargetUpt_mean = modelSec.rxnTargetUpt.mean;
        rxnTargetUpt_SD = modelSec.rxnTargetUpt.SD;
        
        %% Prepare the table with the accuracy data
        nRows = length(param.objectives) * (length(rxnTargetSecList) + length(rxnTargetUptList));
        varTypes = {'string', 'string', 'string', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'string'};
        varNames = {'model', 'objective', 'rxns', 'mean', 'SD', 'target', 'v', 'predict', 'agree', 'dv', 'messages'};
        fullReport = table('Size', [nRows length(varTypes)], 'VariableTypes', varTypes, 'VariableNames', varNames);
        
        % Predict fluxes - modelSec
        multipleObjectivesParam.objectives = param.objectives;
        multipleObjectivesParam.modelType = 'sec';
        multipleObjectivesParam.printLevel = param.printLevel;
        solutionsSec = modelMultipleObjectives(modelSec, multipleObjectivesParam);
        
        % Analysis of uptake predictions
        for i = 1:length(param.objectives)
            bool = false(nRows, 1);
            bool((i - 1) * length(rxnTargetUptList) + 1:i * length(rxnTargetUptList)) = 1;
            %vTypes = {'string','string','string','double','double','double','double','double','double'};
            %vNames = {'model','objective','rxns','mean','SD','target','v','predict','dv'};
            fullReport.model(bool) = 'modelSec';
            fullReport.objective(bool) = param.objectives{i};
            fullReport.rxns(bool) = rxnTargetUptList;
            fullReport.mean(bool) = rxnTargetUpt_mean;
            fullReport.SD(bool) = rxnTargetUpt_SD;
            
            target = sign(rxnTargetUpt_mean);
            switch param.approach
                case 'mean'
                    %mean experimental uptake rates below analytical chemistry precision limit
                    %considered zero
                    target(abs(rxnTargetUpt_mean) < boundPrecisionLimit) = 0;
                case 'SD'
                    %if the interval mean +/- SD contains zero, then
                    %experimental uptake rate is considered zero
                    idxs = ((rxnTargetUpt_mean - rxnTargetUpt_SD) < 0) & ((rxnTargetUpt_mean + rxnTargetUpt_SD) > 0);
                    target(idxs) = 0;
                case 'UptSec'
                    idxs = ((rxnTargetUpt_mean - rxnTargetUpt_SD) < 0) & ((rxnTargetUpt_mean + rxnTargetUpt_SD) > 0);
                    target(idxs)=NaN;
            end
            fullReport.target(bool) = target;
            
            if solutionsSec.(param.objectives{i}).stat == 1 || solutionsSec.(param.objectives{i}).stat == 3
                fluxRxn = solutionsSec.(param.objectives{i}).v;
                fullReport.v(bool) = fluxRxn(findRxnIDs(modelSec, rxnTargetUptList));
                predict = sign(fullReport.v(bool));
                switch param.approach
                    case 'mean'
                        %if the predicted flux magnitude is below fluxEpsilon,
                        %the predicted flux is considered zero
                        predict(abs(predict) < boundPrecisionLimit) = 0;
                    case 'SD'
                        %if the predicted flux magnitude is within the analytical chemistry mean +/- SD it is considered zero
                        predict(target==0 & (rxnTargetUpt_mean - rxnTargetUpt_SD) < fullReport.v(bool) & (rxnTargetUpt_mean + rxnTargetUpt_SD) > fullReport.v(bool)) = 0;
                    case 'UptSec'
                        predict(isnan(target))=NaN;
                end
                
                fullReport.predict(bool) = predict;
                
                fullReport.agree(bool) = fullReport.target(bool) == fullReport.predict(bool);
                fullReport.dv(bool) = fullReport.mean(bool) - fullReport.v(bool);
            else
                fullReport.predict(bool) = NaN;
                fullReport.agree(bool) = NaN;
                fullReport.dv(bool) = NaN;
                if isfield(solutionsSec.(param.objectives{i}), 'messages')
                    fullReport.messages(bool) = solutionsSec.(param.objectives{i}).messages;
                end
                if isfield(solutionsSec.(param.objectives{i}), 'message')
                    fullReport.messages(bool) = solutionsSec.(param.objectives{i}).message;
                end
                warning([param.objectives{i} ' not optimal. stat = ' num2str(solutionsSec.(param.objectives{i}).stat)])
            end
        end
        
        % Predict fluxes - modelUpt
        multipleObjectivesParam.modelType = 'upt';
        solutionsUpt = modelMultipleObjectives(modelUpt, multipleObjectivesParam);
        
        % Analysis of secretion predictions
        for i = 1:length(param.objectives)
            bool = false(nRows, 1);
            %put the secretion predictions after the uptake
            %predictions
            bool((length(param.objectives) * length(rxnTargetUptList)) + (i - 1) * ...
                length(rxnTargetSecList) + 1:(length(param.objectives) * ...
                length(rxnTargetUptList)) + i * length(rxnTargetSecList)) = 1;
            %vTypes = {'string','string','string','double','double','double','double','double','double'};
            %vNames = {'model','objective','rxns','mean','SD','target','v','predict','dv'};
            fullReport.model(bool) = 'modelUpt';
            fullReport.objective(bool) = param.objectives{i};
            fullReport.rxns(bool) = rxnTargetSecList;
            fullReport.mean(bool) = rxnTargetSec_mean;
            fullReport.SD(bool) = rxnTargetSec_SD;
            target = sign(rxnTargetSec_mean);
            
            switch param.approach
                case 'mean'
                    %mean experimental uptake rates below analytical chemistry precision limit
                    %considered zero
                    target(abs(rxnTargetSec_mean) < boundPrecisionLimit) = 0;
                case 'SD'
                    %if the interval mean +/- SD contains zero, then
                    %experimental uptake rate is considered zero
                    idxs = ((rxnTargetSec_mean - rxnTargetSec_SD) < 0) & ((rxnTargetSec_mean + rxnTargetSec_SD) > 0);
                    target(idxs) = 0;
                case 'UptSec'
                    idxs = ((rxnTargetSec_mean - rxnTargetSec_SD) < 0) & ((rxnTargetSec_mean + rxnTargetSec_SD) > 0);
                    target(idxs) = NaN;
            end
            fullReport.target(bool) = target;
            
            if solutionsUpt.(param.objectives{i}).stat == 1
                fluxRxn = solutionsUpt.(param.objectives{i}).v;
                fullReport.v(bool) = fluxRxn(findRxnIDs(modelUpt, rxnTargetSecList));
                predict = sign(fullReport.v(bool));
                
                switch param.approach
                    case 'mean'
                        %if the predicted flux magnitude is below fluxEpsilon,
                        %the predicted flux is considered zero
                        predict(abs(predict) < boundPrecisionLimit) = 0;
                    case 'SD'
                        %if the predicted flux magnitude is within the analytical chemistry mean +/- SD it is considered zero
                        predict(target==0 & (rxnTargetSec_mean - rxnTargetSec_SD) < fullReport.v(bool) & (rxnTargetSec_mean + rxnTargetSec_SD) > fullReport.v(bool)) = 0;
                    case 'UptSec'
                        predict(isnan(target))=NaN;
                end
                
                fullReport.predict(bool) = predict;
                
                fullReport.agree(bool) = fullReport.target(bool) == fullReport.predict(bool);
                fullReport.dv(bool) = fullReport.mean(bool) - fullReport.v(bool);
            else
                fullReport.predict(bool) = NaN;
                fullReport.agree(bool) = NaN;
                fullReport.dv(bool) = NaN;
                if isfield(solutionsUpt.(param.objectives{i}), 'messages')
                    fullReport.messages(bool) = solutionsUpt.(param.objectives{i}).messages;
                end
                warning([param.objectives{i} ' not optimal. stat = '''''])
            end
        end
        
    else
        if iscell(param.trainingSet.mean)
            param.trainingSet.mean = str2double(param.trainingSet.mean);
        end
        if iscell(param.trainingSet.SD)
            param.trainingSet.SD = str2double(param.trainingSet.SD);
        end
        
        experimentalMean = param.trainingSet.mean;
        experimentalSD = param.trainingSet.SD;
        
        % Identify secretions and uptakes present in the model
        exoMetRxnsIdx = ismember(param.trainingSet.rxns, model.rxns);
        
        % Secretions
        switch param.approach
            case 'mean'
                boolSec = experimentalMean > 0 & exoMetRxnsIdx;
            case 'SD'
                boolSec = (experimentalMean - experimentalSD) > 0 & exoMetRxnsIdx;
            case 'UptSec'
                boolSec = (experimentalMean - experimentalSD) > 0 & exoMetRxnsIdx;
        end
        
        rxnTargetSecList = param.trainingSet.rxns(boolSec);
        rxnTargetSec_mean = param.trainingSet.mean(boolSec);
        rxnTargetSec_SD = param.trainingSet.SD(boolSec);
        
        % Uptakes
        switch param.approach
            case 'mean'
                boolUpt = experimentalMean < 0 & exoMetRxnsIdx;
            case 'SD'
                boolUpt = (experimentalMean + experimentalSD) < 0 & exoMetRxnsIdx;
            case 'UptSec'
                boolUpt = (experimentalMean + experimentalSD) < 0 & exoMetRxnsIdx;
        end
        
        rxnTargetUptList = param.trainingSet.rxns(boolUpt);
        rxnTargetUpt_mean = param.trainingSet.mean(boolUpt);
        rxnTargetUpt_SD = param.trainingSet.SD(boolUpt);
        
        % Prepare the table with the accuracy data
        nRows = length(param.objectives) * (length(rxnTargetSecList) + length(rxnTargetUptList));
        varTypes = {'string', 'string', 'string', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'string'};
        varNames = {'model', 'objective', 'rxns', 'mean', 'SD', 'target', 'v', 'predict', 'agree', 'dv', 'messages'};
        fullReport = table('Size', [nRows length(varTypes)], 'VariableTypes', varTypes, 'VariableNames', varNames);
        
        
        %% MODEL_SEC
        
        % Check model
        solution = optimizeCbModel(model);
        if solution.stat~=1
            error('Model does not solve properly')
        else
            modelSec = model;
        end
        
        if 1
            % Open uptake bounds
            modelSec = changeRxnBounds(modelSec, rxnTargetUptList, min(model.lb), 'l');
            modelSec = changeRxnBounds(modelSec, rxnTargetUptList, max(model.ub), 'u');
        else
            %set to preconditioned value
            [LIA,LOCB] = ismember(rxnTargetUptList,modelSec.rxns);
            LOCB(LOCB == 0) = [];
            new_lb(LIA,1) = modelSec.lb_preconditioned(LOCB);
            new_ub(LIA,1) = modelSec.ub_preconditioned(LOCB);
            % Open uptake bounds
            modelSec = changeRxnBounds(modelSec, rxnTargetUptList, new_lb, 'l');
            modelSec = changeRxnBounds(modelSec, rxnTargetUptList, new_ub, 'u');
        end
        
        solution = optimizeCbModel(modelSec);
        if solution.stat~=1
            error('modelSec model does not solve properly')
        end
        
        % Predict fluxes - modelSec
        multipleObjectivesParam.objectives = param.objectives;
        multipleObjectivesParam.modelType = 'sec';
        multipleObjectivesParam.printLevel = param.printLevel;
        solutionsSec = modelMultipleObjectives(modelSec, multipleObjectivesParam);
        
        % Analysis of uptake predictions
        for i = 1:length(param.objectives)
            bool = false(nRows, 1);
            bool((i - 1) * length(rxnTargetUptList) + 1:i * length(rxnTargetUptList)) = 1;
            %vTypes = {'string','string','string','double','double','double','double','double','double'};
            %vNames = {'model','objective','rxns','mean','SD','target','v','predict','dv'};
            fullReport.model(bool) = 'modelSec';
            fullReport.objective(bool) = param.objectives{i};
            fullReport.rxns(bool) = rxnTargetUptList;
            fullReport.mean(bool) = rxnTargetUpt_mean;
            fullReport.SD(bool) = rxnTargetUpt_SD;
            
            target = sign(rxnTargetUpt_mean);
            switch param.approach
                case 'mean'
                    %mean experimental uptake rates below analytical chemistry precision limit
                    %considered zero
                    target(abs(rxnTargetUpt_mean) < boundPrecisionLimit) = 0;
                case 'SD'
                    %if the interval mean +/- SD contains zero, then
                    %experimental uptake rate is considered zero
                    idxs = ((rxnTargetUpt_mean - rxnTargetUpt_SD) < 0) & ((rxnTargetUpt_mean + rxnTargetUpt_SD) > 0);
                    target(idxs) = 0;
                case 'UptSec'
                    idxs = ((rxnTargetUpt_mean - rxnTargetUpt_SD) < 0) & ((rxnTargetUpt_mean + rxnTargetUpt_SD) > 0);
                    target(idxs)=NaN;
            end
            fullReport.target(bool) = target;
            
            if solutionsSec.(param.objectives{i}).stat == 1 || solutionsSec.(param.objectives{i}).stat == 3
                fluxRxn = solutionsSec.(param.objectives{i}).v;
                fullReport.v(bool) = fluxRxn(findRxnIDs(modelSec, rxnTargetUptList));
                predict = sign(fullReport.v(bool));
                switch param.approach
                    case 'mean'
                        %if the predicted flux magnitude is below fluxEpsilon,
                        %the predicted flux is considered zero
                        predict(abs(predict) < boundPrecisionLimit) = 0;
                    case 'SD'
                        %if the predicted flux magnitude is within the analytical chemistry mean +/- SD it is considered zero
                        predict(target==0 & (rxnTargetUpt_mean - rxnTargetUpt_SD) < fullReport.v(bool) & (rxnTargetUpt_mean + rxnTargetUpt_SD) > fullReport.v(bool)) = 0;
                    case 'UptSec'
                        predict(isnan(target))=NaN;
                end
                
                fullReport.predict(bool) = predict;
                
                fullReport.agree(bool) = fullReport.target(bool) == fullReport.predict(bool);
                fullReport.dv(bool) = fullReport.mean(bool) - fullReport.v(bool);
            else
                fullReport.predict(bool) = NaN;
                fullReport.agree(bool) = NaN;
                fullReport.dv(bool) = NaN;
                if isfield(solutionsSec.(param.objectives{i}), 'messages')
                    fullReport.messages(bool) = solutionsSec.(param.objectives{i}).messages;
                end
                if isfield(solutionsSec.(param.objectives{i}), 'message')
                    fullReport.messages(bool) = solutionsSec.(param.objectives{i}).message;
                end
                warning([param.objectives{i} ' not optimal. stat = ' num2str(solutionsSec.(param.objectives{i}).stat)])
            end
        end
        
        %% MODEL_UPT
        
        % Generate modelUpt
        modelUpt = model;
        
        if 1
            % Open secretion bounds
            modelUpt = changeRxnBounds(modelUpt, rxnTargetSecList, min(model.lb), 'l');
            modelUpt = changeRxnBounds(modelUpt, rxnTargetSecList, max(model.ub), 'u');
        else
            %set to preconditioned value
            [LIA,LOCB] = ismember(rxnTargetSecList,modelSec.rxns);
            LOCB(LOCB == 0) = [];
            new_lb(LIA,1) = modelUpt.lb_preconditioned(LOCB);
            new_ub(LIA,1) = modelUpt.ub_preconditioned(LOCB);
            % Open secretion bounds
            modelUpt = changeRxnBounds(modelUpt, rxnTargetSecList, new_lb, 'l');
            modelUpt = changeRxnBounds(modelUpt, rxnTargetSecList, new_ub, 'u');
        end
        
        solution = optimizeCbModel(modelUpt);
        if solution.stat~=1
            error('modelUpt model does not solve properly')
        end
        
        % Predict fluxes - modelUpt
        multipleObjectivesParam.modelType = 'upt';
        solutionsUpt = modelMultipleObjectives(modelUpt, multipleObjectivesParam);
        
        % Analysis of secretion predictions
        for i = 1:length(param.objectives)
            bool = false(nRows, 1);
            %put the secretion predictions after the uptake
            %predictions
            bool((length(param.objectives) * length(rxnTargetUptList)) + (i - 1) * ...
                length(rxnTargetSecList) + 1:(length(param.objectives) * ...
                length(rxnTargetUptList)) + i * length(rxnTargetSecList)) = 1;
            %vTypes = {'string','string','string','double','double','double','double','double','double'};
            %vNames = {'model','objective','rxns','mean','SD','target','v','predict','dv'};
            fullReport.model(bool) = 'modelUpt';
            fullReport.objective(bool) = param.objectives{i};
            fullReport.rxns(bool) = rxnTargetSecList;
            fullReport.mean(bool) = rxnTargetSec_mean;
            fullReport.SD(bool) = rxnTargetSec_SD;
            target = sign(rxnTargetSec_mean);
            
            switch param.approach
                case 'mean'
                    %mean experimental uptake rates below analytical chemistry precision limit
                    %considered zero
                    target(abs(rxnTargetSec_mean) < boundPrecisionLimit) = 0;
                case 'SD'
                    %if the interval mean +/- SD contains zero, then
                    %experimental uptake rate is considered zero
                    idxs = ((rxnTargetSec_mean - rxnTargetSec_SD) < 0) & ((rxnTargetSec_mean + rxnTargetSec_SD) > 0);
                    target(idxs) = 0;
                case 'UptSec'
                    idxs = ((rxnTargetSec_mean - rxnTargetSec_SD) < 0) & ((rxnTargetSec_mean + rxnTargetSec_SD) > 0);
                    target(idxs) = NaN;
            end
            fullReport.target(bool) = target;
            
            if solutionsUpt.(param.objectives{i}).stat == 1
                fluxRxn = solutionsUpt.(param.objectives{i}).v;
                fullReport.v(bool) = fluxRxn(findRxnIDs(modelUpt, rxnTargetSecList));
                predict = sign(fullReport.v(bool));
                
                switch param.approach
                    case 'mean'
                        %if the predicted flux magnitude is below fluxEpsilon,
                        %the predicted flux is considered zero
                        predict(abs(predict) < boundPrecisionLimit) = 0;
                    case 'SD'
                        %if the predicted flux magnitude is within the analytical chemistry mean +/- SD it is considered zero
                        predict(target==0 & (rxnTargetSec_mean - rxnTargetSec_SD) < fullReport.v(bool) & (rxnTargetSec_mean + rxnTargetSec_SD) > fullReport.v(bool)) = 0;
                    case 'UptSec'
                        predict(isnan(target))=NaN;
                end
                
                fullReport.predict(bool) = predict;
                
                fullReport.agree(bool) = fullReport.target(bool) == fullReport.predict(bool);
                fullReport.dv(bool) = fullReport.mean(bool) - fullReport.v(bool);
            else
                fullReport.predict(bool) = NaN;
                fullReport.agree(bool) = NaN;
                fullReport.dv(bool) = NaN;
                if isfield(solutionsUpt.(param.objectives{i}), 'messages')
                    fullReport.messages(bool) = solutionsUpt.(param.objectives{i}).messages;
                end
                warning([param.objectives{i} ' not optimal. stat = '''''])
            end
        end
        
    end
    %% Flux prediction: qualitative accuracy
    
    nRows = 3 * length(param.objectives);
    varTypes = {'string', 'string', 'double', 'double','double','double'};
    varNames = {'objective', 'model', 'qualAccuracy', 'Spearman', 'SpearmanPval','wEuclidNorm'};
    comparisonStats = table('Size', [nRows length(varTypes)], 'VariableTypes', varTypes, 'VariableNames', varNames);
    
    for i = 1:length(param.objectives)
        
        % modelSec and modelUpt combined
        ind = (i - 1) * 3 + 1;
        comparisonStats.objective{ind} = param.objectives{i};
        rowsInReport = strcmp(fullReport.objective, param.objectives{i}) & ~isnan(fullReport.target);
        comparisonStats.model{ind} = 'both';
        v = fullReport.v(rowsInReport);
        dv = fullReport.dv(rowsInReport);
        vExp = fullReport.mean(rowsInReport);
        %bool = ~(isoutlier(dv) | isnan(dv) | isnan(vExp));
        bool = ~(isnan(dv) | isnan(vExp));
        w  = sparse(1./(1 + (vExp.^2)));
        if any(bool)
            comparisonStats.wEuclidNorm(ind) = sqrt(dv(bool)' * diag(w(bool)) * dv(bool));
            [Spearman, SpearmanPval]  = corr(v(bool),vExp(bool),'Type','Spearman');
            comparisonStats.Spearman(ind) = Spearman;
            comparisonStats.SpearmanPval(ind) = SpearmanPval;
        else
            comparisonStats.wEuclidNorm(ind) = NaN;
            comparisonStats.SpearmanPval(ind) = NaN;
        end
        % confusionMatrix
        C = confusionmat(fullReport.target(rowsInReport), fullReport.predict(rowsInReport), 'ORDER',[1, 0, -1]);
        comparisonStats.qualAccuracy(ind) = sum(diag(C), 1) / sum(sum(C, 1));
        
        %modelSec
        ind = (i - 1) * 3 + 2;
        comparisonStats.objective{ind} = param.objectives{i};
        rowsInReport = strcmp(fullReport.objective, param.objectives{i}) & strcmp(fullReport.model, 'modelSec') & ~isnan(fullReport.target);
        comparisonStats.model{ind} = 'modelSec';
        v = fullReport.v(rowsInReport);
        dv = fullReport.dv(rowsInReport);
        vExp = fullReport.mean(rowsInReport);
        %bool = ~(isoutlier(dv) | isnan(dv) | isnan(vExp));
        bool = ~(isnan(dv) | isnan(vExp));
        w  = sparse(1./(1 + (vExp.^2)));
        if any(bool)
            comparisonStats.wEuclidNorm(ind) = sqrt(dv(bool)' * diag(w(bool)) * dv(bool));
            [Spearman, SpearmanPval]  = corr(v(bool),vExp(bool),'Type','Spearman');
            comparisonStats.Spearman(ind) = Spearman;
            comparisonStats.SpearmanPval(ind) = SpearmanPval;
        else
            comparisonStats.wEuclidNorm(ind) = NaN;
            comparisonStats.SpearmanPval(ind) = NaN;
        end
        % confusionMatrix
        C = confusionmat(fullReport.target(rowsInReport), fullReport.predict(rowsInReport), 'ORDER',[1, 0, -1]);
        comparisonStats.qualAccuracy(ind) = sum(diag(C), 1) / sum(sum(C, 1));
        
        %modelUpt
        ind = (i - 1) * 3 + 3;
        comparisonStats.objective{ind} = param.objectives{i};
        rowsInReport = strcmp(fullReport.objective, param.objectives{i}) & strcmp(fullReport.model, 'modelUpt') & ~isnan(fullReport.target);
        comparisonStats.model{ind} = 'modelUpt';
        v = fullReport.v(rowsInReport);
        dv = fullReport.dv(rowsInReport);
        vExp = fullReport.mean(rowsInReport);
        %bool = ~(isoutlier(dv) | isnan(dv) | isnan(vExp));
        bool = ~(isnan(dv) | isnan(vExp));
        w  = sparse(1./(1 + (vExp.^2)));
        if any(bool)
            comparisonStats.wEuclidNorm(ind) = sqrt(dv(bool)' * diag(w(bool)) * dv(bool));
            [Spearman, SpearmanPval]  = corr(v(bool),vExp(bool),'Type','Spearman');
            comparisonStats.Spearman(ind) = Spearman;
            comparisonStats.SpearmanPval(ind) = SpearmanPval;
        else
            comparisonStats.wEuclidNorm(ind) = NaN;
            comparisonStats.SpearmanPval(ind) = NaN;
        end
        if isnan(comparisonStats.SpearmanPval(ind))
            disp(ind)
        end
        % confusionMatrix
        C = confusionmat(fullReport.target(rowsInReport), fullReport.predict(rowsInReport),'ORDER',[1, 0, -1]);
        comparisonStats.qualAccuracy(ind) = sum(diag(C), 1) / sum(sum(C, 1));
        
    end
    
end

%% Comparison data

% if any(ismember({'fluxConsistent', 'thermoConsistentFlux'}, param.tests))
%     comparisonData.metaboliteConsistency = modelConsistencyInfo.metaboliteConsistency;
%     comparisonData.reactionConsistency = modelConsistencyInfo.reactionConsistency;
% end
if ismember({'flux'}, param.tests)
    comparisonData.fullReport = fullReport;
    comparisonData.comparisonStats = comparisonStats;
end
%% Prepare summary

% if any(ismember({'fluxConsistent', 'thermoConsistentFlux'}, param.tests))
%     % consistencyAccuracy
%     consistencyAccuracy = mean([modelConsistencyInfo.fluxConsistent_accuracyMets; ...
%         modelConsistencyInfo.fluxConsistent_accuracyRxns; ...
%         modelConsistencyInfo.thermoFluxConsistent_accuracyMets; ...
%         modelConsistencyInfo.thermoFluxConsistent_accuracyRxns],'omitnan');
% end

if ismember({'flux'}, param.tests)
    % fluxAccuracy
    rows = find(strcmp(comparisonStats.model, 'both'));
    unfeasibleOF = isnan(comparisonStats.qualAccuracy(rows));
    objectiveOutlier = isoutlier(comparisonStats.qualAccuracy(rows));
    fluxAccuracy = mean(comparisonStats.qualAccuracy(rows(~objectiveOutlier & ~unfeasibleOF)));
    
    % euclideanDistance
    objectiveOutlier = isoutlier(comparisonStats.wEuclidNorm(rows));
    euclideanDistance = mean(comparisonStats.wEuclidNorm(rows(~objectiveOutlier & ~unfeasibleOF)));
end

if prod(ismember({'fluxConsistent'; 'thermoConsistentFlux'; 'flux'}, param.tests))
    
    summary = table([consistencyAccuracy;...
        fluxAccuracy; ...
        euclideanDistance],...
        ...
        'VariableNames', ...
        {'Value'},...
        'RowNames',...
        {'Consistency accuracy'; ...
        'Flux accuracy'; ...
        'Euclidean distance'});
    
elseif any(ismember(param.tests, {'fluxConsistent'; 'thermoConsistentFlux'}))
    
    summary.consistencyAccuracy = consistencyAccuracy;
    
elseif ismember({'flux'}, param.tests)
    
    summary.fluxAccuracy = fluxAccuracy;
    summary.euclideanDistance = euclideanDistance;
    
end

end
