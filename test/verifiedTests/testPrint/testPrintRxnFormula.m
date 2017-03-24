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
initTest(fileparts(which(mfilename)));

load('ecoli_core_model', 'model');

delete('printRxnFormula.txt');
diary('printRxnFormula.txt');
formulas = printRxnFormula(model);
diary off
load printRxnFormula_ref.mat
assert(isequal(formulas,formulas_ref));
text1 = fileread('printRxnFormula_ref.txt');
text2 = fileread('printRxnFormula.txt');
assert(isequal(text1,text2));

% change the directory
cd(currentDir)
