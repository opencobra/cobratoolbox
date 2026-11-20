% The COBRAToolbox: testRBioNet_search.m
%
% Purpose:
%     - rBioNet_search returns the rows of an rBioNet table (a cell array, or the reaction or
%       metabolite database named by 'rxn' or 'met' and loaded through rBioNetSaveLoad) whose
%       entry in the given column matches the search phrase: exactly (exact = 1) or, otherwise,
%       as a case-insensitive regular expression (or an identical string). Empty entries are
%       skipped. Any other table shows an error message box and returns [].
%     - Expected rows are derived by hand from the hand-built tables; the databases of the
%       'rxn'/'met' branch are small .mat files and a settings file written by the test in a
%       temporary folder (pattern of testRBioNetSaveLoad).
%
% Function under test:
%     src/reconstruction/rBioNet/rBioNet_search.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built tables. The message box is opened and closed by
%     the test.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The default of exact is applied only when str is also missing
%       SEVERITY: limitation
%       TRIGGER: rBioNet_search(table, column, str) with three inputs
%       OBSERVED: (R2025a, 2026-11-15) the test is nargin < 3, so exact stays undefined and
%         rBioNet_search({'a', 'Urea'}, 2, 'Urea') stops at line 45 with 'Not enough input
%         arguments.' (all callers in the toolbox pass four inputs, as the USAGE line
%         documents)
%       EXPECTED: exact = 0 (partial match) when only exact is omitted
%       LINES: 24-26
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRBioNet_search'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% a metabolite-like table: abbreviation, name, formula; row 4 has an empty name
metTable = {'urea', 'Urea', 'CH4N2O'; ...
    'glc_D', 'D-Glucose', 'C6H12O6'; ...
    'gal', 'D-Galactose', 'C6H12O6'; ...
    'h', [], 'H'; ...
    'mix', 'a+b', 'C2'};

%% exact match: only identical entries, case-sensitive; empty entries are skipped

% the rows are copied unchanged from the table, so isequal is exact
assert(isequal(rBioNet_search(metTable, 2, 'Urea', 1), metTable(1, :)));
assert(isequal(rBioNet_search(metTable, 2, 'Urea', true), metTable(1, :)));
assert(isequal(rBioNet_search(metTable, 3, 'C6H12O6', 1), metTable(2:3, :)));
% a different case or a part of the entry does not match exactly: an empty 0x3 cell
noMatch = rBioNet_search(metTable, 2, 'urea', 1);
assert(iscell(noMatch) && isequal(size(noMatch), [0, 3]));
assert(isempty(rBioNet_search(metTable, 2, 'Gluc', 1)));

%% partial match: case-insensitive regular expression; empty entries are skipped

assert(isequal(rBioNet_search(metTable, 2, 'GLUC', 0), metTable(2, :)));
assert(isequal(rBioNet_search(metTable, 2, 'D-', 0), metTable(2:3, :)));
% the phrase is a regular expression: '^u' matches only the name that starts with u/U
assert(isequal(rBioNet_search(metTable, 2, '^u', 0), metTable(1, :)));
% 'a+b' as a pattern does not match the text 'a+b', the identical string still matches
assert(isequal(rBioNet_search(metTable, 2, 'a+b', 0), metTable(5, :)));
assert(isempty(rBioNet_search(metTable, 1, 'xyz', 0)));

%% the default of exact: reached only with two inputs, here on an empty table

% (line 25) with no row nothing is compared, so the missing phrase is never used
emptyResult = rBioNet_search(cell(0, 3), 2);
assert(isempty(emptyResult));

%% 'rxn' and 'met' load the databases named in rBioNetSettingsDB.mat

tmpDir = tempname;
mkdir(tmpDir);
cd(tmpDir);
rxnDB = {'HEX1', 'Hexokinase', 'atp[c] + glc_D[c] -> adp[c] + g6p[c] + h[c]'; ...
    'PGI', 'Glucose-6-phosphate isomerase', 'g6p[c] <=> f6p[c]'};
metDB = metTable;
compDB = {'c', 'cytosol'};
save('rxnDB.mat', 'rxnDB');
save('metDB.mat', 'metDB');
save('compDB.mat', 'compDB');
rxn_path = fullfile(tmpDir, 'rxnDB.mat');
met_path = fullfile(tmpDir, 'metDB.mat');
comp_path = fullfile(tmpDir, 'compDB.mat');
% the settings file in the current folder is found before any other one on the path
save('rBioNetSettingsDB.mat', 'rxn_path', 'met_path', 'comp_path');

assert(isequal(rBioNet_search('rxn', 1, 'PGI', 1), rxnDB(2, :)));
assert(isequal(rBioNet_search('rxn', 3, 'g6p', 0), rxnDB));
assert(isequal(rBioNet_search('met', 1, 'gal', 1), metDB(3, :)));

cd(fileDir);
rmdir(tmpDir, 's');

%% any other table shows an error message box and returns []

output = rBioNet_search('model', 1, 'x', 1);
assert(isequal(output, []));
assert(contains(closeMessageBoxes(), 'Variable table incorrect in rBioNet_search'));

% change the directory
cd(currentDir)

function boxText = closeMessageBoxes()
% Returns the text of the open message boxes and closes them, so that no window stays open.
boxes = findall(0, 'Type', 'figure', '-regexp', 'Tag', '^Msgbox_');
boxText = '';
for iBox = 1:numel(boxes)
    boxLines = cellstr(get(findall(boxes(iBox), 'Type', 'text'), 'String'));
    boxText = [boxText, ' ', strjoin(strtrim(boxLines), ' ')]; %#ok<AGROW>
end
delete(boxes);
end
