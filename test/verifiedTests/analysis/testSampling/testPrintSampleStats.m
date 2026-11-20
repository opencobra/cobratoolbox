% The COBRAToolbox: testPrintSampleStats.m
%
% Purpose:
%     - printSampleStats computes calcSampleStats of one sample or a cell array of samples
%       and prints a tab-delimited table (to the command window or to fileName): one row per
%       reaction with the reaction, the subsystems (when present) and, per sample, the mode,
%       mean, median and standard deviation columns. The function is QUARANTINED
%       (Constitution III-Defects, quarantine in back-fill campaigns): with more than one
%       sample only the first sample's mode is printed, so every row has one value fewer per
%       extra sample than the header and the values sit under the wrong columns (defect
%       below); no assertion about the function is made.
%
% Function under test:
%     src/analysis/sampling/printSampleStats.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use hand-built samples and a model struct
%     with rxns (and subSystems) and read back the file written to a tempname folder.
%
% Coverage exemptions:
%     every line - printSampleStats is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: With several samples only the first sample's mode is printed
%       SEVERITY: wrong-result
%       TRIGGER: printSampleStats({[1 1 2; 3 4 4], [5 5 6; 7 8 8]},
%         struct('rxns', {{'r1'; 'r2'}}), {'A', 'B'})
%       OBSERVED: header 'Rxn A-mode B-mode A-mean B-mean A-median B-median A-std B-std'
%         (8 value columns) but row 'r1 1.000000 1.333333 5.333333 1.000000 5.000000
%         0.577350 0.577350' (7 values: B-mode 5 is missing and every later value is shifted
%         one column to the left; MATLAB R2025a). sampleStats.mode(i) (line 56) indexes the
%         reactions x samples matrix linearly, so it is always the first sample's value.
%       EXPECTED: one mode per sample (sampleStats.mode(i, :)), as for mean, median and std
%         (lines 59, 62, 65), matching the header of lines 36-38
%       LINES: 56
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPrintSampleStats'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
