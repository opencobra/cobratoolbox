function [listDuplicates] = check4DuplicatesInList(list)
% This function checks for duplicate entries in a list.
%
% INPUT
% list              List of e.g. metabolite abbr
%
% OUTPUT
% listDuplicates    List of duplicated entries. Second (or more) occurance
%                   of the duplicate is provided.
%
% Ines Thiele, 09/2021

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
