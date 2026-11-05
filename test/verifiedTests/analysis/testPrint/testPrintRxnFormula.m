% The COBRAToolbox: testPrintRxnFormula.m
%
% Purpose:
%     - testPrint tests the functionality of printRxnFormula
%       and compares it to expected data.
%
% Function under test:
%     src/analysis/exploration/printRxnFormula.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; ecoli_core_model loaded through getDistributedModel
%     for the reference output, a hand-written toy model for the branches.
%
% Coverage exemptions:
%     None. Every other executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A model without ub loses its lower bounds
%       SEVERITY: wrong-result
%       TRIGGER: a model without the field ub
%       OBSERVED: model.lb is overwritten with +Inf and ub stays missing, so a reversible
%         reaction is printed with -> instead of <=>
%       EXPECTED: model.ub is set to +Inf and model.lb is left as it is
%       LINES: 91
%     - DEFECT: GPRs built from model.rules are wrong or stop with an error
%       SEVERITY: wrong-result
%       TRIGGER: printing with gprFlag on a model without grRules, or with proteinFlag, on any
%         reaction with a rule
%       OBSERVED: num2str($1) gives a character, which indexes the gene list by its character
%         code (x(1) reads gene 49), so another gene is printed or the call fails with "Index
%         exceeds the number of array elements"; the pattern '|' also matches the empty text
%       EXPECTED: the rule printed with the gene or protein names and the words or and and
%       LINES: 221-225, 229-233
%     - DEFECT: Bounds do not follow the file identifier
%       SEVERITY: wrong-result
%       TRIGGER: printBounds true with a file identifier in fid
%       OBSERVED: the bounds are printed on the screen, the formula goes to the file
%       EXPECTED: the bounds go to the file together with the formula
%       LINES: 237
%
% Authors:
%     - Lemmer El Assal March 2017
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPrintRxnFormula'));
cd(fileDir);

% this test needs no solver, toolbox or particular operating system
prepareTest();

model = getDistributedModel('ecoli_core_model.mat');

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

diary('printRxnFormula.txt');
formulas = printRxnFormula(model, model.rxns, true, true, true, 1, true, true);
diary off

text1 = importdata('refData_printRxnFormulaGPR.txt');
text2 = importdata('printRxnFormula.txt');
assert(isequal(text1, text2));

% remove the generated file
delete('printRxnFormula.txt');

%% toy model; R1 is reversible with the upper bound at zero, R2 is irreversible
toyModel = struct('S', sparse([1, -1; 0, 1]), 'rxns', {{'R1'; 'R2'}}, 'mets', {{'A'; 'B'}});
toyModel.lb = [-10; 0];
toyModel.ub = [0; 10];

%% without lb the reactions are taken as reversible
formulas = printRxnFormula(rmfield(toyModel, 'lb'), 'printFlag', false);
assert(isequal(formulas, {' <=> A '; 'A  <=> B '}));

%% directionFlag reverses a reaction that can only run backwards
formulas = printRxnFormula(toyModel, 'directionFlag', true, 'printFlag', false);
assert(isequal(formulas, {'A  <=> '; 'A  -> B '}));

%% without metNames the identifiers are used, with a message
printed = evalc('formulas = printRxnFormula(toyModel, ''metNameFlag'', true, ''printFlag'', false);');
assert(contains(printed, 'metNames requested, but no metNames Field exists in the model'));
assert(isequal(formulas, {' <=> A '; 'A  -> B '}));

%% without proteins the genes are used, with a message
toyModelGenes = toyModel;
toyModelGenes.genes = {'g1'; 'g2'};
printed = evalc('printRxnFormula(toyModelGenes, ''proteinFlag'', true, ''printFlag'', false);');
assert(contains(printed, 'Proteins requested, but no proteins Field exists in the model'));

%% the keyword 'all' and a single reaction name are both accepted as reaction list
formulas = printRxnFormula(toyModel, 'rxnAbbrList', 'all', 'printFlag', false);
assert(isequal(size(formulas), [2, 1]));
formulas = printRxnFormula(toyModel, 'rxnAbbrList', 'R2', 'printFlag', false);
assert(isequal(formulas, {'A  -> B '}));

%% a reaction that is not in the model gives NA and is reported when printing
printed = evalc('formulas = printRxnFormula(toyModel, ''rxnAbbrList'', {''R9''});');
assert(isequal(formulas, {'NA'}));
assert(contains(printed, 'not in model'));
formulas = printRxnFormula(toyModel, 'rxnAbbrList', {'R9'}, 'printFlag', false);
assert(isequal(formulas, {'NA'}));

%% the bounds follow the formula
printed = evalc('printRxnFormula(toyModel, ''rxnAbbrList'', {''R2''}, ''printBounds'', true);');
assert(contains(printed, sprintf('lb:%f\tub:%f', 0, 10)));

%% an entry that stands for more than one reaction stops with an error
errorMessage = '';
try
    printRxnFormula(toyModel, 'rxnAbbrList', {['R1'; 'R2']}, 'printFlag', false);
catch ME
    errorMessage = ME.message;
end
assert(contains(errorMessage, 'duplicated reaction IDs'));

% change the directory
cd(currentDir)
