% The COBRAToolbox: testTranslateList.m
%
% Purpose:
%     - testTranslateList tests the functionality of translateList()
%       and checks solution against a known solution.
%
% Authors:
%     - Lemmer El Assal February 2017
%

% define the path to The COBRAToolbox
pth = which('initCobraToolbox.m');
CBTDIR = pth(1:end-(length('initCobraToolbox.m') + 1));

initTest([CBTDIR, filesep, 'test', filesep, 'verifiedTests', filesep, 'testTools']);

list = {'a', 'b', 'c'};
trList1 = {'b', 'c'};
trList2 = {'B', 'C'};
newList = translateList(list, trList1, trList2);
assert(isequal(newList,{'a', 'B', 'C'}))

% change the directory
cd(CBTDIR)
