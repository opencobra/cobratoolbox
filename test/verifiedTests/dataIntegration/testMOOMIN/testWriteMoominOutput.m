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
writeMoominOutput(model, 'test.out', 'format', 'json');
writeMoominOutput(model, 'test.out', 'format', 'full');
writeMoominOutput(model, 'test.out', 'type', 'input');
writeMoominOutput(model, 'test.out', 'nSolution', 2);
writeMoominOutput(model, 'test.out', 'string', 1);

% delete the output file
if exist('test.out')
	delete('test.out');
end
fprintf('Done.\n');
cd(currentDir);