% The COBRAToolbox: testLoadSamples.m
%
% Purpose:
%     - loadSamples reads the sample files <filename>_1.mat ... <filename>_<numFiles>.mat
%       (variable points, variables x points, unfilled columns are zero at the end), skips the
%       first numSkipped files, and takes from each file either points at regular intervals
%       (default) or min(pointsPerFile, nPoints) points in random order (randPts = true); a
%       missing file stops the loading with a message. The function is QUARANTINED
%       (Constitution III-Defects, quarantine in back-fill campaigns): the default
%       regular-interval mode returns more points per file than pointsPerFile (defect below),
%       so no assertion about the function is made.
%
% Function under test:
%     src/analysis/sampling/loadSamples.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use hand-built sample files in a tempname
%     folder.
%
% Coverage exemptions:
%     every line - loadSamples is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: More points than pointsPerFile are taken from a file at regular intervals
%       SEVERITY: wrong-result
%       TRIGGER: points = [1:8 0 0; 11:18 0 0]; save('samples_1.mat', 'points');
%         loadSamples('samples', 1, 3) (and in general whenever pointsPerFile does not divide
%         the number of points of a file)
%       OBSERVED: 4 points (columns 1, 3, 5, 7) are returned: the step floor(8 / 3) = 2
%         gives ceil(8 / 2) points; loadSamples('samples', 1, 5) returns all 8 points (MATLAB
%         R2025a). Up to 2 * pointsPerFile - 1 points can be returned per file.
%       EXPECTED: the documented number of points to be taken from each file (pointsPerFile),
%         as the random selection does
%       LINES: 50-51
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testLoadSamples'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
