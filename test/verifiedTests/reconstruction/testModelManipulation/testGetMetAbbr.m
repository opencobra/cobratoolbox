% The COBRAToolbox: testGetMetAbbr.m
%
% Purpose:
%     - Characterization test that PINS the current behaviour of getMetAbbr,
%       which strips the compartment suffix from COBRA metabolite IDs of the form
%       'abbreviation[compartment]' and also returns the unique abbreviations.
%       The function previously had no test (feature 025-tier1-test-pilot). It
%       asserts EXISTING behaviour (Constitution Principle III, characterization
%       mode) and must not change getMetAbbr.
%
% Function under test:
%     src/reconstruction/refinement/getMetAbbr.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built metabolite ID lists.
%     Never skipped.
%
% Coverage exemptions:
%     None. Every executable line of getMetAbbr is reached below.
%
% Authors:
%     - Generated for feature 025-tier1-test-pilot, 2026-10-06.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetMetAbbr'));
cd(fileDir);

%% a single metabolite ID given as a char vector

% char in -> char out, for BOTH outputs (the unique list of one entry is unwrapped)
[metAbbr, uniqueMetAbbrs] = getMetAbbr('atp[c]');
assert(ischar(metAbbr) && strcmp(metAbbr, 'atp'));
assert(ischar(uniqueMetAbbrs) && strcmp(uniqueMetAbbrs, 'atp'));

%% a cell array of metabolite IDs

% two compartments of atp and one adp: three abbreviations, two unique ones
metIDs = {'atp[c]'; 'adp[c]'; 'atp[m]'};
[metAbbr, uniqueMetAbbrs] = getMetAbbr(metIDs);

% abbreviations come back as a COLUMN cell array in the input order
assert(isequal(metAbbr, {'atp'; 'adp'; 'atp'}));
% the unique list is de-duplicated and sorted (as MATLAB's unique does), as a column
assert(isequal(uniqueMetAbbrs, {'adp'; 'atp'}));

% a row cell array is also accepted and still gives a column
metAbbrFromRow = getMetAbbr({'atp[c]', 'adp[c]'});
assert(isequal(metAbbrFromRow, {'atp'; 'adp'}));

%% a cell array with a single entry stays a cell (only char input is unwrapped)

[metAbbr, uniqueMetAbbrs] = getMetAbbr({'glc_D[e]'});
assert(iscell(metAbbr) && isequal(metAbbr, {'glc_D'}));
assert(iscell(uniqueMetAbbrs) && isequal(uniqueMetAbbrs, {'glc_D'}));

% change the directory
cd(currentDir)
