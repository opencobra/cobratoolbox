% The COBRAToolbox: testMinimumSetCoverPlain.m
%
% Purpose:
%     - minimumSetCoverPlain finds a minimum-size set of columns of a 0/1 matrix that covers every
%     row (exact branch and bound, no toolbox).
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/topology/reactingMoieties/minimumSetCoverPlain.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Lines 64-65 and 125-126 of minimumSetCoverPlain.m (two defensive errors) are never reached:
%     every row is checked to be coverable at the start, so no later search step can run out of columns.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMinimumSetCoverPlain'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% In every example the minimum size is known from the construction; the exact columns are
% only compared where the optimum is unique.

%% unique optimum

% rows 1-2 are covered by column 1, rows 3-4 by column 3
[selectedColumns, fval] = minimumSetCoverPlain([1 0 0; 1 1 0; 0 1 1; 0 0 1]);
assert(isequal(selectedColumns, [1; 3]) && fval == 2);
% every row needs its own column
[selectedColumns, fval] = minimumSetCoverPlain(eye(3));
assert(isequal(selectedColumns, [1; 2; 3]) && fval == 3);
% rows 2-5 each need their single-row column, so all four are needed
[selectedColumns, fval] = minimumSetCoverPlain([1 1 1 1; 1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1]);
assert(isequal(selectedColumns, [1; 2; 3; 4]) && fval == 4);

%% the optimum is smaller than the greedy choice

% universe 1..6, S1 = {1,2,3,4}, S2 = {1,3,5}, S3 = {2,4,6}: greedy takes S1 and then needs 2 more
% sets (3 in total), the optimum is S2 and S3
coverMatrix = zeros(6, 3);
coverMatrix([1 2 3 4], 1) = 1;
coverMatrix([1 3 5], 2) = 1;
coverMatrix([2 4 6], 3) = 1;
[selectedColumns, fval] = minimumSetCoverPlain(coverMatrix);
assert(isequal(selectedColumns, [2; 3]) && fval == 2);

%% several optimal covers: the size is the optimum and the covers are valid

cycleMatrix = [1 1 0 0; 0 1 1 0; 0 0 1 1; 1 0 0 1];       % each row is covered by 2 neighbouring columns
[selectedColumns, fval] = minimumSetCoverPlain(cycleMatrix);
assert(fval == 2 && numel(selectedColumns) == 2);
assert(all(sum(cycleMatrix(:, selectedColumns), 2) >= 1));

%% an instance where the search improves on the greedy solution while exploring

% rows 1-6, columns 1-5. Row 2 can only be covered by column 2; rows 1 and 3 are both covered by column 5.
% Enumerating all column pairs shows that {2, 5} is the only cover of size 2 and that no single column covers.
searchInstance = [0 0 1 0 1; 0 1 0 0 0; 1 0 0 1 1; 1 1 0 1 0; 1 1 0 1 0; 1 1 0 0 0];
pairs = nchoosek(1:5, 2);
coversOfSizeTwo = pairs(arrayfun(@(k) all(sum(searchInstance(:, pairs(k, :)), 2) >= 1), 1:size(pairs, 1)), :);
assert(isequal(coversOfSizeTwo, [2 5]));
assert(~any(all(searchInstance > 0, 1)));
[selectedColumns, fval] = minimumSetCoverPlain(searchInstance);
assert(isequal(selectedColumns, [2; 5]) && fval == 2);

%% only the pattern of non-zeros matters, and unused columns are never chosen

[selectedColumns, fval] = minimumSetCoverPlain([1 0 5; 0 1 0]);
assert(isequal(selectedColumns, [1; 2]) && fval == 2);
% column 1 is empty: the single useful column is column 2 (original index)
[selectedColumns, fval] = minimumSetCoverPlain([0 1 0; 0 1 1]);
assert(isequal(selectedColumns, 2) && fval == 1);

%% no rows: nothing to cover

[selectedColumns, fval] = minimumSetCoverPlain(zeros(0, 3));
assert(isempty(selectedColumns) && fval == 0);

%% a row that no column covers is an error

errorCaught = false;
try
    minimumSetCoverPlain([1 0; 0 0]);
catch exception
    errorCaught = strcmp(exception.identifier, 'minimumSetCoverPlain:UncoveredRow');
end
assert(errorCaught);

% change the directory
cd(currentDir)
