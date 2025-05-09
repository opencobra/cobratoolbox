function [output] = searcher(keyWords, database, varargin)
% Function that searches a database based on keywords with one of two
% search strategies
%
% Usage: 
%   [output] = searcher(keyWords, database, varargin)
% 
% Inputs:
%   keyWords:       Array of string that are to be used to search with
%   database:       Table of a database that has to be searched
% 
% Optional inputs:
%   searchType:     Method of searching keywords in the food database.
%                   Either iterative or cumulative. Defaults to iterative
%   notInclude:     Key words that exclude items. Defaults to an empty
%                   cell array.
% 
% Output:
%   output:         A cell array with the matches found in the database
% 
% Example:
%   [output] = searcher(keyWords, database, "searchType", 'cumulative')
% 
% .. Author - Bram Nap, 05-2024 

% Parse inputs
parser = inputParser();
parser.addRequired('keyWords', @iscell);
parser.addRequired('database', @iscell);
parser.addParameter('searchType', 'iterative',@ischar);
parser.addParameter('notInclude', {}, @iscell);

parser.parse(keyWords, database, varargin{:});

keyWords = parser.Results.keyWords;
database = parser.Results.database;
searchType = parser.Results.searchType;
notInclude = parser.Results.notInclude;

selectionSecondLast = {};
if strcmpi(searchType, 'iterative')
    for j = 1:size(keyWords,1)
        if j == 1
            % For the first key word, find all items in the database that
            % contain the key word
            selection = unique(database(contains(lower(database(:,1)), lower(keyWords(j))), 1));
        elseif j == size(keyWords,1) - 1
            % For subsequent keyword find the matches in the selection
            % created by the previous keywords. Store the selection of the
            % last keyword in case there are no matches from the new
            % keyword
            selectionSecondLast = selection(contains(lower(selection), lower(keyWords(j))));
            selection = selectionSecondLast;
        else
            % For the last keyword find the matches in the selection
            % created by the previous keyword
            selection = selection(contains(lower(selection), lower(keyWords(j))));
        end
    end
    
    % Remove the items that contain keywords that should not be included
    remove = false;
    if max(size(notInclude)) > 1
        remove = true;
    elseif ~isempty(cell2mat(notInclude)) 
        remove = true;
    end
    if remove
            for k = 1:size(notInclude,1)
                selection(contains(lower(selection), lower(notInclude(k)))) = [];
                selectionSecondLast(contains(lower(selectionSecondLast), lower(notInclude(k)))) = [];
            end
    end
    
    % Return the output
    if ~isempty(selection)
        output = selection;
    elseif ~isempty(selectionSecondLast)
        output = selectionSecondLast;
    else
        output = {};
    end

else
    % Initialise the storage variable
    queryItems = {'x'};
    for j = 1:size(keyWords,1)
        % For each keyword find the which items contain the keyword and
        % store them
        selection = unique(database{contains(lower(database.description), lower(keyWords(j))), 3});
        queryItems(end+1:end+size(selection,1),1) = selection;
    end
    
    % Count how often each item occurs for each keyword
    queryItems = queryItems(2:end, 1);
    [grouped,groupName] = groupcounts(queryItems);

    totGroup = [groupName, num2cell(grouped)];
    
    % Remove the items that contain keywords that should not be included
    if ~isempty(notInclude)
        for k = 1:size(notInclude)
            selection(contains(lower(totGroup(:,1)), lower(notInclude(k))),:) = [];
        end
    end
    
    % Give a bias to the first key word by adding +1 to all items found
    % witht that keyword
    firstKeyRes = unique(database{contains(lower(database.description), lower(keyWords(1))), 3});
    [~,~,idx] = intersect(firstKeyRes, totGroup(:,1));

    if ~isempty(idx)
        totGroup(idx,2) = num2cell(cell2mat(totGroup(idx,2))+1);
    end
    
    % Find all the suggestions that have occur in at least x-1 amount of
    % times, with x being the total amount of keywords. If that is empty
    % the suggestion occuring in at least x-2 are found. If the results is
    % also empty it is considered no matches are found
    if ~isempty(totGroup)
        if ~isempty(totGroup(cell2mat(totGroup(:,2)) >size(keyWords,1)-1,:))
            output = totGroup(cell2mat(totGroup(:,2)) >size(keyWords,1)-1,:);
        elseif ~isempty(totGroup(cell2mat(totGroup(:,2)) >size(keyWords,1)-2,:))
            output = totGroup(cell2mat(totGroup(:,2)) >size(keyWords,1)-2,:);
        else
            output = {};            
        end
    else
        output = {};
    end
end
if ~isempty(output)
    [~,~,idx] = intersect(output, database(:,1));
    output(:,2:3) = database(idx,2:3);
end