% The COBRAToolbox: testCountUnique.m
%
% Purpose:
%     - testCountUnique tests the functionality of countUnique()
%       and checks solution against a known solution.
%
% Authors:
%     - Lemmer El Assal February 2017
%

% define the path to The COBRAToolbox
pth = which('initCobraToolbox.m');
CBTDIR = pth(1:end-(length('initCobraToolbox.m') + 1));

initTest([CBTDIR, filesep, 'test', filesep, 'verifiedTests', filesep, 'testTools']);

ref_sortedCount = [2; 2; 2; 1; 1];
ref_sortedList = [1, 2, 4, 5, 6];

vec = [1, 2, 4, 5, 6, 1, 2, 4];
[sortedList, sortedCount] = countUnique(vec);

assert(isequal(ref_sortedList, sortedList));
assert(isequal(ref_sortedCount, sortedCount));

% change the directory
cd(CBTDIR)
