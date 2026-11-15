% The COBRAToolbox: testReadPythonPickle.m
%
% Purpose:
%     - readPythonPickle reads a binary Python pickle (protocols 2 to 5) without Python and
%       returns its MATLAB representation as documented in its header (dict -> containers.Map,
%       list/set -> column cell, tuple -> row cell, str -> char, bytes -> uint8, numbers ->
%       double, bool -> logical, None -> [], NumPy arrays and scalars -> numeric/logical
%       arrays, other objects -> structure with pyClass, args and state).
%     - This test reads the pickle files written by Python for the older shared test
%       (test/verifiedTests/base/testIO/pythonFiles/pickle_protocol2.p to 5: one dictionary
%       with 43 entries covering every supported object), whose content is fixed by the
%       Python script that wrote them, and pickles written byte by byte here for the opcodes
%       that Python does not write for these objects (BINSTRING, SHORT_BINSTRING,
%       BINUNICODE8, BINBYTES8, READONLY_BUFFER, POP, POP_MARK, DUP, BUILD of a dictionary,
%       empty bytes, a set without arguments, big-endian and unsupported NumPy scalars, an
%       object of unknown class) and for the
%       errors (wrong input, missing file, text file, out-of-band buffers, unsupported
%       opcode, empty pickle). Expected values of the hand-written pickles follow from the
%       pickle opcode definitions (Python's pickletools documentation), by hand.
%
% Function under test:
%     src/base/io/utilities/readPythonPickle.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, small pickle files (fixtures and a temporary folder).
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testReadPythonPickle'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the pickle files written by Python, and a temporary folder for the hand-written pickles
pythonDir = fullfile(fileparts(fileDir), 'pythonFiles');
tmpDir = tempname;
mkdir(tmpDir);
% write a byte vector to a pickle file in the temporary folder and read it back
readBytes = @(bytes) readPythonPickle(writePickle(fullfile(tmpDir, 'test.p'), bytes));

%% pickles written by Python, protocols 2 to 5: every supported object

for protocol = 2:5
    data = readPythonPickle(fullfile(pythonDir, sprintf('pickle_protocol%d.p', protocol)));
    % a dict becomes a containers.Map with char keys
    assert(isa(data, 'containers.Map') && data.Count == 43);
    % integers of every size (BININT1, BININT2, BININT, LONG1 positive and negative), float,
    % booleans and None; all numbers are doubles, integers are exact
    assert(data('int_small') == 7 && data('int_medium') == 300 && data('int_negative') == -5);
    assert(data('int_large') == 70000 && data('long_positive') == 2 ^ 40 && data('long_negative') == -2 ^ 40);
    assert(data('float') == 2.5 && islogical(data('true')) && data('true') && ~data('false'));
    assert(isempty(data('none')));
    % strings (short, long, non-ASCII UTF-8) and bytes (short, long)
    assert(strcmp(data('str_short'), 'abc') && strcmp(data('str_long'), repmat('x', 1, 300)));
    assert(strcmp(data('str_unicode'), char([74 105 109 233 110 101 122])));
    assert(isequal(data('bytes_short'), uint8([1 2])) && isequal(data('bytes_long'), repmat(uint8(7), 1, 300)));
    % list -> column cell, tuples -> row cells, sets -> column cells, nested dictionaries
    assert(isequal(data('list'), {1; 'a'; {2; 3}}));
    assert(isequal(data('tuple0'), cell(1, 0)) && isequal(data('tuple1'), {1}) && isequal(data('tuple2'), {1, 2}));
    assert(isequal(data('tuple3'), {1, 2, 3}) && isequal(data('tuple4'), {1, 2, 3, 4}));
    assert(isequal(data('set'), {1; 2; 3}) && isequal(data('frozenset'), {4}) && isempty(data('empty_set')));
    ordered = data('ordered');
    assert(isa(ordered, 'containers.Map') && ordered('x') == 1 && ordered('y') == 2);
    % integer keys become char keys
    intKeys = data('int_keys');
    assert(strcmp(intKeys('1'), 'one') && strcmp(intKeys('2'), 'two'));
    singleItem = data('single_item_dict');
    assert(singleItem('k') == 1);
    % NumPy arrays: C order permuted to MATLAB order, Fortran order, booleans, 0-d, big
    % endian, object arrays (cells); NumPy scalars, an unsupported one (complex) as structure
    assert(isequal(data('array_c'), [0 1 2; 3 4 5]));
    assert(isa(data('array_fortran'), 'int32') && isequal(double(data('array_fortran')), [0 1 2; 3 4 5]));
    assert(isequal(data('array_bool'), [true; false]) && isequal(data('array_0d'), 3.5));
    assert(isa(data('array_big_endian'), 'int32') && isequal(double(data('array_big_endian')), [0; 1; 2; 3]));
    assert(isequal(data('array_object'), {'a'; 1}));
    assert(data('scalar_float') == 1.25 && data('scalar_int16') == -3);
    assert(islogical(data('scalar_bool')) && data('scalar_bool'));
    scalarComplex = data('scalar_complex');
    assert(isstruct(scalarComplex) && contains(scalarComplex.pyClass, 'scalar'));
    % an object of another class: pyClass, and its state (here a dictionary) from BUILD
    custom = data('custom');
    assert(strcmp(custom.pyClass, '__main__.Custom') && custom.state('a') == 1 && strcmp(custom.state('b'), 'x'));
    % shared references (memo, also beyond 256 entries) are read completely
    assert(isequal(data('shared'), {{1; 2}; {1; 2}}));
    many = data('many');
    assert(numel(many) == 300 && strcmp(many{300}, 's299') && isequal(data('many_again'), many));
    assert(isequal(data('late'), {9}) && isequal(data('late_again'), {9}));
end

%% opcodes Python does not write for these objects

% POP: 1 2 POP -> 1
assert(isequal(readBytes([128 4 75 1 75 2 48 46]), 1));
% POP_MARK: 5 MARK 1 2 POP_MARK -> 5
assert(isequal(readBytes([128 4 75 5 40 75 1 75 2 49 46]), 5));
% DUP and TUPLE2: 3 DUP TUPLE2 -> (3, 3)
assert(isequal(readBytes([128 4 75 3 50 134 46]), {3, 3}));
% SHORT_BINSTRING, BINSTRING and BINUNICODE8 'abc'
assert(isequal(readBytes([128 2 85 3 double('abc') 46]), 'abc'));
assert(isequal(readBytes([128 2 84 3 0 0 0 double('abc') 46]), 'abc'));
assert(isequal(readBytes([128 4 141 3 0 0 0 0 0 0 0 double('abc') 46]), 'abc'));
% BINBYTES8 and BYTEARRAY8 followed by READONLY_BUFFER (in-band buffer read as bytes)
assert(isequal(readBytes([128 4 142 2 0 0 0 0 0 0 0 1 2 46]), uint8([1 2])));
assert(isequal(readBytes([128 5 150 2 0 0 0 0 0 0 0 1 2 152 46]), uint8([1 2])));
% BUILD of a dictionary with a dictionary state: {} BUILD({'a': 1}) -> {'a': 1}
data = readBytes([128 4 125 125 140 1 double('a') 75 1 115 98 46]);
assert(isa(data, 'containers.Map') && data.Count == 1 && data('a') == 1);
% SETITEM with an integer key: {7: 'v'} -> key '7'
data = readBytes([128 4 125 75 7 140 1 double('v') 115 46]);
assert(strcmp(data('7'), 'v'));
% GLOBAL and REDUCE of a class the reader does not know: builtins.len(1) -> structure
data = readBytes([128 2 99 double('builtins') 10 double('len') 10 75 1 133 82 46]);
assert(isstruct(data) && strcmp(data.pyClass, 'builtins.len') && isequal(data.args, {1}) && isempty(data.state));
% REDUCE of a callable that is not a global: pyClass 'unknown'; the argument that is not a
% tuple is wrapped in a cell
data = readBytes([128 2 75 1 75 2 82 46]);
assert(strcmp(data.pyClass, 'unknown') && isequal(data.args, {2}));

%% empty bytes and a set built without arguments

% b'' as written by Python 3.12, pickle.dumps(b'', protocol=2): __builtin__.bytes() -> an
% empty uint8 row
data = readBytes([128 2 99 double('__builtin__') 10 double('bytes') 10 113 0 41 82 113 1 46]);
assert(isa(data, 'uint8') && isequal(size(data), [1 0]));
% builtins.set() called without arguments (Python writes set([]) instead): an empty column
data = readBytes([128 2 99 double('builtins') 10 double('set') 10 41 82 46]);
assert(iscell(data) && isequal(size(data), [0 1]));

%% NumPy scalars written by hand: big endian and an unsupported data type

% numpy.core.multiarray.scalar(numpy.dtype('>i2') with state (3, '>'), b'\xff\xfd') = -3:
% the bytes are reversed for a big-endian data type
dtypeBigEndian = [99 double('numpy') 10 double('dtype') 10 140 2 double('i2') 133 82 ...
    75 3 140 1 double('>') 134 98];
scalarGlobal = [99 double('numpy.core.multiarray') 10 double('scalar') 10];
data = readBytes([128 2 scalarGlobal dtypeBigEndian 67 2 255 253 134 82 46]);
assert(isequal(data, -3) && isa(data, 'double'));
% a dtype whose state is not (version, byte order): the byte order stays little endian
dtypeNoState = [99 double('numpy') 10 double('dtype') 10 140 2 double('i2') 133 82 75 3 133 98];
data = readBytes([128 2 scalarGlobal dtypeNoState 67 2 253 255 134 82 46]);
assert(isequal(data, -3));
% a data type the reader does not convert (c8): structure with the class and arguments
dtypeComplex = [99 double('numpy') 10 double('dtype') 10 140 2 double('c8') 133 82];
data = readBytes([128 2 scalarGlobal dtypeComplex 67 2 0 0 134 82 46]);
assert(isstruct(data) && strcmp(data.pyClass, 'numpy.core.multiarray.scalar'));
% BUILD of a value that is neither an array, a dtype, an object nor a dictionary: unchanged
assert(isequal(readBytes([128 4 75 4 75 5 98 46]), 4));

%% errors: input, files that cannot be read, unsupported content

% the file name must be text
assert(verifyCobraFunctionError('readPythonPickle', 'inputs', {1}, 'testMessage', 'fileName must be a string.'));
assert(verifyCobraFunctionError('readPythonPickle', 'inputs', {}, 'testMessage', 'fileName must be a string.'));
% a missing file
missingFile = fullfile(tmpDir, 'missing.p');
assert(verifyCobraFunctionError('readPythonPickle', 'inputs', {missingFile}, ...
    'testMessage', sprintf('File %s could not be opened.', missingFile)));
% a text file and an empty file are not binary pickles
textFile = writePickle(fullfile(tmpDir, 'text.p'), double('not a pickle'));
assert(verifyCobraFunctionError('readPythonPickle', 'inputs', {textFile}, ...
    'testMessage', sprintf('%s is not a binary pickle file (protocol >= 2).', textFile)));
emptyFile = writePickle(fullfile(tmpDir, 'empty.p'), []);
assert(verifyCobraFunctionError('readPythonPickle', 'inputs', {emptyFile}, ...
    'testMessage', sprintf('%s is not a binary pickle file (protocol >= 2).', emptyFile)));
% out-of-band buffers (NEXT_BUFFER), an unsupported opcode (PERSID, 0x50) and a pickle
% without object
oobFile = writePickle(fullfile(tmpDir, 'oob.p'), [128 5 151 46]);
assert(verifyCobraFunctionError('readPythonPickle', 'inputs', {oobFile}, 'testMessage', ...
    sprintf('%s uses out-of-band buffers (pickle protocol 5), which are not supported.', oobFile)));
opcodeFile = writePickle(fullfile(tmpDir, 'opcode.p'), [128 4 80 46]);
assert(verifyCobraFunctionError('readPythonPickle', 'inputs', {opcodeFile}, 'testMessage', ...
    sprintf('Unsupported pickle opcode 0x50 at byte 3 of %s.', opcodeFile)));
noObjectFile = writePickle(fullfile(tmpDir, 'noObject.p'), [128 4 46]);
assert(verifyCobraFunctionError('readPythonPickle', 'inputs', {noObjectFile}, ...
    'testMessage', sprintf('Empty pickle file %s.', noObjectFile)));
% a string scalar file name is accepted
assert(isequal(readPythonPickle(string(writePickle(fullfile(tmpDir, 'test.p'), [128 4 75 1 46]))), 1));

rmdir(tmpDir, 's');

% change the directory
cd(currentDir)

function fileName = writePickle(fileName, bytes)
% write the bytes to the file and return its name (helper of this test)
fid = fopen(fileName, 'w');
fwrite(fid, bytes, 'uint8');
fclose(fid);
end
