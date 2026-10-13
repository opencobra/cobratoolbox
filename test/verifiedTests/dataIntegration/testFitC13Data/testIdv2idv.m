% The COBRAToolbox: testIdv2idv.m
%
% Purpose:
%     - idv2idv builds the 2^n by 2^n permutation matrix that maps an isotopomer distribution vector
%     to the one with the bit order of the labelling pattern reversed (for n labelled atoms).
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/dataIntegration/fluxomics/c13solver/idv2idv.m
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
fileDir = fileparts(which('testIdv2idv'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% The function always issues the warning "are you sure you want to call this function?", which is
% left visible (Constitution VII-B); every call below therefore prints it.

%% two labelled atoms: the 4 x 4 permutation of the reversed bit pairs

lastwarn('');
permutation = full(idv2idv(2));
assert(contains(lastwarn, 'are you sure you want to call this function?'));
% 00 -> 00, 01 -> 10, 10 -> 01, 11 -> 11
assert(isequal(permutation, [1 0 0 0; 0 0 1 0; 0 1 0 0; 0 0 0 1]));

%% three labelled atoms: element i is moved to the position with its bits reversed

permutation = full(idv2idv(3));
assert(isequal(permutation * (0:7)', [0 4 2 6 1 5 3 7]'));
assert(isequal(sum(permutation, 1), ones(1, 8)) && isequal(sum(permutation, 2), ones(8, 1)));

%% no atoms (or a negative number): the scalar 1

assert(idv2idv(0) == 1);
assert(idv2idv(-1) == 1);

% change the directory
cd(currentDir)
