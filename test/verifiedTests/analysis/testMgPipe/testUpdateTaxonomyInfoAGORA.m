% The COBRAToolbox: testUpdateTaxonomyInfoAGORA.m
%
% Purpose:
%     - updateTaxonomyInfoAGORA reads AGORA_infoFile.xlsx and AGORA2_infoFile.xlsx, looks up
%       the NCBI Taxonomy lineage of every strain with parseNCBItaxonomy and writes the
%       tables back under the same names in the current folder. The columns Species, Genus,
%       Family, Order, Class, Phylum and Kingdom (from superkingdom) are replaced by every
%       non-empty rank that NCBI returns; the Strain column only when the strain is not
%       'root', a species is returned and the strain differs from it.
%     - parseNCBItaxonomy reads the NCBI Taxonomy web page (internet). Tests never use the
%       internet, so the test writes a stand-in parseNCBItaxonomy.m with fixed lineages to a
%       temporary folder and runs the function from that folder: MATLAB finds functions and
%       files of the current folder before those on the path, so the stand-in and the two
%       hand-written information tables are used and no path is changed. The test checks
%       that the stand-in is the function found before calling. Expected tables follow from
%       the rules above applied by hand to the stand-in lineages.
%
% Function under test:
%     src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/updateTaxonomyInfoAGORA.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-written spreadsheets and a stand-in for the NCBI
%     look-up in a temporary folder.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The row counter is printed for every strain
%       SEVERITY: cosmetic
%       TRIGGER: updateTaxonomyInfoAGORA() with information tables of one or more strains
%       OBSERVED: "i = 2", "i = 3", ... printed for every row of both tables (the statement
%         i has no semicolon)
%       EXPECTED: no console output, or progress gated behind a print level
%       LINES: 38, 87
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testUpdateTaxonomyInfoAGORA'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

sandboxDir = tempname;
mkdir(sandboxDir);

% stand-in lineages by NCBI ID: 101 all ranks; 102 strain 'root'; 103 no species; 104 strain
% equal to the species; 105 empty strain and genus; 106 nothing found
stubLines = {
    'function taxonomy = parseNCBItaxonomy(NCBI)'
    '% stand-in for the NCBI look-up written by testUpdateTaxonomyInfoAGORA'
    'switch NCBI'
    '    case 101'
    '        taxonomy = struct(''superkingdom'', ''Bacteria'', ''phylum'', ''Phy1'', ''class'', ''Cla1'', ''order'', ''Ord1'', ...'
    '            ''family'', ''Fam1'', ''genus'', ''Gen1'', ''species'', ''Spe1'', ''strain'', ''Str1'');'
    '    case 102'
    '        taxonomy = struct(''strain'', ''root'', ''species'', ''Spe2'', ''genus'', ''Gen2'');'
    '    case 103'
    '        taxonomy = struct(''strain'', ''Str3'', ''genus'', ''Gen3'');'
    '    case 104'
    '        taxonomy = struct(''strain'', ''Spe4'', ''species'', ''Spe4'', ''family'', ''Fam4'');'
    '    case 105'
    '        taxonomy = struct(''strain'', '''', ''species'', ''Spe5'', ''genus'', '''');'
    '    otherwise'
    '        taxonomy = struct();'
    'end'
    'end'};
fid = fopen(fullfile(sandboxDir, 'parseNCBItaxonomy.m'), 'w');
fprintf(fid, '%s\n', stubLines{:});
fclose(fid);

% information tables: every taxonomy column holds an old value
header = {'MicrobeID', 'Strain', 'Species', 'Genus', 'Family', 'Order', 'Class', 'Phylum', ...
    'Kingdom', 'NCBI Taxonomy ID'};
oldValues = {'oS', 'oSp', 'oG', 'oF', 'oO', 'oC', 'oP', 'oK'};
agoraIds = [101; 102; 103; 104; 105; 106];
agoraTable = [header; [arrayfun(@(k) sprintf('m%d', k), agoraIds, 'UniformOutput', false), ...
    repmat(oldValues, numel(agoraIds), 1), num2cell(agoraIds)]];
agora2Ids = [104; 101];
agora2Table = [header; [arrayfun(@(k) sprintf('n%d', k), agora2Ids, 'UniformOutput', false), ...
    repmat(oldValues, numel(agora2Ids), 1), num2cell(agora2Ids)]];
writetable(cell2table(agoraTable), fullfile(sandboxDir, 'AGORA_infoFile.xlsx'), 'WriteVariableNames', false);
writetable(cell2table(agora2Table), fullfile(sandboxDir, 'AGORA2_infoFile.xlsx'), 'WriteVariableNames', false);

% the updated rows (columns Strain to Kingdom) expected from the stand-in lineages
updated = containers.Map('KeyType', 'double', 'ValueType', 'any');
updated(101) = {'Str1', 'Spe1', 'Gen1', 'Fam1', 'Ord1', 'Cla1', 'Phy1', 'Bacteria'};
updated(102) = {'oS', 'Spe2', 'Gen2', 'oF', 'oO', 'oC', 'oP', 'oK'};
updated(103) = {'oS', 'oSp', 'Gen3', 'oF', 'oO', 'oC', 'oP', 'oK'};
updated(104) = {'oS', 'Spe4', 'oG', 'Fam4', 'oO', 'oC', 'oP', 'oK'};
updated(105) = {'oS', 'Spe5', 'oG', 'oF', 'oO', 'oC', 'oP', 'oK'};
updated(106) = oldValues;

%% both information tables are updated in the current folder

cd(sandboxDir);
rehash
% the stand-in is the function found, so the NCBI web page is not read
assert(strcmp(which('parseNCBItaxonomy'), fullfile(sandboxDir, 'parseNCBItaxonomy.m')));
updateTaxonomyInfoAGORA();

% AGORA: the rules applied to every lineage; identifiers and NCBI IDs unchanged
writtenTable = readcell(fullfile(sandboxDir, 'AGORA_infoFile.xlsx'));
assert(isequal(writtenTable(1, :), header));
assert(isequal(writtenTable(2:end, [1 10]), agoraTable(2:end, [1 10])));
for k = 1:numel(agoraIds)
    assert(isequal(writtenTable(k + 1, 2:9), updated(agoraIds(k))));
end

% AGORA2: processed independently of the first table
writtenTable = readcell(fullfile(sandboxDir, 'AGORA2_infoFile.xlsx'));
assert(isequal(writtenTable(1, :), header));
assert(isequal(writtenTable(2:end, [1 10]), agora2Table(2:end, [1 10])));
for k = 1:numel(agora2Ids)
    assert(isequal(writtenTable(k + 1, 2:9), updated(agora2Ids(k))));
end

%% clean up

% leave the folder and forget the stand-in, so that parseNCBItaxonomy is the toolbox function
cd(fileDir);
clear parseNCBItaxonomy
rmdir(sandboxDir, 's');
rehash

% change the directory
cd(currentDir)
