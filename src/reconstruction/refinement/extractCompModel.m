function compModel = extractCompModel(model, compSymbol, intOnlyFlag, updateGenes)
% Creates model for a cellular compartment
%
% USAGE:
%
%    compModel = extractCompModel(model, compSymbol, intOnlyFlag)
%
% INPUTS:
%    model:          COBRA model structure
%    compSymbol:     Compartment symbol
%
% OPTIONAL INPUT:
%    intOnlyFlag:    Include only non-transport reactions (Default = true)
%    updateGenes:    Update the GPR rules removing all unassociated genes.
%                    This can take some time on larger models.(default
%                    false)
%
% OUTPUT:
%    compModel:      COBRA model for a cellular compartment
%
% .. Author: - Markus Herrgard 3/1/06

if (nargin < 3)
    intOnlyFlag = true;
end

if ~exist('updateGenes','var')
    updateGenes = false;
end

[baseMetNames,compSymbols] = parseMetNames(model.mets);

selMets = strcmp(compSymbols,compSymbol);

if (sum(selMets) == 0)
    warning('Compartment symbol not found');
    compModel = [];
    return;
end

if (intOnlyFlag)

    % Include only non-transport reactions
    selRxns = (sum(model.S(selMets,:) ~= 0)' == sum(model.S ~= 0)') & any(model.S(selMets,:) ~= 0,1)';
    rxnList = model.rxns(selRxns);

else

    % Include transporters
    selRxns = any(model.S(selMets,:) ~= 0,1)';
    rxnList = model.rxns(selRxns);

end

% Extract subnetwork model
compModel = extractSubNetwork(model,rxnList,{},updateGenes);

if (isfield(compModel,'description'))
    compModel.description = [compModel.description ' Compartment:' compSymbol'];
end
