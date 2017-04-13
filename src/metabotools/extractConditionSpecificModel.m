function [modelPruned] = extractConditionSpecificModel(model,theshold)
% The function prunes a subnetwork based on a user-defined threshold. The subnetwork does not contain blocked reactions. Please note that Recon has blocked reactions which will always be removed. Thus, not all reactions are removed as a consequence of the data integration.
% Depends on fastFVA, fluxVariability analysis
%
% USAGE:
%
%    [modelPruned] = extractConditionSpecificModel(model, theshold)
%
% INPUTS:
%    model:           Global metabolic model (Recon) - constrained
%    theshold:        Fluxes below the threshold will be considered zero and respective reactions as blocked, e.g., 10e-6. 
%
% OUTPUTS:
%    modelPruned:     submodel without blocked reactions
%
% .. Author: - Maike K. Aurich 13/02/15

[minFlux,maxFlux] = fluxVariability(model,0);
%[minFluxMODEL,maxFluxMODEL] = fastFVA(model,0);
Flux = [minFlux maxFlux];


for i = 1 : length(Flux);
    x = length (find (abs(Flux(i,:))<=theshold))==2;
    i;
    Blockedrxns(i,1) = x;
end
Blocked= model.rxns(Blockedrxns);
Blocked(:,2)= model.subSystems(Blockedrxns);
noBlockedrxns(1,2) =length(find(Blockedrxns));

modelPruned = removeRxns(model,Blocked(:,1));

end

