function [gene_id, gene_expr] = findUsedGenesLevels(model,expressionData)
%Returns vectors of gene identifiers and corresponding gene expression
%levels for each gene present in the model (model.gene).
%
%INPUTS
%
%   model               input model (COBRA model structure)
%
%   expressionData      mRNA expression data structure
%       firstColumn     Vector containing GeneIDs
%       scondColumn     Vector containing corresponding expression value (FPKM)
%
%OUTPUTS
%
%   gene_id             vector of gene identifiers present in the model
%                       that are associated with expression data
%
%   gene_expr           vector of expression values associated to each
%                       gened_id
%
% S. Opdam & A. Richelle May 2017


    genes_ID = zeros(length(model.genes),1);
    for i = 1:length(model.genes)
        genes_ID(i) = str2num(model.genes{i});
    end
    
    cnts = -1*ones(length(genes_ID),2);
    cnts(:,1) = genes_ID;

    for i = 1:length(genes_ID)
        cur_ID = genes_ID(i);
        flag = 0;
        for j = 1:length(expressionData)
            if expressionData(j,1) == cur_ID
                if flag == 1
                    disp(['Double for ',num2str(cur_ID)])
                    cnts(i,2) = cnts(i,2) + expressionData(j,2);
                end
                if flag == 0
                    flag = 1;
                    cnts(i,2) = expressionData(j,2);
                end
            end
        end
    end

    data_inds = find(cnts(:,2)~= -1);
    gene_expr = cnts(data_inds,2);
    gene_id = model.genes(data_inds);
end