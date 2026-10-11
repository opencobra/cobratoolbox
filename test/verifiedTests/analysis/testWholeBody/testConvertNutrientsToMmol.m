% The COBRAToolbox: testConvertNutrientsToMmol.m
%
% Purpose:
%     - convertNutrientsToMmol converts nutrient amounts given in g, mg or ug into mmol of the corresponding VMH metabolites, merging duplicate metabolite IDs.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/wholeBody/Nutrition_Modelling_Toolbox/convertNutrientsToMmol.m
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
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConvertNutrientsToMmol'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons: one multiplication and one division of
% small numbers, so rounding is far below 1e-15 relative
tol = 1e-15;

%% unit conversion: g, mg and ug to mmol (amount in g / molecular weight in g/mmol)

values = [1 2; 3 4; 5 6];
[metIDs, valuesMmol, duplicates] = convertNutrientsToMmol(values, {'g'; 'mg'; 'ug'}, {'m1'; 'm2'; 'm3'}, [100; 50; 10]);
assert(isequal(metIDs, {'m1'; 'm2'; 'm3'}));
expectedMmol = [1 2; 3e-3 4e-3; 5e-6 6e-6] ./ [100; 50; 10];
assert(max(abs(valuesMmol(:) - expectedMmol(:)) ./ abs(expectedMmol(:))) < 1e-12);
% every ID occurs once -> no duplicates reported
assert(isequal(size(duplicates), [0 2]));

%% both micro signs are accepted for ug

[~, mmolMicroSign] = convertNutrientsToMmol(1, {[char(181) 'g']}, {'m1'}, 10);
[~, mmolGreekMu] = convertNutrientsToMmol(1, {[char(956) 'g']}, {'m1'}, 10);
assert(abs(mmolMicroSign - 1e-7) < tol);
assert(abs(mmolGreekMu - 1e-7) < tol);

%% duplicate IDs: the largest amount (ignoring NaN) is kept and the duplicate is reported

% unit names are not case sensitive; rows 1 and 2 are the same metabolite m1
[metIDs, valuesMmol, duplicates] = convertNutrientsToMmol([1; 3], {'g'; 'G'}, {'m1'; 'm1'}, [100; 100]);
assert(isequal(metIDs, {'m1'}));
assert(abs(valuesMmol - 0.03) < tol);
assert(isequal(duplicates, {'m1', 2}));

% a molecular weight that is NaN in one duplicate row is ignored
[~, valuesMmol] = convertNutrientsToMmol([1; 3], {'g'; 'g'}, {'m1'; 'm1'}, [100; NaN]);
assert(abs(valuesMmol - 0.03) < tol);

% NaN amounts are ignored when taking the maximum of duplicates, column by column
[~, valuesMmol] = convertNutrientsToMmol([1 NaN; 3 4], {'g'; 'g'}, {'m1'; 'm1'}, [10; 10]);
assert(norm(valuesMmol - [0.3 0.4]) < 1e-12);

%% conflicting molecular weights: a warning is issued and the first weight is used

lastwarn('');
[~, valuesMmol] = convertNutrientsToMmol([1; 3], {'g'; 'g'}, {'m1'; 'm1'}, [100; 200]);
assert(contains(lastwarn, 'Different molecular weights are given for m1'));
assert(abs(valuesMmol - 0.03) < tol);

%% invalid input

% a unit other than g, mg, ug
assert(verifyCobraFunctionError('convertNutrientsToMmol', 'inputs', {1, {'kg'}, {'m1'}, 10}, ...
    'testMessage', 'Unknown units found: kg. Only g, mg and ug are supported.'));
% a metabolite without any molecular weight
assert(verifyCobraFunctionError('convertNutrientsToMmol', 'inputs', {[1; 2], {'g'; 'g'}, {'m1'; 'm2'}, [10; NaN]}, ...
    'testMessage', 'No molecular weight is available for the following VMH metabolites: m2. Please add them to the info file.'));

% change the directory
cd(currentDir)
