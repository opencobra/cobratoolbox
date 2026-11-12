% The COBRAToolbox: testTranslateMetagenome2AGORA.m
%
% Purpose:
%     - tests the basic functionality of translateMetagenome2AGORA
%     - Ensure that the organisms in the input file were correctly translated. This is the case
%       if all organisms in the output file correspond to an AGORA strain model or AGORA
%       pan-model. Note that this test cannot tell if the biological identity of the translated
%       organisms is correct as this requires manual inspection. Moreover, input files with
%       abundance data from other sources may fail due to differences in formatting and
%       nomenclature.
%     - The input is a small abundance table in MetaPhlAn notation and a small taxonomy table,
%       both written here to a temporary folder. The function writes its result to the current
%       folder, so the test runs inside that temporary folder.
%     - This test used to run only on Windows with an info file on the path and a file downloaded
%       from EMBL-EBI; everywhere else it printed a message and tested nothing (0 of 159 lines).
%
% Function under test:
%     src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/translateMetagenome2AGORA.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver; the tables are written by hand.
%
% Coverage exemptions:
%     Lines 226, 266-268, 271-272: unreachable on the supported MATLAB releases, these branches
%       only run on MATLAB older than R2020a (the text of version does not contain "(R202").
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Abundances read from a tsv file are added and normalized as text
%       SEVERITY: wrong-result
%       TRIGGER: an input file with the extension .tsv, the format named in the help text
%       OBSERVED: readInputTableForPipeline returns the numbers of a tsv file as text, so the two
%         rows of one taxon with 4 and 2 add up to 102 ('4' + '2') and the normalized abundances
%         of 4 and 3 are 0.5049 and 0.4951 (character codes) instead of 0.5714 and 0.4286
%       EXPECTED: the abundances are summed and normalized as numbers
%       LINES: 224, 258
%
% Authors:
%     - Almut Heinken - March 2019
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testTranslateMetagenome2AGORA'));
cd(fileDir);

% this test needs no solver, toolbox or particular operating system
prepareTest();

% work in a temporary folder, which is removed at the end or when the test fails
sandboxDir = tempname;
mkdir(sandboxDir);
cd(sandboxDir);
sandboxDir = pwd;  % the folder name as MATLAB reports it
leaveSandbox = onCleanup(@() cleanUpSandbox(currentDir, sandboxDir));

%% write the taxonomy of a tiny reconstruction resource
% columns of the AGORA info file; the two resources only differ by the name of the file
taxLevels = {'Species'; 'Genus'; 'Family'; 'Order'; 'Class'; 'Phylum'};
infoHeader = [taxLevels', {'ModelAGORA'}];
infoRows = {
    'Blautia hansenii', 'Blautia', 'Lachnospiraceae', 'Clostridiales', 'Clostridia', 'Firmicutes', 'Blautia_hansenii_DSM_20583'
    'Bacteroides caccae', 'Bacteroides', 'Bacteroidaceae', 'Bacteroidales', 'Bacteroidia', 'Bacteroidetes', 'Bacteroides_caccae_ATCC_43185'
    'unclassified', 'unclassified', 'unclassified', 'unclassified', 'unclassified', 'unclassified', 'unclassified_model'
    };
writetable(cell2table(infoRows, 'VariableNames', infoHeader), 'AGORA_infoFile.xlsx');
copyfile('AGORA_infoFile.xlsx', 'AGORA2_infoFile.xlsx');
% the sandbox is active: the tables that are read are the ones written here
assert(exist(fullfile(sandboxDir, 'AGORA_infoFile.xlsx'), 'file') == 2);

%% write the abundance table, one row per taxon in MetaPhlAn notation
firmicutes = 'k__Bacteria|p__Firmicutes|c__Clostridia|o__Clostridiales|f__Lachnospiraceae';
bacteroides = 'k__Bacteria|p__Bacteroidetes|c__Bacteroidia|o__Bacteroidales|f__Bacteroidaceae';
abundanceRows = {
    [firmicutes '|g__Blautia|s__hansenii'],                  4, 1, 0   % species without genus
    [bacteroides '|g__Bacteroides|s__Bacteroides_caccae'],   3, 1, 0   % species with genus
    [bacteroides '|g__Bacteroides|s__caccae'],               1, 2, 0   % same species again
    [bacteroides '|g__Bacteroides|s__Bacteroides_unclassified'], 9, 9, 0 % unclassified: dropped
    [bacteroides '|g__Fake|s__Fake_organism'],               6, 6, 6   % not in the resource
    [firmicutes '|g__Blautia|s__'],                          8, 8, 0   % empty species: a genus
    [firmicutes '|g__Blautia'],                              2, 2, 0   % same genus again
    [bacteroides '|g__Bacteroides'],                         5, 5, 0
    firmicutes,                                              5, 5, 0
    'k__Bacteria|p__Firmicutes|c__Clostridia|o__Clostridiales', 1, 1, 0
    'k__Bacteria|p__Firmicutes|c__Clostridia',               1, 1, 0
    'k__Bacteria|p__Firmicutes',                             1, 1, 0
    'k__Bacteria',                                           7, 7, 7   % no taxon level at all
    };
abundanceFile = 'abundances.txt';
fid = fopen(abundanceFile, 'w');
fprintf(fid, 'ID\tsample1\tsample2\tsample3\n');
for i = 1:size(abundanceRows, 1)
    fprintf(fid, '%s\t%g\t%g\t%g\n', abundanceRows{i, :});
end
fclose(fid);

%% every taxonomic level gives organisms of the resource, normalized per sample
for t = 1:size(taxLevels, 1)
    fprintf(' > Running translateMetagenome2AGORA with %s...\n', taxLevels{t});
    orgList = unique(infoRows(:, strcmp(taxLevels{t}, infoHeader)));
    orgList(strncmp('unclassified', orgList, 12)) = [];
    [translatedAbundances, normalizedAbundances, unmappedRows] = ...
        translateMetagenome2AGORA(abundanceFile, taxLevels{t});

    % Verify that the output file is not empty
    assert(size(translatedAbundances, 1) > 1)

    % Find the overlap between translated organisms and AGORA organisms
    translatedOrgs = translatedAbundances(2:end, 1);
    translatedOrgs = strrep(translatedOrgs, 'pan', '');
    translatedOrgs = strrep(translatedOrgs, '_', ' ');
    C = intersect(translatedOrgs, orgList);

    % Verify that all output organisms overlap with AGORA organisms
    assert(length(translatedOrgs) == length(C))

    % Verify that the relative abundances for each sample sum up to at most 1
    for i = 2:size(normalizedAbundances, 2)
        assert(sum(cell2mat(normalizedAbundances(2:end, i))) - 1 < 0.0001)
    end
end

%% the values on species level, worked out by hand from the table above
[translatedAbundances, normalizedAbundances, unmappedRows] = ...
    translateMetagenome2AGORA(abundanceFile, 'Species', 'AGORA');
% the two rows of Bacteroides caccae are summed, unclassified taxa and other levels are gone
assert(isequal(translatedAbundances(:, 1), {''; 'panBlautia_hansenii'; 'panBacteroides_caccae'}))
assert(isequal(cell2mat(translatedAbundances(2:end, 2:end)), [4, 1, 0; 4, 3, 0]))
% each sample sums to one; the third sample only holds taxa outside the resource and stays zero
assert(isequal(cell2mat(normalizedAbundances(2:end, 2:end)), [0.5, 0.25, 0; 0.5, 0.75, 0]))
% the taxa that were not found are reported, next to the header
assert(isempty(setxor(unmappedRows, {''; 'panFake_organism'; 'pank_Bacteria'})))

%% the result is written to the current folder
outputFile = dir(fullfile(sandboxDir, 'translatedAbundances*'));
assert(numel(outputFile) == 1);
writtenText = fileread(fullfile(sandboxDir, outputFile.name));
assert(contains(writtenText, 'panBacteroides_caccae'));

%% the depth and the resource have defaults, and AGORA2 is read from its own file
defaultAbundances = translateMetagenome2AGORA(abundanceFile);
assert(isequal(defaultAbundances, translatedAbundances))
agora2Abundances = translateMetagenome2AGORA(abundanceFile, 'Species', 'AGORA2');
assert(isequal(agora2Abundances, translatedAbundances))

%% another resource is refused
assert(verifyCobraFunctionError('translateMetagenome2AGORA', ...
    'inputs', {abundanceFile, 'Species', 'OTHER'}, ...
    'testMessage', 'Incorrect input for reconstruction resource!'));

% leave and remove the temporary folder
clear leaveSandbox

% output a success message
fprintf('Done.\n');


function cleanUpSandbox(startDir, sandboxDir)
    % returns to the folder where the test started and removes the temporary folder
    cd(startDir);
    rmdir(sandboxDir, 's');
end
