% The COBRAToolbox: testSummarizeFeaturesOnTaxonLevels.m
%
% Purpose:
%     - summarizeFeaturesOnTaxonLevels(propertiesFolder, infoFilePath, reconVersion,
%       customFeatures) sums reaction presence, metabolite presence, uptake/secretion and
%       internal production of the refined strains per species, genus, family, order, class
%       and phylum (and per custom feature), normalises each taxon to its largest value,
%       plots a clustered heat map (cobraClustergram) and writes the tables. The function
%       is QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns): it
%       raises an error for every input that reaches a summary; no assertion about the
%       function is made.
%
% Function under test:
%     src/reconstruction/demeter/src/properties/summarizeFeaturesOnTaxonLevels.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would write the property files and the
%     information table in a temporary folder.
%
% Coverage exemptions:
%     every line - summarizeFeaturesOnTaxonLevels is quarantined for the defects below
%     (feature 20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: the row range is built from size(getTax), a two-element vector
%       SEVERITY: error
%       TRIGGER: in folder d, Refined/ReactionMetabolitePresence/reactionPresence_v_refined.txt
%         ({'', 'r1', 'r2'; 's1', 1, 0; 's2', 1, 1; 's3', 0, 1}) and info3.txt (MicrobeID,
%         Phylum, Class, Order, Family, Genus, Species, Gram for s1-s3);
%         summarizeFeaturesOnTaxonLevels(d, 'd/info3.txt', 'v'); and, with an information
%         table of one strain, summarizeFeaturesOnTaxonLevels(d, 'd/info1.txt', 'v', {'Gram'})
%       OBSERVED: (R2025a, 2026-11-15) error "Colon operands must be real scalars." at line
%         49 (taxon levels) and at line 105 (custom features)
%       EXPECTED: rows 2:numel(getTax)+1 filled with the taxa
%       LINES: 49, 105
%     - DEFECT: the table of taxon level i is named with the file prefix of row i
%       SEVERITY: error
%       TRIGGER: the first call above once line 49 is fixed (more than 4 taxon levels)
%       OBSERVED: (code reading, R2025a source of 2026-11-15) line 91 indexes files{i,1} with
%         the taxon-level index i = 1..6 although files has 4 rows: index error at the
%         Class level, and the tables of every property file are written under the prefixes
%         ReactionPresence_ to InternalProduction_ by taxon level, overwriting each other
%       EXPECTED: files{f,1} (the prefix of the property file being summarised); the same
%         applies to line 151
%       LINES: 91, 151
%     - DEFECT: numeric presence values become NaN on R2020a and newer
%       SEVERITY: wrong-result
%       TRIGGER: the first call above once line 49 is fixed
%       OBSERVED: (R2025a, 2026-11-15) readInputTableForPipeline returns the presence values
%         as numbers ({'m1', [1]}), and str2double({1, 0}) is [NaN NaN], so line 55 makes
%         every taxon sum NaN, normalised to 0 by lines 72-78 (line 112 has the version
%         branch that line 55 lacks)
%       EXPECTED: the sums of the 0/1 presence values of the strains of each taxon
%       LINES: 55
%     - DEFECT: undefined variable ddataByFeature
%       SEVERITY: error
%       TRIGGER: customFeatures given, once line 105 is fixed
%       OBSERVED: (code reading, R2025a source of 2026-11-15) line 126 reads
%         size(ddataByFeature, 1); ddataByFeature is defined nowhere in the file, so the
%         custom-feature branch raises "Unrecognized function or variable" and the heat map
%         of line 140 is never drawn
%       EXPECTED: size(dataByFeature, 1)
%       LINES: 126
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSummarizeFeaturesOnTaxonLevels'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
