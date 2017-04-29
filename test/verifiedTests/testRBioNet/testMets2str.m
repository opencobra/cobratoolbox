% The COBRAToolbox: testMets2str.m
%
% Purpose:
%     - testMets2str tests the functionality of mets2str in the
%     rBioNet extension
%
% Authors:
%     - Stefania Magnusdottir April 2017
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMets2str'));
cd(fileDir);

% load rBioNet reaction database
load([fileDir, filesep 'rxn.mat'])

% concatenate cell array of strings into one string
outstr = mets2str(rxn(1:3, 1));

% test that output is a string
assert(ischar(outstr))

% change the directory
cd(currentDir)
