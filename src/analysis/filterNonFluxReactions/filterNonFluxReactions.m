function filterNonFluxReactions(phenotype)
% Filters and saves in an excel file reactions which do not carry a flux
% in context specific models of the same phenotype from folder resultsPostOptimization\contextSpecificModels
% and filters non-flux reactions which are present in all the models of the
% same phanotype
% 
%
% USAGE:
%
%   filterNonFluxReactions(phenotype)
%
% INPUTS:
%   phenotype:              char representing the phenotype name provided
%                           in each model name of the same phanotype
%
% .. Authors:
%       - Kristina Grausa 05/16/2022
%       - Kristina Grausa 08/23/2022 - standard header and formatting
%       - Farid Zare      20/11/2023 - Repository addresses are correcteds

    dest = string(strcat('resultsPostOptimization/contextSpecificModels/*', phenotype, '*.*'));
    S = dir(dest);
    count = length(S);

    result = {};
    resultAll = {};
    commonZeroReactions = {};

    for i=1:1:count
        sheetName = 'Reaction List';
        filename = strcat(S(i).folder, '/', S(i).name);
        data=readtable(filename,'Sheet',sheetName);

        % Copy headers
        result(1,:) = data.Properties.VariableNames;
        counter = 2;
        for n=1:1:height(data)
            lb = str2double(data.LowerBound{n});
            ub = str2double(data.UpperBound{n});
            if lb == 0 && ub == 0
                result(counter,:) = table2cell(data(n,:)); 
                counter = counter + 1;
            end
        end
        resultAll{i} = result;
        result = {};
    end


    % Find common
    dataSetsCount = length(resultAll);
    dataSet1 = resultAll{1,1};
    
    % Copy headers
    commonZeroReactions(1,:) = dataSet1(1,:);
    counter = 2;

    % Compare all data sets to the 1st data set
    for n=2:1:height(dataSet1)
        reactionAbbr = string(dataSet1(n,1));
        foundTimes = 1;

        for k=2:1:length(resultAll)
            data = resultAll{k}; 
            for s=2:1:height(data)
                if string(data(s,1)) == reactionAbbr
                   foundTimes = foundTimes + 1; 
                end
            end
        end

        if foundTimes == dataSetsCount 
            commonZeroReactions(counter,:) = dataSet1(n,:);
            counter = counter + 1;
        end
    end
    
    % Save results
    folderName = 'resultsPostOptimization/nonFluxReactions/';
    if ~exist(folderName, 'dir')
       mkdir(folderName)
    end

    excelFileName = string(strcat(folderName,'nonFluxReactions', phenotype, '.xls'));
    for n=1:1:length(resultAll)
        sheet1Name = strrep(S(n).name,'.xls','');
        writecell(resultAll{n},excelFileName,'Sheet',sheet1Name,'AutoFitWidth',false);
    end

    sheetName = string(strcat('Common_', phenotype));
    writecell(commonZeroReactions,excelFileName,'Sheet',sheetName,'AutoFitWidth',false);
end
