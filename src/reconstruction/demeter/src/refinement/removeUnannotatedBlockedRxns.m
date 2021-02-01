function model = removeUnannotatedBlockedRxns(model, biomassRxn)
% Performs a flux variability analysis on an unlimited reconstruction and
% removes any reactions that do not have gene-protein-reaction rules and
% cannot carry flux.
%
% INPUT
% model             COBRA model structure
% biomassRxn        Biomass reaction abbreviation
%
% OUTPUT
% model             COBRA model structure
%
% Stefania Magnusdottir, Nov 2017

if ~any(ismember(model.rxns, biomassRxn))
    error(['Reaction ', biomassRxn, ' not found in model.'])
end

% set unlimited constraints
model.lb(model.lb > 0) = 0;
model.ub(model.ub < 0) = 0;
model.lb(model.lb < 0) = -1000;
model.ub(model.ub > 0) = 1000;

% flux variability analysis
if ~isempty(ver('distcomp'))
    [minFlux, maxFlux, ~, ~] = fastFVA(model, 0, 'max', 'ibm_cplex', ...
        model.rxns, 'S');
else
    [minFlux, maxFlux] = fluxVariability(model, 0, 'max', model.rxns);
end
FBA=optimizeCbModel(model,'max');
if FBA.f > 1e-6
    % find blocked reactions without GPRs
    unannBlocked = model.rxns(abs(minFlux) < 1e-6 & abs(maxFlux) < 1e-6 & ...
                              cellfun(@isempty, model.rules));

    % remove blocked unannotated reactions
    for i = 1:length(unannBlocked)
        model = removeRxns(model, unannBlocked{i});
        fprintf('Reaction %s removed from reconstruction.', unannBlocked{i});
    end
else
    warning(['Model cannot carry flux through the reaction ', biomassRxn, ...
             '. Blocked reactions not removed.'])
end

end
