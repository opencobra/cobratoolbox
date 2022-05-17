function model = createContextSpecificModel(modelPath, trDataPath, mediumDataPath, growthNotAffectingGeneDel, meetMinimumReq, thApproach, lowerTh, upperTh, objective, gmAndOperation, gmOrOperation, constrAll, excludeBiomassEq, biomassId, percentile)
    
    trSheets = sheetnames(trDataPath);
    modelOriginal=readCbModel(modelPath);
    
    if ~isfield(modelOriginal, 'grRules')
        modelOriginal = addGrRulesToModel(modelOriginal);
    end
    
    logicalOperators = ["and" "or" "(" ")" "((" "))"];
    log = cell(height(modelOriginal.rxns),5);
    
    for s=1:1:height(trSheets) 
        model = modelOriginal;
        trData=readtable(trDataPath,'Sheet',trSheets{s}); 
        minRequirements = {};
        if meetMinimumReq == 1
            try
                minRequirements = readtable(strcat('Results post-optimization/Minimum requirements/',trSheets{s},'.xls')).FBAMin; 
            catch e
                minRequirements = {};
            end
        end

        % Gene Mapping
        for i=1:1:length(model.rxns)

            log{i,1} = model.rxns{i};
            log{i,2} = model.grRules{i};

            % No associated genes
            if model.grRules{i} == "" 
                log{i,3} = 'No associated genes';

            % One Gene (expression does not contain brackets)
            elseif ~contains(model.grRules{i},"(")
                log{i,3} = 'One Gene';
                value = findTranscriptionValue(model.grRules{i},trData);
                if value ~= 0
                    log{i,5} = findTranscriptionValue(model.grRules{i},trData);
                end

            % Gene combination AND + OR (expression contains double brackets)
            elseif contains(model.grRules{i},"((") || contains(model.grRules{i},"))")

                log{i,3} = 'AND + OR';
                value = model.grRules{i};

                %Split ORs
                ands = split(model.grRules{i},"or");
                orsToCompare = [];

                for k=1:1:length(ands)
                    %Split ANDs
                    operands = split(ands(k));
                    andsToCompare = [];

                    for l=1:1:length(operands)
                        if ~ismember(operands{l},logicalOperators) && operands(l)~=""
                            tr_Val = findTranscriptionValue(operands{l},trData);
                            andsToCompare = [andsToCompare tr_Val];
                        end
                    end
                    if strcmp(gmAndOperation,'MIN')
                        orsToCompare = [orsToCompare min(andsToCompare)];
                    else 
                        orsToCompare = [orsToCompare round(geomean(andsToCompare))];
                    end
                end

                operands = split(model.grRules{i});
                for l=1:1:length(operands)
                    if ~ismember(operands{l},logicalOperators)
                        tr_Val = findTranscriptionValue(operands{l},trData);
                        value = strrep(value,operands{l},num2str(tr_Val));
                    end
                end
                log{i,4} = value;
                if strcmp(gmOrOperation,'MAX')
                    log{i,5} = max(orsToCompare);
                else 
                    log{i,5} = sum(orsToCompare);
                end

            % Gene combination AND
            elseif contains(model.grRules{i},"and")
                log{i,3} = 'AND only';
                value = model.grRules{i};
                operands = split(model.grRules{i});
                numbersToCompare = [];

                for l=1:1:length(operands)
                    if ~ismember(operands{l},logicalOperators)
                        tr_Val = findTranscriptionValue(operands{l},trData);
                        numbersToCompare = [numbersToCompare tr_Val];
                        value = strrep(value,operands{l},num2str(tr_Val));
                    end
                end
                log{i,4} = value;
                if strcmp(gmAndOperation,'MIN')
                    log{i,5} = min(numbersToCompare);
                else 
                    log{i,5} = round(geomean(numbersToCompare));
                end

            % Gene combination OR
            elseif contains(model.grRules{i},"or")
                log{i,3} = 'OR only';
                value = model.grRules{i};
                operands = split(model.grRules{i});
                numbersToCompare = [];

                for l=1:1:length(operands)
                    if ~ismember(operands{l},logicalOperators)
                        tr_Val = findTranscriptionValue(operands{l},trData);
                        numbersToCompare = [numbersToCompare tr_Val];
                        value = strrep(value,operands{l},num2str(tr_Val));
                    end
                end
                log{i,4} = value;
                if strcmp(gmOrOperation,'MAX')
                    log{i,5} = max(orsToCompare);
                else 
                    log{i,5} = sum(orsToCompare);
                end
            end

            %Set reaction bounds
            if ~isempty(log{i,5})
                try
                    constrainRxn = true;
                    if ~isempty(minRequirements)
                        if log{i,5} < str2double(minRequirements{i})
                            constrainRxn = false;
                        end
                    end
                    
                    if constrainRxn
                        if constrAll == 1 && model.lb(i) < 0
                            value = log{i,5};
                            model = changeRxnBounds(model,model.rxns{i},-value,'l');
                            model = changeRxnBounds(model,model.rxns{i},value,'u');
                        elseif model.lb(i) == 0
                            model = changeRxnBounds(model,model.rxns{i},log{i,5},'u');
                        end
                    end
                catch e
                  disp(e);
                end
            end
        end


        % Delete Inactive genes
        model = deleteInactiveGenes(model, trData, trDataPath, thApproach, lowerTh, upperTh, s, growthNotAffectingGeneDel, percentile);


        % Apply medium data
        if ~isempty(mediumDataPath)
            [numbers, text, mediumData] = xlsread(mediumDataPath,trSheets{s});
              for n=2:1:height(mediumData)
                 model = changeRxnBounds(model,mediumData{n,1}, mediumData{n,2}, 'l');
                 model = changeRxnBounds(model,mediumData{n,1}, mediumData{n,3}, 'u');
             end
        end

        % Set objective function 
        model = changeObjective(model,objective);

        if excludeBiomassEq == 1 && ~isempty(biomassId)
           model = changeRxnBounds(model,biomassId,0,'b');
        end

        % Save context-specific model
        folderName = 'Results post-optimization/Context-specific models';
        if ~exist(folderName, 'dir')
           mkdir(folderName)
        end
        excelFileName = convertStringsToChars(strcat('Results post-optimization/Context-specific models/', trSheets{s}, '.xls'));
        writeCbModel(model, excelFileName);

        % Perform optimization
        try
            [minFlux, maxFlux] = fluxVariability(model, 90, 'max');
            minFlux = ["MinFlux" ;minFlux];
            maxFlux = ["MaxFlux" ;maxFlux];

            % Save results
            [d1,d2, existingData] = xlsread(excelFileName);
            newData = [existingData, minFlux, maxFlux];  
            writematrix(newData,excelFileName,'AutoFitWidth',false);

        catch e
            disp(e);
        end
    end
end