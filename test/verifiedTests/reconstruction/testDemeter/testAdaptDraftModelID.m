% The COBRAToolbox: testAdaptDraftModelID.m
%
% Purpose:
%     - adaptDraftModelID turns the file name of a draft model into a microbe identifier by removing
%     known suffixes (.sbml, .RAST, _genome, ...) and replacing blanks and separators by
%     underscores.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/demeter/src/integration/adaptDraftModelID.m
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
fileDir = fileparts(which('testAdaptDraftModelID'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% known suffixes are removed

assert(strcmp(adaptDraftModelID('Bacteroides_caccae.fbamodel.sbml'), 'Bacteroides_caccae'));
assert(strcmp(adaptDraftModelID('Strain_1.model.sbml'), 'Strain_1'));
assert(strcmp(adaptDraftModelID('Species_X.RAST'), 'Species_X'));
assert(strcmp(adaptDraftModelID('Species_X___RAST'), 'Species_X'));
assert(strcmp(adaptDraftModelID('abc_DraftModel'), 'abc'));
assert(strcmp(adaptDraftModelID('abc_genome'), 'abc'));
assert(strcmp(adaptDraftModelID('abc.contigs'), 'abc'));
assert(strcmp(adaptDraftModelID('abc.mat'), 'abc'));

%% separators become underscores

assert(strcmp(adaptDraftModelID('A b-c.d(e)f/g+h'), 'A_b_c_d_e_f_g_h'));

%% repeated underscores are shortened

assert(strcmp(adaptDraftModelID('a___b'), 'a_b'));
assert(strcmp(adaptDraftModelID('a,b'), 'a_b'));

%% an identifier without anything to change

assert(strcmp(adaptDraftModelID('Escherichia_coli'), 'Escherichia_coli'));

% change the directory
cd(currentDir)
