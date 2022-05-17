function genes = findHighlyLowlyExpressedGenesLT1(threshold, trDataPath, sheetIndex)

    lowlyExpressedGenes = findGenesBelowThresholdLocal1(threshold, trDataPath, sheetIndex);
    highlyExpressedGenes = findGenesAboveThresholdLocal1(threshold, trDataPath, sheetIndex);
    genes = vertcat(lowlyExpressedGenes,highlyExpressedGenes);
end