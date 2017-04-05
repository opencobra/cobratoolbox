% The COBRAToolbox: testPrintFluxVector.m
%
% Purpose:
%     - testPrintFluxVector tests the functionality of printFluxVector
%       and compares it to expected data.
%
% Authors:
%     - Sylvain Arreckx March 2017
%

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPrintFluxVector'));
cd(fileDir);

load([CBTDIR, filesep, 'test' filesep 'models' filesep 'ecoli_core_model.mat'], 'model');

% remove old generated file
delete('printFluxVector.txt');

% initialize the random number generator to make the results in this test repeatable.
rng('default');
flux = randn(length(model.rxns), 1);

diary('printFluxVector.txt');
printFluxVector(model, flux);
diary off

text1 = importdata('refData_printFluxVector.txt');
text2 = importdata('printFluxVector.txt');
assert(isequal(text1, text2));

printFluxVector(model, flux, true, false, 1, 'printFluxVector.txt', [], true);
text1 = importdata('refData_printFluxVectorFormula.txt');
text2 = importdata('printFluxVector.txt');
assert(isequal(text1, text2));

% remove the generated file
delete('printFluxVector.txt');

% change the directory
cd(currentDir)
