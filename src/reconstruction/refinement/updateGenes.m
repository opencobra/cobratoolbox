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
% Note - the gene order will be changed to sorted. You should probably use
%        buildRxnGeneMat to make sure the order matches in all relevant
%        fields.
%
% .. Authors:
%       - written by Diana El Assal 30/06/2017
%       - fixed by Uri David Akavia 16/07/2017
%       - Only recreate model.genes if it does not exist by Thomas Pfau Sept 2017

modelNew = model;

if ~isfield(model.genes) %This is VERY odd and should not happen, but lets see    
    grRules = model.grRules;
    grRules = grRules(~cellfun(@isempty,grRules));
    genes = regexprep(grRules, {'and', 'AND', 'or', 'OR', '(', ')'}, '');
    genes = splitString(genes, ' ');
    genes = [genes{:}]';
    genes = unique(genes(cellfun('isclass', genes, 'char')));    
    %Now, we created the genes field, so lets build the rules field as
    %well.
    modelNew.genes = genes(~cellfun('isempty', genes));  % Not sure this is necessary anymore, but it won't hurt.
    modelNew = generateRules(modelNew);   
end

%Now, remove unused genes.
modelNew = removeUnusedGenes(modelNew);

%Finally, check for duplicate genes. This is actually tricky. because we
%might need to merge stuff.
[genes,ia,ic] = unique(model.genes);

if numel(genes) < numel(model.genes)
    checkedgene = 1;
    while numel(genes) < numel(model.genes)
        %We only check from where we know that we are done (avoiding double
        %checks).
        for checkedgene = checkedgene:numel(genes)
            dupidx = find(ic == checkedgene);
            if numel(dupidx) > 1
                model = mergeModelFieldPositions(model,'genes',dupidx);
                [genes,ia,ic] = unique(model.genes);
                break
            end
        end
    end
end

%And now, reorder the gene field alphabetically (again updating all
%dependent fields).
[~,sortedOrder] = sort(modelNew.genes);
modelNew = updateFieldOrderForType(model,'gene',sortedOrder);

