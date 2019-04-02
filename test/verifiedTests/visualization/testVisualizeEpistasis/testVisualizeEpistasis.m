% The COBRAToolbox: testVisualizePathwayInEpistasis.m
%
% Purpose:
%      - testConvertGene2PathwayInteractions tests the whether visualizePathwayInEpistasis
%      is working correctly
%
%  Author:
%      - Original file: Chintan J Joshi - 11/29/2018
%
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testVisualizeEpistasis'));
cd(fileDir);

% get the inputs
load('refData_visualizeEpistasis.mat', 'Nall','usys');

% get the outputs
load('refData_visualizeEpistasis.mat','np','pos','neg');

% list of solver packages: none needed

% run visualizePathwayInEpistasis
[np1,pos1,neg1] = visualizePathwayInEpistasis(Nall,10,usys);

fprintf('Testing visualization of epistasis as pathways...');
% check the first output
assert(sum(sum(np1~=np))==0);
% check the second output
assert(sum(sum(pos1~=pos))==0);
% check the third output
assert(sum(sum(neg1~=neg))==0);
fprintf('Done!\n');

% change the directory
cd(currentDir)
