% The COBRAToolbox: testPrintInRecon3Dmap.m
%
% Purpose:
%     - tests the printInRecon3Dmap function using the Recon3D network
%
% Authors:
%     - German Preciat -- December 2019
%

global CBTDIR
fileName = 'Recon2.v04.mat';
model = readCbModel([CBTDIR filesep 'test' filesep 'models' filesep 'mat' filesep fileName]);

% save the current path
currentDir = pwd;

% initialize the test
cd(fileparts(which('testPrintInRecon3Dmap')));

% Load reference data
testMap = regexp( fileread('testMap.txt'), '\n', 'split')';

% Generate new data
printInRecon3Dmap(findRxnsFromSubSystem(model, 'Citric acid cycle'));
newMap = regexp( fileread('C__fakepath_data4ReconMap3_1.txt'), '\n', 'split')';

% Test the data
assert(isequal(testMap, newMap), 'Reference map does not match.')

% change the directory
cd(currentDir)



