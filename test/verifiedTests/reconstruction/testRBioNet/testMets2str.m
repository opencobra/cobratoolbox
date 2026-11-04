% The COBRAToolbox: testMets2str.m
%
% Purpose:
%     - testMets2str tests the functionality of mets2str in the
%     rBioNet extension
%
% Function under test:
%     src/reconstruction/rBioNet/mets2str.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
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
fileDir = fileparts(which('testMets2str'));
cd(fileDir);

% this test needs no solver, MATLAB toolbox or particular operating system
prepareTest();

% load rBioNet reaction database
load([fileDir, filesep 'rxn.mat'])

% concatenate cell array of strings into one string
outstr = mets2str(rxn(1:3, 1));

% test that output is a string
assert(ischar(outstr))

%% the names are joined in order, for a column and for a row

assert(strcmp(outstr, strjoin(rxn(1:3, 1)', ', ')));
assert(strcmp(mets2str({'act', 'acon-C', 'pep'}), 'act, acon-C, pep'));
assert(strcmp(mets2str({'act'}), 'act'));

% change the directory
cd(currentDir)
