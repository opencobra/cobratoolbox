% The COBRAToolbox: testFourFundamentalSubpaces.m
%
% Purpose:
%     - fourFundamentalSubpaces returns bases of the four fundamental subspaces of a matrix S (null
%     space, row space, left null space, column space), the permutations and the rank.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/subspaces/fourFundamentalSubpaces.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Lines 81-94 of fourFundamentalSubpaces.m (the singular-value branch, used on platforms other
%     than Linux) are not reached on Linux; on other platforms lines 53-80 are not reached. The
%     checks below hold for both branches.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFourFundamentalSubpaces'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for the residuals S*N and L*S: scaled LU factorisation of a tiny matrix, so
% rounding is far below 1e-10
tol = 1e-10;

S = sparse([1 2 0 1; 0 1 1 1; 1 3 1 2]);        % 3 x 4, rank 2 (row 3 = row 1 + row 2)
[numRows, numColumns] = size(S);

%% sizes, rank and the defining properties of the subspaces

[N, R, L, C, p, q, rankS] = fourFundamentalSubpaces(S, 0);
assert(rankS == 2);
% null space: S*N = 0 with n - rank columns
assert(isequal(size(N), [numColumns, numColumns - rankS]));
assert(norm(S * N, 'fro') < tol);
% row space: n x rank, independent columns
assert(isequal(size(R), [numColumns, rankS]) && rank(full(R)) == rankS);
% left null space: (m - rank) x m with L*S = 0
assert(isequal(size(L), [numRows - rankS, numRows]));
assert(norm(L * S, 'fro') < tol);
% column space: rank x m, independent rows
assert(isequal(size(C), [rankS, numRows]) && rank(full(C)) == rankS);

% the permutations (only returned by the Linux branch)
if ~isempty(p)
    assert(isequal(sort(p(:))', 1:numColumns));
    assert(isequal(sort(q(:))', 1:numRows));
end

%% the printing level: the default prints a report, level 0 prints nothing

printedText = evalc('fourFundamentalSubpaces(S);');
assert(~isempty(printedText));
printedText = evalc('fourFundamentalSubpaces(S, 0);');
assert(isempty(printedText));

% change the directory
cd(currentDir)
