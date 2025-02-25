function [metIDs, suggestedMets] = getVMHID(mets, suggest)
% getVMHID - Retrieve metabolite IDs corresponding to the given metabolite names.
%
%
% Inputs:
%    mets - Cell array of metabolite names (strings) for which IDs are required.
%    suggest - Flag indicating whether to generate suggestions (1) or not (0).
%
% Outputs:
%    metIDs - Cell array of metabolite IDs corresponding to the input names.
%    suggestedMets - Cell array of possible matches for each unfound metabolite name.
%
% Example:
%    metaboliteNames = {'glucose', 'fructose'};
%    [metIDs, suggestedMets] = getVMHID(metaboliteNames, 1);
%
% Other requirements: COBRA toolbox installation and initialisation 
%
% Author: - Anna Sheehy - 16/07/2024

    % Load the VMH Database
    DB = loadVMHDatabase();
    
    % Initialize the output cell arrays for metabolite IDs and suggestions
    metIDs = cell(size(mets));
    n = length(mets);
    
    if suggest == 1
        % Initialize suggestions cell array if suggest flag is true
        suggestions = cell(700, n);
        suggestions(1, :) = mets;
    else
        % Initialize an empty suggestions cell array if suggest flag is false
        suggestions = cell(size(mets));
    end
    
    % Convert database metabolite names to lower case for case-insensitive comparison
    dbMetNames = lower(DB.metabolites(:, 2));
    
    % Initialize counters for found and unfound metabolites
    foundCount = 0;
    unfoundCount = 0;
    
    % Loop through each input metabolite name
    for i = 1:length(mets)
        % Convert input metabolite name to lower case for case-insensitive comparison
        metName = lower(mets{i});
        
        % Find the index of the metabolite name in the database
        index = find(strcmp(dbMetNames, metName), 1);
        
        % If the metabolite is found, retrieve its ID
        if ~isempty(index)
            metIDs{i} = DB.metabolites{index, 1};
            foundCount = foundCount + 1;
            
            % Set suggestedMets message if all metabolites are found and suggest is true
            if n == 1 && suggest == 1
               suggestedMets = 'All metabolites found'; 
            end
            
            % Clear column in suggestions if found
            if width(suggestions) == 1
                suggestedMets = 'All metabolites found'; 
            else
                suggestions(:, i) = [];
            end
            
        elseif suggest == 1
            % If not found and suggest flag is true, try to find partial matches
            partialMatches = find(contains(dbMetNames, metName));
            unfoundCount = unfoundCount + 1;
            
            % If partial matches are found, list them as suggestions
            if ~isempty(partialMatches)
                % Retrieve metabolite names from the database that partially match the input metabolite name
                ToOrder = DB.metabolites(partialMatches, 2);
                % Sort based on the length of each metabolite name in ascending order
                [~, sortIdx] = sort(cellfun(@length, ToOrder));
                ToOrder = ToOrder(sortIdx);
                % Determine the number of suggestions and update the suggestions array
                k = length(partialMatches) + 1; 
                suggestions(2:k, i) = ToOrder;   
            else
                suggestions{i} = [];
            end
            
            % Assign an empty array for the unfound metabolite ID
            metIDs{i} = [];
        end
    end
    
    % Display the number of found and unfound metabolites
    fprintf('Number of found metabolites: %d\n', foundCount);
    fprintf('Number of unfound metabolites: %d\n', unfoundCount);
    
    % Set suggestedMets to suggestions if it does not exist
    if ~exist('suggestedMets', 'var')
        suggestedMets = suggestions;
        emptyRows = all(cellfun(@isempty, suggestedMets), 2);
        suggestedMets(emptyRows, :) = [];
    end


     
end


