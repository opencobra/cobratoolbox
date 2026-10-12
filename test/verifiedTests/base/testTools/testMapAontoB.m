% The COBRAToolbox: testMapAontoB.m
%
% Purpose:
%     - mapAontoB maps the rows of A onto the keys of B: the output has one row per key of B, filled
%     from A where the keys match.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/utilities/mapAontoB.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Line 44 (the class check of the keys) and lines 122-135 (the call without Ain) of
%     mapAontoB.m are not tested because of the defects below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The check that Akey and Bkey have the same class is broken
%       SEVERITY: error
%       TRIGGER: Akey and Bkey of different classes, for example {'a'} and 1
%       OBSERVED: the class names are compared with ~=, so classes with names of different length
%         give an incompatible-sizes error, and classes whose names have the same length are not
%         detected
%       EXPECTED: the error: class of Akey and Bkey must be the same
%       LINES: 43-45
%     - DEFECT: Without Ain the matched keys of B are returned wrongly
%       SEVERITY: wrong-result
%       TRIGGER: a call with only Akey and Bkey
%       OBSERVED: the matched keys are taken with a logical index that picks the first entries of
%         Bkey (for Akey {a,b,c} and Bkey {b,z,c} the result is {b,[],z} instead of {b,[],c})
%       EXPECTED: {b,[],c}
%       LINES: 121-135
%
% Authors:
%     - Generated for feature tier1-test-batch3, 2026-10-12.

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
