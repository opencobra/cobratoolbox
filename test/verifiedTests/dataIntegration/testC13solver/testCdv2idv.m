% The COBRAToolbox: testCdv2idv.m
%
% Purpose:
%     - cdv2idv returns the sparse matrix that converts a cumomer distribution vector of n carbons
%     into the isotopomer distribution vector, caching the result in a global variable.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Defect(s) fixed by feature 20261102-140321-tier1-safe-defect-fixes: Asking for zero carbons
%       fails once the cache holds an entry.
%
% Function under test:
%     src/dataIntegration/fluxomics/c13solver/cdv2idv.m
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
%     - Updated for feature 20261102-140321-tier1-safe-defect-fixes, 2026-11-02.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCdv2idv'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the function keeps its result in a global cache; every section starts from an empty cache and
% the cache is cleared at the end of the test
cleanup = onCleanup(@() clear('global', 'CDV2IDVSAV'));

%% matrices for small numbers of carbons

global CDV2IDVSAV
CDV2IDVSAV = [];

assert(isequal(full(cdv2idv(1)), [1 -1; 0 1]));
assert(isequal(full(cdv2idv(2)), [1 -1 -1 1; 0 1 0 -1; 0 0 1 -1; 0 0 0 1]));
assert(issparse(cdv2idv(2)));

%% the matrix is the inverse of the one from idv2cdv

global CDV2IDVSAV
CDV2IDVSAV = [];
% with n = 0 first (empty cache) and then larger numbers
assert(isequal(full(cdv2idv(0) * idv2cdv(0)), 1));
CDV2IDVSAV = [];
for n = 1:4
    assert(isequal(full(cdv2idv(n) * idv2cdv(n)), eye(2^n)), 'n = %d', n);
end

%% the result is cached and reused

global CDV2IDVSAV
CDV2IDVSAV = [];
first = cdv2idv(3);
assert(~isempty(CDV2IDVSAV{3}) && isequal(CDV2IDVSAV{3}, first));
% a modified cache entry is returned unchanged
CDV2IDVSAV{3} = 'cached';
assert(strcmp(cdv2idv(3), 'cached'));

%% zero carbons after the cache has been filled

global CDV2IDVSAV
CDV2IDVSAV = [];
cdv2idv(2);
% the cache holds an entry, yet zero carbons still give the 1 x 1 identity, as with an empty cache
zeroCarbons = cdv2idv(0);
assert(issparse(zeroCarbons) && isequal(full(zeroCarbons), 1));

% change the directory
cd(currentDir)
