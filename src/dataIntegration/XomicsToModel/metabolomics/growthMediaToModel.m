function [model, specificData, coreRxnAbbr, modelGenerationReport] = growthMediaToModel(model, specificData, param, coreRxnAbbr, modelGenerationReport)
% Apply growth-media constraints from context-specific media data to a COBRA model
%
% USAGE:
%
%    [model, specificData, coreRxnAbbr, modelGenerationReport] = growthMediaToModel(model, specificData, param, coreRxnAbbr, modelGenerationReport)
%
% INPUTS:
%    model:    COBRA model with fields:
%
%                * .rxns - `n x 1` reaction identifiers
%                * .lb - `n x 1` lower flux bounds
%                * .ub - `n x 1` upper flux bounds
%
%    specificData:    A structure containing context-specific data with fields:
%
%                       * .mediaData - table of fresh-media constraints (with .mets and .rxns columns)
%                       * .exoMet - table of exometabolomic fluxes
%
%    param:    A structure containing the parameters for the function:
%
%                * .metabolomicsBeforeExtraction - Logical, whether metabolomics is added before extraction
%                * .debug - Logical, whether to save progress for debugging
%                * .workingDirectory - directory where debug files are written
%                * .printLevel - verbose level controlling printed output
%                * .TolMinBoundary - the reaction boundary's minimum value
%                * .TolMaxBoundary - the reaction boundary's maximum value
%                * .relaxOptions - options passed to relaxedFBA if the problem becomes infeasible
%
%    coreRxnAbbr:    core reaction identifiers
%    modelGenerationReport:    report struct accumulated during model generation
%
% OUTPUTS:
%    model:    the input COBRA model with media constraints applied (fields .rxns, .rxnNames, .lb, .ub updated)
%    specificData:    the input specificData with its media and exometabolomic fields updated
%    coreRxnAbbr:    updated core reaction identifiers
%    modelGenerationReport:    updated model-generation report
%
% .. Author(s): Aga W.

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