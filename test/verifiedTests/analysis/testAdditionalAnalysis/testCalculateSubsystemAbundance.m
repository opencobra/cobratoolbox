% The COBRAToolbox: testCalculateSubsystemAbundance.m
%
% Purpose:
%     - calculateSubsystemAbundance reads a table of reaction abundances (reactions as rows,
%       microbiome models as columns), removes the biomass reactions (identifiers starting
%       with 'bio') and, for every subsystem of the VMH reaction database, returns the sum of
%       the abundances of its reactions that are in the table divided by the number of these
%       reactions (the fraction of the highest possible subsystem abundance). Reactions of
%       the table that are not in the database and database reactions without subsystem are
%       ignored; the subsystems are sorted alphabetically.
%     - The test writes a small VMH database and an abundance table to a temporary folder
%       and runs the function there (loadVMHDatabase reads the files of the current folder
%       first). Expected values are hand calculations from the table.
%     - The globals of loadVMHDatabase are restored at the end.
%
% Function under test:
%     src/analysis/multiSpecies/microbiomeModelingToolbox/additionalAnalysis/calculateSubsystemAbundance.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-written database and abundance files in a temporary
%     folder.
%
% Coverage exemptions:
%     Line 52: branch for MATLAB releases before R2020a (version-specific; the test machines
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
fileDir = fileparts(which('testCalculateSubsystemAbundance'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% save the global variables read by loadVMHDatabase (no additional reactions in this test)
globalsBefore = who('global');
global additionalSecretionRxns additionalUptakeRxns
savedSecretion = additionalSecretionRxns;
savedUptake = additionalUptakeRxns;
additionalSecretionRxns = [];
additionalUptakeRxns = [];

% the VMH database of the test: EX_atp(e) and EX_lac_L(e) (Exchange), ATPM (Energy), PGI
% and PFK (Glycolysis) and NOSUB (no subsystem)
sandboxDir = tempname;
mkdir(sandboxDir);
writeTestDatabase(sandboxDir);
cd(sandboxDir);

%% subsystem abundances of two microbiome models

% EX_lac_L(e) is not in the table, so Exchange holds EX_atp(e) only; biomass525 is removed,
% UNKNOWN is not in the database and NOSUB has no subsystem
abundanceFile = fullfile(sandboxDir, 'ReactionAbundance.csv');
fid = fopen(abundanceFile, 'w');
fprintf(fid, 'Reaction,S1,S2\n');
fprintf(fid, 'EX_atp(e),0.5,1\nATPM,1,0.2\nPGI,1,0\nPFK,0.5,0.25\nbiomass525,1,1\nUNKNOWN,1,1\nNOSUB,1,1\n');
fclose(fid);
subsystemAbundance = calculateSubsystemAbundance(abundanceFile);
assert(isequal(subsystemAbundance(:, 1), {'Subsystems'; 'Energy'; 'Exchange'; 'Glycolysis'}));
assert(isequal(subsystemAbundance(1, :), {'Subsystems', 'S1', 'S2'}));
% Energy = ATPM; Exchange = EX_atp(e); Glycolysis = (PGI + PFK) / 2. The values are sums
% and halves of decimal inputs, so a tolerance of 1e-12 covers the rounding
expected = [1 0.2; 0.5 1; 0.75 0.125];
assert(max(max(abs(cell2mat(subsystemAbundance(2:end, 2:end)) - expected))) < 1e-12);

%% a single model and a table without any reaction of a subsystem

% only PFK of Glycolysis and no Exchange or Energy reaction: one subsystem
fid = fopen(abundanceFile, 'w');
fprintf(fid, 'Reaction,M1\nPFK,0.4\nbiomass_x,1\n');
fclose(fid);
subsystemAbundance = calculateSubsystemAbundance(abundanceFile);
assert(isequal(subsystemAbundance(:, 1), {'Subsystems'; 'Glycolysis'}));
assert(abs(subsystemAbundance{2, 2} - 0.4) < 1e-12);

%% clean up

cd(fileDir);
rmdir(sandboxDir, 's');
additionalSecretionRxns = savedSecretion;
additionalUptakeRxns = savedUptake;
newGlobals = setdiff(who('global'), globalsBefore);
if ~isempty(newGlobals)
    clearvars('-global', newGlobals{:});
end

% change the directory
cd(currentDir)

function writeTestDatabase(sandboxDir)
% writes MetaboliteDatabase.txt (13 tab-separated columns, no header) and
% ReactionDatabase.txt (12 columns, header) as read by loadVMHDatabase; the reaction
% fields contain no blank, so that readtable detects the tab as in the full database
metaboliteRows = {
    'ac',    'Acetate',    'C2H3O2',        'C2H3O2',        '-1', 'C00033', '176',  '30089', '', '', 'HMDB00042', '19/09/2018', 'Pyruvate metabolism'
    'atp',   'ATP',        'C10H12N5O13P3', 'C10H12N5O13P3', '-4', 'C00002', '5957', '15422', '', '', 'HMDB00538', '19/09/2018', 'Nucleotide'
    'h2o',   'Water',      'H2O',           'H2O',           '0',  'C00001', '962',  '15377', '', '', 'HMDB02111', '19/09/2018', ''
    'glc_D', 'D-Glucose',  '',              'C6H12O6',       '0',  'C00031', '',     '',      '', '', '',          '19/09/2018', 'Glycolysis'
    'lac_L', 'L-Lactate',  '',              'C3H5O3',        '-1', 'C00186', '',     '422',   '', '', '',          '19/09/2018', 'Pyruvate metabolism'
    'but',   'Butyrate (C4:0)/x', '',       'C4H7O2',        '-1', 'C00246', '',     '',      '', '', '',          '19/09/2018', 'Fatty acid'};
reactionHeader = {'ReactionID', 'Description', 'Formula', 'Reversible', 'ConfidenceScore', 'Notes', ...
    'References', 'ECNumber', 'KEGGID', 'LastModified', 'Subsystem', 'Subsystem_general'};
reactionRows = {
    'EX_atp(e)',   'ATP_exchange',        'atp[e]<=>',             '1', '0', '', '', '', '', '19/09/2018', 'Exchange',   'Exchange'
    'EX_lac_L(e)', 'Lactate_exchange',    'lac_L[e]<=>',           '1', '0', '', '', '', '', '19/09/2018', 'Exchange',   'Exchange'
    'ATPM',        'ATP_maintenance',     'atp[c]+h2o[c]->adp[c]', '0', '1', '', '', '', '', '19/09/2018', 'Energy',     'Energy'
    'PGI',         'Glucose_isomerase',   'g6p[c]<=>f6p[c]',       '1', '1', '', '', '', '', '19/09/2018', 'Glycolysis', 'Carbohydrate'
    'PFK',         'Phosphofructokinase', 'f6p[c]->fdp[c]',        '0', '1', '', '', '', '', '19/09/2018', 'Glycolysis', 'Carbohydrate'
    'NOSUB',       'No_subsystem',        'a[c]->b[c]',            '0', '1', '', '', '', '', '19/09/2018', '',           ''};
fid = fopen(fullfile(sandboxDir, 'MetaboliteDatabase.txt'), 'w');
for i = 1:size(metaboliteRows, 1)
    fprintf(fid, '%s\n', strjoin(metaboliteRows(i, :), sprintf('\t')));
end
fclose(fid);
fid = fopen(fullfile(sandboxDir, 'ReactionDatabase.txt'), 'w');
fprintf(fid, '%s\n', strjoin(reactionHeader, sprintf('\t')));
for i = 1:size(reactionRows, 1)
    fprintf(fid, '%s\n', strjoin(reactionRows(i, :), sprintf('\t')));
end
fclose(fid);
end
