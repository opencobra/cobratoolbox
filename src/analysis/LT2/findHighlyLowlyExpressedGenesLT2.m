function genes = findHighlyLowlyExpressedGenesLT2(lowerThreshold, upperThreshold, trDataPath, sheetIndex)

    lowlyExpressedGenes = findGenesBelowThresholdLocal2(lowerThreshold, upperThreshold, trDataPath, sheetIndex);
    highlyExpressedGenes = findGenesAboveThresholdLocal2(lowerThreshold, upperThreshold, trDataPath, sheetIndex);
    genes = vertcat(lowlyExpressedGenes,highlyExpressedGenes);
end