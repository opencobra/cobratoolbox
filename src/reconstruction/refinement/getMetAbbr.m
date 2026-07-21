function [metAbbr, uniqueMetAbbrs] = getMetAbbr(mets)
% Gets the abbreviation for each metabolite, and the unique abbreviations,
% from metabolite abbreviation(s), each of which must have compartment
% symbol concatentated on the right hand side (i.e. `metAbbr[*]`).
%
% USAGE:
%
%    [metAbbr, uniqueMetAbbrs] = getMetAbbr(mets)
%
% INPUT:
%    mets:                  char array with a single metabolite abbreviation
%                           (with compartment, e.g. `metAbbr[c]`), or
%                           `m x 1` cell array of such metabolite abbreviations
%
% OUTPUTS:
%    metAbbr:               char array with a single metabolite abbreviation
%                           (compartment symbol removed), or
%                           `m x 1` cell array of metabolite abbreviations
%
%    uniqueMetAbbrs:        char array with a single metabolite abbreviation
%                           or
%                           cell array of unique metabolite abbreviations
%
% .. Author:
%       - Ronan M.T. Fleming

bool=0;
if ischar(mets)
    tmp{1}=mets;
    mets=tmp;
    bool=1;
end

pat = '(?<abbr>[^\[]+)\[(?<compartment>[^\]]+)\]';
metStruct = regexp(mets,pat,'names'); % m x 1 cell array with fields abbr and compartment in each cell
metStruct = [metStruct{:}]'; % Convert from cell array to double
metAbbr = {metStruct.abbr}; % Concatenate compartment fields
metAbbr = reshape(metAbbr,length(metAbbr),1);
uniqueMetAbbrs = unique(metAbbr);

if bool==1
    metAbbr = metAbbr{1};
    uniqueMetAbbrs = uniqueMetAbbrs{1};
end