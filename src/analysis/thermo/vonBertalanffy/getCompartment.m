function [compartments, uniqueCompartments, abbr, uniqueAbbr] = getCompartment(mets)
% Gets the compartment for each metabolite, and the unique compartments,
% from metabolite abbreviation(s), each of which must have compartment
% symbol concatenated on the right hand side (i.e. `metAbbr[*]`), or
% using the underscore format (e.g., `metAbbr_x`).
%
% USAGE:
%
%    [compartments, uniqueCompartments, abbr, uniqueAbbr] = getCompartment(mets)
%
% INPUT:
%    mets:                  char array with a single metabolite abbreviation
%                           or 
%                           `m x 1` cell array of metabolite abbreviations 
%                           
% OUTPUTS:
%    compartments:          char array with a single compartment identifier
%                           or 
%                           `m x 1` cell array of compartment identifiers
%
%    uniqueCompartments:    char array with a single compartment identifier
%                           or
%                           cell array of unique compartment identifiers
%    abbr:                  char array with a single metabolite
%                           abbreviation, without compartment
%                           or 
%                           `m x 1` cell array of metabolite abbreviations,
%                           without compartments 
%    uniqueAbbr:            unique cell array of metabolite abbrviations
%                           without compartment
%
% .. Author:
%       - Ronan M.T. Fleming
%       - Hulda SH, Nov. 2012   Switched from for loop to regular expression
%       - Farid Zare, 2024/08/15  Updated to handle underscore compartment notation

bool = 0;
if ischar(mets)
    tmp{1} = mets;
    mets = tmp;
    bool = 1;
end

% Initialize outputs
compartments = cell(size(mets));
abbr = cell(size(mets));

% Regular expression pattern for `metAbbr[*]` format
pat_brackets = '(?<abbr>[^\[]+)\[(?<compartment>[^\]]+)\]';

% Loop through each metabolite to handle both formats
for i = 1:length(mets)
    met = mets{i};
    
    % Check if it matches the bracket format
    if contains(met, '[') && contains(met, ']')
        metStruct = regexp(met, pat_brackets, 'names');
        abbr{i} = metStruct.abbr;
        compartments{i} = metStruct.compartment;
    else
        % Handle underscore format `metAbbr_x`
        pat_underscore = '(?<abbr>.+)_(?<compartment>[a-zA-Z])$';
        metStruct = regexp(met, pat_underscore, 'names');
        
        if ~isempty(metStruct)
            abbr{i} = metStruct.abbr;
            compartments{i} = metStruct.compartment;
        else
            % If it doesn't match either format, leave it unchanged
            abbr{i} = met;
            compartments{i} = '';
        end
    end
end

% Convert to column cell arrays
compartments = reshape(compartments, length(compartments), 1);
abbr = reshape(abbr, length(abbr), 1);
uniqueCompartments = unique(compartments);
uniqueAbbr = unique(abbr);

% Handle single string input case
if bool == 1
    compartments = compartments{1};
    uniqueCompartments = uniqueCompartments{1};
    abbr = abbr{1};
    uniqueAbbr = uniqueAbbr{1};
end
