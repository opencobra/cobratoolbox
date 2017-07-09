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
fileDir = fileparts(which('testCalcGroupStats'));
cd(fileDir);

% load reference data - too complex to embed
load('refData_calcGroupStats.mat');

data = 6 * ones(5);
statname = {'mean', 'std', 'median', 'count'};
groups = {'test1', 'test2', 'test3', 'test4', 'test1'};

ref_groupCnt = [2; 1; 1; 1];

groupStat = zeros(size(ref_groupStat));
for i = 1:4
    [groupStat(:, :, i), groupList, groupCnt] = calcGroupStats(data, groups, statname{i}, ref_groupList, 1, 10);
    assert(isequal(ref_groupList, groupList));
    assert(isequal(ref_groupCnt, groupCnt));
end
assert(isequal(ref_groupStat, groupStat));

[groupStat, groupList, groupCnt] = calcGroupStats(data, groups);  % nargin < 3 sets statname to 'mean' and nRand to 1000
assert(isequal(ref_groupList, groupList));
assert(isequal(ref_groupCnt, groupCnt));
assert(isequal(ref_groupStat(:, :, 1), groupStat));

[groupStat, groupList, groupCnt] = calcGroupStats(data, groups, statname{1}, [], 1, 10);
assert(isequal(ref_groupList, groupList));
assert(isequal(ref_groupCnt, groupCnt));
assert(isequal(ref_groupStat(:, :, 1), groupStat));

ref_groupCnt = [0; 0; 0; 0];
[groupStat, groupList, groupCnt] = calcGroupStats(data, 'test', statname{1}, ref_groupList, 1, 10);
assert(isequal(ref_groupList, groupList));
assert(isequal(ref_groupCnt, groupCnt));
assert(any(any(isnan(groupStat))));
[groupStat, groupList, groupCnt] = calcGroupStats(data, 'test');  % nargin < 3 sets statname to 'mean' and nRand to 1000
assert(isequal({'test'}, groupList));
assert(isequal(1, groupCnt));
assert(isequal(6 * ones(1, 5), groupStat));
%additional test ot check zScore
[groupStat, groupList, groupCnt, zScore] = calcGroupStats(data, 'test', statname{1}, ref_groupList, 1, 10);
assert(isequal(zeros(4,5),zScore))
[groupStat, groupList, groupCnt, zScore] = calcGroupStats(data, groups, statname{4}, ref_groupList, 1, 10);
assert(isequal(ones(4,5),isnan(zScore)))
% change the directory
cd(currentDir)
