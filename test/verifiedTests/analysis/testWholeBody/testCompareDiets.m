% The COBRAToolbox: testCompareDiets.m
%
% Purpose:
%     - compareDiets lists the flux change (diet 2 minus diet 1) of every metabolite in two diets and the metabolites that are unique to each diet.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/wholeBody/Nutrition_Modelling_Toolbox/compareDiets.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Line 74 of compareDiets.m (the line that flips the sign of the result (fluxChanges = fluxChanges*-1, used when the direction argument is false) is uncovered because of the defect below.
%
% Known defects / quirks pinned (NOT fixed here):
%     Calling the function with the direction argument false errors (MATLAB:math:mustBeNumericCharOrLogical): the result is a cell array and cannot be multiplied by -1. That input is skipped here (documented, not tested, not fixed).
%
% Authors:
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCompareDiets'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% two diets as {metabolite, flux}; values may be numbers or numeric text
diet1 = {'a', 1; 'b', 2; 'e', '5'};
diet2 = {'a', 3; 'c', 4; 'e', '7'};

% expected result: change = diet2 - diet1; a metabolite missing from one diet counts as 0
expectedChanges = {'a', 2; 'b', -2; 'c', 4; 'e', 2};

%% direction diet 1 -> diet 2 (true), including text values and metabolites in one diet only

[fluxChanges, uniqueDiet1, uniqueDiet2] = compareDiets(diet1, diet2, true);
assert(isequal(fluxChanges, expectedChanges));
% 'b' is only in diet 1, 'c' is only in diet 2
assert(isequal(uniqueDiet1, {'b'}));
assert(isequal(uniqueDiet2, {'c'}));

%% an empty direction argument defaults to true

fluxChangesDefault = compareDiets(diet1, diet2, []);
assert(isequal(fluxChangesDefault, expectedChanges));

%% a direction argument that is neither true nor false: a warning is issued and the result is unchanged

lastwarn('');
fluxChangesOutOfRange = compareDiets(diet1, diet2, 2);
assert(contains(lastwarn, 'one2Two has to be true(1) or false(0)'));
assert(isequal(fluxChangesOutOfRange, expectedChanges));

lastwarn('');
fluxChangesNegative = compareDiets(diet1, diet2, -1);
assert(contains(lastwarn, 'one2Two has to be true(1) or false(0)'));
assert(isequal(fluxChangesNegative, expectedChanges));

% change the directory
cd(currentDir)
