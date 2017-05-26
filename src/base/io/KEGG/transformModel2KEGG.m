function modelKEGG = transformModel2KEGG(model,Dictionary)
% Replaces `model.mets` with `model.metKEGGID`. If no KEGGID
% defined, the empty cell will be replaced with metabolite abreviation.
%
% USAGE:
%
%    modelKEGG = transformModel2KEGG(model, Dictionary)
%
% INPUTS:
%    model:         COBRA model structure
%    Dictionary:    consists of:
%
%                     * CompAbr = Dictionary(:, 1): List of compounds abreviation (non-compartelized)
%                     * KEGGID = Dictionary(:, 2): List of KEGGIDs for compounds in `CompAbr`
%
% OUTPUT:
%    modelKEGG:     KEGG model structure
%
% .. Author: - 11-09-07 IT

if (nargin == 3)
    modelKEGG = mapKEGGID2Model(model, Dictionary);
elseif(nargin == 2)
    warning('missing data');
elseif(nargin ==1)
    modelKEGG = model;
end

modelKEGG.metsAbr = modelKEGG.mets;
modelKEGG.mets = modelKEGG.metKEGGID;

for i = 1: length(modelKEGG.metsAbr)
    if (isempty(modelKEGG.mets{i}))
        modelKEGG.mets(i)=modelKEGG.metsAbr(i);
    end
end
