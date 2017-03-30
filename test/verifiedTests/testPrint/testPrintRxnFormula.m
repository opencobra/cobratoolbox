% The COBRAToolbox: testPrintRxnFormula.m
%
% Purpose:
%     - testPrint tests the functionality of printRxnFormula
%       and compares it to expected data.
%
% Authors:
%     - Lemmer El Assal March 2017
%

% save the current path
currentDir = pwd;

% initialize the test
cd(fileparts(which(mfilename)));

load('ecoli_core_model', 'model');

% remove old generated file
delete('printRxnFormula.txt');

diary('printRxnFormula.txt');
formulas = printRxnFormula(model);
diary off

load('refData_printRxnFormula.mat');
assert(isequal(formulas, formulas_ref));
text1 = fileread('refData_printRxnFormula.txt');
text2 = fileread('printRxnFormula.txt');
assert(isequal(text1, text2));

% remove the generated file
delete('printRxnFormula.txt');

model = rmfield(model, 'rev');
diary('printRxnFormula.txt');
formulas = printRxnFormula(model, model.rxns, true, true, true, 1, true, true);
diary off

text1 = fileread('refData_printRxnFormulaGPR.txt');
text2 = fileread('printRxnFormula.txt');
assert(isequal(text1, text2));

% remove the generated file
delete('printRxnFormula.txt');

% change the directory
cd(currentDir)
