% The COBRAToolbox: testCheckFormulae.m
%
% Purpose:
%     - checkFormulae compares the atom counts of two chemical formulas for the elements C, H, O, P,
%     S, K, Na and N, optionally ignoring some elements.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/thermo/formulae/checkFormulae.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Elements other than C, H, O, P, S, K, Na and N are ignored
%       SEVERITY: limitation
%       TRIGGER: two formulas that differ only in another element, for example C6H12O6Cl and C6H12O6
%       OBSERVED: the function returns 1 (equal)
%       EXPECTED: 0 (different)
%       LINES: 31-45
%
% Authors:
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCheckFormulae'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% equal and different formulas

assert(checkFormulae('C6H12O6', 'C6H12O6') == 1);
assert(checkFormulae('C6H12O6', 'C6H12O5') == 0);
% the order of the elements does not matter
assert(checkFormulae('H12C6O6', 'C6H12O6') == 1);
% Na and N are different elements
assert(checkFormulae('NaCl', 'NCl') == 0);

%% elements that are ignored by request

% as a list, or as one text
assert(checkFormulae('C6H12O6', 'C6H12O5', {'O'}) == 1);
assert(checkFormulae('C6H12O6', 'C6H12O5', 'O') == 1);
% the ignored element is the only difference: another difference still counts
assert(checkFormulae('C6H12O6', 'C5H12O5', {'O'}) == 0);

% change the directory
cd(currentDir)
