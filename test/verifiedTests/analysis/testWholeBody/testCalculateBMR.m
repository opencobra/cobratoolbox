% The COBRAToolbox: testCalculateBMR.m
%
% Purpose:
%     - calculateBMR returns the basal metabolic rate (kcal/day) of a person from sex, weight (kg), height (cm) and age (years) with three published equations (Harris-Benedict original and revised, Mifflin-St Jeor).
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/wholeBody/PSCMToolbox/calculateBMR.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects / quirks pinned (NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCalculateBMR'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons: a handful of multiplications and additions on
% numbers of size ~1e3, so rounding is far below 1e-9
tol = 1e-9;

%% male: both spellings of the sex are accepted

% expected values worked out by hand, e.g. original Harris-Benedict for 70 kg, 175 cm, 30 y:
% 66.5 + 13.75*70 + 5.003*175 - 6.755*30 = 1701.875
expectedMale = [1701.875; 1695.6670000000001; 1648.75];
assert(norm(calculateBMR('male', 70, 175, 30) - expectedMale) < tol);
assert(norm(calculateBMR('Male', 70, 175, 30) - expectedMale) < tol);

%% female: any other text is treated as female

expectedFemale = [1417.23; 1405.333; 1345.25];
assert(norm(calculateBMR('female', 60, 165, 25) - expectedFemale) < tol);
assert(norm(calculateBMR('anything else', 60, 165, 25) - expectedFemale) < tol);

% change the directory
cd(currentDir)
