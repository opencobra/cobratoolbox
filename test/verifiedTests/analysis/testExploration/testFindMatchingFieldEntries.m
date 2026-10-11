% The COBRAToolbox: testFindMatchingFieldEntries.m
%
% Purpose:
%     - findMatchingFieldEntries searches a list of strings (or ";"-separated annotations) for entries similar to a search string and returns the matches, their positions and similarities.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/exploration/findMatchingFieldEntries.m
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
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindMatchingFieldEntries'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% list of identifiers shared by the plain-field sections
fieldEntries = {'glucose'; 'glutamate'; 'gluc-6-p'; 'water'};

%% plain field, search string of 4 or more characters: similarity threshold

% 'glucose' matches itself exactly and 'gluc-6-p' with an edit distance of 3.1 (7 characters
% searched, so similarity = 1 - 3.1 / 7); 'glutamate' and 'water' are too different
[matchingIDs, positions, similarities] = findMatchingFieldEntries(fieldEntries, 'glucose', false, 0.5);
assert(isequal(matchingIDs, {'glucose'; 'gluc-6-p'}));
assert(isequal(positions, [1; 3]));
% similarity is a real number: tolerance 1e-9 covers floating-point rounding only
assert(abs(similarities(1) - 1) < 1e-9);
assert(abs(similarities(2) - (1 - 3.1 / 7)) < 1e-9);

% a stricter minimum similarity keeps only the exact match
[matchingIDs, positions, similarities] = findMatchingFieldEntries(fieldEntries, 'glucose', false, 0.99);
assert(isequal(matchingIDs, {'glucose'}));
assert(isequal(positions, 1));
assert(abs(similarities - 1) < 1e-9);

% nothing is similar enough -> empty outputs
[matchingIDs, positions, similarities] = findMatchingFieldEntries(fieldEntries, 'zzzzz', false, 0.9);
assert(isempty(matchingIDs) && isempty(positions) && isempty(similarities));

%% plain field, search string shorter than 4 characters: case-independent substring match

% 'WAT' is contained in 'water' (ignoring case); similarity still comes from the edit
% distance (value recorded from the current implementation, 4 decimals -> tolerance 1e-4)
[matchingIDs, positions, similarities] = findMatchingFieldEntries(fieldEntries, 'WAT', false, 0.5);
assert(isequal(matchingIDs, {'water'}));
assert(isequal(positions, 4));
assert(abs(similarities - 0.8833) < 1e-4);

%% annotation fields: entries are ';'-separated lists, the best annotation of each entry is used

annotationEntries = {'CHEBI:1;glucose'; 'water;h2o'; 'x;glucosa'};

% long search string: the best annotation per entry is compared with the threshold;
% 'glucosa' differs from 'glucose' by one substitution (distance 1 of 7)
[matchingIDs, positions, similarities] = findMatchingFieldEntries(annotationEntries, 'glucose', true, 0.7);
assert(isequal(matchingIDs, {'glucose'; 'glucosa'}));
assert(isequal(positions, [1; 3]));
assert(abs(similarities(1) - 1) < 1e-9);
assert(abs(similarities(2) - (1 - 1 / 7)) < 1e-9);

% short search string: substring match on the best annotation of each entry
[matchingIDs, positions, similarities] = findMatchingFieldEntries(annotationEntries, 'h2o', true, 0.7);
assert(isequal(matchingIDs, {'h2o'}));
assert(isequal(positions, 2));
assert(abs(similarities - 1) < 1e-9);

% change the directory
cd(currentDir)
