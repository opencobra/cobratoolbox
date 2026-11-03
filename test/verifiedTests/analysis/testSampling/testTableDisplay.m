% The COBRAToolbox: testTableDisplay.m
%
% Purpose:
%     - TableDisplay is a handle class that formats a table as text, one row at a time. The
%       constructor takes a structure with one field per column, either a printf format without
%       the leading % or a structure with the fields format, type, default, length and label;
%       the missing ones are derived (type 'string' for a format ending in s, else 'double';
%       default '' or NaN; length from the first digits of the format; label from the field
%       name). header returns the labels right-aligned in their widths and a dashed rule; print
%       returns one row, using the default for a missing value and cutting text to length - 1
%       characters.
%       Characterization test that PINS the current behaviour (feature
%       20261103-105830-tier2-safe-batch, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Reference values: the expected strings are built below with sprintf from the formats of
%       the columns (no first-run value is needed). Because of the first defect below, the
%       exact text between two columns is not asserted: only the formatted pieces, their
%       order, the dashed rule and the final newline are.
%
% Function under test:
%     src/analysis/sampling/BarrierRound/utils/TableDisplay.m
%     (other classes of the same name under external/ and papers/ come later on the path; the
%     test checks that this one is used)
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Line 57, the infinite length of a format without digits: it cannot be reached because
%     regexp with 'once' returns an empty character array, which ismissing does not flag (see the
%     second defect below). The infinite-length branch of header (lines 83-84) is reached with a
%     length of Inf given explicitly.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The blank that separates the columns is dropped
%       SEVERITY: wrong-result
%       TRIGGER: header() or print(data) of any table
%       OBSERVED: strcat removes the trailing blank of every piece, so the columns are joined
%         without a separator: the label line is one character per column boundary shorter than
%         its dashed rule (23 versus 25 characters for the widths 5, 8 and 10), and a value that
%         fills its width runs into the previous column
%       EXPECTED: one blank after every column, as counted by the dashed rule and assumed by the
%         cut of text values to length - 1 characters
%       LINES: 89, 115
%     - DEFECT: A format without a width gives a NaN length and header fails
%       SEVERITY: error
%       TRIGGER: a column whose format has no digits, for example 's' or 'g', then header()
%       OBSERVED: the column length is NaN, and header fails in repmat with 'Replication factors
%         must be a row vector of integers or integer scalars.'
%       EXPECTED: the length Inf, so that the label is printed with %s
%       LINES: 55-57, 93
%
% Authors:
%     - Generated for feature 20261103-105830-tier2-safe-batch, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testTableDisplay'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the class of the COBRA Toolbox source tree is the one used
classFile = which('TableDisplay');
assert(contains(classFile, fullfile('src', 'analysis', 'sampling', 'BarrierRound', 'utils')));

% a table with an integer column, a text column and a column given as a structure
columnFormat = struct('iter', '5i', 'name', '8s', 'val', struct('format', '10.3e', 'label', 'Value'));

%% constructor: the missing column properties are derived

tableDisplay = TableDisplay(columnFormat);

% the columns keep the order of the fields
assert(isequal(fieldnames(tableDisplay.format), {'iter'; 'name'; 'val'}));

% a format ending in s is text with default '', any other is a number with default NaN; the
% length is the first number in the format and the label is the field name unless given
% (isequaln because the default NaN is compared)
assert(isequaln(tableDisplay.format.iter, struct('format', '5i', 'type', 'double', 'default', NaN, 'length', 5, 'label', 'iter')));
assert(strcmp(tableDisplay.format.name.type, 'string') && strcmp(tableDisplay.format.name.default, ''));
assert(tableDisplay.format.name.length == 8 && strcmp(tableDisplay.format.name.label, 'name'));
assert(strcmp(tableDisplay.format.val.type, 'double') && isnan(tableDisplay.format.val.default));
assert(tableDisplay.format.val.length == 10 && strcmp(tableDisplay.format.val.label, 'Value'));

% a column given with every property is kept unchanged
fullColumn = struct('format', '6.2f', 'type', 'double', 'default', 7, 'length', 3, 'label', 'L');
tableDisplay = TableDisplay(struct('lab', fullColumn));
assert(isequal(tableDisplay.format.lab, fullColumn));

%% header: the labels right-aligned in their widths, then a dashed rule

tableDisplay = TableDisplay(columnFormat);
headerText = tableDisplay.header();
headerLines = strsplit(headerText, newline);

% three parts: the label line, the rule and the empty text after the final newline
assert(numel(headerLines) == 3 && isempty(headerLines{3}));
% the rule spans every column and one separator between two columns: 5 + 8 + 10 + 2
assert(isequal(headerLines{2}, repmat('-', 1, 25)));
% each label appears right-aligned in its width, in column order
labelStart = cellfun(@(label) strfind(headerLines{1}, label), ...
    {sprintf('%5s', 'iter'), sprintf('%8s', 'name'), sprintf('%10s', 'Value')});
assert(issorted(labelStart));

% a column with an explicit infinite length prints its label as is and adds its length to the rule
tableDisplay = TableDisplay(struct('id', '4i', 'note', struct('format', 's', 'length', Inf)));
headerLines = strsplit(tableDisplay.header(), newline);
assert(startsWith(headerLines{1}, sprintf('%4s', 'id')) && contains(headerLines{1}, 'note'));
assert(isequal(headerLines{2}, repmat('-', 1, 4 + 1 + 4 - 1)));

%% print: one row with the formatted values

tableDisplay = TableDisplay(columnFormat);
rowText = tableDisplay.print(struct('iter', 3, 'name', 'abc', 'val', pi));
assert(ischar(rowText) && endsWith(rowText, newline));
valueStart = cellfun(@(piece) strfind(rowText, piece), ...
    {sprintf('%5i', 3), sprintf('%8s', 'abc'), sprintf('%10.3e', pi)});
assert(issorted(valueStart));

% text longer than length - 1 characters is cut (char or string input)
rowText = tableDisplay.print(struct('iter', 3, 'name', 'abcdefghijk', 'val', pi));
assert(contains(rowText, sprintf('%8s', 'abcdefg')) && ~contains(rowText, 'abcdefgh'));
rowText = tableDisplay.print(struct('iter', 3, 'name', "abcdefghijk", 'val', pi));
assert(ischar(rowText) && contains(rowText, sprintf('%8s', 'abcdefg')) && ~contains(rowText, 'abcdefgh'));

% a missing value is printed with the default of its column (NaN for a number)
rowText = tableDisplay.print(struct('iter', 4));
assert(startsWith(rowText, sprintf('%5i', 4)) && contains(rowText, sprintf('%10.3e', NaN)));

% a text column of infinite length is never cut
tableDisplay = TableDisplay(struct('note', struct('format', 's', 'length', Inf)));
rowText = tableDisplay.print(struct('note', 'a long note'));
assert(startsWith(rowText, 'a long note') && endsWith(rowText, newline));

% change the directory
cd(currentDir)
