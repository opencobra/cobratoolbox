% The COBRAToolbox: testSearcher.m
%
% Purpose:
%     - searcher finds database entries whose names contain all key words (searched one after the other) and returns them with the other two database columns.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/wholeBody/Nutrition_Modelling_Toolbox/searcher.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Lines 90-133 of searcher.m (the whole else-branch for a searchType other than "iterative", from queryItems = {x} to the end of that branch) are uncovered because of the defect below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Non-iterative search type cannot run
%       SEVERITY: unusable-option
%       TRIGGER: searchType other than iterative
%       OBSERVED: the input parser requires database to be a cell array, but this branch reads
%         database.description, a property of tables, so every call errors
%       EXPECTED: a search that works with the database type the branch needs
%       LINES: 33, 90-133
%
% Authors:
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSearcher'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% database: name, a number, a label (the function returns columns 2 and 3 with the match)
database = {'Apple pie', 1, 'x'; 'Apple juice', 2, 'y'; 'Banana split', 3, 'z'; 'Apple pie green', 4, 'w'; 'Pear', 5, 'v'};

%% one key word: all names containing it (not case sensitive), sorted

result = searcher({'apple'}, database);
assert(isequal(result, {'Apple juice', 2, 'y'; 'Apple pie', 1, 'x'; 'Apple pie green', 4, 'w'}));

%% two key words: names containing both

result = searcher({'apple'; 'pie'}, database);
assert(isequal(result, {'Apple pie', 1, 'x'; 'Apple pie green', 4, 'w'}));

%% three key words: names containing all three

result = searcher({'apple'; 'pie'; 'green'}, database);
assert(isequal(result, {'Apple pie green', 4, 'w'}));

%% last key word matches nothing: the result of the previous (second-last) key word is returned

result = searcher({'apple'; 'pie'; 'zzz'}, database);
assert(isequal(result, {'Apple pie', 1, 'x'; 'Apple pie green', 4, 'w'}));

%% names to exclude

% one exclusion word
result = searcher({'apple'}, database, 'notInclude', {'juice'});
assert(isequal(result, {'Apple pie', 1, 'x'; 'Apple pie green', 4, 'w'}));
% several exclusion words
result = searcher({'apple'}, database, 'notInclude', {'juice'; 'green'});
assert(isequal(result, {'Apple pie', 1, 'x'}));

%% nothing found: an empty result

assert(isempty(searcher({'kiwi'}, database)));
assert(isempty(searcher({'apple'; 'zzz'}, database)));
assert(isempty(searcher({'zz'; 'pie'; 'green'}, database)));

%% invalid input types are rejected by the input parser

assert(verifyCobraFunctionError('searcher', 'inputs', {'apple', database}));

% change the directory
cd(currentDir)
