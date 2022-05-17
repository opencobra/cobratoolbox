function genes = findHighlyLowlyExpressedGenesGT1(threshold, geneNames, expressionValues)

    lowlyExpressedGenes = findGenesBelowThresholdGT1(threshold, geneNames, expressionValues);
    highlyExpressedGenes = findGenesAboveThresholdGT1(threshold, geneNames, expressionValues);
    genes = vertcat(lowlyExpressedGenes,highlyExpressedGenes);
end