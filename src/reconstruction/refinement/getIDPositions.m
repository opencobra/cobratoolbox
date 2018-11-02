function [pos,pres] = getIDPositions(model,ids,basefield)
% Get the positions of the IDs for the given basefield.
% This function will currently only work for rxns and mets and also checks the
% associated ctrs (for mets) and evars (for rxns) fields for the given IDs.
% elements from evars / ctrs will have positions nRxns/nMets + position
% respectively.
%
% USAGE:
%
%    [pos,pres] = getIDPositions(model,ids,basefield)
%
% INPUTS:
%    model:               model structure
%    ids:                 cell array of reaction names
%    basefield:           Either 'rxns', or 'mets'
%
%
% OUTPUT:
%    pos:                 The positions of the given ids in the
%                         [rxns;evars] or [mets;ctrs] vectors for rxns and
%                         mets , respectively.
       
if strcmp(basefield,'rxns')
    if isfield(model, 'evars')
        searchvector = [model.rxns ; model.evars];
    else
        searchvector = model.rxns;
    end
elseif strcmp(basefield,'mets')
    if isfield(model, 'ctrs')
        searchvector = [model.mets ; model.ctrs];
    else
        searchvector = model.mets;
    end
elseif isfield(model,basefield) && iscellstr(model.(basefield))
    searchvector = model.(basefield);
else    
    error('Basefield has to be a  field representing a cell array of strings in the model');
end
   
[pres,pos] = ismember(ids,searchvector);