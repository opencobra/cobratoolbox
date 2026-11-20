% The COBRAToolbox: testNumpyBufferToArray.m
%
% Purpose:
%     - numpyBufferToArray converts the raw byte buffer of a NumPy array (as stored in a
%       pickle) into a MATLAB array of the class of its data type: big endian buffers are
%       byte-swapped, booleans become logical, C-order arrays are permuted so that
%       array(i, j, ...) is array[i-1, j-1, ...], one-dimensional arrays become columns,
%       0-d arrays scalars, and object arrays (a cell of elements) are reshaped the same way.
%     - Expected values are built by hand: the bytes are written with typecast (native little
%       endian, the order NumPy uses for '<') or reversed per element for '>', and the
%       arrangement follows the NumPy definitions of C order (last index fastest) and Fortran
%       order (first index fastest). The documented example is checked as given.
%
% Function under test:
%     src/base/io/utilities/numpyBufferToArray.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built byte buffers.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testNumpyBufferToArray'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the hand-built little-endian buffers below rely on typecast giving the bytes in the
% machine's order; every platform MATLAB supports is little endian
[~, ~, machineEndian] = computer;
assert(strcmp(machineEndian, 'L'));

%% documented example: two little-endian int32 values in a one-dimensional array

array = numpyBufferToArray(uint8([1 0 0 0 2 0 0 0]), '<i4', 2, false);
% integers are exact; one-dimensional arrays are columns
assert(isa(array, 'int32') && isequal(array, int32([1; 2])));

%% every numeric type, little endian ('<', '|' and no prefix), one-dimensional

typeCases = {'|i1', int8([-1 5]); '|u1', uint8([0 255]); '<i2', int16([-300 7]); ...
    '<u2', uint16([1 65535]); 'i4', int32([-70000 3]); '<u4', uint32([1 4000000000]); ...
    '<i8', int64([-2 2^40]); '=u8', uint64([3 2^50]); '<f4', single([1.5 -0.25]); ...
    '<f8', [pi -1e300]};
for t = 1:size(typeCases, 1)
    values = typeCases{t, 2};
    array = numpyBufferToArray(typecast(values, 'uint8'), typeCases{t, 1}, 2, false);
    % the bytes are reinterpreted, not converted, so the values are exact
    assert(isa(array, class(values)) && isequal(array, values(:)), typeCases{t, 1});
end

%% booleans: every non-zero byte is true

array = numpyBufferToArray(uint8([1 0 7]), '|b1', 3, false);
assert(islogical(array) && isequal(array, [true; false; true]));

%% big endian: the bytes of each element are reversed before the conversion

values = int32([1 -2 300]);
bigEndianBytes = reshape(flipud(reshape(typecast(values, 'uint8'), 4, [])), 1, []);
array = numpyBufferToArray(bigEndianBytes, '>i4', 3, false);
assert(isequal(array, values(:)));
values = [0.5 -3];
bigEndianBytes = reshape(flipud(reshape(typecast(values, 'uint8'), 8, [])), 1, []);
% a double buffer given as a column of doubles holding byte values is converted to uint8
array = numpyBufferToArray(double(bigEndianBytes(:)), '>f8', 2, false);
assert(isequal(array, values(:)));

%% shapes: 0-d, C order and Fortran order in two and three dimensions

% 0-d (empty shape): a scalar
array = numpyBufferToArray(typecast(2.5, 'uint8'), '<f8', [], false);
assert(isequal(array, 2.5));
% 2 x 3, C order: the buffer holds the rows one after the other
array = numpyBufferToArray(typecast(int16(1:6), 'uint8'), '<i2', [2 3], false);
assert(isequal(array, int16([1 2 3; 4 5 6])));
% 2 x 3, Fortran order: the buffer holds the columns one after the other
array = numpyBufferToArray(typecast(int16([1 4 2 5 3 6]), 'uint8'), '<i2', int64([2 3]), true);
assert(isequal(array, int16([1 2 3; 4 5 6])));
% 2 x 3 x 4, C order: array[i, j, k] = 12 i + 4 j + k (0-based)
[i3, j3, k3] = ndgrid(1:2, 1:3, 1:4);
array = numpyBufferToArray(typecast(0:23, 'uint8'), '<f8', [2; 3; 4], false);
assert(isequal(array, (i3 - 1) * 12 + (j3 - 1) * 4 + (k3 - 1)));

%% object arrays: the elements are given as a cell array (any dtype text)

array = numpyBufferToArray({'a', 1, 'b', 2, 'c', 3}, '|O', [2 3], false);
assert(isequal(array, {'a', 1, 'b'; 2, 'c', 3}));
array = numpyBufferToArray({'a'; 1}, '|O', 2, false);
assert(isequal(array, {'a'; 1}));

%% errors: missing inputs, dtype not a text, unsupported dtype

assert(verifyCobraFunctionError('numpyBufferToArray', 'inputs', {uint8([1 0]), '<i2', 1}, ...
    'testMessage', 'raw, dtype, shape and isFortran must be provided.'));
assert(verifyCobraFunctionError('numpyBufferToArray', 'inputs', {uint8([1 0]), 2, 1, false}, ...
    'testMessage', 'dtype must be a NumPy type string.'));
assert(verifyCobraFunctionError('numpyBufferToArray', 'inputs', {uint8(1:16), '<c16', 1, false}, ...
    'testMessage', 'NumPy data type <c16 is not supported.'));

% change the directory
cd(currentDir)
