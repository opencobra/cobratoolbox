function expressionRxns = selectGeneFromGPR_efmviz(model, gene_names, gene_exp, gene_sig, parsedGPR, minSum)
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
%                   (as returned by "findUsedGeneLevels_efmviz.m")
%   gene_exp:       gene FPKM/expression values, corresponding to names (column vector)
%                   (as returned by "findUsedGeneLevels.m")
%   parsedGPR:      GPR matrix as returned by "GPRparser.m"
%
% OPTIONAL INPUTS:
%   minSum:         instead of using min and max, use min for AND and Sum
%                   for OR
%
% OUTPUTS:
%   expressionRxns:  reaction expression, corresponding to model.rxns.
%                   No gene-expression data and orphan reactions will
%                   be given a value of -1.
%          .rxnSig - significance for each rxn associated with each
%                     reaction
%           .rxnExp - expression for each rxn associated with each
%                     reaction
% ORIGINAL AUTHOR: Anne Richelle, May 2017
% Adapted by Chaitra Sarathy to use significance levels along with
% expression value 
% Last modified: Chaitra Sarathy, 13 Aug 2019


if ~exist('minSum','var')
    minSum = false;
end
% -1 means unknown/no data
expressionRxns.rxnSig = zeros(length(model.rxns),1); 
expressionRxns.rxnExp = -1*ones(length(model.rxns),1); 
for i = 1:length(model.rxns)
    curSigArr=parsedGPR{i};
    curSig= [];
    curExp = [];
    for j=1:length(curSigArr)
        if length(curSigArr{j})>=1
            geneID = find(ismember(gene_names,curSigArr{j}));
            % if the gene is measured
            if ~isempty(geneID) 
                if minSum
                    % This is an or rule, so we sum up all options.
                    curSig = [curSig, sum(gene_sig(geneID))]; 
                    curExp = [curExp, sum(gene_exp(geneID))];
                else
                    % If there is data for any gene in 'AND' rule, take the minimum value
                    %curGeneID = [curGeneID, geneID];
                    curSig = [curSig, min(gene_sig(geneID))];
                    curExp = [curExp, min(gene_exp(geneID))];
                end
            end
        end
    end
    if ~isempty(curSig)
        if minSum
            % in case of min sum these are and clauses that are combined, so its the minimum.
            expressionRxns.rxnSig(i) = min(curSig); 
            expressionRxns.rxnExp(i) = min(curExp);
        else
            % if there is data for any gene in the 'OR' rule, take the maximum value
            expressionRxns.rxnSig(i) = max(curSig);
            expressionRxns.rxnExp(i) = max(curExp);
        end
    end
end

end