% The COBRAToolbox: testPrintInRecon3Dmap.m
%
% Purpose:
%     - tests the printInRecon3Dmap function using the Recon3D network
%
% Authors:
%     - German Preciat -- December 2019
%

global CBTDIR
fileName = 'Recon2.v05.mat';
model = readCbModel([CBTDIR filesep 'test' filesep 'models' filesep 'mat' filesep fileName]);

% save the current path
currentDir = pwd;

% initialize the test
cd(fileparts(which('testPrintInRecon3Dmap')));

% Load reference data
testMap = regexp( fileread('testMap.txt'), '\n', 'split')';

% Generate new data
printInRecon3Dmap(model.rxns);
fileName = 'C__fakepath_data4ReconMap3_1.txt';
newMap = regexp( fileread(fileName), '\n', 'split')';
if exist(fileName, 'file') == 2
    delete(fileName);
end

% Test the data
L = length(testMap{2})-1;
for i=1:length(testMap)
    if length(testMap{i}) > L
    	assert(isequal(testMap{i}(1:L), newMap{i}(1:L)))
    end
end
% change the directory
cd(currentDir)



 