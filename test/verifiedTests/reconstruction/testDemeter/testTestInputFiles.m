% The COBRAToolbox: testTestInputFiles.m
%
% Purpose:
%     - testInputFiles() is a DEMETER test-suite function (its name starts with "test"; this
%       file tests it). It reads the reconstruction IDs from the first column of
%       AGORA2_infoFile.xlsx (below a header row) and, for each of the nine input tables
%       AromaticAATable.txt ... secretionProductTable.txt (tab-separated, header row, IDs in
%       the first column), returns in two structures with one field per table the IDs of
%       the info file missing from the table and the IDs of the table that are not in the
%       info file (sorted, setdiff), warning about each table with such IDs.
%     - The files are found through the current folder, so the test writes a small info
%       file and nine tables in a temporary folder and runs the function there; the
%       expected sets follow by hand from the files.
%
% Function under test:
%     src/reconstruction/demeter/suite/tests/testInputFiles.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - file look-ups of hand-written files in a temporary folder, no model, no solver.
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
fileDir = fileparts(which('testTestInputFiles'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

inputTables = {'AromaticAATable'; 'BileAcidTable'; 'CarbonSourcesTable'; ...
    'FermentationTable'; 'GenomeAnnotation'; 'GrowthRequirementsTable'; ...
    'PutrefactionTable'; 'uptakeTable'; 'secretionProductTable'};

sandboxDir = tempname;
mkdir(sandboxDir);
cd(sandboxDir);

% info file: header row and three reconstructions
writecell({'MicrobeID', 'Phylum'; 'Microbe_A', 'P1'; 'Microbe_B', 'P2'; ...
    'Microbe_C', 'P3'}, 'AGORA2_infoFile.xlsx');

% every table lists the three reconstructions, except BileAcidTable (Microbe_B and Microbe_C
% missing, Microbe_D and Microbe_E unknown) and uptakeTable (Microbe_C missing)
tableIDs = repmat({{'Microbe_A'; 'Microbe_B'; 'Microbe_C'}}, numel(inputTables), 1);
tableIDs{2} = {'Microbe_E'; 'Microbe_A'; 'Microbe_D'};
tableIDs{8} = {'Microbe_B'; 'Microbe_A'};
for iTable = 1:numel(inputTables)
    fid = fopen([inputTables{iTable} '.txt'], 'w');
    fprintf(fid, 'MicrobeID\tValue\n');
    for iRow = 1:numel(tableIDs{iTable})
        fprintf(fid, '%s\t%s\n', tableIDs{iTable}{iRow}, 'yes');
    end
    fclose(fid);
end

%% missing and unknown IDs per table

lastwarn('');
[modelIDsMissingInTable, incorrectIDsInTable] = testInputFiles();

% one field per table, in the order of the list
assert(isequal(fieldnames(modelIDsMissingInTable), inputTables));
assert(isequal(fieldnames(incorrectIDsInTable), inputTables));

% BileAcidTable: two reconstructions missing, two unknown IDs (sorted)
assert(isequal(modelIDsMissingInTable.BileAcidTable, {'Microbe_B'; 'Microbe_C'}));
assert(isequal(incorrectIDsInTable.BileAcidTable, {'Microbe_D'; 'Microbe_E'}));

% uptakeTable: one reconstruction missing, no unknown ID
assert(isequal(modelIDsMissingInTable.uptakeTable, {'Microbe_C'}));
assert(isempty(incorrectIDsInTable.uptakeTable));

% the seven complete tables have nothing to report
for iTable = [1, 3, 4, 5, 6, 7, 9]
    assert(isempty(modelIDsMissingInTable.(inputTables{iTable})));
    assert(isempty(incorrectIDsInTable.(inputTables{iTable})));
end

% the last warning names the last table with a missing reconstruction (uptakeTable comes
% after BileAcidTable and has no unknown ID)
assert(strcmp(lastwarn, 'Some reconstruction names are not present in table uptakeTable'));

% remove the temporary files and change the directory
cd(currentDir)
rmdir(sandboxDir, 's');
