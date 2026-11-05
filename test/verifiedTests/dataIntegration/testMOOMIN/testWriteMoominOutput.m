% The COBRAToolbox: testWriteMoominOutput.m
%
% Purpose:
%     - Tests the writeMoominOutput function meant for exporting outputs of moomin
%
% Function under test:
%     src/dataIntegration/transcriptomics/MOOMIN/writeMoominOutput.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The json format writes colour names without quotes
%       SEVERITY: wrong-result
%       TRIGGER: format json with the default colours as strings
%       OBSERVED: the file reads {"rxn1": red, "rxn2": blue, "rxn3": yellow}, which is not valid JSON;
%         the reference file ref_test_json.out, from the original test, holds the same text
%       EXPECTED: quoted values, {"rxn1": "red", "rxn2": "blue", "rxn3": "yellow"}
%       LINES: 140-141, 148-149
%
% Author:
%     - Original file: Taneli Pusa 09/2019
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.

global CBTDIR

% initialize the test
currentDir = pwd;
fileDir = fileparts(which('testWriteMoominOutput.m'));
cd(fileDir);
testPath = pwd;

% this test needs no solver, toolbox or particular operating system
prepareTest();

% the output goes to a temporary file, never next to the tracked reference files
outFile = [tempname '.out'];
removeOutFile = onCleanup(@() delete(outFile));

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
writeMoominOutput(model, outFile);
test = importdata(outFile);
ref = importdata('ref_test.out');
assert(isequal(test, ref));
writeMoominOutput(model, outFile, 'format', 'json');
test = importdata(outFile);
ref = importdata('ref_test_json.out');
assert(isequal(test, ref));
writeMoominOutput(model, outFile, 'format', 'full');
test = readtable(outFile, 'FileType', 'text');
ref = readtable('ref_test_full.out', 'FileType', 'text');
assert(isequaln(test, ref));    % because of the nan variables , isequaln must be used for comparison
writeMoominOutput(model, outFile, 'type', 'input');
test = importdata(outFile);
ref = importdata('ref_test_input.out');
assert(isequal(test, ref));
writeMoominOutput(model, outFile, 'nSolution', 2);
test = importdata(outFile);
ref = importdata('ref_test_sol2.out');
assert(isequal(test, ref));
writeMoominOutput(model, outFile, 'string', 0);
test = importdata(outFile);
ref = importdata('ref_test_numbers.out');
assert(isequal(test, ref));

%% a model without a solution is refused
modelNoSolution = rmfield(model, 'outputColours');
assert(verifyCobraFunctionError('writeMoominOutput', 'inputs', {modelNoSolution, outFile}, ...
    'testMessage', 'Model contains no solutions.'));
modelNoSolution.outputColours = [];
assert(verifyCobraFunctionError('writeMoominOutput', 'inputs', {modelNoSolution, outFile}, ...
    'testMessage', 'Model contains no solutions.'));

%% wrong optional inputs are refused
% an option without a value
assert(verifyCobraFunctionError('writeMoominOutput', 'inputs', {model, outFile, 'format'}, ...
    'testMessage', 'Check optional inputs.'));
% a solution the model does not hold: there are two
assert(verifyCobraFunctionError('writeMoominOutput', 'inputs', {model, outFile, 'nSolution', 3}, ...
    'testMessage', 'There are only 2 solutions.'));
% an unknown option name
assert(verifyCobraFunctionError('writeMoominOutput', 'inputs', {model, outFile, 'colour', 1}, ...
    'testMessage', sprintf('Could not recognise optional input names.\nNo input named "colour"')));
% unknown values of the options type and format
assert(verifyCobraFunctionError('writeMoominOutput', 'inputs', {model, outFile, 'type', 'best'}, ...
    'testMessage', 'Unknown type option "best"'));
assert(verifyCobraFunctionError('writeMoominOutput', 'inputs', {model, outFile, 'format', 'xml'}, ...
    'testMessage', 'Unknown format option "xml"'));

%% type combined writes the consensus colours
writeMoominOutput(model, outFile, 'type', 'combined');
written = strsplit(strtrim(fileread(outFile)), newline);
assert(isequal(written, {sprintf('rxnID\tcombined'), sprintf('R_rxn1\tred'), ...
    sprintf('R_rxn2\tyellow'), sprintf('R_rxn3\tyellow')}));

%% type frequency writes numbers even when colours are asked for as strings
writeMoominOutput(model, outFile, 'type', 'frequency');
written = strsplit(strtrim(fileread(outFile)), newline);
assert(isequal(written, {sprintf('rxnID\tfrequency'), sprintf('R_rxn1\t1'), ...
    sprintf('R_rxn2\t1'), sprintf('R_rxn3\t0.5')}));

%% json output of colour codes keeps the numbers
writeMoominOutput(model, outFile, 'format', 'json', 'string', 0);
assert(isequal(fileread(outFile), '{"rxn1": 1, "rxn2": -1, "rxn3": 6}'));

%% the colour code 2 is a strongly up-regulated reaction
modelStrong = model;
modelStrong.outputColours(1, 1) = 2;
writeMoominOutput(modelStrong, outFile);
written = strsplit(strtrim(fileread(outFile)), newline);
assert(isequal(written, {sprintf('rxnID\toutput'), sprintf('R_rxn1\tr.red'), ...
    sprintf('R_rxn2\tblue'), sprintf('R_rxn3\tyellow')}));

%% the full format with colour codes writes numbers instead of colour names
writeMoominOutput(model, outFile, 'format', 'full', 'string', 0);
writtenTable = readtable(outFile, 'FileType', 'text');
% the rows are sorted by decreasing weight: rxn3, rxn1, rxn2
assert(isequal(writtenTable.ID, {'R_rxn3'; 'R_rxn1'; 'R_rxn2'}));
assert(isequal(writtenTable.output, [6; 1; -1]));
assert(isequal(writtenTable.input, [-1; 1; 0]));
assert(isequal(writtenTable.consensus, [6; 1; 6]));

fprintf('Done.\n');
clear removeOutFile
cd(currentDir);
