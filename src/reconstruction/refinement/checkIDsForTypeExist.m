function [bool, existing] = checkIDsForTypeExist(model, ids, basefield)
% Check whether the given IDs exist for the given type of base field. Base
% fields include rxns, mets, genes, comps, proteins, ctrs, evars. ctrs/mets
% as well as rxns/evars will be considered as a combined field.
%
% USAGE:
%
%    [bool, existing] = checkIDsForTypeExist(model, ids, basefield)
%
% INPUTS:
%    model:               model structure with fields:
%
%                            * .rxns - `n x 1` cell array of reaction identifiers
%                            * .evars - (if present) `evars x 1` cell array of extra variable identifiers, combined with `.rxns` when `basefield` is `rxns` or `evars`
%                            * .mets - `m x 1` cell array of metabolite identifiers
%                            * .ctrs - (if present) `ctrs x 1` cell array of constraint identifiers, combined with `.mets` when `basefield` is `mets` or `ctrs`
%    ids:                 cell array of identifiers
%    basefield:           Any base field defined.
%
%
% OUTPUT:
%    bool:                Boolean vector true if any of the IDs exist.
%    existing:            Unique set of pre-existing IDs for this base field.
%
% EXAMPLE:
%    [bool,existing] = checkIDsForTypeExist(model,'atp[c]','mets')

if isfield(model,basefield)
    existingIDs = model.(basefield);
else
    bool = false;
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
bool = any(presence);
if nargout == 2
    existing = unique(existingIDs(presence));
end