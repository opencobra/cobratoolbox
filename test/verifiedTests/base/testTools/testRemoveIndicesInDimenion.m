% The COBRAToolbox: testRemoveIndicesInDimenion.m
%
% Purpose:
%     - removeIndicesInDimenion indexes an array of any number of dimensions along one given
%       dimension with the given indices (numeric or logical) and keeps every entry of the other
%       dimensions. Its only caller, removeFieldEntriesForType, passes the complement of the
%       entries to remove (~indicesToRemove), so the given indices are the entries that are KEPT;
%       see the defect note on the help text below.
%       Characterization test that PINS the current behaviour (feature
%       20261103-105830-tier2-safe-batch, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Expected values are derived by hand from MATLAB indexing of the hand-built inputs.
%
% Function under test:
%     src/base/utilities/removeIndicesInDimenion.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The help text says the given indices are removed, but they are the ones kept
%       SEVERITY: cosmetic
%       TRIGGER: any call, e.g. removeIndicesInDimenion(magic(4), 1, [1 3])
%       OBSERVED: rows 1 and 3 are returned (the given indices are kept); the only caller,
%         removeFieldEntriesForType, relies on this and passes the complement of the entries to
%         remove
%       EXPECTED: a help text that describes the indices as the entries to keep (the code is
%         consistent with its caller)
%       LINES: 2-16
%
% Authors:
%     - Generated for feature 20261103-105830-tier2-safe-batch, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRemoveIndicesInDimenion'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% numeric indices along the first dimension of a matrix keep those rows

A = magic(4);
result = removeIndicesInDimenion(A, 1, [1 3]);
% rows 1 and 3, all columns, in the given order
assert(isequal(result, A([1 3], :)));
assert(isequal(result, [16 2 3 13; 9 7 6 12]));

%% logical indices along the second dimension of a matrix keep the true columns

A = magic(4);
result = removeIndicesInDimenion(A, 2, logical([1 0 0 1]));
assert(isequal(result, A(:, [1 4])));
assert(isequal(size(result), [4 2]));

%% the dimension may be any dimension of an N-dimensional array

B = reshape(1:24, 2, 3, 4);
result = removeIndicesInDimenion(B, 3, [2 4]);
% the first two dimensions are untouched, pages 2 and 4 are kept
assert(isequal(size(result), [2 3 2]));
assert(isequal(result, B(:, :, [2 4])));

%% cell arrays are indexed in the same way

names = {'a'; 'b'; 'c'};
result = removeIndicesInDimenion(names, 1, [true; false; true]);
assert(isequal(result, {'a'; 'c'}));

%% an empty index list keeps nothing along that dimension

A = magic(4);
result = removeIndicesInDimenion(A, 1, []);
assert(isequal(size(result), [0 4]));

% change the directory
cd(currentDir)
