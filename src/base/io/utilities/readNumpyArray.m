function data = readNumpyArray(fileName)
% Reads an array stored in the NumPy binary format (.npy, versions 1.0, 2.0
% and 3.0). Arrays stored in C (row-major) order are permuted so that
% `data(i, j, ...)` corresponds to `array[i-1, j-1, ...]` in Python.
% One-dimensional arrays are returned as column vectors.
%
% USAGE:
%
%    data = readNumpyArray(fileName)
%
% INPUT:
%    fileName:     (string) path to the .npy file
%
% OUTPUT:
%    data:         array with the data. Supported data types: bool
%                  (returned as logical), signed and unsigned integers of
%                  1, 2, 4 and 8 bytes (returned with the corresponding
%                  integer class) and floats of 4 and 8 bytes (single and
%                  double)
%
% EXAMPLE:
%
%    qual = double(readNumpyArray('scenario_qFVA_feasibleOnly_0_250.npy'));
%
% .. Author: - Sebastián N. Mendoza, 13/10/2026

if nargin < 1 || ~(ischar(fileName) || isstring(fileName))
    error('fileName must be a string.');
end
fileName = char(fileName);
if ~exist(fileName, 'file')
    error('File %s not found.', fileName);
end

fid = fopen(fileName, 'r', 'l');
if fid < 0
    error('File %s could not be opened.', fileName);
end
magic = fread(fid, 6, 'uint8=>uint8')';
if ~isequal(magic, [147, uint8('NUMPY')])
    fclose(fid);
    error('%s is not a NumPy .npy file.', fileName);
end
version = fread(fid, 2, 'uint8=>double')';
if version(1) == 1
    headerLength = fread(fid, 1, 'uint16=>double');
else
    headerLength = fread(fid, 1, 'uint32=>double');
end
header = fread(fid, headerLength, 'char=>char')';

descr = regexp(header, '''descr''\s*:\s*''([^'']+)''', 'tokens', 'once');
fortranOrder = regexp(header, '''fortran_order''\s*:\s*(True|False)', 'tokens', 'once');
shapeText = regexp(header, '''shape''\s*:\s*\(([^\)]*)\)', 'tokens', 'once');
if isempty(descr) || isempty(fortranOrder) || isempty(shapeText)
    fclose(fid);
    error('Header of %s could not be parsed: %s', fileName, header);
end
descr = descr{1};
fortranOrder = strcmp(fortranOrder{1}, 'True');
shape = str2double(regexp(shapeText{1}, '\d+', 'match'));

byteOrder = descr(1);
typeCode = descr(2:end);
types = {'b1', 'uint8', 'logical'; 'i1', 'int8', 'int8'; 'u1', 'uint8', 'uint8'; ...
    'i2', 'int16', 'int16'; 'u2', 'uint16', 'uint16'; 'i4', 'int32', 'int32'; ...
    'u4', 'uint32', 'uint32'; 'i8', 'int64', 'int64'; 'u8', 'uint64', 'uint64'; ...
    'f4', 'single', 'single'; 'f8', 'double', 'double'};
row = find(strcmp(types(:, 1), typeCode));
if isempty(row)
    fclose(fid);
    error('Data type %s of %s is not supported.', descr, fileName);
end
machineFormat = 'l';
if byteOrder == '>'
    machineFormat = 'b';
end
nElements = prod(shape);
raw = fread(fid, nElements, [types{row, 2} '=>' types{row, 2}], 0, machineFormat);
fclose(fid);
if numel(raw) ~= nElements
    error('Unexpected end of file in %s.', fileName);
end
if strcmp(types{row, 3}, 'logical')
    raw = raw ~= 0;
end

if isempty(shape)
    data = raw;
elseif numel(shape) == 1
    data = raw(:);
elseif fortranOrder
    data = reshape(raw, shape);
else
    data = permute(reshape(raw, fliplr(shape)), numel(shape):-1:1);
end
end
