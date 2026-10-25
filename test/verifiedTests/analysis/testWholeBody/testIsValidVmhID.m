% The COBRAToolbox: testIsValidVmhID.m
%
% Purpose:
%     - isValidVmhID checks identifiers of the Virtual Metabolic Human database: it flags empty,
%     placeholder (0, -, nan) and containing-blank, comma or semicolon identifiers as invalid, and
%     recognises the text "not in VMH".
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/wholeBody/Nutrition_Modelling_Toolbox/isValidVmhID.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Identifiers with surrounding blanks are rejected although they are trimmed for the
%         other checks
%       SEVERITY: limitation
%       TRIGGER: an identifier such as  pyr  with leading or trailing blanks
%       OBSERVED: the blank test is applied to the untrimmed text, so the identifier is invalid,
%         while the empty, placeholder and "not in VMH" tests use the trimmed text
%       EXPECTED: a blank-padded identifier treated like its trimmed form
%       LINES: 28
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testIsValidVmhID'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% valid identifiers

[isValid, isNotInVmh] = isValidVmhID({'glc_D', 'pyr'});
assert(isequal(isValid, [true true]) && isequal(isNotInVmh, [false false]));

%% placeholders and empty identifiers are invalid

[isValid, isNotInVmh] = isValidVmhID({'', '0', '-', 'NaN', 'nan'});
assert(~any(isValid) && ~any(isNotInVmh));

%% text saying the metabolite is not in the database

[isValid, isNotInVmh] = isValidVmhID({'Not in VMH', 'not in the vmh', 'NOT IN VMH'});
assert(~any(isValid) && all(isNotInVmh));

%% identifiers with separators are invalid

[isValid, ~] = isValidVmhID({'a b', 'a,b', 'ok;x', sprintf('a\tb')});
assert(~any(isValid));

%% string input with a missing value

[isValid, isNotInVmh] = isValidVmhID(["abc"; missing]);
assert(isequal(isValid, [true; false]) && isequal(isNotInVmh, [false; false]));

% change the directory
cd(currentDir)
