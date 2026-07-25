function model = transformKEGG2Model(modelKEGG, dictionary)
% Translates the metabolites from KEGG to cobra model names.
%
% USAGE:
%
%    model = transformKEGG2Model(modelKEGG, dictionary)
%
% INPUTS:
%    modelKEGG:     KEGG model structure
%
% OPTIONAL INPUTS:
%    dictionary:    consists of:
%
%                     * CompAbr = dictionary(:, 1): List of compounds abreviation (non-compartelized)
%                     * KEGGID = dictionary(:, 2): List of KEGGIDs for compounds in `CompAbr`
%
% OUTPUT:
%    model:         COBRA model structure

if (nargin == 2)
    model = mapMetName2KEGGID(modelKEGG,dictionary);
elseif(nargin ==1)
    model = modelKEGG;
end

model.mets = model.metsAbr;

for i = 1: length(model.mets)
    if (isempty(model.mets{i}))
        model.mets(i)=model.metKEGGID(i);
    end
end
%removing temporary field
model = rmfield(model,'metsAbr');
end
