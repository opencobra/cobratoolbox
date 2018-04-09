function [modelNew] = updateGenes(model)
% Update the model genes field (if it does not exist, generate it from the
% grRules field, if it exists, remove Unused genes and  remove duplicate genes.
%
% USAGE:
%
%    [modelNew] = updateGenes(model);
%
% INPUT:
%    model:              COBRA model structure
%
% OUTPUT:
%    modelNew:           COBRA model structure with corrected genes
%
% NOTE: 
%        The gene order will be changed to sorted. You should probably use
%        buildRxnGeneMat to make sure the order matches in all relevant
%        fields.
%
% .. Authors:
%       - written by Diana El Assal 30/06/2017
%       - fixed by Uri David Akavia 16/07/2017
%       - Only recreate model.genes if it does not exist by Thomas Pfau Sept 2017

modelNew = model;

%Now, remove unused genes.
modelNew = removeUnusedGenes(modelNew);

%Finally, check for duplicate genes. This is actually tricky. because we
%might need to merge stuff.
[genes,ia,ic] = unique(modelNew.genes);

if numel(genes) < numel(modelNew.genes)
    checkedgene = 1;
    while numel(genes) < numel(modelNew.genes)
        %We only check from where we know that we are done (avoiding double
        %checks).
        for checkedgene = checkedgene:numel(genes)
            dupidx = find(ic == checkedgene);
            if numel(dupidx) > 1
                modelNew = mergeModelFieldPositions(modelNew,'genes',dupidx);
                [genes,ia,ic] = unique(model.genes);
                break
            end
        end
    end
end

%And now, reorder the gene field alphabetically (again updating all
%dependent fields).
[~,sortedOrder] = sort(modelNew.genes);
modelNew = updateFieldOrderForType(modelNew,'genes',sortedOrder);

