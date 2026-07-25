function [listDuplicates] = check4DuplicatesInList(list)
% Checks for duplicate entries in a list
%
% USAGE:
%
%    [listDuplicates] = check4DuplicatesInList(list)
%
% INPUT:
%    list:              list of entries, e.g. metabolite abbreviations
%
% OUTPUT:
%    listDuplicates:    list of duplicated entries; the second (or later)
%                       occurrence of each duplicate is provided
%
% .. Author: - Ines Thiele, 09/2021

listDuplicates = [];
cnt = 1;
[D,IA,ID]= duplicates((list));
Di = find(IA);
if isempty(Di)
    fprintf('No duplicate metabolites exists.\n')
else
    for i = 1 : length(Di)
        fprintf([list{Di(i)} ' appears more than once.\n'])
        listDuplicates{cnt,1} = list{Di(i)};
        listDuplicates{cnt,2} = num2str(Di(i));
        cnt = cnt +1;
    end
end
