% The COBRAToolbox: testReadPythonFiles.m
%
% Purpose:
%     - tests readNumpyArray, readPythonPickle, numpyBufferToArray and
%       readCobrapyJSONModel with small files written by NumPy and Python
%       (folder pythonFiles: all NumPy data types, C and Fortran order, big
%       endian, versions 1.0 to 3.0 of the .npy format; pickle protocols 2 to
%       5 with all the supported Python objects) and with files written by
%       the test (rare pickle opcodes, cobrapy JSON models and invalid files)
%
% Authors:
%     - Sebastián N. Mendoza, 13/10/2026
%     - COBRA test format (wrong inputs): Sebastián N. Mendoza, 19/10/2026
%     - NumPy and pickle files written by Python: Sebastián N. Mendoza, 21/10/2026
%

global CBTDIR

% save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));
testPath = pwd;
pythonDir = [testPath filesep 'pythonFiles'];
tmpDir = tempname;
mkdir(tmpDir);

% wrong inputs: missing files and files of another format
textFile = fullfile(tmpDir, 'notPython.txt');
fid = fopen(textFile, 'w');
fprintf(fid, 'not a Python file');
fclose(fid);
assert(verifyCobraFunctionError('readNumpyArray', 'inputs', {fullfile(tmpDir, 'missing.npy')}));
assert(verifyCobraFunctionError('readNumpyArray', 'inputs', {textFile}));
assert(verifyCobraFunctionError('readNumpyArray', 'inputs', {1}));
assert(verifyCobraFunctionError('readPythonPickle', 'inputs', {textFile}));
assert(verifyCobraFunctionError('readPythonPickle', 'inputs', {fullfile(tmpDir, 'missing.p')}));
assert(verifyCobraFunctionError('readPythonPickle', 'inputs', {1}));
assert(verifyCobraFunctionError('readCobrapyJSONModel', 'inputs', {fullfile(tmpDir, 'missing.json')}));
assert(verifyCobraFunctionError('numpyBufferToArray', 'inputs', {uint8([1 0]), '<i2', 1}));
assert(verifyCobraFunctionError('numpyBufferToArray', 'inputs', {uint8([1 0]), 2, 1, false}));

% NumPy .npy files
% all data types: [1 2 3] ([True False True] for booleans)
types = {'b1', 'logical'; 'i1', 'int8'; 'u1', 'uint8'; 'i2', 'int16'; 'u2', 'uint16'; 'i4', 'int32'; ...
    'u4', 'uint32'; 'i8', 'int64'; 'u8', 'uint64'; 'f4', 'single'; 'f8', 'double'};
for t = 1:size(types, 1)
    data = readNumpyArray(fullfile(pythonDir, ['npy_type_' types{t, 1} '.npy']));
    assert(isa(data, types{t, 2}));
    if strcmp(types{t, 1}, 'b1')
        assert(isequal(data, [true; false; true]));
    else
        assert(isequal(double(data), [1; 2; 3]));
    end
end
% C and Fortran order, three dimensions, big endian, 0-d arrays and versions 2.0 and 3.0
assert(isequal(readNumpyArray(fullfile(pythonDir, 'npy_c_order.npy')), [0 1 2; 3 4 5]));
data = readNumpyArray(fullfile(pythonDir, 'npy_fortran_order.npy'));
assert(isa(data, 'int32') && isequal(double(data), [0 1 2; 3 4 5]));
data = readNumpyArray(fullfile(pythonDir, 'npy_3d.npy'));
[i, j, k] = ndgrid(1:2, 1:3, 1:4);
assert(isequal(size(data), [2 3 4]) && isequal(double(data), (i - 1) * 12 + (j - 1) * 4 + (k - 1)));
data = readNumpyArray(fullfile(pythonDir, 'npy_big_endian.npy'));
assert(isa(data, 'int64') && isequal(double(data), [0 1; 2 3]));
data = readNumpyArray(fullfile(pythonDir, 'npy_0d.npy'));
assert(isa(data, 'single') && isscalar(data) && data == 2.5);
assert(isequal(readNumpyArray(fullfile(pythonDir, 'npy_version2.npy')), [1.5 2.5]));
assert(isequal(readNumpyArray(fullfile(pythonDir, 'npy_version3.npy')), [1.5 2.5]));
% unsupported data type, truncated file and header that cannot be parsed
assert(verifyCobraFunctionError('readNumpyArray', 'inputs', {fullfile(pythonDir, 'npy_complex.npy')}));
assert(verifyCobraFunctionError('readNumpyArray', 'inputs', {fullfile(pythonDir, 'npy_truncated.npy')}));
badHeaderFile = fullfile(tmpDir, 'badHeader.npy');
fid = fopen(badHeaderFile, 'w', 'l');
fwrite(fid, [147, double('NUMPY'), 1, 0], 'uint8');
fwrite(fid, 8, 'uint16');
fwrite(fid, '{}      ', 'char');
fclose(fid);
assert(verifyCobraFunctionError('readNumpyArray', 'inputs', {badHeaderFile}));
% .npy file written by MATLAB: 2 x 3 int64 array in C order
header = '{''descr'': ''<i8'', ''fortran_order'': False, ''shape'': (2, 3), }';
header = [header, repmat(' ', 1, 64 - mod(10 + numel(header) + 1, 64)), newline];
npyFile = fullfile(tmpDir, 'test.npy');
fid = fopen(npyFile, 'w', 'l');
fwrite(fid, [147, double('NUMPY'), 1, 0], 'uint8');
fwrite(fid, numel(header), 'uint16');
fwrite(fid, header, 'char');
fwrite(fid, int64([1 2 3 4 5 6]), 'int64');
fclose(fid);
data = readNumpyArray(npyFile);
assert(isequal(size(data), [2 3]) && isequal(double(data), [1 2 3; 4 5 6]));

% pickle files written by Python (protocols 2 to 5)
for protocol = 2:5
    data = readPythonPickle(fullfile(pythonDir, sprintf('pickle_protocol%d.p', protocol)));
    assert(isa(data, 'containers.Map') && data.Count == 43);
    % numbers, booleans and None
    assert(data('int_small') == 7 && data('int_medium') == 300 && data('int_negative') == -5);
    assert(data('int_large') == 70000 && data('long_positive') == 2 ^ 40 && data('long_negative') == -2 ^ 40);
    assert(data('float') == 2.5 && data('true') == true && data('false') == false && isempty(data('none')));
    assert(islogical(data('true')));
    % strings and bytes
    assert(strcmp(data('str_short'), 'abc') && strcmp(data('str_long'), repmat('x', 1, 300)));
    assert(strcmp(data('str_unicode'), char([74 105 109 233 110 101 122])));
    assert(isequal(data('bytes_short'), uint8([1 2])) && isequal(data('bytes_long'), repmat(uint8(7), 1, 300)));
    % lists, tuples, sets and dictionaries
    assert(isequal(data('list'), {1; 'a'; {2; 3}}));
    assert(isequal(data('tuple0'), cell(1, 0)) && isequal(data('tuple1'), {1}) && isequal(data('tuple2'), {1, 2}));
    assert(isequal(data('tuple3'), {1, 2, 3}) && isequal(data('tuple4'), {1, 2, 3, 4}));
    assert(isequal(data('set'), {1; 2; 3}) && isequal(data('frozenset'), {4}) && isempty(data('empty_set')));
    ordered = data('ordered');
    assert(isa(ordered, 'containers.Map') && ordered('x') == 1 && ordered('y') == 2);
    intKeys = data('int_keys');
    assert(strcmp(intKeys('1'), 'one') && strcmp(intKeys('2'), 'two'));
    singleItem = data('single_item_dict');
    assert(singleItem('k') == 1);
    % NumPy arrays and scalars
    assert(isequal(data('array_c'), [0 1 2; 3 4 5]));
    assert(isa(data('array_fortran'), 'int32') && isequal(double(data('array_fortran')), [0 1 2; 3 4 5]));
    assert(isequal(data('array_bool'), [true; false]) && isequal(data('array_0d'), 3.5));
    assert(isa(data('array_big_endian'), 'int32') && isequal(double(data('array_big_endian')), [0; 1; 2; 3]));
    assert(isequal(data('array_object'), {'a'; 1}));
    assert(data('scalar_float') == 1.25 && data('scalar_int16') == -3 && data('scalar_bool') == true);
    scalarComplex = data('scalar_complex');
    assert(isstruct(scalarComplex) && contains(scalarComplex.pyClass, 'scalar'));
    % other objects and shared references
    custom = data('custom');
    assert(strcmp(custom.pyClass, '__main__.Custom') && custom.state('a') == 1 && strcmp(custom.state('b'), 'x'));
    assert(isequal(data('shared'), {{1; 2}; {1; 2}}));
    many = data('many');
    assert(numel(many) == 300 && strcmp(many{300}, 's299') && isequal(data('many_again'), many));
    assert(isequal(data('late'), {9}) && isequal(data('late_again'), {9}));
end
assert(verifyCobraFunctionError('readPythonPickle', 'inputs', {fullfile(pythonDir, 'pickle_complex_array.p')}));

% pickle opcodes written by the test
pickles = {[128 4 75 1 75 2 48 46], 1; ...                                          % POP
    [128 4 75 5 40 75 1 75 2 49 46], 5; ...                                          % POP_MARK
    [128 4 75 3 50 134 46], {3, 3}; ...                                              % DUP
    [128 2 85 3 double('abc') 46], 'abc'; ...                                        % SHORT_BINSTRING
    [128 2 84 3 0 0 0 double('abc') 46], 'abc'; ...                                  % BINSTRING
    [128 4 141 3 0 0 0 0 0 0 0 double('abc') 46], 'abc'; ...                         % BINUNICODE8
    [128 4 142 2 0 0 0 0 0 0 0 1 2 46], uint8([1 2]); ...                            % BINBYTES8
    [128 5 150 2 0 0 0 0 0 0 0 1 2 152 46], uint8([1 2]); ...                        % BYTEARRAY8, READONLY_BUFFER
    [128 4 125 125 140 1 double('a') 75 1 115 98 46], 'buildMap'; ...                % BUILD of a dictionary
    [128 4 125 75 7 140 1 double('v') 115 46], 'intKey'; ...                         % SETITEM with an integer key
    [128 2 99 double('builtins') 10 double('len') 10 75 1 82 46], 'builtins.len'; ... % GLOBAL and REDUCE
    [128 2 75 1 41 82 46], 'unknown'};                                               % REDUCE of a non-global
for p = 1:size(pickles, 1)
    pickleFile = fullfile(tmpDir, sprintf('opcodes%d.p', p));
    fid = fopen(pickleFile, 'w');
    fwrite(fid, pickles{p, 1}, 'uint8');
    fclose(fid);
    data = readPythonPickle(pickleFile);
    expected = pickles{p, 2};
    if ischar(expected) && strcmp(expected, 'buildMap')
        assert(isa(data, 'containers.Map') && data('a') == 1);
    elseif ischar(expected) && strcmp(expected, 'intKey')
        assert(strcmp(data('7'), 'v'));
    elseif ischar(expected) && any(strcmp(expected, {'builtins.len', 'unknown'}))
        assert(isstruct(data) && strcmp(data.pyClass, expected));
    else
        assert(isequal(data, expected));
    end
end
% out-of-band buffers, unsupported opcodes and empty pickles
invalid = {[128 5 151 46], [128 4 80 46], [128 4 46]};
for p = 1:numel(invalid)
    pickleFile = fullfile(tmpDir, sprintf('invalid%d.p', p));
    fid = fopen(pickleFile, 'w');
    fwrite(fid, invalid{p}, 'uint8');
    fclose(fid);
    assert(verifyCobraFunctionError('readPythonPickle', 'inputs', {pickleFile}));
end
% pickle (protocol 2) written by the test: {'a': [1, 2.5, 'x'], 'b': None, 'c': (True, 300)}
bytes = [128 2 125 113 0 40 88 1 0 0 0 97 113 1 93 113 2 40 75 1 71 64 4 0 0 0 0 0 0 ...
    88 1 0 0 0 120 113 3 101 88 1 0 0 0 98 113 4 78 88 1 0 0 0 99 113 5 136 77 44 1 134 113 6 117 46];
pickleFile = fullfile(tmpDir, 'test.p');
fid = fopen(pickleFile, 'w');
fwrite(fid, bytes, 'uint8');
fclose(fid);
data = readPythonPickle(pickleFile);
a = data('a');
assert(iscell(a) && numel(a) == 3 && a{1} == 1 && a{2} == 2.5 && strcmp(a{3}, 'x'));
assert(isempty(data('b')));
c = data('c');
assert(c{1} == true && c{2} == 300);

% cobrapy JSON models
% A_e <-> (EX_A), A_e -> B_c (R1), with genes, names and compartments
jsonFile = fullfile(tmpDir, 'test.json');
fid = fopen(jsonFile, 'w');
fprintf(fid, ['{"metabolites": [{"id": "A_e", "name": "A", "compartment": "e", "charge": 0, "formula": "C2"},' ...
    '{"id": "B_c", "name": "B", "compartment": "c"}],' ...
    '"reactions": [{"id": "EX_A", "name": "exchange", "metabolites": {"A_e": -1.0}, "lower_bound": -10, "upper_bound": 1000, "gene_reaction_rule": ""},' ...
    '{"id": "R1", "name": "r1", "metabolites": {"A_e": -1, "B_c": 2.5}, "lower_bound": 0, "upper_bound": 1000, "gene_reaction_rule": "g1 or g2", "objective_coefficient": 1, "subsystem": "S1"}],' ...
    '"genes": [{"id": "g1"}, {"id": "g2"}], "id": "test", "name": "test model", "compartments": {"e": "extracellular", "c": "cytosol"}, "version": "1"}']);
fclose(fid);
model = readCobrapyJSONModel(jsonFile, 'printLevel', 1);
assert(isequal(model.mets, {'A_e'; 'B_c'}) && isequal(model.metComps, {'e'; 'c'}));
assert(isequal(model.rxns, {'EX_A'; 'R1'}) && isequal(model.subSystems, {''; 'S1'}));
assert(isequal(full(model.S), [-1 -1; 0 2.5]));
assert(isequal(model.lb, [-10; 0]) && isequal(model.ub, [1000; 1000]) && isequal(model.c, [0; 1]));
assert(isequal(model.genes, {'g1'; 'g2'}) && strcmp(model.modelName, 'test model'));
% model without genes (identical metabolite and reaction fields)
fid = fopen(jsonFile, 'w');
fprintf(fid, ['{"metabolites": [{"id": "A_e", "name": "A", "compartment": "e"}, {"id": "B_e", "name": "B", "compartment": "e"}],' ...
    '"reactions": [{"id": "R1", "name": "r1", "metabolites": {"A_e": -1, "B_e": 1}, "lower_bound": -5, "upper_bound": 5, "gene_reaction_rule": ""}], "id": "noGenes"}']);
fclose(fid);
model = readCobrapyJSONModel(jsonFile);
assert(isempty(model.genes) && isequal(model.rules, {''}) && isequal(full(model.S), [-1; 1]));
% invalid models: no reactions, undefined metabolite, reaction without stoichiometry
invalidModels = {'{"metabolites": []}', ...
    '{"metabolites": [{"id": "A_e"}], "reactions": [{"id": "R1", "metabolites": {"X_e": 1}}]}', ...
    '{"metabolites": [{"id": "A_e"}], "reactions": [{"id": "R1"}, {"id": "R2", "metabolites": {"A_e": 1}}]}'};
for m = 1:numel(invalidModels)
    fid = fopen(jsonFile, 'w');
    fprintf(fid, '%s', invalidModels{m});
    fclose(fid);
    assert(verifyCobraFunctionError('readCobrapyJSONModel', 'inputs', {jsonFile}));
end

rmdir(tmpDir, 's');
fprintf('Done.\n');

% change the directory
cd(currentDir)
