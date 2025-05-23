function [scoredFoods, fluxValues] = vmhFoodFinder(templateFilePath, varargin)
% Finding VMH food alternatives to original food items based on key words
% or pre-selected VMH food items.
%
% Usage:
%   [output, fluxValues] = vmhFoodFinder(templateFilePath, varargin)
%
% Inputs:
%   templateFilePath:   Path to the filled in template file
%
% Optional Inputs:
%   searchType:         Method of searching keywords in the food database.
%                       Either iterative or cumulative. Defaults to
%                       iterative
%   addStarch:          Boolean indicating if additional starch should be
%                       added based on the VMH food macros. Defaults to
%                       false
%   databaseType:       Character, which database should be used either
%                       'usda' for USDA FoodData database or 'frida' for
%                       the Danish food institute database. Can be 'mixed'
%                       if both databases should be used.
%   maxItems:           Numeric, value indicating what the max amount of
%                       VMH food alternatives will be analysed for macros.
%                       Defaults to 50
%   outputDir:          Path to where the output file will be stored.
%                       Defaults to [pwd filesep 'NT_Result']
%   foodSources2Use:    Cell of strings, dictates which food sources from
%                       the USDA database will be used to find food items.
%                       Defaults to {'sr_legacy_food'; 'foundation_food';
%                       'survey_fndds_food'};
%
% Output:
%   scoredFoods:        A structure where each field is a fooditem and
%                       contains a table with the macro values of the
%                       original food items and the VMH alternatives. The
%                       score calculate based on similarity witht the
%                       original food item is present as well.
%   fluxValues:         A structure where each field is a fooditem
%                       containing the calculated flux vector based on the
%                       amount eaten
%
% Example:
%   [output, fluxValues] = vmhFoodFinder(templateFilePath, 'addStarch', true)
%
% .. Author - Bram Nap, 05-2024

% Parse the inputs
parser = inputParser();
parser.addRequired('templateFilePath', @ischar);
parser.addParameter('searchType', 'iterative',@ischar);
parser.addParameter('addStarch', false,@islogical);
parser.addParameter('databaseType', 'mixed',@ischar);
parser.addParameter('maxItems', 50, @isnumeric);
parser.addParameter('outputDir', [pwd filesep 'NT_Result'], @ischar);
parser.addParameter('foodSources2Use', {'sr_legacy_food';'foundation_food';'survey_fndds_food'}, @iscell);

parser.parse(templateFilePath, varargin{:});

templateFilePath = parser.Results.templateFilePath;
searchType = parser.Results.searchType;
addStarch = parser.Results.addStarch;
databaseType = parser.Results.databaseType;
maxItems = parser.Results.maxItems;
outputDir = parser.Results.outputDir;
foodSources2Use = parser.Results.foodSources2Use;
%%

% Read the template file as a table
userInput = readtable(templateFilePath, 'preserveVariableNames', true);

% Read in the database
if strcmpi(databaseType, 'usda')
    foodNames = load('USDAfoodItems.mat').allFoods;

    for i = 1:max(size(foodSources2Use))
        if i == 1
            foodNamesSub = foodNames(strcmpi(foodNames.data_type, foodSources2Use(i)),:);
        else
            foodNamesSub1 = foodNames(strcmpi(foodNames.data_type, foodSources2Use(i)),:);
            foodNamesSub = [foodNamesSub; foodNamesSub1];
        end
    end
    foodNames = [foodNamesSub.description, foodNamesSub.fdc_id];
    foodNames(:,3) = {'usda'};
elseif strcmpi(databaseType, 'frida')
    foodNames = load("frida2024_foodIdDictionary.mat").foodIdDictionary;
    foodNamesFrida = [foodNames.foodName, foodNames.foodId];
    foodNamesFrida(:,3) = {'frida'};

    if isstring(foodNamesFrida)
        foodNamesFrida = cellstr(foodNamesFrida);
    end
elseif strcmpi(databaseType, 'mixed')
    foodNames = load('USDAfoodItems.mat').allFoods;

    for i = 1:max(size(foodSources2Use))
        if i == 1
            foodNamesSub = foodNames(strcmpi(foodNames.data_type, foodSources2Use(i)),:);
        else
            foodNamesSub1 = foodNames(strcmpi(foodNames.data_type, foodSources2Use(i)),:);
            foodNamesSub = [foodNamesSub; foodNamesSub1];
        end
    end
    foodNamesUsda = [foodNamesSub.description, string(foodNamesSub.fdc_id)];
    foodNamesUsda(:,3) = {'usda'};

    if isstring(foodNamesUsda)
        foodNamesUsda = cellstr(foodNamesUsda);
    end

    foodNames = load("frida2024_foodIdDictionary.mat").foodIdDictionaryFrida;
    foodNamesFrida = [foodNames.foodName, foodNames.foodId];
    foodNamesFrida(:,3) = {'frida'};

    if isstring(foodNamesFrida)
        foodNamesFrida = cellstr(foodNamesFrida);
    end
else
    error(['Database type does not correspond to the options please choose' ...
        'usda, frida or mixed'])
end
% Initialise storage variables
foods2Check = struct();
noResult = {};
manyResult = {};
alteredKeyWords = {};

% Create aliases x1,x2... etc for the original food item names for easy
% usage and store the conversion as a translation array
numbers = 1:size(userInput,1);
shadowName = strcat('x', string(numbers'));
translation = [userInput.OriginalFoodName(1:end), shadowName];

for i = 1:size(userInput,1)
    adjust = 0;
    % Check if the user has already specified any VMH food alternatives
    if ~strcmpi(userInput.databaseID(i), 'NaN') && iscell(userInput.databaseID(i)) && ~isempty(userInput.databaseID{i})
        % If VMH food alternative have already been suggested change

        % spaces around ; to ';'
        if contains(userInput.databaseID(i),';')
            databaseAlternatives = splitKeyWord(userInput.databaseID(i), adjust);
            databaseNames = splitKeyWord(userInput.databaseName(i), adjust);
        else
            % If no ; is present we assume only 1 VMH input
            databaseAlternatives = userInput.databaseID(i);
            databaseNames = userInput.databaseName(i);
        end
        % Delete empty entries
        databaseAlternatives(cellfun(@isempty,databaseAlternatives)) = [];
        databaseNames(cellfun(@isempty,databaseNames)) = [];
        
        % Sanity checks
        if length(databaseNames) ~= length(databaseAlternatives)
            error('The amount of database IDs do not match the number of database names you have given. For each databasebase ID give the respective database name')
        elseif any(contains(databaseNames, ',')) || any(contains(databaseNames, ' ')) || any(contains(databaseAlternatives, ',')) || any(contains(databaseAlternatives, ' '))
            error('It seems that there is a , or whitespace in your database ID or names. Please double check ; has been used to seperate the different entries.')
        end
        % combine the database ID and their respective database names
        toStore = [databaseAlternatives, databaseNames];
        
        foodNameItemList = cell(size(toStore,1),1);
        for k = 1:size(toStore,1)
            if strcmpi(toStore(k,2), 'usda')
                foodNameItem = foodNamesUsda(str2double(string(foodNamesUsda(:,2))) == str2double(toStore{k,1}),1);
                foodNameItemList(k,1) = foodNameItem;
            elseif strcmpi(toStore(k,2), 'frida')
                foodNameItem = foodNamesFrida(str2double(string(foodNamesFrida(:,2))) == str2double(toStore{k,1}),1);
                foodNameItemList(k,1) = foodNameItem;
            else
                error('Please use only USDA or FRIDA as database names')
            end
        end
        % Set the original food names
        toStore = [foodNameItemList, toStore];
        
        % Set the amount of food ingested and add the VMH items to the
        % foods2Check structure with their alias as field name
        
        toStore(:,4) = {userInput.("WeightEaten (g)")(i)};
        foods2Check.(translation(i,2)) = toStore;
    else
        % If no VMH food suggestions were already given obtain the keywords
        % used to define the food item
        foodInfo = userInput(i,:);

        % Obtain the keywords
        query = foodInfo.KeyWords;
        keyWords = splitKeyWord(query, adjust);

        % Obtain words that should be excluded from the search
        notIncludeQuery = foodInfo.toExclude;
        if any(isletter(string(notIncludeQuery)))
            notIncludeKeyWords = splitKeyWord(notIncludeQuery, adjust);
        else
            notIncludeKeyWords = {};
        end
        % Find VMH food suggestions with the searcher function
        if strcmpi(databaseType, 'mixed')
            totGroupSubUsda = searcher(keyWords, foodNamesUsda, "searchType", searchType, "notInclude", notIncludeKeyWords);
            totGroupSubFrida = searcher(keyWords, foodNamesFrida, "searchType", searchType, "notInclude", notIncludeKeyWords);
            totGroupSub = [totGroupSubUsda;totGroupSubFrida];
        elseif strcmpi(databaseType, 'usda')
            totGroupSub = searcher(keyWords, foodNamesUsda, "searchType", searchType, "notInclude", notIncludeKeyWords);
        elseif strcmpi(databaseType, 'frida')
            totGroupSub = searcher(keyWords, foodNamesFrida, "searchType", searchType, "notInclude", notIncludeKeyWords);
        end

        % Initialise a boolean indication if the keywords were changed
        keyWordAltered = 0;
        if isempty(totGroupSub) || size(totGroupSub,1) > maxItems
            % If too many or no VMH food suggestions were found we adjust
            adjust = 1;
            altKeyWord = splitKeyWord(keyWords, adjust);

            % Store the previous VMH suggestions in a new variable
            totGroupSubold = totGroupSub;
            % Search again for VMH food suggestions with the altered
            % keywords
            if strcmpi(databaseType, 'mixed')
                totGroupSubUsda = searcher(altKeyWord, foodNamesUsda, "searchType", searchType, "notInclude", notIncludeKeyWords);
                totGroupSubFrida = searcher(altKeyWord, foodNamesFrida, "searchType", searchType, "notInclude", notIncludeKeyWords);
                totGroupSub = [totGroupSubUsda;totGroupSubFrida];
            else
                totGroupSub = searcher(altKeyWord, foodNames, "searchType", searchType, "notInclude", notIncludeKeyWords);
            end
            % If no items or too many items found, revert to old results
            if isempty(totGroupSub) || size(totGroupSub,1) > maxItems
                totGroupSub = totGroupSubold;
            else
                % Update that the keywords have been altered
                % Save which food items have had their keywords altered
                alteredKeyWords{end+1, 1} = cell2mat(userInput{i,1});
                alteredKeyWords{end,2} = keyWordAltered;
            end
        end

        if isempty(totGroupSub)
            % If the search gave no results save that food item in the
            % noResults variable
            noResult(end+1,1) = userInput{i,1};

        elseif size(totGroupSub,1) <= maxItems
            % If the amount of VMH food suggestions is smaller or equal to
            % the maximum foods allowed assign them the food ingested from
            % the original food item and save them under their alias in the
            % foods2Check structure
            totGroupSub(:,4) = {foodInfo.("WeightEaten (g)")};

            foods2Check.(translation(i,2)) = totGroupSub;
        else
            % If the amount of suggested food items exceed the maxItems
            % store the food item in manyResults
            manyResult(end+1,1) = userInput{i,1};
            manyResult(end,2:size(totGroupSub,1)+1) = totGroupSub(:,1)';
        end
    end
end

% Obtain the flux and macro values
[~, macroValuesLabel] = collectFoodItemInfo(foods2Check, "addStarch",addStarch, "macroType", 'database');
[fluxValues, macroValuesMetabolites] = collectFoodItemInfo(foods2Check, "addStarch",addStarch, "macroType", 'metabolites');


% Compare the suggested VMH food's macros witht the macros of the original
% food.
[scoredFoods] = calculateFoodScore(userInput, macroValuesLabel, macroValuesMetabolites,translation);

% Add the database and database ID to the scored food names to track where
% the food items came from
fieldNames = fieldnames(scoredFoods);
for i = 1:size(fieldNames,1)
    % Obtain the scored table with the flux values for macros and the score
    % based on reported macros
    tempTable = scoredFoods.(fieldNames{i});
    % Obtain the database information for the fooditems
    foodItemDatabaseInfo = foods2Check.(fieldNames{i});
    % Add the database origin and ID to the table
    tempTable.databaseOrigin = [{''};foodItemDatabaseInfo(:,3)];
    tempTable.databaseID = [{''};foodItemDatabaseInfo(:,2)];
    % Reorder for improved interpretability
    tempTable = tempTable(:, [1, end, end-1, 2:end-2]);
    % Overwrite original table
    scoredFoods.(fieldNames{i}) = tempTable;
end

% Initialise storage variables
output = {};
outputCut = {};
for i = 1:size(userInput,1)
    % Obtain the alias for the original food item
    shadow = translation(i,2);
    originalItem = translation(i,1);
    % Check if the alias is found in the scoredFoods variable
    if isfield(scoredFoods, shadow)
        % Extract the table with macros and score
        tempTable = scoredFoods.(cell2mat(shadow));
        % Sort the table with the highest score on top
        tempTableSort = sortrows(tempTable, size(tempTable,2), "ascend");

        % Store the result in the storage variable
        tempCell = [tempTableSort.Properties.VariableNames;table2cell(tempTableSort)];
        tempCellStore = [tempCell;repelem({' '},size(tempTable,2))];
        output = [output;tempCellStore];

        % If the output is more than 10, save the top 10 results in a new
        % variable
        if size(tempCell,1) > 11
            tempCell = tempCell(1:11,:);
            tempCellStore = [tempCell;repelem({' '},size(tempTable,2))];
        end
        outputCut = [outputCut;tempCellStore];

        % Check if the original food item can be found in the manyResult
        % variable
    elseif ~isempty(find(strcmp(manyResult, originalItem), 1))
        % Save a line saying that key words gave too many suggested VMH
        % food items
        text = strcat(cell2mat(originalItem), sprintf(' has over %f alternative food Items. Please refine your keywords. Add more keywords. It might help to look at the file xx.xlsx where all the found alternative names are stored. Otherwise looking for the food item on VMH.life might help identifying key words or even an alternative food item.', maxItems));
        tempCell = cell(1,size(tempTable,2));
        tempCell{1} = text;
        tempCellStore = [tempCell;repelem({' '},size(tempTable,2))];
        output = [output;tempCellStore];
        outputCut = [outputCut;tempCellStore];
    elseif ~isempty(find(strcmp(noResult, originalItem), 1))
        % Save a line saying that the key words did not give any suggested
        % VMH food items
        text = strcat(cell2mat(originalItem), ' did not give alternative food Items. Please look at your keywords. It might help to for the food item on VMH.life might help identifying keywords or even an alternative food item.');
        tempCell = cell(1,size(tempTable,2));
        tempCell{1} = text;
        tempCellStore = [tempCell;repelem({' '},size(tempTable,2))];
        output = [output;tempCellStore];
        outputCut = [outputCut;tempCellStore];
    else
    end
end

if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% Save results
writecell(output, [outputDir, filesep, 'fullComparisonFoodItems.xlsx']);
writecell(outputCut, [outputDir, filesep, 'topResultsComparisonFoodItems.xlsx']);
writecell(manyResult', [outputDir, filesep, 'tooManyDatabaseHits.xlsx']);
writecell(noResult, [outputDir, filesep, 'noDatabaseHits.txt']);

% Find the cells in the saved excel worksheet where food items with altered
% key words are stored
if ~isempty(alteredKeyWords)
    [~,~,colourChangeIdx] = intersect(alteredKeyWords(cell2mat(alteredKeyWords(:,2)) == 1,1), output(:,1));
    colourChangeIdx = strcat('A', string(colourChangeIdx));
else
    colourChangeIdx = {};
end

if ~isempty(colourChangeIdx)
    % Connect to Excel
    Excel = actxserver('excel.application');
    % Get Workbook object
    WB = Excel.Workbooks.Open(fullfile(outputDir, 'fullComparisonFoodItems.xlsx'),0,false);

    % Adjust the column width of column A
    WB.Worksheets.Item(1).Range('A:A').columnWidth = 50;

    % Adjust the colour of the cell for food items with changed key items
    for i = 1:size(colourChangeIdx,1)
        WB.Worksheets.Item(1).Range(colourChangeIdx{i}).Interior.ColorIndex = 3;
    end
    % Save Workbook
    WB.Save();
    % Close Workbook
    WB.Close();

    % Quit Excel
    Excel.Quit();
end
end

function keyWordsSplit = splitKeyWord(keyWords, adjust)
% Function to split items based on ;
%
% Usage:
%   keyWordsSplit = splitKeyWord(keyWords, adjust)
%
% Inputs:
%   keyWords:   cell array of items to be split
%   adjust:     Boolean to indicate if the items should be adjusted as well
%
% Output:
%   keyWordsSplit:  A cell array with the split items
%
% Example:
%   keyWordsSplit = splitKeyWord(keyWords, adjust)
%
% .. Author - Bram Nap, 02-2025

if adjust
    % Adjust the keywords so that "-", "," and " " are also read
    % as ; increasing the amount of keywords
    keyWordsSplit = strrep(keyWords, '-', ';');
    keyWordsSplit = strrep(keyWordsSplit, ',', ';');
    keyWordsSplit = strrep(keyWordsSplit, ' ', ';');
    keyWordsSplit = strrep(keyWordsSplit, '; ', ';');
    keyWordsSplit = strrep(keyWordsSplit, ' ; ', ';');
    keyWordsSplit = strrep(keyWordsSplit, ' ;', ';');
    keyWordsSplit = strrep(keyWordsSplit, ' ', ';');
else
    % change spaces around ; to ';'
    keyWordsSplit = strrep(keyWords, '; ', ';');
    keyWordsSplit = strrep(keyWordsSplit, ' ; ', ';');
    keyWordsSplit = strrep(keyWordsSplit, ' ;', ';');
end
% Split the keywords on ;
keyWordsSplit = split(keyWordsSplit, ';');

keyWordsSplit(cellfun(@isempty, keyWordsSplit)) = [];
end
