function listIsozymes = getListOfUniqueIsozymes(model)
% Get a preliminary list of unique isozymes for a given model
%
% This function gets a preliminary list of unique isozymes for a given model
% or reconstruction by inspecting the gene-protein-reaction rules.
%
% USAGE:
%
%    listIsozymes = getListOfUniqueIsozymes(model)
%
% INPUT:
%    model:     Model or reconstruction structure, with fields:
%
%                 * .genes - gene identifiers
%
% OUTPUT:
%    listIsozymes:    Preliminary list of unique isozymes for the model


grR = {};
for i = 1 : length(model.genes)
    [Rxns, grRules] = getRxnsFromGene(model,model.genes{i});
    grRules = regexprep(grRules,'\.\d','');
    grRules = unique(grRules);
    
    for k = 1 : length(grRules)
        if  contains(grRules{k},'or')% only isozymes
            if ~contains(grRules{k},'and')% only isozymes
                grRules{k} = regexprep(grRules{k},'\(','');
                grRules{k} = regexprep(grRules{k},'\)','');
            end
            x = split(grRules{k},' or ');
            y = unique(x);
            y = sort(y);
            
            if length(y)>1
                for m = 1 : length(y)
                    if m == 1
                        z = y{m};
                    else
                        z = [z ' or ' y{m}];
                    end
                end
            end
            grR = [grR;z];
        end
    end
end
grR = unique(grR);
listIsozymes = grR;