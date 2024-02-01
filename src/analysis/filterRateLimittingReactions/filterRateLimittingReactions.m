function filterRateLimittingReactions(phenotype)
% Filters and saves in an excel file reactions where maximal flux value
% equals lower bound in context specific models of the same phenotype from folder resultsPostOptimization\contextSpecificModels
% and filters rate limitting reactions which are present in all the models
% of the same phenotype
% 
%
% USAGE:
%
%    filterRateLimittingReactions(phenotype)
%
% INPUTS:
%    phenotype:              char representing the phenotype name provided
%                            in each model name of the same phanotype
%
% .. Authors:
%       - Kristina Grausa 05/16/2022
%       - Kristina Grausa 08/23/2022 - standard header and formatting
%       - Farid Zare      11/21/2023 - Correction of repository address format 
%

    dest = string(strcat('resultsPostOptimization/contextSpecificModels/*', phenotype, '*.xls'));
    S = dir(dest);
    count = length(S);

    result = {};
    resultAll = {}; 
    commonBottleneckReactions = {};

    for i=1:1:count
        sheetName = 'Reaction List';
        filename = strcat(S(i).folder, '/', S(i).name);
        data=readtable(filename,'Sheet',sheetName);

        % Copy headers
        result(1,:) = data.Properties.VariableNames;
        counter = 2;
        for n=1:1:height(data)
            ub = str2double(data.UpperBound{n});
            try
            maxFlux = str2double(data.MaxFlux{n});
            gpr = data.GPR{n};
            if ub == maxFlux && ub ~= 0 && maxFlux ~= 1000 && ~isempty(gpr)
                result(counter,:) = table2cell(data(n,:));
                counter = counter + 1;
            end
            catch e
             disp(e);
            end
        end
        resultAll{i} = result;
        result = {};
    end


    %Find common
    dataSetsCount = length(resultAll);
    dataSet1 = resultAll{1,1};
    
    % Copy headers
    commonBottleneckReactions(1,:) = dataSet1(1,:);
    counter = 2;

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
            commonBottleneckReactions(counter,:) = dataSet1(n,:);
            counter = counter + 1;
        end
    end
    
    % Save results
    folderName = 'resultsPostOptimization/rateLimittingReactions/';
    if ~exist(folderName, 'dir')
       mkdir(folderName)
    end

    excelFileName = string(strcat(folderName,'_rate_limitting_reactions', phenotype, '.xls'));
    for n=1:1:length(resultAll)
        sheet1Name = strrep(S(n).name,'.xls','');
        writecell(resultAll{n},excelFileName,'Sheet',sheet1Name,'AutoFitWidth',false);
    end

    sheetName = string(strcat('Common_', phenotype));
    writecell(commonBottleneckReactions,excelFileName,'Sheet',sheetName,'AutoFitWidth',false);
end
