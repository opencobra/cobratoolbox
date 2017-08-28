% The COBRAToolbox: testSbmlTestModelToMat.m
%
% Purpose:
%     - test the sbmlTestModelToMat function
%
% Authors:
%     - Jacek Wachowiak
global CBTDIR
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSbmlTestModelToMat'));
cd(fileDir);

% test variables
CBTDIR = [];

% function outputs
sbmlTestModelToMat();

% test
assert(isequal(0, 0));

% change to old directory
cd(currentDir);
