function model = transformKEGG2Model(modelKEGG,dictionary)
%translate the metabolites from KEGG to cobra model names
%   Detailed explanation goes here
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
model = rmfield(model,model.metsAbr)
end

