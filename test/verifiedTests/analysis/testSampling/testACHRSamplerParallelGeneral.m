% The COBRAToolbox: testACHRSamplerParallelGeneral.m
%
% Purpose:
%     - ACHRSamplerParallelGeneral moves the points of a sampling structure by artificial
%       centering hit-and-run (serial when proc is omitted or 1; with proc > 1 the master
%       starts proc - 1 MATLAB worker processes that exchange points through xx*.mat files).
%       The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the parallel mode cannot start its workers on Linux and macOS (defect
%       below), so no assertion about the function is made.
%
% Function under test:
%     src/analysis/sampling/ACHR/ACHRSamplerParallelGeneral.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use a hand-built sampling structure in a
%     temporary folder.
%
% Coverage exemptions:
%     every line - ACHRSamplerParallelGeneral is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The parallel mode cannot start its worker processes on Linux and macOS
%       SEVERITY: unusable-option
%       TRIGGER: on Linux, ACHRSamplerParallelGeneral(sampleStruct, 1, 10, 60, 2) (proc = 2,
%         as gpSampler calls it with threads = 2), any sampleStruct
%       OBSERVED: line 126 builds the shell command 'matlab -singleCompThread -automation
%         -nojvm -r ACHRSamplerParallelGeneral([],1,10,0,-1,'<pwd>');exit; &' with the -r
%         argument unquoted; sh -c on this text prints 'sh: 1: Syntax error: "(" unexpected'
%         and MATLAB system() on the same text (matlab replaced by echo) returns status 2, so
%         no worker starts; the master then waits for xxRoundAck1x1.mat in the loop of
%         lines 286-296, which only a worker writes (read from the code; the master was not
%         run here because it calls system('matlab ...'))
%       EXPECTED: the workers start (the -r argument quoted for the shell) and the sampling
%         finishes
%       LINES: 126, 128
%     - DEFECT: A log file is written into the current folder
%       SEVERITY: cosmetic
%       TRIGGER: from an empty folder, with sampleStruct.warmupPts = [0.2 0.8 0.5 0.4; 0.3
%         0.1 0.6 0.9] and sampleStruct.internal with offset [0; 0], ubnew [1; 1], lbnew
%         [0; 0], Anew zeros(0, 2), Cnew zeros(0, 2), Dnew zeros(0, 1), fixed []:
%         ACHRSamplerParallelGeneral(sampleStruct, 1, 10, 60) (serial mode)
%       OBSERVED: the folder then holds ACHRParallelError.txt (opened on line 115), left
%         there after the call
%       EXPECTED: no undocumented file, or a documented location
%       LINES: 115
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testACHRSamplerParallelGeneral'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
