% The COBRAToolbox: testMergeTextDataAndData.m
%
% Purpose:
%     - mergeTextDataAndData puts the numbers read from a spreadsheet back into the text columns:
%     columns that are empty in the text part (after treating "NaN", "-", "#N/A" and "Not
%     calculated" as empty) take their values from the numeric data.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/io/utilities/mergeTextDataAndData.m
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
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMergeTextDataAndData'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% The function prints progress text; it is captured with evalc (Constitution VII-A) and the captured
% text uses the unique variable name printedText.

%% empty text columns take the numeric columns, in order

textData = {'name', 'v1', 'v2'; 'a', '', ''; 'b', '', ''};
printedText = evalc('merged = mergeTextDataAndData(textData, [1 2; 3 4]);');
assert(isequal(merged, {'name', 'v1', 'v2'; 'a', 1, 2; 'b', 3, 4}));
assert(contains(printedText, 'Assuming there were headings') && contains(printedText, 'Merging numerical data into column 2'));

%% placeholders for missing values count as empty

textData = {'name', 'v1', 'v2'; 'a', '#N/A', 'Not calculated'; 'b', 'NaN', '-'};
printedText = evalc('merged = mergeTextDataAndData(textData, [1 2; 3 4], 1);');
assert(isequal(merged, {'name', 'v1', 'v2'; 'a', 1, 2; 'b', 3, 4}));

%% a column that really has text keeps it; extra numeric columns are appended

textData = {'name', 'v1', []; 'a', 'x', 5; 'b', '', 6};
printedText = evalc('merged = mergeTextDataAndData(textData, [5; 6], 1);');
assert(isequal(merged(2:3, 1:2), {'a', 'x'; 'b', ''}));
assert(isequal(merged(2:3, 3), {5; 6}));

%% a text column between numeric columns: the numeric data keeps a (NaN) column for it

% (a spreadsheet read gives NaN in the numeric data for text columns after the first number column)
textData = {'name', 'v1', 'txt', 'v2'; 'a', '', 'x', ''; 'b', '', 'y', ''};
printedText = evalc('merged = mergeTextDataAndData(textData, [1 NaN 2; 3 NaN 4], 1);');
assert(isequal(merged, {'name', 'v1', 'txt', 'v2'; 'a', 1, 'x', 2; 'b', 3, 'y', 4}));

%% fewer data rows than text rows: the missing values are NaN

textData = {'name', 'v'; 'a', ''; 'b', ''; 'c', ''};
printedText = evalc('merged = mergeTextDataAndData(textData, [1; 2], 1);');
assert(isequal(merged(2:3, 2), {1; 2}) && isnan(merged{4, 2}));

%% a table without a heading row

textData = cell(2, 1);
textData(:) = {''};
printedText = evalc('merged = mergeTextDataAndData(textData, [1; 2], 0);');
assert(isequal(merged, {1; 2}));
assert(~contains(printedText, 'Assuming there were headings'));

% change the directory
cd(currentDir)
