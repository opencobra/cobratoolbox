function list = translateList(list,trList1,trList2)
%translateList Translate a list of identifiers (either numerical or cell
%array) using a dictionary
%
% list = translateList(list,trList1,trList2)
%
% Usage:
%
% Define original list
%
% list = {'a','b','c'}
%
% Define dictionary
%
% trList1 = {'b','c'} 
% trList2 = {'B','C'}
%
% newList = translateList(list,trList1,trList2);
% 
% returns
%
% newList = {'a','B','C'};
%
% Markus Herrgard 8/17/06

[isInList,listInd] = ismember(list,trList1);

list(isInList) = trList2(listInd(listInd ~= 0));
