% The COBRAToolbox: testGetSubsystemPresence.m
%
% Purpose:
%     - getSubsystemPresence(propertiesFolder, reconVersion) reads the reactions of a
%       reconstruction resource (Reactions_<reconVersion>.txt, 12 columns in the layout of
%       the VMH reaction database, column 11 the subsystem) and the reaction presence of
%       every reconstruction (ReactionMetabolitePresence/reactionPresence_<reconVersion>.txt,
%       one row per reconstruction, one 0/1 column per reaction) and writes
%       ReactionMetabolitePresence/SubsystemPresence_<reconVersion>.txt: one column per
%       non-empty subsystem (sorted), one row per reconstruction, value = number of the
%       subsystem's reactions present in the reconstruction / number of reactions of the
%       subsystem in the resource.
%     - The Reactions file has no header row, as printReconstructionContent writes it;
%       every row, including the first, is a reaction. The test writes both files by hand in
%       a temporary folder; expected fractions are counted by hand.
%
% Function under test:
%     src/reconstruction/demeter/src/properties/getSubsystemPresence.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-written text files in a temporary folder.
%
% Coverage exemptions:
%     Line 43: branch for MATLAB releases before R2020a (version-specific; the test machines
%     run R2020a or newer, where contains(version, '(R202') is true).
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetSubsystemPresence'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

propertiesFolder = tempname;
mkdir(fullfile(propertiesFolder, 'ReactionMetabolitePresence'));

% reactions of the resource (columns: ID, description, formula, reversible, confidence,
% notes, references, EC number, KEGG ID, date, subsystem, general subsystem): Glycolysis 2,
% TCA 3, Transport 1 (absent from the presence file), and one reaction without subsystem
reactionIds = {'PGI'; 'PFK'; 'CS'; 'ACONT'; 'ICDH'; 'EX_glc_D(e)'; 'GLCt'};
subsystems = {'Glycolysis'; 'Glycolysis'; 'TCA'; 'TCA'; 'TCA'; ''; 'Transport'};
nRxns = numel(reactionIds);
fillColumn = @(prefix) arrayfun(@(k) sprintf('%s%d', prefix, k), (1:nRxns)', 'UniformOutput', false);
reactionTable = [reactionIds, fillColumn('desc'), fillColumn('form'), fillColumn('rev'), ...
    fillColumn('conf'), fillColumn('note'), fillColumn('ref'), fillColumn('ec'), ...
    fillColumn('kegg'), fillColumn('date'), subsystems, fillColumn('gen')];
fid = fopen(fullfile(propertiesFolder, 'Reactions_v.txt'), 'w');
for i = 1:nRxns
    fprintf(fid, '%s\n', strjoin(reactionTable(i, :), sprintf('\t')));
end
fclose(fid);

% reaction presence of three reconstructions
presenceHeader = {'Model_ID', 'PGI', 'PFK', 'CS', 'ACONT', 'ICDH', 'EX_glc_D(e)'};
presenceRows = {
    'm1', 1, 1, 1, 0, 0, 1
    'm2', 0, 1, 1, 1, 1, 0
    'm3', 0, 0, 0, 0, 0, 1};
writetable(cell2table([presenceHeader; presenceRows]), ...
    fullfile(propertiesFolder, 'ReactionMetabolitePresence', 'reactionPresence_v.txt'), ...
    'FileType', 'text', 'WriteVariableNames', false, 'Delimiter', 'tab');

%% fraction of the reactions of each subsystem present in each reconstruction

getSubsystemPresence(propertiesFolder, 'v');

outputFile = fullfile(propertiesFolder, 'ReactionMetabolitePresence', 'SubsystemPresence_v.txt');
assert(isfile(outputFile));
written = readcell(outputFile, 'FileType', 'text', 'Delimiter', '\t');
% sorted non-empty subsystems; the reaction without subsystem gives no column
assert(isequal(written(1, :), {'Model_ID', 'Glycolysis', 'TCA', 'Transport'}));
% reconstructions in the order of the presence file
assert(isequal(written(2:end, 1), {'m1'; 'm2'; 'm3'}));
% hand count: Glycolysis {PGI, PFK}, TCA {CS, ACONT, ICDH}, Transport {GLCt} (present in no
% reconstruction file, so 0/1). The values are written with num2str (at least 5
% significant digits), hence the tolerance of 1e-4
expectedFractions = [2/2, 1/3, 0
                     1/2, 3/3, 0
                     0,   0,   0];
assert(max(max(abs(cell2mat(written(2:end, 2:end)) - expectedFractions))) < 1e-4);

%% clean up

rmdir(propertiesFolder, 's');

% change the directory
cd(currentDir)
