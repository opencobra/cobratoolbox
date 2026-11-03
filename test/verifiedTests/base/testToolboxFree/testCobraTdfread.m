% The COBRAToolbox: testCobraTdfread.m
%
% Purpose:
%     - cobraTdfread is the plain-MATLAB replacement for tdfread (Statistics and Machine
%       Learning Toolbox). This test checks the syntax used by the call sites in src/
%       (s = tdfread(path) on tab-separated files such as the VMH reaction and metabolite
%       tables and the DEMETER tables; tdfread('name.tsv') resolved on the MATLAB path; the
%       num2str/strrep('NaN') processing of numeric columns in readInputTableForPipeline), the
%       numeric-or-char column rule (numbers parsed by str2double, never evaluated; empty
%       fields NaN), blank padding of char columns, field names (genvarname), delimiters,
%       line endings, empty lines versus lines of empty fields,
%       values against a hand-written parse in the reference script and against the shape of
%       the MathWorks documentation example, the errors, and (only where the toolbox is
%       installed) parity with tdfread on files without empty fields.
%
%       The test writes small text files to a temporary folder (the purpose of the function is
%       to read a file) and removes the folder when it finishes.
%
% Function under test:
%     src/base/utilities/toolboxFree/cobraTdfread.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261103-120403-toolbox-free-replacements, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCobraTdfread'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% temporary folder for the test files, removed when this workspace is cleared
tempFolder = tempname;
mkdir(tempFolder);
removeTempFolder = onCleanup(@() rmdir(tempFolder, 's'));
tab = char(9);
crlf = [char(13) char(10)];
lf = char(10);

% a VMH-like table: CRLF line ends, a quoted text field, an empty numeric field, NaN, an
% exponent, and a header with a space (the same text as TSV_TEXT in
% specs/20261103-120403-toolbox-free-replacements/references/multivariate.py)
vmhLikeText = ['abbreviation' tab 'charge' tab 'description' tab 'my value' tab 'avgWeight' crlf ...
    'h2o' tab '0' tab 'Water' tab '1.5e2' tab '18.015' crlf ...
    'atp' tab '-4' tab '"Adenosine triphosphate"' tab '' tab '507.18' crlf ...
    'glc_D' tab '0' tab 'D-Glucose' tab 'NaN' tab '180.16' crlf];
vmhLikeFile = fullfile(tempFolder, 'vmhLike.tsv');
writeTextFile(vmhLikeFile, vmhLikeText);
% a table of the shape of the MathWorks documentation example (sat2.dat, comma-delimited,
% "Test,Gender,Score" with first row "Verbal,Male,470"; the doc lists Gender 4x6 char,
% Score 4x1 double, Test 4x12 char)
satText = ['Test,Gender,Score' lf 'Verbal,Male,470' lf 'Verbal,Female,530' lf ...
    'Quantitative,Male,520' lf 'Quantitative,Female,480' lf];
satFile = fullfile(tempFolder, 'sat2.dat');
writeTextFile(satFile, satText);

%% call-site syntax s = tdfread(path) on a VMH-like tab-separated file

% reference: hand-written parse in multivariate.py:
%   'abbreviation': char 3x5 ['h2o  ', 'atp  ', 'glc_D']
%   'charge': double [0.0, -4.0, 0.0]
%   'description': char 3x24 ['Water ...', '"Adenosine triphosphate"', 'D-Glucose ...']
%   'my value': double [150.0, nan, nan]
%   'avgWeight': double [18.015, 507.18, 180.16]
% numbers are converted by str2double, which rounds the decimal text correctly, so the values
% equal the MATLAB literals exactly
s = cobraTdfread(vmhLikeFile);
assert(isequal(fieldnames(s), {'abbreviation'; 'charge'; 'description'; 'myValue'; 'avgWeight'}));
assert(ischar(s.abbreviation) && isequal(s.abbreviation, ['h2o  '; 'atp  '; 'glc_D']));
assert(isa(s.charge, 'double') && isequal(s.charge, [0; -4; 0]));
assert(isequal(size(s.description), [3 24]) && isequal(s.description(2, :), '"Adenosine triphosphate"'));
assert(isequal(s.description(1, :), ['Water' blanks(19)]));
assert(isequaln(s.myValue, [150; NaN; NaN]));
assert(isequal(s.avgWeight, [18.015; 507.18; 180.16]));
% string file name
assert(isequaln(cobraTdfread(string(vmhLikeFile)), s));

%% call-site processing of readInputTableForPipeline and producetSNEPlots

% numeric columns go through num2str and the 'NaN' text is removed, so an empty field comes
% back as an empty cell; char columns go through cellstr, which removes the padding
s = cobraTdfread(vmhLikeFile);
formattedColumn = cellstr(num2str(s.myValue));
formattedColumn = strrep(formattedColumn, ' NaN', '');
formattedColumn = strrep(formattedColumn, 'NaN', '');
assert(isequal(formattedColumn, {'150'; ''; ''}));
assert(isequal(cellstr(s.abbreviation), {'h2o'; 'atp'; 'glc_D'}));

%% call-site syntax tdfread('VMH_Reactions.tsv'): a bare file name found on the MATLAB path

fullPathResult = cobraTdfread(vmhLikeFile);
addpath(tempFolder);
removeFromPath = onCleanup(@() rmpath(tempFolder));
cd(currentDir);
assert(isequaln(cobraTdfread('vmhLike.tsv'), fullPathResult));
cd(fileDir);
clear removeFromPath

%% the VMH tables used by annotateModel (only where the papers submodule is present)

vmhFolder = fullfile(fileparts(which('initCobraToolbox')), 'papers', '2020_WholeBodyModelling', 'Data', 'Recon3D_star');
if exist(fullfile(vmhFolder, 'VMH_Reactions.tsv'), 'file') == 2
    % annotateModel uses these fields as char rows (cellstr, strtok, regexprep of quotes)
    reactions = cobraTdfread(fullfile(vmhFolder, 'VMH_Reactions.tsv'));
    for field = {'abbreviation', 'description', 'subsystem', 'ecnumber', 'keggId', 'seed', 'metanetx'}
        assert(ischar(reactions.(field{1})) && size(reactions.(field{1}), 1) == 19314);
    end
    assert(strcmp(cellstr(reactions.abbreviation(1, :)), '10FTHF5GLUtl'));
    assert(strcmp(cellstr(reactions.subsystem(1, :)), '"Transport, lysosomal"'));
    metabolites = cobraTdfread(fullfile(vmhFolder, 'VMH_Metabolites.tsv'));
    assert(ischar(metabolites.abbreviation) && size(metabolites.abbreviation, 1) == 8585);
    assert(strcmp(cellstr(metabolites.abbreviation(1, :)), '10dacb'));
else
    fprintf('skipped: papers/2020_WholeBodyModelling VMH tables not present\n');
end

%% MathWorks documentation example shape: tdfread('sat2.dat', ',')

s = cobraTdfread(satFile, ',');
assert(isequal(fieldnames(s), {'Test'; 'Gender'; 'Score'}));
assert(ischar(s.Gender) && isequal(size(s.Gender), [4 6]));
assert(isa(s.Score, 'double') && isequal(size(s.Score), [4 1]) && s.Score(1) == 470);
assert(ischar(s.Test) && isequal(size(s.Test), [4 12]) && isequal(s.Test(1, :), ['Verbal' blanks(6)]));

%% delimiters: names and characters

expected = cobraTdfread(satFile, ',');
delimiterCases = {{'comma', ','}, {'tab', tab}, {'\t', tab}, {tab, tab}, {'semi', ';'}, {';', ';'}, ...
    {'bar', '|'}, {'|', '|'}, {'space', ' '}, {' ', ' '}};
for k = 1:numel(delimiterCases)
    delimitedFile = fullfile(tempFolder, sprintf('delimited%d.txt', k));
    writeTextFile(delimitedFile, strrep(satText, ',', delimiterCases{k}{2}));
    assert(isequal(cobraTdfread(delimitedFile, delimiterCases{k}{1}), expected));
end
% the default delimiter is tab; an empty delimiter is the default
writeTextFile(fullfile(tempFolder, 'tabbed.txt'), strrep(satText, ',', tab));
assert(isequal(cobraTdfread(fullfile(tempFolder, 'tabbed.txt')), expected));
assert(isequal(cobraTdfread(fullfile(tempFolder, 'tabbed.txt'), []), expected));
assert(isequal(cobraTdfread(fullfile(tempFolder, 'tabbed.txt'), "TAB"), expected));

%% line endings, blank lines, a missing final newline and a byte-order mark

expected = cobraTdfread(satFile, ',');
variants = {strrep(satText, lf, crlf), strrep(satText, lf, char(13)), ...
    [lf satText lf lf], satText(1:end - 1), [char(65279) satText], strrep(satText, lf, [lf '   ' lf])};
for k = 1:numel(variants)
    variantFile = fullfile(tempFolder, sprintf('variant%d.csv', k));
    writeTextFile(variantFile, variants{k});
    assert(isequal(cobraTdfread(variantFile, ','), expected));
end

%% numeric columns: numbers only (str2double, no evaluation), empty fields NaN

numericText = ['plain' tab 'signs' tab 'special' tab 'comma' tab 'expression' tab 'empty' tab 'spaced' lf ...
    '1' tab '+.5' tab 'Inf' tab '1,000' tab 'pi' tab '' tab ' 12 ' lf ...
    '2' tab '-3.' tab '-inf' tab '2' tab '1+2' tab '' tab '7' lf ...
    '3' tab '1E-3' tab 'nan' tab '3' tab '4' tab '' tab '' lf];
numericFile = fullfile(tempFolder, 'numeric.tsv');
writeTextFile(numericFile, numericText);
s = cobraTdfread(numericFile);
assert(isequal(s.plain, [1; 2; 3]) && isequal(s.signs, [0.5; -3; 1e-3]));
assert(isequaln(s.special, [Inf; -Inf; NaN]) && isequaln(s.spaced, [12; 7; NaN]));
% '1,000' and 'pi', '1+2' are text: the columns are char (str2num would have evaluated them)
assert(ischar(s.comma) && isequal(s.comma, ['1,000'; '2    '; '3    ']));
assert(ischar(s.expression) && isequal(cellstr(s.expression), {'pi'; '1+2'; '4'}));
% a column whose fields are all empty is a blank char matrix with one row per line
assert(ischar(s.empty) && isequal(size(s.empty), [3 0]));

%% field names: genvarname of the trimmed header (valid and unique)

% genvarname (used by tdfread of about R2012): blanks removed with the next letter capitalized,
% a leading digit prefixed by 'x', other characters hex-encoded ('-' -> '0x2D'), repeats
% numbered ('A', 'A1')
namesText = ['1st col' tab 'a-b' tab 'a-b' tab ' padded ' tab 'A' tab 'A' lf 'x' tab 'y' tab 'z' tab 'w' tab 'u' tab 'v' lf];
namesFile = fullfile(tempFolder, 'names.tsv');
writeTextFile(namesFile, namesText);
s = cobraTdfread(namesFile);
assert(isequal(fieldnames(s), {'x1stCol'; 'a0x2Db'; 'a0x2Db1'; 'padded'; 'A'; 'A1'}));

%% a data line made only of delimiters is a row of empty fields; empty lines are skipped

emptyRowFile = fullfile(tempFolder, 'emptyRow.tsv');
writeTextFile(emptyRowFile, ['name' tab 'value' lf tab lf 'atp' tab '2' lf lf]);
s = cobraTdfread(emptyRowFile);
assert(isequal(s.name, ['   '; 'atp']) && isequaln(s.value, [NaN; 2]));
% a line of spaces is skipped for a tab delimiter, but is a row of empty fields for a space
% delimiter
writeTextFile(emptyRowFile, ['name' tab 'value' lf '   ' lf 'atp' tab '2' lf]);
s = cobraTdfread(emptyRowFile);
assert(isequal(s.name, 'atp') && isequal(s.value, 2));
writeTextFile(emptyRowFile, ['name value' lf ' ' lf 'atp 2' lf]);
s = cobraTdfread(emptyRowFile, 'space');
assert(isequal(s.name, ['   '; 'atp']) && isequaln(s.value, [NaN; 2]));
% in a one-column file an empty entry is an empty line, so it is skipped
oneColumnFile = fullfile(tempFolder, 'oneColumn.tsv');
writeTextFile(oneColumnFile, ['value' lf '1' lf lf '3' lf]);
s = cobraTdfread(oneColumnFile);
assert(isequal(s.value, [1; 3]));
writeTextFile(oneColumnFile, ['name' crlf 'h2o' crlf crlf 'glc_D' crlf]);
s = cobraTdfread(oneColumnFile);
assert(isequal(s.name, ['h2o  '; 'glc_D']));

%% a header without data lines: empty char fields

headerFile = fullfile(tempFolder, 'header.tsv');
writeTextFile(headerFile, ['first' tab 'second' crlf]);
s = cobraTdfread(headerFile);
assert(isequal(fieldnames(s), {'first'; 'second'}) && ischar(s.first) && isempty(s.first));

%% errors: unequal field counts, missing or empty file, unsupported delimiter and options

badFile = fullfile(tempFolder, 'bad.tsv');
writeTextFile(badFile, ['a' tab 'b' lf '1' tab '2' lf '3' lf]);
assert(verifyCobraFunctionError('cobraTdfread', 'inputs', {badFile}, ...
    'testMessage', 'cobraTdfread: line 3 has 1 fields but the header has 2.'));
missingFile = fullfile(tempFolder, 'missing.tsv');
assert(verifyCobraFunctionError('cobraTdfread', 'inputs', {missingFile}, ...
    'testMessage', sprintf('cobraTdfread: cannot open the file ''%s''.', missingFile)));
emptyFile = fullfile(tempFolder, 'empty.tsv');
writeTextFile(emptyFile, [lf lf]);
assert(verifyCobraFunctionError('cobraTdfread', 'inputs', {emptyFile}, ...
    'testMessage', sprintf('cobraTdfread: the file ''%s'' has no header line.', emptyFile)));
assert(verifyCobraFunctionError('cobraTdfread', ...
    'testMessage', 'cobraTdfread: a file name is required (the file selection dialog is not supported).'));
assert(verifyCobraFunctionError('cobraTdfread', 'inputs', {42}, ...
    'testMessage', 'cobraTdfread: the file name must be a character vector or string scalar.'));
assert(verifyCobraFunctionError('cobraTdfread', 'inputs', {satFile, ':'}, ...
    'testMessage', 'cobraTdfread: unsupported delimiter '':'' (supported: ''\t''/''tab'', '' ''/''space'', '',''/''comma'', '';''/''semi'', ''|''/''bar'').'));
assert(verifyCobraFunctionError('cobraTdfread', 'inputs', {satFile, 9}, ...
    'testMessage', 'cobraTdfread: unsupported delimiter of class ''double''.'));
assert(verifyCobraFunctionError('cobraTdfread', 'inputs', {satFile, ',', 'ReadVariableNames'}, ...
    'testMessage', 'cobraTdfread: unsupported option ''ReadVariableNames'' (only a file name and a delimiter are supported).'));
assert(verifyCobraFunctionError('cobraTdfread', 'inputs', {satFile, ',', 1}, ...
    'testMessage', 'cobraTdfread: unsupported option ''double'' (only a file name and a delimiter are supported).'));

%% parity with tdfread (only where the Statistics and Machine Learning Toolbox is installed)

if exist('tdfread', 'file') == 2 && license('test', 'Statistics_Toolbox')
    % files without empty fields or extra blanks, where the documented rules decide the result
    cleanFile = fullfile(tempFolder, 'clean.tsv');
    writeTextFile(cleanFile, ['abbreviation' tab 'charge' tab 'formula' tab 'weight' lf ...
        'h2o' tab '0' tab 'H2O' tab '18.015' lf 'atp' tab '-4' tab 'C10H12N5O13P3' tab '507.18' lf]);
    assert(isequal(cobraTdfread(cleanFile), tdfread(cleanFile)));
    assert(isequal(cobraTdfread(satFile, ','), tdfread(satFile, ',')));
    assert(isequal(cobraTdfread(satFile, 'comma'), tdfread(satFile, 'comma')));
    fprintf('parity with tdfread: passed\n');
else
    fprintf('skipped: Statistics and Machine Learning Toolbox not installed\n');
end

% remove the temporary folder and change the directory
clear removeTempFolder
cd(currentDir)

function writeTextFile(fileName, text)
% writes text to a file exactly as given (UTF-8, no added line end)
fileId = fopen(fileName, 'w', 'n', 'UTF-8');
fprintf(fileId, '%s', text);
fclose(fileId);
end
