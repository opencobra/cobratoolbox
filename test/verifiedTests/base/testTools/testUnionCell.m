% The COBRAToolbox: testUnionCell.m
%
% Purpose:
%     - testUnionCell tests the functionality of unioncell()
%       and checks solution against a known solution.
%
% Authors:
%     - Lemmer El Assal February 2017
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testUnionCell'));
cd(fileDir);

load testUnionCell.mat;

A = {'String1', 'String2'};
B = {'String2', 'String1'};

AB{1} = unioncell(A, 1, B, 1);
AB{2} = unioncell(A, 1, B, 2);
AB{3} = unioncell(A, 2, B, 1);
AB{4} = unioncell(A, 2, B, 2);

assert(isequal(ref_AB, AB))

% change the directory
cd(currentDir)
