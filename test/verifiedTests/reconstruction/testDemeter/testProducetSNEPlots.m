% The COBRAToolbox: testProducetSNEPlots.m
%
% Purpose:
%     - producetSNEPlots(propertiesFolder, infoFilePath, reconVersion, customFeatures) embeds
%       reaction presence, metabolite presence, uptake/secretion and internal production of
%       the strains with t-SNE (tsne, Statistics and Machine Learning Toolbox), plots them by
%       taxon (gscatter) and by custom features (gscatter3) and writes the coordinates. The
%       function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns) for the defects below; no assertion about the function is made. Without
%       the defects, lines 176-224 and 252-280 would still need the Statistics and Machine
%       Learning Toolbox (tsne, gscatter), which the reference machine does not have.
%
% Function under test:
%     src/reconstruction/demeter/src/properties/producetSNEPlots.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would write the property files and the
%     information table in a temporary folder (and declare the Statistics and Machine
%     Learning Toolbox for the t-SNE lines).
%
% Coverage exemptions:
%     every line - producetSNEPlots is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: 16 to 19 taxa with few singletons raise an index error
%       SEVERITY: error
%       TRIGGER: info.txt (tab-separated: MicrobeID, Phylum, Class, Order, Family, Genus,
%         Species) for 32 strains m01..m32, every rank of strain k = P<ceil(k/2)> (16 taxa of
%         2 strains); ReactionMetabolitePresence/ReactionPresence_v.txt in folder d (header
%         row, one row per strain, 3 positive features); producetSNEPlots(d, 'd/info.txt', 'v')
%       OBSERVED: (R2025a, 2026-11-15) error "Index exceeds the number of array elements.
%         Index must not exceed 16." at line 160 (uniqueXX = uniqueXX(1:20) with 16 taxa),
%         before tsne is reached; the folder tSNE_Plots was created
%       EXPECTED: all taxa kept when there are fewer than 20 (keep the min(20, n) largest)
%       LINES: 155-160
%     - DEFECT: three t-SNE coordinates are stored in two columns
%       SEVERITY: error
%       TRIGGER: customFeatures given and at least 10 strains with information, so that
%         line 260 computes Y with 'NumDimensions' 3
%       OBSERVED: (R2025a, 2026-11-15; tsne is not installed, so the assignment of line 263
%         was run alone with a 10 x 3 Y) error "Unable to perform assignment because the size
%         of the left side is 10-by-2 and the size of the right side is 10-by-3."
%       EXPECTED: columns 3:5 (or a two-dimensional embedding), as the header of line 296
%         names only an x and a y value
%       LINES: 263
%     - DEFECT: the custom-feature branch filters on the taxa of the last taxon level
%       SEVERITY: cosmetic
%       TRIGGER: producetSNEPlots(d, info, 'v', {'Gram'}) with at least 10 strains
%       OBSERVED: (code reading, R2025a source of 2026-11-15) lines 246-248 remove rows where
%         taxa (the species list left by the taxon loop, already without 'N/A' and of
%         another length) is 'N/A', so they never remove anything; the strains whose feature
%         is 'N/A' are kept. Lines 66-67 already drop strains absent from the information
%         table, so no 'N/A' feature arises unless the first header of the property file is
%         itself an identifier of the information table
%       EXPECTED: the filter applied to feats (strains with no information on the feature
%         removed from data, red_orgs and feats)
%       LINES: 246-248
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testProducetSNEPlots'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
