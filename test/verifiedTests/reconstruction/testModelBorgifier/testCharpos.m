% The COBRAToolbox: testCharpos.m
%
% Purpose:
%     - charpos flags the characters of a text that are not numeric digits.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/comparison/modelBorgifier/charpos.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The letters i and j count as digits
%       SEVERITY: wrong-result
%       TRIGGER: a text containing the letter i or j (or other characters that str2double reads as
%         numbers)
%       OBSERVED: each character is tested with str2double, which reads i and j as the imaginary
%         unit, so charpos reports them as numeric
%       EXPECTED: only the digits 0 to 9 reported as numeric
%       LINES: 4-6
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCharpos'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% letters and digits

assert(isequal(charpos('a1b2'), [true false true false]));

%% other symbols are not digits

assert(isequal(charpos('-.+'), [true true true]));

%% the empty text

assert(isempty(charpos('')));

% change the directory
cd(currentDir)
