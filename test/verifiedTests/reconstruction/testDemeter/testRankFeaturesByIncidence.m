% The COBRAToolbox: testRankFeaturesByIncidence.m
%
% Purpose:
%     - rankFeaturesByIncidence(propertiesFolder, reconVersion) counts, for reaction
%       presence, metabolite presence, uptake/secretion and internal production, in how many
%       reconstructions each feature is non-zero (when at least 20 reconstructions are in the
%       file), ranks the features from most to least common, adds descriptions from the VMH
%       database (loadVMHDatabase) and writes a ranked table (.xls) and a plot per file to
%       Ranked_features. The function is QUARANTINED (Constitution III-Defects, quarantine
%       in back-fill campaigns): the column "Percentage of reconstructions" is not the
%       fraction of reconstructions; no assertion about the function is made.
%
% Function under test:
%     src/reconstruction/demeter/src/properties/rankFeaturesByIncidence.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would write the four property files and a small
%     VMH database (MetaboliteDatabase.txt, ReactionDatabase.txt) in a temporary folder and
%     save and restore the globals of loadVMHDatabase.
%
% Coverage exemptions:
%     every line - rankFeaturesByIncidence is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: the percentage of reconstructions is divided by the count of the most common feature
%       SEVERITY: wrong-result
%       TRIGGER: in folder d, ReactionMetabolitePresence/ReactionPresence_v.txt,
%         ReactionMetabolitePresence/MetabolitePresence_v.txt, ComputedFluxes/UptakeSecretion_v.txt
%         and ComputedFluxes/InternalProduction_v.txt, each with header {'Model_ID', 'ATPM',
%         'PGI'} and 20 strains, ATPM 1 in strains 1-10, PGI 1 in strains 1-4, 0 otherwise;
%         rankFeaturesByIncidence(d, 'v')
%       OBSERVED: (R2025a, 2026-11-15) Ranked_features/Reaction_presence_ranked_v.xls: ATPM
%         "Number of reconstructions" '10', "Percentage of reconstructions" '1'; PGI '4' and
%         '0.4' (lines 59 and 75 divide by max(B)); the plot (ylabel "Fraction of presence in
%         tested reconstructions") shows the same values
%       EXPECTED: 10/20 = 0.5 and 4/20 = 0.2, the fraction of the 20 reconstructions (or a
%         percentage) as the column header and the plot label say
%       LINES: 59, 75
%     - DEFECT: metabolite and uptake/secretion features are looked up in the reaction database
%       SEVERITY: cosmetic
%       TRIGGER: rankFeaturesByIncidence(d, 'v') with metabolite IDs (e.g. 'atp') in
%         MetabolitePresence_v.txt and '<exchange>_uptake'/'<exchange>_secretion' columns (as
%         computeUptakeSecretion writes them) in UptakeSecretion_v.txt
%       OBSERVED: (code reading, R2025a source of 2026-11-15) for i < 4 (line 46) every
%         feature is searched in database.reactions, so metabolite presence and
%         uptake/secretion features never get a description, formula or subsystem
%       EXPECTED: metabolite presence described from database.metabolites (as internal
%         production is) and uptake/secretion features described from their exchange reaction
%       LINES: 46, 51-56
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRankFeaturesByIncidence'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
