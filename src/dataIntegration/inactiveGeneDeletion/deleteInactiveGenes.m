function model = deleteInactiveGenes(model, trData, trDataPath, thApproach, lowerTh, upperTh, sheetIndex, growthNotAffectingGeneDel, percentile)      
% Returns a tissue specific model with inactive genes deleted
%
% USAGE:
%
%   model = deleteInactiveGenes(model, trData, trDataPath, thApproach, lowerTh, upperTh, sheetIndex, growthNotAffectingGeneDel, percentile)
%
% INPUTS:
%   model:                      model strusture 
%   trData:                     table with columns 'GeneId' and 'Data'
%   trDataPath:                 char full transcriptomics data filename
%   thApproach:                 double (1-GT1, 2-LT1, 3-LT2)
%   lowerTh:                    double
%   upperTh:                    double (required for LT2)
%   sheetIndex:                 double transcriptomics dataset sheet index
%   growthNotAffectingGeneDel:  double (1 or 0) check if grRatio equals 1
%                               after gene deletion compared to wildtype
%   percentile:                 double (1 or 0) bool option to convert
%                               thresholds to percentile value 
%
% OUTPUTS:
%	model:                      extracted model
%
% .. Authors:
%       - Kristina Grausa 05/16/2022
%       - Kristina Grausa 08/23/2022 - standard header and formatting

    % Calculate percentile if needed
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
                    % Test if gene deletions affects growth
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
