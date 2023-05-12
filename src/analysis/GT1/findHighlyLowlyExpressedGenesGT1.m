function genes = findHighlyLowlyExpressedGenesGT1(threshold, geneNames, expressionValues)
% Filters transcriptomics dataset and returns highly and lowly expressed gene 
% cell array (columns: geneId, expressionValue, expression classification - 'High'/'Low')
% containing genes with expression value above and below the given global threshold value 
%
% USAGE:
%
%   genes = findHighlyLowlyExpressedGenesGT1(threshold, geneNames, expressionValues)
%
% INPUTS:
%   threshold:              double
%   geneNames:              char cell array ix1 with all gene Ids
%   expressionValues:       double cell array ix1 with gene expression
%                           values
%
% OUTPUTS:
%	genes:                  cell array ix3 where columns include geneId, 
%                           expressionValue, expression classification - 'High'/'Low'
%
% .. Authors:
%       - Kristina Grausa 05/16/2022
%       - Kristina Grausa 08/23/2022 - standard header and formatting

    lowlyExpressedGenes = findGenesBelowThresholdGT1(threshold, geneNames, expressionValues);
    highlyExpressedGenes = findGenesAboveThresholdGT1(threshold, geneNames, expressionValues);
    genes = vertcat(lowlyExpressedGenes,highlyExpressedGenes);
end
