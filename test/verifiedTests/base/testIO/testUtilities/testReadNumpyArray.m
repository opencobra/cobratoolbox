% The COBRAToolbox: testReadNumpyArray.m
%
% Purpose:
%     - readNumpyArray reads an array stored in the NumPy binary format (.npy, versions 1.0,
%       2.0 and 3.0) and returns it with the MATLAB class of its data type, permuting arrays
%       stored in C order so that data(i, j, ...) is array[i-1, j-1, ...], and returning
%       one-dimensional arrays as columns. This test writes small .npy files byte by byte
%       following the published format (magic string, version, header length, header dict,
%       data) and checks every supported data type, both byte orders, C and Fortran order,
%       0-d, 1-d, 3-d and empty arrays, and every error the function raises.
%     - Expected values are the values written into each file, arranged as the NumPy
%       documentation defines C order (last index fastest) and Fortran order (first index
%       fastest).
%
% Function under test:
%     src/base/io/utilities/readNumpyArray.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; the input files are written by the test into a tempname
%     folder that is removed at the end.
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
fileDir = fileparts(which('testReadNumpyArray'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

tmpDir = tempname;
mkdir(tmpDir);

% .npy files to write: format version, descr, fortran_order, shape text, values written in
% file order, fwrite precision, byte order of the data ('l' little, 'b' big endian), and the
% expected result (class and values)
[i3, j3, k3] = ndgrid(1:2, 1:3, 1:4);
npyCases = {
    % C order 2 x 3: file order is row by row
    1, '<f8', 'False', '(2, 3)', 1:6, 'float64', 'l', [1 2 3; 4 5 6]
    % Fortran order 2 x 3: file order is column by column
    1, '<i4', 'True', '(2, 3)', [1 4 2 5 3 6], 'int32', 'l', int32([1 2 3; 4 5 6])
    % version 2.0 (4-byte header length), one-dimensional: a column
    2, '<u2', 'False', '(4,)', [1 2 3 65535], 'uint16', 'l', uint16([1; 2; 3; 65535])
    % version 3.0, booleans: every non-zero byte is true
    3, '|b1', 'False', '(3,)', [1 0 2], 'uint8', 'l', [true; false; true]
    % big endian 64-bit integers
    1, '>i8', 'False', '(2,)', [-2 258], 'int64', 'b', int64([-2; 258])
    % big endian 4-byte floats in Fortran order
    1, '>f4', 'True', '(1, 2)', [1.5 -2.5], 'float32', 'b', single([1.5 -2.5])
    % 0-d array (shape ()): a scalar
    1, '|i1', 'False', '()', -5, 'int8', 'l', int8(-5)
    % three dimensions in C order: array[i, j, k] = 12 i + 4 j + k (0-based)
    1, '<f4', 'False', '(2, 3, 4)', 0:23, 'float32', 'l', single((i3 - 1) * 12 + (j3 - 1) * 4 + (k3 - 1))
    % the remaining integer types
    1, '|u1', 'False', '(2,)', [0 255], 'uint8', 'l', uint8([0; 255])
    1, '<i2', 'False', '(2,)', [-1 300], 'int16', 'l', int16([-1; 300])
    1, '<u4', 'False', '(2,)', [1 4000000000], 'uint32', 'l', uint32([1; 4000000000])
    1, '<u8', 'False', '(2,)', [1 2^40], 'uint64', 'l', uint64([1; 2^40])
    % empty arrays: zero elements in one and in two dimensions
    1, '<f8', 'False', '(0,)', [], 'float64', 'l', zeros(0, 1)
    1, '<f8', 'False', '(2, 0)', [], 'float64', 'l', zeros(2, 0)
    };

%% every supported type, byte order, memory order and number of dimensions

for c = 1:size(npyCases, 1)
    [version, descr, fortranText, shapeText, fileValues, precision, byteOrder, expected] = npyCases{c, :};
    % header dict padded with spaces and ended by a newline so that the data start at a
    % multiple of 64 bytes (6 magic + 2 version + 2 or 4 header-length bytes before it)
    header = sprintf('{''descr'': ''%s'', ''fortran_order'': %s, ''shape'': %s, }', descr, fortranText, shapeText);
    prefixLength = 8 + 2 * (1 + (version > 1));
    header = [header, repmat(' ', 1, mod(-(prefixLength + numel(header) + 1), 64)), newline];
    npyFile = fullfile(tmpDir, sprintf('case%d.npy', c));
    fid = fopen(npyFile, 'w', 'l');
    fwrite(fid, [147, double('NUMPY'), version, 0], 'uint8');
    if version == 1
        fwrite(fid, numel(header), 'uint16');
    else
        fwrite(fid, numel(header), 'uint32');
    end
    fwrite(fid, header, 'char');
    fwrite(fid, fileValues, precision, 0, byteOrder);
    fclose(fid);

    data = readNumpyArray(npyFile);
    % class, size and values are exact: integers and binary fractions are stored exactly
    assert(strcmp(class(data), class(expected)), sprintf('case %d: class %s', c, class(data)));
    assert(isequal(size(data), size(expected)), sprintf('case %d: size', c));
    assert(isequal(data, expected), sprintf('case %d: values', c));
end

%% the file name may be a string scalar

data = readNumpyArray(string(fullfile(tmpDir, 'case1.npy')));
assert(isequal(data, [1 2 3; 4 5 6]));

%% errors: no or non-text file name, missing file, folder, other format, bad header

assert(verifyCobraFunctionError('readNumpyArray', 'testMessage', 'fileName must be a string.'));
assert(verifyCobraFunctionError('readNumpyArray', 'inputs', {1}, 'testMessage', 'fileName must be a string.'));
missingFile = fullfile(tmpDir, 'missing.npy');
assert(verifyCobraFunctionError('readNumpyArray', 'inputs', {missingFile}, ...
    'testMessage', sprintf('File %s not found.', missingFile)));
% a folder exists but cannot be opened as a file
assert(verifyCobraFunctionError('readNumpyArray', 'inputs', {tmpDir}, ...
    'testMessage', sprintf('File %s could not be opened.', tmpDir)));
% a text file does not start with the magic string \x93NUMPY
textFile = fullfile(tmpDir, 'notNumpy.txt');
fid = fopen(textFile, 'w');
fprintf(fid, 'not a NumPy file');
fclose(fid);
assert(verifyCobraFunctionError('readNumpyArray', 'inputs', {textFile}, ...
    'testMessage', sprintf('%s is not a NumPy .npy file.', textFile)));
% a header without descr, fortran_order and shape
badHeader = ['{}', repmat(' ', 1, 53), newline];
badHeaderFile = fullfile(tmpDir, 'badHeader.npy');
fid = fopen(badHeaderFile, 'w', 'l');
fwrite(fid, [147, double('NUMPY'), 1, 0], 'uint8');
fwrite(fid, numel(badHeader), 'uint16');
fwrite(fid, badHeader, 'char');
fclose(fid);
assert(verifyCobraFunctionError('readNumpyArray', 'inputs', {badHeaderFile}, ...
    'testMessage', sprintf('Header of %s could not be parsed: %s', badHeaderFile, badHeader)));

%% errors: unsupported data type and truncated data

% complex numbers ('<c16') and a file that holds 2 of the 4 elements its shape announces
errorCases = {'<c16', '(1,)', [1 0], 'Data type <c16 of %s is not supported.'
    '<f8', '(4,)', [1 2], 'Unexpected end of file in %s.'};
for c = 1:size(errorCases, 1)
    header = sprintf('{''descr'': ''%s'', ''fortran_order'': False, ''shape'': %s, }', errorCases{c, 1}, errorCases{c, 2});
    header = [header, repmat(' ', 1, mod(-(10 + numel(header) + 1), 64)), newline];
    npyFile = fullfile(tmpDir, sprintf('error%d.npy', c));
    fid = fopen(npyFile, 'w', 'l');
    fwrite(fid, [147, double('NUMPY'), 1, 0], 'uint8');
    fwrite(fid, numel(header), 'uint16');
    fwrite(fid, header, 'char');
    fwrite(fid, errorCases{c, 3}, 'float64');
    fclose(fid);
    assert(verifyCobraFunctionError('readNumpyArray', 'inputs', {npyFile}, ...
        'testMessage', sprintf(errorCases{c, 4}, npyFile)));
end

% remove the temporary files and change the directory
rmdir(tmpDir, 's');
cd(currentDir)
