% The COBRAToolbox: testPrintRxnFormula.m
%
% Purpose:
%     - testPrint tests the functionality of printRxnFormula
%       and compares it to expected data.
%
% Authors:
%     - Lemmer El Assal March 2017
%

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPrintRxnFormula'));
cd(fileDir);

load([CBTDIR, filesep, 'test' filesep 'models' filesep 'ecoli_core_model.mat'], 'model');

% remove old generated file
delete('printRxnFormula.txt');

diary('printRxnFormula.txt');
formulas = printRxnFormula(model);
diary off

load('refData_printRxnFormula.mat');
assert(isequal(formulas, formulas_ref));
text1 = importdata('refData_printRxnFormula.txt');
text2 = importdata('printRxnFormula.txt');

assert(isequal(text1, text2));

% remove the generated file
delete('printRxnFormula.txt');

model = rmfield(model, 'rev');
diary('printRxnFormula.txt');
formulas = printRxnFormula(model, model.rxns, true, true, true, 1, true, true);
diary off

text1 = importdata('refData_printRxnFormulaGPR.txt');
text2 = importdata('printRxnFormula.txt');
assert(isequal(text1, text2));

% remove the generated file
delete('printRxnFormula.txt');

% change the directory
cd(currentDir)
