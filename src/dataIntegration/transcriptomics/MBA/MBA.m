function tissueModel = MBA(model, medium_set, high_set, tol)
% Uses the MBA algorithm (`Jerby et al., 2010`) to extract a context
% specific model using data. MBA algorithm defines high-confidence reactions
% to ensure activity in the extracted model. Medium confidence reactions
% are only kept when a certain parsimony trade-off is met. In random order,
% the algorithm prunes other reactions and removes them if not required to
% support high- or medium- confidence reactions.
%
% USAGE:
%
%    tissueModel = MBA(model, medium_set, high_set)
%
% INPUTS:
%    model:          input model (COBRA model structure)
%    medium_set:     list of reactions with medium confidence
%    high_set:       list of reactions with high confidence
%
% OPTIONAL INPUTS:
%    tol:            minimum flux threshold for "expressed" reactions
%                    (default 1e-8)
%
% OUTPUT:
%    tissueModel:    extracted model
%
% `Jerby et al. (201)). Computational reconstruction of tissue-specific
% metabolic models: application to human liver metabolism. Mol. Syst. Biol.
% 6, 401.`
%
% .. Author: - Commented by A. Richelle, May 2017.

if nargin < 4 || isempty(tol)
    tol = 1e-8;
end

    NC = setdiff(model.rxns,union(high_set,medium_set));
    
    %MBA
    PM = model;
    removed = {};
    
    param.epsilon=tol;
    param.modeFlag=0;
    param.method='fastcc';
    
    while ~isempty(NC)
        ri = randi([1,numel(NC)],1);
        r = NC{ri};       
            
        PM_temp = removeRxns(PM, r);
        sol = optimizeCbModel(PM_temp);
        if sol.stat ~= 1
            inactive = PM_temp.rxns;
        else
            [~,fluxConsistentRxnBool] = findFluxConsistentSubset(PM_temp,param);
            inactive=[PM_temp.rxns(fluxConsistentRxnBool==0);r];
        end  
        eH = intersect(inactive, high_set);
        eM = intersect(inactive, medium_set);
        eX = setdiff(inactive,union(high_set,medium_set));
        
        epsil=0.5;
        if numel(eH)==0 && numel(eM) < epsil*numel(eX)
            PM = removeRxns(PM, inactive);
            NC = setdiff(NC,inactive);
            removed = union(removed,inactive);
        else
            NC = setdiff(NC,r);
        end
    end

    tissueModel = removeUnusedGenes(PM);

end
