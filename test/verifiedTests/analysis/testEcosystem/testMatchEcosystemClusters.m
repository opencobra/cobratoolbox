% The COBRAToolbox: testMatchEcosystemClusters.m
%
% Purpose:
%     - matchEcosystemClusters(refValues, refRxnIds, repValues, rxnIds, clusters) relabels the
%       clusters of a scenario so that they match the clusters of a reference scenario (the
%       first reference cluster whose representative states agree on all shared reactions with
%       defined states), gives new labels to clusters without a match and appends their states
%       to the reference. The function is quarantined (feature
%       20261113-142115-test-backfill-tiers): this file asserts nothing about it until the
%       defect below is fixed.
%
% Function under test:
%     src/analysis/ecosystem/matchEcosystemClusters.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built matrices of representative states.
%
% Coverage exemptions:
%     every line — matchEcosystemClusters is quarantined for the defect below (feature 20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: clusters without points are matched to a reference cluster instead of NaN, and
%       an empty reference cluster absorbs unmatched clusters
%       SEVERITY: wrong-result
%       TRIGGER: a cluster without points, whose column of representative states is all NaN
%                (as getEcosystemClusterReactionValues returns it), in repValues or refValues;
%                e.g. refValues = [1 2; 0 NaN; -1 -1], refRxnIds = {'R1'; 'R2'; 'R3'},
%                repValues = [0 3 7 NaN; 1 2 9 NaN; 5 5 5 NaN], rxnIds = {'R2'; 'R1'; 'R4'},
%                clusters = [1; 2; 3; 3; 1]; and, matching a clustering with itself,
%                eco = struct('qualVectors', [1 0; 1 0; 2 3], 'clusters', [1; 1; 3], 'k', 3,
%                'rxn2cluster', {{'R1'; 'R2'}}),
%                [~, v, ids] = getEcosystemClusterReactionValues(eco, 'thr', 0.8, 'changing', false),
%                [newClusters, ~, clusterMap] = matchEcosystemClusters(v, ids, v, ids, eco.clusters)
%       OBSERVED: MATLAB 2026-11-13: first call: clusterMap = [1; 2; 3; 1] (cluster 4 has no
%                 points); second call: v = [1 NaN 2; 0 NaN 3], clusterMap = [1; 1; 2] and
%                 newClusters = [1; 1; 2]: the empty cluster 2 is mapped to 1 and cluster 3 is
%                 relabelled 2, the empty reference cluster, because a column without defined
%                 states agrees vacuously with every column (line 63)
%       EXPECTED: clusterMap NaN for clusters without points (documented output: first call
%                 clusterMap = [1; 2; 3; NaN]); by the evident intent, a reference cluster
%                 without points is no match, so matching a clustering with itself returns its
%                 own labels: newClusters = [1; 1; 3], clusterMap = [1; NaN; 3]
%       LINES: 58-67
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMatchEcosystemClusters'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
