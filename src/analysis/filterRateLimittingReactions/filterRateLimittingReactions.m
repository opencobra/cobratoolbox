function filterRateLimittingReactions(phenotype)
    dest = string(strcat('Results post-optimization\Context-specific models\*', phenotype, '*.xls'));
    S = dir(dest);
    count = length(S);

    result = {};
    resultAll = {}; % zero reaction for each dataset
    commonBottleneckReactions = {}; % common

    for i=1:1:count
        sheetName = 'Reaction List';
        filename = strcat(S(i).folder, '\', S(i).name);
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
    folderName = 'Results post-optimization\Rate limitting reactions\';
    if ~exist(folderName, 'dir')
       mkdir(folderName)
    end

    excelFileName = string(strcat(folderName,'rate_limitting_reactions_', phenotype, '.xls'));
    for n=1:1:length(resultAll)
        sheet1Name = strrep(S(n).name,'.xls','');
        writecell(resultAll{n},excelFileName,'Sheet',sheet1Name,'AutoFitWidth',false);
    end

    sheetName = string(strcat('Common_', phenotype));
    writecell(commonBottleneckReactions,excelFileName,'Sheet',sheetName,'AutoFitWidth',false);
end