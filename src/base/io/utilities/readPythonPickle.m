function data = readPythonPickle(fileName)
% Reads a Python pickle file (binary protocols 2 to 5, with in-band buffers
% for protocol 5) containing basic Python objects and NumPy arrays,
% without requiring Python. Supported objects and their MATLAB
% representation:
%
%    =======================  ==========================================
%    Python                   MATLAB
%    =======================  ==========================================
%    dict, OrderedDict        containers.Map (char keys)
%    list, set                column cell array
%    tuple                    row cell array
%    str                      char
%    bytes                    uint8 row vector
%    int, float               double
%    bool                     logical
%    None                     []
%    numpy.ndarray            numeric/logical array (cell for object arrays)
%    numpy scalar             numeric/logical scalar
%    other objects            structure with fields pyClass, args and state
%    =======================  ==========================================
%
% USAGE:
%
%    data = readPythonPickle(fileName)
%
% INPUT:
%    fileName:     (string) path to the pickle file
%
% OUTPUT:
%    data:         MATLAB representation of the pickled object
%
% EXAMPLE:
%
%    data = readPythonPickle('biomin_newgrid_sce_a02_biocons_75Fe_5S.p');
%    points = data('points');
%    rxn2cluster = data('rxn2cluster');
%
% NOTE:
%
%    Arrays stored in C order are permuted so that `A(i, j)` corresponds to
%    `array[i-1, j-1]` in Python. Objects referenced several times in the
%    pickle (shared references) are read completely: lists and sets are
%    built in handle objects and converted to cell arrays at the end (see
%    `resolvePickleProxies`), so each reference receives a copy of the
%    complete list. Dictionaries (containers.Map) are handle objects, so
%    shared dictionaries remain shared in MATLAB.
%
% .. Author: - Sebastián N. Mendoza, 13/10/2026

if nargin < 1 || ~(ischar(fileName) || isstring(fileName))
    error('fileName must be a string.');
end
fileName = char(fileName);
fid = fopen(fileName, 'r');
if fid < 0
    error('File %s could not be opened.', fileName);
end
b = fread(fid, Inf, 'uint8=>uint8')';
fclose(fid);
if isempty(b) || b(1) ~= 128
    error('%s is not a binary pickle file (protocol >= 2).', fileName);
end

mark = struct('pyMark', true);
stack = {};
memo = {};
p = 1;
nBytes = numel(b);
finished = false;
while p <= nBytes && ~finished
    op = b(p);
    p = p + 1;
    switch op
        case 128 % PROTO
            p = p + 1;
        case 149 % FRAME
            p = p + 8;
        case 125 % EMPTY_DICT
            stack{end + 1} = containers.Map('KeyType', 'char', 'ValueType', 'any');
        case {93, 143} % EMPTY_LIST, EMPTY_SET (list proxies, see resolvePickleProxies)
            stack{end + 1} = containers.Map('KeyType', 'double', 'ValueType', 'any');
        case 41 % EMPTY_TUPLE
            stack{end + 1} = cell(1, 0);
        case 40 % MARK
            stack{end + 1} = mark;
        case 148 % MEMOIZE
            memo{end + 1} = stack{end};
        case 113 % BINPUT
            memo{double(b(p)) + 1} = stack{end};
            p = p + 1;
        case 114 % LONG_BINPUT
            memo{double(typecast(b(p:p + 3), 'uint32')) + 1} = stack{end};
            p = p + 4;
        case 104 % BINGET
            stack{end + 1} = memo{double(b(p)) + 1};
            p = p + 1;
        case 106 % LONG_BINGET
            stack{end + 1} = memo{double(typecast(b(p:p + 3), 'uint32')) + 1};
            p = p + 4;
        case {140, 88, 141, 85, 84} % SHORT_BINUNICODE, BINUNICODE, BINUNICODE8, SHORT_BINSTRING, BINSTRING
            if op == 140 || op == 85
                n = double(b(p));
                p = p + 1;
            elseif op == 141
                n = double(typecast(b(p:p + 7), 'uint64'));
                p = p + 8;
            else
                n = double(typecast(b(p:p + 3), 'uint32'));
                p = p + 4;
            end
            stack{end + 1} = native2unicode(b(p:p + n - 1), 'UTF-8');
            p = p + n;
        case {67, 66, 142, 150} % SHORT_BINBYTES, BINBYTES, BINBYTES8, BYTEARRAY8
            if op == 67
                n = double(b(p));
                p = p + 1;
            elseif op == 66
                n = double(typecast(b(p:p + 3), 'uint32'));
                p = p + 4;
            else
                n = double(typecast(b(p:p + 7), 'uint64'));
                p = p + 8;
            end
            stack{end + 1} = b(p:p + n - 1);
            p = p + n;
        case 152 % READONLY_BUFFER (in-band buffers are read as bytes)
        case 151 % NEXT_BUFFER
            error('%s uses out-of-band buffers (pickle protocol 5), which are not supported.', fileName);
        case 147 % STACK_GLOBAL
            name = stack{end};
            module = stack{end - 1};
            stack(end - 1:end) = [];
            stack{end + 1} = struct('pyGlobal', [module '.' name]);
        case 99 % GLOBAL
            nl = find(b(p:end) == 10, 2);
            module = char(b(p:p + nl(1) - 2));
            name = char(b(p + nl(1):p + nl(2) - 2));
            p = p + nl(2);
            stack{end + 1} = struct('pyGlobal', [module '.' name]);
        case 75 % BININT1
            stack{end + 1} = double(b(p));
            p = p + 1;
        case 77 % BININT2
            stack{end + 1} = double(typecast(b(p:p + 1), 'uint16'));
            p = p + 2;
        case 74 % BININT
            stack{end + 1} = double(typecast(b(p:p + 3), 'int32'));
            p = p + 4;
        case 138 % LONG1
            n = double(b(p));
            p = p + 1;
            bytesLong = double(b(p:p + n - 1));
            value = sum(bytesLong .* 256 .^ (0:n - 1));
            if n > 0 && bytesLong(end) >= 128
                value = value - 256 ^ n;
            end
            stack{end + 1} = value;
            p = p + n;
        case 71 % BINFLOAT (big endian)
            stack{end + 1} = typecast(fliplr(b(p:p + 7)), 'double');
            p = p + 8;
        case 136 % NEWTRUE
            stack{end + 1} = true;
        case 137 % NEWFALSE
            stack{end + 1} = false;
        case 78 % NONE
            stack{end + 1} = [];
        case {116, 144, 145} % TUPLE, ADDITEMS, FROZENSET
            for m = numel(stack):-1:1
                if isstruct(stack{m}) && isfield(stack{m}, 'pyMark')
                    break
                end
            end
            items = stack(m + 1:end);
            stack(m:end) = [];
            if op == 116
                stack{end + 1} = items;
            elseif op == 145
                stack{end + 1} = items(:);
            else
                target = stack{end};
                for i = 1:numel(items)
                    target(target.Count + 1) = items{i};
                end
            end
        case 133 % TUPLE1
            stack{end} = stack(end);
        case 134 % TUPLE2
            items = stack(end - 1:end);
            stack(end - 1:end) = [];
            stack{end + 1} = items;
        case 135 % TUPLE3
            items = stack(end - 2:end);
            stack(end - 2:end) = [];
            stack{end + 1} = items;
        case {82, 129} % REDUCE, NEWOBJ
            args = resolvePickleProxies(stack{end});
            callable = stack{end - 1};
            stack(end - 1:end) = [];
            if isstruct(callable) && isfield(callable, 'pyGlobal')
                className = callable.pyGlobal;
            else
                className = 'unknown';
            end
            if ~iscell(args)
                args = {args};
            end
            if any(strcmp(className, {'numpy.core.multiarray._reconstruct', 'numpy._core.multiarray._reconstruct'}))
                obj = struct('pyNdarray', true, 'value', []);
            elseif any(strcmp(className, {'numpy.core.numeric._frombuffer', 'numpy._core.numeric._frombuffer'}))
                % arrays of protocol 5: (buffer, dtype, shape, order)
                dtype = args{2};
                obj = numpyBufferToArray(args{1}, [dtype.byteOrder, regexprep(dtype.pyDtype, '^[<>|=]', '')], ...
                    cell2mat(args{3}), strcmp(args{4}, 'F'));
            elseif strcmp(className, 'numpy.dtype')
                obj = struct('pyDtype', args{1}, 'byteOrder', '<');
            elseif any(strcmp(className, {'numpy.core.multiarray.scalar', 'numpy._core.multiarray.scalar'}))
                dtype = args{1};
                raw = args{2};
                code = regexprep(dtype.pyDtype, '^[<>|=]', '');
                classes = {'b1', 'uint8'; 'i1', 'int8'; 'u1', 'uint8'; 'i2', 'int16'; 'u2', 'uint16'; ...
                    'i4', 'int32'; 'u4', 'uint32'; 'i8', 'int64'; 'u8', 'uint64'; 'f4', 'single'; 'f8', 'double'};
                row = find(strcmp(classes(:, 1), code));
                if isempty(row)
                    obj = struct('pyClass', className, 'args', {args}, 'state', []);
                else
                    if strcmp(dtype.byteOrder, '>')
                        raw = fliplr(raw);
                    end
                    obj = double(typecast(uint8(raw), classes{row, 2}));
                    if strcmp(code, 'b1')
                        obj = obj ~= 0;
                    end
                end
            elseif strcmp(className, '_codecs.encode') && numel(args) == 2 && any(strcmpi(args{2}, {'latin1', 'latin-1'}))
                % bytes of protocol 2: _codecs.encode(text, 'latin1')
                obj = uint8(double(args{1}));
            elseif any(strcmp(className, {'builtins.bytes', '__builtin__.bytes'})) && isempty(args)
                obj = zeros(1, 0, 'uint8');
            elseif strcmp(className, 'collections.OrderedDict')
                obj = containers.Map('KeyType', 'char', 'ValueType', 'any');
            elseif any(strcmp(className, {'builtins.set', 'builtins.frozenset', '__builtin__.set', '__builtin__.frozenset'}))
                if isempty(args)
                    obj = cell(0, 1);
                else
                    obj = args{1}(:);
                end
            else
                obj = struct('pyClass', className, 'args', {args}, 'state', []);
            end
            stack{end + 1} = obj;
        case 98 % BUILD
            state = stack{end};
            stack(end) = [];
            obj = stack{end};
            if isstruct(obj) && isfield(obj, 'pyNdarray')
                % state: (version, shape, dtype, isFortran, rawdata)
                state = resolvePickleProxies(state);
                dtype = state{3};
                obj = numpyBufferToArray(state{5}, [dtype.byteOrder, regexprep(dtype.pyDtype, '^[<>|=]', '')], ...
                    cell2mat(state{2}), state{4});
            elseif isstruct(obj) && isfield(obj, 'pyDtype')
                if iscell(state) && numel(state) >= 2 && ischar(state{2})
                    obj.byteOrder = state{2};
                end
            elseif isstruct(obj) && isfield(obj, 'pyClass')
                obj.state = state;
            elseif isa(obj, 'containers.Map') && isa(state, 'containers.Map')
                keysState = keys(state);
                for i = 1:numel(keysState)
                    obj(keysState{i}) = state(keysState{i});
                end
            end
            stack{end} = obj;
        case 115 % SETITEM
            value = stack{end};
            key = stack{end - 1};
            stack(end - 1:end) = [];
            if ~ischar(key)
                key = num2str(key);
            end
            dict = stack{end};
            dict(key) = value; %#ok<NASGU>
        case 117 % SETITEMS
            for m = numel(stack):-1:1
                if isstruct(stack{m}) && isfield(stack{m}, 'pyMark')
                    break
                end
            end
            items = stack(m + 1:end);
            stack(m:end) = [];
            dict = stack{end};
            for i = 1:2:numel(items)
                key = items{i};
                if ~ischar(key)
                    key = num2str(key);
                end
                dict(key) = items{i + 1};
            end
        case 97 % APPEND
            value = stack{end};
            stack(end) = [];
            target = stack{end};
            target(target.Count + 1) = value;
        case 101 % APPENDS
            for m = numel(stack):-1:1
                if isstruct(stack{m}) && isfield(stack{m}, 'pyMark')
                    break
                end
            end
            items = stack(m + 1:end);
            stack(m:end) = [];
            target = stack{end};
            for i = 1:numel(items)
                target(target.Count + 1) = items{i};
            end
        case 48 % POP
            stack(end) = [];
        case 49 % POP_MARK
            for m = numel(stack):-1:1
                if isstruct(stack{m}) && isfield(stack{m}, 'pyMark')
                    break
                end
            end
            stack(m:end) = [];
        case 50 % DUP
            stack{end + 1} = stack{end};
        case 46 % STOP
            finished = true;
        otherwise
            error('Unsupported pickle opcode 0x%s at byte %d of %s.', dec2hex(op), p - 1, fileName);
    end
end
if isempty(stack)
    error('Empty pickle file %s.', fileName);
end
data = resolvePickleProxies(stack{end});
end
