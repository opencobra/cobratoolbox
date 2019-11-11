function [expressionRxns, parsedGPR, gene_used, signifRxns] = mapExpressionToReactions(model, expressionData, minSum)                                          
% Determines the expression data associated to each reaction present in
% the model 
%
% USAGE:
%
%    [expressionRxns parsedGPR, gene_used] = mapExpressionToReactions(model, expressionData) 
%    [expressionRxns, parsedGPR, gene_used, signifRxns] =  mapExpressionToReactions(model, expressionData, minSum)
%
% INPUTS:
%	model                   model strusture
%	expressionData          mRNA expression data structure
%       .gene               	cell array containing GeneIDs in the same
%                               format as model.genes
%       .value                  Vector containing corresponding expression
%                               value (FPKM/RPKM)
%       .sig:               [optional field] Vector containing significance values of
%                           expression corresponding to expression values in
%                           expressionData.value (ex. p-values)
%
% OPTIONAL INPUT:
%    minSum:         instead of using min and max, use min for AND and Sum
%                    for OR (default: false, i.e. use min)
%
% OUTPUTS:
%   expressionRxns:         reaction expression, corresponding to model.rxns.
%   parsedGPR:              cell matrix containing parsed GPR rule
%   gene_used:              gene identifier, corresponding to model.rxns, from GPRs
%                           whose value (expression and/or significance) was chosen for that
%                           reaction
%
% OPTIONAL OUTPUTS:
%   signifRxns:              significance of reaction expression, corresponding to model.rxns.

%
% Authors:
%       - Anne Richelle, May 2017 - integration of new extraction methods 
%       - Chaitra Sarathy, Oct 2019, add significance value as optional input

if ~exist('minSum','var')
    minSum = false;
end

if isfield(expressionData, 'sig') 
    exprSigFlag = 1; 
else
    exprSigFlag = 0;
end 

% Extracting GPR data from model
parsedGPR = GPRparser(model,minSum);


if exprSigFlag == 0
    % Find wich genes in expression data are used in the model
    [gene_id, gene_expr] = findUsedGenesLevels(model,expressionData);

    % Link the gene to the model reactions
    [expressionRxns,  gene_used] = selectGeneFromGPR(model, gene_id, gene_expr, parsedGPR, minSum);
    
else
    
    [gene_id, gene_expr, gene_sig] = findUsedGenesLevels(model, expressionData);
    [expressionRxns,  gene_used, signifRxns] = selectGeneFromGPR(model, gene_id, gene_expr, parsedGPR, minSum, gene_sig);
    
end
