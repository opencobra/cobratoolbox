% The COBRAToolbox: testReadInputTableForPipeline.m
%
% Purpose:
%     - readInputTableForPipeline reads a table file (tab-delimited .txt, .tsv, or another
%       format that readtable reads, such as .csv) into a cell array whose first row holds
%       the column headers, as DEMETER expects. On MATLAB R2020a and newer, .txt and other
%       files are read with readtable (headers as written in the file, also when they are
%       not valid MATLAB names), and .tsv files with cobraTdfread (numeric columns are
%       converted to text and NaN to an empty text). This test writes small tables by hand
%       in a temporary folder and compares the cell arrays with the values written (hand
%       derivation).
%
% Function under test:
%     src/reconstruction/demeter/src/integration/readInputTableForPipeline.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-written text files in a temporary folder.
%
% Coverage exemptions:
%     Lines 30, 59, 60, 62: branches for MATLAB releases before R2020a (version-specific;
%     the test machines run R2020a or newer, where contains(version, '(R202') is true).
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testReadInputTableForPipeline'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

tmpDir = tempname;
mkdir(tmpDir);
writeText = @(name, text) writeTableFile(fullfile(tmpDir, name), text);

%% tab-delimited .txt file with valid MATLAB names as headers

writeText('valid.txt', sprintf('Name\tValue\na\t1\nb\t2\n'));
cellTable = readInputTableForPipeline(fullfile(tmpDir, 'valid.txt'));
% numbers stay numbers; text stays text
assert(isequal(cellTable, {'Name', 'Value'; 'a', 1; 'b', 2}));

%% tab-delimited .txt file with a header that is not a valid MATLAB name

% readtable changes the header to a valid name (and warns); the header as written in the
% file (kept by readtable in VariableDescriptions) is returned
writeText('spaces.txt', sprintf('Name\tValue\tother col\na\t1\tx\nb\t2\ty\n'));
cellTable = readInputTableForPipeline(fullfile(tmpDir, 'spaces.txt'));
assert(isequal(cellTable, {'Name', 'Value', 'other col'; 'a', 1, 'x'; 'b', 2, 'y'}));

%% a file in another format (.csv), with valid and with invalid header names

writeText('valid.csv', sprintf('Name,Value\na,1\nb,2\n'));
cellTable = readInputTableForPipeline(fullfile(tmpDir, 'valid.csv'));
assert(isequal(cellTable, {'Name', 'Value'; 'a', 1; 'b', 2}));
writeText('spaces.csv', sprintf('Name,my value\na,1\nb,2\n'));
cellTable = readInputTableForPipeline(fullfile(tmpDir, 'spaces.csv'));
assert(isequal(cellTable, {'Name', 'my value'; 'a', 1; 'b', 2}));

%% .tsv file: numeric columns become text, NaN becomes an empty text

writeText('mixed.tsv', sprintf('Name\tValue\tScore\na\t1\t1.5\nb\t2\t\nc\t10\t3\n'));
cellTable = readInputTableForPipeline(fullfile(tmpDir, 'mixed.tsv'));
assert(isequal(size(cellTable), [4 3]));
assert(isequal(cellTable(1, :), {'Name', 'Value', 'Score'}));
assert(isequal(cellTable(2:end, 1), {'a'; 'b'; 'c'}));
% every entry is text; the numbers are written by num2str, which pads them to a common width,
% so they are compared after strtrim
assert(iscellstr(cellTable));
assert(isequal(strtrim(cellTable(2:end, 2)), {'1'; '2'; '10'}));
% the empty Score of b is NaN in the file data and becomes an empty text
assert(isequal(strtrim(cellTable(2:end, 3)), {'1.5'; ''; '3'}));
assert(isempty(cellTable{3, 3}));

rmdir(tmpDir, 's');

% change the directory
cd(currentDir)

function writeTableFile(fileName, text)
% write a text file (helper of this test)
fid = fopen(fileName, 'w');
fprintf(fid, '%s', text);
fclose(fid);
end
