function statResults = runStatisticsOnModerationAnalysisResults(data,metadata,formula,regressionResults,moderationThreshold_usePValue,moderationThreshold,saveDir)
% Filters regression results from moderation analysis for significantly
% correlating metabolites fluxes/bacterial taxa. Then stratifies the filtered
% flux/rel. abundances data for the moderator & performs new statistical analysis 
% on the stratified data.
% Notes: The moderator needs to be categorical.
%
% INPUTS:
%   data:                           [Table] Processed flux/relative abundances data.
%   metadata:                       [Table] Metadata containing ID & pot. additional variables 
%                                   (confounders, moderators)
%   formula:                        [String] Regression formula in Wilkinson notation.
%   regressionResults:              [Struct] Structure containing tables for flux &
%                                   rel. abundances regression results.
%   moderationThreshold_usePValue:  [Boolean] Cutoff threshold being either
%                                   FDR or pValue.
%                                   Default = true.
%   moderationThreshold:            [Numerical] Cutoff threshold for maximal FDR value from
%                                   moderation analysis a metabolite/bacterial taxa needs to
%                                   pass that it will be included in subsequent 
%                                   analysis of stratified fluxes/taxa.
%                                   Default = 0.05 (5%).
%   saveDir:                        [Character array] Path to working directory.
%
% OUTPUT:
%   statResults:                    [Struct] Structure containing tables for
%                                   regression results for moderator stratified data
%                                   of significant hits from initial from moderation 
%                                   analysis regressions.
%                                   Will be empty, if regression does not contain Flux
%                                   or relative abundance.
%
% AUTHOR:
%   Jonas Widder, 11/2024

% Specify dependent on user input, if the pValue or FDR is being used as
% Cutoff-threshold
if moderationThreshold_usePValue == true
    moderationThresholdType = "pValue";
else
    moderationThresholdType = "FDR";
end

% Get responce & moderator from formula
formulaItems = strsplit(formula,"+");
formulaItems = [strtrim(strsplit(formulaItems{1},'~')) formulaItems(2:end)];
response = formulaItems{1};
predictor = formulaItems{2};
interactionTerm = formulaItems{end};
toEraseFromModerator = strcat(predictor, ':');
moderator = erase(interactionTerm, toEraseFromModerator);

% Get regressionResults table with predictor
fieldNames = string(fieldnames(regressionResults));
regressionResults = regressionResults.(fieldNames(1));

if predictor == "Flux"
    % Filter metabolites in fluxes regressionResults with FDR below moderationThreshold &
    % store significantly correlated metabolite fluxes in filteredData
    filteredMetabolites = regressionResults.Reaction(regressionResults.(moderationThresholdType) < moderationThreshold);
    filteredMetabolites = filteredMetabolites';
    filteredData = data(:, ["ID", filteredMetabolites]);
else
    % Filter taxa in relative_abundances regressionResults with FDR below moderationThreshold &
    % store significantly correlated relative_abundances in filteredData
    filteredTaxa = regressionResults.Taxa(regressionResults.(moderationThresholdType) < moderationThreshold);
    filteredTaxa = filteredTaxa';
    filteredData = data(:, ["ID", filteredTaxa]);
end

% If filteredData contains more than one column, meaning there are
% significanty correlated metabolite fluxes/taxa rel.abundances, stratify them
if width(filteredData) > 1
    % ToDo: Test if moderator variable is categorical, skip if continous

    % Find unique categories in moderator metadata column
    [categories, ~, categoriesIdx] = unique(metadata.(moderator));
    
    % Preallocate structured variable for statistical results for moderator variable
    statResults = struct;
    
    % Create empty cell array as index explaining the fields of the statResults
    index = cell(2*length(categories),1);
    statResults.index = index;
    
    % Prepare regression formula excluding current moderator & interaction term
    stratifiedFormula = erase(formula, strcat('+',interactionTerm));
    stratifiedFormula = erase(stratifiedFormula, strcat('+',moderator));
    
    % Specify variable which tracks to which position in statResults index
    % description should be written to
    tracker = 1;
    
    % Loop over categories from moderator variable
    for idx = 1:length(categories)
        category = string(categories(idx));
    
        % Check if there are samples present for both states of the response
        % in the category
        % ToDo: In next step thresholds for minimum number of samples per
        % state of the response will be set
        categoryMetadata = metadata(categoriesIdx == find(categories == category), :);
        uniquesResponsesForCategory = unique(categoryMetadata.(response));
    
        % If samples are present for both states, run statistical analysis
        if length(uniquesResponsesForCategory) == 2
            % Stratify filteredData only including samples from current category
            categoryData = filteredData(categoriesIdx == find(categories == category), :);
    
            % Add description for runNonparametricTests for category to statResults index
            index{tracker} = strcat('Table1_', category, ': Two sided wilcoxon rank sum test results for ', category, ': ', response, ' ~ ', predictor);
            statResults.index = index;
    
            % Increase tracker that it will use the next available empty
            % index row for next entry
            tracker = tracker + 1;
    
            % Investigate response differences for the categoryData
            statResults.(strcat('Table1_', category)) =  runNonparametricTests(categoryData, metadata, predictor, response);
            
            % Renormalize categoryData
            categoryData{:,2:end} = normalize(table2array(categoryData(:,2:end)));
    
            % Perform regression on category stratified data using formula excluding 
            % current moderator & interaction term
            results = performRegressions(categoryData, metadata, stratifiedFormula);
    
            % If optimal regression solution could be found, save the table with predictor
            if ~contains(fieldnames(results), 'NotDefined')
                % Add description for regression for category to statResults index
                index{tracker} = strcat('Table2_', category, ': Outcomes from regression model for ', category, ': ', stratifiedFormula);
                statResults.index = index;
    
                % Increase tracker that it will use the next available empty
                % index row for next entry
                tracker = tracker + 1;
    
                statResults.(strcat('Table2_', category)) = results.(predictor);
            else
                disp('Iteration limit for regression reached - no optimal solution could be found.')
            end
        else
            disp(strcat(category, ' does not contain samples for both response groups, therefore no statistical analysis can be performed.'))
        end
        
    end
    
    % Save statResults for moderator variable in excel spreadsheet
    statResults.index = cell2table(index);
    sheetNames = string(fieldnames(statResults));
    spreadsheetName = strcat('statistical_results_', predictor, '_stratified', moderator, '.xlsx');
    
    resultPath = [saveDir filesep spreadsheetName];
    
    % Remove excel file if it already exists to prevent partial overwriting.
    if ~isempty(which(resultPath))
        delete(resultPath);
    end
    
    % Save statResults
    for i = 1:length(sheetNames)
        % Get sheet
        sheet = statResults.(sheetNames(i));
        % Write to table
        writetable(sheet,resultPath,'Sheet',sheetNames(i),'WriteRowNames',true,'PreserveFormat',true)
    end
% If filteredData contains only one column, meaning there are no
% significanty correlated metabolite fluxes/taxa rel.abundances, exit the function
else
    statResults = '';
end

end