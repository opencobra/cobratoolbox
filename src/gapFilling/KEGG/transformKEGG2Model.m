function model = transformKEGG2Model(modelKEGG,dictionary)
%translate the metabolites from KEGG to cobra model names
%   Detailed explanation goes here
if (nargin == 2)
    model = mapMetName2KEGGID(modelKEGG,dictionary);
elseif(nargin ==1)
    model = modelKEGG;
end

model.mets = model.metsAbr;
%modelKEGG.mets = modelKEGG.KEGGID;

for i = 1: length(model.mets)
    if (isempty(model.mets{i}))
        model.mets(i)=model.KEGGID(i);
    end
end

end

