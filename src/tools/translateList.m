function list = translateList(list, trList1, trList2)
% Translate a list of identifiers (either numerical or cell array) using a dictionary
%
% Usage:
%
%     list = translateList(list, trList1, trList2)
%
% Inputs:
%   list:
%   trList1:
%   trList2:
%
% Outputs:
%   list:
%
% Example:
%
% Define original list
%
% list = {'a', 'b', 'c'}
%
% Define dictionary
%
% trList1 = {'b', 'c'}
% trList2 = {'B', 'C'}
%
% newList = translateList(list, trList1, trList2);
%
% returns
%
% newList = {'a', 'B', 'C'};
%

[isInList, listInd] = ismember(list, trList1);

list(isInList) = trList2(listInd(listInd ~= 0));
