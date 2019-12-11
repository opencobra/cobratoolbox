function [expressionRxns, parsedGPR] = mapExpressionToReactions_efmviz(model, expressionData, minSum)                                          
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
%       .sig                    Vector containing corresponding significance values
% OPTIONAL INPUT:
%   minSum:         instead of using min and max, use min for AND and Sum
%                   for OR (default: false, i.e. use min)
% OUTPUTS:
%   expressionRxns:         structure describing reaction expression and significance, corresponding to model.rxns.
%   parsedGPR:              cell matrix containing parsed GPR rule
%
% Original Authors:
%       - Anne Richelle, May 2017 - integration of new extraction methods 
% Adapted by Chaitra Sarathy to use significance levels along with
% expression value and respective functions in efmviz
% Last modified: Chaitra Sarathy, 13 Aug 2019
if ~exist('minSum','var')
    minSum = false;
end

parsedGPR = GPRparser(model,minSum);% Extracting GPR data from model

% Find wich genes in expression data are used in the model
[gene_id, gene_expr, gene_sig] = findUsedGenesLevels_efmviz(model,expressionData);

% Link the gene to the model reactions
expressionRxns = selectGeneFromGPR_efmviz(model, gene_id, gene_expr, gene_sig, parsedGPR, minSum);