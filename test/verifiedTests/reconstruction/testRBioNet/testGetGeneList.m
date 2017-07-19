% The COBRAToolbox: testGetGeneList.m
%
% Purpose:
%     - testGetGeneList tests the functionality of getgenelist in the
%     rBioNet extension
%
% Authors:
%     - Stefania Magnusdottir April 2017
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetGeneList'));
cd(fileDir);

% load rBioNet reaction database
load([fileDir, filesep 'rxn.mat'])

% concatenate reaction names into one string
outstr = mets2str(rxn(1:3, 1));

% test that output is a string
assert(ischar(outstr))

% change the directory
cd(currentDir)
