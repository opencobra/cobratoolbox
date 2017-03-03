function metID = findMetIDs(model,metList)
%findMetIDs Find metabolite numbers in a model
%
% metID = findMetIds(model,metList)
%
%INPUTS
% model         COBRA model structure
% metList       List of metabolites
%
%OUTPUT
% metID         List of metabolite IDs corresponding to metList
%
% Jan Schellenberger 8/15/08

if (iscell(metList))
    [tmp,metID] = ismember(metList,model.mets);    
else
    metID = find(strcmp(model.mets,metList));
    if (isempty(metID))
        metID = 0;
    end
    if (length(metID) > 1)
        metID = metID(1);
    end
end