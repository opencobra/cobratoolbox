function [expressionCol,  gene_used, signifCol] = selectGeneFromGPR(model, gene_names, gene_exp, parsedGPR, minSum, gene_sig)
% Map gene expression to reaction expression using the GPR rules. An AND
% will be replaced by MIN and an OR will be replaced by MAX.
%
% USAGE:
%
%   [expressionCol,  gene_used] = selectGeneFromGPR(model, gene_names, gene_exp, parsedGPR, minSum)
%   [expressionCol,  gene_used, signifCol] = selectGeneFromGPR(model, gene_names, gene_exp, parsedGPR, minSum, gene_sig)
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
%   gene_sig:       vector of significance values associated to each
%                   'gene_id' (as returned by "findUsedGeneLevels.m")
%
% OUTPUTS:
%   expressionCol:  reaction expression, corresponding to model.rxns.
%                   No gene-expression data and orphan reactions will
%                   be given a value of -1.
%   gene_used:      gene identifier, corresponding to model.rxns, from GPRs
%                   whose value (expression and/or significance) was chosen for that
%                   reaction
%
% OPTIONAL OUTPUTS:
%   signifCol:      reaction significance, corresponding to model.rxns.
%                   No gene-expression data and orphan reactions will
%                   be given a value of 0.
%
% Authors: Anne Richelle, May 2017
%          Chaitra Sarathy, Oct 2019, add significance value as optional input

if ~exist('minSum','var')
    minSum = false;
end

if ~exist('gene_sig','var') 
    geneSigFlag = 0; 
else
    geneSigFlag = 1;
end 

gene_used={};
for i=1:length(model.rxns)
	gene_used{i}='';
end

% -1 means unknown/no data
expressionCol = -1*ones(length(model.rxns),1); 
signifCol = zeros(length(model.rxns),1); 
for i = 1:length(model.rxns)
    curExprArr=parsedGPR{i};
    curSig= [];
    curExpr = [];
    gene_potential=[];
    for j=1:length(curExprArr)
        if length(curExprArr{j})>=1
            geneID = find(ismember(gene_names,curExprArr{j}));
            % if the gene is measured
            if ~isempty(geneID) 
                if minSum
                    % This is an or rule, so we sum up all options.
                    curExpr = [curExpr, sum(gene_exp(geneID))];
                    gene_potential=[gene_potential, gene_names(geneID)'];
                    if geneSigFlag ~= 0 
                        curSig = [curSig, sum(gene_sig(geneID))]; 
                    end
                else
                    % If there is data for any gene in 'AND' rule, take the minimum value
                    [minGenevalue, minID]=min(gene_exp(geneID));
                    curExpr= [curExpr, minGenevalue]; %If there is data for any gene in 'AND' rule, take the minimum value
                    gene_potential=[gene_potential, gene_names(geneID(minID))]; 
                    if geneSigFlag ~= 0
                        curSig = [curSig, gene_sig(geneID(minID))]; 
                    end
                end
            end
        end
    end
    if ~isempty(curExpr)
        if minSum
            % in case of min sum these are and clauses that are combined, so its the minimum.
            [expressionCol(i), ID_min] = min(curExpr);
            gene_used{i}=gene_potential(ID_min);
            if ~isempty(curSig)
                signifCol(i) = curSig(ID_min); 
            end
        else
            % if there is data for any gene in the 'OR' rule, take the maximum value
            [expressionCol(i), ID_max] = max(curExpr);
            gene_used{i}=gene_potential(ID_max);
            if ~isempty(curSig)
                signifCol(i) = curSig(ID_max); 
            end
        end
    end
end

end