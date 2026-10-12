% The COBRAToolbox: testCompareTwoMDVs.m
%
% Purpose:
%     - compareTwoMDVs compares two mass-distribution vectors (average and standard deviation per
%     fragment mass) with z-scores and returns the sum of their absolute values.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/dataIntegration/fluxomics/compareTwoMDVs.m
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
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCompareTwoMDVs'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for the z-scores: square roots and quotients of small numbers
tol = 1e-8;

first.names = {'a0'; 'a1'; 'a2'};
first.ave = [0.5; 0.3; 0.2];
first.stdev = [0.01; 0.02; 0.03];
second = first;
second.ave = [0.4; 0.3; 0.3];

%% z-score = (ave1 - ave2) / sqrt(std1^2 + std2^2 + 0.02^2), and their absolute sum

[totalZ, zScore] = compareTwoMDVs(first, second);
expectedZ = [0.1; 0; -0.1] ./ sqrt(first.stdev.^2 + second.stdev.^2 + 0.02^2);
assert(norm(zScore - expectedZ) < tol);
assert(abs(totalZ - sum(abs(expectedZ))) < tol);
assert(abs(totalZ - 6.2144900682) < 1e-9);      % the same value, written out

%% identical vectors give 0

[totalZ, zScore] = compareTwoMDVs(first, first);
assert(totalZ == 0 && all(zScore == 0));

%% a NaN average gives the total -1

withNaN = first;
withNaN.ave(1) = NaN;
assert(compareTwoMDVs(withNaN, second) == -1);

%% a single input is rejected

errorCaught = false;
try
    compareTwoMDVs(first);
catch exception
    errorCaught = contains(exception.message, 'compareTwoMDVs(mdv1,mdv2)');
end
assert(errorCaught);

% change the directory
cd(currentDir)
