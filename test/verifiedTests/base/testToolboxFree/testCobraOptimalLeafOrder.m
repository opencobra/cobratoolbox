% The COBRAToolbox: testCobraOptimalLeafOrder.m
%
% Purpose:
%     - cobraOptimalLeafOrder is the plain-MATLAB replacement for optimalleaforder(Z, D)
%       (Statistics and Machine Learning Toolbox) with its default criterion, as used for
%       clustergram's leaf order. The optimal order is not unique, so this test checks that the
%       order is consistent with the tree and that its sum of adjacent distances equals the
%       minimum over all tree-consistent orders, found independently by enumerating all 2^(n-1)
%       flips of the tree, on seeded random data of several sizes; plus a hand example, square
%       and vector distance input, one leaf, an unbalanced (chain) tree of 600 leaves, and the
%       error for mismatched input; and (only where the toolbox is installed) parity of the
%       cost with optimalleaforder.
%
% Function under test:
%     src/base/utilities/toolboxFree/cobraOptimalLeafOrder.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261111-152503-toolbox-free-remaining, 2026-11-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCobraOptimalLeafOrder'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

adjacentCost = @(order, D) sum(D(sub2ind(size(D), order(1:end - 1), order(2:end))));

%% hand example: two pairs of close points

X = [0; 10; 1; 11];
D = abs(X - X');
Z = computeEcosystemLinkage(D, 'average');
order = cobraOptimalLeafOrder(Z, D);
% clusters {1, 3} and {2, 4}; the optimum puts 3 next to 2 (distance 9): cost 1 + 9 + 1
assert(adjacentCost(order, D) == 11 && (isequal(order, [1 3 2 4]) || isequal(order, [4 2 3 1])));
% the pdist vector form gives the same order
assert(isequal(cobraOptimalLeafOrder(Z, D(tril(true(4), -1))'), order));

%% seeded random data: the cost equals the minimum over all tree-consistent orders

rng(20261111);
for trial = 1:8
    n = 3 + mod(trial, 6);
    points = randn(n, 2);
    D = sqrt((points(:, 1) - points(:, 1)') .^ 2 + (points(:, 2) - points(:, 2)') .^ 2);
    Z = computeEcosystemLinkage(D, 'average');
    order = cobraOptimalLeafOrder(Z, D);
    assert(isequal(sort(order), 1:n) && isTreeConsistent(order, Z));
    % brute force: every combination of flips of the n - 1 internal nodes
    best = Inf;
    for flips = 0:2 ^ (n - 1) - 1
        best = min(best, adjacentCost(flippedOrder(Z, bitget(flips, 1:n - 1)), D));
    end
    assert(abs(adjacentCost(order, D) - best) < 1e-12, sprintf('trial %d', trial));
end

%% one leaf, and an unbalanced tree (chain) of 600 leaves without recursion limits

assert(cobraOptimalLeafOrder(zeros(0, 3), 0) == 1);
n = 600;
X = (1:n)' .^ 2;
D = abs(X - X');
Z = computeEcosystemLinkage(D, 'average');
order = cobraOptimalLeafOrder(Z, D);
% points on a line: the optimum is the sorted order (or its reverse)
assert(isequal(order, 1:n) || isequal(order, n:-1:1));

%% errors: distances of the wrong size

assert(verifyCobraFunctionError('cobraOptimalLeafOrder', 'inputs', {Z(1:3, :), zeros(5)}, ...
    'testMessage', 'cobraOptimalLeafOrder: D must hold the distances of the 4 leaves of Z.'));

%% parity with optimalleaforder (only where the Statistics and Machine Learning Toolbox is installed)

if exist('optimalleaforder', 'file') == 2 && license('test', 'Statistics_Toolbox')
    points = randn(30, 3);
    D = squareform(pdist(points));
    Z = linkage(pdist(points), 'average');
    orderToolbox = optimalleaforder(Z, pdist(points));
    % the optimum need not be unique: compare the costs
    assert(abs(adjacentCost(cobraOptimalLeafOrder(Z, D), D) - adjacentCost(orderToolbox, D)) < 1e-10);
    fprintf('parity with optimalleaforder: passed\n');
else
    fprintf('skipped: Statistics and Machine Learning Toolbox not installed\n');
end

% change the directory
cd(currentDir)

function order = flippedOrder(Z, flips)
% Leaf order of the tree with the children of internal node k swapped where flips(k) is 1
n = size(Z, 1) + 1;
sequences = num2cell(1:n);
for row = 1:n - 1
    left = sequences{Z(row, 1)};
    right = sequences{Z(row, 2)};
    if flips(row)
        sequences{n + row} = [right, left];
    else
        sequences{n + row} = [left, right];
    end
end
order = sequences{end};
end

function consistent = isTreeConsistent(order, Z)
% Every cluster of the tree occupies consecutive positions of order
n = size(Z, 1) + 1;
position(order) = 1:n;
members = num2cell(1:n);
consistent = true;
for row = 1:n - 1
    members{n + row} = [members{Z(row, 1)}, members{Z(row, 2)}];
    span = position(members{n + row});
    consistent = consistent && max(span) - min(span) + 1 == numel(span);
end
end
