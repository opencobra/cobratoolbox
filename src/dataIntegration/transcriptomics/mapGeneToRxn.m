function expressionRxns = mapGeneToRxn(model, gene_id, gene_expr, parsedGPR, corrRxn)
%Map gene expression to reaction expression using the GPR rules. An AND
%will be replaced by MIN and an OR will be replaced by MAX.
%
%INPUTS
%
%   model               COBRA model structure
%
%   gene_id             vector of gene identifiers present in the model
%                       that are associated with expression data
%                       (as returned by "findUsedGeneLevels.m")
%
%   gene_expr           vector of expression values associated to each
%                       gened_id (as returned by "findUsedGeneLevels.m")
%
%   parsedGPR           cell array describing the possible combination of gene needed for each
%                       reactions in the model without using "AND" and "OR" logical rule
%                       (as returned by "extractGPRS.m")
%
%   corrRxn             cell array containg the reaction names associated
%                       to parsedGPR (as returned by "extractGPRS.m")
%
%OUTPUTS
%
%   expressionRxns      expression data, corresponding to model.rxns, that
%                       will be used by the extraction method algorithm
%
% S. Opdam & A. Richelle, May 2017



    expressionRxn = -1*ones(length(model.rxns),1); %-1 means unknown/no data
    
    for i = 1:length(corrRxn)
        %find index of current reaction in model reaction array
        rxnInd = find(ismember(model.rxns,corrRxn{i})); 
        %all genes that play a role in current reaction
        genesInRxn = parsedGPR(i,:); 
        curExprArr = [];
        
        for j = 1:length(genesInRxn)
            if ~isempty(genesInRxn{j})
                %find index of gene in array of genes associated to
                %expression data
                geneInd = find(ismember(gene_id,genesInRxn{j})); 
                if ~isempty(geneInd)
                    curExprArr = [curExprArr, gene_expr(geneInd)];
                end
            end
        end
        
        %If there is multiple data related to an "AND" rule, take the minimum
        %value data
        if ~isempty(curExprArr) 
            curExpr = min(curExprArr);
            %if an "OR" rule exist ( if there is already data associated
            %with this reaction), keep the maximum value
            if curExpr > expressionRxn(rxnInd)
                expressionRxns(rxnInd) = curExpr;
            end
        end
    end
    
end