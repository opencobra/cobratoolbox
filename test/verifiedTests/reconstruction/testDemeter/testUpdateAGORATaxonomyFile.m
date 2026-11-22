% The COBRAToolbox: testUpdateAGORATaxonomyFile.m
%
% Purpose:
%     - updateAGORATaxonomyFile(version) reads AGORA_infoFile.xlsx ('AGORA') or
%       AGORA2_infoFile.xlsx ('AGORA2'), looks up the NCBI Taxonomy lineage of every strain
%       with parseNCBItaxonomy (column 'NCBI Taxonomy ID'), writes every rank that the
%       lineage holds into the column of that rank (strain to Strain, ..., phylum to Phylum;
%       kingdom and superkingdom both to Kingdom, superkingdom last, so it wins), writes the
%       table back under the same name in the current folder and returns it. Any other
%       version raises an error.
%     - parseNCBItaxonomy reads the NCBI Taxonomy web page (internet). Tests never use the
%       internet, so the test writes a stand-in parseNCBItaxonomy.m with fixed lineages to a
%       temporary folder and runs the function from that folder: MATLAB finds functions and
%       files of the current folder before those on the path, so the stand-in and the two
%       hand-written information tables are used and no path is changed. The test checks
%       that the stand-in is the function found before calling. Expected tables follow from
%       the rules above applied by hand to the stand-in lineages.
%
% Function under test:
%     src/reconstruction/demeter/src/integration/updateAGORATaxonomyFile.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-written spreadsheets and a stand-in for the NCBI
%     look-up in a temporary folder.
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
fileDir = fileparts(which('testUpdateAGORATaxonomyFile'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

sandboxDir = tempname;
mkdir(sandboxDir);

% stand-in lineages by NCBI ID: 101 every rank with kingdom and superkingdom; 102 kingdom
% and genus only; 103 nothing found; 104 species and superkingdom only
stubLines = {
    'function taxonomy = parseNCBItaxonomy(NCBI)'
    '% stand-in for the NCBI look-up written by testUpdateAGORATaxonomyFile'
    'switch NCBI'
    '    case 101'
    '        taxonomy = struct(''superkingdom'', ''Bacteria'', ''kingdom'', ''King1'', ''phylum'', ''Phy1'', ...'
    '            ''class'', ''Cla1'', ''order'', ''Ord1'', ''family'', ''Fam1'', ''genus'', ''Gen1'', ...'
    '            ''species'', ''Spe1'', ''strain'', ''Str1'');'
    '    case 102'
    '        taxonomy = struct(''kingdom'', ''King2'', ''genus'', ''Gen2'');'
    '    case 104'
    '        taxonomy = struct(''species'', ''Spe4'', ''superkingdom'', ''Archaea'');'
    '    otherwise'
    '        taxonomy = struct();'
    'end'
    'end'};
fid = fopen(fullfile(sandboxDir, 'parseNCBItaxonomy.m'), 'w');
fprintf(fid, '%s\n', stubLines{:});
fclose(fid);

% information tables: the columns are found by their header, so they are not in the order
% of the ranks; every taxonomy column holds an old value
header = {'MicrobeID', 'NCBI Taxonomy ID', 'Kingdom', 'Strain', 'Phylum', 'Species', 'Class', ...
    'Genus', 'Order', 'Family'};
oldValues = {'oK', 'oS', 'oP', 'oSp', 'oC', 'oG', 'oO', 'oF'};
agoraTable = [header; {'m101', 101}, oldValues; {'m102', 102}, oldValues; {'m103', 103}, oldValues];
agora2Table = [header; {'n104', 104}, oldValues];
writetable(cell2table(agoraTable), fullfile(sandboxDir, 'AGORA_infoFile.xlsx'), 'WriteVariableNames', false);
writetable(cell2table(agora2Table), fullfile(sandboxDir, 'AGORA2_infoFile.xlsx'), 'WriteVariableNames', false);

% expected AGORA table, derived by hand from the stand-in lineages (columns in the order of
% the header: Kingdom, Strain, Phylum, Species, Class, Genus, Order, Family)
expectedAgora = [header
    {'m101', 101, 'Bacteria', 'Str1', 'Phy1', 'Spe1', 'Cla1', 'Gen1', 'Ord1', 'Fam1'}  % superkingdom wins
    {'m102', 102, 'King2', 'oS', 'oP', 'oSp', 'oC', 'Gen2', 'oO', 'oF'}                % kingdom alone
    {'m103', 103}, oldValues];                                                         % nothing found
expectedAgora2 = [header
    {'n104', 104, 'Archaea', 'oS', 'oP', 'Spe4', 'oC', 'oG', 'oO', 'oF'}];

cd(sandboxDir);
rehash
% the stand-in is the function found, so the NCBI web page is not read
assert(strcmp(which('parseNCBItaxonomy'), fullfile(sandboxDir, 'parseNCBItaxonomy.m')));

%% 'AGORA': the AGORA table is updated, returned and written back; AGORA2 is not touched

infoFile = updateAGORATaxonomyFile('AGORA');
% text and the numeric NCBI identifiers are compared exactly
assert(isequal(infoFile, expectedAgora));
assert(isequal(readcell(fullfile(sandboxDir, 'AGORA_infoFile.xlsx')), expectedAgora));
assert(isequal(readcell(fullfile(sandboxDir, 'AGORA2_infoFile.xlsx')), agora2Table));

%% 'AGORA2': the AGORA2 table is updated, returned and written back

infoFile = updateAGORATaxonomyFile('AGORA2');
assert(isequal(infoFile, expectedAgora2));
assert(isequal(readcell(fullfile(sandboxDir, 'AGORA2_infoFile.xlsx')), expectedAgora2));
% the AGORA table keeps the content of the first call
assert(isequal(readcell(fullfile(sandboxDir, 'AGORA_infoFile.xlsx')), expectedAgora));

%% any other version is rejected

assert(verifyCobraFunctionError('updateAGORATaxonomyFile', 'inputs', {'AGORA3'}, ...
    'outputArgCount', 1, 'testMessage', 'Not a valid version of AGORA!'));

%% clean up

% leave the folder and forget the stand-in, so that parseNCBItaxonomy is the toolbox function
cd(fileDir);
clear parseNCBItaxonomy
rmdir(sandboxDir, 's');
rehash

% change the directory
cd(currentDir)
