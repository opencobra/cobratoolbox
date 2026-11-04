% The COBRAToolbox: testPrintFluxVector.m
%
% Purpose:
%     - testPrintFluxVector tests the functionality of printFluxVector
%       and compares it to expected data.
%
% Function under test:
%     src/analysis/exploration/printFluxVector.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; ecoli_core_model loaded through getDistributedModel.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: excFlag has no effect unless nonZeroFlag is set
%       SEVERITY: wrong-result
%       TRIGGER: printFluxVector(model, flux, false, true)
%       OBSERVED: every reaction is printed, because the selection of the exchange reactions is
%         only applied when nonZeroFlag is true
%       EXPECTED: only the exchange fluxes are printed, as documented for excFlag
%       LINES: 112-115
%     - DEFECT: Formulas or GPRs of a partly zero flux vector stop with an error
%       SEVERITY: error
%       TRIGGER: nonZeroFlag true with formulaFlag or gprFlag true while at least one reaction
%         is not selected, for example a flux vector with a zero entry
%       OBSERVED: the column of formulas holds fewer texts than rows, so the assignment fails
%         with "Unable to perform assignment because the size of the left side is 95-by-1 and
%         the size of the right side is 92-by-1"
%       EXPECTED: the selected reactions are printed with their formula or GPR
%       LINES: 82-85, 102-105
%
% Authors:
%     - Sylvain Arreckx March 2017
%     - Farid Zare      21/11/2023    old file deleted, A success message is added
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPrintFluxVector'));
cd(fileDir);

% this test needs no solver, toolbox or particular operating system
prepareTest();

model = getDistributedModel('ecoli_core_model.mat');

% remove old generated file
delete('printFluxVector.txt');

% initialize the random number generator to make the results in this test repeatable.
rng('default');
%NOTE: This will create Infeasible fluxes for irreversible reactions, thus
%showing very odd fluxes with an irrev reaction carrying negative flux. But
%thats ok for the test.
flux = randn(length(model.rxns), 1);

diary('printFluxVector.txt');
printFluxVector(model, flux);
diary off

%Initialize the test
fprintf(' -- Running testPrintFluxVector.m:');

text1 = importdata('refData_printFluxVector.txt');
text2 = importdata('printFluxVector.txt');
assert(isequal(text1, text2));

% remove the old file
delete('printFluxVector.txt');

printFluxVector(model, flux, true, false, 1, 'printFluxVector.txt', [], true);
text1 = importdata('refData_printFluxVectorFormula.txt');
text2 = importdata('printFluxVector.txt');
assert(isequal(text1, text2));

% remove the generated file
delete('printFluxVector.txt');

%% an empty flux vector prints nothing
assert(isempty(evalc('printFluxVector(model, [])')));

%% exchange reactions only, among the nonzero fluxes
printed = evalc('printFluxVector(model, flux, true, true)');
assert(contains(printed, 'EX_glc(e)'));
assert(~contains(printed, 'GAPD'));

%% a logical vector selects the rows to print
selection = ismember(model.rxns, {'GAPD'; 'PGK'});
printed = evalc('printFluxVector(model, flux, selection)');
assert(contains(printed, 'GAPD') && contains(printed, 'PGK'));
assert(~contains(printed, 'FBA'));

%% formulas of all reactions, whether or not their flux is zero
formulas = printRxnFormula(model, {'GAPD'}, false, false);
zeroFlux = flux;
zeroFlux(strcmp(model.rxns, 'GAPD')) = 0;
printed = evalc('printFluxVector(model, zeroFlux, false, false, -1, [], [], true)');
assert(contains(printed, strtrim(formulas{1})));

%% GPRs of all reactions, whether or not their flux is zero
printed = evalc('printFluxVector(model, zeroFlux, false, false, -1, [], [], false, true)');
assert(contains(printed, model.grRules{strcmp(model.rxns, 'PFL')}));

%% GPRs of the nonzero fluxes, here all reactions
printed = evalc('printFluxVector(model, flux, true, false, -1, [], [], false, true)');
assert(contains(printed, model.grRules{strcmp(model.rxns, 'PFL')}));

% output a success message
fprintf('... Done.\n');

% change the directory
cd(currentDir)
