% The COBRAToolbox: testFixChemFormulas.m
%
% Purpose:
%     - fixChemFormulas removes the implicit count of 1 after the elements C, H, N, O, P and S in
%     chemical formulas.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/comparison/modelBorgifier/fixChemFormulas.m
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
fileDir = fileparts(which('testFixChemFormulas'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% a count of one is removed after the six elements

formulas = fixChemFormulas({'C1H4O1', 'N1P1S1', 'H1', 'C1'});
assert(isequal(formulas, {'CH4O', 'NPS', 'H', 'C'}));

%% larger counts and other elements are kept

formulas = fixChemFormulas({'C10H1', 'Na1Cl1', 'C12H22O11'});
assert(isequal(formulas, {'C10H', 'Na1Cl1', 'C12H22O11'}));

%% a single text

assert(strcmp(fixChemFormulas('C6H12O6'), 'C6H12O6'));
assert(strcmp(fixChemFormulas('C1'), 'C'));

% change the directory
cd(currentDir)
