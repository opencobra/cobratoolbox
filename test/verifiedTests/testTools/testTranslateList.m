% The COBRAToolbox: testTranslateList.m
%
% Purpose:
%     - testTranslateList tests the functionality of translateList()
%       and checks solution against a known solution.
%
% Authors:
%     - Lemmer El Assal February 2017
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testTranslateList'));
cd(fileDir);

list = {'a', 'b', 'c'};
trList1 = {'b', 'c'};
trList2 = {'B', 'C'};
newList = translateList(list, trList1, trList2);
assert(isequal(newList,{'a', 'B', 'C'}))

% change the directory
cd(currentDir)
