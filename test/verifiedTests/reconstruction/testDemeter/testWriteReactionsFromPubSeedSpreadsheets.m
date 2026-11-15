% The COBRAToolbox: testWriteReactionsFromPubSeedSpreadsheets.m
%
% Purpose:
%     - writeReactionsFromPubSeedSpreadsheets reads the PubSEED comparative-genomics
%       spreadsheets of a folder (one row per organism, one column per gene function) and
%       writes inputDataFolder/genomeAnnotation.txt: for each organism of the information
%       file (PubSEED name in column 2) and each annotated gene function, the VMH reactions
%       of that function (InReactions.txt) with the gene rule '<version>.<peg>.peg' (several
%       pegs joined by ' or ', '][' written as 'gap_filled'), plus a gap-filled exchange
%       reaction EX_<met>(e) for each extracellular metabolite of the reaction formula
%       (VMH database, loadVMHDatabase); repeated reactions of an organism are written once.
%     - The test writes the information file, InReactions.txt, a small VMH database and two
%       spreadsheets by hand in a temporary folder and runs the function from that folder,
%       where readtable finds these files before the ones on the path. The expected file is
%       derived by hand from the code (comments below).
%
% Function under test:
%     src/reconstruction/demeter/src/integration/writeReactionsFromPubSeedSpreadsheets.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-written text files in a temporary folder.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testWriteReactionsFromPubSeedSpreadsheets'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% loadVMHDatabase reads the globals additionalSecretionRxns and additionalUptakeRxns:
% save them and remember the globals that existed before the test
globalsBefore = who('global');
global additionalSecretionRxns additionalUptakeRxns
savedSecretion = additionalSecretionRxns;
savedUptake = additionalUptakeRxns;
additionalSecretionRxns = [];
additionalUptakeRxns = [];

% the sandbox: input files, two spreadsheets, an empty spreadsheet folder, the output folder
sandboxDir = tempname;
mkdir(sandboxDir);
spreadsheetDir = fullfile(sandboxDir, 'spreadsheets');
emptySpreadsheetDir = fullfile(sandboxDir, 'noSpreadsheets');
outputDir = fullfile(sandboxDir, 'inputData');
mkdir(spreadsheetDir);
mkdir(emptySpreadsheetDir);
mkdir(outputDir);
tab = sprintf('\t');
writeLines = @(path, lines) writeTextLines(path, lines);

% information files: model ID, PubSEED name, annotation version (numbers in the first file,
% text in the second)
writeLines(fullfile(sandboxDir, 'infoNumeric.txt'), {['MicrobeID' tab 'PubSeedID' tab 'Annotation version ID'], ...
    ['orgA' tab 'Org A (1.1)' tab '1.1'], ['orgB' tab 'Org B (2.2)' tab '2.2']});
writeLines(fullfile(sandboxDir, 'infoText.txt'), {['MicrobeID' tab 'PubSeedID' tab 'Annotation version ID'], ...
    ['orgA' tab 'Org A (1.1)' tab 'v1'], ['orgB' tab 'Org B (2.2)' tab 'v2']});
% gene functions and their reactions; GeneA has two reactions, GeneD shares RXN_A with GeneA
writeLines(fullfile(sandboxDir, 'InReactions.txt'), {['PubSEED Abreviation' tab 'VMH Abbreviation'], ...
    ['Exchange' tab 'EX_glc_D(e)'], ['GeneA' tab 'RXN_A'], ['GeneA' tab 'RXN_A2'], ...
    ['GeneB' tab 'RXN_B'], ['GeneC' tab 'RXN_C'], ['GeneD' tab 'RXN_A']});
% the VMH database (format of testLoadVMHDatabase); no empty field and descriptions with
% different numbers of blanks, so that readtable detects the tab (not the blank) as
% delimiter of this short file. RXN_A takes up extracellular glucose
metaboliteRows = {
    'atp',   'ATP',        'C10H12N5O13P3', 'C10H12N5O13P3', '-4', 'C00002', '5957', '15422', '', '', 'HMDB00538', '19/09/2018', 'Nucleotide'
    'h2o',   'Water',      'H2O',           'H2O',           '0',  'C00001', '962',  '15377', '', '', 'HMDB02111', '19/09/2018', ''
    'glc_D', 'D-Glucose',  '',              'C6H12O6',       '0',  'C00031', '',     '',      '', '', '',          '19/09/2018', 'Glycolysis'};
metaboliteLines = cell(1, size(metaboliteRows, 1));
for i = 1:size(metaboliteRows, 1)
    metaboliteLines{i} = strjoin(metaboliteRows(i, :), tab);
end
writeLines(fullfile(sandboxDir, 'MetaboliteDatabase.txt'), metaboliteLines);
reactionLines = {strjoin({'ReactionID', 'Description', 'Formula', 'Reversible', 'ConfidenceScore', 'Notes', ...
    'References', 'ECNumber', 'KEGGID', 'LastModified', 'Subsystem', 'Subsystem_general'}, tab)};
reactionRows = {'EX_glc_D(e)', 'glucose exchange', 'glc_D[e] <=> ', '1'
    'RXN_A', 'glucose uptake by the cell', 'glc_D[e] -> glc_D[c]', '0'
    'RXN_A2', 'A2', 'a[c] -> b[c]', '0'
    'RXN_B', 'the reaction of gene B', 'c[c] -> d[c]', '0'
    'RXN_C', 'C reaction', 'e[c] + f[c] -> g[c]', '0'};
for i = 1:size(reactionRows, 1)
    reactionLines{end + 1} = strjoin([reactionRows(i, :), {'0', 'n', 'r', 'e', 'k', '19/09/2018', 'x', 'y'}], tab); %#ok<SAGROW>
end
writeLines(fullfile(sandboxDir, 'ReactionDatabase.txt'), reactionLines);
% spreadsheet 1: orgA has GeneA (peg 5) and GeneB (pegs 3 and 4), not GeneC; orgB has GeneB
% gap-filled ('][') and GeneC (peg 7); a third organism is not in the information file
writeLines(fullfile(spreadsheetDir, 'sheet1.tsv'), {['Organism' tab 'GeneA' tab 'GeneB' tab 'GeneC'], ...
    ['Org A (1.1)' tab '5' tab '3, 4' tab ''], ['Org B (2.2)' tab '' tab '][' tab '7'], ...
    ['Unknown organism (9.9)' tab '1' tab '' tab '']});
% spreadsheet 2: orgA has GeneD (peg 8), whose reaction RXN_A orgA already has
writeLines(fullfile(spreadsheetDir, 'sheet2.tsv'), {['Organism' tab 'GeneD'], ['Org A (1.1)' tab '8']});

% read back the written file as one cell row per line
outputFile = fullfile(outputDir, 'genomeAnnotation.txt');
readRows = @() cellfun(@(line) strsplit(line, tab), ...
    splitlines(strip(fileread(outputFile), 'right', newline)), 'UniformOutput', false);

cd(sandboxDir);

%% numeric annotation versions

% spreadsheet 1, orgA: GeneA -> RXN_A (gene rule 1.1.5.peg) and, as glc_D[e] is
% extracellular, EX_glc_D(e) gap-filled; RXN_A2 (1.1.5.peg); GeneB -> RXN_B with the two
% pegs; orgB: GeneB -> RXN_B gap-filled; GeneC -> RXN_C (peg 7, read from a numeric column).
% Spreadsheet 2, orgA: GeneD -> RXN_A and EX_glc_D(e) again; both repetitions are removed
writeReactionsFromPubSeedSpreadsheets(fullfile(sandboxDir, 'infoNumeric.txt'), outputDir, spreadsheetDir);
rows = readRows();
expectedRows = {
    {'orgA', 'RXN_A', '1.1.5.peg'}
    {'orgA', 'EX_glc_D(e)', 'gap_filled'}
    {'orgA', 'RXN_A2', '1.1.5.peg'}
    {'orgA', 'RXN_B', '1.1.3.peg or 1.1.4.peg'}
    {'orgB', 'RXN_B', 'gap_filled'}
    {'orgB', 'RXN_C', '2.2.7.peg'}};
assert(isequal(rows, expectedRows));

%% annotation versions written as text

% the same reactions; the gene rules start with the text version
writeReactionsFromPubSeedSpreadsheets(fullfile(sandboxDir, 'infoText.txt'), outputDir, spreadsheetDir);
rows = readRows();
assert(numel(rows) == 6);
assert(isequal(rows{1}, {'orgA', 'RXN_A', 'v1.5.peg'}));
assert(isequal(rows{4}, {'orgA', 'RXN_B', 'v1.3.peg or v1.4.peg'}));
assert(isequal(rows{6}, {'orgB', 'RXN_C', 'v2.7.peg'}));

%% no spreadsheet: an empty file is written

% the file of the previous call is removed first, so that the file checked is the new one
delete(outputFile);
writeReactionsFromPubSeedSpreadsheets(fullfile(sandboxDir, 'infoNumeric.txt'), outputDir, emptySpreadsheetDir);
assert(exist(outputFile, 'file') == 2);
assert(isempty(strtrim(fileread(outputFile))));

%% restore the globals, remove the sandbox

cd(fileDir);
additionalSecretionRxns = savedSecretion;
additionalUptakeRxns = savedUptake;
newGlobals = setdiff(who('global'), globalsBefore);
if ~isempty(newGlobals)
    clearvars('-global', newGlobals{:});
end
rmdir(sandboxDir, 's');

% change the directory
cd(currentDir)

function writeTextLines(path, lines)
% writes the lines to a text file, each followed by a newline
fid = fopen(path, 'w');
fprintf(fid, '%s\n', lines{:});
fclose(fid);
end
