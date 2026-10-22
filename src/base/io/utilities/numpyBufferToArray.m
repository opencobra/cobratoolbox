function array = numpyBufferToArray(raw, dtype, shape, isFortran)
% Converts the raw data buffer of a NumPy array (e.g. stored in a pickle
% file) into a MATLAB array. Used by `readPythonPickle`.
%
% USAGE:
%
%    array = numpyBufferToArray(raw, dtype, shape, isFortran)
%
% INPUTS:
%    raw:          (uint8) raw bytes of the array, or a cell array with the
%                  elements of an object array
%    dtype:        (char) NumPy type string, e.g. '<f8', '|b1', '>i4'
%    shape:        (double) shape of the array (empty for 0-d arrays)
%    isFortran:    (logical) the data is stored in Fortran (column-major)
%                  order
%
% OUTPUT:
%    array:        numeric or logical array (cell array for object arrays).
%                  Arrays stored in C order are permuted so that
%                  `array(i, j)` corresponds to `array[i-1, j-1]` in Python;
%                  one-dimensional arrays are column vectors
%
% EXAMPLE:
%
%    array = numpyBufferToArray(uint8([1 0 0 0 2 0 0 0]), '<i4', 2, false);
%
% .. Author: - Sebastián N. Mendoza, 21/10/2026

if nargin < 4
    error('raw, dtype, shape and isFortran must be provided.');
end
if ~ischar(dtype)
    error('dtype must be a NumPy type string.');
end
code = regexprep(dtype, '^[<>|=]', '');
classes = {'b1', 'uint8'; 'i1', 'int8'; 'u1', 'uint8'; 'i2', 'int16'; 'u2', 'uint16'; ...
    'i4', 'int32'; 'u4', 'uint32'; 'i8', 'int64'; 'u8', 'uint64'; 'f4', 'single'; 'f8', 'double'};
row = find(strcmp(classes(:, 1), code));
if iscell(raw)
    values = raw(:);
elseif isempty(row)
    error('NumPy data type %s is not supported.', dtype);
else
    raw = uint8(raw(:)');
    if dtype(1) == '>'
        itemSize = numel(typecast(zeros(1, 1, classes{row, 2}), 'uint8'));
        raw = reshape(fliplr(reshape(raw, itemSize, [])')', 1, []);
    end
    values = typecast(raw, classes{row, 2});
    if strcmp(code, 'b1')
        values = values ~= 0;
    end
    values = values(:);
end
shape = double(shape(:)');
if isempty(shape)
    array = values;
elseif numel(shape) == 1
    array = reshape(values, shape, 1);
elseif isFortran
    array = reshape(values, shape);
else
    array = permute(reshape(values, fliplr(shape)), numel(shape):-1:1);
end
end
