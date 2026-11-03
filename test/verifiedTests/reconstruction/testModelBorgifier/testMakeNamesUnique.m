% The COBRAToolbox: testMakeNamesUnique.m
%
% Purpose:
%     - makeNamesUnique checks a list of names for duplicates. A list without duplicates is
%       returned unchanged and nothing is asked; duplicates are renamed through prompts to the
%       user (automatic or manual renaming). Only the non-interactive path is tested.
%       Characterization test that PINS the current behaviour (feature
%       20261103-105830-tier2-safe-batch, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Expected values are the hand-built input lists themselves.
%
% Function under test:
%     src/reconstruction/comparison/modelBorgifier/makeNamesUnique.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     - Lines 54-76 and 86-118: renaming duplicates asks the user with input() (automatic or
%       manual renaming), so a list with duplicates cannot be tested without user interaction.
%     - Line 128: the final message is only printed when duplicates remain after the renaming.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: An empty list stops with an error
%       SEVERITY: error
%       TRIGGER: makeNamesUnique({})
%       OBSERVED: error "Unrecognized function or variable 'count'" from countUnique, called at
%         line 50, which assigns count only inside a loop over the unique names
%       EXPECTED: the empty list returned unchanged (it has no duplicates)
%       LINES: 50
%     - DEFECT: Positions of duplicates are printed as character codes
%       SEVERITY: wrong-result
%       TRIGGER: a list with duplicates and no nameInfo, answering the prompts (interactive)
%       OBSERVED: fprintf('%d\n', num2str(position)) prints the character codes of the digits,
%         e.g. position 12 is printed as 49 and 50, so the user is told the wrong entries to
%         rename
%       EXPECTED: the position of each duplicate printed as a number
%       LINES: 97
%
% Authors:
%     - Generated for feature 20261103-105830-tier2-safe-batch, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMakeNamesUnique'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% a list without duplicates is returned unchanged

names = {'glc_D[c]'; 'g6p[c]'; 'atp'; 'adp'};
result = makeNamesUnique(names);
assert(isequal(result, names));

%% names that differ only in case are distinct names

names = {'atp[c]'; 'ATP[c]'; 'Atp[c]'};
result = makeNamesUnique(names);
assert(isequal(result, names));

%% the optional information list does not change a list without duplicates

names = {'glc_D[c]'; 'g6p[c]'};
nameInfo = {'D-glucose'; 'glucose 6-phosphate'};
result = makeNamesUnique(names, nameInfo);
assert(isequal(result, names));

%% a single name is unique

result = makeNamesUnique({'h2o[c]'});
assert(isequal(result, {'h2o[c]'}));

% change the directory
cd(currentDir)
