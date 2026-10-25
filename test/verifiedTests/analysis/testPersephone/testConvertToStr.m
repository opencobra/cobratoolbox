% The COBRAToolbox: testConvertToStr.m
%
% Purpose:
%     - convertToStr returns a character vector unchanged and joins the characters of a cell array
%     into one character vector.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/persephone/additionalFunctions/convertToStr.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConvertToStr'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% a character vector is returned unchanged

assert(strcmp(convertToStr('abc'), 'abc'));
assert(strcmp(convertToStr(''), ''));

%% a cell array of characters is concatenated

assert(strcmp(convertToStr({'a', 'b', 'c'}), 'abc'));
assert(strcmp(convertToStr({'ab', 'cd'}), 'abcd'));

% change the directory
cd(currentDir)
