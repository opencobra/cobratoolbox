% The COBRAToolbox: testModel2escher.m
%
% Purpose:
%     - model2escher prepares a model for the Escher map viewer: reaction identifiers that start
%     with a digit get the prefix A_ and the compartment brackets of metabolite identifiers become
%     underscores.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/visualization/EscherMap/model2escher.m
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
fileDir = fileparts(which('testModel2escher'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

model.rxns = {'1abc'; 'x1'; '22'};
model.mets = {'glc[c]'; 'atp[e]'};
out = model2escher(model);

%% reaction identifiers beginning with a digit

assert(isequal(out.rxns, {'A_1abc'; 'x1'; 'A_22'}));

%% compartment brackets

assert(isequal(out.mets, {'glc_c'; 'atp_e'}));

%% longer compartment names are converted as well

model.mets = {'a[mito]'; 'plain'};
out = model2escher(model);
assert(isequal(out.mets, {'a_mito'; 'plain'}));

% change the directory
cd(currentDir)
