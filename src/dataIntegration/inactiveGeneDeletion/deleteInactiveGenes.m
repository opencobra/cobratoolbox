function model = deleteInactiveGenes(model, trData, trDataPath, thApproach, lowerTh, upperTh, sheetIndex, growthNotAffectingGeneDel, percentile)      
    
    % Calculate percentile
    if percentile == 1        
        lowerTh = calculatePercentile(trData.Data, lowerTh);
        upperTh = calculatePercentile(trData.Data, upperTh);
    end
    
    inactiveGenes = {};
    if thApproach == 1
        inactiveGenes = findGenesBelowThresholdGT1(lowerTh, trData.Geneid, trData.Data);
    elseif thApproach == 2
        inactiveGenes = findGenesBelowThresholdLocal1(lowerTh,trDataPath,sheetIndex);
    else
        inactiveGenes = findGenesBelowThresholdLocal2(lowerTh, upperTh, trDataPath,sheetIndex);
    end

    % Non expressed genes
    genes_to_delete = {};
    counter = 1;
    for j=1:1:length(inactiveGenes)
        for n=1:1:length(model.genes)
            if strcmp(inactiveGenes{j}, model.genes{n}) % Metabolic genes only
                if growthNotAffectingGeneDel == 1
                    % Test is gene deletions affects growth
                    [grRatio, grRateKO, grRateWT, hasEffect, delRxns] = singleGeneDeletion(model, 'FBA', inactiveGenes(j));
                    disp(inactiveGenes(j));
                    if grRatio == 1
                        genes_to_delete{counter} = inactiveGenes{j};
                        counter = counter + 1;
                    end 
                else
                    genes_to_delete{counter} = inactiveGenes{j};
                    counter = counter + 1;
                end
            end
        end 
    end
    % Delete genes
    [model, hasEffect, constrRxnNames, deletedGenes] = deleteModelGenes(model, genes_to_delete);
end