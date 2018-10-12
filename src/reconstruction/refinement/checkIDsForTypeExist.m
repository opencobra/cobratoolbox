function [tf,existing] = checkIDsForTypeExist(model,ids,basefield)
% Check whether the given IDs exist for the given type of base field. Base
% fields include rxns, mets, genes, comps, proteins, ctrs, evars. ctrs/mets
% as well as rxns/evars will be considered as a combined field. 
%
% USAGE:
%
%    [tf,existing] = checkIDsForTypeExist(model,ids,basefield)
%
% INPUTS:
%    model:               model structure
%    ids:                 cell array of reaction names
%    basefield:           Any base field defined.
%
%
% OUTPUT:
%    tf:                  Whether any of the IDs exists.
%    existing:            the already existing IDs for this base field.
%
%

if isfield(model,basefield)
    existingIDs = model.(basefield);
else
    tf = false;
    return;
end

% if its rxns/evars we include the other if present, assuming rxns is always
% present
if strcmp(basefield,'evars') || strcmp(basefield,'rxns')
    if isfield(model, 'evars')
        existingIDs = [model.rxns ; model.evars];
    else
        existingIDs = model.rxns;
    end
end

% if its mets/ctrswe include the other if present, assuming mets is always
% present
if strcmp(basefield,'mets') || strcmp(basefield,'ctrs')
    if isfield(model, 'ctrs')
        existingIDs = [model.mets ; model.ctrs];
    else
        existingIDs = model.mets;
    end
end

presence = ismember(existingIDs,ids);
tf = any(presence);
if nargout == 2
    existing = unique(existingIDs(presence));
end