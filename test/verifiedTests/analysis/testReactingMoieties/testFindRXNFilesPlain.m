% The COBRAToolbox: testFindRXNFilesPlain.m
%
% Purpose:
%     - findRXNFilesPlain(model, rxnfileDir) returns which metabolites (metRXNBool) and
%       reactions (rxnRXNBool) of a model have an RXN file <rxn id>.rxn in a folder, and which
%       reactions are internal (internalRxnBool: model.SConsistentRxnBool, else
%       model.SIntRxnBool, else findSExRxnInd), and prints how many internal reactions have
%       no file. The test writes empty .rxn files (only the names are read), a .txt file and
%       a folder named like an RXN file into a tempname folder, and checks the outputs
%       against hand-derived values for each source of internalRxnBool, a folder path with
%       a trailing separator, every reaction mapped, 100 unmapped internal reactions (no
%       list printed), and the two errors. The printed text is recorded with diary.
%
% Function under test:
%     src/analysis/topology/reactingMoieties/findRXNFilesPlain.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - hand-built models (createModel and a 101-reaction struct); no solver.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindRXNFilesPlain'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% folder with R1.rxn and R2.rxn; notes.txt (not .rxn) and a folder R3.rxn are ignored
workDir = tempname;
rxnDir = fullfile(workDir, 'rxnFiles');
mkdir(rxnDir);
mkdir(fullfile(rxnDir, 'R3.rxn'));
for fileName = {'R1.rxn', 'R2.rxn', 'notes.txt'}
    fid = fopen(fullfile(rxnDir, fileName{1}), 'w');
    fclose(fid);
end

% five reactions: R1, R2, R3 internal, EX_a and EX_d exchanges; mets a, b, c, d
model = createModel({'R1', 'R2', 'R3', 'EX_a', 'EX_d'}, {'', '', '', '', ''}, ...
    {'a[c] -> b[c]', 'b[c] -> c[c]', 'c[c] -> d[c]', 'a[c] <=> ', 'd[c] <=> '}, ...
    'printLevel', 0);
expectedRxnRXNBool = [true; true; false; false; false];
% metabolites of R1 and R2: a, b and c (d is only in R3 and EX_d)
expectedMetRXNBool = ismember(model.mets, {'a[c]', 'b[c]', 'c[c]'});

% record the command window in a temporary file; the previous diary state is restored below
diaryWasOn = strcmp(get(0, 'Diary'), 'on');
previousDiaryFile = get(0, 'DiaryFile');
if diaryWasOn
    diary('off');
end

%% SConsistentRxnBool is used before SIntRxnBool; one internal reaction (R3) has no file

consistentModel = model;
consistentModel.SConsistentRxnBool = [true; true; true; false; false];
consistentModel.SIntRxnBool = [true; true; false; false; false];
diaryFile = fullfile(workDir, 'consistent.txt');
diary(diaryFile);
[metRXNBool, rxnRXNBool, internalRxnBool] = findRXNFilesPlain(consistentModel, rxnDir);
diary('off');
printedText = fileread(diaryFile);
assert(isequal(rxnRXNBool, expectedRxnRXNBool));
assert(isequal(metRXNBool, expectedMetRXNBool));
assert(islogical(internalRxnBool) && isequal(internalRxnBool, [true; true; true; false; false]));
% two files are available (the .txt file and the folder do not count); R3 is listed
assert(contains(printedText, 'RXN files available for 2 reactions.'));
assert(contains(printedText, 'RXN files found for 2 internal reactions.'));
assert(contains(printedText, 'RXN files not found for 1 internal reactions:'));
assert(contains(printedText, 'R3'));

%% SIntRxnBool (a numeric row vector) when SConsistentRxnBool is absent; trailing separator

% only R1 and R2 are internal, so every unmapped reaction is external
intModel = model;
intModel.SIntRxnBool = [1, 1, 0, 0, 0];
diaryFile = fullfile(workDir, 'sint.txt');
diary(diaryFile);
[metRXNBool, rxnRXNBool, internalRxnBool] = findRXNFilesPlain(intModel, [rxnDir filesep]);
diary('off');
printedText = fileread(diaryFile);
assert(isequal(rxnRXNBool, expectedRxnRXNBool));
assert(isequal(metRXNBool, expectedMetRXNBool));
% returned as a logical column
assert(islogical(internalRxnBool) && isequal(internalRxnBool, [true; true; false; false; false]));
assert(contains(printedText, 'RXN files found for all 2 internal reactions.'));
assert(~contains(printedText, 'not found'));

%% neither field: findSExRxnInd marks the EX_ reactions as external

diaryFile = fullfile(workDir, 'computed.txt');
diary(diaryFile);
[metRXNBool, rxnRXNBool, internalRxnBool] = findRXNFilesPlain(model, rxnDir);
diary('off');
printedText = fileread(diaryFile);
assert(isequal(rxnRXNBool, expectedRxnRXNBool));
assert(isequal(metRXNBool, expectedMetRXNBool));
assert(isequal(internalRxnBool, [true; true; true; false; false]));
assert(contains(printedText, 'RXN files not found for 1 internal reactions:'));

%% every reaction has a file: internalRxnBool is still assigned, nothing more is printed

mappedModel = createModel({'R1', 'R2'}, {'', ''}, {'a[c] -> b[c]', 'b[c] -> c[c]'}, ...
    'printLevel', 0);
mappedModel.SIntRxnBool = [true; true];
diaryFile = fullfile(workDir, 'allMapped.txt');
diary(diaryFile);
[metRXNBool, rxnRXNBool, internalRxnBool] = findRXNFilesPlain(mappedModel, rxnDir);
diary('off');
printedText = fileread(diaryFile);
assert(isequal(rxnRXNBool, [true; true]));
assert(isequal(metRXNBool, [true; true; true]));
assert(isequal(internalRxnBool, [true; true]));
assert(contains(printedText, 'RXN files available for 2 reactions.'));
assert(~contains(printedText, 'RXN files found'));

%% 100 unmapped internal reactions: counted, but the list is not printed (limit < 100)

% hand-built struct: R1 .. R101 internal, one metabolite each; only R1 (and R2) have files
nLarge = 101;
largeModel.rxns = arrayfun(@(k) sprintf('R%d', k), (1:nLarge)', 'UniformOutput', false);
largeModel.S = speye(nLarge);
largeModel.SIntRxnBool = true(nLarge, 1);
% R2 has a file as well, so 99 are unmapped; rename it so that exactly 100 are unmapped
largeModel.rxns{2} = 'X2';
diaryFile = fullfile(workDir, 'large.txt');
diary(diaryFile);
[metRXNBool, rxnRXNBool] = findRXNFilesPlain(largeModel, rxnDir);
diary('off');
printedText = fileread(diaryFile);
assert(isequal(find(rxnRXNBool), 1));
assert(isequal(find(metRXNBool), 1));
assert(contains(printedText, 'RXN files found for 1 internal reactions.'));
assert(contains(printedText, 'RXN files not found for 100 internal reactions:'));
% the names of the unmapped reactions are not displayed
assert(~contains(printedText, 'R101') && ~contains(printedText, 'X2'));

%% errors: no RXN file in the folder (or no folder), no file for any model reaction

emptyDir = fullfile(workDir, 'noRxnFiles');
mkdir(emptyDir);
fid = fopen(fullfile(emptyDir, 'notes.txt'), 'w');
fclose(fid);
assert(verifyCobraFunctionError('findRXNFilesPlain', 'inputs', {model, emptyDir}, ...
    'testMessage', 'Rxnfile directory is empty or nonexistent.'));
assert(verifyCobraFunctionError('findRXNFilesPlain', 'inputs', ...
    {model, fullfile(workDir, 'missingFolder')}, ...
    'testMessage', 'Rxnfile directory is empty or nonexistent.'));
% assert with a single message argument keeps the characters \n literally
unmappedModel = createModel({'X1'}, {''}, {'a[c] -> b[c]'}, 'printLevel', 0);
assert(verifyCobraFunctionError('findRXNFilesPlain', 'inputs', {unmappedModel, rxnDir}, ...
    'testMessage', ['No RXN files found for model reactions.\nCheck that rxnfile names ', ...
    'match reaction identifiers in rxns.']));

%% restore the diary state and remove the files

set(0, 'DiaryFile', previousDiaryFile);
if diaryWasOn
    diary('on');
end
rmdir(workDir, 's');

% change the directory
cd(currentDir)
