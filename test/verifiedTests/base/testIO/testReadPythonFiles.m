% The COBRAToolbox: testReadPythonFiles.m
%
% Purpose:
%     - tests readNumpyArray, readPythonPickle and readCobrapyJSONModel with
%       small files written by the test
%
% Authors:
%     - Sebastián N. Mendoza, 13/10/2026
%     - COBRA test format (wrong inputs): Sebastián N. Mendoza, 19/10/2026
%

global CBTDIR

% save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));
tmpDir = tempname;
mkdir(tmpDir);

% wrong inputs: missing files and files of another format
textFile = fullfile(tmpDir, 'notPython.txt');
fid = fopen(textFile, 'w');
fprintf(fid, 'not a Python file');
fclose(fid);
assert(verifyCobraFunctionError('readNumpyArray', 'inputs', {fullfile(tmpDir, 'missing.npy')}));
assert(verifyCobraFunctionError('readNumpyArray', 'inputs', {textFile}));
assert(verifyCobraFunctionError('readPythonPickle', 'inputs', {textFile}));
assert(verifyCobraFunctionError('readCobrapyJSONModel', 'inputs', {fullfile(tmpDir, 'missing.json')}));

% .npy file (version 1.0) with a 2 x 3 int64 array in C order: [[1 2 3]; [4 5 6]]
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
assert(isequal(size(data), [2 3]));
assert(isequal(double(data), [1 2 3; 4 5 6]));

% pickle (protocol 2) of {'a': [1, 2.5, 'x'], 'b': None, 'c': (True, 300)}
bytes = [128 2 125 113 0 40 88 1 0 0 0 97 113 1 93 113 2 40 75 1 71 64 4 0 0 0 0 0 0 ...
    88 1 0 0 0 120 113 3 101 88 1 0 0 0 98 113 4 78 88 1 0 0 0 99 113 5 136 77 44 1 134 113 6 117 46];
pickleFile = fullfile(tmpDir, 'test.p');
fid = fopen(pickleFile, 'w');
fwrite(fid, bytes, 'uint8');
fclose(fid);
data = readPythonPickle(pickleFile);
assert(isa(data, 'containers.Map'));
a = data('a');
assert(iscell(a) && numel(a) == 3 && a{1} == 1 && a{2} == 2.5 && strcmp(a{3}, 'x'));
assert(isempty(data('b')));
c = data('c');
assert(c{1} == true && c{2} == 300);

% cobrapy JSON model: A_e <-> (EX_A), A_e -> B_c (R1)
jsonFile = fullfile(tmpDir, 'test.json');
fid = fopen(jsonFile, 'w');
fprintf(fid, ['{"metabolites": [{"id": "A_e", "name": "A", "compartment": "e", "charge": 0, "formula": "C2"},' ...
    '{"id": "B_c", "name": "B", "compartment": "c"}],' ...
    '"reactions": [{"id": "EX_A", "name": "exchange", "metabolites": {"A_e": -1.0}, "lower_bound": -10, "upper_bound": 1000, "gene_reaction_rule": ""},' ...
    '{"id": "R1", "name": "r1", "metabolites": {"A_e": -1, "B_c": 2.5}, "lower_bound": 0, "upper_bound": 1000, "gene_reaction_rule": "g1 or g2", "objective_coefficient": 1}],' ...
    '"genes": [{"id": "g1"}, {"id": "g2"}], "id": "test", "compartments": {"e": "extracellular", "c": "cytosol"}, "version": "1"}']);
fclose(fid);
model = readCobrapyJSONModel(jsonFile);
assert(isequal(model.mets, {'A_e'; 'B_c'}));
assert(isequal(model.rxns, {'EX_A'; 'R1'}));
assert(isequal(full(model.S), [-1 -1; 0 2.5]));
assert(isequal(model.lb, [-10; 0]) && isequal(model.c, [0; 1]));
assert(isequal(model.genes, {'g1'; 'g2'}));

rmdir(tmpDir, 's');
fprintf('Done.\n');
cd(currentDir);
