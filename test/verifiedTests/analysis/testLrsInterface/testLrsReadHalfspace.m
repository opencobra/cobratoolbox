% The COBRAToolbox: testLrsReadHalfspace.m
%
% Purpose:
%     - lrsReadHalfspace(modelName, param) reads an lrs H-representation file <modelName>.ine
%       (with the _pos_ineq/_neg_ineq and _noR suffixes chosen by param) into A, b and csense,
%       the linearity rows becoming 'E' and the others 'G'. The function is QUARANTINED
%       (Constitution III-Defects, quarantine in back-fill campaigns): a row written with
%       rational coefficients (x/y), which lrs itself writes, is returned as a row of zeros;
%       no assertion about the function is made.
%
% Function under test:
%     src/analysis/topology/extremeRays/lrs/lrsInterface/lrsReadHalfspace.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - no solver; a test would write .ine files in a temporary folder and compare the
%     matrices read back with the hand-written coefficients.
%
% Coverage exemptions:
%     every line - lrsReadHalfspace is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: a row with rational coefficients is read as a row of zeros
%       SEVERITY: wrong-result
%       TRIGGER: a file r.ine holding "r / H-representation / begin / 2 3 rational / 1/2 1 0 /
%         0 0 1 / end", then [A, b, csense] = lrsReadHalfspace('r.ine', struct('inequality', 0))
%       OBSERVED: A = [0 0; 0 1], b = [0; 0], csense = 'GG' (R2025a, 2026-11-16): the branch for
%         rows with '/' converts the scanned values (and divides the integer part by the
%         fractional part, 1/2 -> 1.2 -> 1 / 0.2) but never stores them in A, so the row stays
%         zero; the integer file "-2 1 1 / 0 0 1" with linearity 1 1 is read correctly
%       EXPECTED: A = [1 0; 0 1], b = [-1/2; 0] (the H-representation 1/2 + x1 >= 0, x2 >= 0)
%       LINES: 163-176
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testLrsReadHalfspace'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so nothing is run;
% the call is the standard opening of a COBRA test
prepareTest();

% change the directory
cd(currentDir)
