function model = keepCompartment(model, compartments)
% This function removes reactions in all compartments except those
% specified by the cell array "compartments"
%
% USAGE:
%
%    model = keepCompartment(model, compartments)
%
% INPUTS:
%    model:           COBRA model structure
%    compartments:    cell array of strings (e.g., to discard all
%                     reactions except those in the mitochondria and
%                     cytosol, compartments = {'[m]', '[c]'};
%
% OUTPUT:
%    model:           COBRA model with reactions in the specified compartmetns
%
% .. Author: - Nathan Lewis, June 8, 2008


compartments = regexprep(compartments, '\[([^\]]+\])\]','$1'); % compartments is a cell array list of compartments to keep (e.g. {'[e]','[c]','[m]'})
relMets = ismember(model.metComps,compartments);
reacsToKeep = findRxnsFromMets(model,model.mets(relMets),'exclusive', true);
if numel(reacsToKeep) <= numel(model.rxns)
    model = removeRxns(model,setdiff(model.rxns,reacsToKeep));
else
    fprintf('No Compartments Removed\n')
end

