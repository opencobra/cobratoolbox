% The COBRAToolbox: testSimilarity.m
%
% Purpose:
%     - testSimilarity tests the functionality of similarity in the 
%       rBioNet extension
%
% Function under test:
%     src/reconstruction/rBioNet/similarity.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver; the small rBioNet reaction database of the test
%     folder.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Stefania Magnusdottir April 2017
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSimilarity'));
cd(fileDir);

% this test needs no solver, MATLAB toolbox or particular operating system
prepareTest();

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

%% by default the progress is shown, and the result is the same

% the fifth reaction of the database is ENO, the only one of the first ten with these metabolites
reactions = similarity('2pg[c] <=> h2o[c] + 2 pep[c]', rxn(1:10, 3));
assert(isequal(reactions, 5));
assert(isequal(similarity('2pg[c] <=> h2o[c] + 2 pep[c]', rxn(1:10, 3), 0), reactions));

% change the directory
cd(currentDir)
