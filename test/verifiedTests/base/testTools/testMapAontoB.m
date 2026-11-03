% The COBRAToolbox: testMapAontoB.m
%
% Purpose:
%     - mapAontoB maps the rows of A onto the keys of B: the output has one row per key of B, filled
%     from A where the keys match.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%       Defect(s) fixed by feature 20261102-140321-tier1-safe-defect-fixes: The check that Akey
%       and Bkey have the same class is broken; Without Ain the matched keys of B are returned
%       wrongly.
%
% Function under test:
%     src/base/utilities/mapAontoB.m
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
%     - Updated for feature 20261102-140321-tier1-safe-defect-fixes, 2026-11-02.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMapAontoB'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

keysA = {'a', 'b', 'c'};
keysB = {'b', 'z', 'c'};

%% numbers: keys that are not in A give NaN

[mapped, isFound, positionInA] = mapAontoB(keysA, keysB, [1 2 3]', [], 0);
assert(isequaln(full(mapped)', [2 NaN 3]));
assert(isequal(isFound, [true false true]));
assert(isequal(positionInA, [2 0 3]));

%% several columns, and text, logical and int64 values

assert(isequaln(full(mapAontoB(keysA, keysB, [1 10; 2 20; 3 30], [], 0)), [2 20; NaN NaN; 3 30]));
assert(isequal(mapAontoB(keysA, keysB, {'x'; 'y'; 'w'}, [], 0), {'y'; []; 'w'}));
assert(isequal(mapAontoB(keysA, keysB, [true; false; true], [], 0)', [false false true]));
assert(isequaln(full(mapAontoB(keysA, keysB, int64([1; 2; 3]), [], 0))', [2 NaN 3]));

%% an existing output Bin keeps its rows for the keys that are not in A

assert(isequal(mapAontoB(keysA, keysB, [1 10; 2 20; 3 30], zeros(3, 2), 0), [2 20; 0 0; 3 30]));
% an empty Bin means no Bin
assert(isequaln(full(mapAontoB(keysA, keysB, [1 10; 2 20; 3 30], [], 0)), [2 20; NaN NaN; 3 30]));

%% numeric keys

assert(isequaln(full(mapAontoB([1 2 3], [3 4], [7; 8; 9], [], 0))', [9 NaN]));

%% tables

tableA = table({'a'; 'b'; 'c'}, [1; 2; 3], 'VariableNames', {'id', 'v'});
% without Bin: a table with one row per key of B (missing keys stay at the default value 0)
mappedTable = mapAontoB(keysA, keysB, tableA(:, 'v'), [], 0);
assert(isequal(mappedTable.v, [2; 0; 3]));
% with Bin and a key name: a join on that variable keeps the rows of Bin
tableB = table({'b'; 'z'}, [0; 0], 'VariableNames', {'id', 'q'});
joined = mapAontoB('id', 'id', tableA, tableB, 0);
assert(isequal(joined.id, {'b'; 'z'}) && joined.v(1) == 2 && isnan(joined.v(2)));
% with Bin and keys that are not text: a join on the common variable names
joinedByName = mapAontoB(1, 2, tableA, tableB, 0);
assert(isequal(joinedByName.id, {'b'; 'z'}) && joinedByName.v(1) == 2);

%% a repeated key in A: the first one is used and a warning is issued

lastwarn('');
mapped = mapAontoB({'a', 'a', 'b'}, {'a', 'b'}, [1; 2; 3]);
assert(contains(lastwarn, 'Akey is not unique'));
assert(isequal(full(mapped)', [1 3]));

%% without Ain: the keys of B that are in A, an empty, NaN or false entry otherwise

[mapped, isFound, positionInA] = mapAontoB(keysA, keysB);
assert(isequal(mapped, {'b'; []; 'c'}));
assert(isequal(isFound, [true false true]) && isequal(positionInA, [2 0 3]));
% numeric keys: NaN for the key that is not in A
assert(isequaln(full(mapAontoB([1 2 3], [3 4 2])), [3; NaN; 2]));
% int64 keys are returned as numbers, with NaN for the key that is not in A
assert(isequaln(full(mapAontoB(int64([1 2 3]), int64([3 4]))), [3; NaN]));
% logical keys: false for the key that is not in A
assert(isequal(mapAontoB(true, [false true]), [false; true]));
% a key class that cannot be filled
assert(verifyCobraFunctionError('mapAontoB', 'inputs', {single([1 2]), single(1)}, ...
    'testMessage', 'unrecognised class'));

%% keys of different classes raise the documented error

% class names of different lengths (cell and double)
assert(verifyCobraFunctionError('mapAontoB', 'inputs', {{'a'}, 1}, ...
    'testMessage', 'class of Akey and Bkey must be the same'));
% class names of the same length (cell and char, double and single)
assert(verifyCobraFunctionError('mapAontoB', 'inputs', {{'a'}, 'a', 1, [], 0}, ...
    'testMessage', 'class of Akey and Bkey must be the same'));
assert(verifyCobraFunctionError('mapAontoB', 'inputs', {[1 2], single([1 2]), [5; 6], [], 0}, ...
    'testMessage', 'class of Akey and Bkey must be the same'));

%% invalid input

% Ain and Bin of different classes
assert(verifyCobraFunctionError('mapAontoB', 'inputs', {keysA, keysB, [1; 2; 3], {'a'; 'b'; 'c'}, 0}, ...
    'testMessage', 'Class of Ain and Bin must be the same'));
% Ain and Bin with different numbers of columns
assert(verifyCobraFunctionError('mapAontoB', 'inputs', {keysA, keysB, [1 2; 3 4; 5 6], zeros(3, 1), 0}, ...
    'testMessage', 'size(Bout,2)~=size(Ain,2)'));
% a class of Ain that cannot be filled
assert(verifyCobraFunctionError('mapAontoB', 'inputs', {keysA, keysB, single([1; 2; 3]), [], 0}, ...
    'testMessage', 'unrecognised class'));

% change the directory
cd(currentDir)
