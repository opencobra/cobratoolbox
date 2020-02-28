% The COBRAToolbox: testWriteMoominOutput.m
%
% Purpose:
%     - Tests the writeMoominOutput function meant for exporting outputs of moomin
%
% Author:
%     - Original file: Taneli Pusa 09/2019

global CBTDIR

% initialize the test
currentDir = pwd;
fileDir = fileparts(which('testWriteMoominOutput.m'));
cd(fileDir);
testPath = pwd;

% create a toy example
model = struct;
model.rxns = {'rxn1'; 'rxn2'; 'rxn3'};
model.rxnNames = model.rxns;
model.genes = {'g1'; 'g2'; 'g3'; 'g4'};
model.rules = {'x(1) | x(2)'; ''; '((x(1) & x(2)) | (x(3) & x(4)))'};
model.subSystems = {'ss1'; 'ss2'; ''};
model.inputColours = [1; 0; -1];
model.weights = [1; -1; 2];
model.outputColours = [1, 1; -1, -2; 6, 0];
model.leadingGenes = [1; 0; 3];
model.frequency = [1; 1; 0.5];
model.combined = [1; 6; 6];
expression.GeneID = {'g1'; 'g2'; 'g3'; 'g4'};
expression.PPDE = [0.9; 0.9; 0.1; 0.1];
expression.FC = [1; -1; 0.1; -0.1];
model.expression = expression;

% test with different input variants
fprintf(' -- Running testWriteMoominOutput ... ');
writeMoominOutput(model, 'test.out');
test = importdata('test.out');
ref = importdata('ref_test.out');
assert(isequal(test, ref));
writeMoominOutput(model, 'test.out', 'format', 'json');
test = importdata('test.out');
ref = importdata('ref_test_json.out');
assert(isequal(test, ref));
writeMoominOutput(model, 'test.out', 'format', 'full');
test = readtable('test.out', 'FileType', 'text');
ref = readtable('ref_test_full.out', 'FileType', 'text');
assert(isequal(test, ref));
writeMoominOutput(model, 'test.out', 'type', 'input');
test = importdata('test.out');
ref = importdata('ref_test_input.out');
assert(isequal(test, ref));
writeMoominOutput(model, 'test.out', 'nSolution', 2);
test = importdata('test.out');
ref = importdata('ref_test_sol2.out');
assert(isequal(test, ref));
writeMoominOutput(model, 'test.out', 'string', 0);
test = importdata('test.out');
ref = importdata('ref_test_numbers.out');
assert(isequal(test, ref));

% delete the output file
if exist('test.out')
	delete('test.out');
end
fprintf('Done.\n');
cd(currentDir);