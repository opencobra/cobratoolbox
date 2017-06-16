function geneID = findGeneIDs(model, geneList)
% Finds gene numbers in a model
%
% USAGE:
%
%    geneID = findGeneIDs(model, geneList)
%
% INPUTS:
%    model:       COBRA model structure
%    geneList:    List of genes
%
% OUTPUT:
%    geneID:      List of gene IDs corresponding to `geneList`
%
% .. Author: - Jeff Orth 7/16/09

if (iscell(geneList))
    [tmp,geneID] = ismember(geneList,model.genes);
else
    geneID = find(strcmp(model.genes,geneList));
    if (isempty(geneID))
        geneID = 0;
    end
    if (length(geneID) > 1)
        geneID = geneID(1);
    end
end
