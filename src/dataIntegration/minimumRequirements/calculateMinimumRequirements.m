function calculateMinimumRequirements(modelPath, trDataPath, mediumDataPath, growthNotAffectingGeneDel, thApproach, lowerTh, upperTh, objective, percentile)

    trSheets = sheetnames(trDataPath);
    modelOriginal=readCbModel(modelPath);
    for i=1:1:height(trSheets)
        model = modelOriginal;
        trData=readtable(trDataPath,'Sheet',trSheets{i}); 
        
        % Calculate percentile
        if percentile == 1      
            lowerThreshold = calculatePercentile(trData.Data, lowerTh);
            upperThreshold = calculatePercentile(trData.Data, upperTh);
        else
            lowerThreshold = lowerTh;
            upperThreshold = upperTh;
        end
        
        inactiveGenes = {};
        if thApproach == 1
            inactiveGenes = findGenesBelowThresholdGT1(lowerThreshold, trData.Geneid, trData.Data);
        elseif thApproach == 2
            inactiveGenes = findGenesBelowThresholdLocal1(lowerThreshold,trDataPath,i);
        else
            inactiveGenes = findGenesBelowThresholdLocal2(lowerThreshold, upperThreshold, trDataPath,i);
        end

        % Non expressed genes
        genes_to_delete = {};
        counter = 1;
        for j=1:1:length(inactiveGenes)
            for n=1:1:length(model.genes)
                if strcmp(inactiveGenes{j}, model.genes{n}) % Metabolic genes only
                    if growthNotAffectingGeneDel == 1
                        try
                            % Test is gene deletions affects growth
                            [grRatio, grRateKO, grRateWT, hasEffect, delRxns] = singleGeneDeletion(model, 'FBA', inactiveGenes(j));
                            disp(inactiveGenes(j));
                            if grRatio == 1
                                genes_to_delete{counter} = inactiveGenes{j};
                                counter = counter + 1;
                            end 
                        catch Ex
                            disp(Ex);
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

        % Apply medium data
        if ~isempty(mediumDataPath)
            [numbers, text, mediumData] = xlsread(mediumDataPath,trSheets{i});
              for n=2:1:height(mediumData)
                 model = changeRxnBounds(model,mediumData{n,1}, mediumData{n,2}, 'l');
                 model = changeRxnBounds(model,mediumData{n,1}, mediumData{n,3}, 'u');
             end
        end

        % Set objective function 
        model = changeObjective(model,objective);

        % Perform optimization
        FBAsolutionMin = optimizeCbModel(model, 'min');
        if ~isempty(FBAsolutionMin.x)
            FBAMin = ["FBAMin" ;FBAsolutionMin.x];

            % Save results
            folderName = 'Results post-optimization/Minimum requirements';
            if ~exist(folderName, 'dir')
               mkdir(folderName)
            end

            excelFileName = convertStringsToChars(strcat('Results post-optimization/Minimum requirements/', trSheets{i}, '.xls'));
            writeCbModel(model, excelFileName);
            [d1,d2, existingData] = xlsread(excelFileName);
            newData = [existingData, FBAMin];  
            writematrix(newData,excelFileName,'AutoFitWidth',false);
        end
    end
end