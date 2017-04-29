% The COBRAToolbox: testLegalRxnFormula.m
%
% Purpose:
%     - testReactionEq tests the functionality of LegalRxnFormula in the
%     rBioNet extension
%
% Authors:
%     - Stefania Magnusdottir April 2017
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testReactionEq'));
cd(fileDir);

% load E. coli model
load('ecoli_core_model.mat', 'model')

% check validity of reaction formulas
formula = printRxnFormula(model, model.rxns(1));
result = LegalRxnFormula(formula, model.rxns(1));

% test output
assert(result)

% change the directory
cd(currentDir)
