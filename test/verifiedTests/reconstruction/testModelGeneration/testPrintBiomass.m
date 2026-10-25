% The COBRAToolbox: testPrintBiomass.m
%
% Purpose:
%     - printBiomass prints the metabolites and stoichiometric coefficients (in scientific notation)
%     of a biomass reaction and returns them.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/modelGeneration/modelProperties/printBiomass.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPrintBiomass'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

model.mets = {'atp[c]'; 'glc[c]'; 'bio[c]'};
model.S = [-50 0; 0 -1; 1 0];

%% components and fractions of the first reaction

text = evalc('[component, fraction] = printBiomass(model, 1);');
assert(isequal(component, {'atp[c]'; 'bio[c]'}));
assert(isequal(fraction, [-50; 1]));
% one line per component: name, tab and the coefficient in scientific notation
assert(strcmp(text, sprintf('atp[c]\t-5.000000e+01\nbio[c]\t1.000000e+00\n')));

%% the matrix A takes precedence over S when present

model.A = [0 0; 0 -2; 0 0];
text = evalc('[component, fraction] = printBiomass(model, 2);');
assert(isequal(component, {'glc[c]'}) && fraction == -2);
assert(strcmp(text, sprintf('glc[c]\t-2.000000e+00\n')));

%% sparse matrices

sparseModel.mets = {'x[c]'; 'y[c]'};
sparseModel.S = sparse([0; 3]);
text = evalc('[component, fraction] = printBiomass(sparseModel, 1);');
assert(isequal(component, {'y[c]'}) && full(fraction) == 3);

% change the directory
cd(currentDir)
