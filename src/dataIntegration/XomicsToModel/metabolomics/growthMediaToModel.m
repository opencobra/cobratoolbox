function [model, specificData, coreRxnAbbr, modelGenerationReport] = growthMediaToModel(model, specificData, param, coreRxnAbbr, modelGenerationReport)
%
% USAGE:
%   [model, specificData, coreRxnAbbr, modelGenerationReport] = growthMediaToModel(model, specificData, param, coreRxnAbbr, modelGenerationReport)
%
% INPUTS:
%  model.rxns:               
%  model.rxnNames:       
%  model.lb:                   
%  model.ub:                   
%  specificData.mediaData:
%  specificData.mediaData.mets:
%  specificData.mediaData.rxns:
%  specificData.exoMet:
%
%  param.metabolomicsBeforeExtraction:
%  param.debug:             
%  param.workingDirectory:
%  param.printLevel:   
%  param.TolMinBoundary:
%  param.TolMaxBoundary:
%  param.relaxOptions:
%  coreRxnAbbr:             
%  modelGenerationReport:
%
% OUTPUTS:
%  model.rxns:               
%  model.rxnNames:       
%  model.lb:                   
%  model.ub:                   
%  specificData.mediaData:
%  specificData.mediaData.mediaData:
%  specificData.mediaData.mets:
%  specificData.mediaData.Properties:
%  specificData.mediaData.rxns:
%  specificData.exoMet:
%  specificData.exoMet.exoMet:
%  specificData.exoMet.ismedia:
%  coreRxnAbbr:             
%  modelGenerationReport:
%
% EXAMPLE:
%
% NOTE:
%
% Author(s): Aga W.

if param.metabolomicsBeforeExtraction && param.debug
    save([param.workingDirectory filesep '10.a.debug_prior_to_media_constraints.mat'])
elseif param.debug
    save([param.workingDirectory filesep '22.a.debug_prior_to_media_constraints.mat'])
end

%% 10/22.a. Set growth media constraints (if provided)

if isfield(specificData, 'mediaData') && ~isempty(specificData.mediaData)
    
    if param.printLevel > 0
        disp('--------------------------------------------------------------')
        disp(' ')
        disp('Adding growth media information...')
    end
    
    % Constrain media reactions
    if ~ismember('rxns', specificData.mediaData.Properties.VariableNames) && ismember('mets', specificData.mediaData.Properties.VariableNames)
        modelTemp = findSExRxnInd(model);
        allExRxns = model.rxns(modelTemp.ExchRxnBool);
        for i = 1:length(specificData.mediaData.mets)
            if any(contains(allExRxns, strcat('_', specificData.mediaData.mets(i))))
                specificData.mediaData.rxns(i) = allExRxns(contains(allExRxns, strcat('_', specificData.mediaData.mets(i))));
            end
        end
        [model, rxnsConstrained, rxnBoundsCorrected] = constrainRxns(model, specificData, param, 'mediaDataConstraints', param.printLevel);
    elseif ismember('rxns', specificData.mediaData.Properties.VariableNames)
        [model, rxnsConstrained, rxnBoundsCorrected] = constrainRxns(model, specificData, param, 'mediaDataConstraints', param.printLevel);
    end
    
    % Identify media reactions in metabolomic data
    if isfield(specificData,'exoMet')
        specificData.exoMet.ismedia = false(length(specificData.exoMet.mean), 1);
        specificData.exoMet.ismedia(ismember(specificData.exoMet.rxns, specificData.mediaData.rxns)) = 1;
    end
    
    if param.printLevel > 0
        disp(' ')
    end
    clear modelTemp
    
    if ~isempty(rxnsConstrained)
        if param.printLevel > 1
            fprintf('%s\n\n','Growth media bounds were set on the following reactions:')
            rxnsConstrainedBool = ismember(model.rxns, rxnsConstrained);
            table(model.rxns(rxnsConstrainedBool), model.rxnNames(rxnsConstrainedBool),...
                model.lb(rxnsConstrainedBool), model.ub(rxnsConstrainedBool), ...
                printRxnFormula(model, 'rxnAbbrList', model.rxns(rxnsConstrainedBool), ...
                'printFlag', false), 'VariableNames', {'rxnsConstrained', ...
                'Name', 'lb', 'ub', 'equation'})
            %printConstraints(model, options.TolMinBoundary, options.TolMaxBoundary, ismember(model.rxns, rxnsConstrained))
        end
    end
    
    if ~isempty(rxnBoundsCorrected)
        if param.printLevel > 1
            fprintf('%s\n\n','Bounds were corrected by constrainRxns on the following reactions:')
            printConstraints(model, param.TolMinBoundary, param.TolMaxBoundary, ismember(model.rxns, rxnBoundsCorrected))
        end
    end
    
    if any(model.lb > model.ub)
        error('lower bounds greater than upper bounds')
    end
end

% Check feasibility
if isfield(specificData, 'mediaData') && ~isempty(specificData.mediaData)
    sol = optimizeCbModel(model);
    if  sol.stat ~=1
        fprintf('%s\n','Infeasible after application of growth media constraints. Trying relaxation...')
        %options.relaxOptions.rxns = unique([options.exoMet.rxns; options.mediaData.rxns]);
        [solution, modelTemp] = relaxedFBA(model, param.relaxOptions);
        if solution.stat==1
            fprintf('%s\n','.. relaxation worked.')
            model = modelTemp;
        else
            error('Infeasible after application of media constraints and relaxation failed.')
        end
    elseif sol.stat ==1
        if param.printLevel>0
            disp(' ')
            fprintf('%s\n\n','Feasible after application of media constraints.')
        end
    end
end