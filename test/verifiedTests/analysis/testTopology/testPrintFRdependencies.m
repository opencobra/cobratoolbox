% The COBRAToolbox: testPrintFRdependencies.m
%
% Purpose:
%     - printFRdependencies(model, filePathName) reports, for each dependent row of [F, R]
%       (model.FRdrows, one row of model.FRW each), the metabolites it depends on (the nonzero
%       columns of its FRW row), the reactions of model.FRVcols that consume or produce it,
%       and the submatrix of [F, R] (F = -S and R = S with negative entries set to zero) on the
%       independent and dependent rows, to the command window or, appended, to a text file.
%       The test hand-builds FRdrows, FRwrows and FRW on two createModel models: a
%       four-metabolite model (short lists, one and two reactions, a displayed 4 x 4
%       submatrix) and an 18-metabolite model (a list of 17 metabolites and an 18 x 2
%       submatrix, both above the display limits). Every expected line, the dimension and the
%       rank of the submatrix are derived by hand from S; the command window is recorded with
%       diary in a temporary file.
%
% Function under test:
%     src/analysis/topology/FR/printFRdependencies.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - two hand-built createModel models, no solver; the FR fields of checkRankFR are
%     set by hand.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPrintFRdependencies'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% four metabolites: R1: A + B -> C, R2: C -> D, R3: D -> A; R3 is left out of the
% columns of [F; R] (FRVcols), so it never appears in the report
smallModel = createModel({'R1'; 'R2'; 'R3'}, {'R1'; 'R2'; 'R3'}, {'A + B -> C'; 'C -> D'; 'D -> A'}, ...
    'printLevel', 0);
assert(isequal(smallModel.mets, {'A[c]'; 'B[c]'; 'C[c]'; 'D[c]'}));
smallModel.FRVcols = [true; true; false];
% C and D are the dependent rows, A and B the rows they depend on
smallModel.FRdrows = logical([0; 0; 1; 1]);
smallModel.FRwrows = logical([1; 1; 0; 0]);
% C depends on A and B, D on A only (the console form ignores entries below 1e-6)
smallModel.FRW = sparse([0.5 2 0 0; 1 1e-9 0 0]);

% 18 metabolites: R1: m01 + ... + m17 -> m18, every column in [F; R]
bigMets = arrayfun(@(i) sprintf('m%02d', i), (1:18)', 'UniformOutput', false);
bigModel = createModel({'R1'}, {'R1'}, {[strjoin(bigMets(1:17), ' + ') ' -> ' bigMets{18}]}, 'printLevel', 0);
assert(isequal(bigModel.mets, strcat(bigMets, '[c]')));
bigModel.FRVcols = true;
bigModel.FRdrows = [false(17, 1); true];
bigModel.FRwrows = [true(17, 1); false];
% m18 depends on all 17 substrates, more than the 8 that are listed
bigModel.FRW = sparse([ones(1, 17), 0]);

% record the command window in a temporary file; the previous diary state is restored below
workDir = tempname;
mkdir(workDir);
diaryWasOn = strcmp(get(0, 'Diary'), 'on');
previousDiaryFile = get(0, 'DiaryFile');
if diaryWasOn
    diary('off');
end

%% command window: dependencies, reactions and the displayed submatrix

diaryFile = fullfile(workDir, 'small.txt');
diary(diaryFile);
printFRdependencies(smallModel);
diary('off');
printedText = fileread(diaryFile);
% C: two FRW entries; D: the 1e-9 entry is below the console threshold, so only A
assert(contains(printedText, 'C[c] is dependent on: A[c] and B[c].'));
assert(contains(printedText, 'D[c] is dependent on: A[c].'));
% C is consumed by R2 and produced by R1 (two reactions); D is produced by R2 only, its
% consumption by R3 is outside FRVcols
assert(contains(printedText, 'The reactions are:'));
assert(contains(printedText, 'The reaction is:'));
assert(~contains(printedText, 'R3'));
% rows A, B, C, D of [F(:, 1:2), R(:, 1:2)] = [1 0 0 0; 1 0 0 0; 0 1 1 0; 0 0 0 1]: all four
% columns are nonzero and rows A and B are equal, so the rank is 3
assert(contains(printedText, 'FR subset of dimension 4 x 4, of rank 3.'));
assert(~isempty(regexp(printedText, ['2 independent rows:\s+1\s+0\s+0\s+0\s+1\s+0\s+0\s+0\s+' ...
    '2 dependent rows:\s+0\s+1\s+1\s+0\s+0\s+0\s+0\s+1'], 'once')));

%% command window: more than 8 metabolites and more than 15 rows are not displayed

diaryFile = fullfile(workDir, 'big.txt');
diary(diaryFile);
printFRdependencies(bigModel);
diary('off');
printedText = fileread(diaryFile);
assert(contains(printedText, 'm18[c] is dependent on:  10 or more metabolites, will not be displayed'));
assert(contains(printedText, 'The reaction is:'));
% 17 independent and 1 dependent row; the nonzero columns are F(:, 1) and R(:, 1), rank 2
assert(contains(printedText, 'FR subset of dimension 18 x 2, of rank 2.'));
assert(contains(printedText, 'More than 15 rows or columns in the'));
assert(~contains(printedText, 'independent rows:'));

%% text file: the same report appended to an existing file

reportFile = fullfile(workDir, 'report.txt');
reportFid = fopen(reportFile, 'w');
fprintf(reportFid, 'existing line\n');
fclose(reportFid);
printFRdependencies(smallModel, reportFile);
reportText = fileread(reportFile);
% the file keeps its first line (append mode)
assert(startsWith(reportText, sprintf('existing line\nC[c] is dependent on: A[c] and B[c].\nThe reactions are:\n')));
% the file form lists every nonzero FRW entry, so D also lists B (entry 1e-9)
assert(contains(reportText, sprintf('D[c] is dependent on: A[c] and B[c].\nThe reaction is:\n')));
% each reaction line is the identifier, a tab and the formula of printRxnFormula
assert(~isempty(regexp(reportText, 'R2\tC\[c\]\s+->\s+D\[c\]', 'once')));
assert(~isempty(regexp(reportText, 'R1\tA\[c\]\s+\+\s+B\[c\]\s+->\s+C\[c\]', 'once')));
% the submatrix is written with dlmwrite, one row per line and single spaces
assert(endsWith(reportText, sprintf(['FR subset of dimension 4 x 4, of rank 3.\n2 independent rows:\n' ...
    '1 0 0 0\n1 0 0 0\n2 dependent rows:\n0 1 1 0\n0 0 0 1\n'])));

%% text file: lists and submatrices above the display limits

reportFile = fullfile(workDir, 'bigReport.txt');
printFRdependencies(bigModel, reportFile);
reportText = fileread(reportFile);
assert(strcmp(reportText(1:find(reportText == newline, 1) - 1), ...
    'm18[c] is dependent on:  10 or more metabolites, will not be displayed'));
assert(contains(reportText, sprintf('The reaction is:\nR1\t')));
assert(endsWith(reportText, sprintf(['FR subset of dimension 18 x 2, of rank 2.\n' ...
    'More than 15 rows or columns in the dependency, so will not display.\n'])));

%% restore the diary state and remove the files

set(0, 'DiaryFile', previousDiaryFile);
if diaryWasOn
    diary('on');
end
rmdir(workDir, 's');

% change the directory
cd(currentDir)
