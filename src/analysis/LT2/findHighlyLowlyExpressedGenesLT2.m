function genes = findHighlyLowlyExpressedGenesLT2(lowerThreshold, upperThreshold, trDataPath, sheetIndex)
% Filters transcriptomics dataset and returns highly and lowly expressed gene 
% cell array (columns: geneId, expressionValue, expression classification - 'High'/'Low',
% applied threshold type - 'Global'/'Local') when multiple transcriptomics datasets available
%
% USAGE:
%
%   genes = findHighlyLowlyExpressedGenesLT2(lowerThreshold, upperThreshold, trDataPath, sheetIndex)
%
% INPUTS:
%   lowerThreshold:         double
%   upperThreshold:         double
%   trDataPath:             char full transcriptomics data filename
%   sheetIndex:             double target transcriptomics dataset sheet index 
%
% OUTPUTS:
%	genes:                  cell array ix4 where columns include geneId, 
%                           expressionValue, expression classification -
%                           'High'/'Low' and applied threshold type - 'Global'/'Local'
%
% .. Authors:
%       - Kristina Grausa 05/16/2022
%       - Kristina Grausa 08/23/2022 - standard header and formatting

    lowlyExpressedGenes = findGenesBelowThresholdLocal2(lowerThreshold, upperThreshold, trDataPath, sheetIndex);
    highlyExpressedGenes = findGenesAboveThresholdLocal2(lowerThreshold, upperThreshold, trDataPath, sheetIndex);
    genes = vertcat(lowlyExpressedGenes,highlyExpressedGenes);
end
