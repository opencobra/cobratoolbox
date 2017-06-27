function expressionCol = selectGeneFromGPR(model, gene_names, gene_exp, parsedGPR, minSum)
% Map gene expression to reaction expression using the GPR rules. An AND
% will be replaced by MIN and an OR will be replaced by MAX.
%
% USAGE:
%   expressionCol = selectGeneFromGPR(model, gene_names, gene_exp, parsedGPR, minMax)
%
% INPUTS:
%   model:          COBRA model struct
%   gene_names:     gene identifiers corresponding to gene_exp. Names must
%                   be in the same format as model.genes (column vector)
%                   (as returned by "findUsedGeneLevels.m")
%   gene_exp:       gene FPKM/expression values, corresponding to names (column vector)
%                   (as returned by "findUsedGeneLevels.m")
%   parsedGPR:      GPR matrix as returned by "GPRparser.m"
%
% OPTIONAL INPUTS:
%   minSum:         instead of using min and max, use min for AND and Sum
%                   for OR
%
% OUTPUTS:
%   expressionCol:  reaction expression, corresponding to model.rxns.
%                   No gene-expression data and orphan reactions will
%                   be given a value of -1.
%
% AUTHOR: Anne Richelle, May 2017


if ~exist('minSum','var')
    minSum = false;
end

expressionCol = -1*ones(length(model.rxns),1); %-1 means unknown/no data
for i = 1:length(model.rxns)
    curExprArr=parsedGPR{i};
    curExpr= [];
    for j=1:length(curExprArr)
        if length(curExprArr{j})>=1
            geneID = find(ismember(gene_names,curExprArr{j}));
            if ~isempty(geneID) %if the gene is measured
                curExpr= [curExpr, min(gene_exp(geneID))]; %If there is data for any gene in 'AND' rule, take the minimum value
            end
        end
    end
    if ~isempty(curExpr)
        if minSum
            expressionCol(i)=sum(curExpr);
        else
            expressionCol(i)=max(curExpr);%If there is data for any gene in the 'OR' rule, take the maximum value
        end
    end
end

end