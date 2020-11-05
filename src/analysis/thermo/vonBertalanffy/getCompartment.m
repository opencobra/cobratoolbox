function [compartments, uniqueCompartments, abbr, uniqueAbbr] = getCompartment(mets)
% Gets the compartment for each metabolite, and the unique compartments,
% from metabolite abbreviation(s), each of which must have compartment
% symbol concatentated on the right hand side (i.e. `metAbbr[*]`).
%
% USAGE:
%
%    [compartments, uniqueCompartments] = getCompartment(mets)
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
%
% .. Author:
%       - Ronan M.T. Fleming
%       - Hulda SH, Nov. 2012   Switched from for loop to regular expression

bool=0;
if ischar(mets)
    tmp{1}=mets;
    mets=tmp;
    bool=1;
end

pat = '(?<abbr>[^\[]+)\[(?<compartment>[^\]]+)\]';
metStruct = regexp(mets,pat,'names'); % m x 1 cell array with fields abbr and compartment in each cell
metStruct = [metStruct{:}]'; % Convert from cell array to double
compartments = {metStruct.compartment}; % Concatenate compartment fields
compartments = reshape(compartments,length(compartments),1);
abbr = {metStruct.abbr}; % Concatenate compartment fields
abbr = reshape(abbr,length(abbr),1);
uniqueCompartments = unique(compartments);
uniqueAbbr = unique(abbr);

if bool==1
    compartments = compartments{1};
    uniqueCompartments = uniqueCompartments{1};
    abbr = abbr{1};
    uniqueAbbr = uniqueAbbr{1};
end