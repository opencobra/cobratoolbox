% The COBRAToolbox: testPrintRxnFormula.m
%
% Purpose:
%     - testPrint tests the functionality of printRxnFormula
%       and compares it to expected data.
%
% Authors:
%     - Lemmer El Assal March 2017
%

% define the path to The COBRAToolbox
pth = which('initCobraToolbox.m');
CBTDIR = pth(1:end-(length('initCobraToolbox.m') + 1));

cd([CBTDIR, filesep, 'test', filesep, 'verifiedTests', filesep, 'testPrint']);

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
cd(CBTDIR)
