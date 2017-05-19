function tissueModel = MBA(model, expressionRxns, threshold_medium, threshold_high, tol, core)
% Uses the MBA algorithm (`Jerby et al., 2010`) to extract a context
% specific model using data. MBA algorithm defines high-confidence reactions
% to ensure activity in the extracted model. Medium confidence reactions
% are only kept when a certain parsimony trade-off is met. In random order,
% the algorithm prunes other reactions and removes them if not required to
% support high- or medium-confidence reactions.
%
% USAGE:
%
%    tissueModel = MBA(model, expressionRxns, threshold_medium, threshold_high, tol, core)
%
% INPUTS:
%    model:               input model (COBRA model structure)
%    expressionRxns:      expression data, corresponding to `model.rxns` (see
%                         `mapGeneToRxn.m`)
%    threshold_medium:    reactions with expression above this threshold are medium
%                         confidence (expression threshold)
%    threshold_high:      reactions with expression above this threshold are high confidence
%                         (expression threshold)
%    tol:                 minimum flux threshold for "expressed" reactions
%                         (default 1e-8)
%    core:                cell with reaction names (strings) that are manually put in
%                         the high confidence core
%
% OUTPUTS:
%   tissueModel:          extracted model
%
% `Jerby et al. (201)). Computational reconstruction of tissue-specific
% metabolic models: application to human liver metabolism. Mol. Syst. Biol. 6, 401.`

if nargin < 5
    tol = 1e-8;
end
    % Get High expression core and medium expression core
    indH = find(expressionRxns > threshold_high);
    indM = find(expressionRxns >= threshold_medium & expressionRxns <= threshold_high);
    CH = union(model.rxns(indH),core);
    CM = model.rxns(indM);

    NC = setdiff(model.rxns,union(CH,CM));

    %MBA
    PM = model;
    removed = {};

    param.epsilon=tol;
    param.modeFlag=0;
    param.method='fastcc';

    while ~isempty(NC)
        ri = randi([1,numel(NC)],1);
        r = NC{ri};

        PM = removeRxns(PM, r);
        [fluxConsistentMetBool,fluxConsistentRxnBool] = findFluxConsistentSubset(PM,param);
        inactive=PM.rxns(fluxConsistentRxnBool==0);
        eH = intersect(inactive, CH);
        eM = intersect(inactive, CM);
        eX = setdiff(inactive,union(CH,CM));

        if numel(eH)==0 && numel(eM) < epsil*numel(eX)
            PM = removeRxns(PM, inactive);
            NC = setdiff(NC,inactive);
            removed = union(removed,inactive);
        else
            NC = setdiff(NC,r);
        end
    end

    tissueModel = removeNonUsedGenes(PM);

end
