% The COBRAToolbox: testBiomassPrecursorCheck.m
%
% Purpose:
%    - This script aims to test testBiomassPrecursorCheck.m
%
% Authors:
%    - Siu Hung Joshua Chan June 2018
%
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testBiomassPrecursorCheck'));
cd(fileDir);

model = readCbModel('iJO1366.mat');
[missingMets, presentMets] = biomassPrecursorCheck(model);

% change the directory
cd(currentDir)
