% The COBRAToolbox: testIdv2mdv.m
%
% Purpose:
%     - idv2mdv returns the matrix that converts an isotopomer distribution vector of n carbons into
%     the mass distribution vector of the whole molecule or of a fragment, memoizing fragment
%     matrices in global variables.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/dataIntegration/fluxomics/c13solver/idv2mdv.m
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
fileDir = fileparts(which('testIdv2mdv'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the function keeps memoized fragment matrices in global variables; start empty and clear afterwards
clear global pseudohash1 pseudohash2
cleanup = onCleanup(@() clear('global', 'pseudohash1', 'pseudohash2'));

%% whole molecule (one argument)

assert(isequal(full(idv2mdv(1)), [1 0; 0 1]));
% two carbons: the mass shift is the number of labelled carbons
assert(isequal(full(idv2mdv(2)), [1 0 0 0; 0 1 1 0; 0 0 0 1]));
assert(isequal(size(idv2mdv(3)), [4 8]));
% every isotopomer belongs to exactly one mass isotopomer
assert(all(sum(idv2mdv(4), 1) == 1));

%% a fragment containing both carbons gives the same matrix as the whole molecule

assert(isequal(full(idv2mdv(2, [1 1])), full(idv2mdv(2))));

%% a fragment with one of the two carbons

% the fragment is read from the last carbon: isotopomers with the last carbon labelled have mass shift 1
fragmentMatrix = idv2mdv(2, [1 0]);
assert(isequal(full(fragmentMatrix), [1 0 1 0; 0 1 0 1]));

%% the memoized matrix is returned the second time

first = idv2mdv(2, [1 0]);
assert(isequal(idv2mdv(2, [1 0]), first));

%% the fragment must have one entry per carbon

verifyCobraFunctionError('idv2mdv', 'inputs', {3, [1 0]}, 'testMessage', 'error in fragment length');

% change the directory
cd(currentDir)
