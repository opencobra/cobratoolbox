% The COBRAToolbox: testCalculateInteractionsByTaxon.m
%
% Purpose:
%     - calculateInteractionsByTaxon counts, for each taxon on the levels phylum, class,
%       order, family and genus, how often each of the nine pairwise interaction outcomes
%       was predicted for its microbes (output of simulatePairwiseInteractions plus a taxon
%       table). The function is QUARANTINED (Constitution III-Defects, quarantine in
%       back-fill campaigns): it errors when the taxon table has fewer rows than columns
%       (defect below), so no assertion about the function is made.
%
% Function under test:
%     src/analysis/multiSpecies/microbiomeModelingToolbox/pairwiseInteractionModeling/calculateInteractionsByTaxon.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use hand-built cell tables.
%
% Coverage exemptions:
%     every line - calculateInteractionsByTaxon is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Errors when the taxon table has fewer rows than columns
%       SEVERITY: error
%       TRIGGER: pw = {'Pair', 'M1', 'M2', 'a', 'b', 'c', 'd', 'Outcome1', 'Outcome2';
%         'A_B', 'A', 'B', 0, 0, 0, 0, 'Competition', 'Competition'};
%         tx = {'ModelID', 'Genus', 'Family', 'Order', 'Class', 'Phylum';
%         'A', 'g1', 'f1', 'o1', 'c1', 'p1'; 'B', 'g2', 'f1', 'o1', 'c1', 'p1'};
%         calculateInteractionsByTaxon(pw, tx)
%       OBSERVED: MATLAB:badsubscript, Index in position 1 exceeds array bounds. Index must
%         not exceed 3. The loop on line 42 runs over length(taxonInformation), the larger
%         dimension (6 columns), instead of the 3 rows, and line 43 reads row 4.
%       EXPECTED: one Competition counted for each of g1 and g2, two for family f1 and for
%         every higher level (the header requires six columns and any number of microbes)
%       LINES: 42-43
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCalculateInteractionsByTaxon'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
