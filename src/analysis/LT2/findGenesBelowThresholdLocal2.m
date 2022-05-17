function genes = findGenesBelowThresholdLocal2(lowerThreshold, upperThreshold, trDataPath, sheetIndex)
    try
        trDataAll = {};
        cnt = 1;

        % Get transcriptomics data sheet names
        trSheets = sheetnames(trDataPath);
        sheetNameParts = split(trSheets{sheetIndex},'_');
        phenotype = sheetNameParts{2};

        % Get target trancriptomics sheet
        trTarget=readtable(trDataPath,'Sheet',trSheets{sheetIndex}); 

        % Get all data sets of the same phemotype (GENES MUST BE IN THE SAME ORDER)    
        for i=1:1:height(trSheets)
            if contains(trSheets{i}, phenotype)
                data=readtable(trDataPath,'Sheet',trSheets{i}); 
                if length(trDataAll) == 0
                    trDataAll(:,1) = table2cell(data(:,1));
                    cnt = 2;
                end
                trDataAll(:,cnt) = table2cell(data(:,2));
                cnt = cnt + 1;
            end
        end

        cnt = 1;
        % Find genes below global or local thresholds
        for i=1:1:height(trDataAll)
            if lowerThreshold > trTarget{i,2} % Expression below global threshold
                genes{cnt,1} = char(trTarget{i,1});
                genes{cnt,2} = trTarget{i,2};
                genes{cnt,3} = 'Low';
                genes{cnt,4} = 'Global';
                cnt = cnt + 1;
            elseif upperThreshold > trTarget{i,2} % Check Local threshold
                row = trDataAll(i,:);
                expressionSum = 0;
                for j=2:1:length(row)
                    expressionSum = expressionSum + row{j};
                end
                avg = expressionSum/length(row)-1; 
                if avg > trTarget{i,2}
                    genes{cnt,1} = char(trTarget{i,1});
                    genes{cnt,2} = trTarget{i,2};
                    genes{cnt,3} = 'Low';
                    genes{cnt,4} = 'Local';
                    cnt = cnt + 1;
                end
            end
        end
    catch e
        disp(e);
    end
end