% The COBRAToolbox: testComputeMetabolicDistance.m
%
% Purpose:
%     - computeMetabolicDistance(propertiesFolder, reconVersion, numWorkers) should compute
%       the Jaccard distance between every pair of strains for reaction presence and for
%       uptake/secretion potential, write MetabolicDistance_<reconVersion>.txt and plot the
%       two distances against each other. The function is QUARANTINED (Constitution
%       III-Defects, quarantine in back-fill campaigns): it raises an error for every input;
%       no assertion about the function is made.
%
% Function under test:
%     src/reconstruction/demeter/src/properties/computeMetabolicDistance.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would write the two property files in a
%     temporary folder.
%
% Coverage exemptions:
%     every line - computeMetabolicDistance is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: the distances are stored in comDistTmp but read from the undefined comDist
%       SEVERITY: error
%       TRIGGER: ComputedFluxes/UptakeSecretion_v.txt and ReactionPresence/ReactionPresence_v.txt
%         in a folder d, each with a header row and 101 strains x 3 features of 0/1, then
%         computeMetabolicDistance(d, 'v', 0) run from d
%       OBSERVED: (R2025a, 2026-11-15) error "Unrecognized function or variable 'comDist'."
%         at line 52; comDistTmp.mat was written to the current folder first
%       EXPECTED: the pairwise distances of the first file stored in column 3 of the table
%       LINES: 38-41, 52, 54
%     - DEFECT: the blocks of 100 rows run past the last strain
%       SEVERITY: error
%       TRIGGER: the same two files with 3 strains x 2 features, then
%         computeMetabolicDistance(d, 'v', 0)
%       OBSERVED: (R2025a, 2026-11-15) error "Index in position 1 exceeds array bounds. Index
%         must not exceed 4." at line 38 (the parfor over k = j:j+99 reads data(k, k+1:end))
%       EXPECTED: one distance per pair of the 3 strains; the loop limited to the rows that
%         exist (and the distance taken between strains, not along a diagonal of the table)
%       LINES: 37-39
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testComputeMetabolicDistance'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
