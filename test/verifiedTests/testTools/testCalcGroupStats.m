% The COBRAToolbox: testCalcGroupStats.m
%
% Purpose:
%     - testCalcGroupStats tests the functionality of calcGroupStats()
%       and checks solution against a known solution.
%
% Authors:
%     - Lemmer El Assal February 2017
%

% save the current path
currentDir = pwd;

% initialize the test
initTest(fileparts(which(mfilename)));

% load reference data - too complex to embed
load('refData_calcGroupStats.mat');

data = 6 * ones(5);
statname = {'mean', 'std', 'median', 'count'};
groups = {'test1', 'test2', 'test3', 'test4', 'test1'};

ref_groupCnt = [2; 1; 1; 1];

for i = 1:4
    [groupStat(:,:,i), groupList, groupCnt] = calcGroupStats(data, groups, statname{i}, ref_groupList, 1, 10);
    assert(isequal(ref_groupList, groupList));
    assert(isequal(ref_groupCnt, groupCnt));
end

assert(isequal(ref_groupStat, groupStat))

% change the directory
cd(currentDir)
