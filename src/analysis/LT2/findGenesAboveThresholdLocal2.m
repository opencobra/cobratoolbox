function genes = findGenesAboveThresholdLocal2(lowerThreshold, upperThreshold, trDataPath, sheetIndex)
% Filters transcriptomics dataset and returns highly expressed gene 
% cell array (columns: geneId, expressionValue, expression classification - 'High',
% applied threshold type - 'Global'/'Local') containing genes with expression value above 
% the given upper global threshold value or above the given lower threshold value and the local 
% gene specific threshold when multiple transcriptomics datasets available
%
% USAGE:
%
%   genes = findGenesAboveThresholdLocal2(lowerThreshold, upperThreshold, trDataPath, sheetIndex)
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
%                           'High' and applied threshold type - 'Global'/'Local'
%
% .. Authors:
%       - Kristina Grausa 05/16/2022
%       - Kristina Grausa 08/23/2022 - standard header and formatting

    try
        trDataAll = {};
        cnt = 1;

        % Get transcriptomics data sheet names
        trSheets = sheetnames(trDataPath);
        sheetNameParts = split(trSheets{sheetIndex},'_');
        phenotype = sheetNameParts{2};

        % Get target trancriptomics sheet
        trTarget=readtable(trDataPath,'Sheet',trSheets{sheetIndex}); 

        % Get all data sets of the same phemotype
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
        % Find genes above global or local thresholds
        for i=1:1:height(trDataAll)
            if upperThreshold <= trTarget{i,2} % Expression above global threshold
                genes{cnt,1} = string(trTarget{i,1});
                genes{cnt,2} = trTarget{i,2};
                genes{cnt,3} = 'High';
                genes{cnt,4} = 'Global';
                cnt = cnt + 1;
            elseif upperThreshold > trTarget{i,2} && lowerThreshold <= trTarget{i,2}
                row = trDataAll(i,:);
                expressionSum = 0;
                for j=2:1:length(row)
                    expressionSum = expressionSum + row{j};
                end
                avg = expressionSum/length(row)-1; 
                if avg <= trTarget{i,2} % Expression above local threshold
                    genes{cnt,1} = string(trTarget{i,1});
                    genes{cnt,2} = trTarget{i,2};
                    genes{cnt,3} = 'High';
                    genes{cnt,4} = 'Local';
                    cnt = cnt + 1;
                end
            end
        end
    catch e
        disp(e);
    end
end
