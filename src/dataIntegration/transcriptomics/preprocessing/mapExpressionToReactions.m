function [expressionRxns, parsedGPR, gene_used] = mapExpressionToReactions(model, expressionData, minSum)                                          
% Determines the expression data associated to each reaction present in
% the model 
%
% USAGE:
%    [expressionRxns parsedGPR] = mapExpressionToReactions(model, expressionData) 
%
% INPUTS:
%	model                   model strusture
%	expressionData          mRNA expression data structure
%       .gene               	cell array containing GeneIDs in the same
%                               format as model.genes
%       .value                  Vector containing corresponding expression
%                               value (FPKM/RPKM)
% OPTIONAL INPUT:
%   minSum:         instead of using min and max, use min for AND and Sum
%                   for OR (default: false, i.e. use min)
% OUTPUTS:
%   expressionRxns:         reaction expression, corresponding to model.rxns.
%   parsedGPR:              cell matrix containing parsed GPR rule
%
% .. Authors:
%       - Anne Richelle, May 2017 - integration of new extraction methods 

if ~exist('minSum','var')
    minSum = false;
end

parsedGPR = GPRparser(model,minSum);% Extracting GPR data from model
% Find wich genes in expression data are used in the model
[gene_id, gene_expr] = findUsedGenesLevels(model,expressionData);
% Link the gene to the model reactions
[expressionRxns, gene_used] = selectGeneFromGPR(model, gene_id, gene_expr, parsedGPR, minSum);