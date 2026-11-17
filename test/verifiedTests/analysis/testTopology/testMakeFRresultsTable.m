% The COBRAToolbox: testMakeFRresultsTable.m
%
% Purpose:
%     - makeFRresultsTable(FRresults, resultsDirectory, resultsFileName, modelMetaData,
%       tableFilename) tabulates the results of checkRankFRdriver: a first column of 32 row
%       headings and one column per model with the species, version, model identifier,
%       PMID or DOI (from modelMetaData, ordered by its rows, or the model identifier alone),
%       the row and column counts, ranks, coefficient magnitudes and the counts of the boolean
%       vectors of each model; with FRresults empty it loads FRresults from a .mat file, and it
%       can write the table as a tab-delimited file.
%     - Once the defects below are fixed, the test should hand-build two results (one without
%       the elemental balance fields, which give NaN) and check every cell against values
%       counted by hand from the hand-set vectors and matrices (28 counts per model), with and
%       without metadata (columns ordered by the metadata rows, PMID else DOI, empty metadata
%       the same as none), with metadata missing one of the models, the load from a named and
%       from the default file in a temporary folder given with and without a trailing file
%       separator, the call without resultsDirectory, and the written file.
%       Quarantined: no behaviour of makeFRresultsTable is asserted until the error defects
%       below are fixed; this file only opens the test.
%
% Function under test:
%     src/analysis/topology/FR/makeFRresultsTable.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - hand-built result structures of two small models; no solver.
%
% Coverage exemptions:
%     every line - makeFRresultsTable is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The optional resultsDirectory cannot be omitted: its default is one
%         developer's personal folder
%       SEVERITY: error
%       TRIGGER: makeFRresultsTable([]) (FRresults empty, resultsDirectory omitted)
%       OBSERVED: (R2025a, 2026-11-17) "Unable to change current folder to '<a Dropbox
%         folder in one developer's home>' (Name is nonexistent or not a folder)." at line
%         35: line 33 sets that folder as the default, so the call fails on every other
%         machine
%       EXPECTED: no machine-specific default (for example the current folder, or an error
%         asking for resultsDirectory)
%       LINES: 32-35
%     - DEFECT: A resultsDirectory without a trailing file separator cannot be loaded
%       SEVERITY: error
%       TRIGGER: FRresults saved as <folder>/saved.mat; makeFRresultsTable([], folder,
%         'saved') with folder = tempname (no trailing separator)
%       OBSERVED: (R2025a, 2026-11-17) "Unable to find file or directory '<folder>saved'."
%         (MATLAB:load:couldNotReadFile) at line 36: the path is built by concatenation; the
%         same call with [folder filesep] loads the file and returns the table
%       EXPECTED: the file <folder>/saved.mat loaded (fullfile)
%       LINES: 36
%     - DEFECT: A model missing from modelMetaData stops the function with an error
%       SEVERITY: error
%       TRIGGER: FRresults with modelID 'm1' and 'm2'; makeFRresultsTable(FRresults, [], [],
%         {'Species one', 'v1', 'm1', '1', ''}) (no row for m2), or the metadata row of m2
%         only (no row for m1)
%       OBSERVED: (R2025a, 2026-11-17) metadata for m1 only: "Unable to perform assignment
%         with 0 elements on the right-hand side." (MATLAB:TooManyOutputsDueToMissingBraces)
%         at line 85 when the column of m2 is filled; metadata for m2 only: "Unrecognized
%         function or variable 'n'." at line 85: n is set only when the identifier is found
%         (lines 71-74) and modelMetaData{bool, 1} is empty
%       EXPECTED: a column for every model of FRresults, with empty metadata cells (as without
%         metadata) and the warning of line 77, since the header does not require every
%         model to be in modelMetaData
%       LINES: 70-74, 85, 95, 105, 115-120
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.
%     - Quarantined after the independent review (T021), 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMakeFRresultsTable'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
