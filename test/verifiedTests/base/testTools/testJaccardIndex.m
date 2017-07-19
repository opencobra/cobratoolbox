% The COBRAToolbox: testJaccardIndex.m
%
% Purpose:
%     - Tests the JaccardIndex function
%
% Author:
%     - Original file: Laurent Heirendt
%     - CI integration: Laurent Heirendt

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testJaccardIndex'));
cd(fileDir);

% define the test vectors
testVect1 = [0; -1; -2; -3; -4; -5; -6];
testVect2 = - testVect1;
testVect3 = [-2; 0; -2; 0; -2; 0; -2];
testVect4 = - testVect3;

% all similar flux ranges
J_test1 = fvaJaccardIndex([testVect1, testVect1], [testVect2, testVect2]);

for i = 1:length(J_test1)
    assert(J_test1(i) == 1);
end

% partial similar flux ranges
J_test2 = fvaJaccardIndex([testVect1, testVect3], [testVect2, testVect4]);

assert(J_test2(3) == 1.0);
assert(J_test2(5) == 1.0/2.0);
assert(J_test2(7) == 1.0/3.0);

% no similar flux ranges
J_test3 = fvaJaccardIndex([testVect1, testVect3], [testVect1, testVect4]);

for i = 1:length(J_test3)
    assert(J_test3(i) == 0);
end

% test if flux vectors of only 1 model are input
try
    J = fvaJaccardIndex(testVect3, testVect4);
catch ME
    assert(length(ME.message) > 0)
end

% test if flux vectors of only 1 model are input
try
    J = fvaJaccardIndex([testVect1 testVect2], testVect4);
catch ME
    assert(length(ME.message) > 0)
end

% change the directory
cd(currentDir)
