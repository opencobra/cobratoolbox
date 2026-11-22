% The COBRAToolbox: testClusterEcosystemPoints.m
%
% Purpose:
%     - clusterEcosystemPoints groups the analyzed points of an ecosystem grid by their
%       qualitative flux vectors (hierarchical clustering cut to at most k clusters, or DBSCAN)
%       and returns the cluster of each point and the number of clusters k (also stored in
%       eco.k). The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): for the hierarchical method the returned number of clusters is the requested
%       maximum, not the number of clusters formed (defect below), so no assertion about the
%       function is made here. The clustering itself is compared with SciPy in
%       testEcosystemClustering.m.
%
% Function under test:
%     src/analysis/ecosystem/clusterEcosystemPoints.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use a hand-built matrix of qualitative states.
%
% Coverage exemptions:
%     every line - clusterEcosystemPoints is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The hierarchical method returns the requested maximum k as the number of clusters
%       SEVERITY: wrong-result
%       TRIGGER: eco = struct('qualVectors', [1 0 0; 1 0 0; 0 3 0; 0 3 1]);
%         [eco, clusters, k] = clusterEcosystemPoints(eco, 'printLevel', 0) (default k = 20)
%       OBSERVED: clusters = [1 2 3 4], k = 20 and eco.k = 20; getEcosystemClusterReactionValues
%         then returns 20 columns, 16 of them NaN for empty clusters, and with 'changing' true
%         it counts the NaN of the empty clusters as a change
%       EXPECTED: k = eco.k = 4, the number of clusters (OUTPUTS: "k: number of clusters",
%         "eco.k (number of clusters)"), as the dbscan branch does with numel(unique(labels))
%       LINES: 173, 185
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testClusterEcosystemPoints'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
