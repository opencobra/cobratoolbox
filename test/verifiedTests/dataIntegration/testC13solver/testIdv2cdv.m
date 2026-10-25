% The COBRAToolbox: testIdv2cdv.m
%
% Purpose:
%     - idv2cdv returns the matrix that converts an isotopomer distribution vector of n carbons into
%     the cumomer distribution vector.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/dataIntegration/fluxomics/c13solver/idv2cdv.m
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
fileDir = fileparts(which('testIdv2cdv'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% no carbons

assert(isequal(idv2cdv(0), 1));
% a negative number is treated like zero
assert(isequal(idv2cdv(-3), 1));

%% one and two carbons

assert(isequal(idv2cdv(1), [1 1; 0 1]));
assert(isequal(idv2cdv(2), [1 1 1 1; 0 1 0 1; 0 0 1 1; 0 0 0 1]));

%% size and structure for larger numbers

M = idv2cdv(4);
assert(isequal(size(M), [16 16]));
% upper triangular with ones on the diagonal
assert(isequal(M, triu(M)) && all(diag(M) == 1));
% every entry is zero or one
assert(all(M(:) == 0 | M(:) == 1));

% change the directory
cd(currentDir)
