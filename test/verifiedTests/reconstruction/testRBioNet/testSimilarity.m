% The COBRAToolbox: testSimilarity.m
%
% Purpose:
%     - testSimilarity tests the functionality of similarity in the 
%       rBioNet extension
%
% Authors:
%     - Stefania Magnusdottir April 2017
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSimilarity'));
cd(fileDir);

% load rBioNet reaction database
load([fileDir, filesep 'rxn.mat'])

% find similar reactions, only checks metabolites
reactions = similarity('2pg[c] <=> h2o[c] + 2 pep[c]', rxn(:, 3), 0);

% test that similar reactions are found
assert(~isempty(reactions))

% try to find reacitons similar to made-up reaction
reactions = similarity('2pg[c] <=> ac[c] + 2 met-L[c]', rxn(:, 3), 0);

% test that similar reactions are found
assert(isempty(reactions))

% change the directory
cd(currentDir)
