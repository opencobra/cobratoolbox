% The COBRAToolbox: testColumnVector.m
%
% Purpose:
%     - Tests the columnVector function
% Author:
%     - Original file: Laurent Heirendt
%     - CI integration: Laurent Heirendt

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testColumnVector'));
cd(fileDir);

% define the vector vec
vec = [1, 2, 3, 4, 5, 6];

% transpose the original vector
vecT = columnVector(vec);

% save the transposed vector
vecT_default = vec';

% check if all the values are the same
for i = 1:length(vec)
    assert(vecT(i) == vecT_default(i));
end

% check if the size is flipped
assert(size(vecT, 1) == size(vec, 2))
assert(size(vecT, 2) == size(vec, 1))

% test if a vector is already a column vector
vec1 = columnVector(vecT_default);

% check if the same vector is returned
assert(size(vec1, 1) == size(vecT_default, 1))
assert(size(vec1, 2) == size(vecT_default, 2))

% check if all the values are the same
for i = 1:length(vec)
    assert(vec1(i) == vecT_default(i));
end

% check if the size is flipped
assert(size(vec1, 1) == size(vec, 2))
assert(size(vec1, 2) == size(vec, 1))

% change the directory
cd(currentDir)
