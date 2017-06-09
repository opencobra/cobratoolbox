function expressionCol = mapGeneToRxn(model, gene_names, gene_exp, parsedGPR, corrRxn)
    % Map gene expression to reaction expression using the GPR rules. An AND
    % will be replaced by MIN and an OR will be replaced by MAX.
    % Input:
    %   model - COBRA model struct
    %   gene_names - gene identifiers corresponding to gene_exp. Names must
    %                be in the same format as model.genes (column vector)
    %                (as returned by "findUsedGeneLevels.m")
    %   gene_exp - gene FPKM/expression values, corresponding to names (column vector)
    %              (as returned by "findUsedGeneLevels.m")
    %   parsedGPR - GPR matrix as returned by "extractGPRS.m"
    %   corrRxn - reaction cell as returned by "extractGPRS.m"
    % Output:
    %   expressionCol - reaction expression, corresponding to model.rxns.
    %                   No gene-expression data and orphan reactions will
    %                   be given a value of -1.

    expressionCol = -1*ones(length(model.rxns),1); %-1 means unknown/no data
    for ri = 1:length(corrRxn)
        rxnInd = find(ismember(model.rxns,corrRxn{ri})); %index of current reaction in model reaction array
        genesInRxn = parsedGPR(ri,:); %all genes that play a role in current reaction
        curExprArr = []; %Expression of all genes in the reaction
        for gi = 1:length(genesInRxn)
            if ~isempty(genesInRxn{gi}) %only do this when it is actually a gene, not a ''
                geneInd = find(ismember(gene_names,genesInRxn{gi})); %find index of gene in array of measured genes
                if ~isempty(geneInd) %if the gene is measured
                    curExprArr = [curExprArr, gene_exp(geneInd)]; %#ok<AGROW>
                end
            end
        end
        if ~isempty(curExprArr) %If there is data for any gene in the AND (or for a single gene only)
            curExpr = min(curExprArr);
            if curExpr > expressionCol(rxnInd) %An OR is found which has higher expression
                expressionCol(rxnInd) = curExpr;
            end
        end
    end   
end