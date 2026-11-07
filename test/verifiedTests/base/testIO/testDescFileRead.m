% The COBRAToolbox: testDescFileRead.m
%
% Purpose:
%     - descFileRead reads a tab-delimited text file into a structure with one field per column:
%       the field names are the headers of the first line (blanks replaced by '_') and each field
%       is a character array with one row per data line, as wide as the longest entry of the
%       column. Empty entries are kept. It replaces tdfread of the Statistics and Machine
%       Learning Toolbox, and the file is closed after reading.
%       Characterization test that PINS the current behaviour (feature
%       20261103-105830-tier2-safe-batch, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Reference values: the file read is COBRA_structure_fields.tab, the field definition file
%       shipped with the toolbox (src/base/io/definitions); the expected content is obtained
%       below by splitting the text of the same file at newlines and tabs. The size of the file
%       (15 columns, 82 data lines) was recorded from the first run on 2026-11-03 (no model, no
%       solver); it guards consistency with the shipped file, not independent correctness
%       (Tier 5). No file is created.
%
% Function under test:
%     src/base/io/definitions/descFileRead.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver; the input is a data file shipped with the
%     toolbox.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Short entries are padded with null characters, not blanks
%       SEVERITY: limitation
%       TRIGGER: a column whose entries have different lengths (any ordinary file)
%       OBSERVED: the rows of the character arrays are filled up with char(0); cellstr and
%         strtrim remove them, but the rows differ from the tdfread output the header promises
%       EXPECTED: rows padded with blanks, as tdfread returns them
%       LINES: 40
%     - DEFECT: An empty line ends the reading
%       SEVERITY: wrong-result
%       TRIGGER: a file with an empty line before its last data line
%       OBSERVED: the loop condition cline ~= -1 is empty for an empty line, so the reading stops
%         there and the following lines are dropped without a message
%       EXPECTED: every data line read (the empty line skipped or kept as an empty row)
%       LINES: 34
%
% Authors:
%     - Generated for feature 20261103-105830-tier2-safe-batch, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testDescFileRead'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the field definition file of the toolbox
fileName = which('COBRA_structure_fields.tab');
assert(~isempty(fileName));

% its content split at newlines and tabs, keeping empty entries; the file ends with a newline
fileLines = regexp(fileread(fileName), '\n', 'split');
assert(isempty(fileLines{end}));
fileLines(end) = [];
headers = strrep(strsplit(fileLines{1}, '\t', 'CollapseDelimiters', false), ' ', '_');
dataLines = cellfun(@(line) strsplit(line, '\t', 'CollapseDelimiters', false), fileLines(2:end), 'UniformOutput', false);
nRows = numel(dataLines);

% the open files, to check that the file is closed again
if exist('openedFiles') %#ok<EXIST> openedFiles replaces fopen('all') from R2024a
    getOpenFiles = @openedFiles;
else
    getOpenFiles = @() fopen('all');
end

%% one field per header, one row per data line

openFilesBefore = getOpenFiles();
raw = descFileRead(fileName);
assert(isequal(getOpenFiles(), openFilesBefore));

% the field names are the headers with blanks replaced by '_' (for example 'Model Field')
assert(isstruct(raw) && isscalar(raw));
assert(isequal(fieldnames(raw), headers'));
assert(any(strcmp(headers, 'Model_Field')) && any(strcmp(headers, 'referenced_Field')));

% Tier-5 size of the shipped file (first run, 2026-11-03): 15 columns and 82 data lines, every
% line has an entry (possibly empty) for every column
assert(numel(headers) == 15 && nRows == 82);
assert(all(cellfun(@numel, dataLines) == numel(headers)));

%% each field holds the entries of its column

raw = descFileRead(fileName);
for i = 1:numel(headers)
    column = cellfun(@(entries) entries{i}, dataLines, 'UniformOutput', false)';
    field = raw.(headers{i});
    % a character array with one row per data line, as wide as the longest entry
    assert(ischar(field));
    assert(isequal(size(field), [nRows, max(cellfun(@numel, column))]));
    % the entries, without the padding of the shorter rows (cellstr removes the trailing
    % blanks and null characters, so the trailing blanks of the expected entries are removed too)
    assert(isequal(cellstr(field), deblank(column)));
end

% examples: the first metabolite-sized field and an empty entry are kept in place
assert(strcmp(deblank(raw.Model_Field(1, :)), 'S'));
assert(strcmp(cellstr(raw.Model_Field(2, :)), 'mets'));
assert(any(cellfun(@isempty, cellstr(raw.databaseid))));

% change the directory
cd(currentDir)
