function modelKEGG = transformModel2KEGG(model,Dictionary)
%transformModel2KEGG replaces model.mets with model.KEGGID; if no KEGGID
% defined, the empty cell will be replaced with metabolite abreviation
%
%   modelKEGG = transformModel2KEGG(model,CompAbr, KEGGID)
%
% model      model structure
% CompAbr    List of compounds abreviation (non-compartelized)
% KEGGID     List of KEGGIDs for compounds in CompAbr
%
% 11-09-07 IT

if (nargin == 3)
    modelKEGG = mapKEGGID2Model(model, Dictionary);
elseif(nargin == 2)
    warning('missing data');
elseif(nargin ==1)
    modelKEGG = model;
end

modelKEGG.metsAbr = modelKEGG.mets;
modelKEGG.mets = modelKEGG.KEGGID;

for i = 1: length(modelKEGG.metsAbr)
    if (isempty(modelKEGG.mets{i}))
        modelKEGG.mets(i)=modelKEGG.metsAbr(i);
    end
end

