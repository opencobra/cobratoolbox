% The COBRAToolbox: testCorrectMetName.m
%
% Purpose:
%     - correctMetName replaces, in column 2 (species name) of parsed.r_info.species, the
%       names of the rows listed in column 8 of cmpM_results.listOfNotFound (the species row
%       numbers, as cmpMet writes them) by the names of listR, pairwise and in order; every
%       other entry and field is kept.
%     - Expected structures are derived by hand from the hand-built inputs.
%
% Function under test:
%     src/visualization/cellDesigner/correctMetName.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built parsed structure.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Debug output of the species row numbers
%       SEVERITY: cosmetic
%       TRIGGER: any call
%       OBSERVED: line 41 lacks a terminating semicolon, so r_listN is printed on every call
%       EXPECTED: no output
%       LINES: 41
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.
%     - Help text of correctMetName corrected to match the code (feature 20261120-151023-doc-matches-code), 2026-11-20.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCorrectMetName'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% a parsed CellDesigner structure (layout of parseCD: species id, name, -, -, line number)
parsed = struct();
parsed.re1.name = {'re1', 'HEX1'};
parsed.r_info.ID = {'re1', 're1', 'HEX1'};
parsed.r_info.species = {'s1', 'glc', [], [], '5'; ...
    's2', 'g6p', [], [], '7'; ...
    's3', 'f6p', [], [], '9'};
% cmpMet output: column 8 holds the row number of each species not found
cmpResults.listOfNotFound = cell(2, 8);
cmpResults.listOfNotFound(:, 8) = {3; 1};

%% the listed rows get the new names in column 2, in order; everything else is kept

updated = correctMetName(parsed, cmpResults, {'f6p_corrected'; 'glc_D'});
expectedSpecies = parsed.r_info.species;
expectedSpecies{3, 2} = 'f6p_corrected';
expectedSpecies{1, 2} = 'glc_D';
% only the species list changes; text entries are compared exactly
assert(isequal(updated.r_info.species, expectedSpecies));
assert(isequal(updated.r_info.ID, parsed.r_info.ID));
assert(isequal(updated.re1, parsed.re1));
assert(isequal(fieldnames(updated), fieldnames(parsed)));

%% a shorter listR corrects only the first listed rows

updated = correctMetName(parsed, cmpResults, {'f6p_corrected'});
expectedSpecies = parsed.r_info.species;
expectedSpecies{3, 2} = 'f6p_corrected';
assert(isequal(updated.r_info.species, expectedSpecies));

%% an empty listR leaves the structure unchanged

assert(isequal(correctMetName(parsed, cmpResults, {}), parsed));

% change the directory
cd(currentDir)
