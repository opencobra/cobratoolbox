% The COBRAToolbox: testRowReduce.m
%
% Purpose:
%     - rowReduce removes linearly dependent rows of a matrix A (and the matching entries of a
%     vector a) and returns the independent rows, their indices and the rank.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/subspaces/rowReduce/rowReduce.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     The branches that depend on the platform and on the factorisation result are not all
%     reached on one machine: on Linux and macOS the QR fallback (lines 61 and 66, and the
%     local function qrRowReduce, lines 73-86 of rowReduce.m) is not reached. The checks below
%     hold for every branch.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRowReduce'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the matrix has one dependent row: row 2 = 2 * row 1; the rows that are kept depend on the
% factorisation method, so only properties that hold for every method are checked
A = sparse([1 2; 2 4; 0 1]);
a = [1; 2; 3];

%% independent rows are kept and the vector follows

[AA, aa, pp, rankA, p] = rowReduce(A, a, 1, 0);
assert(rankA == 2);
assert(numel(pp) == rankA && numel(unique(pp)) == rankA && all(ismember(pp, 1:3)));
assert(isequal(full(AA), full(A(pp, :))));
assert(isequal(full(aa), a(pp)));
assert(rank(full(AA)) == rankA);
% p is a permutation of the rows with the kept rows first
assert(isequal(sort(p(:))', 1:3));
assert(isequal(p(1:rankA), pp));

%% without the vector a, an empty vector of the right length is used

[~, aa, ~, rankA] = rowReduce(A);
assert(rankA == 2 && isequal(size(aa), [2 1]) && nnz(aa) == 0);

%% a matrix of full row rank is returned whole

[AA, ~, pp, rankA] = rowReduce(sparse(eye(3)), [1; 2; 3], 1, 0);
assert(rankA == 3 && isequal(full(AA), eye(3)) && isequal(sort(pp(:))', 1:3));

%% another mode

[~, ~, ~, rankA] = rowReduce(sparse([1 0; 0 1; 1 1]), [1; 2; 3], 2, 0);
assert(rankA == 2);

%% a zero matrix has rank 0

[AA, ~, ~, rankA] = rowReduce(sparse(3, 2), zeros(3, 1), 1, 0);
assert(rankA == 0 && isequal(size(AA), [0 2]));

%% the report line with the default print level

printedText = evalc('rowReduce(A, a);');
assert(contains(printedText, 'Eliminated 1 dependent rows'));

%% inconsistent dimensions are rejected

errorCaught = false;
try
    rowReduce(A, [1; 2], 1, 0);
catch exception
    errorCaught = strcmp(exception.message, 'Dimensions of A and a are inconsistent');
end
assert(errorCaught);

% change the directory
cd(currentDir)
