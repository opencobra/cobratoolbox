% The COBRAToolbox: testPrintFluxVector.m
%
% Purpose:
%     - testPrintFluxVector tests the functionality of printFluxVector
%       and compares it to expected data.
%
% Authors:
%     - Sylvain Arreckx March 2017
%     - Farid Zare      21/11/2023    old file deleted, A success message is added
%

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPrintFluxVector'));
cd(fileDir);

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

% output a success message
fprintf('... Done.\n');

% change the directory
cd(currentDir)
