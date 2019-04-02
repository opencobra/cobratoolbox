function model = removeCompartments(model, compIDs, keepTransportReactions)
% Remove the specified compartments (and all metabolites in this
% compartment) from the model.
%
% USAGE:
%
%    model = removeCompartment(model, compIDs, keepTransportReactions)
%
% INPUTS:
%    model:             COBRA model structure
%    compIDs:           List of identifier(s) of the compartments to remove
%
% OPTIONAL INPUT:
%    keepTransportReactions:    Whether to keep reactions which transport
%                               metabolites into the compartment or not.
%                               Those reactions will become exchange
%                               reactions!
%                               (default: true)
%
% OUTPUT:
%    model:             COBRA model with removed compartments
%
% .. Authors:
%       - Thomas Pfau 2018

if ~exist('keepTransportReactions','var')
    keepTransportReactions = true;
end

metsToRemove = ismember(model.metComps,compIDs);
if keepTransportReactions
    model = removeMetabolites(model,model.mets(metsToRemove));
else
    allReactions = findRxnsFromMets(model,model.mets(metsToRemove));
    model = removeRxns(model,allReactions);
end

compsToDel = ismember(model.comps,compIDs);
model = removeFieldEntriesForType(model,compsToDel,'comps',numel(model.comps));
