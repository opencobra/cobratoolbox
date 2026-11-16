% The COBRAToolbox: testMakeFRresultsTable.m
%
% Purpose:
%     - makeFRresultsTable(FRresults, resultsDirectory, resultsFileName, modelMetaData,
%       tableFilename) tabulates the results of checkRankFRdriver: a first column of 32 row
%       headings and one column per model with the species, version, model identifier,
%       PMID or DOI (from modelMetaData, ordered by its rows, or the model identifier alone),
%       the row and column counts, ranks, coefficient magnitudes and the counts of the boolean
%       vectors of each model; it can load FRresults from a .mat file and write the table as a
%       tab-delimited file. The test hand-builds two results (one without the elemental
%       balance fields, which give NaN) and checks every cell against values counted by hand
%       from the hand-set vectors and matrices, with and without metadata, the load from a
%       named and from the default file in a temporary folder, and the written file.
%
% Function under test:
%     src/analysis/topology/FR/makeFRresultsTable.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - hand-built result structures of two small models; no solver.
%
% Coverage exemptions:
%     Line 33: the default results folder, skipped for the cosmetic defect below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: the default results folder is one developer's personal folder
%       SEVERITY: cosmetic
%       TRIGGER: makeFRresultsTable([]) (FRresults empty, resultsDirectory omitted)
%       OBSERVED: line 33 sets resultsDirectory to a Dropbox folder in one developer's home and
%         line 35 changes to it, which fails on any other machine with the error of cd for a
%         missing folder (read from the code; not run, the call depends on that folder)
%       EXPECTED: no machine-specific default; an error asking for resultsDirectory
%       LINES: 33
%     - DEFECT: a model missing from modelMetaData has no column
%       SEVERITY: limitation
%       TRIGGER: modelMetaData without a row whose third column is FRresults(k).modelID
%       OBSERVED: lines 71-74 set n only when the identifier is found, so the column of the
%         previous model (n of the previous k) is overwritten, or, for the first model, n is
%         undefined (read from the code; the header documents one metadata row per model)
%       EXPECTED: every model of FRresults listed in modelMetaData, or a column or an error
%         for a missing one
%       LINES: 71-74
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMakeFRresultsTable'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% model m1: 4 metabolites, 2 reactions, with elemental balance fields
model1.S = sparse([-1 0; 1 -1; 0 1; 0 2]);
model1.balancedMetBool = logical([1; 1; 0; 1]);
model1.SConsistentMetBool = logical([1; 1; 1; 0]);
model1.FRuniqueRowBool = logical([1; 1; 0; 1]);
model1.FRnonZeroRowBool1 = logical([1; 0; 1; 1]);
model1.fluxConsistentMetBool = logical([1; 1; 1; 1]);
model1.FRnonZeroRowBool = logical([1; 1; 1; 0]);
model1.FRrows = logical([1; 1; 0; 0]);
model1.Frb = zeros(3, 5);
model1.rankBilinearFrRr = 2;
model1.largestConnectedRowsFRBool = logical([1; 1; 1; 0]);
model1.SIntMetBool = logical([1; 1; 1; 0]);
model1.SIntRxnBool = logical([1; 0]);
model1.balancedRxnBool = logical([1; 1]);
model1.SConsistentRxnBool = logical([1; 1]);
model1.FRuniqueColBool = logical([1; 0]);
model1.fluxConsistentRxnBool = logical([1; 1]);
model1.FRnonZeroColBool = logical([1; 1]);
model1.largestConnectedColsFRVBool = logical([0; 1]);
model1.FRVcols = logical([1; 1]);

% model m2: 3 metabolites, 1 reaction, without elemental balance fields
model2.S = sparse([-4; 1; 3]);
model2.SConsistentMetBool = true(3, 1);
model2.FRuniqueRowBool = true(3, 1);
model2.FRnonZeroRowBool1 = true(3, 1);
model2.fluxConsistentMetBool = logical([1; 1; 0]);
model2.FRnonZeroRowBool = logical([1; 0; 1]);
model2.FRrows = true(3, 1);
model2.Frb = zeros(2, 2);
model2.rankBilinearFrRr = 1;
model2.largestConnectedRowsFRBool = logical([1; 0; 0]);
model2.SIntMetBool = true(3, 1);
model2.SIntRxnBool = true;
model2.SConsistentRxnBool = true;
model2.FRuniqueColBool = true;
model2.fluxConsistentRxnBool = false;
model2.FRnonZeroColBool = true;
model2.largestConnectedColsFRVBool = true;
model2.FRVcols = true;

FRresults = struct('modelID', {'m1', 'm2'}, 'model', {model1, model2}, ...
    'rankFRvanilla', {3, 2}, 'rankS', {2, 1}, 'rankFR', {1, 2}, 'rankFRV', {2, 1}, 'rankFRVvanilla', {2, 1});

% rows 5 to 32 of each model column, counted by hand from the vectors above:
% rows, rank [F,R] vanilla, rank S, min, max and min/max |S_ij| (exact: 1/2 and 1/4), balanced
% rows, consistent rows (4 nested intersections), rows of proper [F,R], rank FR, rows and rank
% of bilinear [F,R], largest connected rows, exchange rows, reactions, exchange cols, balanced
% cols, consistent cols (4 nested intersections), largest connected cols, proper cols, ranks
expectedModel1 = [4 3 2 1 2 0.5 3 3 1 1 1 2 1 3 2 3 1 2 1 2 2 1 1 1 1 2 2 2]';
expectedModel2 = [3 2 1 1 4 0.25 NaN 3 3 2 1 3 2 2 1 1 0 1 0 NaN 1 1 0 0 1 1 1 1]';

%% without metadata: one column per model in the order of FRresults

[FRresultsTable, FRresultsOut] = makeFRresultsTable(FRresults);
tableCells = table2cell(FRresultsTable);
% 32 rows (the preallocated 29 grow), a heading column and two model columns
assert(isequal(size(tableCells), [32 3]));
assert(isequal(tableCells([1:5, 22, 32], 1), {'Species'; 'Version'; 'modelID'; 'PMID or DOI'; ...
    '# Reactants = # Rows of [S S_e]'; '# Reactions = # Cols of [S S_e]'; '# Rank of vanilla [F;R]'}));
assert(all(cellfun(@ischar, tableCells(:, 1))));
% metadata rows are empty, the identifier comes from FRresults
assert(isequal(tableCells(1:4, 2), {''; ''; 'm1'; ''}) && isequal(tableCells(1:4, 3), {''; ''; 'm2'; ''}));
% counts and ranks are exact integers; the two ratios are exact binary fractions
assert(isequaln(cell2mat(tableCells(5:32, 2)), expectedModel1));
assert(isequaln(cell2mat(tableCells(5:32, 3)), expectedModel2));
% FRresults is returned unchanged
assert(isequal(FRresultsOut, FRresults));

% empty metadata is the same as no metadata
assert(isequaln(table2cell(makeFRresultsTable(FRresults, [], [], {})), tableCells));

%% with metadata: columns follow the metadata rows, PMID or else DOI

modelMetaData = {'Species two', 'v2', 'm2', '', '10.1000/xyz'; ...
                 'Species one', 'v1', 'm1', '12345', ''};
tableCells = table2cell(makeFRresultsTable(FRresults, [], [], modelMetaData));
% m2 is the first metadata row, so its column is 2; m1 goes to column 3
assert(isequal(tableCells(1:4, 2), {'Species two'; 'v2'; 'm2'; '10.1000/xyz'}));
assert(isequal(tableCells(1:4, 3), {'Species one'; 'v1'; 'm1'; '12345'}));
assert(isequaln(cell2mat(tableCells(5:32, 2)), expectedModel2));
assert(isequaln(cell2mat(tableCells(5:32, 3)), expectedModel1));

%% results loaded from a named file and from the default file name

workDir = tempname;
mkdir(workDir);
% a saved result has modelFilename instead of modelID; the identifier is the name without .mat
FRresults = struct('modelFilename', 'm1.mat', 'model', model1, 'rankFRvanilla', 3, 'rankS', 2, ...
    'rankFR', 1, 'rankFRV', 2, 'rankFRVvanilla', 2);
save(fullfile(workDir, 'savedResults.mat'), 'FRresults');
[FRresultsTable, FRresultsOut] = makeFRresultsTable([], [workDir filesep], 'savedResults');
cd(fileDir);
tableCells = table2cell(FRresultsTable);
assert(isequal(size(tableCells), [32 2]) && strcmp(tableCells{3, 2}, 'm1'));
assert(isequaln(cell2mat(tableCells(5:32, 2)), expectedModel1));
assert(strcmp(FRresultsOut.modelID, 'm1'));
% without a file name the file FRresults_20150130T011200.mat is read
FRresults.modelFilename = 'm1default.mat';
save(fullfile(workDir, 'FRresults_20150130T011200.mat'), 'FRresults');
[~, FRresultsOut] = makeFRresultsTable([], [workDir filesep]);
cd(fileDir);
assert(strcmp(FRresultsOut.modelID, 'm1default'));

%% the table written as a tab-delimited file

tableFile = fullfile(workDir, 'FRtable.txt');
FRresults = struct('modelID', {'m1', 'm2'}, 'model', {model1, model2}, ...
    'rankFRvanilla', {3, 2}, 'rankS', {2, 1}, 'rankFR', {1, 2}, 'rankFRV', {2, 1}, 'rankFRVvanilla', {2, 1});
makeFRresultsTable(FRresults, [], [], [], tableFile);
writtenLines = strsplit(strtrim(fileread(tableFile)), newline)';
% a line of variable names and one line per table row, three tab-separated fields each
assert(numel(writtenLines) == 33);
assert(isequal(strsplit(writtenLines{4}, sprintf('\t')), {'modelID', 'm1', 'm2'}));
assert(isequal(strsplit(writtenLines{6}, sprintf('\t')), {'# Reactants = # Rows of [S S_e]', '4', '3'}));

rmdir(workDir, 's');

% change the directory
cd(currentDir)
