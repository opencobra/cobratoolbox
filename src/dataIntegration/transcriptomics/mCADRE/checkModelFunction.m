function requiredMetsStatus= checkModelFunction(model, requiredMets)
%Check that the model is able to produce the list of metabolites defined in
%requiredMets
%
%INPUTS
%   model                   model structure
%   requiredMets            cell array with the list of metabolites that
%                           the model need to be able to produce
%
%OUTPUTS
%   requiredMetsStatus      0 : test fail 
%                           1 : test succeed 
%
%This script is an adapted version of the implementation from
%https://github.com/jaeddy/mcadre. Adapted and commented by A. Richelle,
%May 2017.

    
    %If requiredMets is empty, skip the step and always say the test is passed
    if isempty(requiredMets)
        requiredMetsStatus = true;
        warning('No metabolites defined to check the model function')
    else
        % Add demand reactions for required metabolites
        % function evalc used to remove display of reaction added
        [~, model, requiredRxns] = evalc(['addDemandReaction(model,requiredMets);']);
        
        % Check that the demand reaction can carry fluxes (default value of
        % flux active - 1e-8?
        inactiveRequired = checkRxnFlux(model, requiredRxns);
        requiredMetsStatus = ~numel(inactiveRequired);
    end
 
end
