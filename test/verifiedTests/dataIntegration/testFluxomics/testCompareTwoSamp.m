% The COBRAToolbox: testCompareTwoSamp.m
%
% Purpose:
%     - compareTwoSamp computes the mass distribution vectors (MDVs) of two sets of sampled flux
%       vectors with calcMDVfromSamp and compares them with compareTwoMDVs (sum of z-scores).
%       The function is quarantined for the defect below: it calls calcMDVfromSamp with the
%       arguments in the wrong order and without the experiment structure, so every call stops
%       with an error. This file only opens the test; it asserts nothing about the function.
%
% Function under test:
%     src/dataIntegration/fluxomics/compareTwoSamp.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - the documented inputs include a model structure; no solver.
%
% Coverage exemptions:
%     every line - compareTwoSamp is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: calcMDVfromSamp is called as calcMDVfromSamp(points, measuredMetabolites), every call stops with an error
%       SEVERITY: error
%       TRIGGER: with the fixtures of testFitC13Data, load('point.mat', 'v0');
%         load('model.mat', 'model'); compareTwoSamp([], model, struct('points', v0),
%         struct('points', v0)) (also with a fifth argument {'xalaL011'})
%       OBSERVED: (R2025a, 2026-11-16) "Undefined function 'convert_input' for input arguments
%         of type 'double'." raised in calcMDVfromSamp line 34: the sampled points are passed as
%         its first argument glc and measuredMetabolites as its argument points; with empty
%         points (glc empty) it stops with "Not enough input arguments." at calcMDVfromSamp line
%         32 because no experiment structure is passed; xglc is never passed on
%       EXPECTED: calcMDVfromSamp(xglc, samp.points, experiment) for each sample, then the
%         z-scores of compareTwoMDVs
%       LINES: 57-58
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCompareTwoSamp'));
cd(fileDir);

% declare the requirements of this test. This test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
