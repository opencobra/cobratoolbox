% The COBRAToolbox: testPrintObjective.m
%
% Purpose:
%     - printObjective returns the reactions with a non-zero objective coefficient and displays a
%     table of their metabolites, stoichiometric coefficients and reaction numbers; it warns when
%     the model has no objective.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/modelGeneration/printObjective.m
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
fileDir = fileparts(which('testPrintObjective'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

model.mets = {'a[c]'; 'b[c]'; 'bio[c]'};
model.rxns = {'r1'; 'bio'};
model.S = [-1 -2; 1 0; 0 1];
model.c = [0; 1];

%% one objective reaction

text = evalc('objectiveAbbr = printObjective(model);');
assert(isequal(objectiveAbbr, {'bio'}));
% a table with the coefficients and metabolites of the biomass reaction is displayed
assert(contains(text, 'summaryT') && contains(text, 'Coefficient') && contains(text, 'Metabolite'));
assert(contains(text, 'a[c]') && contains(text, 'bio[c]') && contains(text, 'bio'));

%% two objective reactions

model.c = [1; 1];
text = evalc('objectiveAbbr = printObjective(model);');
assert(isequal(objectiveAbbr, {'r1'; 'bio'}));
assert(contains(text, 'r1') && contains(text, 'bio'));

%% no objective

model.c = [0; 0];
lastwarn('');
text = evalc('objectiveAbbr = printObjective(model);');
assert(isempty(objectiveAbbr));
assert(contains(lastwarn, 'There is no objective!'));

% change the directory
cd(currentDir)
