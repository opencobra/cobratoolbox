% The COBRAToolbox: testFindOrganicExRxns.m
%
% Purpose:
%     - findOrganicExRxns finds the exchange reactions (single-metabolite reactions) of a model
%     whose metabolite is organic (contains carbon, X, Y or R in its formula), excluding the biomass
%     reaction and reactions to keep.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/dataIntegration/transcriptomics/rFASTCORMICS/findOrganicExRxns.m
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
fileDir = fileparts(which('testFindOrganicExRxns'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% reactions: exchange of glucose (organic), oxygen (inorganic), a metabolite with X, the biomass
% reaction (a single metabolite) and an internal reaction
model.rxns = {'EX_glc'; 'EX_o2'; 'EX_x'; 'bio'; 'r'};
model.mets = {'glc'; 'o2'; 'xx'; 'a'};
model.metFormulas = {'C6H12O6'; 'O2'; 'X'; 'C'};
model.S = [1  0  0 0 -1; ...
           0 -1  0 0  0; ...
           0  0 -1 0  0; ...
           0  0  0 1  1];

%% organic exchange reactions without the biomass reaction

text = evalc("[exOrgaRxns, exOrgaInd] = findOrganicExRxns(model, {'bio'}, {});");
% all single-metabolite reactions except the biomass: glc, o2, x; the organic ones are glc and x
assert(isequal(exOrgaRxns, {'EX_glc'; 'EX_o2'; 'EX_x'}));
assert(isequal(exOrgaInd, [1 3]));
% metabolites with X in the formula are reported as closed inputs
assert(contains(text, 'Warning metabolites with X in their Formulas these inputs are closed'));

%% no biomass reaction in the model: a warning, and the biomass-like reaction is kept in the list

lastwarn('');
text = evalc("[exOrgaRxns, exOrgaInd] = findOrganicExRxns(model, {'notInModel'}, {});");
assert(contains(lastwarn, 'No biomass set for the model'));
assert(isequal(exOrgaRxns, {'EX_glc'; 'EX_o2'; 'EX_x'; 'bio'}));
assert(isequal(exOrgaInd, [1 3 4]));

%% reactions to keep are excluded

lastwarn('');
text = evalc("[exOrgaRxns, exOrgaInd] = findOrganicExRxns(model, {'notInModel'}, {'EX_o2'});");
assert(contains(lastwarn, 'No biomass set for the model'));
assert(isequal(exOrgaRxns, {'EX_glc'; 'EX_x'; 'bio'}));
assert(isequal(exOrgaInd, [1 3 4]));

%% biomass and reactions to keep together

text = evalc("[exOrgaRxns, exOrgaInd] = findOrganicExRxns(model, {'bio'}, {'EX_glc'});");
assert(isequal(exOrgaRxns, {'EX_o2'; 'EX_x'}));
assert(isequal(exOrgaInd, 3));

%% formulas with Y

model2 = model;
model2.metFormulas{3} = 'Y2';
text = evalc("[~, exOrgaInd] = findOrganicExRxns(model2, {'bio'}, {});");
assert(contains(text, 'Warning metabolites with Y in their Formulas these inputs are closed'));
assert(isequal(exOrgaInd, [1 3]));

% change the directory
cd(currentDir)
